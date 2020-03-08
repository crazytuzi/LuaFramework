local CChildComeToMeReq = class("CChildComeToMeReq")
CChildComeToMeReq.TYPEID = 12609393
function CChildComeToMeReq:ctor(locations, childId)
  self.id = 12609393
  self.locations = locations or {}
  self.childId = childId or nil
end
function CChildComeToMeReq:marshal(os)
  os:marshalCompactUInt32(table.getn(self.locations))
  for _, v in ipairs(self.locations) do
    v:marshal(os)
  end
  os:marshalInt64(self.childId)
end
function CChildComeToMeReq:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.map.Location")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.locations, v)
  end
  self.childId = os:unmarshalInt64()
end
function CChildComeToMeReq:sizepolicy(size)
  return size <= 65535
end
return CChildComeToMeReq
