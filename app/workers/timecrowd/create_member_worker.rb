class Timecrowd::CreateMemberWorker
  include Sidekiq::Worker

  def perform data
    # member = JSON.parse(data)

    # return if TimecrowdMember.exists?(timecrowd_id: member["id"])

    # TimecrowdMember.create!(
    #   timecrowd_id: member["id"],
    #   nickname: member["nickname"],
    #   avatar_url: member["avatar_url"],
    #   vn_side: match_vn_prefix?(member["nickname"])
    # )
  end

  private

  def match_vn_prefix?(str)
    str && str.start_with?("vn_", "VN_")
  end
end
