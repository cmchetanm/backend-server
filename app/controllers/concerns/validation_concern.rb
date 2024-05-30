module ValidationConcern

  def validate_params
    required_params = %i[from to text]
    missing_params = required_params.find { |param| params[param].blank? }

    if missing_params.present?
      return render json: { message: '', error: I18n.t('error.missing_params', params: missing_params) }, status: :bad_request
    end

    validate_number_length(:from)
    validate_number_length(:to)
    validate_text_length(:text)
  end

  def validate_number_length(num)
    value = params[num]
    if value.length < 6 || value.length > 16
      render json: { message: '', error: I18n.t('error.invalid', key: num) }, status: :bad_request
    end
  end

  def validate_text_length(text)
    value = params[text]
    if value.length > 120
      render json: { message: '', error: I18n.t('error.invalid', key: text) },
             status: :bad_request
    end
  end

  def phone_number_exist_in_account?(number)
    PhoneNumber.exists?(number: number, account_id: @account.id)
  end

  def check_stop_text?(text)
    ['STOP', 'STOP\n', 'STOP\r', 'STOP\r\n'].include?(text)
  end

  def stop_message(from, to)
    redis.set("#{from}_#{to}", 'STOP', ex: 4.hours)
  end

  def cache_stopped_message?(from, to)
    redis.get("#{from}_#{to}") == 'STOP'
  end

  def rate_limit_reached?(from)
    redis.get("#{from}_count").to_i >= 50
  end

  def increase_rate_limit(from)
    count = redis.incr("#{from}_count")
    redis.expire("#{from}_count", 24.hours) if count == 1
  end

  def redis
    @redis ||= Redis.new
  end

end
