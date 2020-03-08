local SSynJiuXiaoFisrtWinRes = class("SSynJiuXiaoFisrtWinRes")
SSynJiuXiaoFisrtWinRes.TYPEID = 12595469
function SSynJiuXiaoFisrtWinRes:ctor(cfgid, roles)
  self.id = 12595469
  self.cfgid = cfgid or nil
  self.roles = roles or {}
end
function SSynJiuXiaoFisrtWinRes:marshal(os)
  os:marshalInt32(self.cfgid)
  os:marshalCompactUInt32(table.getn(self.roles))
  for _, v in ipairs(self.roles) do
    v:marshal(os)
  end
end
function SSynJiuXiaoFisrtWinRes:unmarshal(os)
  self.cfgid = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.jiuxiao.RoleData")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.roles, v)
  end
end
function SSynJiuXiaoFisrtWinRes:sizepolicy(size)
  return size <= 65535
end
return SSynJiuXiaoFisrtWinRes
