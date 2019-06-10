class Transaction < ApplicationRecord
  belongs_to :account

  def year_month
    year_month_day = date.split('-')
    "Y#{year_month_day[0]}M#{year_month_day[1]}"
  end
end
