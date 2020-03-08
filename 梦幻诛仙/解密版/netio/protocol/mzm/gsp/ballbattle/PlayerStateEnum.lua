local OctetsStream = require("netio.OctetsStream")
local PlayerStateEnum = class("PlayerStateEnum")
PlayerStateEnum.TEMP_DEATH = -2
PlayerStateEnum.DEATH = -1
PlayerStateEnum.PROTECT = 0
PlayerStateEnum.BUFF_SPEED = 1
PlayerStateEnum.BUFF_FREEZE = 2
PlayerStateEnum.BUFF_SHADOW = 3
PlayerStateEnum.BUFF_GHOST = 4
PlayerStateEnum.MAX_LEVEL = 5
function PlayerStateEnum:ctor()
end
function PlayerStateEnum:marshal(os)
end
function PlayerStateEnum:unmarshal(os)
end
return PlayerStateEnum
