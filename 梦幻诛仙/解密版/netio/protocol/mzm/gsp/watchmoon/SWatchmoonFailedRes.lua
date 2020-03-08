local SWatchmoonFailedRes = class("SWatchmoonFailedRes")
SWatchmoonFailedRes.TYPEID = 12600843
function SWatchmoonFailedRes:ctor(roleids)
  self.id = 12600843
  self.roleids = roleids or {}
end
function SWatchmoonFailedRes:marshal(os)
  os:marshalCompactUInt32(table.getn(self.roleids))
  for _, v in ipairs(self.roleids) do
    os:marshalInt64(v)
  end
end
function SWatchmoonFailedRes:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt64()
    table.insert(self.roleids, v)
  end
end
function SWatchmoonFailedRes:sizepolicy(size)
  return size <= 65535
end
return SWatchmoonFailedRes
