local SNotifyTeamPKConfirm = class("SNotifyTeamPKConfirm")
SNotifyTeamPKConfirm.TYPEID = 12619780
function SNotifyTeamPKConfirm:ctor(role_id)
  self.id = 12619780
  self.role_id = role_id or nil
end
function SNotifyTeamPKConfirm:marshal(os)
  os:marshalInt64(self.role_id)
end
function SNotifyTeamPKConfirm:unmarshal(os)
  self.role_id = os:unmarshalInt64()
end
function SNotifyTeamPKConfirm:sizepolicy(size)
  return size <= 65535
end
return SNotifyTeamPKConfirm
