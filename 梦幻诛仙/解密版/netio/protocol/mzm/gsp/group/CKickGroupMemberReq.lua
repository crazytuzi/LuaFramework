local CKickGroupMemberReq = class("CKickGroupMemberReq")
CKickGroupMemberReq.TYPEID = 12605186
function CKickGroupMemberReq:ctor(groupid, memberid)
  self.id = 12605186
  self.groupid = groupid or nil
  self.memberid = memberid or nil
end
function CKickGroupMemberReq:marshal(os)
  os:marshalInt64(self.groupid)
  os:marshalInt64(self.memberid)
end
function CKickGroupMemberReq:unmarshal(os)
  self.groupid = os:unmarshalInt64()
  self.memberid = os:unmarshalInt64()
end
function CKickGroupMemberReq:sizepolicy(size)
  return size <= 65535
end
return CKickGroupMemberReq
