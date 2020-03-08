local RoleInfo = require("netio.protocol.mzm.gsp.breakegg.RoleInfo")
local SSynInviteInfo = class("SSynInviteInfo")
SSynInviteInfo.TYPEID = 12623368
function SSynInviteInfo:ctor(inviter_info, invite_type, session_id, extro_info, end_time)
  self.id = 12623368
  self.inviter_info = inviter_info or RoleInfo.new()
  self.invite_type = invite_type or nil
  self.session_id = session_id or nil
  self.extro_info = extro_info or nil
  self.end_time = end_time or nil
end
function SSynInviteInfo:marshal(os)
  self.inviter_info:marshal(os)
  os:marshalInt32(self.invite_type)
  os:marshalInt64(self.session_id)
  os:marshalOctets(self.extro_info)
  os:marshalInt64(self.end_time)
end
function SSynInviteInfo:unmarshal(os)
  self.inviter_info = RoleInfo.new()
  self.inviter_info:unmarshal(os)
  self.invite_type = os:unmarshalInt32()
  self.session_id = os:unmarshalInt64()
  self.extro_info = os:unmarshalOctets()
  self.end_time = os:unmarshalInt64()
end
function SSynInviteInfo:sizepolicy(size)
  return size <= 65535
end
return SSynInviteInfo
