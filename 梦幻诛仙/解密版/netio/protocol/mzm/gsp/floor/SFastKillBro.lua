local FloorFightRes = require("netio.protocol.mzm.gsp.floor.FloorFightRes")
local SFastKillBro = class("SFastKillBro")
SFastKillBro.TYPEID = 12617749
function SFastKillBro:ctor(activityId, floor, fightInfo)
  self.id = 12617749
  self.activityId = activityId or nil
  self.floor = floor or nil
  self.fightInfo = fightInfo or FloorFightRes.new()
end
function SFastKillBro:marshal(os)
  os:marshalInt32(self.activityId)
  os:marshalInt32(self.floor)
  self.fightInfo:marshal(os)
end
function SFastKillBro:unmarshal(os)
  self.activityId = os:unmarshalInt32()
  self.floor = os:unmarshalInt32()
  self.fightInfo = FloorFightRes.new()
  self.fightInfo:unmarshal(os)
end
function SFastKillBro:sizepolicy(size)
  return size <= 65535
end
return SFastKillBro
