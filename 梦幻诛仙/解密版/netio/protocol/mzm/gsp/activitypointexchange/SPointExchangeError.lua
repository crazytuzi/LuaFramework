local SPointExchangeError = class("SPointExchangeError")
SPointExchangeError.TYPEID = 12624898
SPointExchangeError.POINT_NOT_ENOUGH = 1
SPointExchangeError.EXCHANGE_COUNT_MAX = 2
SPointExchangeError.GOODS_SOLD_OUT = 3
SPointExchangeError.ACTIVITY_CLOSED = 4
SPointExchangeError.MALL_CLOSED = 5
function SPointExchangeError:ctor(errorCode, activityId, goodsCfgId, count)
  self.id = 12624898
  self.errorCode = errorCode or nil
  self.activityId = activityId or nil
  self.goodsCfgId = goodsCfgId or nil
  self.count = count or nil
end
function SPointExchangeError:marshal(os)
  os:marshalInt32(self.errorCode)
  os:marshalInt32(self.activityId)
  os:marshalInt32(self.goodsCfgId)
  os:marshalInt32(self.count)
end
function SPointExchangeError:unmarshal(os)
  self.errorCode = os:unmarshalInt32()
  self.activityId = os:unmarshalInt32()
  self.goodsCfgId = os:unmarshalInt32()
  self.count = os:unmarshalInt32()
end
function SPointExchangeError:sizepolicy(size)
  return size <= 65535
end
return SPointExchangeError
