local SAgreeOrCancelMarriage = class("SAgreeOrCancelMarriage")
SAgreeOrCancelMarriage.TYPEID = 12599813
function SAgreeOrCancelMarriage:ctor(operator, operator_roleid, roleName)
  self.id = 12599813
  self.operator = operator or nil
  self.operator_roleid = operator_roleid or nil
  self.roleName = roleName or nil
end
function SAgreeOrCancelMarriage:marshal(os)
  os:marshalInt32(self.operator)
  os:marshalInt64(self.operator_roleid)
  os:marshalString(self.roleName)
end
function SAgreeOrCancelMarriage:unmarshal(os)
  self.operator = os:unmarshalInt32()
  self.operator_roleid = os:unmarshalInt64()
  self.roleName = os:unmarshalString()
end
function SAgreeOrCancelMarriage:sizepolicy(size)
  return size <= 65535
end
return SAgreeOrCancelMarriage
