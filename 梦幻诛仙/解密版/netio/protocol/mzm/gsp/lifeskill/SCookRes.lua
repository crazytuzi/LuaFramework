local SCookRes = class("SCookRes")
SCookRes.TYPEID = 12589066
function SCookRes:ctor(costVigor, itemId, itemNum)
  self.id = 12589066
  self.costVigor = costVigor or nil
  self.itemId = itemId or nil
  self.itemNum = itemNum or nil
end
function SCookRes:marshal(os)
  os:marshalInt32(self.costVigor)
  os:marshalInt32(self.itemId)
  os:marshalInt32(self.itemNum)
end
function SCookRes:unmarshal(os)
  self.costVigor = os:unmarshalInt32()
  self.itemId = os:unmarshalInt32()
  self.itemNum = os:unmarshalInt32()
end
function SCookRes:sizepolicy(size)
  return size <= 65535
end
return SCookRes
