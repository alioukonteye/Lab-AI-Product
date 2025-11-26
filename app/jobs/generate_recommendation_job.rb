require 'ostruct'

class GenerateRecommendationJob < ApplicationJob
  queue_as :default

  def perform(trip)
    Rails.logger.info "Starting GenerateRecommendationJob for trip #{trip.id}"

    # Check if recommendation already exists to avoid duplicates
    return if trip.recommendation.present?

    # Agregate preferences
    forms = trip.user_trip_statuses.map(&:preferences_form).compact

    aggregated_preferences = OpenStruct.new(
      budget: forms.map(&:budget).join(", "),
      travel_pace: forms.map(&:travel_pace).join(", "),
      interests: forms.map(&:interests).join(", "),
      activity_types: forms.map(&:activity_types).join(", ")
    )

    # Call Gemini service
    service = GeminiService.new
    activities_data = service.generate_activities(trip, aggregated_preferences)

    if activities_data.any?
      ActiveRecord::Base.transaction do
        recommendation = Recommendation.create!(trip: trip)

        activities_data.each do |activity_data|
          activity = ActivityItem.create!(
            name: activity_data['name'],
            description: activity_data['description'],
            price: activity_data['price'],
            activity_type: activity_data['activity_type']
          )
          RecommendationItem.create!(recommendation: recommendation, activity_item: activity)
        end
      end
      Rails.logger.info "Recommendation generated successfully for trip #{trip.id}"
      TripBroadcaster.broadcast_update(trip)
    else
      Rails.logger.error "Failed to generate activities for trip #{trip.id}"
    end
  rescue StandardError => e
    Rails.logger.error "Error in GenerateRecommendationJob: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
  end
end
