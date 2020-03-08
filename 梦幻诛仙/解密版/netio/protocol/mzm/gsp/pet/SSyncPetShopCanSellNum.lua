local SSyncPetShopCanSellNum = class("SSyncPetShopCanSellNum")
SSyncPetShopCanSellNum.TYPEID = 12590617
function SSyncPetShopCanSellNum:ctor(canSellNum)
  self.id = 12590617
  self.canSellNum = canSellNum or nil
end
function SSyncPetShopCanSellNum:marshal(os)
  os:marshalInt32(self.canSellNum)
end
function SSyncPetShopCanSellNum:unmarshal(os)
  self.canSellNum = os:unmarshalInt32()
end
function SSyncPetShopCanSellNum:sizepolicy(size)
  return size <= 65535
end
return SSyncPetShopCanSellNum
