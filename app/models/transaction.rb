class Transaction < ApplicationRecord
  belongs_to :account

  default_scope { where(deleted_at: nil) }

  scope :unallocated, -> { where(allocation: nil) }
  scope :allocated, -> { where.not(allocation: nil) }
  scope :payment_or_transfer, -> { where(payment_or_transfer: true) }
  scope :not_payment_or_transfer, -> { where(payment_or_transfer: [nil, false]) }

  def self.auto_update_payments_or_transfers(force = true)
    where_clauses = [
      { name: 'USAA FUNDS TRANSFER CR' },
      { name: 'TAX WITHHELD' },
      { name: 'INTEREST PAID' },
      { name: 'BK OF AMER MC ONLINE PMT' },
      { name: 'CHASE CREDIT CRD AUTOPAY' },
      { name: 'BA ELECTRONIC PAYMENT' },
      { name: 'CITI AUTOPAY PAYMENT' },
      { name: 'JPMorgan Chase Ext Trnsfr' },
      { name: 'Payment Thank You-Mobile' },
      "name LIKE 'TO%USAA FUNDS TRANSFER DB'",
      "name LIKE 'AUTOPAY %AUTOPAY AUTO-PMT'",
      "name LIKE 'Online Transfer % transaction%'",
      "name like 'AIRBNB, INC DIRECT DEP PPD ID:%'",
      "name LIKE 'AUTOMATIC PAYMENT %'",
      "name LIKE 'USAA CREDIT CARD PAYMENT % WEB ID: %'",
      "name LIKE 'USAA CHK-INTRNT TRANSFER%'",
      "name LIKE 'USAA.COM PAYMNT CREDIT CRD%'",
    ].each do |where_clause|
      query = force ? all : where(payment_or_transfer: nil)
      query.where(where_clause).update_all(payment_or_transfer: true)
    end
  end

  def self.auto_update_allocations(force = false)
    query = force ? all : unallocated
    query = query.where.not(name: 'AIRBNB, INC DIRECT DEP')

    query.where(name: [
      'GREENVIEW MANAGE 4158303125',
      'NAVIA BENEFIT SO FLEXIBLE B'
    ]).update_all(allocation: Account::ALLOCATION_RECURRING)

    query.where(name: [
      'GREENTREEPROP ONLINE PMT',
    ]).update_all(allocation: Account::ALLOCATION_LIVING)

    query.where(name: [
      'SIERRA TELEPHONE COMPA',
      'SIERRA TELEPHONE CO INC',
    ]).update_all(allocation: Account::ALLOCATION_KALEIDOSCOPE)

    query.includes(:account).find_each do |transaction|
      transaction.update(allocation: transaction.account.default_allocation)
    end
  end
end
