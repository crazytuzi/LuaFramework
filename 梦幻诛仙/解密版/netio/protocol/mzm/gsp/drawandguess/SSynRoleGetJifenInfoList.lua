local SSynRoleGetJifenInfoList = class("SSynRoleGetJifenInfoList")
SSynRoleGetJifenInfoList.TYPEID = 12617248
function SSynRoleGetJifenInfoList:ctor(jifen_list)
  self.id = 12617248
  self.jifen_list = jifen_list or {}
end
function SSynRoleGetJifenInfoList:marshal(os)
  os:marshalCompactUInt32(table.getn(self.jifen_list))
  for _, v in ipairs(self.jifen_list) do
    v:marshal(os)
  end
end
function SSynRoleGetJifenInfoList:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.drawandguess.RoleGetJifenInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.jifen_list, v)
  end
end
function SSynRoleGetJifenInfoList:sizepolicy(size)
  return size <= 65535
end
return SSynRoleGetJifenInfoList
