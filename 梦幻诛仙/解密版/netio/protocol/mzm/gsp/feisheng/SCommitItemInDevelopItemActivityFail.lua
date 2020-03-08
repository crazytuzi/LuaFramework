local SCommitItemInDevelopItemActivityFail = class("SCommitItemInDevelopItemActivityFail")
SCommitItemInDevelopItemActivityFail.TYPEID = 12614157
SCommitItemInDevelopItemActivityFail.MODULE_CLOSE_OR_ROLE_FORBIDDEN = -1
SCommitItemInDevelopItemActivityFail.ROLE_STATUS_ERROR = -2
SCommitItemInDevelopItemActivityFail.PARAM_ERROR = -3
SCommitItemInDevelopItemActivityFail.CHECK_NPC_SERVICE_ERROR = -4
SCommitItemInDevelopItemActivityFail.SERVER_LEVEL_NOT_ENOUGH = -5
SCommitItemInDevelopItemActivityFail.CAN_NOT_JOIN_ACTIVITY = 1
SCommitItemInDevelopItemActivityFail.COST_ITEM_FAIL = 2
SCommitItemInDevelopItemActivityFail.EXTRA_VALUE_NOT_ENOUGH = 3
SCommitItemInDevelopItemActivityFail.AWARD_FAIL = 4
function SCommitItemInDevelopItemActivityFail:ctor(res)
  self.id = 12614157
  self.res = res or nil
end
function SCommitItemInDevelopItemActivityFail:marshal(os)
  os:marshalInt32(self.res)
end
function SCommitItemInDevelopItemActivityFail:unmarshal(os)
  self.res = os:unmarshalInt32()
end
function SCommitItemInDevelopItemActivityFail:sizepolicy(size)
  return size <= 65535
end
return SCommitItemInDevelopItemActivityFail
