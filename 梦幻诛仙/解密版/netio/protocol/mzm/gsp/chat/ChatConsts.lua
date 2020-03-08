local OctetsStream = require("netio.OctetsStream")
local ChatConsts = class("ChatConsts")
ChatConsts.CHANNEL_NEWER = 1
ChatConsts.CHANNEL_FACTION = 2
ChatConsts.CHANNEL_TEAM = 3
ChatConsts.CHANNEL_CURRENT = 4
ChatConsts.CHANNEL_WORLD = 5
ChatConsts.CHANNEL_ACTIVITY = 6
ChatConsts.CHANNEL_SOMEONE = 7
ChatConsts.CHANNEL_ANCHOR = 8
ChatConsts.CHANNEL_CHAT_ROOM = 9
ChatConsts.CHANNEL_GROUP = 10
ChatConsts.CHANNEL_ALL_GROUP = 11
ChatConsts.CHANNEL_TRUMPRT = 12
ChatConsts.CHANNEL_SINGLE_BATTLE__CAMP = 13
ChatConsts.CHANNEL_FRIEND = 14
ChatConsts.CONTENT_YY = 1
ChatConsts.CONTENT_NORMAL = 2
ChatConsts.CONTENT_NULL = 3
ChatConsts.CONTENT_CHATGIFT = 4
ChatConsts.CONTENT_BULLET = 5
ChatConsts.CONTENT_PACKET_BAG = 1
ChatConsts.CONTENT_PACKET_PET = 2
ChatConsts.CONTENT_PACKET_TASK = 3
ChatConsts.CONTENT_PACKET_WING = 4
ChatConsts.CONTENT_PACKET_MOUNTS = 5
ChatConsts.CONTENT_PACKET_AIRCRAFT = 6
ChatConsts.CHAT__NO_RECIPIENT = 20
ChatConsts.CHAT__SENDER_MUTED = 21
ChatConsts.CHAT__NOT_AT_TIME = 22
ChatConsts.CHAT__LACK_OF_ENERGY = 23
ChatConsts.CHAT__STRANGER_OFFLINE = 24
ChatConsts.CHAT__NOT_OVER_LEVEL = 25
ChatConsts.BANGZHU = 1
ChatConsts.TANGZHU = 2
ChatConsts.DUOZHU = 3
ChatConsts.JINGYING = 4
ChatConsts.BANGZHONG = 5
ChatConsts.TEAMLEADER = 1
ChatConsts.TEAMMEMBER = 2
ChatConsts.CFG__AUTOPLAYVOICE_MAP = 1
ChatConsts.CFG__AUTOPLAYVOICE_WORLD = 2
ChatConsts.CFG__AUTOPLAYVOICE_TEAM = 3
ChatConsts.CFG__AUTOPLAYVOICE_GANG = 4
ChatConsts.CFG__SHIELDMESSAGE_MAP = 5
ChatConsts.CFG__SHIELDMESSAGE_WORLD = 6
ChatConsts.CFG__SHIELDMESSAGE_TEAM = 7
ChatConsts.CFG__SHIELDMESSAGE_GANG = 8
function ChatConsts:ctor()
end
function ChatConsts:marshal(os)
end
function ChatConsts:unmarshal(os)
end
return ChatConsts
