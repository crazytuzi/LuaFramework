local CClearAllinviteReq = class("CClearAllinviteReq")
CClearAllinviteReq.TYPEID = 12588292
function CClearAllinviteReq:ctor(inviters)
  self.id = 12588292
  self.inviters = inviters or {}
end
function CClearAllinviteReq:marshal(os)
  os:marshalCompactUInt32(table.getn(self.inviters))
  for _, v in ipairs(self.inviters) do
    os:marshalInt64(v)
  end
end
function CClearAllinviteReq:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt64()
    table.insert(self.inviters, v)
  end
end
function CClearAllinviteReq:sizepolicy(size)
  return size <= 65535
end
return CClearAllinviteReq
