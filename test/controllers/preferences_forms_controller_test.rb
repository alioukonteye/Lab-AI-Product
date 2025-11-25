require "test_helper"

class PreferencesFormsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @trip = trips(:one)
    sign_in users(:two) # User two has not filled form
  end

  test "should get new" do
    get new_trip_preferences_form_url(@trip)
    assert_response :success
  end

  test "should create preferences form" do
    assert_difference("PreferencesForm.count") do
      post trip_preferences_forms_url(@trip), params: { preferences_form: { budget: "Medium", travel_pace: "Fast", interests: "Art", activity_types: "Museums" } }
    end

    assert_redirected_to trip_url(@trip)
  end
end
