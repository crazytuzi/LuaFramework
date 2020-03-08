local FloorFightRes = require("netio.protocol.mzm.gsp.floor.FloorFightRes")
local SGetFirstBloodBro = class("SGetFirstBloodBro")
SGetFirstBloodBro.TYPEID = 12617740
function SGetFirstBloodBro:ctor(activityId, floor, fightInfo)
  self.id = 12617740
  self.activityId = activityId or nil
  self.floor = floor or nil
  self.fightInfo = fightInfo or FloorFightRes.new()
end
function SGetFirstBloodBro:marshal(os)
  os:marshalInt32(self.activityId)
  os:marshalInt32(self.floor)
  self.fightInfo:marshal(os)
end
function SGetFirstBloodBro:unmarshal(os)
  self.activityId = os:unmarshalInt32()
  self.floor = os:unmarshalInt32()
  self.fightInfo = FloorFightRes.new()
  self.fightInfo:unmarshal(os)
end
function SGetFirstBloodBro:sizepolicy(size)
  return size <= 65535
end
return SGetFirstBloodBro
