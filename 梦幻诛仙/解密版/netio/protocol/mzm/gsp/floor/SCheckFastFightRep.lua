local FloorFightRes = require("netio.protocol.mzm.gsp.floor.FloorFightRes")
local SCheckFastFightRep = class("SCheckFastFightRep")
SCheckFastFightRep.TYPEID = 12617746
function SCheckFastFightRep:ctor(activityId, floor, fightInfo)
  self.id = 12617746
  self.activityId = activityId or nil
  self.floor = floor or nil
  self.fightInfo = fightInfo or FloorFightRes.new()
end
function SCheckFastFightRep:marshal(os)
  os:marshalInt32(self.activityId)
  os:marshalInt32(self.floor)
  self.fightInfo:marshal(os)
end
function SCheckFastFightRep:unmarshal(os)
  self.activityId = os:unmarshalInt32()
  self.floor = os:unmarshalInt32()
  self.fightInfo = FloorFightRes.new()
  self.fightInfo:unmarshal(os)
end
function SCheckFastFightRep:sizepolicy(size)
  return size <= 65535
end
return SCheckFastFightRep
