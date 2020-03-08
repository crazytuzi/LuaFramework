local SUseMoneyBagItemRes = class("SUseMoneyBagItemRes")
SUseMoneyBagItemRes.TYPEID = 12584826
function SUseMoneyBagItemRes:ctor(moneytype, num, usedItemNum)
  self.id = 12584826
  self.moneytype = moneytype or nil
  self.num = num or nil
  self.usedItemNum = usedItemNum or nil
end
function SUseMoneyBagItemRes:marshal(os)
  os:marshalInt32(self.moneytype)
  os:marshalInt32(self.num)
  os:marshalInt32(self.usedItemNum)
end
function SUseMoneyBagItemRes:unmarshal(os)
  self.moneytype = os:unmarshalInt32()
  self.num = os:unmarshalInt32()
  self.usedItemNum = os:unmarshalInt32()
end
function SUseMoneyBagItemRes:sizepolicy(size)
  return size <= 65535
end
return SUseMoneyBagItemRes
