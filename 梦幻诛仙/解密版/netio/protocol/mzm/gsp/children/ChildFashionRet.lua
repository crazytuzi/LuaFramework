local OctetsStream = require("netio.OctetsStream")
local ChildFashionRet = class("ChildFashionRet")
ChildFashionRet.ERROR_SYSTEM = 1
ChildFashionRet.ERROR_CFG = 2
ChildFashionRet.ERROR_FAHION_EXIST = 3
ChildFashionRet.ERROR_USERID = 4
ChildFashionRet.ERROR_CHILD_NOT_EXIST = 5
ChildFashionRet.ERROR_CHILD_OWNER = 6
ChildFashionRet.ERROR_FASHION_NOT_HAVE = 7
ChildFashionRet.ERROR_PHASE = 8
ChildFashionRet.ERROR_DRESSED_FASHION = 9
ChildFashionRet.ERROR_NOT_WEAR_FASHION = 10
ChildFashionRet.ERROR_DRESSED_FASHION_NOT_MATCH = 11
ChildFashionRet.ERROR_CHILD_FASHION_GENDER_NOT_MATCH = 12
function ChildFashionRet:ctor()
end
function ChildFashionRet:marshal(os)
end
function ChildFashionRet:unmarshal(os)
end
return ChildFashionRet
