local CGetRecallFriendSignAward = class("CGetRecallFriendSignAward")
CGetRecallFriendSignAward.TYPEID = 12600364
function CGetRecallFriendSignAward:ctor(sign_day)
  self.id = 12600364
  self.sign_day = sign_day or nil
end
function CGetRecallFriendSignAward:marshal(os)
  os:marshalInt32(self.sign_day)
end
function CGetRecallFriendSignAward:unmarshal(os)
  self.sign_day = os:unmarshalInt32()
end
function CGetRecallFriendSignAward:sizepolicy(size)
  return size <= 65535
end
return CGetRecallFriendSignAward
