local SErrorInfo = class("SErrorInfo")
SErrorInfo.TYPEID = 12598022
SErrorInfo.CHANLLENGE_COUNT_NOT_ENOUGH = 1
SErrorInfo.YUANBAO_NOT_ENOUGH = 2
SErrorInfo.ROLE_LEVLE_ERROR = 3
SErrorInfo.ROLE_IN_TEAM = 4
SErrorInfo.ACTIVITY_NOT_OPEN = 5
SErrorInfo.BUY_COUNT_TO_MAX = 6
SErrorInfo.ACTIVITY_FINISHED = 7
SErrorInfo.CHANLLENGE_COUNT_ERROR = 8
function SErrorInfo:ctor(errorCode)
  self.id = 12598022
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
