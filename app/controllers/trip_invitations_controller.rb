class TripInvitationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_trip

  def new
  end

  def create
    email = params[:email]
    user = User.find_by(email: email)

    if user.nil?
      user = User.invite!(email: email)
    end

    # Vérifier si l'utilisateur est déjà invité
    if @trip.user_trip_statuses.exists?(user: user)
      redirect_to @trip, alert: "User already invited."
      return
    end

    UserTripStatus.create!(
      user: user,
      trip: @trip,
      role: :invitee,
      trip_status: 'invited',
      is_invited: true,
      invitation_accepted: false
    )

    redirect_to @trip, notice: "Invitation sent to #{email}."
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
