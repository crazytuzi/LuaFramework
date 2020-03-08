local OctetsStream = require("netio.OctetsStream")
local CakeConsts = class("CakeConsts")
CakeConsts.STAGE_PREPARE = 1
CakeConsts.STAGE_COLLECTION = 2
CakeConsts.STAGE_MAKE_CAKE = 3
function CakeConsts:ctor()
end
function CakeConsts:marshal(os)
end
function CakeConsts:unmarshal(os)
end
return CakeConsts
