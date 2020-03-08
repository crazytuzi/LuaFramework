local CKickGangTeamMemberReq = class("CKickGangTeamMemberReq")
CKickGangTeamMemberReq.TYPEID = 12589987
function CKickGangTeamMemberReq:ctor(kicked_memberid)
  self.id = 12589987
  self.kicked_memberid = kicked_memberid or nil
end
function CKickGangTeamMemberReq:marshal(os)
  os:marshalInt64(self.kicked_memberid)
end
function CKickGangTeamMemberReq:unmarshal(os)
  self.kicked_memberid = os:unmarshalInt64()
end
function CKickGangTeamMemberReq:sizepolicy(size)
  return size <= 65535
end
return CKickGangTeamMemberReq
