class SubTask::UpdateRedmineService

  ACTIVITY_TYPE_STRING = {
    clear_requirement: "1. Requirement -",
    detail_design: "2. Design -",
    code: "3. Coding -",
    test: "4. Testing -",
    bug: "5. Bug fixing -",
    release: "6. Release -"
  }
  attr_accessor :sub_task_id

  def initialize sub_task_id
    @sub_task_id = sub_task_id
  end

  def execute
    return if sub_task.update_title

    if sub_task.subject.match(Settings.regex.sub_task.activity_types[sub_task.activity_type])
      sub_task.update!(update_title: true)
    else
      new_subject = "#{ACTIVITY_TYPE_STRING[sub_task.activity_type.to_sym]} #{sub_task.subject}"
      UpdateRedmineIssueWorker.perform_async(sub_task.issue_id, {subject: new_subject}.to_json)
      FetchSubTaskWorker.set(wait: 10.minute).perform_async(sub_task_id, true)
    end
  end

  private

  def sub_task
    @sub_task ||= SubTask.find(sub_task_id)
  end
end
