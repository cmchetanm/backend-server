require 'rails_helper'

RSpec.describe TextSmsController, type: :controller do
  include AuthHelper
  let(:account) { FactoryBot.create(:account) }
  let(:phone_number) { FactoryBot.create(:phone_number, account_id: account.id) }
  let(:paragraph) do
    "Lorem ipsum, or lipsum as it is sometimes known, is dummy text used in laying out print,
    graphic or web designs. The passage is attributed to an unknown typesetter in the 15th
    century who is thought to have scrambled parts of Cicero's De Finibus Bonorum et Malorum for
    use in a type specimen book."
  end
  let(:text) { 'Hello' }

  let(:redis) { Redis.new }
  let(:redis_double) { instance_double(Redis) }
  
  subject(:response_data) { JSON.parse(response.body) }

  shared_examples 'parameter validation' do |action|
    it 'returns an error when parameters missing' do
      post action, params: { from: '', to: '', text: '' }
      
      expect(response_data['message']).to be_empty
      expect(response_data['error']).to eq(I18n.t('error.missing_params', params: 'from'))
      expect(response).to have_http_status(:bad_request)
    end

    it 'returns an error when from parameter is invalid' do
      post action, params: { from: '12345678123456789', to: phone_number.number, text: text }
      expect(response_data['message']).to be_empty
      expect(response_data['error']).to eq(I18n.t('error.invalid', key: 'from'))
      expect(response).to have_http_status(:bad_request)
    end

    it 'returns an error when to parameter is invalid' do
      post action, params: { from: phone_number.number, to: '12345678123456789', text: text }
      
      expect(response_data['message']).to be_empty
      expect(response_data['error']).to eq(I18n.t('error.invalid', key: 'to'))
      expect(response).to have_http_status(:bad_request)
    end

    it 'returns an error when text parameter is invalid' do
      post action, params: { from: phone_number.number, to: phone_number.number, text: paragraph }
      
      expect(response_data['message']).to be_empty
      expect(response_data['error']).to eq(I18n.t('error.invalid', key: 'text'))
      expect(response).to have_http_status(:bad_request)
    end

    it 'handles unknown failure exception' do
      allow(controller).to receive(:phone_number_exist_in_account?).and_raise(StandardError)
      
      post :outbound, params: { from: phone_number.number, to: phone_number.number, text: text }
      
      expect(JSON.parse(response.body)['error']).to eq(I18n.t('error.unknown'))
      expect(response).to have_http_status(:internal_server_error)
    end
  end

  describe 'Text Sms Controller Apis' do
    before(:each) do
      http_login(account.username, account.auth_id)
    end

    describe 'Post #Inbound' do
      it 'returns inbound sms ok when parameters are valid' do
        post :inbound, params: { from: phone_number.number, to: phone_number.number, text: text }
        
        expect(response_data['message']).to eq(I18n.t('message.inbound'))
        expect(response_data['error']).to be_empty
        expect(response).to have_http_status(:ok)
      end

      it 'returns an error when to parameter not found' do
        post :inbound, params: { from: phone_number.number, to: '123456789', text: text }
        
        expect(response_data['error']).to eq(I18n.t('error.params_not_found', params: 'to'))
        expect(response).to have_http_status(:bad_request)
      end

      it 'handles STOP message correctly' do
        post :inbound, params: { from: phone_number.number, to: phone_number.number, text: 'STOP' }
        
        expect(redis.get("#{phone_number.number}_#{phone_number.number}")).to eq('STOP')
        expect(response_data['message']).to eq(I18n.t('message.inbound'))
        expect(response).to have_http_status(:ok)
      end

      include_examples 'parameter validation', :inbound
    end

    describe 'Post #Outbound' do
      it 'returns outbound sms ok when parameters are valid' do
        post :outbound, params: { from: phone_number.number, to: phone_number.number, text: text }
        
        expect(response_data['message']).to eq(I18n.t('message.outbound'))
        expect(response_data['error']).to be_empty
        expect(response).to have_http_status(:ok)
      end

      it 'returns error when from parameter not found' do
        post :outbound, params: { from: '123456789012', to: phone_number.number, text: text }
        
        expect(response_data['message']).to be_empty
        expect(response_data['error']).to eq(I18n.t('error.params_not_found', params: 'from'))
        expect(response).to have_http_status(:bad_request)
      end

      it 'returns an error when STOP request is found' do
        allow(Redis).to receive(:new).and_return(redis_double)
        allow(redis_double).to receive(:get).with("#{phone_number.number}_#{phone_number.number}").and_return('STOP')
        
        post :outbound, params: { from: phone_number.number, to: phone_number.number, text: text }
        
        expect(JSON.parse(response.body)['error']).to eq(I18n.t('error.blocked_error', from: phone_number.number, to: phone_number.number))
        expect(response).to have_http_status(:bad_request)
      end

      it 'returns an error when rate limit is reached' do
        allow(Redis).to receive(:new).and_return(redis_double)
        allow(redis_double).to receive(:get).with("#{phone_number.number}_#{phone_number.number}").and_return(nil)
        allow(redis_double).to receive(:get).with("#{phone_number.number}_count").and_return(51)
        
        post :outbound, params: { from: phone_number.number, to: phone_number.number, text: text }
        
        expect(JSON.parse(response.body)['error']).to eq(I18n.t('error.limit_reached', from: phone_number.number))
        expect(response).to have_http_status(:bad_request)
      end

      include_examples 'parameter validation', :outbound
    end

    describe 'Get #request_not_found' do
      it 'returns an error when http method is wrong' do
        get :request_not_found
        
        expect(response_data['message']).to be_empty
        expect(response_data['error']).to eq(I18n.t('error.method_not_allowed'))
        expect(response).to have_http_status(:method_not_allowed)
      end
    end
  end

  describe 'Authentication Failed' do
    before(:each) do
      http_login('testuser123', 'abc123')
    end

    it 'returns an error when authentication failed' do
      post :inbound
      
      expect(response_data['message']).to be_empty
      expect(response_data['error']).to eq(I18n.t('error.authenticate'))
      expect(response).to have_http_status(:forbidden)
    end
  end
end
