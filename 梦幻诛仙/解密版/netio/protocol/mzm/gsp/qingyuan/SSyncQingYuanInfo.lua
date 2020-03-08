local SSyncQingYuanInfo = class("SSyncQingYuanInfo")
SSyncQingYuanInfo.TYPEID = 12602893
function SSyncQingYuanInfo:ctor(qing_yuan_role_list)
  self.id = 12602893
  self.qing_yuan_role_list = qing_yuan_role_list or {}
end
function SSyncQingYuanInfo:marshal(os)
  os:marshalCompactUInt32(table.getn(self.qing_yuan_role_list))
  for _, v in ipairs(self.qing_yuan_role_list) do
    os:marshalInt64(v)
  end
end
function SSyncQingYuanInfo:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt64()
    table.insert(self.qing_yuan_role_list, v)
  end
end
function SSyncQingYuanInfo:sizepolicy(size)
  return size <= 65535
end
return SSyncQingYuanInfo
