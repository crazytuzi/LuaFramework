local SAttendZhuXianJianZhenActivityFail = class("SAttendZhuXianJianZhenActivityFail")
SAttendZhuXianJianZhenActivityFail.TYPEID = 12614170
SAttendZhuXianJianZhenActivityFail.MODULE_CLOSE_OR_ROLE_FORBIDDEN = -1
SAttendZhuXianJianZhenActivityFail.ROLE_STATUS_ERROR = -2
SAttendZhuXianJianZhenActivityFail.PARAM_ERROR = -3
SAttendZhuXianJianZhenActivityFail.CHECK_NPC_SERVICE_ERROR = -4
SAttendZhuXianJianZhenActivityFail.SERVER_LEVEL_NOT_ENOUGH = -5
SAttendZhuXianJianZhenActivityFail.DB_ERROR = -6
SAttendZhuXianJianZhenActivityFail.CAN_NOT_JOIN_ACTIVITY = 1
SAttendZhuXianJianZhenActivityFail.TRY_TIMES_TO_LIMIT = 2
SAttendZhuXianJianZhenActivityFail.AWARD_FAIL = 3
SAttendZhuXianJianZhenActivityFail.ROLE_IN_TEAM = 4
SAttendZhuXianJianZhenActivityFail.ACTIVITY_STAGE_ERROR = 5
function SAttendZhuXianJianZhenActivityFail:ctor(res)
  self.id = 12614170
  self.res = res or nil
end
function SAttendZhuXianJianZhenActivityFail:marshal(os)
  os:marshalInt32(self.res)
end
function SAttendZhuXianJianZhenActivityFail:unmarshal(os)
  self.res = os:unmarshalInt32()
end
function SAttendZhuXianJianZhenActivityFail:sizepolicy(size)
  return size <= 65535
end
return SAttendZhuXianJianZhenActivityFail
