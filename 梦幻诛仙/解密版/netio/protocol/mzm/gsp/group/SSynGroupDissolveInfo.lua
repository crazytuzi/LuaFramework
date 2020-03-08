local SSynGroupDissolveInfo = class("SSynGroupDissolveInfo")
SSynGroupDissolveInfo.TYPEID = 12605223
function SSynGroupDissolveInfo:ctor(group_dissolve_infos)
  self.id = 12605223
  self.group_dissolve_infos = group_dissolve_infos or {}
end
function SSynGroupDissolveInfo:marshal(os)
  os:marshalCompactUInt32(table.getn(self.group_dissolve_infos))
  for _, v in ipairs(self.group_dissolve_infos) do
    os:marshalOctets(v)
  end
end
function SSynGroupDissolveInfo:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalOctets()
    table.insert(self.group_dissolve_infos, v)
  end
end
function SSynGroupDissolveInfo:sizepolicy(size)
  return size <= 65535
end
return SSynGroupDissolveInfo
