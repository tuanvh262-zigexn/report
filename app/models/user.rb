class User < ApplicationRecord
  has_many :user_working_logs

  enum :role, {
    brse: 0,
    dev: 1,
    tester: 2
  }
end
