class Story::UpdateStatusRedmineService

  attr_accessor :story_id

  def initialize story_id
    @story_id = story_id
  end

  def execute
    return unless story.released?

    UpdateRedmineIssueWorker.perform_async(story.issue_id, {status: 5}.to_json)

    children_issue.each do |issue|
      UpdateRedmineIssueWorker.perform_async(issue, {status: 5}.to_json)
    end

    FetchStoryWorker.set(wait: 10.minute).perform_async(story.issue_id, true)
  end

  private

  def story
    @story ||= Story.find(story_id)
  end

  def redmine_issue
    @redmine_issue ||= Redmine::Issue.new(story.issue_id).execute
  end

  def children_issue
    issue_ids = []

    redmine_issue["children"]&.each do |child|
      issue_ids << child["id"]
      if child["children"].present?
        child["children"].each do |child2|
          issue_ids << child2["id"]
        end
      end
    end

    issue_ids
  end
end
