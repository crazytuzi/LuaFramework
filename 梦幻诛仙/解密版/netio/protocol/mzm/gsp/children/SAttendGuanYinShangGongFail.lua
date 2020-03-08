local SAttendGuanYinShangGongFail = class("SAttendGuanYinShangGongFail")
SAttendGuanYinShangGongFail.TYPEID = 12609349
SAttendGuanYinShangGongFail.MODULE_CLOSE_OR_ROLE_FORBIDDEN = -1
SAttendGuanYinShangGongFail.ROLE_STATUS_ERROR = -2
SAttendGuanYinShangGongFail.CHECK_NPC_SERVICE_ERROR = -3
SAttendGuanYinShangGongFail.HAVE_NO_HOMELAND = 1
SAttendGuanYinShangGongFail.BREED_STATE_ERROR = 2
SAttendGuanYinShangGongFail.CHILD_NUM_TO_UPPER_LIMIT = 3
SAttendGuanYinShangGongFail.POINT_TO_UPPER_LIMIT = 4
SAttendGuanYinShangGongFail.CAN_NOT_JOIN_ACTIVITY = 5
SAttendGuanYinShangGongFail.START_SHANG_GONG_FAIL = 6
function SAttendGuanYinShangGongFail:ctor(res)
  self.id = 12609349
  self.res = res or nil
end
function SAttendGuanYinShangGongFail:marshal(os)
  os:marshalInt32(self.res)
end
function SAttendGuanYinShangGongFail:unmarshal(os)
  self.res = os:unmarshalInt32()
end
function SAttendGuanYinShangGongFail:sizepolicy(size)
  return size <= 65535
end
return SAttendGuanYinShangGongFail
