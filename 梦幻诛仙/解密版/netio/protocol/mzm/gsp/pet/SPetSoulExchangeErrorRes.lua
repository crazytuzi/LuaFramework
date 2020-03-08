local SPetSoulExchangeErrorRes = class("SPetSoulExchangeErrorRes")
SPetSoulExchangeErrorRes.TYPEID = 12590678
SPetSoulExchangeErrorRes.ERROR_MONEY_NOT_ENOUGH = 1
SPetSoulExchangeErrorRes.ERROR_NOT_OVER_PET_LEVEL = 2
SPetSoulExchangeErrorRes.ERROR_ITEM_NOT_ENOUGH = 3
function SPetSoulExchangeErrorRes:ctor(ret)
  self.id = 12590678
  self.ret = ret or nil
end
function SPetSoulExchangeErrorRes:marshal(os)
  os:marshalInt32(self.ret)
end
function SPetSoulExchangeErrorRes:unmarshal(os)
  self.ret = os:unmarshalInt32()
end
function SPetSoulExchangeErrorRes:sizepolicy(size)
  return size <= 65535
end
return SPetSoulExchangeErrorRes
