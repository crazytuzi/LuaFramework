local SPointExchangeRsp = class("SPointExchangeRsp")
SPointExchangeRsp.TYPEID = 12624904
function SPointExchangeRsp:ctor(activityId, activityPointExchangeMallCfgId, pointCount, goodsCfgId, count, available)
  self.id = 12624904
  self.activityId = activityId or nil
  self.activityPointExchangeMallCfgId = activityPointExchangeMallCfgId or nil
  self.pointCount = pointCount or nil
  self.goodsCfgId = goodsCfgId or nil
  self.count = count or nil
  self.available = available or nil
end
function SPointExchangeRsp:marshal(os)
  os:marshalInt32(self.activityId)
  os:marshalInt32(self.activityPointExchangeMallCfgId)
  os:marshalInt64(self.pointCount)
  os:marshalInt32(self.goodsCfgId)
  os:marshalInt32(self.count)
  os:marshalInt32(self.available)
end
function SPointExchangeRsp:unmarshal(os)
  self.activityId = os:unmarshalInt32()
  self.activityPointExchangeMallCfgId = os:unmarshalInt32()
  self.pointCount = os:unmarshalInt64()
  self.goodsCfgId = os:unmarshalInt32()
  self.count = os:unmarshalInt32()
  self.available = os:unmarshalInt32()
end
function SPointExchangeRsp:sizepolicy(size)
  return size <= 65535
end
return SPointExchangeRsp
