class Timecrowd::FetchTimeEntriesWorker
  include Sidekiq::Worker

  def perform spent_on, member_id
    member = TimecrowdMember.find_by(id: member_id)

    return unless member

    TimecrowdTimeEntry.where(
      timecrowd_member_id: member.timecrowd_id,
      spent_on: spent_on
    ).destroy_all

    TimeCrowd::TimeEntries.new(member.timecrowd_id, spent_on).execute["time_entries"].each do |time_entry|
      category_data = {
        timecrowd_id: time_entry.dig('task', 'category', 'id'),
        title: time_entry.dig('task', 'category', 'title'),
      }
      Timecrowd::CreateCategoryWorker.perform_async(category_data.to_json)

      task_data = {
        timecrowd_id: time_entry.dig('task', 'id'),
        title: time_entry.dig('task', 'title'),
        timecrowd_category_id: time_entry.dig('task', 'category', 'id')
      }
      Timecrowd::CreateTaskWorker.perform_async(task_data.to_json)

      time_entry_data = {
        timecrowd_id: time_entry['id'],
        timecrowd_member_id: member.timecrowd_id,
        timecrowd_task_id: time_entry.dig('task', 'id'),
        duration: time_entry['duration'],
        vn_side: member.vn_side,
        spent_on: spent_on
      }
      Timecrowd::CreateTimeEntryWorker.perform_async(time_entry_data.to_json)
    end
  end
end
