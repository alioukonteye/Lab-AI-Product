# Yugo - AI Group Trip Planner

Yugo is an AI-powered application designed to simplify group trip planning. It helps users organize trips, invite friends, collect preferences, and generate personalized itineraries using Google Gemini AI.

## Functional Description

### Key Features
- **Trip Creation**: Users can create trips with a destination, dates, and type (e.g., Leisure, Adventure).
- **Group Management**: Invite friends to join the trip via email.
- **Preferences Collection**: Each participant fills out a preferences form (Budget, Pace, Interests, Activity Types).
- **AI Recommendations**: The app aggregates group preferences and uses Gemini AI to suggest 5 distinct activities.
- **Voting System**: Participants vote (like/dislike) on suggested activities.
- **Itinerary Generation**: Once suggestions are reviewed, the AI generates a detailed day-by-day itinerary based on the most popular activities.

### User Flow
1.  **Create Trip**: Sign up/Login and create a new trip.
2.  **Invite**: Send invitations to friends.
3.  **Preferences**: Everyone fills out their travel preferences.
4.  **Suggestions**: The creator triggers AI to generate activity suggestions.
5.  **Vote**: Participants review and vote on activities.
6.  **Itinerary**: The creator triggers AI to generate the final itinerary.

## Technical Description

### Stack
- **Backend**: Ruby on Rails 7.1.6
- **Database**: PostgreSQL
- **Frontend**: Hotwire (Turbo & Stimulus), Tailwind CSS
- **AI Integration**: Google Gemini API via `ruby_llm` gem
- **Authentication**: Devise
- **Testing**: Minitest

### Key Components
- **GeminiService**: Handles interaction with Google Gemini API for generating activities and itineraries using structured output schemas.
- **UserTripStatus**: Manages user roles (creator/invitee) and status within a trip.
- **Recommendation/Itinerary**: Core models for storing AI-generated content.

## Setup Instructions

### Prerequisites
- Ruby 3.3.5
- PostgreSQL
- Node.js & Yarn (for Tailwind CSS)
- Google Gemini API Key

### Installation
1.  Clone the repository.
2.  Install dependencies:
    ```bash
    bundle install
    yarn install
    ```
3.  Setup database:
    ```bash
    bin/rails db:create db:migrate
    ```
4.  Set environment variables:
    - Create `.env` file (see `.env.example` if available)
    - Add `GEMINI_API_KEY=your_api_key`

### Running the App
```bash
bin/dev
```
Access the app at `http://localhost:3000`.

## Testing
Run the test suite:
```bash
bin/rails test
```
