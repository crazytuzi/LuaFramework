local CTransferMaidToReq = class("CTransferMaidToReq")
CTransferMaidToReq.TYPEID = 12605505
function CTransferMaidToReq:ctor(locations)
  self.id = 12605505
  self.locations = locations or {}
end
function CTransferMaidToReq:marshal(os)
  os:marshalCompactUInt32(table.getn(self.locations))
  for _, v in ipairs(self.locations) do
    v:marshal(os)
  end
end
function CTransferMaidToReq:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.map.Location")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.locations, v)
  end
end
function CTransferMaidToReq:sizepolicy(size)
  return size <= 65535
end
return CTransferMaidToReq
