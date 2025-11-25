# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

puts "\n\e[34m============================================================\e[0m"
puts "\e[34m🌱 STARTING DATABASE SEEDING\e[0m"
puts "\e[34m============================================================\e[0m\n"

puts "\e[33m🗑️  Cleaning database...\e[0m"
# Clean up in reverse order of dependencies
Vote.destroy_all
ItineraryItem.destroy_all
Itinerary.destroy_all
RecommendationItem.destroy_all
Recommendation.destroy_all
ActivityItem.destroy_all
PreferencesForm.destroy_all
UserTripStatus.destroy_all
Trip.destroy_all
User.destroy_all

puts "\e[32m✅ Database cleaned.\e[0m\n"

puts "\e[36m👥 Creating Users...\e[0m"
alice = User.create!(
  email: 'alice@example.com',
  password: 'password',
  first_name: 'Alice',
  last_name: 'Wonderland'
)

bob = User.create!(
  email: 'bob@example.com',
  password: 'password',
  first_name: 'Bob',
  last_name: 'Builder'
)

charlie = User.create!(
  email: 'charlie@example.com',
  password: 'password',
  first_name: 'Charlie',
  last_name: 'Chaplin'
)
puts "\e[32m✅ Users created: Alice, Bob, Charlie\e[0m\n"

# --- Trip A: Just Created ---
puts "\e[35m✈️  Creating Trip A (Paris) - Just Created...\e[0m"
trip_a = Trip.create!(
  name: 'Paris Getaway',
  destination: 'Paris, France',
  start_date: Date.today + 1.month,
  end_date: Date.today + 1.month + 5.days,
  trip_type: 'leisure'
)

UserTripStatus.create!(
  user: alice,
  trip: trip_a,
  role: :creator,
  trip_status: 'created',
  is_invited: true,
  invitation_accepted: true
)
puts "\e[32m   -> Trip created.\e[0m\n"

# --- Trip B: Recommendations Ready ---
puts "\e[35m🍣 Creating Trip B (Tokyo) - Recommendations Ready...\e[0m"
trip_b = Trip.create!(
  name: 'Tokyo Adventure',
  destination: 'Tokyo, Japan',
  start_date: Date.today + 2.months,
  end_date: Date.today + 2.months + 10.days,
  trip_type: 'adventure'
)

UserTripStatus.create!(
  user: alice,
  trip: trip_b,
  role: :creator,
  trip_status: 'created',
  is_invited: true,
  invitation_accepted: true
)

rec_b = Recommendation.create!(
  trip: trip_b,
  system_prompt: "Generated recommendations for Tokyo..."
)

# Create some activity items
activity_1 = ActivityItem.create!(
  name: 'Senso-ji Temple',
  description: 'Ancient Buddhist temple in Asakusa.',
  price: 0,
  activity_type: 'culture'
)
activity_2 = ActivityItem.create!(
  name: 'Tokyo Skytree',
  description: 'Tallest tower in the world.',
  price: 3000,
  activity_type: 'sightseeing'
)

RecommendationItem.create!(recommendation: rec_b, activity_item: activity_1)
RecommendationItem.create!(recommendation: rec_b, activity_item: activity_2)
puts "\e[32m   -> Trip and recommendations created.\e[0m\n"


# --- Trip C: Itinerary Ready ---
puts "\e[35m🗽 Creating Trip C (New York) - Itinerary Ready...\e[0m"
trip_c = Trip.create!(
  name: 'NYC Business Trip',
  destination: 'New York, USA',
  start_date: Date.today + 3.months,
  end_date: Date.today + 3.months + 3.days,
  trip_type: 'business'
)

UserTripStatus.create!(
  user: alice,
  trip: trip_c,
  role: :creator,
  trip_status: 'created',
  is_invited: true,
  invitation_accepted: true
)

itinerary_c = Itinerary.create!(
  trip: trip_c,
  system_prompt: "Final itinerary for NYC..."
)

