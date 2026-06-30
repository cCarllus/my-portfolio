class AddResumeSourceToPortfolioDocuments < ActiveRecord::Migration[8.1]
  def change
    add_column :portfolio_documents, :uses_resume, :boolean, null: false, default: false
  end
end
