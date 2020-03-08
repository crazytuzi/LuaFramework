local CKickOutMemberReq = class("CKickOutMemberReq")
CKickOutMemberReq.TYPEID = 12589882
function CKickOutMemberReq:ctor(targetId)
  self.id = 12589882
  self.targetId = targetId or nil
end
function CKickOutMemberReq:marshal(os)
  os:marshalInt64(self.targetId)
end
function CKickOutMemberReq:unmarshal(os)
  self.targetId = os:unmarshalInt64()
end
function CKickOutMemberReq:sizepolicy(size)
  return size <= 65535
end
return CKickOutMemberReq
