local OctetsStream = require("netio.OctetsStream")
local VoipRoomAction = class("VoipRoomAction")
VoipRoomAction.ACTION_JOIN = 1
VoipRoomAction.ACTION_EXIT = 2
function VoipRoomAction:ctor()
end
function VoipRoomAction:marshal(os)
end
function VoipRoomAction:unmarshal(os)
end
return VoipRoomAction
