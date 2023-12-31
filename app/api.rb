require 'sinatra/base'
require 'json'
require_relative 'ledger'

module ExpenseTracker
  # API
  class API < Sinatra::Base
    def initialize(ledger = Ledger.new)
      @ledger = ledger

      super()
    end

    post '/expenses' do
      expense = JSON.parse(request.body.read)
      result = @ledger.record(expense)

      if result.success?
        JSON.generate('expense_id' => result.expense_id)
      else
        status 422
        JSON.generate('error' => result.error_message)
      end
    end

    get '/expenses/:date' do
      date = params[:date]
      JSON.generate(@ledger.get_expenses_by_date(date))
    end
  end
end
