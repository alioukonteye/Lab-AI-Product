# Clear existing data
puts "Cleaning database..."
UserTripStatus.destroy_all
PreferencesForm.destroy_all
Trip.destroy_all
User.destroy_all

puts "Creating users..."
# Create test users
alice = User.create!(
  email: "alice@example.com",
  password: "password",
  password_confirmation: "password",
  first_name: "Alice"
)

bob = User.create!(
  email: "bob@example.com",
  password: "password",
  password_confirmation: "password",
  first_name: "Bob"
)

charlie = User.create!(
  email: "charlie@example.com",
  password: "password",
  password_confirmation: "password",
  first_name: "Charlie"
)

diana = User.create!(
  email: "diana@example.com",
  password: "password",
  password_confirmation: "password",
  first_name: "Diana"
)

puts "Creating trips in different states..."

# ===== TRIP 1: Waiting for participants to accept =====
trip1 = Trip.create!(
  name: "Paris Weekend",
  destination: "Paris, France",
  start_date: Date.today + 30.days,
  end_date: Date.today + 33.days,
  trip_type: "City break"
)

UserTripStatus.create!(
  user: alice,
  trip: trip1,
  role: :creator,
  trip_status: 'created',
  is_invited: true,
  invitation_accepted: true,
  form_filled: true
)

UserTripStatus.create!(
  user: bob,
  trip: trip1,
  role: :invitee,
  trip_status: 'invited',
  is_invited: true,
  invitation_accepted: false, # NOT ACCEPTED YET
  form_filled: false
)

# ===== TRIP 2: Waiting for preferences =====
trip2 = Trip.create!(
  name: "Tokyo Adventure",
  destination: "Tokyo, Japan",
  start_date: Date.today + 60.days,
  end_date: Date.today + 67.days,
  trip_type: "Adventure"
)

UserTripStatus.create!(
  user: alice,
  trip: trip2,
  role: :creator,
  trip_status: 'joined',
  is_invited: true,
  invitation_accepted: true,
  form_filled: true
)

UserTripStatus.create!(
  user: charlie,
  trip: trip2,
  role: :invitee,
  trip_status: 'joined',
  is_invited: true,
  invitation_accepted: true,
  form_filled: false # PREFERENCES NOT FILLED
)

# ===== TRIP 3: Ready to generate recommendations =====
trip3 = Trip.create!(
  name: "Barcelona Beach Trip",
  destination: "Barcelona, Spain",
  start_date: Date.today + 45.days,
  end_date: Date.today + 49.days,
  trip_type: "Beach"
)

alice_status_3 = UserTripStatus.create!(
  user: alice,
  trip: trip3,
  role: :creator,
  trip_status: 'joined',
  is_invited: true,
  invitation_accepted: true,
  form_filled: true
)

diana_status_3 = UserTripStatus.create!(
  user: diana,
  trip: trip3,
  role: :invitee,
  trip_status: 'joined',
  is_invited: true,
  invitation_accepted: true,
  form_filled: true
)

# Create preferences for both
PreferencesForm.create!(
  user_trip_status: alice_status_3,
  budget: "medium",
  travel_pace: "moderate",
  interests: "Museums, food, culture",
  activity_types: "Walking tours, restaurants"
)

PreferencesForm.create!(
  user_trip_status: diana_status_3,
  budget: "medium",
  travel_pace: "relaxed",
  interests: "Beach, nightlife",
  activity_types: "Beach clubs, bars"
)

# ===== TRIP 4: Recommendations ready - participants need to vote =====
trip4 = Trip.create!(
  name: "Rome Cultural Tour",
  destination: "Rome, Italy",
  start_date: Date.today + 50.days,
  end_date: Date.today + 54.days,
  trip_type: "Cultural"
)

alice_status_4 = UserTripStatus.create!(
  user: alice,
  trip: trip4,
  role: :creator,
  trip_status: 'joined',
  is_invited: true,
  invitation_accepted: true,
  form_filled: true,
  recommendation_reviewed: false
)

bob_status_4 = UserTripStatus.create!(
  user: bob,
  trip: trip4,
  role: :invitee,
  trip_status: 'joined',
  is_invited: true,
  invitation_accepted: true,
  form_filled: true,
  recommendation_reviewed: false
)

# Create preferences
PreferencesForm.create!(
  user_trip_status: alice_status_4,
  budget: "high",
  travel_pace: "moderate",
  interests: "History, architecture, art",
  activity_types: "Museums, guided tours"
)

PreferencesForm.create!(
  user_trip_status: bob_status_4,
  budget: "medium",
  travel_pace: "moderate",
  interests: "Food, culture",
  activity_types: "Food tours, restaurants"
)

# Create recommendation with activities
recommendation_4 = Recommendation.create!(trip: trip4)

