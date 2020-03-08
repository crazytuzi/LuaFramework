local OctetsStream = require("netio.OctetsStream")
local VoipRoomType = class("VoipRoomType")
VoipRoomType.TYPE_TEAM = 1
function VoipRoomType:ctor()
end
function VoipRoomType:marshal(os)
end
function VoipRoomType:unmarshal(os)
end
return VoipRoomType
