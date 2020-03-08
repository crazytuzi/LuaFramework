local SSynRoleBadgesInfo = class("SSynRoleBadgesInfo")
SSynRoleBadgesInfo.TYPEID = 12597505
function SSynRoleBadgesInfo:ctor(badgesInfo)
  self.id = 12597505
  self.badgesInfo = badgesInfo or {}
end
function SSynRoleBadgesInfo:marshal(os)
  os:marshalCompactUInt32(table.getn(self.badgesInfo))
  for _, v in ipairs(self.badgesInfo) do
    v:marshal(os)
  end
end
function SSynRoleBadgesInfo:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.badge.BadgeInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.badgesInfo, v)
  end
end
function SSynRoleBadgesInfo:sizepolicy(size)
  return size <= 65535
end
return SSynRoleBadgesInfo
