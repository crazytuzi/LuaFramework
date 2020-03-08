local SSynPlayerLoseFightRes = class("SSynPlayerLoseFightRes")
SSynPlayerLoseFightRes.TYPEID = 12587577
function SSynPlayerLoseFightRes:ctor(roleinfos, mapCfgid, monsterid, start, nextStart)
  self.id = 12587577
  self.roleinfos = roleinfos or {}
  self.mapCfgid = mapCfgid or nil
  self.monsterid = monsterid or nil
  self.start = start or nil
  self.nextStart = nextStart or nil
end
function SSynPlayerLoseFightRes:marshal(os)
  os:marshalCompactUInt32(table.getn(self.roleinfos))
  for _, v in ipairs(self.roleinfos) do
    v:marshal(os)
  end
  os:marshalInt32(self.mapCfgid)
  os:marshalInt32(self.monsterid)
  os:marshalInt32(self.start)
  os:marshalInt32(self.nextStart)
end
function SSynPlayerLoseFightRes:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.activity.RoleInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.roleinfos, v)
  end
  self.mapCfgid = os:unmarshalInt32()
  self.monsterid = os:unmarshalInt32()
  self.start = os:unmarshalInt32()
  self.nextStart = os:unmarshalInt32()
end
function SSynPlayerLoseFightRes:sizepolicy(size)
  return size <= 65535
end
return SSynPlayerLoseFightRes
