local SGetFinalStageBetInfoFail = class("SGetFinalStageBetInfoFail")
SGetFinalStageBetInfoFail.TYPEID = 12617076
SGetFinalStageBetInfoFail.MODULE_CLOSE_OR_ROLE_FORBIDDEN = -1
SGetFinalStageBetInfoFail.ROLE_STATUS_ERROR = -2
SGetFinalStageBetInfoFail.PARAM_ERROR = -3
SGetFinalStageBetInfoFail.CHECK_NPC_SERVICE_ERROR = -4
SGetFinalStageBetInfoFail.COMMUNICATION_ERROR = 1
SGetFinalStageBetInfoFail.GET_STAGE_DATA_FAIL = 2
SGetFinalStageBetInfoFail.GET_STAGE_BET_DATA_FAIL = 3
function SGetFinalStageBetInfoFail:ctor(res)
  self.id = 12617076
  self.res = res or nil
end
function SGetFinalStageBetInfoFail:marshal(os)
  os:marshalInt32(self.res)
end
function SGetFinalStageBetInfoFail:unmarshal(os)
  self.res = os:unmarshalInt32()
end
function SGetFinalStageBetInfoFail:sizepolicy(size)
  return size <= 65535
end
return SGetFinalStageBetInfoFail
