class TripsController < ApplicationController
  before_action :authenticate_user!

  def index
    @trips = current_user.trips.order(created_at: :desc)
  end

  def show
    @trip = Trip.find(params[:id])
    @user_trip_status = @trip.user_trip_statuses.find_by(user: current_user)
  end

  def new
    @trip = Trip.new
  end

  def create
    @trip = Trip.new(trip_params)

    if @trip.save
      # Créer le statut UserTripStatus pour le créateur
      UserTripStatus.create!(\
        user: current_user,
        trip: @trip,
        role: :creator,
        trip_status: 'created',
        is_invited: true,
        invitation_accepted: true
      )

      redirect_to new_trip_trip_invitations_path(@trip), notice: 'Trip was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def join
    @trip = Trip.find(params[:id])
    @user_trip_status = @trip.user_trip_statuses.find_by(user: current_user)

    unless @user_trip_status
      redirect_to root_path, alert: 'You are not invited to this trip.'
    end
  end

  def accept_invitation
    @trip = Trip.find(params[:id])
    @user_trip_status = @trip.user_trip_statuses.find_by(user: current_user)

    if @user_trip_status
      @user_trip_status.update(invitation_accepted: true, trip_status: 'joined')
      redirect_to new_trip_preferences_form_path(@trip), notice: 'Invitation accepted!'
    else
      redirect_to root_path, alert: 'You are not invited to this trip.'
    end
  end

  private

  def trip_params
    params.require(:trip).permit(:name, :destination, :start_date, :end_date, :trip_type)
  end
end
