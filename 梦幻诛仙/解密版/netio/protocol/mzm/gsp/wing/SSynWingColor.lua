local SSynWingColor = class("SSynWingColor")
SSynWingColor.TYPEID = 12596534
function SSynWingColor:ctor(cfgId, colorId)
  self.id = 12596534
  self.cfgId = cfgId or nil
  self.colorId = colorId or nil
end
function SSynWingColor:marshal(os)
  os:marshalInt32(self.cfgId)
  os:marshalInt32(self.colorId)
end
function SSynWingColor:unmarshal(os)
  self.cfgId = os:unmarshalInt32()
  self.colorId = os:unmarshalInt32()
end
function SSynWingColor:sizepolicy(size)
  return size <= 65535
end
return SSynWingColor