activity_3 = ActivityItem.create!(
  name: 'Central Park Walk',
  description: 'Relaxing walk in the park.',
  price: 0,
  activity_type: 'leisure'
)

ItineraryItem.create!(
  itinerary: itinerary_c,
  activity_item: activity_3,
  day: 1,
  time: '10:00',
  position: 1
)
puts "\e[32m   -> Trip and itinerary created.\e[0m\n"

# --- Trip D: Joined Trip ---
puts "\e[35m💂 Creating Trip D (London) - Bob Creator, Alice Joined...\e[0m"
trip_d = Trip.create!(
  name: 'London Calling',
  destination: 'London, UK',
  start_date: Date.today + 4.months,
  end_date: Date.today + 4.months + 4.days,
  trip_type: 'culture'
)

UserTripStatus.create!(
  user: bob,
  trip: trip_d,
  role: :creator,
  trip_status: 'created',
  is_invited: true,
  invitation_accepted: true
)

UserTripStatus.create!(
  user: alice,
  trip: trip_d,
  role: :invitee,
  trip_status: 'joined',
  is_invited: true,
  invitation_accepted: true
)
puts "\e[32m   -> Trip created with Alice as joined participant.\e[0m\n"

# --- Trip E: Pending Invitation ---
puts "\e[35m🍺 Creating Trip E (Berlin) - Charlie Creator, Alice Pending...\e[0m"
trip_e = Trip.create!(
  name: 'Berlin Tech Conf',
  destination: 'Berlin, Germany',
  start_date: Date.today + 5.months,
  end_date: Date.today + 5.months + 2.days,
  trip_type: 'business'
)

UserTripStatus.create!(
  user: charlie,
  trip: trip_e,
  role: :creator,
  trip_status: 'created',
  is_invited: true,
  invitation_accepted: true
)

UserTripStatus.create!(
  user: alice,
  trip: trip_e,
  role: :invitee,
  trip_status: 'invited',
  is_invited: true,
  invitation_accepted: false
)
puts "\e[32m   -> Trip created with Alice as pending invitee.\e[0m\n"

puts "\n\e[34m============================================================\e[0m"
puts "\e[34m🎉 SEEDING COMPLETED SUCCESSFULLY!\e[0m"
puts "\e[34m============================================================\e[0m\n"

puts "\n\e[1;33m📋 RECAP & TESTING INSTRUCTIONS\e[0m"
puts "\e[33m------------------------------------------------------------\e[0m"

puts "\n\e[1;36m🔑 CREDENTIALS\e[0m"
puts "  • \e[1mAlice\e[0m   | Login: \e[36malice@example.com\e[0m   | Pass: \e[36mpassword\e[0m | -> \e[32mMain Tester\e[0m"
puts "  • \e[1mBob\e[0m     | Login: \e[36mbob@example.com\e[0m     | Pass: \e[36mpassword\e[0m | -> Collaborator"
puts "  • \e[1mCharlie\e[0m | Login: \e[36mcharlie@example.com\e[0m | Pass: \e[36mpassword\e[0m | -> Collaborator"

puts "\n\e[1;35m🧪 TEST SCENARIOS (Log in as Alice)\e[0m"
puts "  1. \e[1mParis Getaway\e[0m     -> \e[36mJust Created\e[0m. Test generating recommendations."
puts "  2. \e[1mTokyo Adventure\e[0m   -> \e[36mRecommendations Ready\e[0m. Test voting/selecting."
puts "  3. \e[1mNYC Business Trip\e[0m -> \e[36mItinerary Ready\e[0m. Test viewing final plan."
puts "  4. \e[1mLondon Calling\e[0m    -> \e[36mJoined\e[0m. Test participant view."
puts "  5. \e[1mBerlin Tech Conf\e[0m  -> \e[36mPending Invite\e[0m. Test accepting invitation."

puts "\n\e[34m============================================================\e[0m\n"
