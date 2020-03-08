local OctetsStream = require("netio.OctetsStream")
local MassWeddingConst = class("MassWeddingConst")
MassWeddingConst.STAGE_SIGN_UP = 0
MassWeddingConst.STAGE_MARRY = 1
MassWeddingConst.STAGE_ROB_MARRIAGE = 2
MassWeddingConst.STAGE_LOVE = 3
function MassWeddingConst:ctor()
end
function MassWeddingConst:marshal(os)
end
function MassWeddingConst:unmarshal(os)
end
return MassWeddingConst
