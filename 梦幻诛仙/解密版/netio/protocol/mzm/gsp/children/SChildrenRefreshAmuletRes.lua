local SChildrenRefreshAmuletRes = class("SChildrenRefreshAmuletRes")
SChildrenRefreshAmuletRes.TYPEID = 12609422
function SChildrenRefreshAmuletRes:ctor(childrenid, skillids)
  self.id = 12609422
  self.childrenid = childrenid or nil
  self.skillids = skillids or {}
end
function SChildrenRefreshAmuletRes:marshal(os)
  os:marshalInt64(self.childrenid)
  os:marshalCompactUInt32(table.getn(self.skillids))
  for _, v in ipairs(self.skillids) do
    os:marshalInt32(v)
  end
end
function SChildrenRefreshAmuletRes:unmarshal(os)
  self.childrenid = os:unmarshalInt64()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    table.insert(self.skillids, v)
  end
end
function SChildrenRefreshAmuletRes:sizepolicy(size)
  return size <= 65535
end
return SChildrenRefreshAmuletRes
