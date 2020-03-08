local SSyncRoleInfoInView = class("SSyncRoleInfoInView")
SSyncRoleInfoInView.TYPEID = 12590872
function SSyncRoleInfoInView:ctor(roleInfoList)
  self.id = 12590872
  self.roleInfoList = roleInfoList or {}
end
function SSyncRoleInfoInView:marshal(os)
  os:marshalCompactUInt32(table.getn(self.roleInfoList))
  for _, v in ipairs(self.roleInfoList) do
    v:marshal(os)
  end
end
function SSyncRoleInfoInView:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.map.SimpleRoleInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.roleInfoList, v)
  end
end
function SSyncRoleInfoInView:sizepolicy(size)
  return size <= 65535
end
return SSyncRoleInfoInView
