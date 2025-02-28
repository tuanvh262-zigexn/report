class Apw::Ajax::StoriesController < ApplicationController
  def index
    @stories = Story.where("subject LIKE ?", "%#{params[:subject]}%")
    render json: @stories.as_json(only: [:id, :subject])
  end
end
