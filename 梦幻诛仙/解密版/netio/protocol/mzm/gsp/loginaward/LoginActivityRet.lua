local OctetsStream = require("netio.OctetsStream")
local LoginActivityRet = class("LoginActivityRet")
LoginActivityRet.ERROR_ACTIVITY_CFG_NOT_EXIST = 1
LoginActivityRet.ERROR_ACTIVITY_AWARD_CFG_NOT_EXIST = 2
LoginActivityRet.ERROR_AWARD_FAILED = 3
LoginActivityRet.ERROR_SYSTEM = 4
LoginActivityRet.ERROR_BEGINNER_LOGIN_SIGN_CFG = 5
function LoginActivityRet:ctor()
end
function LoginActivityRet:marshal(os)
end
function LoginActivityRet:unmarshal(os)
end
return LoginActivityRet
