class Apw::EntriesController < ApplicationController
  def index
    @support = Entries::IndexSupport.new
  end
end
