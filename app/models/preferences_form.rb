class PreferencesForm < ApplicationRecord
  belongs_to :user_trip_status

  validates :budget, :travel_pace, :interests, :activity_types, presence: true
end
