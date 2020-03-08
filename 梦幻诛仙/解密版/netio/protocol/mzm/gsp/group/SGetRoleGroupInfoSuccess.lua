local SGetRoleGroupInfoSuccess = class("SGetRoleGroupInfoSuccess")
SGetRoleGroupInfoSuccess.TYPEID = 12605209
function SGetRoleGroupInfoSuccess:ctor(groupid2group_basic_info)
  self.id = 12605209
  self.groupid2group_basic_info = groupid2group_basic_info or {}
end
function SGetRoleGroupInfoSuccess:marshal(os)
  local _size_ = 0
  for _, _ in pairs(self.groupid2group_basic_info) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.groupid2group_basic_info) do
    os:marshalInt64(k)
    v:marshal(os)
  end
end
function SGetRoleGroupInfoSuccess:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt64()
    local BeanClazz = require("netio.protocol.mzm.gsp.group.GroupInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.groupid2group_basic_info[k] = v
  end
end
function SGetRoleGroupInfoSuccess:sizepolicy(size)
  return size <= 65535
end
return SGetRoleGroupInfoSuccess
