local CGetRecallFriendSignAwardInfo = class("CGetRecallFriendSignAwardInfo")
CGetRecallFriendSignAwardInfo.TYPEID = 12600359
function CGetRecallFriendSignAwardInfo:ctor()
  self.id = 12600359
end
function CGetRecallFriendSignAwardInfo:marshal(os)
end
function CGetRecallFriendSignAwardInfo:unmarshal(os)
end
function CGetRecallFriendSignAwardInfo:sizepolicy(size)
  return size <= 65535
end
return CGetRecallFriendSignAwardInfo
