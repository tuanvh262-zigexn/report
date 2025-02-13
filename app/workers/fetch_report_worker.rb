class FetchReportWorker
  include Sidekiq::Worker

  def perform report_id
    Report::GenerateService.new(report_id).execute
  end
end
