class Recommendation < ApplicationRecord
  belongs_to :trip
  has_many :recommendation_items, dependent: :destroy
  has_many :activity_items, through: :recommendation_items

  # Check if votes match (consensus reached on activities)
  # Returns false if not enough activities have majority approval
  def votes_match?
    return false if recommendation_items.empty?

    participants_count = trip.user_trip_statuses.count
    majority_threshold = (participants_count / 2) + 1

    # Count how many items have majority approval
    approved_count = recommendation_items.count do |item|
      item.votes.where(liked: true).count >= majority_threshold
    end

    # We need at least 1 approved activity for consensus
    approved_count > 0
  end
end
