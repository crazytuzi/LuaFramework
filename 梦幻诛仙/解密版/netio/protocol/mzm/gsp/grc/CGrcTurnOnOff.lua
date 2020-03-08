local CGrcTurnOnOff = class("CGrcTurnOnOff")
CGrcTurnOnOff.TYPEID = 12600337
function CGrcTurnOnOff:ctor(gift_type, onoff)
  self.id = 12600337
  self.gift_type = gift_type or nil
  self.onoff = onoff or nil
end
function CGrcTurnOnOff:marshal(os)
  os:marshalInt32(self.gift_type)
  os:marshalUInt8(self.onoff)
end
function CGrcTurnOnOff:unmarshal(os)
  self.gift_type = os:unmarshalInt32()
  self.onoff = os:unmarshalUInt8()
end
function CGrcTurnOnOff:sizepolicy(size)
  return size <= 65535
end
return CGrcTurnOnOff
