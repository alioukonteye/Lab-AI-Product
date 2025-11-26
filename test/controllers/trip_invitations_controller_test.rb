require "test_helper"

class TripInvitationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @trip = trips(:one)
    sign_in users(:one)
  end

  test "should get new" do
    get new_trip_trip_invitation_url(@trip)
    assert_response :success
  end

  test "should create invitation" do
    assert_difference("UserTripStatus.count") do
      post trip_trip_invitations_url(@trip), params: { email: "newuser@example.com" }
    end

    assert_redirected_to trip_url(@trip)
  end
end
