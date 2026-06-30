module Admin
  class SkillsController < BaseController
    include CrudActions

    private

    def model_class = Skill
    def collection_path = admin_skills_path

    def record_params = params.require(:skill).permit(:name, :category, :featured, :published)
  end
end
