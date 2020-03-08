local OctetsStream = require("netio.OctetsStream")
local GrowConsts = class("GrowConsts")
GrowConsts.ST_ON_GOING = 1
GrowConsts.ST_FINISHED = 2
GrowConsts.ST_HAND_UP = 3
function GrowConsts:ctor()
end
function GrowConsts:marshal(os)
end
function GrowConsts:unmarshal(os)
end
return GrowConsts
