local CEquipQiLinUseItemReq = class("CEquipQiLinUseItemReq")
CEquipQiLinUseItemReq.TYPEID = 12584852
function CEquipQiLinUseItemReq:ctor(bagid, key, itemid, itemNum)
  self.id = 12584852
  self.bagid = bagid or nil
  self.key = key or nil
  self.itemid = itemid or nil
  self.itemNum = itemNum or nil
end
function CEquipQiLinUseItemReq:marshal(os)
  os:marshalInt32(self.bagid)
  os:marshalInt32(self.key)
  os:marshalInt32(self.itemid)
  os:marshalInt32(self.itemNum)
end
function CEquipQiLinUseItemReq:unmarshal(os)
  self.bagid = os:unmarshalInt32()
  self.key = os:unmarshalInt32()
  self.itemid = os:unmarshalInt32()
  self.itemNum = os:unmarshalInt32()
end
function CEquipQiLinUseItemReq:sizepolicy(size)
  return size <= 65535
end
return CEquipQiLinUseItemReq
