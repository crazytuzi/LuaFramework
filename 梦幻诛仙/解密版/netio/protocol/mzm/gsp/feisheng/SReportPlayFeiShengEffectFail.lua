local SReportPlayFeiShengEffectFail = class("SReportPlayFeiShengEffectFail")
SReportPlayFeiShengEffectFail.TYPEID = 12614181
SReportPlayFeiShengEffectFail.MODULE_CLOSE_OR_ROLE_FORBIDDEN = -1
SReportPlayFeiShengEffectFail.ROLE_STATUS_ERROR = -2
SReportPlayFeiShengEffectFail.PARAM_ERROR = -3
SReportPlayFeiShengEffectFail.CHECK_NPC_SERVICE_ERROR = -4
SReportPlayFeiShengEffectFail.SERVER_LEVEL_NOT_ENOUGH = -5
SReportPlayFeiShengEffectFail.DB_ERROR = -6
SReportPlayFeiShengEffectFail.CAN_NOT_JOIN_ACTIVITY = 1
SReportPlayFeiShengEffectFail.ACTIVITY_NOT_COMPLETE = 2
SReportPlayFeiShengEffectFail.ALREADY_REPORT = 3
function SReportPlayFeiShengEffectFail:ctor(activity_cfg_id, res)
  self.id = 12614181
  self.activity_cfg_id = activity_cfg_id or nil
  self.res = res or nil
end
function SReportPlayFeiShengEffectFail:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
  os:marshalInt32(self.res)
end
function SReportPlayFeiShengEffectFail:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
  self.res = os:unmarshalInt32()
end
function SReportPlayFeiShengEffectFail:sizepolicy(size)
  return size <= 65535
end
return SReportPlayFeiShengEffectFail
