class UpdateStoryWorker
  include Sidekiq::Worker

  def perform
    Story.where.not(status: :closed).pluck(:issue_id).each do |issue|
      FetchStoryWorker.perform_async(issue)
    end
  end
end
