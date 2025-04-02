class TimeCrowdTask < ApplicationRecord
  belongs_to :story

  enum :activity_type, {
    investigate: 1,
    design: 2,
    coding: 3,
    testing: 4
  }
end
