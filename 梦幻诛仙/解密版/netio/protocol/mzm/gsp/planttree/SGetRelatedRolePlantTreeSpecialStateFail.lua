local SGetRelatedRolePlantTreeSpecialStateFail = class("SGetRelatedRolePlantTreeSpecialStateFail")
SGetRelatedRolePlantTreeSpecialStateFail.TYPEID = 12611605
SGetRelatedRolePlantTreeSpecialStateFail.MODULE_CLOSE_OR_ROLE_FORBIDDEN = -1
SGetRelatedRolePlantTreeSpecialStateFail.ROLE_STATUS_ERROR = -2
SGetRelatedRolePlantTreeSpecialStateFail.PARAM_ERROR = -3
SGetRelatedRolePlantTreeSpecialStateFail.DB_ERROR = -4
SGetRelatedRolePlantTreeSpecialStateFail.CAN_NOT_JOIN_ACTIVITY = 1
function SGetRelatedRolePlantTreeSpecialStateFail:ctor(res)
  self.id = 12611605
  self.res = res or nil
end
function SGetRelatedRolePlantTreeSpecialStateFail:marshal(os)
  os:marshalInt32(self.res)
end
function SGetRelatedRolePlantTreeSpecialStateFail:unmarshal(os)
  self.res = os:unmarshalInt32()
end
function SGetRelatedRolePlantTreeSpecialStateFail:sizepolicy(size)
  return size <= 65535
end
return SGetRelatedRolePlantTreeSpecialStateFail
