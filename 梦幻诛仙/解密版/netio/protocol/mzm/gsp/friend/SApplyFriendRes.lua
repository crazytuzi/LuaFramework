local StrangerInfo = require("netio.protocol.mzm.gsp.friend.StrangerInfo")
local SApplyFriendRes = class("SApplyFriendRes")
SApplyFriendRes.TYPEID = 12587017
function SApplyFriendRes:ctor(strangerInfo)
  self.id = 12587017
  self.strangerInfo = strangerInfo or StrangerInfo.new()
end
function SApplyFriendRes:marshal(os)
  self.strangerInfo:marshal(os)
end
function SApplyFriendRes:unmarshal(os)
  self.strangerInfo = StrangerInfo.new()
  self.strangerInfo:unmarshal(os)
end
function SApplyFriendRes:sizepolicy(size)
  return size <= 65535
end
return SApplyFriendRes
