local SGetStockingAwardSuccess = class("SGetStockingAwardSuccess")
SGetStockingAwardSuccess.TYPEID = 12629505
function SGetStockingAwardSuccess:ctor(position)
  self.id = 12629505
  self.position = position or nil
end
function SGetStockingAwardSuccess:marshal(os)
  os:marshalInt32(self.position)
end
function SGetStockingAwardSuccess:unmarshal(os)
  self.position = os:unmarshalInt32()
end
function SGetStockingAwardSuccess:sizepolicy(size)
  return size <= 65535
end
return SGetStockingAwardSuccess
