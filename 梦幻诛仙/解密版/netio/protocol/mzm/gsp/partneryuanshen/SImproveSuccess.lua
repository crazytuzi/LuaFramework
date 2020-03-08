local SImproveSuccess = class("SImproveSuccess")
SImproveSuccess.TYPEID = 12621061
function SImproveSuccess:ctor(position, level, property)
  self.id = 12621061
  self.position = position or nil
  self.level = level or nil
  self.property = property or nil
end
function SImproveSuccess:marshal(os)
  os:marshalInt32(self.position)
  os:marshalInt32(self.level)
  os:marshalInt32(self.property)
end
function SImproveSuccess:unmarshal(os)
  self.position = os:unmarshalInt32()
  self.level = os:unmarshalInt32()
  self.property = os:unmarshalInt32()
end
function SImproveSuccess:sizepolicy(size)
  return size <= 65535
end
return SImproveSuccess
