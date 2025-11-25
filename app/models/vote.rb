class Vote < ApplicationRecord
  belongs_to :user
  belongs_to :recommendation_item

  validates :user_id, uniqueness: { scope: :recommendation_item_id }
end
