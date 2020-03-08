local OctetsStream = require("netio.OctetsStream")
local MountsConst = class("MountsConst")
MountsConst.NO_RIDE = 0
MountsConst.MAIN_BATTLE_MOUNT_CELL = 1
MountsConst.NO_REFRESH_PASSIVE_SKILL = 0
MountsConst.NO_USE_YUAN_BAO = 0
MountsConst.YES_USE_YUAN_BAO = 1
MountsConst.TIME_FOREVER = -1
MountsConst.NO_CHIEF_BATTLE_MOUNTS = 0
MountsConst.YES_CHIEF_BATTLE_MOUNTS = 1
MountsConst.NO_STAR_NUM_ACTIVE = 0
MountsConst.COLOR_CHANGE = 0
MountsConst.MODEL_CHANGE = 1
MountsConst.CHIP_TYPE = 0
MountsConst.ITEM_TYPE = 1
MountsConst.NO_USE_ALL = 0
MountsConst.YES_UES_ALL = 1
function MountsConst:ctor()
end
function MountsConst:marshal(os)
end
function MountsConst:unmarshal(os)
end
return MountsConst
