local SGetBackGameAwardFail = class("SGetBackGameAwardFail")
SGetBackGameAwardFail.TYPEID = 12620549
SGetBackGameAwardFail.NOT_IN_BACK_GAME_ACTIVITY = -1
SGetBackGameAwardFail.ALREADY_GET_BACK_GAME_AWARD = -2
SGetBackGameAwardFail.REQUEST_ID_WRONG = -3
SGetBackGameAwardFail.OFFER_AWARD_FAIL = -4
function SGetBackGameAwardFail:ctor(error_code)
  self.id = 12620549
  self.error_code = error_code or nil
end
function SGetBackGameAwardFail:marshal(os)
  os:marshalInt32(self.error_code)
end
function SGetBackGameAwardFail:unmarshal(os)
  self.error_code = os:unmarshalInt32()
end
function SGetBackGameAwardFail:sizepolicy(size)
  return size <= 65535
end
return SGetBackGameAwardFail
