local SSyncGroupShoppingBanInfo = class("SSyncGroupShoppingBanInfo")
SSyncGroupShoppingBanInfo.TYPEID = 12623623
function SSyncGroupShoppingBanInfo:ctor(ban_infos)
  self.id = 12623623
  self.ban_infos = ban_infos or {}
end
function SSyncGroupShoppingBanInfo:marshal(os)
  local _size_ = 0
  for _, _ in pairs(self.ban_infos) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, _ in pairs(self.ban_infos) do
    k:marshal(os)
  end
end
function SSyncGroupShoppingBanInfo:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.groupshopping.GroupShoppingBanInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.ban_infos[v] = v
  end
end
function SSyncGroupShoppingBanInfo:sizepolicy(size)
  return size <= 65535
end
return SSyncGroupShoppingBanInfo
