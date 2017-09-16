class City < ApplicationRecord

  AUTOCOMPLETE_LIMIT = 10
  
  def self.autocomplete(query)
    where("name ILIKE ?","#{query}%").limit(AUTOCOMPLETE_LIMIT).select("(name || ', ' || country_code) as name, open_map_id as id")
  end

  def self.get_weather(city_id, city_name)
    if city_id.to_i == 0
      return Services::OpenWeatherMapSao.get_weather_by_city_name(city_name)
    else
      # assuming weather report is updated every 6 - 12 hours
      open_weather_response = Rails.cache.fetch("open_weather_response:#{city_id}", :expires_in => 6.hours) do
        Services::OpenWeatherMapSao.get_weather_by_city_id(city_id)
      end
      return open_weather_response
    end
  end
end
