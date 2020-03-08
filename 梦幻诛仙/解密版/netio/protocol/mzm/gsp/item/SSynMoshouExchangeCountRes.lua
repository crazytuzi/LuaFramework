local SSynMoshouExchangeCountRes = class("SSynMoshouExchangeCountRes")
SSynMoshouExchangeCountRes.TYPEID = 12584846
function SSynMoshouExchangeCountRes:ctor(exchangeCount, canExchangeMoshou)
  self.id = 12584846
  self.exchangeCount = exchangeCount or nil
  self.canExchangeMoshou = canExchangeMoshou or nil
end
function SSynMoshouExchangeCountRes:marshal(os)
  os:marshalInt32(self.exchangeCount)
  os:marshalInt32(self.canExchangeMoshou)
end
function SSynMoshouExchangeCountRes:unmarshal(os)
  self.exchangeCount = os:unmarshalInt32()
  self.canExchangeMoshou = os:unmarshalInt32()
end
function SSynMoshouExchangeCountRes:sizepolicy(size)
  return size <= 65535
end
return SSynMoshouExchangeCountRes
