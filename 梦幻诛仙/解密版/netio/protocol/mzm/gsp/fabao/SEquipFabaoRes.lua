local SEquipFabaoRes = class("SEquipFabaoRes")
SEquipFabaoRes.TYPEID = 12596001
function SEquipFabaoRes:ctor(faobaotype)
  self.id = 12596001
  self.faobaotype = faobaotype or nil
end
function SEquipFabaoRes:marshal(os)
  os:marshalInt32(self.faobaotype)
end
function SEquipFabaoRes:unmarshal(os)
  self.faobaotype = os:unmarshalInt32()
end
function SEquipFabaoRes:sizepolicy(size)
  return size <= 65535
end
return SEquipFabaoRes
