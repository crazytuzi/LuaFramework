local CPointExchangeReq = class("CPointExchangeReq")
CPointExchangeReq.TYPEID = 12624907
function CPointExchangeReq:ctor(activityId, goodsCfgId, count)
  self.id = 12624907
  self.activityId = activityId or nil
  self.goodsCfgId = goodsCfgId or nil
  self.count = count or nil
end
function CPointExchangeReq:marshal(os)
  os:marshalInt32(self.activityId)
  os:marshalInt32(self.goodsCfgId)
  os:marshalInt32(self.count)
end
function CPointExchangeReq:unmarshal(os)
  self.activityId = os:unmarshalInt32()
  self.goodsCfgId = os:unmarshalInt32()
  self.count = os:unmarshalInt32()
end
function CPointExchangeReq:sizepolicy(size)
  return size <= 65535
end
return CPointExchangeReq
