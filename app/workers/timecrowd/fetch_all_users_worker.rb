class Timecrowd::FetchAllUsersWorker
  include Sidekiq::Worker

  def perform
    # TimecrowdMember.all.destroy_all

    # TimeCrowd::Teams.new.execute.each do |data|
    #   TimeCrowd::Members.new(data["id"]).execute.each do |member|
    #     Timecrowd::CreateMemberWorker.perform_async(member["user"].to_json)
    #   end
    # end
  end
end
