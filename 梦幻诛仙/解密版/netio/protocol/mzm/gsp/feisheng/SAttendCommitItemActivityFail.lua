local SAttendCommitItemActivityFail = class("SAttendCommitItemActivityFail")
SAttendCommitItemActivityFail.TYPEID = 12614146
SAttendCommitItemActivityFail.MODULE_CLOSE_OR_ROLE_FORBIDDEN = -1
SAttendCommitItemActivityFail.ROLE_STATUS_ERROR = -2
SAttendCommitItemActivityFail.PARAM_ERROR = -3
SAttendCommitItemActivityFail.CHECK_NPC_SERVICE_ERROR = -4
SAttendCommitItemActivityFail.SERVER_LEVEL_NOT_ENOUGH = -5
SAttendCommitItemActivityFail.CAN_NOT_JOIN_ACTIVITY = 1
SAttendCommitItemActivityFail.ITEM_NOT_ENOUGH = 2
SAttendCommitItemActivityFail.AWARD_FAIL = 3
function SAttendCommitItemActivityFail:ctor(activity_cfg_id, res)
  self.id = 12614146
  self.activity_cfg_id = activity_cfg_id or nil
  self.res = res or nil
end
function SAttendCommitItemActivityFail:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
  os:marshalInt32(self.res)
end
function SAttendCommitItemActivityFail:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
  self.res = os:unmarshalInt32()
end
function SAttendCommitItemActivityFail:sizepolicy(size)
  return size <= 65535
end
return SAttendCommitItemActivityFail
