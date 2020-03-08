local CUseChildrenGrowthItemReq = class("CUseChildrenGrowthItemReq")
CUseChildrenGrowthItemReq.TYPEID = 12609363
function CUseChildrenGrowthItemReq:ctor(childrenid, itemKey)
  self.id = 12609363
  self.childrenid = childrenid or nil
  self.itemKey = itemKey or nil
end
function CUseChildrenGrowthItemReq:marshal(os)
  os:marshalInt64(self.childrenid)
  os:marshalInt32(self.itemKey)
end
function CUseChildrenGrowthItemReq:unmarshal(os)
  self.childrenid = os:unmarshalInt64()
  self.itemKey = os:unmarshalInt32()
end
function CUseChildrenGrowthItemReq:sizepolicy(size)
  return size <= 65535
end
return CUseChildrenGrowthItemReq
