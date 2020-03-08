local CDispatchLiHeReq = class("CDispatchLiHeReq")
CDispatchLiHeReq.TYPEID = 12589932
function CDispatchLiHeReq:ctor(roleIdList)
  self.id = 12589932
  self.roleIdList = roleIdList or {}
end
function CDispatchLiHeReq:marshal(os)
  os:marshalCompactUInt32(table.getn(self.roleIdList))
  for _, v in ipairs(self.roleIdList) do
    os:marshalInt64(v)
  end
end
function CDispatchLiHeReq:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt64()
    table.insert(self.roleIdList, v)
  end
end
function CDispatchLiHeReq:sizepolicy(size)
  return size <= 65535
end
return CDispatchLiHeReq
