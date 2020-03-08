local SGetFoolsDayInfoFail = class("SGetFoolsDayInfoFail")
SGetFoolsDayInfoFail.TYPEID = 12612865
SGetFoolsDayInfoFail.MODULE_CLOSE_OR_ROLE_FORBIDDEN = -1
SGetFoolsDayInfoFail.ROLE_STATUS_ERROR = -2
SGetFoolsDayInfoFail.PARAM_ERROR = -3
SGetFoolsDayInfoFail.DB_ERROR = -4
SGetFoolsDayInfoFail.CAN_NOT_JOIN_ACTIVITY = 1
function SGetFoolsDayInfoFail:ctor(res)
  self.id = 12612865
  self.res = res or nil
end
function SGetFoolsDayInfoFail:marshal(os)
  os:marshalInt32(self.res)
end
function SGetFoolsDayInfoFail:unmarshal(os)
  self.res = os:unmarshalInt32()
end
function SGetFoolsDayInfoFail:sizepolicy(size)
  return size <= 65535
end
return SGetFoolsDayInfoFail
