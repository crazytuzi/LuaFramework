local CEquipSkillRefreshReq = class("CEquipSkillRefreshReq")
CEquipSkillRefreshReq.TYPEID = 12584859
function CEquipSkillRefreshReq:ctor(bagid, key, itemid)
  self.id = 12584859
  self.bagid = bagid or nil
  self.key = key or nil
  self.itemid = itemid or nil
end
function CEquipSkillRefreshReq:marshal(os)
  os:marshalInt32(self.bagid)
  os:marshalInt32(self.key)
  os:marshalInt32(self.itemid)
end
function CEquipSkillRefreshReq:unmarshal(os)
  self.bagid = os:unmarshalInt32()
  self.key = os:unmarshalInt32()
  self.itemid = os:unmarshalInt32()
end
function CEquipSkillRefreshReq:sizepolicy(size)
  return size <= 65535
end
return CEquipSkillRefreshReq
