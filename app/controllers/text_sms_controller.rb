class TextSmsController < ApplicationController
  include ValidationConcern
  before_action :validate_params, except: :request_not_found

  def inbound
    if phone_number_exist_in_account?(params[:to])
      stop_message(params[:from], params[:to]) if check_stop_text?(params[:text])

      render json: { message: I18n.t('message.inbound'), error: '' }, status: :ok
    else
      render json: { message: '', error: I18n.t('error.params_not_found', params: 'to') }, status: :bad_request
    end
  end

  def outbound
    if cache_stopped_message?(params[:from], params[:to])
      render json: { message: '', error: I18n.t('error.blocked_error', from: params[:from], to: params[:to]) },
             status: :bad_request
    elsif rate_limit_reached?(params[:from])
      render json: { message: '', error: I18n.t('error.limit_reached', from: params[:from]) }, status: :bad_request
    elsif phone_number_exist_in_account?(params[:from])
      increase_rate_limit(params[:from])
      render json: { message: I18n.t('message.outbound'), error: '' }, status: :ok
    else
      render json: { message: '', error: I18n.t('error.params_not_found', params: 'from') }, status: :bad_request
    end
  end

  def request_not_found
    render json: { message: '', error: I18n.t('error.method_not_allowed') }, status: :method_not_allowed
  end

end
