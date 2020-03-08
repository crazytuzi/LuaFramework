local OctetsStream = require("netio.OctetsStream")
local MonsterLocation = class("MonsterLocation")
function MonsterLocation:ctor(monsterCfgId, monsterInstanceId, mapId, x, y)
  self.monsterCfgId = monsterCfgId or nil
  self.monsterInstanceId = monsterInstanceId or nil
  self.mapId = mapId or nil
  self.x = x or nil
  self.y = y or nil
end
function MonsterLocation:marshal(os)
  os:marshalInt32(self.monsterCfgId)
  os:marshalInt32(self.monsterInstanceId)
  os:marshalInt32(self.mapId)
  os:marshalInt32(self.x)
  os:marshalInt32(self.y)
end
function MonsterLocation:unmarshal(os)
  self.monsterCfgId = os:unmarshalInt32()
  self.monsterInstanceId = os:unmarshalInt32()
  self.mapId = os:unmarshalInt32()
  self.x = os:unmarshalInt32()
  self.y = os:unmarshalInt32()
end
return MonsterLocation
