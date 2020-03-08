local SUnEquipFabaoRes = class("SUnEquipFabaoRes")
SUnEquipFabaoRes.TYPEID = 12595991
function SUnEquipFabaoRes:ctor(faobaotype)
  self.id = 12595991
  self.faobaotype = faobaotype or nil
end
function SUnEquipFabaoRes:marshal(os)
  os:marshalInt32(self.faobaotype)
end
function SUnEquipFabaoRes:unmarshal(os)
  self.faobaotype = os:unmarshalInt32()
end
function SUnEquipFabaoRes:sizepolicy(size)
  return size <= 65535
end
return SUnEquipFabaoRes
