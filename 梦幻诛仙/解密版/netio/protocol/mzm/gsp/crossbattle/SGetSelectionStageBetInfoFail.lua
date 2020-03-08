local SGetSelectionStageBetInfoFail = class("SGetSelectionStageBetInfoFail")
SGetSelectionStageBetInfoFail.TYPEID = 12617046
SGetSelectionStageBetInfoFail.MODULE_CLOSE_OR_ROLE_FORBIDDEN = -1
SGetSelectionStageBetInfoFail.ROLE_STATUS_ERROR = -2
SGetSelectionStageBetInfoFail.PARAM_ERROR = -3
SGetSelectionStageBetInfoFail.CHECK_NPC_SERVICE_ERROR = -4
SGetSelectionStageBetInfoFail.COMMUNICATION_ERROR = 1
SGetSelectionStageBetInfoFail.GET_STAGE_DATA_FAIL = 2
SGetSelectionStageBetInfoFail.GET_STAGE_BET_DATA_FAIL = 3
function SGetSelectionStageBetInfoFail:ctor(res)
  self.id = 12617046
  self.res = res or nil
end
function SGetSelectionStageBetInfoFail:marshal(os)
  os:marshalInt32(self.res)
end
function SGetSelectionStageBetInfoFail:unmarshal(os)
  self.res = os:unmarshalInt32()
end
function SGetSelectionStageBetInfoFail:sizepolicy(size)
  return size <= 65535
end
return SGetSelectionStageBetInfoFail
