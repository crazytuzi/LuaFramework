local SGetTitleFail = class("SGetTitleFail")
SGetTitleFail.TYPEID = 12612883
SGetTitleFail.MODULE_CLOSE_OR_ROLE_FORBIDDEN = -1
SGetTitleFail.ROLE_STATUS_ERROR = -2
SGetTitleFail.PARAM_ERROR = -3
SGetTitleFail.DB_ERROR = -4
SGetTitleFail.CAN_NOT_JOIN_ACTIVITY = 1
SGetTitleFail.ALREADY_GET_TITLE = 2
SGetTitleFail.POINT_NOT_ENOUGH = 3
SGetTitleFail.AWARD_FAIL = 4
function SGetTitleFail:ctor(res)
  self.id = 12612883
  self.res = res or nil
end
function SGetTitleFail:marshal(os)
  os:marshalInt32(self.res)
end
function SGetTitleFail:unmarshal(os)
  self.res = os:unmarshalInt32()
end
function SGetTitleFail:sizepolicy(size)
  return size <= 65535
end
return SGetTitleFail
