require 'ruby_llm'
require 'ruby_llm/schema'

class GeminiService
  # Définition des schémas pour la sortie structurée
  class ActivitiesSchema < RubyLLM::Schema
    array :activities do
      object do
        string :name
        string :description
        number :price
        string :category
        string :activity_type
      end
    end
  end

  class ItinerarySchema < RubyLLM::Schema
    array :days do
      number :day_number
      array :activities do
        string :time
        string :activity_name
        string :description
      end
    end
  end

  def generate_activities(trip, preferences)
    prompt = <<~PROMPT
      Generate a list of 5 distinct activities for a trip to #{trip.destination} for #{trip.trip_type}.
      Dates: #{trip.start_date} to #{trip.end_date}.
      Preferences:
      - Budget: #{preferences.budget}
      - Pace: #{preferences.travel_pace}
      - Interests: #{preferences.interests}
      - Activity Types: #{preferences.activity_types}
    PROMPT

    response = RubyLLM.chat(model: 'gpt-4o-mini')
                      .with_schema(ActivitiesSchema)
                      .ask(prompt)

    # with_schema returns a RubyLLM::Message object with structured content
    content = response.respond_to?(:content) ? response.content : response

    puts "DEBUG: Raw AI Response: #{response.inspect}"
    puts "DEBUG: Parsed Content: #{content.inspect}"
    Rails.logger.info "DEBUG: Raw AI Response: #{response.inspect}"
    Rails.logger.info "DEBUG: Parsed Content: #{content.inspect}"

    return [] unless content && content['activities']
    content['activities']
  rescue StandardError => e
    Rails.logger.error "AI API Error: #{e.message}"
    []
  end

  def generate_itinerary(trip, selected_activity_ids)
    activities = ActivityItem.where(id: selected_activity_ids).map { |a| "- #{a.name}: #{a.description} (#{a.category})" }.join("\n")

    prompt = <<~PROMPT
      Create a day-by-day itinerary for a trip to #{trip.destination} from #{trip.start_date} to #{trip.end_date}.
      Include the following selected activities:
      #{activities}
    PROMPT

    Rails.logger.info "Generating itinerary for trip #{trip.id} with activities: #{selected_activity_ids}"

    response = RubyLLM.chat(model: 'gpt-4o-mini')
                      .with_schema(ItinerarySchema)
                      .ask(prompt)

    Rails.logger.info "AI API response: #{response.inspect}"

    # with_schema returns a RubyLLM::Message object with structured content
    content = response.respond_to?(:content) ? response.content : response

    return {} unless content && content['days']

    # Transform the structured response to the format expected by the controller
    # Controller expects a hash { "day_1" => [...], "day_2" => [...] }
    formatted_response = {}
    content['days'].each do |day|
      formatted_response["day_#{day['day_number']}"] = day['activities']
    end
    return formatted_response if formatted_response.any?

    # Fallback if API fails or returns empty
    Rails.logger.warn "AI API returned empty response, using fallback data"
    fallback_itinerary(trip)
  rescue StandardError => e
    Rails.logger.error "AI API Error: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    fallback_itinerary(trip)
  end

  private

  def fallback_itinerary(trip)
    {
      "day_1" => [
        { "time" => "09:00", "activity_name" => "Morning Exploration", "description" => "Start your day exploring the city center." },
        { "time" => "13:00", "activity_name" => "Local Lunch", "description" => "Enjoy delicious local cuisine." },
        { "time" => "15:00", "activity_name" => "Afternoon Sightseeing", "description" => "Visit famous landmarks." }
      ],
      "day_2" => [
        { "time" => "10:00", "activity_name" => "Cultural Tour", "description" => "Visit museums and art galleries." },
        { "time" => "14:00", "activity_name" => "Relaxation", "description" => "Spend time at a park or beach." }
      ]
    }
  end
end
