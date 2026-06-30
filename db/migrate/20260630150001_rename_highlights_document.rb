class RenameHighlightsDocument < ActiveRecord::Migration[8.1]
  class Document < ActiveRecord::Base
    self.table_name = "portfolio_documents"
  end

  def up
    Document.where(content_kind: "highlights").find_each do |document|
      document.update_columns(titles: document.titles.merge(
        "pt" => "Projetos / Destaques",
        "en" => "Projects / Highlights"
      ))
    end
  end

  def down
    Document.where(content_kind: "highlights").find_each do |document|
      document.update_columns(titles: document.titles.merge(
        "pt" => "Destaques",
        "en" => "Highlights"
      ))
    end
  end
end
