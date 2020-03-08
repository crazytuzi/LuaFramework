local SChildrenEquipStageUpRes = class("SChildrenEquipStageUpRes")
SChildrenEquipStageUpRes.TYPEID = 12609420
function SChildrenEquipStageUpRes:ctor(childrenid, pos, stage)
  self.id = 12609420
  self.childrenid = childrenid or nil
  self.pos = pos or nil
  self.stage = stage or nil
end
function SChildrenEquipStageUpRes:marshal(os)
  os:marshalInt64(self.childrenid)
  os:marshalInt32(self.pos)
  os:marshalInt32(self.stage)
end
function SChildrenEquipStageUpRes:unmarshal(os)
  self.childrenid = os:unmarshalInt64()
  self.pos = os:unmarshalInt32()
  self.stage = os:unmarshalInt32()
end
function SChildrenEquipStageUpRes:sizepolicy(size)
  return size <= 65535
end
return SChildrenEquipStageUpRes
