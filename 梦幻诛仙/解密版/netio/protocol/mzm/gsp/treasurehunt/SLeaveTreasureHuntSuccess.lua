local SLeaveTreasureHuntSuccess = class("SLeaveTreasureHuntSuccess")
SLeaveTreasureHuntSuccess.TYPEID = 12633096
function SLeaveTreasureHuntSuccess:ctor(activity_cfg_id)
  self.id = 12633096
  self.activity_cfg_id = activity_cfg_id or nil
end
function SLeaveTreasureHuntSuccess:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
end
function SLeaveTreasureHuntSuccess:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
end
function SLeaveTreasureHuntSuccess:sizepolicy(size)
  return size <= 65535
end
return SLeaveTreasureHuntSuccess
