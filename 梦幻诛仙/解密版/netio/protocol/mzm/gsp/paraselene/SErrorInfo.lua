local SErrorInfo = class("SErrorInfo")
SErrorInfo.TYPEID = 12598274
SErrorInfo.TEAM_NUM_NOT_ENOUGH = 1
SErrorInfo.PASSED_ACTIVITY = 2
SErrorInfo.ROLE_LEVLE_ERROR = 3
SErrorInfo.ACTIVITY_NOT_OPEN = 4
SErrorInfo.PASSED_LAYER = 5
function SErrorInfo:ctor(errorCode)
  self.id = 12598274
  self.errorCode = errorCode or nil
end
function SErrorInfo:marshal(os)
  os:marshalInt32(self.errorCode)
end
function SErrorInfo:unmarshal(os)
  self.errorCode = os:unmarshalInt32()
end
function SErrorInfo:sizepolicy(size)
  return size <= 65535
end
return SErrorInfo
