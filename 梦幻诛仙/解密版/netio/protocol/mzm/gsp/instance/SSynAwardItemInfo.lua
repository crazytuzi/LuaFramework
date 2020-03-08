local SSynAwardItemInfo = class("SSynAwardItemInfo")
SSynAwardItemInfo.TYPEID = 12591375
function SSynAwardItemInfo:ctor(awardUuid, itemid, roles)
  self.id = 12591375
  self.awardUuid = awardUuid or nil
  self.itemid = itemid or nil
  self.roles = roles or {}
end
function SSynAwardItemInfo:marshal(os)
  os:marshalInt64(self.awardUuid)
  os:marshalInt32(self.itemid)
  os:marshalCompactUInt32(table.getn(self.roles))
  for _, v in ipairs(self.roles) do
    v:marshal(os)
  end
end
function SSynAwardItemInfo:unmarshal(os)
  self.awardUuid = os:unmarshalInt64()
  self.itemid = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.instance.RoleInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.roles, v)
  end
end
function SSynAwardItemInfo:sizepolicy(size)
  return size <= 65535
end
return SSynAwardItemInfo
