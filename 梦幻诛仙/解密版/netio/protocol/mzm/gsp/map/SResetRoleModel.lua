local SResetRoleModel = class("SResetRoleModel")
SResetRoleModel.TYPEID = 12590955
function SResetRoleModel:ctor(modelInfo, menPai, gender)
  self.id = 12590955
  self.modelInfo = modelInfo or nil
  self.menPai = menPai or nil
  self.gender = gender or nil
end
function SResetRoleModel:marshal(os)
  os:marshalOctets(self.modelInfo)
  os:marshalInt32(self.menPai)
  os:marshalInt32(self.gender)
end
function SResetRoleModel:unmarshal(os)
  self.modelInfo = os:unmarshalOctets()
  self.menPai = os:unmarshalInt32()
  self.gender = os:unmarshalInt32()
end
function SResetRoleModel:sizepolicy(size)
  return size <= 65535
end
return SResetRoleModel
