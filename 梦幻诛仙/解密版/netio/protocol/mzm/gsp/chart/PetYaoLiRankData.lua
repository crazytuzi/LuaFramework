local OctetsStream = require("netio.OctetsStream")
local PetYaoLiRankData = class("PetYaoLiRankData")
function PetYaoLiRankData:ctor(no, petId, roleId, petName, roleName, yaoLi, step, templateId)
  self.no = no or nil
  self.petId = petId or nil
  self.roleId = roleId or nil
  self.petName = petName or nil
  self.roleName = roleName or nil
  self.yaoLi = yaoLi or nil
  self.step = step or nil
  self.templateId = templateId or nil
end
function PetYaoLiRankData:marshal(os)
  os:marshalInt32(self.no)
  os:marshalInt64(self.petId)
  os:marshalInt64(self.roleId)
  os:marshalString(self.petName)
  os:marshalString(self.roleName)
  os:marshalInt32(self.yaoLi)
  os:marshalInt32(self.step)
  os:marshalInt32(self.templateId)
end
function PetYaoLiRankData:unmarshal(os)
  self.no = os:unmarshalInt32()
  self.petId = os:unmarshalInt64()
  self.roleId = os:unmarshalInt64()
  self.petName = os:unmarshalString()
  self.roleName = os:unmarshalString()
  self.yaoLi = os:unmarshalInt32()
  self.step = os:unmarshalInt32()
  self.templateId = os:unmarshalInt32()
end
return PetYaoLiRankData
