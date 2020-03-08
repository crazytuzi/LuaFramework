local SLianYaoRes = class("SLianYaoRes")
SLianYaoRes.TYPEID = 12589062
function SLianYaoRes:ctor(costVigor, itemKey, itemId, itemNum)
  self.id = 12589062
  self.costVigor = costVigor or nil
  self.itemKey = itemKey or nil
  self.itemId = itemId or nil
  self.itemNum = itemNum or nil
end
function SLianYaoRes:marshal(os)
  os:marshalInt32(self.costVigor)
  os:marshalInt32(self.itemKey)
  os:marshalInt32(self.itemId)
  os:marshalInt32(self.itemNum)
end
function SLianYaoRes:unmarshal(os)
  self.costVigor = os:unmarshalInt32()
  self.itemKey = os:unmarshalInt32()
  self.itemId = os:unmarshalInt32()
  self.itemNum = os:unmarshalInt32()
end
function SLianYaoRes:sizepolicy(size)
  return size <= 65535
end
return SLianYaoRes
