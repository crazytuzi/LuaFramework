local SSyncGangSignReq = class("SSyncGangSignReq")
SSyncGangSignReq.TYPEID = 12589941
function SSyncGangSignReq:ctor(roleId, signStr)
  self.id = 12589941
  self.roleId = roleId or nil
  self.signStr = signStr or nil
end
function SSyncGangSignReq:marshal(os)
  os:marshalInt64(self.roleId)
  os:marshalString(self.signStr)
end
function SSyncGangSignReq:unmarshal(os)
  self.roleId = os:unmarshalInt64()
  self.signStr = os:unmarshalString()
end
function SSyncGangSignReq:sizepolicy(size)
  return size <= 65535
end
return SSyncGangSignReq
