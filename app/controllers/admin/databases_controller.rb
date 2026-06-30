module Admin
  class DatabasesController < BaseController
    def show; end

    def export_sql
      send_backup(:sql)
    end

    def export_sqlite
      send_backup(:sqlite)
    end

    def import
      unless ActiveModel::Type::Boolean.new.cast(params[:confirm_replace])
        return redirect_to admin_database_path, alert: t("admin.database.confirm_required")
      end

      PortfolioBackup::Import.new(upload: params[:backup]).call
      redirect_to admin_database_path, notice: t("admin.database.imported")
    rescue PortfolioBackup::Import::InvalidBackup
      redirect_to admin_database_path, alert: t("admin.database.invalid")
    end

    private

    def send_backup(format)
      result = PortfolioBackup::Export.new.call(format:)
      send_data result.data, filename: result.filename, type: result.content_type, disposition: "attachment"
    end
  end
end
