class ApplicationController < ActionController::Base
  before_action :authenticate_user
  around_action :handle_exception

  private

  def authenticate_user
    authenticate_or_request_with_http_basic do |username, password|
      @account = Account.find_by(username: username, auth_id: password)

      return render json: { message: '', error: I18n.t('error.authenticate') }, status: :forbidden unless @account

      true
    end
  end

  def handle_exception
    yield
  rescue StandardError => e
    logger.error "Unhandled exception: #{e.message}"
    render json: { message: '', error: I18n.t('error.unknown') }, status: :internal_server_error
  end
end
