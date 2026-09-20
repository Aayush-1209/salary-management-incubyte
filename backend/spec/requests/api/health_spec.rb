require 'rails_helper'

RSpec.describe 'Api::Health', type: :request do
  describe 'GET /api/health' do
    it 'returns 200 with ok status' do
      get '/api/health'

      expect(response).to have_http_status(:ok)
    end

    it 'returns JSON with status ok' do
      get '/api/health'

      json = response.parsed_body
      expect(json['status']).to eq('ok')
    end

    it 'returns a timestamp' do
      get '/api/health'

      json = response.parsed_body
      expect(json['timestamp']).to be_present
    end

    it 'reports database connection status' do
      get '/api/health'

      json = response.parsed_body
      expect(json['database']).to eq('connected')
    end
  end
end
