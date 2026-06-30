require "rails_helper"

RSpec.describe "Admin database backups", type: :request do
  before do
    allow_any_instance_of(AdminPolicy).to receive(:authorized?).and_return(true)
    create_portfolio_content
  end

  it "renders the backup management page" do
    get admin_database_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Exportar .sql")
    expect(response.body).to include("Exportar .sqlite3")
  end

  it "downloads the portable SQL backup" do
    get export_sql_admin_database_path

    expect(response).to have_http_status(:ok)
    expect(response.media_type).to eq("application/sql")
    expect(response.headers.fetch("Content-Disposition")).to include(".sql")
    expect(response.body).to start_with("-- MY_PORTFOLIO_BACKUP_V1")
  end

  it "requires explicit confirmation before importing" do
    post import_admin_database_path

    expect(response).to redirect_to(admin_database_path)
    expect(flash[:alert]).to eq("Confirme que deseja substituir os dados atuais.")
  end
end
