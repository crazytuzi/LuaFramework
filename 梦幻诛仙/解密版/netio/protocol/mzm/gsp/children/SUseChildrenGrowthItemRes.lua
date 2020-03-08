local SUseChildrenGrowthItemRes = class("SUseChildrenGrowthItemRes")
SUseChildrenGrowthItemRes.TYPEID = 12609376
function SUseChildrenGrowthItemRes:ctor(growValue, childrenid, itemKey, useItemCount)
  self.id = 12609376
  self.growValue = growValue or nil
  self.childrenid = childrenid or nil
  self.itemKey = itemKey or nil
  self.useItemCount = useItemCount or nil
end
function SUseChildrenGrowthItemRes:marshal(os)
  os:marshalFloat(self.growValue)
  os:marshalInt64(self.childrenid)
  os:marshalInt32(self.itemKey)
  os:marshalInt32(self.useItemCount)
end
function SUseChildrenGrowthItemRes:unmarshal(os)
  self.growValue = os:unmarshalFloat()
  self.childrenid = os:unmarshalInt64()
  self.itemKey = os:unmarshalInt32()
  self.useItemCount = os:unmarshalInt32()
end
function SUseChildrenGrowthItemRes:sizepolicy(size)
  return size <= 65535
end
return SUseChildrenGrowthItemRes
