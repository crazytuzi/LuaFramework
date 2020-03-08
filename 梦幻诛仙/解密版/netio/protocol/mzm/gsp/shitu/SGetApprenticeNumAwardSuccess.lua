local SGetApprenticeNumAwardSuccess = class("SGetApprenticeNumAwardSuccess")
SGetApprenticeNumAwardSuccess.TYPEID = 12601624
function SGetApprenticeNumAwardSuccess:ctor(award_score_cfg_id)
  self.id = 12601624
  self.award_score_cfg_id = award_score_cfg_id or nil
end
function SGetApprenticeNumAwardSuccess:marshal(os)
  os:marshalInt32(self.award_score_cfg_id)
end
function SGetApprenticeNumAwardSuccess:unmarshal(os)
  self.award_score_cfg_id = os:unmarshalInt32()
end
function SGetApprenticeNumAwardSuccess:sizepolicy(size)
  return size <= 65535
end
return SGetApprenticeNumAwardSuccess
