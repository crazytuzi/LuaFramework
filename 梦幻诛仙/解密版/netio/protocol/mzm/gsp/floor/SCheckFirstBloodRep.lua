local FloorFightRes = require("netio.protocol.mzm.gsp.floor.FloorFightRes")
local SCheckFirstBloodRep = class("SCheckFirstBloodRep")
SCheckFirstBloodRep.TYPEID = 12617744
function SCheckFirstBloodRep:ctor(activityId, floor, fightInfo)
  self.id = 12617744
  self.activityId = activityId or nil
  self.floor = floor or nil
  self.fightInfo = fightInfo or FloorFightRes.new()
end
function SCheckFirstBloodRep:marshal(os)
  os:marshalInt32(self.activityId)
  os:marshalInt32(self.floor)
  self.fightInfo:marshal(os)
end
function SCheckFirstBloodRep:unmarshal(os)
  self.activityId = os:unmarshalInt32()
  self.floor = os:unmarshalInt32()
  self.fightInfo = FloorFightRes.new()
  self.fightInfo:unmarshal(os)
end
function SCheckFirstBloodRep:sizepolicy(size)
  return size <= 65535
end
return SCheckFirstBloodRep
