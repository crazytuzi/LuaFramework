local SSynGroupJoinInfo = class("SSynGroupJoinInfo")
SSynGroupJoinInfo.TYPEID = 12605221
function SSynGroupJoinInfo:ctor(group_join_infos)
  self.id = 12605221
  self.group_join_infos = group_join_infos or {}
end
function SSynGroupJoinInfo:marshal(os)
  os:marshalCompactUInt32(table.getn(self.group_join_infos))
  for _, v in ipairs(self.group_join_infos) do
    v:marshal(os)
  end
end
function SSynGroupJoinInfo:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.group.GroupJoinInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.group_join_infos, v)
  end
end
function SSynGroupJoinInfo:sizepolicy(size)
  return size <= 65535
end
return SSynGroupJoinInfo
