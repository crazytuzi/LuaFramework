local SShouTuSuccess = class("SShouTuSuccess")
SShouTuSuccess.TYPEID = 12601605
function SShouTuSuccess:ctor(masterRoleId, masterRoleName, sessionid)
  self.id = 12601605
  self.masterRoleId = masterRoleId or nil
  self.masterRoleName = masterRoleName or nil
  self.sessionid = sessionid or nil
end
function SShouTuSuccess:marshal(os)
  os:marshalInt64(self.masterRoleId)
  os:marshalString(self.masterRoleName)
  os:marshalInt64(self.sessionid)
end
function SShouTuSuccess:unmarshal(os)
  self.masterRoleId = os:unmarshalInt64()
  self.masterRoleName = os:unmarshalString()
  self.sessionid = os:unmarshalInt64()
end
function SShouTuSuccess:sizepolicy(size)
  return size <= 65535
end
return SShouTuSuccess
