local SBackGameSignFail = class("SBackGameSignFail")
SBackGameSignFail.TYPEID = 12620547
SBackGameSignFail.NOT_IN_BACK_GAME_ACTIVITY = -1
SBackGameSignFail.ALREADY_SIGN = -2
SBackGameSignFail.REQUEST_INDEX_WRONG = -3
SBackGameSignFail.OFFER_AWARD_FAIL = -4
function SBackGameSignFail:ctor(error_code)
  self.id = 12620547
  self.error_code = error_code or nil
end
function SBackGameSignFail:marshal(os)
  os:marshalInt32(self.error_code)
end
function SBackGameSignFail:unmarshal(os)
  self.error_code = os:unmarshalInt32()
end
function SBackGameSignFail:sizepolicy(size)
  return size <= 65535
end
return SBackGameSignFail
