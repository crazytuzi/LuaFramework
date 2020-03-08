local SSynInviteJoinInfo = class("SSynInviteJoinInfo")
SSynInviteJoinInfo.TYPEID = 12623371
function SSynInviteJoinInfo:ctor(inviter_id, role_info_list, invite_type, session_id, extro_info, end_time)
  self.id = 12623371
  self.inviter_id = inviter_id or nil
  self.role_info_list = role_info_list or {}
  self.invite_type = invite_type or nil
  self.session_id = session_id or nil
  self.extro_info = extro_info or nil
  self.end_time = end_time or nil
end
function SSynInviteJoinInfo:marshal(os)
  os:marshalInt64(self.inviter_id)
  os:marshalCompactUInt32(table.getn(self.role_info_list))
  for _, v in ipairs(self.role_info_list) do
    v:marshal(os)
  end
  os:marshalInt32(self.invite_type)
  os:marshalInt64(self.session_id)
  os:marshalOctets(self.extro_info)
  os:marshalInt64(self.end_time)
end
function SSynInviteJoinInfo:unmarshal(os)
  self.inviter_id = os:unmarshalInt64()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.breakegg.RoleInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.role_info_list, v)
  end
  self.invite_type = os:unmarshalInt32()
  self.session_id = os:unmarshalInt64()
  self.extro_info = os:unmarshalOctets()
  self.end_time = os:unmarshalInt64()
end
function SSynInviteJoinInfo:sizepolicy(size)
  return size <= 65535
end
return SSynInviteJoinInfo
