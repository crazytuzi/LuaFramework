local SMapTeamSyncPos = class("SMapTeamSyncPos")
SMapTeamSyncPos.TYPEID = 12590892
function SMapTeamSyncPos:ctor(teamId, keyPointPath, direction, mapId, mapInstanceId)
  self.id = 12590892
  self.teamId = teamId or nil
  self.keyPointPath = keyPointPath or {}
  self.direction = direction or nil
  self.mapId = mapId or nil
  self.mapInstanceId = mapInstanceId or nil
end
function SMapTeamSyncPos:marshal(os)
  os:marshalInt64(self.teamId)
  os:marshalCompactUInt32(table.getn(self.keyPointPath))
  for _, v in ipairs(self.keyPointPath) do
    v:marshal(os)
  end
  os:marshalInt32(self.direction)
  os:marshalInt32(self.mapId)
  os:marshalInt32(self.mapInstanceId)
end
function SMapTeamSyncPos:unmarshal(os)
  self.teamId = os:unmarshalInt64()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.map.Location")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.keyPointPath, v)
  end
  self.direction = os:unmarshalInt32()
  self.mapId = os:unmarshalInt32()
  self.mapInstanceId = os:unmarshalInt32()
end
function SMapTeamSyncPos:sizepolicy(size)
  return size <= 65535
end
return SMapTeamSyncPos
