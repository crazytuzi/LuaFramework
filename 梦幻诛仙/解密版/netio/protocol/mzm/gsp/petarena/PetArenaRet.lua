local OctetsStream = require("netio.OctetsStream")
local PetArenaRet = class("PetArenaRet")
PetArenaRet.ERROR_SYSTEM = 1
PetArenaRet.ERROR_USERID = 2
PetArenaRet.ERROR_CFG = 3
PetArenaRet.ERROR_SWITCH = 4
PetArenaRet.ERROR_STATUS = 5
PetArenaRet.ERROR_TARGET = 6
PetArenaRet.ERROR_DEFEND_EMPTY = 7
PetArenaRet.ERROR_ROBOT_DEFEND_EMPTY = 8
function PetArenaRet:ctor()
end
function PetArenaRet:marshal(os)
end
function PetArenaRet:unmarshal(os)
end
return PetArenaRet
