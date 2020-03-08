local CSyncRoleMove = class("CSyncRoleMove")
CSyncRoleMove.TYPEID = 12590889
function CSyncRoleMove:ctor(keyPointPath, mapId)
  self.id = 12590889
  self.keyPointPath = keyPointPath or {}
  self.mapId = mapId or nil
end
function CSyncRoleMove:marshal(os)
  os:marshalCompactUInt32(table.getn(self.keyPointPath))
  for _, v in ipairs(self.keyPointPath) do
    v:marshal(os)
  end
  os:marshalInt32(self.mapId)
end
function CSyncRoleMove:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.map.Location")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.keyPointPath, v)
  end
  self.mapId = os:unmarshalInt32()
end
function CSyncRoleMove:sizepolicy(size)
  return size <= 65535
end
return CSyncRoleMove
