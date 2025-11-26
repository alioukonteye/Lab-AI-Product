class GenerateItineraryJob < ApplicationJob
  queue_as :default

  def perform(trip)
    Rails.logger.info "Starting GenerateItineraryJob for trip #{trip.id}"

    # Check if itinerary already exists
    return if trip.itinerary.present?

    recommendation = trip.recommendation
    unless recommendation
      Rails.logger.warn "No recommendation found for trip #{trip.id}, cannot generate itinerary"
      return
    end

    participants_count = trip.user_trip_statuses.count
    majority_threshold = (participants_count / 2) + 1

    selected_activity_ids = []
    recommendation.recommendation_items.each do |item|
      likes = item.votes.where(liked: true).count
      if likes >= majority_threshold
        selected_activity_ids << item.activity_item_id
      end
    end

    if selected_activity_ids.empty?
      # Fallback: take top 3 most liked
      selected_activity_ids = recommendation.recommendation_items
        .sort_by { |item| -item.votes.where(liked: true).count }
        .first(3)
        .map(&:activity_item_id)
    end

    # Call Gemini service
    service = GeminiService.new
    itinerary_data = service.generate_itinerary(trip, selected_activity_ids)

    if itinerary_data.any?
      ActiveRecord::Base.transaction do
        itinerary = Itinerary.create!(trip: trip)

        itinerary_data.each do |day_key, activities|
          day_number = day_key.gsub('day_', '').to_i
          activities.each_with_index do |activity, index|
            activity_item = ActivityItem.find_by(name: activity['activity_name'])

            activity_item ||= ActivityItem.create!(
              name: activity['activity_name'],
              description: activity['description'],
              activity_type: 'Itinerary Item',
              price: 0
            )

            ItineraryItem.create!(
              itinerary: itinerary,
              activity_item: activity_item,
              day: day_number,
              time: activity['time'],
              position: index + 1
            )
          end
        end
      end
      Rails.logger.info "Itinerary generated successfully for trip #{trip.id}"
      TripBroadcaster.broadcast_update(trip)
    else
      Rails.logger.error "Failed to generate itinerary data for trip #{trip.id}"
    end
  rescue StandardError => e
    Rails.logger.error "Error in GenerateItineraryJob: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
  end
end
