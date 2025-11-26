class VotesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_recommendation_item

  def create
    @vote = @recommendation_item.votes.find_or_initialize_by(user: current_user)
    @vote.liked = params[:vote][:liked]

    if @vote.save
      check_recommendation_status
      TripBroadcaster.broadcast_update(@recommendation_item.recommendation.trip)

      respond_to do |format|
        format.html { redirect_back(fallback_location: root_path, notice: 'Vote recorded.') }
        format.turbo_stream do
          @recommendation = @recommendation_item.recommendation
          @trip = @recommendation.trip
          render turbo_stream: turbo_stream.replace("recommendation_card", partial: "recommendations/card", locals: { recommendation: @recommendation, trip: @trip })
        end
      end
    else
      redirect_back(fallback_location: root_path, alert: 'Unable to vote.')
    end
  end

  private

  def set_recommendation_item
    @recommendation_item = RecommendationItem.find(params[:recommendation_item_id])
  end

  def check_recommendation_status
    # Logique pour vérifier si toutes les activités sont revues et mettre à jour UserTripStatus
    # "pour qu'une recommandation passe à validée, il faut que toutes les activités aient une majorité de likes."
    # "Si c'est le cas, le champs "recommendation_reviewed" de la table user_trip_status passe à true."

    # En fait, le brief dit : "pour qu'une recommandation passe à validée, il faut que toutes les activités aient une majorité de likes. Si c'est le cas, le champs "recommendation_reviewed" de la table user_trip_status passe à true."
    # Cela implique de vérifier le statut GLOBAL de la recommandation, mais de mettre à jour le statut de l'UTILISATEUR ?
    # Ou est-ce que "recommendation_reviewed" signifie que l'UTILISATEUR a fini de revoir ?
    # "lorsque les utilisateurs ont fait une revue des activités proposées" -> statut de la page d'attente.

    # J'interprète "recommendation_reviewed" comme "L'utilisateur a voté sur tous les éléments".
    recommendation = @recommendation_item.recommendation
    total_items = recommendation.recommendation_items.count
    user_votes = Vote.where(user: current_user, recommendation_item: recommendation.recommendation_items).count

    if user_votes == total_items
      user_trip_status = UserTripStatus.find_by(user: current_user, trip: recommendation.trip)
      user_trip_status.update(recommendation_reviewed: true)

      # Check if ALL participants have reviewed
      trip = recommendation.trip
      all_reviewed = trip.user_trip_statuses.all?(&:recommendation_reviewed?)

      if all_reviewed && !trip.itinerary
        GenerateItineraryJob.perform_later(trip)
      end
    end
  end
end
