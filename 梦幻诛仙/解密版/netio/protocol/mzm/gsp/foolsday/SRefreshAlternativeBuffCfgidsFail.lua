local SRefreshAlternativeBuffCfgidsFail = class("SRefreshAlternativeBuffCfgidsFail")
SRefreshAlternativeBuffCfgidsFail.TYPEID = 12612875
SRefreshAlternativeBuffCfgidsFail.MODULE_CLOSE_OR_ROLE_FORBIDDEN = -1
SRefreshAlternativeBuffCfgidsFail.ROLE_STATUS_ERROR = -2
SRefreshAlternativeBuffCfgidsFail.PARAM_ERROR = -3
SRefreshAlternativeBuffCfgidsFail.DB_ERROR = -4
SRefreshAlternativeBuffCfgidsFail.CAN_NOT_JOIN_ACTIVITY = 1
SRefreshAlternativeBuffCfgidsFail.REFRESH_TIME_TO_LIMIT = 2
function SRefreshAlternativeBuffCfgidsFail:ctor(res)
  self.id = 12612875
  self.res = res or nil
end
function SRefreshAlternativeBuffCfgidsFail:marshal(os)
  os:marshalInt32(self.res)
end
function SRefreshAlternativeBuffCfgidsFail:unmarshal(os)
  self.res = os:unmarshalInt32()
end
function SRefreshAlternativeBuffCfgidsFail:sizepolicy(size)
  return size <= 65535
end
return SRefreshAlternativeBuffCfgidsFail
