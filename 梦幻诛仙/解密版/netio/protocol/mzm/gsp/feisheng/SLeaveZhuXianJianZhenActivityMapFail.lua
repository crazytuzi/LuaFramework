local SLeaveZhuXianJianZhenActivityMapFail = class("SLeaveZhuXianJianZhenActivityMapFail")
SLeaveZhuXianJianZhenActivityMapFail.TYPEID = 12614177
SLeaveZhuXianJianZhenActivityMapFail.MODULE_CLOSE_OR_ROLE_FORBIDDEN = -1
SLeaveZhuXianJianZhenActivityMapFail.ROLE_STATUS_ERROR = -2
SLeaveZhuXianJianZhenActivityMapFail.PARAM_ERROR = -3
SLeaveZhuXianJianZhenActivityMapFail.CHECK_NPC_SERVICE_ERROR = -4
SLeaveZhuXianJianZhenActivityMapFail.SERVER_LEVEL_NOT_ENOUGH = -5
SLeaveZhuXianJianZhenActivityMapFail.DB_ERROR = -6
SLeaveZhuXianJianZhenActivityMapFail.CAN_NOT_JOIN_ACTIVITY = 1
SLeaveZhuXianJianZhenActivityMapFail.ACTIVITY_STAGE_ERROR = 2
function SLeaveZhuXianJianZhenActivityMapFail:ctor(res)
  self.id = 12614177
  self.res = res or nil
end
function SLeaveZhuXianJianZhenActivityMapFail:marshal(os)
  os:marshalInt32(self.res)
end
function SLeaveZhuXianJianZhenActivityMapFail:unmarshal(os)
  self.res = os:unmarshalInt32()
end
function SLeaveZhuXianJianZhenActivityMapFail:sizepolicy(size)
  return size <= 65535
end
return SLeaveZhuXianJianZhenActivityMapFail
