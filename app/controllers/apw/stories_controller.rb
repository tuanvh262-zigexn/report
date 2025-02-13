class Apw::StoriesController < ApplicationController
  def show
    @story = Story.find(params[:id])
    @support = Stories::ShowSupport.new(@story)
  end
end
