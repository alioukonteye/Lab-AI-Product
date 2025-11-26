class TripInvitationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_trip

  def new
  end

  def create
    emails = params[:emails]&.reject(&:blank?) || []

    if emails.empty?
      redirect_to new_trip_trip_invitations_path(@trip), alert: "Please enter at least one email address."
      return
    end

    emails.each do |email|
      user = User.find_by(email: email)

      # Créer utilisateur si n'existe pas
      if user.nil?
        user = User.invite!(email: email)
      end

      # Skip si déjà invité
      next if @trip.user_trip_statuses.exists?(user: user)

      UserTripStatus.create!(
        user: user,
        trip: @trip,
        role: :invitee,
        trip_status: 'invited',
        is_invited: true,
        invitation_accepted: false
      )
    end

    redirect_to new_trip_preferences_form_path(@trip), notice: "Invitations sent successfully!"
  end

  private

  def set_trip
    @trip = Trip.find(params[:trip_id])
    # S'assurer que l'utilisateur actuel est le créateur
    unless @trip.user_trip_statuses.find_by(user: current_user)&.creator?
      redirect_to @trip, alert: "Only the trip creator can invite participants."
    end
  end
end
