class PreferencesFormsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_trip

  def new
    @user_trip_status = @trip.user_trip_statuses.find_by(user: current_user)
    if @user_trip_status.form_filled?
      redirect_to @trip, alert: "You have already filled your preferences."
      return
    end

    @step = (params[:step] || 1).to_i
    session[:preferences_data] ||= {}

    # Initialize form with session data
    @preferences_form = PreferencesForm.new(session[:preferences_data])
    @preferences_form.user_trip_status = @user_trip_status
  end

  def create
    @user_trip_status = @trip.user_trip_statuses.find_by(user: current_user)
    @step = (params[:step] || 1).to_i

    # Initialize session storage for preferences
    session[:preferences_data] ||= {}

    # Update session with current step data
    if params[:preferences_form].present?
      session[:preferences_data].merge!(preferences_form_params.to_h)
    end

    # Only save to database at final step (4)
    if @step == 4
      @preferences_form = PreferencesForm.find_or_initialize_by(user_trip_status: @user_trip_status)
      @preferences_form.assign_attributes(session[:preferences_data])

      if @preferences_form.save
        @user_trip_status.update(form_filled: true)
        session[:preferences_data] = nil # Clear session

        # Check if all participants have filled preferences
        all_filled = @trip.user_trip_statuses.all?(&:form_filled?)

        # Broadcast update to all participants (so they see "Waiting" or "Generating")
        TripBroadcaster.broadcast_update(@trip)

        # Auto-generate recommendations if all preferences are filled and no recommendation exists
        if all_filled && !@trip.recommendation
          GenerateRecommendationJob.perform_later(@trip)
        end

        redirect_to @trip, notice: 'Preferences saved successfully.'
      else
        render :new, status: :unprocessable_entity
      end
    else
      # For steps 1-3, just move to next step
      redirect_to new_trip_preferences_form_path(@trip, step: @step + 1)
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
