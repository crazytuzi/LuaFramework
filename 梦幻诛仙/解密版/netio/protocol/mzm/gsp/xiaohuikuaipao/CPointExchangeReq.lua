local CPointExchangeReq = class("CPointExchangeReq")
CPointExchangeReq.TYPEID = 12622850
function CPointExchangeReq:ctor(pointExchangeCfgId, count)
  self.id = 12622850
  self.pointExchangeCfgId = pointExchangeCfgId or nil
  self.count = count or nil
end
function CPointExchangeReq:marshal(os)
  os:marshalInt32(self.pointExchangeCfgId)
  os:marshalInt32(self.count)
end
function CPointExchangeReq:unmarshal(os)
  self.pointExchangeCfgId = os:unmarshalInt32()
  self.count = os:unmarshalInt32()
end
function CPointExchangeReq:sizepolicy(size)
  return size <= 65535
end
return CPointExchangeReq
