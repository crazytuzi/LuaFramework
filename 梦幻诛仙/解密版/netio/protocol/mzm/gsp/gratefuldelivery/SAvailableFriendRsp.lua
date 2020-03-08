local SAvailableFriendRsp = class("SAvailableFriendRsp")
SAvailableFriendRsp.TYPEID = 12615688
function SAvailableFriendRsp:ctor(roles, activity_id)
  self.id = 12615688
  self.roles = roles or {}
  self.activity_id = activity_id or nil
end
function SAvailableFriendRsp:marshal(os)
  os:marshalCompactUInt32(table.getn(self.roles))
  for _, v in ipairs(self.roles) do
    os:marshalInt64(v)
  end
  os:marshalInt32(self.activity_id)
end
function SAvailableFriendRsp:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt64()
    table.insert(self.roles, v)
  end
  self.activity_id = os:unmarshalInt32()
end
function SAvailableFriendRsp:sizepolicy(size)
  return size <= 65535
end
return SAvailableFriendRsp
