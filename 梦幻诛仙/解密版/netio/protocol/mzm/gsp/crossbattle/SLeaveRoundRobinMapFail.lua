local SLeaveRoundRobinMapFail = class("SLeaveRoundRobinMapFail")
SLeaveRoundRobinMapFail.TYPEID = 12616972
SLeaveRoundRobinMapFail.MODULE_CLOSE_OR_ROLE_FORBIDDEN = -1
SLeaveRoundRobinMapFail.ROLE_STATUS_ERROR = -2
SLeaveRoundRobinMapFail.PARAM_ERROR = -3
SLeaveRoundRobinMapFail.CHECK_NPC_SERVICE_ERROR = -4
function SLeaveRoundRobinMapFail:ctor(res)
  self.id = 12616972
  self.res = res or nil
end
function SLeaveRoundRobinMapFail:marshal(os)
  os:marshalInt32(self.res)
end
function SLeaveRoundRobinMapFail:unmarshal(os)
  self.res = os:unmarshalInt32()
end
function SLeaveRoundRobinMapFail:sizepolicy(size)
  return size <= 65535
end
return SLeaveRoundRobinMapFail
