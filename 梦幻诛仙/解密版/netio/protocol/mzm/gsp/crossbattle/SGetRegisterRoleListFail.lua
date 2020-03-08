local SGetRegisterRoleListFail = class("SGetRegisterRoleListFail")
SGetRegisterRoleListFail.TYPEID = 12617005
SGetRegisterRoleListFail.MODULE_CLOSE_OR_ROLE_FORBIDDEN = -1
SGetRegisterRoleListFail.ROLE_STATUS_ERROR = -2
SGetRegisterRoleListFail.PARAM_ERROR = -3
SGetRegisterRoleListFail.CHECK_NPC_SERVICE_ERROR = -4
SGetRegisterRoleListFail.ACTIVITY_NOT_OPEN = 1
SGetRegisterRoleListFail.ACTIVITY_STAGE_ERROR = 2
SGetRegisterRoleListFail.CORPS_NOT_REGISTER = 3
function SGetRegisterRoleListFail:ctor(res)
  self.id = 12617005
  self.res = res or nil
end
function SGetRegisterRoleListFail:marshal(os)
  os:marshalInt32(self.res)
end
function SGetRegisterRoleListFail:unmarshal(os)
  self.res = os:unmarshalInt32()
end
function SGetRegisterRoleListFail:sizepolicy(size)
  return size <= 65535
end
return SGetRegisterRoleListFail
