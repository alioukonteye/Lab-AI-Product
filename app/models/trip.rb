class Trip < ApplicationRecord
  has_many :user_trip_statuses, dependent: :destroy
  has_many :users, through: :user_trip_statuses
  has_one :recommendation, dependent: :destroy
  has_one :itinerary, dependent: :destroy

  validates :name, :destination, :start_date, :end_date, presence: true
end
