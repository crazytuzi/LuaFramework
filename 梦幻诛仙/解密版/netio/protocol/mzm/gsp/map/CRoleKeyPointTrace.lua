local CRoleKeyPointTrace = class("CRoleKeyPointTrace")
CRoleKeyPointTrace.TYPEID = 12590857
function CRoleKeyPointTrace:ctor(mapId, keyPoints)
  self.id = 12590857
  self.mapId = mapId or nil
  self.keyPoints = keyPoints or {}
end
function CRoleKeyPointTrace:marshal(os)
  os:marshalInt32(self.mapId)
  os:marshalCompactUInt32(table.getn(self.keyPoints))
  for _, v in ipairs(self.keyPoints) do
    v:marshal(os)
  end
end
function CRoleKeyPointTrace:unmarshal(os)
  self.mapId = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.map.Location")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.keyPoints, v)
  end
end
function CRoleKeyPointTrace:sizepolicy(size)
  return size <= 65535
end
return CRoleKeyPointTrace
