class Transaction < ApplicationRecord
  belongs_to :account

  default_scope { where(deleted_at: nil) }

  scope :unallocated, -> { where(allocation: nil) }
  scope :allocated, -> { where.not(allocation: nil) }
  scope :payment_or_transfer, -> { where(payment_or_transfer: true) }
  scope :not_payment_or_transfer, -> { where(payment_or_transfer: [nil, false]) }

  def year_month
    year_month_day = date.split('-')
    "Y#{year_month_day[0]}M#{year_month_day[1]}"
  end

  def self.auto_update_payments_or_transfers
    where(name: "USAA FUNDS TRANSFER CR").update_all(payment_or_transfer: true)
    where("name LIKE 'TO%USAA FUNDS TRANSFER DB'").update_all(payment_or_transfer: true)
    where(name: "TAX WITHHELD").update_all(payment_or_transfer: true)
    where(name: "INTEREST PAID").update_all(payment_or_transfer: true)
    where("name LIKE 'AUTOPAY %AUTOPAY AUTO-PMT'").update_all(payment_or_transfer: true)
    where("name LIKE 'Online Transfer % transaction%'").update_all(payment_or_transfer: true)
    where(name: "BK OF AMER MC ONLINE PMT").update_all(payment_or_transfer: true)
    where("name like 'AIRBNB, INC DIRECT DEP PPD ID:%'").update_all(payment_or_transfer: true)
    where("name LIKE 'USAA CREDIT CARD PAYMENT % WEB ID: %'").update_all(payment_or_transfer: true)
    where("name LIKE 'AUTOMATIC PAYMENT - THANK%'").update_all(payment_or_transfer: true)
    where(name: 'CHASE CREDIT CRD AUTOPAY').update_all(payment_or_transfer: true)
    where(name: 'BA ELECTRONIC PAYMENT').update_all(payment_or_transfer: true)
  end

  def self.auto_update_allocations(force = false)
    query = force ? all : unallocated

    query.includes(:account).find_each do |transaction|
      transaction.update(allocation: transaction.account.default_allocation)
    end

    query.where(name: [
      'GREENVIEW MANAGE 4158303125',
    ]).update_all(allocation: Account::ALLOCATION_RECURRING)

    query.where(name: [
      'GREENTREEPROP ONLINE PMT',
    ]).update_all(allocation: Account::ALLOCATION_LIVING)

    query.where(name: [
      'SIERRA TELEPHONE COMPA',
      'SIERRA TELEPHONE CO INC',
    ]).update_all(allocation: Account::ALLOCATION_KALEIDOSCOPE)
  end
end
