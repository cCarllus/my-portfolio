class AdminPolicy
  def initialize(session)
    @session = session
  end

  def authorized?
    ActiveModel::Type::Boolean.new.cast(session[:admin_authenticated])
  end

  private

  attr_reader :session
end
