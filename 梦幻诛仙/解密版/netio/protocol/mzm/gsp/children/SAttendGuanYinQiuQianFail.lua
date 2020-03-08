local SAttendGuanYinQiuQianFail = class("SAttendGuanYinQiuQianFail")
SAttendGuanYinQiuQianFail.TYPEID = 12609351
SAttendGuanYinQiuQianFail.MODULE_CLOSE_OR_ROLE_FORBIDDEN = -1
SAttendGuanYinQiuQianFail.ROLE_STATUS_ERROR = -2
SAttendGuanYinQiuQianFail.CHECK_NPC_SERVICE_ERROR = -3
SAttendGuanYinQiuQianFail.HAVE_NO_HOMELAND = 1
SAttendGuanYinQiuQianFail.BREED_STATE_ERROR = 2
SAttendGuanYinQiuQianFail.CHILD_NUM_TO_UPPER_LIMIT = 3
SAttendGuanYinQiuQianFail.POINT_TO_UPPER_LIMIT = 4
SAttendGuanYinQiuQianFail.CAN_NOT_JOIN_ACTIVITY = 5
SAttendGuanYinQiuQianFail.START_QIU_QIAN_FAIL = 6
function SAttendGuanYinQiuQianFail:ctor(res)
  self.id = 12609351
  self.res = res or nil
end
function SAttendGuanYinQiuQianFail:marshal(os)
  os:marshalInt32(self.res)
end
function SAttendGuanYinQiuQianFail:unmarshal(os)
  self.res = os:unmarshalInt32()
end
function SAttendGuanYinQiuQianFail:sizepolicy(size)
  return size <= 65535
end
return SAttendGuanYinQiuQianFail
