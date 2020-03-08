local SGetMoneyRes = class("SGetMoneyRes")
SGetMoneyRes.TYPEID = 12584966
function SGetMoneyRes:ctor(shoppingid, money)
  self.id = 12584966
  self.shoppingid = shoppingid or nil
  self.money = money or nil
end
function SGetMoneyRes:marshal(os)
  os:marshalInt64(self.shoppingid)
  os:marshalInt32(self.money)
end
function SGetMoneyRes:unmarshal(os)
  self.shoppingid = os:unmarshalInt64()
  self.money = os:unmarshalInt32()
end
function SGetMoneyRes:sizepolicy(size)
  return size <= 65535
end
return SGetMoneyRes
