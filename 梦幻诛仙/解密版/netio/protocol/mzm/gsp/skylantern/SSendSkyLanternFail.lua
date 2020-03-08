local SSendSkyLanternFail = class("SSendSkyLanternFail")
SSendSkyLanternFail.TYPEID = 12624130
SSendSkyLanternFail.ERROR_SYSTEM = 1
SSendSkyLanternFail.ERROR_USERID = 2
SSendSkyLanternFail.ERROR_CFG = 3
SSendSkyLanternFail.ERROR_PARAM = 4
SSendSkyLanternFail.ERROR_NOT_IN_SEND_POSITION = 5
SSendSkyLanternFail.ERROR_CAN_NOT_JOIN_ACTIVITY = 6
SSendSkyLanternFail.ERROR_WRONG_TYPE = 7
SSendSkyLanternFail.ERROR_WRONG_CHANNEL = 8
SSendSkyLanternFail.ERROR_NOT_IN_GANG = 9
function SSendSkyLanternFail:ctor(activity_id, error_code)
  self.id = 12624130
  self.activity_id = activity_id or nil
  self.error_code = error_code or nil
end
function SSendSkyLanternFail:marshal(os)
  os:marshalInt32(self.activity_id)
  os:marshalInt32(self.error_code)
end
function SSendSkyLanternFail:unmarshal(os)
  self.activity_id = os:unmarshalInt32()
  self.error_code = os:unmarshalInt32()
end
function SSendSkyLanternFail:sizepolicy(size)
  return size <= 65535
end
return SSendSkyLanternFail
