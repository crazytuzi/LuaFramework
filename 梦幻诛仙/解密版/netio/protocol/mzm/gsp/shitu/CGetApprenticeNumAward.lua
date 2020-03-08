local CGetApprenticeNumAward = class("CGetApprenticeNumAward")
CGetApprenticeNumAward.TYPEID = 12601622
function CGetApprenticeNumAward:ctor(award_score_cfg_id)
  self.id = 12601622
  self.award_score_cfg_id = award_score_cfg_id or nil
end
function CGetApprenticeNumAward:marshal(os)
  os:marshalInt32(self.award_score_cfg_id)
end
function CGetApprenticeNumAward:unmarshal(os)
  self.award_score_cfg_id = os:unmarshalInt32()
end
function CGetApprenticeNumAward:sizepolicy(size)
  return size <= 65535
end
return CGetApprenticeNumAward
