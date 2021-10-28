require 'rails_helper'

RSpec.describe Api::SudokusController, type: :request do
  describe "POST /api/sudoku" do
    context 'for invalid input' do

      context "when data size is invalid" do
        it 'should return error' do
          post '/api/sudoku', params: {'data': [ ]}
          res_body = JSON.parse(response.body)

          expect(response).to have_http_status 422
          expect(res_body["error"]).to eq('Array size should be 9X9')
        end

        it 'should return error' do
          post '/api/sudoku', params: {'data': [ [ ] ]}
          res_body = JSON.parse(response.body)

          expect(response).to have_http_status 422
          expect(res_body["error"]).to eq('Array size should be 9X9')
        end
      end

      context 'when data value is invalid' do
        context "when value is repeat" do
          it 'should return error' do
            post '/api/sudoku', params: {
              "data": [
                [2, nil, 5, nil, nil, 9, nil, 2, 4],
                [nil, nil, nil, nil, nil, nil, 3, nil, 7],
                [7, nil, nil, 8, 5, 6, nil, 1, nil],
                [4, 5, nil, 7, nil, nil, nil, nil, nil],
                [nil, nil, 9, nil, nil, nil, 1, nil, nil],
                [nil, nil, nil, nil, nil, 2, nil, 8, 5],
                [nil, 2, nil, 4, 1, 8, nil, nil, 6],
                [6, nil, 8, nil, nil, nil, nil, nil, nil],
                [1, nil, nil, 2, nil, nil, 7, nil, 8]
              ]
            }, as: :json
            res_body = JSON.parse(response.body)

            expect(response).to have_http_status 422
            expect(res_body["error"]).to eq("Can't solve sudoku")
          end
        end

        context "when value is greater than 9" do
          it 'should return error' do
            post '/api/sudoku', params: {
              "data": [
                [2, nil, 5, nil, nil, 9, nil, nil, 40],
                [nil, nil, nil, nil, nil, nil, 3, nil, 7],
                [7, nil, nil, 8, 5, 6, nil, 1, nil],
                [4, 5, nil, 7, nil, nil, nil, nil, nil],
                [nil, nil, 9, nil, nil, nil, 1, nil, nil],
                [nil, nil, nil, nil, nil, 2, nil, 8, 5],
                [nil, 2, nil, 4, 1, 8, nil, nil, 6],
                [6, nil, 8, nil, nil, nil, nil, nil, nil],
                [1, nil, nil, 2, nil, nil, 7, nil, 8]
              ]
            }, as: :json
            res_body = JSON.parse(response.body)

            expect(response).to have_http_status 422
            expect(res_body["error"]).to eq("Can't solve sudoku")
          end
        end

        context "when value is less than 1" do
          it 'should return error' do
            post '/api/sudoku', params: {
              "data": [
                [2, nil, 5, nil, nil, 9, nil, nil, 0],
                [nil, nil, nil, nil, nil, nil, 3, nil, 7],
                [7, nil, nil, 8, 5, 6, nil, 1, nil],
                [4, 5, nil, 7, nil, nil, nil, nil, nil],
                [nil, nil, 9, nil, nil, nil, 1, nil, nil],
                [nil, nil, nil, nil, nil, 2, nil, 8, 5],
                [nil, 2, nil, 4, 1, 8, nil, nil, 6],
                [6, nil, 8, nil, nil, nil, nil, nil, nil],
                [1, nil, nil, 2, nil, nil, 7, nil, 8]
              ]
            }, as: :json
            res_body = JSON.parse(response.body)

            expect(response).to have_http_status 422
            expect(res_body["error"]).to eq("Can't solve sudoku")
          end
        end
      end

      context 'when data is valid' do
        let(:success_response) {{
          "solution" => [
            [2, 1, 5, 3, 7, 9, 8, 6, 4],
            [9, 8, 6, 1, 2, 4, 3, 5, 7],
            [7, 3, 4, 8, 5, 6, 2, 1, 9],
            [4, 5, 2, 7, 8, 1, 6, 9, 3],
            [8, 6, 9, 5, 4, 3, 1, 7, 2],
            [3, 7, 1, 6, 9, 2, 4, 8, 5],
            [5, 2, 7, 4, 1, 8, 9, 3, 6],
            [6, 4, 8, 9, 3, 7, 5, 2, 1],
            [1, 9, 3, 2, 6, 5, 7, 4, 8]
          ]
        }}

        it 'should return success with status 200 for array input' do
          post '/api/sudoku', params: {
            "data": [
              [2, nil, 5, nil, nil, 9, nil, nil, 4],
              [nil, nil, nil, nil, nil, nil, 3, nil, 7],
              [7, nil, nil, 8, 5, 6, nil, 1, nil],
              [4, 5, nil, 7, nil, nil, nil, nil, nil],
              [nil, nil, 9, nil, nil, nil, 1, nil, nil],
              [nil, nil, nil, nil, nil, 2, nil, 8, 5],
              [nil, 2, nil, 4, 1, 8, nil, nil, 6],
              [6, nil, 8, nil, nil, nil, nil, nil, nil],
              [1, nil, nil, 2, nil, nil, 7, nil, 8]
            ]
          }, as: :json
          res_body = JSON.parse(response.body)
          expect(response).to have_http_status 200
          expect(res_body).to eq(success_response)
        end

        it 'should return success with status 200 for string input' do
          post '/api/sudoku', params: {
            "data": "[
              [2, null, 5, null, null, 9, null, null, 4],
              [null, null, null, null, null, null, 3, null, 7],
              [7, null, null, 8, 5, 6, null, 1, null],
              [4, 5, null, 7, null, null, null, null, null],
              [null, null, 9, null, null, null, 1, null, null],
              [null, null, null, null, null, 2, null, 8, 5],
              [null, 2, null, 4, 1, 8, null, null, 6],
              [6, null, 8, null, null, null, null, null, null],
              [1, null, null, 2, null, null, 7, null, 8]
            ]"
          }, as: :json
          res_body = JSON.parse(response.body)
          expect(response).to have_http_status 200
          expect(res_body).to eq(success_response)
        end
      end
    end
  end
end
