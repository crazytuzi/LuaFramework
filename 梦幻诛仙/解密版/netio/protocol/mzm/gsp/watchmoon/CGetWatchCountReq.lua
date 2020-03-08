local CGetWatchCountReq = class("CGetWatchCountReq")
CGetWatchCountReq.TYPEID = 12600834
function CGetWatchCountReq:ctor(roleids)
  self.id = 12600834
  self.roleids = roleids or {}
end
function CGetWatchCountReq:marshal(os)
  os:marshalCompactUInt32(table.getn(self.roleids))
  for _, v in ipairs(self.roleids) do
    os:marshalInt64(v)
  end
end
function CGetWatchCountReq:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt64()
    table.insert(self.roleids, v)
  end
end
function CGetWatchCountReq:sizepolicy(size)
  return size <= 65535
end
return CGetWatchCountReq
