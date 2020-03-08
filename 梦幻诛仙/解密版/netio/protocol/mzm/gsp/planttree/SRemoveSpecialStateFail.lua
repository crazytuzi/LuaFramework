local SRemoveSpecialStateFail = class("SRemoveSpecialStateFail")
SRemoveSpecialStateFail.TYPEID = 12611598
SRemoveSpecialStateFail.MODULE_CLOSE_OR_ROLE_FORBIDDEN = -1
SRemoveSpecialStateFail.ROLE_STATUS_ERROR = -2
SRemoveSpecialStateFail.PARAM_ERROR = -3
SRemoveSpecialStateFail.DB_ERROR = -4
SRemoveSpecialStateFail.CAN_NOT_JOIN_ACTIVITY = 1
SRemoveSpecialStateFail.RELATIONSHIP_ERROR = 2
SRemoveSpecialStateFail.NOT_IN_THIS_SPECIAL_STATE = 3
SRemoveSpecialStateFail.AWARD_FAIL = 4
function SRemoveSpecialStateFail:ctor(res)
  self.id = 12611598
  self.res = res or nil
end
function SRemoveSpecialStateFail:marshal(os)
  os:marshalInt32(self.res)
end
function SRemoveSpecialStateFail:unmarshal(os)
  self.res = os:unmarshalInt32()
end
function SRemoveSpecialStateFail:sizepolicy(size)
  return size <= 65535
end
return SRemoveSpecialStateFail
