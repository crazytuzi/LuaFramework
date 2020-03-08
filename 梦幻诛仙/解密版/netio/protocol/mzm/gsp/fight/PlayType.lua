local OctetsStream = require("netio.OctetsStream")
local PlayType = class("PlayType")
PlayType.PLAY_SKILL = 0
PlayType.PLAY_CAPTURE = 1
PlayType.PLAY_SUMMON = 2
PlayType.PLAY_ESCAPE = 3
PlayType.PLAY_TALK = 4
PlayType.PLAY_TIP = 5
PlayType.PLAY_USEITEM = 6
PlayType.PLAY_CHANGE_FIGHT_MAP = 7
PlayType.PLAY_FIGHTER_STATUS = 8
PlayType.PLAY_CHANGE_FIGHTER = 9
PlayType.PLAY_CHANGE_MODEL = 10
function PlayType:ctor()
end
function PlayType:marshal(os)
end
function PlayType:unmarshal(os)
end
return PlayType
