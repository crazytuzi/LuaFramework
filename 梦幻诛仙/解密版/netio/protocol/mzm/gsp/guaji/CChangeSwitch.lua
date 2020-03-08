local CChangeSwitch = class("CChangeSwitch")
CChangeSwitch.TYPEID = 12591113
function CChangeSwitch:ctor(switch_type, open)
  self.id = 12591113
  self.switch_type = switch_type or nil
  self.open = open or nil
end
function CChangeSwitch:marshal(os)
  os:marshalInt32(self.switch_type)
  os:marshalUInt8(self.open)
end
function CChangeSwitch:unmarshal(os)
  self.switch_type = os:unmarshalInt32()
  self.open = os:unmarshalUInt8()
end
function CChangeSwitch:sizepolicy(size)
  return size <= 32
end
return CChangeSwitch
