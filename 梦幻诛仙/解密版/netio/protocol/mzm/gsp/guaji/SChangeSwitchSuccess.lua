local SChangeSwitchSuccess = class("SChangeSwitchSuccess")
SChangeSwitchSuccess.TYPEID = 12591112
function SChangeSwitchSuccess:ctor(switch_type, open)
  self.id = 12591112
  self.switch_type = switch_type or nil
  self.open = open or nil
end
function SChangeSwitchSuccess:marshal(os)
  os:marshalInt32(self.switch_type)
  os:marshalUInt8(self.open)
end
function SChangeSwitchSuccess:unmarshal(os)
  self.switch_type = os:unmarshalInt32()
  self.open = os:unmarshalUInt8()
end
function SChangeSwitchSuccess:sizepolicy(size)
  return size <= 32
end
return SChangeSwitchSuccess
