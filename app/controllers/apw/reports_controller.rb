class Apw::ReportsController < ApplicationController
  def index
    @support = Report::IndexSupport.new(params[:q])
  end
end
