class Apw::EntriesController < ApplicationController
  def index
    @support = Entries::IndexSupport.new(params[:q])
  end
end
