class FetchAllReportWorker
  include Sidekiq::Worker

  def perform
    TeamReport.where(latest: false).each do |report|
      FetchReportWorker.perform_async(report.id)
    end
  end
end
