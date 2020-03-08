local SSynEquipQilinModeRes = class("SSynEquipQilinModeRes")
SSynEquipQilinModeRes.TYPEID = 12584854
function SSynEquipQilinModeRes:ctor(mode)
  self.id = 12584854
  self.mode = mode or nil
end
function SSynEquipQilinModeRes:marshal(os)
  os:marshalInt32(self.mode)
end
function SSynEquipQilinModeRes:unmarshal(os)
  self.mode = os:unmarshalInt32()
end
function SSynEquipQilinModeRes:sizepolicy(size)
  return size <= 65535
end
return SSynEquipQilinModeRes
