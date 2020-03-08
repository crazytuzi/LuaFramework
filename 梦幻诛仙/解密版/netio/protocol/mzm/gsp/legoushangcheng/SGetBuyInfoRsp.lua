local SGetBuyInfoRsp = class("SGetBuyInfoRsp")
SGetBuyInfoRsp.TYPEID = 12621315
function SGetBuyInfoRsp:ctor(cfgId2buyCount)
  self.id = 12621315
  self.cfgId2buyCount = cfgId2buyCount or {}
end
function SGetBuyInfoRsp:marshal(os)
  local _size_ = 0
  for _, _ in pairs(self.cfgId2buyCount) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.cfgId2buyCount) do
    os:marshalInt32(k)
    os:marshalInt32(v)
  end
end
function SGetBuyInfoRsp:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.cfgId2buyCount[k] = v
  end
end
function SGetBuyInfoRsp:sizepolicy(size)
  return size <= 65535
end
return SGetBuyInfoRsp
