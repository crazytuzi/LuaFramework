local SReplyPayRespect = class("SReplyPayRespect")
SReplyPayRespect.TYPEID = 12601629
function SReplyPayRespect:ctor(operator, master_role_id, apprentice_role_id)
  self.id = 12601629
  self.operator = operator or nil
  self.master_role_id = master_role_id or nil
  self.apprentice_role_id = apprentice_role_id or nil
end
function SReplyPayRespect:marshal(os)
  os:marshalInt32(self.operator)
  os:marshalInt64(self.master_role_id)
  os:marshalInt64(self.apprentice_role_id)
end
function SReplyPayRespect:unmarshal(os)
  self.operator = os:unmarshalInt32()
  self.master_role_id = os:unmarshalInt64()
  self.apprentice_role_id = os:unmarshalInt64()
end
function SReplyPayRespect:sizepolicy(size)
  return size <= 65535
end
return SReplyPayRespect
