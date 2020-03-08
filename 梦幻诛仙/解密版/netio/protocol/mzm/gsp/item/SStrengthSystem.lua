local SStrengthSystem = class("SStrengthSystem")
SStrengthSystem.TYPEID = 12584714
function SStrengthSystem:ctor(roleId, roleName, equipCfgId, strengthLevel)
  self.id = 12584714
  self.roleId = roleId or nil
  self.roleName = roleName or nil
  self.equipCfgId = equipCfgId or nil
  self.strengthLevel = strengthLevel or nil
end
function SStrengthSystem:marshal(os)
  os:marshalInt64(self.roleId)
  os:marshalString(self.roleName)
  os:marshalInt32(self.equipCfgId)
  os:marshalInt32(self.strengthLevel)
end
function SStrengthSystem:unmarshal(os)
  self.roleId = os:unmarshalInt64()
  self.roleName = os:unmarshalString()
  self.equipCfgId = os:unmarshalInt32()
  self.strengthLevel = os:unmarshalInt32()
end
function SStrengthSystem:sizepolicy(size)
  return size <= 65535
end
return SStrengthSystem
