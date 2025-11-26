class ActivityItem < ApplicationRecord
  has_many :recommendation_items, dependent: :destroy
  has_many :itinerary_items, dependent: :destroy
end
