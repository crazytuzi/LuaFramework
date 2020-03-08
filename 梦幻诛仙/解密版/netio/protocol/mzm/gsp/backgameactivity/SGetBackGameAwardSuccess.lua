local SGetBackGameAwardSuccess = class("SGetBackGameAwardSuccess")
SGetBackGameAwardSuccess.TYPEID = 12620545
function SGetBackGameAwardSuccess:ctor(award_tier_cfg_id)
  self.id = 12620545
  self.award_tier_cfg_id = award_tier_cfg_id or nil
end
function SGetBackGameAwardSuccess:marshal(os)
  os:marshalInt32(self.award_tier_cfg_id)
end
function SGetBackGameAwardSuccess:unmarshal(os)
  self.award_tier_cfg_id = os:unmarshalInt32()
end
function SGetBackGameAwardSuccess:sizepolicy(size)
  return size <= 65535
end
return SGetBackGameAwardSuccess
