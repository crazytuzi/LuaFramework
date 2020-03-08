local FriendInfo = require("netio.protocol.mzm.gsp.friend.FriendInfo")
local SAddNewFriendRes = class("SAddNewFriendRes")
SAddNewFriendRes.TYPEID = 12587022
function SAddNewFriendRes:ctor(friendInfo)
  self.id = 12587022
  self.friendInfo = friendInfo or FriendInfo.new()
end
function SAddNewFriendRes:marshal(os)
  self.friendInfo:marshal(os)
end
function SAddNewFriendRes:unmarshal(os)
  self.friendInfo = FriendInfo.new()
  self.friendInfo:unmarshal(os)
end
function SAddNewFriendRes:sizepolicy(size)
  return size <= 65535
end
return SAddNewFriendRes
