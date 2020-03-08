local SErrorInfo = class("SErrorInfo")
SErrorInfo.TYPEID = 12595726
SErrorInfo.CHANLLENGE_COUNT_NOT_ENOUGH = 1
SErrorInfo.YUANBAO_NOT_ENOUGH = 2
SErrorInfo.FIRST_VICTORY_ERROR = 3
SErrorInfo.FIVE_FIGHT_ERROR = 4
SErrorInfo.SEASON_AWARD_ERROR = 5
SErrorInfo.ROLE_LEVLE_ERROR = 6
SErrorInfo.ROLE_IN_TEAM = 7
SErrorInfo.FRESH_ERROR = 8
function SErrorInfo:ctor(errorCode)
  self.id = 12595726
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
