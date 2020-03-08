local OctetsStream = require("netio.OctetsStream")
local GetKnockOutContext = class("GetKnockOutContext")
GetKnockOutContext.OPER_REFRESH_KNOCK_OUT_DATA = -1
GetKnockOutContext.OPER_CHECK_PANEL_REQ = 0
GetKnockOutContext.OPER_GET_SPECIAL_FIGHT_ZONE_REQ = 1
GetKnockOutContext.OPER_CREATE_PREPARE_WORLD_REQ = 2
GetKnockOutContext.OPER_GET_STAGE_BET_INFO_REQ = 3
GetKnockOutContext.OPER_GET_FIGHT_ZONE_INFO_REQ = 4
GetKnockOutContext.OPER_BET_IN_KNOCKOUT = 5
GetKnockOutContext.OPER_SETTLE_KNOCKOUT_STAGE_BET = 6
GetKnockOutContext.OPER_SETTLE_ROLE_KNOCKOUT_STAGE_BET = 7
GetKnockOutContext.OPER_REPORT_FIGHT_RESULT = 8
GetKnockOutContext.OPER_NOTIFY_FIGHT_RESULT = 9
GetKnockOutContext.OPER_KNOCK_OUT_AWARD = 10
GetKnockOutContext.OPER_HISTORY_GET_FIGHT = 11
GetKnockOutContext.OPER_HISTORY_TOP_THREE_CORPS_INFO = 12
GetKnockOutContext.OPER_CHAMPION_CORPS_INFO = 13
GetKnockOutContext.OPER_FINAL_SERVER_AWARD = 14
function GetKnockOutContext:ctor(oper_type, content)
  self.oper_type = oper_type or nil
  self.content = content or nil
end
function GetKnockOutContext:marshal(os)
  os:marshalInt32(self.oper_type)
  os:marshalOctets(self.content)
end
function GetKnockOutContext:unmarshal(os)
  self.oper_type = os:unmarshalInt32()
  self.content = os:unmarshalOctets()
end
return GetKnockOutContext
