local SGetSectionCompleteAwardFail = class("SGetSectionCompleteAwardFail")
SGetSectionCompleteAwardFail.TYPEID = 12611595
SGetSectionCompleteAwardFail.MODULE_CLOSE_OR_ROLE_FORBIDDEN = -1
SGetSectionCompleteAwardFail.ROLE_STATUS_ERROR = -2
SGetSectionCompleteAwardFail.PARAM_ERROR = -3
SGetSectionCompleteAwardFail.DB_ERROR = -4
SGetSectionCompleteAwardFail.CAN_NOT_JOIN_ACTIVITY = 1
SGetSectionCompleteAwardFail.ALREADY_GET_AWARD = 2
SGetSectionCompleteAwardFail.SECTION_NOT_COMPLETE = 3
SGetSectionCompleteAwardFail.AWARD_FAIL = 4
function SGetSectionCompleteAwardFail:ctor(res)
  self.id = 12611595
  self.res = res or nil
end
function SGetSectionCompleteAwardFail:marshal(os)
  os:marshalInt32(self.res)
end
function SGetSectionCompleteAwardFail:unmarshal(os)
  self.res = os:unmarshalInt32()
end
function SGetSectionCompleteAwardFail:sizepolicy(size)
  return size <= 65535
end
return SGetSectionCompleteAwardFail
