local OctetsStream = require("netio.OctetsStream")
local MapGroupType = class("MapGroupType")
MapGroupType.MGT_TEAM = 0
MapGroupType.MGT_COUPLE_FLY = 1
MapGroupType.MGT_MARRIAGE = 2
MapGroupType.MGT_WATCH_MOON_XYXW_FLY = 3
MapGroupType.MGT_WATCH_MOON_SIDE_BY_SIDE_FLY = 4
MapGroupType.MGT_GROUP_WEDDING = 5
function MapGroupType:ctor()
end
function MapGroupType:marshal(os)
end
function MapGroupType:unmarshal(os)
end
return MapGroupType
