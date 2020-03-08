local SRoleBuffInfo = class("SRoleBuffInfo")
SRoleBuffInfo.TYPEID = 12621599
function SRoleBuffInfo:ctor(buff_cfg_ids)
  self.id = 12621599
  self.buff_cfg_ids = buff_cfg_ids or {}
end
function SRoleBuffInfo:marshal(os)
  local _size_ = 0
  for _, _ in pairs(self.buff_cfg_ids) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, _ in pairs(self.buff_cfg_ids) do
    os:marshalInt32(k)
  end
end
function SRoleBuffInfo:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    self.buff_cfg_ids[v] = v
  end
end
function SRoleBuffInfo:sizepolicy(size)
  return size <= 65535
end
return SRoleBuffInfo
