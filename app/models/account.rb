class Account < ApplicationRecord
  self.inheritance_column = :not_type

  has_many :transactions
  belongs_to :plaid_item

  ALLOCATION_AUTO = 'auto'.freeze
  ALLOCATION_KALEIDOSCOPE = 'kaleidoscope'.freeze
  ALLOCATION_LIFESTYLE = 'lifestyle'.freeze
  ALLOCATION_LIVING = 'living'.freeze
  ALLOCATION_RECURRING = 'recurring'.freeze
  ALLOCATION_TRAVEL = 'travel'.freeze

  ALLOCATIONS = [
    ALLOCATION_AUTO,
    ALLOCATION_KALEIDOSCOPE,
    ALLOCATION_LIFESTYLE,
    ALLOCATION_LIVING,
    ALLOCATION_RECURRING,
    ALLOCATION_TRAVEL,
  ].freeze

  validates :default_allocation, inclusion: { in: ALLOCATIONS, if: proc { |a| a.default_allocation.present? } }

  def get_transactions_from_plaid(start_date, end_date, offset: 0, count: 500)
    response = PLAID_CLIENT.transactions.get(
      plaid_item.access_token,
      start_date,
      end_date,
      { offset: offset, count: count, account_ids: [plaid_id] },
    )

    transactions = response.transactions

    if offset + transactions.length < response.total_transactions
      transactions += get_transactions_from_plaid(
        start_date,
        end_date, count: count, offset: transactions.length)
    end

    transactions
  end
end
