local SWorshipSucBro = class("SWorshipSucBro")
SWorshipSucBro.TYPEID = 12612618
function SWorshipSucBro:ctor(roleId, roleName, worshipId, goldNum, contentIndex)
  self.id = 12612618
  self.roleId = roleId or nil
  self.roleName = roleName or nil
  self.worshipId = worshipId or nil
  self.goldNum = goldNum or nil
  self.contentIndex = contentIndex or nil
end
function SWorshipSucBro:marshal(os)
  os:marshalInt64(self.roleId)
  os:marshalString(self.roleName)
  os:marshalInt32(self.worshipId)
  os:marshalInt32(self.goldNum)
  os:marshalInt32(self.contentIndex)
end
function SWorshipSucBro:unmarshal(os)
  self.roleId = os:unmarshalInt64()
  self.roleName = os:unmarshalString()
  self.worshipId = os:unmarshalInt32()
  self.goldNum = os:unmarshalInt32()
  self.contentIndex = os:unmarshalInt32()
end
function SWorshipSucBro:sizepolicy(size)
  return size <= 65535
end
return SWorshipSucBro