[
  { name: 'Colosseum Tour', description: 'Explore ancient Roman amphitheater', price: 25, activity_type: 'Historical' },
  { name: 'Vatican Museums', description: 'Visit Sistine Chapel and art galleries', price: 30, activity_type: 'Cultural' },
  { name: 'Trastevere Food Tour', description: 'Taste authentic Roman cuisine', price: 75, activity_type: 'Food' },
  { name: 'Trevi Fountain Evening Walk', description: 'Romantic stroll through historic center', price: 0, activity_type: 'Sightseeing' },
  { name: 'Roman Forum Exploration', description: 'Walk through ancient Roman marketplace', price: 20, activity_type: 'Historical' }
].each do |activity_data|
  activity = ActivityItem.create!(
    name: activity_data[:name],
    description: activity_data[:description],
    price: activity_data[:price],
    activity_type: activity_data[:activity_type]
  )
  RecommendationItem.create!(recommendation: recommendation_4, activity_item: activity)
end

# ===== TRIP 5: Itinerary complete - ready to view =====
trip5 = Trip.create!(
  name: "Amsterdam Discovery",
  destination: "Amsterdam, Netherlands",
  start_date: Date.today + 40.days,
  end_date: Date.today + 43.days,
  trip_type: "City break"
)

alice_status_5 = UserTripStatus.create!(
  user: alice,
  trip: trip5,
  role: :creator,
  trip_status: 'joined',
  is_invited: true,
  invitation_accepted: true,
  form_filled: true,
  recommendation_reviewed: true
)

charlie_status_5 = UserTripStatus.create!(
  user: charlie,
  trip: trip5,
  role: :invitee,
  trip_status: 'joined',
  is_invited: true,
  invitation_accepted: true,
  form_filled: true,
  recommendation_reviewed: true
)

# Create preferences
PreferencesForm.create!(
  user_trip_status: alice_status_5,
  budget: "medium",
  travel_pace: "relaxed",
  interests: "Art, canals, cycling",
  activity_types: "Museums, bike tours"
)

PreferencesForm.create!(
  user_trip_status: charlie_status_5,
  budget: "medium",
  travel_pace: "moderate",
  interests: "History, coffee shops",
  activity_types: "Walking tours, cafes"
)

# Create recommendation
recommendation_5 = Recommendation.create!(trip: trip5)

activities_5 = [
  { name: 'Van Gogh Museum', description: 'Admire masterpieces of Dutch art', price: 22, activity_type: 'Cultural' },
  { name: 'Canal Cruise', description: 'Explore Amsterdam from the water', price: 18, activity_type: 'Sightseeing' },
  { name: 'Anne Frank House', description: 'Moving historical museum', price: 14, activity_type: 'Historical' },
  { name: 'Bike Tour', description: 'Cycle through the city like a local', price: 35, activity_type: 'Activity' },
  { name: 'Jordaan District Walk', description: 'Explore charming neighborhood', price: 0, activity_type: 'Sightseeing' }
].map do |activity_data|
  activity = ActivityItem.create!(
    name: activity_data[:name],
    description: activity_data[:description],
    price: activity_data[:price],
    activity_type: activity_data[:activity_type]
  )
  RecommendationItem.create!(recommendation: recommendation_5, activity_item: activity)
  activity
end

# Create votes (all liked for consensus)
recommendation_5.recommendation_items.each do |item|
  [alice, charlie].each do |user|
    Vote.create!(recommendation_item: item, user: user, liked: true)
  end
end

# Create itinerary
itinerary_5 = Itinerary.create!(trip: trip5)

# Day 1
[
  { time: '10:00', activity: activities_5[0], position: 1, day: 1 }, # Van Gogh Museum
  { time: '14:00', activity: activities_5[4], position: 2, day: 1 }, # Jordaan Walk
  { time: '17:00', activity: activities_5[1], position: 3, day: 1 }  # Canal Cruise
].each do |item_data|
  ItineraryItem.create!(
    itinerary: itinerary_5,
    activity_item: item_data[:activity],
    day: item_data[:day],
    time: item_data[:time],
    position: item_data[:position]
  )
end

# Day 2
[
  { time: '09:30', activity: activities_5[3], position: 1, day: 2 }, # Bike Tour
  { time: '13:00', activity: activities_5[2], position: 2, day: 2 }  # Anne Frank House
].each do |item_data|
  ItineraryItem.create!(
    itinerary: itinerary_5,
    activity_item: item_data[:activity],
    day: item_data[:day],
    time: item_data[:time],
    position: item_data[:position]
  )
end

puts "✅ Seed completed!"
puts ""
puts "=" * 60
puts "TEST USER LOGIN"
puts "=" * 60
puts "Email: alice@example.com"
puts "Password: password"
puts ""
puts "=" * 60
puts "TRIPS CREATED (as Alice)"
puts "=" * 60
puts "1. #{trip1.name} - État: Waiting for participants to accept"
puts "   → Bob hasn't accepted yet"
puts ""
puts "2. #{trip2.name} - État: Waiting for preferences"
puts "   → Charlie needs to fill preferences"
puts ""
puts "3. #{trip3.name} - État: Ready to generate recommendations"
puts "   → All preferences filled, ready to generate!"
puts ""
puts "4. #{trip4.name} - État: Recommendations ready - vote now!"
puts "   → Alice and Bob need to review and vote on activities"
puts ""
puts "5. #{trip5.name} - État: Itinerary complete!"
puts "   → View your personalized itinerary"
puts ""
puts "=" * 60
puts "Autres users disponibles:"
puts "- bob@example.com (password: password)"
puts "- charlie@example.com (password: password)"
puts "- diana@example.com (password: password)"
puts "=" * 60
