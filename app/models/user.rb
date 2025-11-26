
class User < ApplicationRecord
  # Inclure les modules devise par défaut. Les autres disponibles sont :
  # :confirmable, :lockable, :timeoutable, :trackable et :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :user_trip_statuses, dependent: :destroy
  has_many :trips, through: :user_trip_statuses
  has_many :votes, dependent: :destroy
end
