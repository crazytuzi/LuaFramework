local SUseExchangeItemFail = class("SUseExchangeItemFail")
SUseExchangeItemFail.TYPEID = 12618255
SUseExchangeItemFail.ITEM_NOT_EXISTS = 1
SUseExchangeItemFail.INVALID_ITEM = 2
function SUseExchangeItemFail:ctor(retcode, item_key)
  self.id = 12618255
  self.retcode = retcode or nil
  self.item_key = item_key or nil
end
function SUseExchangeItemFail:marshal(os)
  os:marshalInt32(self.retcode)
  os:marshalInt32(self.item_key)
end
function SUseExchangeItemFail:unmarshal(os)
  self.retcode = os:unmarshalInt32()
  self.item_key = os:unmarshalInt32()
end
function SUseExchangeItemFail:sizepolicy(size)
  return size <= 65535
end
return SUseExchangeItemFail
