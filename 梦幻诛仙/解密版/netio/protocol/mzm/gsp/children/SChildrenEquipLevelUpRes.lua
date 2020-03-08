local SChildrenEquipLevelUpRes = class("SChildrenEquipLevelUpRes")
SChildrenEquipLevelUpRes.TYPEID = 12609418
function SChildrenEquipLevelUpRes:ctor(childrenid, pos, level, exp)
  self.id = 12609418
  self.childrenid = childrenid or nil
  self.pos = pos or nil
  self.level = level or nil
  self.exp = exp or nil
end
function SChildrenEquipLevelUpRes:marshal(os)
  os:marshalInt64(self.childrenid)
  os:marshalInt32(self.pos)
  os:marshalInt32(self.level)
  os:marshalInt32(self.exp)
end
function SChildrenEquipLevelUpRes:unmarshal(os)
  self.childrenid = os:unmarshalInt64()
  self.pos = os:unmarshalInt32()
  self.level = os:unmarshalInt32()
  self.exp = os:unmarshalInt32()
end
function SChildrenEquipLevelUpRes:sizepolicy(size)
  return size <= 65535
end
return SChildrenEquipLevelUpRes
