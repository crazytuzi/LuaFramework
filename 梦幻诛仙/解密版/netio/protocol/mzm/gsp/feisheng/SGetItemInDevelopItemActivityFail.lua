local SGetItemInDevelopItemActivityFail = class("SGetItemInDevelopItemActivityFail")
SGetItemInDevelopItemActivityFail.TYPEID = 12614161
SGetItemInDevelopItemActivityFail.MODULE_CLOSE_OR_ROLE_FORBIDDEN = -1
SGetItemInDevelopItemActivityFail.ROLE_STATUS_ERROR = -2
SGetItemInDevelopItemActivityFail.PARAM_ERROR = -3
SGetItemInDevelopItemActivityFail.CHECK_NPC_SERVICE_ERROR = -4
SGetItemInDevelopItemActivityFail.SERVER_LEVEL_NOT_ENOUGH = -5
SGetItemInDevelopItemActivityFail.CAN_NOT_JOIN_ACTIVITY = 1
SGetItemInDevelopItemActivityFail.ALREADY_GET_ITEM = 2
SGetItemInDevelopItemActivityFail.BAG_FULL = 3
function SGetItemInDevelopItemActivityFail:ctor(res)
  self.id = 12614161
  self.res = res or nil
end
function SGetItemInDevelopItemActivityFail:marshal(os)
  os:marshalInt32(self.res)
end
function SGetItemInDevelopItemActivityFail:unmarshal(os)
  self.res = os:unmarshalInt32()
end
function SGetItemInDevelopItemActivityFail:sizepolicy(size)
  return size <= 65535
end
return SGetItemInDevelopItemActivityFail
