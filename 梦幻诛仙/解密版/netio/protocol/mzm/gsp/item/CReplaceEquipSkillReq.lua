local CReplaceEquipSkillReq = class("CReplaceEquipSkillReq")
CReplaceEquipSkillReq.TYPEID = 12584856
function CReplaceEquipSkillReq:ctor(bagid, key, itemid)
  self.id = 12584856
  self.bagid = bagid or nil
  self.key = key or nil
  self.itemid = itemid or nil
end
function CReplaceEquipSkillReq:marshal(os)
  os:marshalInt32(self.bagid)
  os:marshalInt32(self.key)
  os:marshalInt32(self.itemid)
end
function CReplaceEquipSkillReq:unmarshal(os)
  self.bagid = os:unmarshalInt32()
  self.key = os:unmarshalInt32()
  self.itemid = os:unmarshalInt32()
end
function CReplaceEquipSkillReq:sizepolicy(size)
  return size <= 65535
end
return CReplaceEquipSkillReq
