class Room < ApplicationRecord
  validates :name, presence: true, uniqueness: true

  belongs_to :user

  scope :latest, ->(limit = 10) { order(created_at: :desc).limit(limit) }
end
