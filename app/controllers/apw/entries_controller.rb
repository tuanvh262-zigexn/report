class Apw::EntriesController < ApplicationController
  def index
    @weekly_reports = WeeklyReport.where(public: true)
      .where("team_reports.start_date >= ?", (Date.current - 2.months).beginning_of_week)
      .includes(tasks: :story)
  end
end
