class AddContentKindToPortfolioDocuments < ActiveRecord::Migration[8.1]
  SYSTEM_DOCUMENTS = {
    "about" => { pt: "Sobre mim", en: "About me" },
    "experience" => { pt: "Experiência", en: "Experience" },
    "skills" => { pt: "Competências", en: "Skills" },
    "highlights" => { pt: "Destaques", en: "Highlights" },
    "education" => { pt: "Formação", en: "Education" },
    "resume" => { pt: "Currículo", en: "Resume" }
  }.freeze

  class MigrationProfile < ActiveRecord::Base
    self.table_name = "portfolio_profiles"
  end

  class MigrationDocument < ActiveRecord::Base
    self.table_name = "portfolio_documents"
  end

  def up
    add_column :portfolio_documents, :content_kind, :string, default: "custom", null: false
    add_index :portfolio_documents, %i[portfolio_profile_id content_kind]

    MigrationDocument.reset_column_information
    MigrationProfile.find_each { |profile| create_system_documents(profile) }
  end

  def down
    remove_index :portfolio_documents, %i[portfolio_profile_id content_kind]
    remove_column :portfolio_documents, :content_kind
  end

  private

  def create_system_documents(profile)
    existing_documents = MigrationDocument.where(portfolio_profile_id: profile.id).to_a

    SYSTEM_DOCUMENTS.each_with_index do |(kind, titles), position|
      document = find_existing_document(existing_documents, kind)
      document ||= MigrationDocument.new(portfolio_profile_id: profile.id)

      document.update!(
        content_kind: kind,
        titles: document.titles.presence || titles,
        bodies: initial_body(document, profile, kind),
        position:,
        published: true,
        uses_resume: kind == "resume"
      )
    end

    MigrationDocument
      .where(portfolio_profile_id: profile.id, content_kind: "custom")
      .update_all("position = position + 100")
  end

  def find_existing_document(documents, kind)
    return documents.find(&:uses_resume?) if kind == "resume"

    documents.find { |document| inferred_kind(document) == kind }
  end

  def inferred_kind(document)
    title = document.titles.to_h["pt"].to_s.downcase

    return "about" if title.include?("sobre mim")
    return "experience" if title.include?("experi")
    return "skills" if title.include?("compet") || title.include?("skill")
    return "highlights" if title.include?("destaque")
    return "education" if title.include?("forma") || title.include?("educa")

    "custom"
  end

  def initial_body(document, profile, kind)
    return document.bodies if document.bodies.present?
    return profile.summaries if kind == "about" && profile.summaries.present?

    {}
  end
end
