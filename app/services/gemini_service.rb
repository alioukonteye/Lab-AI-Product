require 'ruby_llm'
require 'ruby_llm/schema'

class GeminiService
  # Définition des schémas pour la sortie structurée
  class ActivitiesSchema < RubyLLM::Schema
    array :activities do
      string :name
      string :description
      number :price
      string :category
      string :activity_type
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

    response = RubyLLM.chat(model: 'gemini-2.0-flash')
                      .with_schema(ActivitiesSchema)
                      .ask(prompt)

    # La réponse est déjà parsée grâce au schéma
    # Cependant, RubyLLM retourne un hash avec les clés définies dans le schéma
    # ActivitiesSchema définit un tableau :activities

    return [] unless response && response['activities']
    response['activities']
  rescue StandardError => e
    Rails.logger.error "Gemini Error: #{e.message}"
    []
  end

  def generate_itinerary(trip, selected_activity_ids)
    activities = ActivityItem.where(id: selected_activity_ids).map { |a| "- #{a.name}: #{a.description} (#{a.category})" }.join("\n")

    prompt = <<~PROMPT
      Create a day-by-day itinerary for a trip to #{trip.destination} from #{trip.start_date} to #{trip.end_date}.
      Include the following selected activities:
      #{activities}
    PROMPT

    response = RubyLLM.chat(model: 'gemini-2.0-flash')
                      .with_schema(ItinerarySchema)
                      .ask(prompt)

    return {} unless response && response['days']

    # Transformer la réponse structurée au format attendu par le contrôleur
    # Le contrôleur attend un hash { "day_1" => [...], "day_2" => [...] }
    formatted_response = {}
    response['days'].each do |day|
      formatted_response["day_#{day['day_number']}"] = day['activities']
    end
    formatted_response
  rescue StandardError => e
    Rails.logger.error "Gemini Error: #{e.message}"
    {}
  end
end
