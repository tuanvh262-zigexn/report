class UpdateActivedStoryWorker
  include Sidekiq::Worker

  def perform
    Story.where(
      status: [:init, :in_progress, :resolved, :code_review, :testing, :verified, :jp_side]
    ).pluck(:issue_id).each do |issue|
      FetchStoryWorker.perform_async(issue)
    end
  end
end
