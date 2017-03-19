require 'rails_helper'

RSpec.describe 'Authors', type: :request do

  let(:pat) { create(:author) }
  let(:michael) { create(:michael_hartl) }
  let(:sam) { create(:sam_ruby) }
  let(:authors) { [pat, michael, sam] }

  describe 'GET /api/authors' do
    before { authors }

    context 'default behavior' do
      before { get '/api/authors' }

      it 'receives HTTP status 200' do
        expect(response.status).to eq 200
      end

      it 'receives a json with data root key' do
        expect(json_body['data']).to_not be nil
      end

      it 'receives all three authors' do
        expect(json_body['data'].size).to eq 3
      end
    end

    describe 'field picking' do
      context 'with the fields parameter' do
        before { get '/api/authors?fields=given_name' }

        it 'gets authors with only given_name' do
          json_body['data'].each do |author|
            expect(author.keys).to eq ['given_name']
          end
        end
      end
      context 'without the field parameter' do
        before { get '/api/authors' }

        it 'gets authors with all entities' do
          json_body['data'].each do |author|
            expect(author.keys).to eq ['id', 'given_name', 'family_name', 'created_at', 'updated_at']
          end
        end
      end
      context 'with invalid field name "fid"' do
        before { get '/api/authors?fields=fid,family_name' }

        it 'get response status 400' do
          expect(response.status).to eq 400
        end

        it 'receives and error' do
          expect(json_body['error']).to_not be nil
        end

        it 'receives error with invalid_params "fields=fid"' do
          expect(json_body['error']['invalid_params']).to eq 'fields=fid'
        end
      end

    end

    describe 'pagination' do
      context 'when asking for the first page' do
        before { get('/api/authors?page=1&per=2') }

        it 'receives HTTP status 200' do
          expect(response.status).to eq 200
        end

        it 'receives only two authors' do
          expect(json_body['data'].size).to eq 2
        end

        it 'receives a response with a link header' do
          expect(response.header['Link'].split(',').first).to eq(
            "<http://www.example.com/api/authors?page=2&per=2>; rel=\"next\""
          )
        end
      end
      context 'when asking for the second page' do
        before { get('/api/authors?page=2&per=2') }

        it "receives HTTP status 200" do
          expect(response.status).to eq 200
        end

        it 'receives only one author' do
          expect(json_body['data'].size).to eq 1
        end
      end
      context 'when sending invalid "page" and "per" parameters' do
        before { get('/api/authors?page=fpage&per=2') }

        it 'receives response status 400 Bad Request' do
          expect(response.status).to eq 400
        end

        it 'receives an error' do
          expect(json_body['error']).to_not be nil
        end

        it 'receives invalid_params with value "page=fpage"' do
          expect(json_body['error']['invalid_params']).to eq 'page=fpage'
        end
      end
    end

    describe 'sorting' do
      context 'with valid column name "id"' do
        before { get '/api/authors?sort=id&dir=desc' }

        it 'receives HTTP status 200' do
          expect(response.status).to eq 200
        end

        it 'return sam as the first author' do
          expect(json_body['data'].first['id']).to eq sam.id
        end

        it 'return pat as the last author' do
          expect(json_body['data'].last['id']).to eq pat.id
        end
      end
      context 'with invalid column name "fid"' do
        before { get '/api/authors?sort=fid&dir=desc' }

        it 'receives status 400 Bad Request' do
          expect(response.status).to eq 400
        end

        it 'receives an error' do
          expect(json_body['error']).to_not be nil
        end

        it 'receives invalid_params with value "sort=fid"' do
          expect(json_body['error']['invalid_params']).to eq 'sort=fid'
        end
      end
    end

    describe 'filtering' do
      context 'with valid filtering param "q[given_name_cont]=Pat"' do
        before { get '/api/authors?q[given_name_cont]=Pat' }

        it 'receives status 200' do
          expect(response.status).to eq 200
        end

        it 'receives only 1 author' do
          expect(json_body['data'].size).to eq 1
        end

        it 'receives author Pat' do
          expect(json_body['data'].first['id']).to eq pat.id
        end
      end
      context 'with invalid filtering param "q[fgiven_name_cont]=Pat"' do
        before { get '/api/authors?q[fgiven_name_cont]=Pat' }

        it 'receives HTTP status 400 Bad Request' do
          expect(response.status).to eq 400
        end

        it 'receives an error' do
          expect(json_body['error']).to_not be nil
        end

        it 'receives invalid_params with value "q[fgiven_name_cont]=Pat"' do
          expect(json_body['error']['invalid_params']).to eq "q[fgiven_name_cont]=Pat"
        end
      end
    end

  end

  describe 'GET /api/authors/:id' do
    context 'with existing resource' do
      before { get "/api/authors/#{sam.id}" }

      it 'receives status 200' do
        expect(response.status).to eq 200
      end

      it 'receives author Sam' do
        expect(json_body['data']['id']).to eq sam.id
      end
    end
    context 'with nonexistent resource' do
      before { get '/api/authors/326874632876' }

      it 'receives status 404 Not Found' do
        expect(response.status).to eq 404
      end
    end
  end

  describe 'POST /api/authors' do
    before { post '/api/authors', params: { data: params } }

    context 'with valid parameters' do
      let(:params) { { family_name: 'Liang', given_name: 'Bran' } }

      it 'receives status code 201' do
        expect(response.status).to eq 201
      end

      it 'receives a user with given_name "Bran"' do
        expect(json_body['data']['given_name']).to eq "Bran"
      end

      it 'create a new author' do
        expect(Author.all.count).to eq 1
      end

      it 'create a new user with given_name:"Bran" and family_name:"Liang"' do
        expect(Author.first.family_name).to eq "Liang"
        expect(Author.first.given_name).to eq "Bran"
      end
    end
    context 'with invalid parameters' do
      let(:params) { { family_name: '', given_name: 'bran' } }

      it 'receives status 422' do
        expect(response.status).to eq 422
      end

      it 'receives an error detail' do
        expect(json_body['error']['invalid_params']).to eq(
          { 'family_name' => ["can't be blank"] }
        )
      end

      it 'does not add record on database' do
        expect(Author.all.size).to eq 0
      end
    end
  end

  describe 'PATCH /api/authors/:id' do
    before { patch "/api/authors/#{sam.id}", params: { data: params } }

    context 'with valid parameters' do
      let(:params) { { family_name: 'Liang' } }

      it 'receives status 200' do
        expect(response.status).to eq 200
      end

      it 'receives patched author with family_name "Liang"' do
        expect(json_body['data']['family_name']).to eq 'Liang'
      end
    end
    context 'with invalid parameters' do
      let(:params) { { family_name: '' } }

      it 'receives status 422 unprocessable_entity' do
        expect(response.status).to eq 422
      end

      it 'receives an error' do
        expect(json_body['error']).to_not be nil
      end

      it 'receives detailed invalid_params message' do
        expect(json_body['error']['invalid_params']).to eq(
          { 'family_name' => ["can't be blank"] }
        )
      end
    end
  end

  describe 'DELETE /api/authors/:id' do
    context 'with existing resource' do
      before { delete "/api/authors/#{sam.id}" }

      it 'receives status 204' do
        expect(response.status).to eq 204
      end

      it 'deletes the author from database' do
        expect(Author.all.size).to eq 0
      end
    end
    context 'with nonexistent resource' do
      it 'receives status 404 Not Found' do
        delete '/api/authors/3278947329847392'
        expect(response.status).to eq 404
      end
    end
  end

end
