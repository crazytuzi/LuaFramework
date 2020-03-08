local OctetsStream = require("netio.OctetsStream")
local CatRet = class("CatRet")
CatRet.ERROR_SYSTEM = 1
CatRet.ERROR_INVALID_PARAM = 2
CatRet.ERROR_GET_FEED_AWARD = 3
CatRet.ERROR_CAT_NOT_EXIST = 4
CatRet.ERROR_CAT_STATE = 5
CatRet.ERROR_HOME_LAND_NOT_EXIST = 6
CatRet.ERROR_GET_EXPLORE_AWARD_FAILED = 7
CatRet.ERROR_ADD_CAT_ITEM = 8
CatRet.ERROR_REMOVE_CAT_ITEM = 9
CatRet.ERROR_HOME_LAND_CAT_MAX = 10
CatRet.ERROR_WOLRD_ID_NOT_EXIST = 11
CatRet.ERROR_FUN_NOT_OPEN = 12
CatRet.ERROR_CHANGE_PARTNER_COST_INVALID = 13
CatRet.ERROR_LEVEL_TO_CAT_CFG = 14
CatRet.ERROR_CAT_LEVEL_CFG = 15
function CatRet:ctor()
end
function CatRet:marshal(os)
end
function CatRet:unmarshal(os)
end
return CatRet
