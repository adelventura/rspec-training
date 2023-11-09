require_relative '../../../app/api'
require 'rack/test'

module ExpenseTracker
  RSpec.describe API do
    include Rack::Test::Methods

    def app
      API.new(ledger)
    end

    let(:ledger) { instance_double('ExpenseTracker::Ledger') }

    def parse
      JSON.parse(last_response.body)
    end

    describe 'POST /expenses' do
      context 'when the expense is successfully recorded' do
        let(:expense) { { 'some' => 'data' } }
        before do
          allow(ledger).to receive(:record)
            .with(expense)
            .and_return(RecordResult.new(true, 417, nil))
        end

        it 'returns the expense id' do
          post '/expenses', JSON.generate(expense)

          expect(parse).to include('expense_id' => 417)
        end

        it 'responds with a 200 (OK)' do
          post '/expenses', JSON.generate(expense)
          expect(last_response.status).to eq(200)
        end
      end

      context 'when the expense fails validation' do
        let(:expense) { { 'some' => 'data' } }
        before do
          allow(ledger).to receive(:record).with(expense).and_return(RecordResult.new(false, 417, 'Expense incomplete'))
        end

        it 'returns an error message' do
          post '/expenses', JSON.generate(expense)

          expect(parse).to include('error' => 'Expense incomplete')
        end

        it 'responds with a 422 (Unprocessable entity)' do
          post '/expenses', JSON.generate(expense)
          expect(last_response.status).to eq(422)
        end
      end
    end

    describe 'GET /expenses/:date' do
      context 'when expenses exist on the given data' do
        before do
          allow(ledger).to receive(:get_expenses_by_date)
            .with('11-07-2023')
            .and_return(['pet supplies'])
        end

        it 'returns the expense records as JSON' do
          get '/expenses/11-07-2023'

          expect(parse).to include('pet supplies')
        end

        it 'responds with a 200 (OK)' do
          get '/expenses/11-07-2023'
          expect(last_response.status).to eq(200)
        end
      end
    end

    context 'when there are no expenses on the given date' do
      before do
        allow(ledger).to receive(:get_expenses_by_date)
          .with('10-01-2023')
          .and_return([])
      end

      it 'returns an empty array as JSON' do
        get '/expenses/10-01-2023'
        expect(parse).to be_empty
      end

      it 'responds with a 200 (OK)' do
        get '/expenses/10-01-2023'
        expect(last_response.status).to eq(200)
      end
    end
  end
end
