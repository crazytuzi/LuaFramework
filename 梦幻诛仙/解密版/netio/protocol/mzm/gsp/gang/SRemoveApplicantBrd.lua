local SRemoveApplicantBrd = class("SRemoveApplicantBrd")
SRemoveApplicantBrd.TYPEID = 12589954
function SRemoveApplicantBrd:ctor(roleid)
  self.id = 12589954
  self.roleid = roleid or nil
end
function SRemoveApplicantBrd:marshal(os)
  os:marshalInt64(self.roleid)
end
function SRemoveApplicantBrd:unmarshal(os)
  self.roleid = os:unmarshalInt64()
end
function SRemoveApplicantBrd:sizepolicy(size)
  return size <= 65535
end
return SRemoveApplicantBrd
