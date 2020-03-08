local SFloorHelpTip = class("SFloorHelpTip")
SFloorHelpTip.TYPEID = 12617750
function SFloorHelpTip:ctor(from, to, leftHelpCount)
  self.id = 12617750
  self.from = from or nil
  self.to = to or nil
  self.leftHelpCount = leftHelpCount or nil
end
function SFloorHelpTip:marshal(os)
  os:marshalInt32(self.from)
  os:marshalInt32(self.to)
  os:marshalInt32(self.leftHelpCount)
end
function SFloorHelpTip:unmarshal(os)
  self.from = os:unmarshalInt32()
  self.to = os:unmarshalInt32()
  self.leftHelpCount = os:unmarshalInt32()
end
function SFloorHelpTip:sizepolicy(size)
  return size <= 65535
end
return SFloorHelpTip
