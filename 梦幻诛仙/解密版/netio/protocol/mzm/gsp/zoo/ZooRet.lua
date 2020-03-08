local OctetsStream = require("netio.OctetsStream")
local ZooRet = class("ZooRet")
ZooRet.ERROR_SYSTEM = 1
ZooRet.ERROR_USERID = 2
ZooRet.ERROR_CFG = 3
ZooRet.ERROR_HOME_LAND_NOT_EXIST = 4
ZooRet.ERROR_WOLRD_ID_NOT_EXIST = 5
ZooRet.ERROR_FUN_NOT_OPEN = 6
ZooRet.ERROR_ANIMAL_NOT_EXIST = 7
ZooRet.ERROR_ANIMAL_STAGE = 8
function ZooRet:ctor()
end
function ZooRet:marshal(os)
end
function ZooRet:unmarshal(os)
end
return ZooRet
