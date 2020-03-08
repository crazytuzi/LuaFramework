local OctetsStream = require("netio.OctetsStream")
local FriendConsts = class("FriendConsts")
FriendConsts.STATUS_ONLINE = 1
FriendConsts.STATUS_OFFLINE = 2
function FriendConsts:ctor()
end
function FriendConsts:marshal(os)
end
function FriendConsts:unmarshal(os)
end
return FriendConsts
