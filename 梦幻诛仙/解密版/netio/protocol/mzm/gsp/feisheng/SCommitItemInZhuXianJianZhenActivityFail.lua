local SCommitItemInZhuXianJianZhenActivityFail = class("SCommitItemInZhuXianJianZhenActivityFail")
SCommitItemInZhuXianJianZhenActivityFail.TYPEID = 12614154
SCommitItemInZhuXianJianZhenActivityFail.MODULE_CLOSE_OR_ROLE_FORBIDDEN = -1
SCommitItemInZhuXianJianZhenActivityFail.ROLE_STATUS_ERROR = -2
SCommitItemInZhuXianJianZhenActivityFail.PARAM_ERROR = -3
SCommitItemInZhuXianJianZhenActivityFail.CHECK_NPC_SERVICE_ERROR = -4
SCommitItemInZhuXianJianZhenActivityFail.SERVER_LEVEL_NOT_ENOUGH = -5
SCommitItemInZhuXianJianZhenActivityFail.DB_ERROR = -6
SCommitItemInZhuXianJianZhenActivityFail.CAN_NOT_JOIN_ACTIVITY = 1
SCommitItemInZhuXianJianZhenActivityFail.ITEM_NOT_ENOUGH = 2
SCommitItemInZhuXianJianZhenActivityFail.COMMIT_ITEM_NUM_TO_LIMIT = 3
SCommitItemInZhuXianJianZhenActivityFail.ACTIVITY_STAGE_ERROR = 4
function SCommitItemInZhuXianJianZhenActivityFail:ctor(res)
  self.id = 12614154
  self.res = res or nil
end
function SCommitItemInZhuXianJianZhenActivityFail:marshal(os)
  os:marshalInt32(self.res)
end
function SCommitItemInZhuXianJianZhenActivityFail:unmarshal(os)
  self.res = os:unmarshalInt32()
end
function SCommitItemInZhuXianJianZhenActivityFail:sizepolicy(size)
  return size <= 65535
end
return SCommitItemInZhuXianJianZhenActivityFail
