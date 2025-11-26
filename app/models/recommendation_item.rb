class RecommendationItem < ApplicationRecord
  belongs_to :recommendation
  belongs_to :activity_item
  has_many :votes, dependent: :destroy
end
