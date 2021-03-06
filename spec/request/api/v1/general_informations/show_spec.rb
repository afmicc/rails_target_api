require 'rails_helper'

describe 'GET api/v1/general_informations', type: :request do
  let!(:user) { create(:user, :confirmed) }
  let!(:about_info) { create(:general_information) }

  describe 'First General Information (key = about)' do
    let(:param) { about_info.key }

    context 'when the request is succesful' do
      before do
        get api_v1_general_information_path(param), headers: auth_header
      end

      it 'is expected a successful response' do
        expect(response).to be_successful
      end

      it 'is expected that response contains some body data' do
        expect(response.body).to include_json(
          general_information:
            {
              title: about_info.title,
              text: about_info.text
            }
        )
      end
    end

    context "when the key doesn't exist" do
      let(:not_found_param) { Faker::Lorem.word }

      before do
        get api_v1_general_information_path(not_found_param), headers: auth_header
      end

      it 'is expected a not found response' do
        expect(response).to have_http_status(:not_found)
      end

      it 'is expected an error message' do
        expect(response.body).to include_json(error: I18n.t('api.errors.not_found'))
      end
    end

    context 'when the user is not logged in' do
      it 'is expected an unauthorized response' do
        get api_v1_general_information_path(param)
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
