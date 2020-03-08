local CGetRecallFriendsBigGiftAward = class("CGetRecallFriendsBigGiftAward")
CGetRecallFriendsBigGiftAward.TYPEID = 12600363
function CGetRecallFriendsBigGiftAward:ctor()
  self.id = 12600363
end
function CGetRecallFriendsBigGiftAward:marshal(os)
end
function CGetRecallFriendsBigGiftAward:unmarshal(os)
end
function CGetRecallFriendsBigGiftAward:sizepolicy(size)
  return size <= 65535
end
return CGetRecallFriendsBigGiftAward
