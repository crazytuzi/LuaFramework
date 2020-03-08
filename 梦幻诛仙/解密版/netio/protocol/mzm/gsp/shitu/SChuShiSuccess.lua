local SChuShiSuccess = class("SChuShiSuccess")
SChuShiSuccess.TYPEID = 12601602
function SChuShiSuccess:ctor(apprenticeRoleId, apprenticeRoleName)
  self.id = 12601602
  self.apprenticeRoleId = apprenticeRoleId or nil
  self.apprenticeRoleName = apprenticeRoleName or nil
end
function SChuShiSuccess:marshal(os)
  os:marshalInt64(self.apprenticeRoleId)
  os:marshalString(self.apprenticeRoleName)
end
function SChuShiSuccess:unmarshal(os)
  self.apprenticeRoleId = os:unmarshalInt64()
  self.apprenticeRoleName = os:unmarshalString()
end
function SChuShiSuccess:sizepolicy(size)
  return size <= 65535
end
return SChuShiSuccess
