require 'rails_helper'

RSpec.describe 'Publishers', tyep: :request do
  let(:oreilly) { create(:publisher) }
  let(:dev_media) { create(:super_books) }
  let(:super_books) { create(:super_books) }
  let(:publishers) { [oreilly, dev_media, super_books] }

  describe 'GET /api/publishers' do
    before { publishers }
    context 'default behavior' do
      before { get '/api/publishers' }

      it 'receives status 200' do
        expect(response.status).to eq 200
      end

      it 'receives three publishers' do
        expect(json_body['data'].size).to eq 3
      end
    end

    describe 'field picking' do
      context 'with the fields parameter' do
        before { get '/api/publishers?fields=name' }

        it 'receives status 200' do
          expect(response.status).to eq 200
        end

        it 'receives only field name' do
          json_body['data'].each do |publisher|
            expect(publisher.keys).to eq ['name']
          end
        end
      end
      context 'without the field parameter' do
        before { get '/api/publishers' }

        it 'return all entities' do
          json_body['data'].each do |publisher|
            expect(publisher.keys).to eq ['id', 'name', 'created_at', 'updated_at']
          end
        end
      end
      context 'with invalid field name "fid"' do
        before { get '/api/publishers?fields=fid' }

        it 'receives status 400 Bad Request' do
          expect(response.status).to eq 400
        end

        it 'receives an error' do
          expect(json_body['error']).to_not be nil
        end

        it 'receives invalid_params with value "fields=fid"' do
          expect(json_body['error']['invalid_params']).to eq 'fields=fid'
        end
      end
    end

    describe 'pagination' do
      context 'when asking for the first page' do
        before { get '/api/publishers?page=1&per=2' }

        it 'receives status 200' do
          expect(response.status).to eq 200
        end

        it 'receives two publishers' do
          expect(json_body['data'].size).to eq 2
        end

        it 'receives header with link' do
          expect(response.header['Link'].split(',').first).to eq(
            "<http://www.example.com/api/publishers?page=2&per=2>; rel=\"next\""
          )
        end
      end
      context 'when asking for the second page' do
        before { get '/api/publishers?page=2&per=2' }

        it 'receives status 200' do
          expect(response.status).to eq 200
        end

        it 'receives one publisher' do
          expect(json_body['data'].size).to eq 1
        end
      end
      context 'when sending invalid "page" and "per" parameters' do
        before { get '/api/publishers?page=fpage&per=2' }

        it 'receives status 400 Bad Request' do
          expect(response.status).to eq 400
        end

        it 'receives an error' do
          expect(json_body['error']).to_not be nil
        end

        it 'receives error with invalid_params "page=fpage"' do
          expect(json_body['error']['invalid_params']).to eq 'page=fpage'
        end
      end
    end

    describe 'sorting' do
      context 'with valid column name "id"' do
        before { get '/api/publishers?sort=id&dir=asc' }

        it 'receives status 200' do
          expect(response.status).to eq 200
        end

        it 'receives oreilly first' do
          expect(json_body['data'].first['id']).to eq oreilly.id
        end

        it 'receives super_books last' do
          expect(json_body['data'].last['id']).to eq super_books.id
        end
      end
      context 'with invalid column name "fid"' do
        before { get '/api/publishers?sort=fid&dir=desc' }

        it 'receives status 400' do
          expect(response.status).to eq 400
        end

        it 'receives an error' do
          expect(json_body['error']).to_not be nil
        end

        it 'receives invalid_params "sort=fid"' do
          expect(json_body['error']['invalid_params']).to eq 'sort=fid'
        end
      end
    end

    describe 'filtering' do
      context 'with valid filtering param "q[name_cont]=reilly"' do
        before { get '/api/publishers?q[name_cont]=reilly' }

        it 'receives status 200' do
          expect(response.status).to eq 200
        end

        it 'receives one publisher' do
          expect(json_body['data'].size).to eq 1
        end

        it 'receives publisher Reilly' do
          expect(json_body['data'].first['id']).to eq oreilly.id
        end
      end
      context 'with invalid filtering param "q[fname_cont]=reilly"' do
        before { get '/api/publishers?q[fname_cont]=reilly' }

        it 'receives status 400' do
          expect(response.status).to eq 400
        end

        it 'receives an error' do
          expect(json_body['error']).to_not be nil
        end

        it 'receives invalid_params "q[fname_cont]=reilly"' do
          expect(json_body['error']['invalid_params']).to eq 'q[fname_cont]=reilly'
        end
      end
    end
  end

  describe 'GET /api/publishers/:id' do
    context 'with existing resource' do
      before { get "/api/publishers/#{super_books.id}" }

      it 'receives status 200' do
        expect(response.status).to eq 200
      end

      it 'receives super books publisher' do
        expect(json_body['data']['id']).to eq super_books.id
      end
    end
    context 'with nonexistent resource' do
      before { get '/api/publishers/326874632' }

      it 'receives status 404' do
        expect(response.status).to eq 404
      end
    end
  end

  describe 'POST /api/publishers' do
    before { post "/api/publishers", params: { data: params } }
    context 'with valid parameters' do
      let(:params) { { name: "branliang" } }

      it 'receives status 201' do
        expect(response.status).to eq 201
      end

      it 'receives publisher with name "branliang"' do
        expect(json_body['data']['name']).to eq 'branliang'
      end

      it 'create a new publisher on database' do
        expect(Publisher.all.size).to eq 1
      end
    end
    context 'with invalid parameters' do
      let(:params) { { name: '' } }

      it 'receives status 422 unprocessable_entity' do
        expect(response.status).to eq 422
      end

      it 'receives an error' do
        expect(json_body['error']).to_not be nil
      end

      it 'receives detail invalid_params' do
        expect(json_body['error']['invalid_params']).to eq(
          { 'name' => ["can't be blank"] }
        )
      end
    end
  end

  describe 'PATCH /api/publishers/:id' do
    before { patch "/api/publishers/#{super_books.id}", params: { data: params } }
    context 'with valid parameters' do
      let(:params) { { name: 'branliang' } }

      it 'receives status 200' do
        expect(response.status).to eq 200
      end

      it 'receives publisher name be "branliang"' do
        expect(json_body['data']['name']).to eq 'branliang'
      end
    end
    context 'with invalid parameters' do
      let(:params) { { name: '' } }

      it 'receives status 422' do
        expect(response.status).to eq 422
      end

      it 'receives an error' do
        expect(json_body['error']).to_not be nil
      end

      it 'receives invalid_params' do
        expect(json_body['error']['invalid_params']).to eq(
          { 'name' => ["can't be blank"] }
        )
      end
    end
  end

  describe 'DELETE /api/publishers/:id' do
    context 'with existing resource' do
      before { delete "/api/publishers/#{super_books.id}" }

      it 'receives status 204' do
        expect(response.status).to eq 204
      end

      it 'delete the publisher from database' do
        expect(Publisher.all.size).to eq 0
      end
    end
    context 'with nonexistent resource' do
      it 'receives status 404' do
        delete '/api/publishers/23897982'
        expect(response.status).to eq 404
      end
    end
  end
end
