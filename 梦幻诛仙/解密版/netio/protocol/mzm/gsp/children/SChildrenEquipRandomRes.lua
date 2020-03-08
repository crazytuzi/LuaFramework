local SChildrenEquipRandomRes = class("SChildrenEquipRandomRes")
SChildrenEquipRandomRes.TYPEID = 12609425
function SChildrenEquipRandomRes:ctor(childrenid, pos, originalPropType, nowPropType)
  self.id = 12609425
  self.childrenid = childrenid or nil
  self.pos = pos or nil
  self.originalPropType = originalPropType or nil
  self.nowPropType = nowPropType or nil
end
function SChildrenEquipRandomRes:marshal(os)
  os:marshalInt64(self.childrenid)
  os:marshalInt32(self.pos)
  os:marshalInt32(self.originalPropType)
  os:marshalInt32(self.nowPropType)
end
function SChildrenEquipRandomRes:unmarshal(os)
  self.childrenid = os:unmarshalInt64()
  self.pos = os:unmarshalInt32()
  self.originalPropType = os:unmarshalInt32()
  self.nowPropType = os:unmarshalInt32()
end
function SChildrenEquipRandomRes:sizepolicy(size)
  return size <= 65535
end
return SChildrenEquipRandomRes
