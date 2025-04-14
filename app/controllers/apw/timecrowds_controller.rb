class Apw::TimecrowdsController < ApplicationController
  def index
    @support = Timecrowds::IndexSupport.new(params[:q])
  end
end
