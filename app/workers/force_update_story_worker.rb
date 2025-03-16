class ForceUpdateStoryWorker
  include Sidekiq::Worker

  def perform redmine_issue_id, update_on
    story = Story.find_by issue_id: redmine_issue_id
    return unless !story || (story.redmine_updated_at.to_i != Time.new(update_on).to_i)

    FetchStoryWorker.perform_async(redmine_issue_id, true)
  end
end
