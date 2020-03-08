local CInviteJoinGroupReq = class("CInviteJoinGroupReq")
CInviteJoinGroupReq.TYPEID = 12605187
function CInviteJoinGroupReq:ctor(groupid, invitees)
  self.id = 12605187
  self.groupid = groupid or nil
  self.invitees = invitees or {}
end
function CInviteJoinGroupReq:marshal(os)
  os:marshalInt64(self.groupid)
  os:marshalCompactUInt32(table.getn(self.invitees))
  for _, v in ipairs(self.invitees) do
    os:marshalInt64(v)
  end
end
function CInviteJoinGroupReq:unmarshal(os)
  self.groupid = os:unmarshalInt64()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt64()
    table.insert(self.invitees, v)
  end
end
function CInviteJoinGroupReq:sizepolicy(size)
  return size <= 65535
end
return CInviteJoinGroupReq
