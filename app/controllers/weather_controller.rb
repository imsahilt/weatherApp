class WeatherController < ApplicationController
  def index
    @weather_infos = City.get_weather(params[:city_id], params[:city_name]) if params[:city_id] && params[:city_name]
  end
end