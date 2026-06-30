class ExpandHighlightsIntoProjects < ActiveRecord::Migration[8.1]
  def change
    change_table :highlights, bulk: true do |t|
      t.string :source, null: false, default: "manual"
      t.string :external_url
      t.integer :github_repository_id
      t.string :primary_language
      t.string :category, null: false, default: "highlight"
      t.string :category_color
      t.datetime :github_synced_at
    end

    add_index :highlights,
      [ :portfolio_profile_id, :github_repository_id ],
      unique: true,
      name: "index_highlights_on_profile_and_github_repository"
  end
end
