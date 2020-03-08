local SErrorInfo = class("SErrorInfo")
SErrorInfo.TYPEID = 12608772
SErrorInfo.NOT_ACTIVITY_PREPARE_STAGE = 1
SErrorInfo.ROLE_LEVEL_ERROR = 2
SErrorInfo.TEAM_IN_HULA_WORLD = 3
SErrorInfo.ROLE_IN_HULA_WORLD = 4
function SErrorInfo:ctor(errorCode)
  self.id = 12608772
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
