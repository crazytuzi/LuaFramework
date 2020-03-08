local SDispatchLiHeRes = class("SDispatchLiHeRes")
SDispatchLiHeRes.TYPEID = 12589933
function SDispatchLiHeRes:ctor(roleIdList)
  self.id = 12589933
  self.roleIdList = roleIdList or {}
end
function SDispatchLiHeRes:marshal(os)
  os:marshalCompactUInt32(table.getn(self.roleIdList))
  for _, v in ipairs(self.roleIdList) do
    os:marshalInt64(v)
  end
end
function SDispatchLiHeRes:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt64()
    table.insert(self.roleIdList, v)
  end
end
function SDispatchLiHeRes:sizepolicy(size)
  return size <= 65535
end
return SDispatchLiHeRes
