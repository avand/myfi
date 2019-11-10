class Transaction < ApplicationRecord
  belongs_to :account

  default_scope { where(deleted_at: nil) }

  def year_month
    year_month_day = date.split('-')
    "Y#{year_month_day[0]}M#{year_month_day[1]}"
  end

  def auto_update_payments_or_transfers
    Transaction.where(name: "USAA FUNDS TRANSFER CR").update_all(payment_or_transfer: true)
    Transaction.where("name LIKE 'TO%USAA FUNDS TRANSFER DB'").update_all(payment_or_transfer: true)
    Transaction.where(name: "TAX WITHHELD").update_all(payment_or_transfer: true)
    Transaction.where(name: "INTEREST PAID").update_all(payment_or_transfer: true)
    Transaction.where("name LIKE 'AUTOPAY %AUTOPAY AUTO-PMT'").update_all(payment_or_transfer: true)
    Transaction.where("name LIKE 'Online Transfer % transaction%'").update_all(payment_or_transfer: true)
    Transaction.where(name: "BK OF AMER MC ONLINE PMT").update_all(payment_or_transfer: true)
    Transaction.where("name like 'AIRBNB, INC DIRECT DEP PPD ID:%'").update_all(payment_or_transfer: true)
    Transaction.where("name LIKE 'USAA CREDIT CARD PAYMENT % WEB ID: %'").update_all(payment_or_transfer: true)
    Transaction.where("name LIKE 'AUTOMATIC PAYMENT - THANK%'").update_all(payment_or_transfer: true)
    Transaction.where(name: 'CHASE CREDIT CRD AUTOPAY').update_all(payment_or_transfer: true)
  end
end
