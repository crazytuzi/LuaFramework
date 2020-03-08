local SGetRecallFriendSignAwardSuccess = class("SGetRecallFriendSignAwardSuccess")
SGetRecallFriendSignAwardSuccess.TYPEID = 12600360
function SGetRecallFriendSignAwardSuccess:ctor(sign_day)
  self.id = 12600360
  self.sign_day = sign_day or nil
end
function SGetRecallFriendSignAwardSuccess:marshal(os)
  os:marshalInt32(self.sign_day)
end
function SGetRecallFriendSignAwardSuccess:unmarshal(os)
  self.sign_day = os:unmarshalInt32()
end
function SGetRecallFriendSignAwardSuccess:sizepolicy(size)
  return size <= 65535
end
return SGetRecallFriendSignAwardSuccess
