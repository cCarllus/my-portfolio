module Admin
  module CrudActions
    extend ActiveSupport::Concern

    included do
      before_action :set_record, only: %i[edit update destroy]
    end

    def index
      @records = resource_scope
    end

    def new
      @record = resource_scope.new
    end

    def create
      @record = resource_scope.new(record_params)
      PositionRecords.append(@record, scope: resource_scope) if @record.respond_to?(:position=)

      if @record.save
        redirect_to collection_path, notice: t("admin.notices.created")
      else
        render :new, status: :unprocessable_content
      end
    end

    def edit
    end

    def update
      if @record.update(record_params)
        redirect_to collection_path, notice: t("admin.notices.updated")
      else
        render :edit, status: :unprocessable_content
      end
    end

    def destroy
      @record.destroy!
      redirect_to collection_path, notice: t("admin.notices.destroyed")
    end

    def reorder
      PositionRecords.reorder(scope: resource_scope, ids: params.require(:ids))
      head :no_content
    rescue PositionRecords::InvalidOrder, ActionController::ParameterMissing
      head :unprocessable_content
    end

    private

    def resource_scope
      model_class.where(portfolio_profile:).ordered
    end

    def set_record
      @record = resource_scope.find(params[:id])
    end
  end
end
