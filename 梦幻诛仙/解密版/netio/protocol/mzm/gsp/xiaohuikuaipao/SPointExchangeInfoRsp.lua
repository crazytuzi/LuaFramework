local SPointExchangeInfoRsp = class("SPointExchangeInfoRsp")
SPointExchangeInfoRsp.TYPEID = 12622860
function SPointExchangeInfoRsp:ctor(pointCount, cfgId2available)
  self.id = 12622860
  self.pointCount = pointCount or nil
  self.cfgId2available = cfgId2available or {}
end
function SPointExchangeInfoRsp:marshal(os)
  os:marshalInt64(self.pointCount)
  local _size_ = 0
  for _, _ in pairs(self.cfgId2available) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.cfgId2available) do
    os:marshalInt32(k)
    os:marshalInt32(v)
  end
end
function SPointExchangeInfoRsp:unmarshal(os)
  self.pointCount = os:unmarshalInt64()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.cfgId2available[k] = v
  end
end
function SPointExchangeInfoRsp:sizepolicy(size)
  return size <= 65535
end
return SPointExchangeInfoRsp
