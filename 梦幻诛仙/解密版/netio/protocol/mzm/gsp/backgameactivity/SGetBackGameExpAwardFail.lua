local SGetBackGameExpAwardFail = class("SGetBackGameExpAwardFail")
SGetBackGameExpAwardFail.TYPEID = 12620557
SGetBackGameExpAwardFail.NOT_IN_BACK_GAME_ACTIVITY = -1
SGetBackGameExpAwardFail.LOGIN_DAY_NOT_ENOUGH = -2
SGetBackGameExpAwardFail.AWARD_ALREADY_GET = -3
SGetBackGameExpAwardFail.AWARD_CFG_NOT_EXIST = -4
SGetBackGameExpAwardFail.OFFER_AWARD_FAIL = -5
function SGetBackGameExpAwardFail:ctor(error_code)
  self.id = 12620557
  self.error_code = error_code or nil
end
function SGetBackGameExpAwardFail:marshal(os)
  os:marshalInt32(self.error_code)
end
function SGetBackGameExpAwardFail:unmarshal(os)
  self.error_code = os:unmarshalInt32()
end
function SGetBackGameExpAwardFail:sizepolicy(size)
  return size <= 65535
end
return SGetBackGameExpAwardFail
