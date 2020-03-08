local SBrdRoleBuffInfo = class("SBrdRoleBuffInfo")
SBrdRoleBuffInfo.TYPEID = 12621598
function SBrdRoleBuffInfo:ctor(role_buff_infos)
  self.id = 12621598
  self.role_buff_infos = role_buff_infos or {}
end
function SBrdRoleBuffInfo:marshal(os)
  local _size_ = 0
  for _, _ in pairs(self.role_buff_infos) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.role_buff_infos) do
    os:marshalInt64(k)
    v:marshal(os)
  end
end
function SBrdRoleBuffInfo:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt64()
    local BeanClazz = require("netio.protocol.mzm.gsp.singlebattle.RoleBuffInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.role_buff_infos[k] = v
  end
end
function SBrdRoleBuffInfo:sizepolicy(size)
  return size <= 65535
end
return SBrdRoleBuffInfo
