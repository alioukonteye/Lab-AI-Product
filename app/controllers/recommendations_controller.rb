require 'ostruct'

class RecommendationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_trip

  def create
    # Agréger les préférences
    forms = @trip.user_trip_statuses.map(&:preferences_form).compact

    aggregated_preferences = OpenStruct.new(
      budget: forms.map(&:budget).join(", "),
      travel_pace: forms.map(&:travel_pace).join(", "),
      interests: forms.map(&:interests).join(", "),
      activity_types: forms.map(&:activity_types).join(", ")
    )

    # Appeler le service Gemini
    service = GeminiService.new
    activities_data = service.generate_activities(@trip, aggregated_preferences)

    if activities_data.any?
      ActiveRecord::Base.transaction do
        @recommendation = Recommendation.create!(trip: @trip)

        activities_data.each do |activity_data|
          activity = ActivityItem.create!(
            name: activity_data['name'],
            description: activity_data['description'],
            price: activity_data['price'],
            activity_type: activity_data['activity_type']
            # category: activity_data['category'] # Pas de colonne category
            # image_url: activity_data['image_url'] # Si nous l'avions
          )
          RecommendationItem.create!(recommendation: @recommendation, activity_item: activity)
        end
      end

      redirect_to trip_recommendation_path(@trip, @recommendation), notice: 'Suggestions generated!'
    else
      redirect_to @trip, alert: 'Failed to generate suggestions. Please try again.'
    end
  end

  def show
    @recommendation = Recommendation.find(params[:id])
    @recommendation_items = @recommendation.recommendation_items.includes(:activity_item, :votes)
  end

  private

  def set_trip
    @trip = Trip.find(params[:trip_id])
  end
end
