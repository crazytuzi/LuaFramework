local CAgreeOrCancelMarriage = class("CAgreeOrCancelMarriage")
CAgreeOrCancelMarriage.TYPEID = 12599825
function CAgreeOrCancelMarriage:ctor(operator, sessionid)
  self.id = 12599825
  self.operator = operator or nil
  self.sessionid = sessionid or nil
end
function CAgreeOrCancelMarriage:marshal(os)
  os:marshalInt32(self.operator)
  os:marshalInt64(self.sessionid)
end
function CAgreeOrCancelMarriage:unmarshal(os)
  self.operator = os:unmarshalInt32()
  self.sessionid = os:unmarshalInt64()
end
function CAgreeOrCancelMarriage:sizepolicy(size)
  return size <= 65535
end
return CAgreeOrCancelMarriage
