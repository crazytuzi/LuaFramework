local CSetXueTuMaxLevel = class("CSetXueTuMaxLevel")
CSetXueTuMaxLevel.TYPEID = 12589840
function CSetXueTuMaxLevel:ctor(level)
  self.id = 12589840
  self.level = level or nil
end
function CSetXueTuMaxLevel:marshal(os)
  os:marshalInt32(self.level)
end
function CSetXueTuMaxLevel:unmarshal(os)
  self.level = os:unmarshalInt32()
end
function CSetXueTuMaxLevel:sizepolicy(size)
  return size <= 65535
end
return CSetXueTuMaxLevel
