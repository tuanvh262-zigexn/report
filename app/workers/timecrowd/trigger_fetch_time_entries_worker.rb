class Timecrowd::TriggerFetchTimeEntriesWorker
  include Sidekiq::Worker

  def perform
    TimecrowdMember.pluck(:id).each do |member_id|
      (Date.current.prev_month.beginning_of_month..Date.current.prev_month.end_of_month).each do |date|
        Timecrowd::FetchTimeEntriesWorker.perform_async(date.strftime('%Y-%m-%d'), member_id)
      end
    end
  end
end
