require "test_helper"
require "minitest/mock"

class ItinerariesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @trip = trips(:one)
    @itinerary = itineraries(:one)
    sign_in users(:one)
  end

  test "should create itinerary" do
    mock_service = Minitest::Mock.new
    mock_service.expect :generate_itinerary, {"day_1" => [{"time" => "10:00", "activity_name" => "Test", "description" => "Desc"}]}, [@trip, Array]

    GeminiService.stub :new, mock_service do
      assert_difference("Itinerary.count") do
        post trip_itineraries_url(@trip)
      end
    end

    assert_redirected_to trip_itinerary_url(@trip, Itinerary.last)
  end

  test "should show itinerary" do
    get trip_itinerary_url(@trip, @itinerary)
    assert_response :success
  end
end
