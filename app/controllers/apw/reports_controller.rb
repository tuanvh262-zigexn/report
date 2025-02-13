class Apw::ReportsController < ApplicationController
  def index
    @support = Reports::IndexSupport.new(params[:q])
  end
end
