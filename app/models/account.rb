class Account < ApplicationRecord
  self.inheritance_column = :not_type

  has_many :transactions

  TYPE_CHECKING = 'checking'.freeze
  TYPE_CREDIT = 'credit'.freeze
  TYPE_SAVINGS = 'savings'.freeze

  TYPES = [TYPE_CHECKING, TYPE_CREDIT, TYPE_SAVINGS].freeze

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

  validates :type, inclusion: { in: TYPES, if: proc { |a| a.type.present? } }
  validates :default_allocation, inclusion: { in: ALLOCATIONS, if: proc { |a| a.default_allocation.present? } }
end
