local SSyncMapEntityMove = class("SSyncMapEntityMove")
SSyncMapEntityMove.TYPEID = 12590956
function SSyncMapEntityMove:ctor(entity_type, instanceid, keyPointPath)
  self.id = 12590956
  self.entity_type = entity_type or nil
  self.instanceid = instanceid or nil
  self.keyPointPath = keyPointPath or {}
end
function SSyncMapEntityMove:marshal(os)
  os:marshalInt32(self.entity_type)
  os:marshalInt64(self.instanceid)
  os:marshalCompactUInt32(table.getn(self.keyPointPath))
  for _, v in ipairs(self.keyPointPath) do
    v:marshal(os)
  end
end
function SSyncMapEntityMove:unmarshal(os)
  self.entity_type = os:unmarshalInt32()
  self.instanceid = os:unmarshalInt64()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.map.Location")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.keyPointPath, v)
  end
end
function SSyncMapEntityMove:sizepolicy(size)
  return size <= 65535
end
return SSyncMapEntityMove
