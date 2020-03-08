local OctetsStream = require("netio.OctetsStream")
local BlessRet = class("BlessRet")
BlessRet.ERROR_SYSTEM = 1
BlessRet.ERROR_USERID = 2
BlessRet.ERROR_CFG = 3
BlessRet.ERROR_REMOVE_ITEM = 4
function BlessRet:ctor()
end
function BlessRet:marshal(os)
end
function BlessRet:unmarshal(os)
end
return BlessRet
