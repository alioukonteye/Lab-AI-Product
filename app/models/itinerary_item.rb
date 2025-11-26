class ItineraryItem < ApplicationRecord
  belongs_to :itinerary
  belongs_to :activity_item
end
