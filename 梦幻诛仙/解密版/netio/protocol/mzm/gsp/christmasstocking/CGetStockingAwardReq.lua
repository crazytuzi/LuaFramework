local CGetStockingAwardReq = class("CGetStockingAwardReq")
CGetStockingAwardReq.TYPEID = 12629511
function CGetStockingAwardReq:ctor(position)
  self.id = 12629511
  self.position = position or nil
end
function CGetStockingAwardReq:marshal(os)
  os:marshalInt32(self.position)
end
function CGetStockingAwardReq:unmarshal(os)
  self.position = os:unmarshalInt32()
end
function CGetStockingAwardReq:sizepolicy(size)
  return size <= 65535
end
return CGetStockingAwardReq
