local SBuyGoodsError = class("SBuyGoodsError")
SBuyGoodsError.TYPEID = 12621313
SBuyGoodsError.BUY_COUNT_ERROR = 1
SBuyGoodsError.MONEY_NOT_ENOUGH = 2
SBuyGoodsError.BAG_IS_FULL = 3
function SBuyGoodsError:ctor(errorCode)
  self.id = 12621313
  self.errorCode = errorCode or nil
end
function SBuyGoodsError:marshal(os)
  os:marshalInt32(self.errorCode)
end
function SBuyGoodsError:unmarshal(os)
  self.errorCode = os:unmarshalInt32()
end
function SBuyGoodsError:sizepolicy(size)
  return size <= 65535
end
return SBuyGoodsError
