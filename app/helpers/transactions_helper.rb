module TransactionsHelper
  def sum_amounts_by_first_of_month(transactions)
    transactions.each_with_object(Hash.new(0)) do |transaction, hash|
      hash["#{transaction.date[0..6]}-01"] += (
        transaction.amount
      )
    end.sort.to_h
  end
end
