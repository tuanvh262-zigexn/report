class CreateStaticStoryWorker
  include Sidekiq::Worker

  STATIC_SUBJECT = [
    '[ Documents ] -',
    '[ Support ] -',
    '[ Investment Plan ] -'
  ]

  def perform
    STATIC_SUBJECT.each do |subject|
      redmine_subject = "#{subject} #{Date.current.strftime('%B %Y')}"

      next if Story.static.exists?(subject: redmine_subject)

      CreateRedmineIssueWorker.perform_async({subject: redmine_subject}.to_json)
    end
  end
end
