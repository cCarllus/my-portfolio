require "base64"
require "json"
require "sqlite3"
require "stringio"

module Admin
  module PortfolioBackup
    class Import
      class InvalidBackup < StandardError; end

      MAX_SIZE = 35.megabytes
      MAX_RECORDS = 10_000
      MAX_FILES = 100
      ASSOCIATIONS = {
        "Skill" => :skills,
        "Experience" => :experiences,
        "Highlight" => :highlights,
        "Education" => :educations,
        "PortfolioDocument" => :portfolio_documents
      }.freeze

      SQL_HEADER = "-- #{Export::FORMAT.upcase}_V#{Export::VERSION}"
      SQL_METADATA = /\AINSERT INTO metadata \(key, value\) VALUES \('([A-Za-z0-9+\/=]+)', '([A-Za-z0-9+\/=]+)'\);\z/
      SQL_RECORD = /\AINSERT INTO records \(record_key, record_type, position, payload\) VALUES \('([A-Za-z0-9+\/=]+)', '([A-Za-z0-9+\/=]+)', (\d+), '([A-Za-z0-9+\/=]+)'\);\z/
      SQL_FILE = /\AINSERT INTO files \(owner_key, attachment_name, filename, content_type, data\) VALUES \('([A-Za-z0-9+\/=]+)', '([A-Za-z0-9+\/=]+)', '([A-Za-z0-9+\/=]+)', '([A-Za-z0-9+\/=]*)', '([A-Za-z0-9+\/=]+)'\);\z/

      def initialize(upload:)
        @upload = upload
      end

      def call
        validate_upload!
        dataset = sql_upload? ? read_sql : read_sqlite
        validate_dataset!(dataset)
        restore(dataset)
      rescue JSON::ParserError, SQLite3::Exception, ActiveRecord::ActiveRecordError,
             ActiveStorage::IntegrityError, ArgumentError, KeyError => error
        raise InvalidBackup, error.message
      ensure
        upload.rewind if upload.respond_to?(:rewind)
      end

      private

      attr_reader :upload

      def validate_upload!
        raise InvalidBackup, "missing file" if upload.blank?
        raise InvalidBackup, "file is too large" if upload.size.to_i > MAX_SIZE
        raise InvalidBackup, "unsupported file type" unless %w[.sql .sqlite3].include?(extension)
      end

      def extension
        File.extname(upload.original_filename.to_s).downcase
      end

      def sql_upload?
        extension == ".sql"
      end

      def read_sql
        lines = upload.read.force_encoding(Encoding::UTF_8).lines.map(&:strip)
        raise InvalidBackup, "invalid SQL backup header" unless lines.shift == SQL_HEADER

        dataset = { metadata: {}, records: [], files: [] }
        lines.each do |line|
          next if line.blank? || Export::SCHEMA.include?(line)

          parse_sql_line(dataset, line)
        end
        dataset
      end

      def parse_sql_line(dataset, line)
        case line
        when SQL_METADATA
          dataset[:metadata][decode(Regexp.last_match(1))] = decode(Regexp.last_match(2))
        when SQL_RECORD
          dataset[:records] << {
            key: decode(Regexp.last_match(1)),
            type: decode(Regexp.last_match(2)),
            position: Regexp.last_match(3).to_i,
            payload: JSON.parse(decode(Regexp.last_match(4)))
          }
        when SQL_FILE
          dataset[:files] << {
            owner_key: decode(Regexp.last_match(1)),
            attachment_name: decode(Regexp.last_match(2)),
            filename: decode(Regexp.last_match(3)),
            content_type: decode(Regexp.last_match(4)),
            data: decode(Regexp.last_match(5))
          }
        else
          raise InvalidBackup, "unexpected SQL statement"
        end
      end

      def read_sqlite
        database = SQLite3::Database.new(upload.tempfile.path)
        database.results_as_hash = true

        {
          metadata: database.execute("SELECT key, value FROM metadata").to_h { |row| [ row["key"], row["value"] ] },
          records: database.execute("SELECT record_key, record_type, position, payload FROM records ORDER BY position, record_key").map do |row|
            { key: row["record_key"], type: row["record_type"], position: row["position"], payload: JSON.parse(row["payload"]) }
          end,
          files: database.execute("SELECT owner_key, attachment_name, filename, content_type, data FROM files").map do |row|
            {
              owner_key: row["owner_key"],
              attachment_name: row["attachment_name"],
              filename: row["filename"],
              content_type: row["content_type"],
              data: row["data"]
            }
          end
        }
      ensure
        database&.close
      end

      def validate_dataset!(dataset)
        metadata = dataset.fetch(:metadata)
        raise InvalidBackup, "unknown backup format" unless metadata["format"] == Export::FORMAT
        raise InvalidBackup, "unsupported backup version" unless metadata["version"] == Export::VERSION
        raise InvalidBackup, "too many records" if dataset.fetch(:records).size > MAX_RECORDS
        raise InvalidBackup, "too many files" if dataset.fetch(:files).size > MAX_FILES

        profiles = dataset.fetch(:records).count { |record| record[:type] == "PortfolioProfile" }
        raise InvalidBackup, "backup must contain one profile" unless profiles == 1
        raise InvalidBackup, "unknown record type" if dataset.fetch(:records).any? { |record| unknown_type?(record[:type]) }
      end

      def unknown_type?(record_type)
        record_type != "PortfolioProfile" && !ASSOCIATIONS.key?(record_type)
      end

      def restore(dataset)
        restored = {}

        PortfolioProfile.transaction do
          profile_record = dataset.fetch(:records).find { |record| record[:type] == "PortfolioProfile" }
          profile = PortfolioProfile.current || PortfolioProfile.new
          ASSOCIATIONS.values.each { |association| profile.public_send(association).destroy_all if profile.persisted? }
          profile.avatar.detach if profile.avatar.attached?
          profile.resume.detach if profile.resume.attached?
          profile.update!(permitted_attributes(PortfolioProfile, profile_record.fetch(:payload)))
          restored[profile_record.fetch(:key)] = profile

          dataset.fetch(:records).reject { |record| record[:type] == "PortfolioProfile" }.each do |record|
            model = record.fetch(:type).constantize
            association = ASSOCIATIONS.fetch(record.fetch(:type))
            restored[record.fetch(:key)] = profile.public_send(association).create!(
              permitted_attributes(model, record.fetch(:payload))
            )
          end

          restore_files(dataset.fetch(:files), restored)
        end

        PortfolioProfile.current!
      end

      def restore_files(files, restored)
        files.each do |file|
          owner = restored.fetch(file.fetch(:owner_key))
          attachment_name = file.fetch(:attachment_name)
          validate_attachment!(owner, attachment_name)
          attachment = owner.public_send(attachment_name)
          attachment.detach if attachment.attached?
          attachment.attach(
            io: StringIO.new(file.fetch(:data)),
            filename: file.fetch(:filename),
            content_type: file.fetch(:content_type).presence
          )
        end
      end

      def validate_attachment!(owner, attachment_name)
        allowed = owner.is_a?(PortfolioProfile) ? %w[avatar resume] : %w[file]
        raise InvalidBackup, "unknown attachment" unless allowed.include?(attachment_name)
      end

      def permitted_attributes(model, payload)
        allowed = model.column_names - %w[id portfolio_profile_id created_at updated_at]
        unknown = payload.keys - allowed
        raise InvalidBackup, "unknown attributes for #{model.name}" if unknown.any?

        payload.slice(*allowed)
      end

      def decode(value)
        Base64.strict_decode64(value)
      end
    end
  end
end
