local CUseXiuLianItemReq = class("CUseXiuLianItemReq")
CUseXiuLianItemReq.TYPEID = 12589573
function CUseXiuLianItemReq:ctor(itemKey, skillBagId, isUseAll)
  self.id = 12589573
  self.itemKey = itemKey or nil
  self.skillBagId = skillBagId or nil
  self.isUseAll = isUseAll or nil
end
function CUseXiuLianItemReq:marshal(os)
  os:marshalInt32(self.itemKey)
  os:marshalInt32(self.skillBagId)
  os:marshalInt32(self.isUseAll)
end
function CUseXiuLianItemReq:unmarshal(os)
  self.itemKey = os:unmarshalInt32()
  self.skillBagId = os:unmarshalInt32()
  self.isUseAll = os:unmarshalInt32()
end
function CUseXiuLianItemReq:sizepolicy(size)
  return size <= 65535
end
return CUseXiuLianItemReq
