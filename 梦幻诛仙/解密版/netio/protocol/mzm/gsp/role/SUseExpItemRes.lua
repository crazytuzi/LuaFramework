local SUseExpItemRes = class("SUseExpItemRes")
SUseExpItemRes.TYPEID = 12585994
function SUseExpItemRes:ctor(itemId, addExp, usedNum, leftNum)
  self.id = 12585994
  self.itemId = itemId or nil
  self.addExp = addExp or nil
  self.usedNum = usedNum or nil
  self.leftNum = leftNum or nil
end
function SUseExpItemRes:marshal(os)
  os:marshalInt32(self.itemId)
  os:marshalInt32(self.addExp)
  os:marshalInt32(self.usedNum)
  os:marshalInt32(self.leftNum)
end
function SUseExpItemRes:unmarshal(os)
  self.itemId = os:unmarshalInt32()
  self.addExp = os:unmarshalInt32()
  self.usedNum = os:unmarshalInt32()
  self.leftNum = os:unmarshalInt32()
end
function SUseExpItemRes:sizepolicy(size)
  return size <= 65535
end
return SUseExpItemRes
