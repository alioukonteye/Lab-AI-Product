require "test_helper"
require "minitest/mock"

class RecommendationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @trip = trips(:one)
    @recommendation = recommendations(:one)
    sign_in users(:one)
  end

  test "should create recommendation" do
    mock_service = Minitest::Mock.new
    mock_service.expect :generate_activities, [{"name" => "Test Activity", "description" => "Desc", "price" => 10, "activity_type" => "Fun"}], [@trip, Object]

    GeminiService.stub :new, mock_service do
      assert_difference("Recommendation.count") do
        post trip_recommendations_url(@trip)
      end
    end

    assert_redirected_to trip_recommendation_url(@trip, Recommendation.last)
  end

  test "should show recommendation" do
    get trip_recommendation_url(@trip, @recommendation)
    assert_response :success
  end
end
