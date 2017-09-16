class WeatherController < ApplicationController
  def index
    @weather_info = City.get_weather(params[:city_id], params[:city_name])
  end
end