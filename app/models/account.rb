class Account < ApplicationRecord
  self.inheritance_column = :not_type

  has_many :transactions
  belongs_to :plaid_item

  ALLOCATION_JEPHPH = 'jephph'.freeze
  ALLOCATION_KALEIDOSCOPE = 'kaleidoscope'.freeze
  ALLOCATION_LIFESTYPE = 'lifestyle'.freeze
  ALLOCATION_RECURRING = 'recurring'.freeze
  ALLOCATION_TRAVEL = 'travel'.freeze

  ALLOCATIONS = [
    ALLOCATION_JEPHPH,
    ALLOCATION_KALEIDOSCOPE,
    ALLOCATION_LIFESTYPE,
    ALLOCATION_RECURRING,
    ALLOCATION_TRAVEL,
  ].freeze

  validates :default_allocation, inclusion: { in: ALLOCATIONS, if: proc { |a| a.default_allocation.present? } }
end
