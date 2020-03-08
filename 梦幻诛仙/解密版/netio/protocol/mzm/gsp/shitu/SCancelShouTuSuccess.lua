local SCancelShouTuSuccess = class("SCancelShouTuSuccess")
SCancelShouTuSuccess.TYPEID = 12601608
function SCancelShouTuSuccess:ctor(masterRoleId, masterRoleName)
  self.id = 12601608
  self.masterRoleId = masterRoleId or nil
  self.masterRoleName = masterRoleName or nil
end
function SCancelShouTuSuccess:marshal(os)
  os:marshalInt64(self.masterRoleId)
  os:marshalString(self.masterRoleName)
end
function SCancelShouTuSuccess:unmarshal(os)
  self.masterRoleId = os:unmarshalInt64()
  self.masterRoleName = os:unmarshalString()
end
function SCancelShouTuSuccess:sizepolicy(size)
  return size <= 65535
end
return SCancelShouTuSuccess
