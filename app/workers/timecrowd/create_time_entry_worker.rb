class Timecrowd::CreateTimeEntryWorker
  include Sidekiq::Worker

  def perform data
    # data = JSON.parse(data)

    # return if TimecrowdTimeEntry.exists?(timecrowd_id: data["timecrowd_id"])

    # TimecrowdTimeEntry.create!(data)
  end
end
