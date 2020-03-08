local OctetsStream = require("netio.OctetsStream")
local MarriageConsts = class("MarriageConsts")
MarriageConsts.CANCEL_MARRIAGE = 0
MarriageConsts.AGREE_MARRIAGE = 1
MarriageConsts.REFUSE_DIVORCE = 0
MarriageConsts.AGREE_DIVROCE = 1
MarriageConsts.BRIDE = 0
MarriageConsts.GROOM = 1
MarriageConsts.NOT_ATTACKED = 0
MarriageConsts.ATTACKED = 1
function MarriageConsts:ctor()
end
function MarriageConsts:marshal(os)
end
function MarriageConsts:unmarshal(os)
end
return MarriageConsts
