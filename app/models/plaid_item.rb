class PlaidItem < ApplicationRecord
  scope :active, -> { where(expired_at: nil) }
  scope :expired, -> { where('expired_at is not null') }

  has_many :accounts

  def expire
    update(expired_at: Time.now)
  end

  def expired?
    expired_at != nil
  end
end
