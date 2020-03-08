local OctetsStream = require("netio.OctetsStream")
local ChildhoodRet = class("ChildhoodRet")
ChildhoodRet.ERROR_SYSTEM = 1
ChildhoodRet.ERROR_INVALID_STATUS = 2
ChildhoodRet.ERROR_NEVER_CHOOSE_INTEREST = 3
ChildhoodRet.ERROR_LEARN_COURSE_STATUS = 4
ChildhoodRet.ERROR_CFG = 5
ChildhoodRet.ERROR_COST_INVALID = 6
ChildhoodRet.ERROR_YUANBAO_INCONSISTENT = 7
ChildhoodRet.ERROR_HOME_NOT_EXIST = 8
ChildhoodRet.ERROR_HOME_WORLD_NOT_EXIST = 9
ChildhoodRet.ERROR_CHILD_NOT_EXIST = 10
ChildhoodRet.ERROR_CHILD_OWNER = 11
ChildhoodRet.ERROR_USERID = 12
ChildhoodRet.ERROR_NOT_LEARN_COURSE = 13
function ChildhoodRet:ctor()
end
function ChildhoodRet:marshal(os)
end
function ChildhoodRet:unmarshal(os)
end
return ChildhoodRet
