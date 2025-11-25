require "test_helper"

class VotesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @recommendation_item = recommendation_items(:two)
    sign_in users(:one)
  end

  test "should create vote" do
    assert_difference("Vote.count") do
      post recommendation_item_votes_url(@recommendation_item), params: { vote: { liked: true } }, headers: { "HTTP_REFERER" => trip_recommendation_url(@recommendation_item.recommendation.trip, @recommendation_item.recommendation) }
    end

    assert_redirected_to trip_recommendation_url(@recommendation_item.recommendation.trip, @recommendation_item.recommendation)
  end
end
