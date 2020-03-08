local CExchangeUseItem = class("CExchangeUseItem")
CExchangeUseItem.TYPEID = 12584764
function CExchangeUseItem:ctor(exchangecfgid, exchangecount, clientneedyuanbao)
  self.id = 12584764
  self.exchangecfgid = exchangecfgid or nil
  self.exchangecount = exchangecount or nil
  self.clientneedyuanbao = clientneedyuanbao or nil
end
function CExchangeUseItem:marshal(os)
  os:marshalInt32(self.exchangecfgid)
  os:marshalInt32(self.exchangecount)
  os:marshalInt64(self.clientneedyuanbao)
end
function CExchangeUseItem:unmarshal(os)
  self.exchangecfgid = os:unmarshalInt32()
  self.exchangecount = os:unmarshalInt32()
  self.clientneedyuanbao = os:unmarshalInt64()
end
function CExchangeUseItem:sizepolicy(size)
  return size <= 65535
end
return CExchangeUseItem
