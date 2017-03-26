require 'rails_helper'

RSpec.describe 'Users', type: :request do
  include_context 'Skip Auth'

  let(:john) { create(:user) }
  let(:users) { [john] }

  describe 'GET /api/users' do
    before { users }
    before { get "/api/users" }

    it 'receives status 200' do
      expect(response.status).to eq 200
    end

  end

  describe 'GET /api/users/:id' do
    before { get "/api/users/#{john.id}" }

    it 'receives status 200' do
      expect(response.status).to eq 200
    end

    it 'receives user john' do
      expect(json_body['data']['id']).to eq john.id
    end
  end

  describe 'POST /api/users' do
    before { post "/api/users", params: { data: params } }

    context "with valid params" do
      let(:params) { {
        password: 'password',
        email: '123@email.com',
        given_name: 'bran',
        family_name: 'liang'
      } }

      it 'receives status 201' do
        expect(response.status).to eq 201
      end

      it 'receives a new user' do
        expect(json_body['data']).to_not be nil
      end
    end
  end

  describe 'PATCH /api/users/:id' do
    before { patch "/api/users/#{john.id}", params: { data: params } }
    let(:params) { {
      given_name: 'test_name'
      } }

    it 'receives status 200' do
      expect(response.status).to eq 200
    end

    it 'receives data' do
      expect(json_body['data']).to_not be nil
    end

    it 'change the john given_name to be "test_name"' do
      expect(john.reload.given_name).to eq "test_name"
    end
  end

  describe 'DELETE /api/users/:id' do
    before { delete "/api/users/#{john.id}" }

    it 'receives status 204' do
      expect(response.status).to eq 204
    end

  end
end
