local CAttendTreasureHunt = class("CAttendTreasureHunt")
CAttendTreasureHunt.TYPEID = 12633092
function CAttendTreasureHunt:ctor(activity_cfg_id)
  self.id = 12633092
  self.activity_cfg_id = activity_cfg_id or nil
end
function CAttendTreasureHunt:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
end
function CAttendTreasureHunt:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
end
function CAttendTreasureHunt:sizepolicy(size)
  return size <= 65535
end
return CAttendTreasureHunt
