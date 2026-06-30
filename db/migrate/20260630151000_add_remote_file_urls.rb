class AddRemoteFileUrls < ActiveRecord::Migration[8.1]
  def change
    change_table :portfolio_profiles, bulk: true do |t|
      t.string :avatar_url
      t.string :resume_url
    end

    add_column :portfolio_documents, :file_url, :string
  end
end
