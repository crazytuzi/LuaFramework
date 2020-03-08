local SSyncRoleMove = class("SSyncRoleMove")
SSyncRoleMove.TYPEID = 12590883
function SSyncRoleMove:ctor(roleId, keyPointPath, direction, mapId)
  self.id = 12590883
  self.roleId = roleId or nil
  self.keyPointPath = keyPointPath or {}
  self.direction = direction or nil
  self.mapId = mapId or nil
end
function SSyncRoleMove:marshal(os)
  os:marshalInt64(self.roleId)
  os:marshalCompactUInt32(table.getn(self.keyPointPath))
  for _, v in ipairs(self.keyPointPath) do
    v:marshal(os)
  end
  os:marshalInt32(self.direction)
  os:marshalInt32(self.mapId)
end
function SSyncRoleMove:unmarshal(os)
  self.roleId = os:unmarshalInt64()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.map.Location")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.keyPointPath, v)
  end
  self.direction = os:unmarshalInt32()
  self.mapId = os:unmarshalInt32()
end
function SSyncRoleMove:sizepolicy(size)
  return size <= 65535
end
return SSyncRoleMove
