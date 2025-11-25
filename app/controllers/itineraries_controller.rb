class ItinerariesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_trip

  def create
    # Sélectionner les activités avec une majorité de likes
    # Logique : Pour chaque élément de recommandation, compter les likes. Si likes > (participants / 2), l'inclure.

    recommendation = @trip.recommendation
    return redirect_to @trip, alert: "No recommendations found." unless recommendation

    participants_count = @trip.user_trip_statuses.count
    # Calcul du seuil de majorité stricte (plus de 50% des participants)
    # Exemple : pour 4 participants, il faut 3 votes. Pour 3 participants, il faut 2 votes.
    majority_threshold = (participants_count / 2) + 1

    selected_activity_ids = []
    recommendation.recommendation_items.each do |item|
      likes = item.votes.where(liked: true).count
      if likes >= majority_threshold
        selected_activity_ids << item.activity_item_id
      end
    end

    if selected_activity_ids.empty?
      # Solution de repli : s'il n'y a pas de majorité, prendre les 3 plus aimés
      selected_activity_ids = recommendation.recommendation_items
        .sort_by { |item| -item.votes.where(liked: true).count }
        .first(3)
        .map(&:activity_item_id)
    end

    # Appeler le service Gemini
    service = GeminiService.new
    itinerary_data = service.generate_itinerary(@trip, selected_activity_ids)

    if itinerary_data.any?
      ActiveRecord::Base.transaction do
        @itinerary = Itinerary.create!(trip: @trip)

        itinerary_data.each do |day_key, activities|
          day_number = day_key.gsub('day_', '').to_i
          activities.each_with_index do |activity, index|
            # Trouver ou créer l'élément d'activité s'il est nouveau (Gemini pourrait halluciner de nouveaux éléments ou modifier les noms)
            # Mais nous avons passé des ID, donc idéalement il retourne des activités correspondantes.
            # Pour simplifier, nous allons essayer de faire correspondre par nom ou simplement en créer un nouveau si nécessaire,
            # OU nous utilisons simplement la description fournie par Gemini.

            # En fait, le prompt demande "activity_name". Nous devrions essayer de trouver l'ActivityItem.

            # Si non trouvé (peut-être que le nom a légèrement changé), créer un espace réservé ou simplement sauter ?
            # Créons-en un nouveau si non trouvé pour être sûr, ou utilisons le premier sélectionné ?
            # Mieux : Le prompt devrait retourner l'ID ? Non, Gemini ne connaît pas nos ID facilement à moins que nous ne les passions.
            # Nous avons passé des noms.

            activity_item = ActivityItem.find_by(name: activity['activity_name'])

            activity_item ||= ActivityItem.create!(
              name: activity['activity_name'],
              description: activity['description'],
              activity_type: 'Itinerary Item',
              price: 0 # Inconnu
            )

            ItineraryItem.create!(
              itinerary: @itinerary,
              activity_item: activity_item,
              day: day_number,
              time: activity['time'],
              position: index + 1
            )
          end
        end
      end

      redirect_to trip_itinerary_path(@trip, @itinerary), notice: 'Itinerary generated!'
    else
      redirect_to @trip, alert: 'Failed to generate itinerary. Please try again.'
    end
  end

  def show
    @itinerary = Itinerary.find(params[:id])
    @itinerary_items = @itinerary.itinerary_items.includes(:activity_item).order(:day, :time)
    @grouped_items = @itinerary_items.group_by(&:day)
  end

  private

  def set_trip
    @trip = Trip.find(params[:trip_id])
  end
end
