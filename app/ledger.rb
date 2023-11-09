module ExpenseTracker
  RecordResult = Struct.new(:success?, :expense_id, :error_message)

  # Ledger
  class Ledger
    def record(expense) end
    def get_expenses_by_date(date) end
  end
end
