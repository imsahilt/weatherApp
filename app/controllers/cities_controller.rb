class CitiesController < ApplicationController
  def autocomplete
    render :json => [], :status => 400 and return unless params[:q].present?
    render :json => City.autocomplete(params[:q]), :status => 200
  end
end