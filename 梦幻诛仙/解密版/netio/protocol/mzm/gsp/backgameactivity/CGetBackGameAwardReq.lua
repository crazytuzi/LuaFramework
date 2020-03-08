local CGetBackGameAwardReq = class("CGetBackGameAwardReq")
CGetBackGameAwardReq.TYPEID = 12620553
function CGetBackGameAwardReq:ctor(award_tier_cfg_id)
  self.id = 12620553
  self.award_tier_cfg_id = award_tier_cfg_id or nil
end
function CGetBackGameAwardReq:marshal(os)
  os:marshalInt32(self.award_tier_cfg_id)
end
function CGetBackGameAwardReq:unmarshal(os)
  self.award_tier_cfg_id = os:unmarshalInt32()
end
function CGetBackGameAwardReq:sizepolicy(size)
  return size <= 65535
end
return CGetBackGameAwardReq
