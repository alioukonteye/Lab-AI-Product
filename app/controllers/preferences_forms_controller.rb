class PreferencesFormsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_trip

  def new
    @user_trip_status = @trip.user_trip_statuses.find_by(user: current_user)
    if @user_trip_status.form_filled?
      redirect_to @trip, alert: "You have already filled your preferences."
      return
    end
    @preferences_form = PreferencesForm.new
  end

  def create
    @user_trip_status = @trip.user_trip_statuses.find_by(user: current_user)
    @preferences_form = PreferencesForm.new(preferences_form_params)
    @preferences_form.user_trip_status = @user_trip_status

    if @preferences_form.save
      @user_trip_status.update(form_filled: true)
      redirect_to @trip, notice: 'Preferences saved successfully.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_trip
    @trip = Trip.find(params[:trip_id])
  end

  def preferences_form_params
    params.require(:preferences_form).permit(:budget, :travel_pace, :interests, :activity_types)
  end
end
