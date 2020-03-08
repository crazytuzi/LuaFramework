local SSynBreakEggJoinInfo = class("SSynBreakEggJoinInfo")
SSynBreakEggJoinInfo.TYPEID = 12623367
function SSynBreakEggJoinInfo:ctor(activity_id, inviter_id, role_info_list, session_id, end_time)
  self.id = 12623367
  self.activity_id = activity_id or nil
  self.inviter_id = inviter_id or nil
  self.role_info_list = role_info_list or {}
  self.session_id = session_id or nil
  self.end_time = end_time or nil
end
function SSynBreakEggJoinInfo:marshal(os)
  os:marshalInt32(self.activity_id)
  os:marshalInt64(self.inviter_id)
  os:marshalCompactUInt32(table.getn(self.role_info_list))
  for _, v in ipairs(self.role_info_list) do
    v:marshal(os)
  end
  os:marshalInt64(self.session_id)
  os:marshalInt64(self.end_time)
end
function SSynBreakEggJoinInfo:unmarshal(os)
  self.activity_id = os:unmarshalInt32()
  self.inviter_id = os:unmarshalInt64()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.breakegg.RoleInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.role_info_list, v)
  end
  self.session_id = os:unmarshalInt64()
  self.end_time = os:unmarshalInt64()
end
function SSynBreakEggJoinInfo:sizepolicy(size)
  return size <= 65535
end
return SSynBreakEggJoinInfo
