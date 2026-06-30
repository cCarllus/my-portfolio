require "base64"
require "json"
require "sqlite3"
require "tempfile"

module Admin
  module PortfolioBackup
    class Export
      Result = Data.define(:data, :filename, :content_type)

      FORMAT = "my_portfolio_backup"
      VERSION = "1"
      SCHEMA = [
        "CREATE TABLE metadata (key TEXT PRIMARY KEY, value TEXT NOT NULL);",
        "CREATE TABLE records (record_key TEXT PRIMARY KEY, record_type TEXT NOT NULL, position INTEGER NOT NULL, payload TEXT NOT NULL);",
        "CREATE TABLE files (owner_key TEXT NOT NULL, attachment_name TEXT NOT NULL, filename TEXT NOT NULL, content_type TEXT, data BLOB NOT NULL);"
      ].freeze

      def initialize(profile: PortfolioProfile.current!)
        @profile = profile
      end

      def call(format:)
        dataset = build_dataset
        timestamp = Time.current.strftime("%Y%m%d-%H%M%S")

        case format.to_sym
        when :sql
          Result.new(
            data: serialize_sql(dataset),
            filename: "portfolio-#{timestamp}.sql",
            content_type: "application/sql"
          )
        when :sqlite
          Result.new(
            data: serialize_sqlite(dataset),
            filename: "portfolio-#{timestamp}.sqlite3",
            content_type: "application/vnd.sqlite3"
          )
        else
          raise ArgumentError, "unsupported backup format"
        end
      end

      private

      attr_reader :profile

      def build_dataset
        records = [ record_for(profile, "profile", 0) ]

        {
          metadata: { "format" => FORMAT, "version" => VERSION, "exported_at" => Time.current.iso8601 },
          records: records + collection_records,
          files: attachment_files
        }
      end

      def collection_records
        {
          skills: "Skill",
          experiences: "Experience",
          highlights: "Highlight",
          educations: "Education",
          portfolio_documents: "PortfolioDocument"
        }.flat_map do |association, record_type|
          profile.public_send(association).ordered.map do |record|
            record_for(record, "#{record_type.underscore}:#{record.id}", record.position)
          end
        end
      end

      def record_for(record, key, position)
        {
          key:,
          type: record.class.name,
          position:,
          payload: record.attributes.except("id", "portfolio_profile_id", "created_at", "updated_at")
        }
      end

      def attachment_files
        files = []
        append_attachment(files, "profile", "avatar", profile.avatar)
        append_attachment(files, "profile", "resume", profile.resume)

        profile.portfolio_documents.includes(file_attachment: :blob).find_each do |document|
          append_attachment(files, "portfolio_document:#{document.id}", "file", document.file)
        end

        files
      end

      def append_attachment(files, owner_key, attachment_name, attachment)
        return unless attachment.attached?

        files << {
          owner_key:,
          attachment_name:,
          filename: attachment.filename.to_s,
          content_type: attachment.content_type,
          data: attachment.download
        }
      end

      def serialize_sql(dataset)
        lines = [ "-- #{FORMAT.upcase}_V#{VERSION}", *SCHEMA ]

        dataset.fetch(:metadata).each do |key, value|
          lines << "INSERT INTO metadata (key, value) VALUES ('#{encode(key)}', '#{encode(value)}');"
        end

        dataset.fetch(:records).each do |record|
          lines << "INSERT INTO records (record_key, record_type, position, payload) VALUES ('#{encode(record[:key])}', '#{encode(record[:type])}', #{record[:position].to_i}, '#{encode(JSON.generate(record[:payload]))}');"
        end

        dataset.fetch(:files).each do |file|
          values = %i[owner_key attachment_name filename content_type data].map { |key| encode(file[key].to_s) }
          lines << "INSERT INTO files (owner_key, attachment_name, filename, content_type, data) VALUES ('#{values.join("', '")}');"
        end

        "#{lines.join("\n")}\n"
      end

      def serialize_sqlite(dataset)
        Tempfile.create([ "portfolio-backup", ".sqlite3" ]) do |file|
          database = SQLite3::Database.new(file.path)
          SCHEMA.each { |statement| database.execute(statement) }

          dataset.fetch(:metadata).each do |key, value|
            database.execute("INSERT INTO metadata (key, value) VALUES (?, ?)", [ key, value ])
          end

          dataset.fetch(:records).each do |record|
            database.execute(
              "INSERT INTO records (record_key, record_type, position, payload) VALUES (?, ?, ?, ?)",
              [ record[:key], record[:type], record[:position], JSON.generate(record[:payload]) ]
            )
          end

          dataset.fetch(:files).each do |backup_file|
            database.execute(
              "INSERT INTO files (owner_key, attachment_name, filename, content_type, data) VALUES (?, ?, ?, ?, ?)",
              [
                backup_file[:owner_key],
                backup_file[:attachment_name],
                backup_file[:filename],
                backup_file[:content_type],
                SQLite3::Blob.new(backup_file[:data])
              ]
            )
          end

          database.close
          File.binread(file.path)
        ensure
          database&.close unless database&.closed?
        end
      end

      def encode(value)
        Base64.strict_encode64(value.to_s)
      end
    end
  end
end
