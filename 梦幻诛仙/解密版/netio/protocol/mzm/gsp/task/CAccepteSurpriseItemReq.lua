local CAccepteSurpriseItemReq = class("CAccepteSurpriseItemReq")
CAccepteSurpriseItemReq.TYPEID = 12592154
function CAccepteSurpriseItemReq:ctor(serverId, uuids)
  self.id = 12592154
  self.serverId = serverId or nil
  self.uuids = uuids or {}
end
function CAccepteSurpriseItemReq:marshal(os)
  os:marshalInt32(self.serverId)
  os:marshalCompactUInt32(table.getn(self.uuids))
  for _, v in ipairs(self.uuids) do
    os:marshalInt64(v)
  end
end
function CAccepteSurpriseItemReq:unmarshal(os)
  self.serverId = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt64()
    table.insert(self.uuids, v)
  end
end
function CAccepteSurpriseItemReq:sizepolicy(size)
  return size <= 65535
end
return CAccepteSurpriseItemReq
