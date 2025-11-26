ENV['GOOGLE_API_KEY'] ||= ENV['GEMINI_API_KEY']

RubyLLM.configure do |config|
  # GitHub Models (Azure OpenAI) - reliable alternative to Gemini
  config.openai_api_base = 'https://models.inference.ai.azure.com'
  config.openai_api_key = ENV['GITHUB_TOKEN']

  # Fallback to Gemini if GitHub token not available
  config.gemini_api_key = ENV['GEMINI_API_KEY'] if ENV['GEMINI_API_KEY']

  # Use the new association-based acts_as API (recommended)
  config.use_new_acts_as = true
end
