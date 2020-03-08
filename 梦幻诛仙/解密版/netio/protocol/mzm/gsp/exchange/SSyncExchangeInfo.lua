local SSyncExchangeInfo = class("SSyncExchangeInfo")
SSyncExchangeInfo.TYPEID = 12604162
function SSyncExchangeInfo:ctor(exchange_activity_infos)
  self.id = 12604162
  self.exchange_activity_infos = exchange_activity_infos or {}
end
function SSyncExchangeInfo:marshal(os)
  local _size_ = 0
  for _, _ in pairs(self.exchange_activity_infos) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.exchange_activity_infos) do
    os:marshalInt32(k)
    v:marshal(os)
  end
end
function SSyncExchangeInfo:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local BeanClazz = require("netio.protocol.mzm.gsp.exchange.ExchangeActivityInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.exchange_activity_infos[k] = v
  end
end
function SSyncExchangeInfo:sizepolicy(size)
  return size <= 65535
end
return SSyncExchangeInfo
