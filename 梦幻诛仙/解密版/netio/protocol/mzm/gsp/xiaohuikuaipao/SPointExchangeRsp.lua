local SPointExchangeRsp = class("SPointExchangeRsp")
SPointExchangeRsp.TYPEID = 12622851
function SPointExchangeRsp:ctor(pointCount, pointExchangeCfgId, count, available)
  self.id = 12622851
  self.pointCount = pointCount or nil
  self.pointExchangeCfgId = pointExchangeCfgId or nil
  self.count = count or nil
  self.available = available or nil
end
function SPointExchangeRsp:marshal(os)
  os:marshalInt64(self.pointCount)
  os:marshalInt32(self.pointExchangeCfgId)
  os:marshalInt32(self.count)
  os:marshalInt32(self.available)
end
function SPointExchangeRsp:unmarshal(os)
  self.pointCount = os:unmarshalInt64()
  self.pointExchangeCfgId = os:unmarshalInt32()
  self.count = os:unmarshalInt32()
  self.available = os:unmarshalInt32()
end
function SPointExchangeRsp:sizepolicy(size)
  return size <= 65535
end
return SPointExchangeRsp
