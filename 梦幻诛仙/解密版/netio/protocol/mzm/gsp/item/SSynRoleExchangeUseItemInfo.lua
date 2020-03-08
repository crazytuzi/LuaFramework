local SSynRoleExchangeUseItemInfo = class("SSynRoleExchangeUseItemInfo")
SSynRoleExchangeUseItemInfo.TYPEID = 12584877
function SSynRoleExchangeUseItemInfo:ctor(role_exchange_use_item_infos)
  self.id = 12584877
  self.role_exchange_use_item_infos = role_exchange_use_item_infos or {}
end
function SSynRoleExchangeUseItemInfo:marshal(os)
  local _size_ = 0
  for _, _ in pairs(self.role_exchange_use_item_infos) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.role_exchange_use_item_infos) do
    os:marshalInt32(k)
    v:marshal(os)
  end
end
function SSynRoleExchangeUseItemInfo:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local BeanClazz = require("netio.protocol.mzm.gsp.item.ExchangeUseItemInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.role_exchange_use_item_infos[k] = v
  end
end
function SSynRoleExchangeUseItemInfo:sizepolicy(size)
  return size <= 65535
end
return SSynRoleExchangeUseItemInfo
