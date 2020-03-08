local CGetRoleGroupInfoReq = class("CGetRoleGroupInfoReq")
CGetRoleGroupInfoReq.TYPEID = 12605191
function CGetRoleGroupInfoReq:ctor(groupid2info_version)
  self.id = 12605191
  self.groupid2info_version = groupid2info_version or {}
end
function CGetRoleGroupInfoReq:marshal(os)
  local _size_ = 0
  for _, _ in pairs(self.groupid2info_version) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.groupid2info_version) do
    os:marshalInt64(k)
    os:marshalInt64(v)
  end
end
function CGetRoleGroupInfoReq:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt64()
    local v = os:unmarshalInt64()
    self.groupid2info_version[k] = v
  end
end
function CGetRoleGroupInfoReq:sizepolicy(size)
  return size <= 65535
end
return CGetRoleGroupInfoReq
