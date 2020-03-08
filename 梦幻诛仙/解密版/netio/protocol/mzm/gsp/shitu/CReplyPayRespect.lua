local CReplyPayRespect = class("CReplyPayRespect")
CReplyPayRespect.TYPEID = 12601628
function CReplyPayRespect:ctor(operator, apprentice_role_id, session_id)
  self.id = 12601628
  self.operator = operator or nil
  self.apprentice_role_id = apprentice_role_id or nil
  self.session_id = session_id or nil
end
function CReplyPayRespect:marshal(os)
  os:marshalInt32(self.operator)
  os:marshalInt64(self.apprentice_role_id)
  os:marshalInt64(self.session_id)
end
function CReplyPayRespect:unmarshal(os)
  self.operator = os:unmarshalInt32()
  self.apprentice_role_id = os:unmarshalInt64()
  self.session_id = os:unmarshalInt64()
end
function CReplyPayRespect:sizepolicy(size)
  return size <= 65535
end
return CReplyPayRespect
