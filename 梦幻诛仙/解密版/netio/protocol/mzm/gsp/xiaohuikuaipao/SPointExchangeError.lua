local SPointExchangeError = class("SPointExchangeError")
SPointExchangeError.TYPEID = 12622863
SPointExchangeError.POINT_NOT_ENOUGH = 1
SPointExchangeError.EXCHANGE_COUNT_MAX = 2
function SPointExchangeError:ctor(errorCode, pointExchangeCfgId, count)
  self.id = 12622863
  self.errorCode = errorCode or nil
  self.pointExchangeCfgId = pointExchangeCfgId or nil
  self.count = count or nil
end
function SPointExchangeError:marshal(os)
  os:marshalInt32(self.errorCode)
  os:marshalInt32(self.pointExchangeCfgId)
  os:marshalInt32(self.count)
end
function SPointExchangeError:unmarshal(os)
  self.errorCode = os:unmarshalInt32()
  self.pointExchangeCfgId = os:unmarshalInt32()
  self.count = os:unmarshalInt32()
end
function SPointExchangeError:sizepolicy(size)
  return size <= 65535
end
return SPointExchangeError
