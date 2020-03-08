local SDevelopItemInDevelopItemActivityFail = class("SDevelopItemInDevelopItemActivityFail")
SDevelopItemInDevelopItemActivityFail.TYPEID = 12614173
SDevelopItemInDevelopItemActivityFail.MODULE_CLOSE_OR_ROLE_FORBIDDEN = -1
SDevelopItemInDevelopItemActivityFail.ROLE_STATUS_ERROR = -2
SDevelopItemInDevelopItemActivityFail.PARAM_ERROR = -3
SDevelopItemInDevelopItemActivityFail.CHECK_NPC_SERVICE_ERROR = -4
SDevelopItemInDevelopItemActivityFail.SERVER_LEVEL_NOT_ENOUGH = -5
SDevelopItemInDevelopItemActivityFail.CAN_NOT_JOIN_ACTIVITY = 1
SDevelopItemInDevelopItemActivityFail.EXTRA_VALUE_TO_LIMIT = 2
SDevelopItemInDevelopItemActivityFail.COST_FAIL = 3
function SDevelopItemInDevelopItemActivityFail:ctor(res)
  self.id = 12614173
  self.res = res or nil
end
function SDevelopItemInDevelopItemActivityFail:marshal(os)
  os:marshalInt32(self.res)
end
function SDevelopItemInDevelopItemActivityFail:unmarshal(os)
  self.res = os:unmarshalInt32()
end
function SDevelopItemInDevelopItemActivityFail:sizepolicy(size)
  return size <= 65535
end
return SDevelopItemInDevelopItemActivityFail
