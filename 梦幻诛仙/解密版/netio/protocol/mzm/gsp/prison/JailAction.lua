local OctetsStream = require("netio.OctetsStream")
local JailAction = class("JailAction")
JailAction.IN_JAIL = 1
JailAction.JAIL_BREAK = 2
JailAction.JAIL_DELIVERY = 3
JailAction.OFF_LINE = 4
JailAction.OUT_JAIL = 5
JailAction.MONEY_NOT_ENOUGH = 6
function JailAction:ctor()
end
function JailAction:marshal(os)
end
function JailAction:unmarshal(os)
end
return JailAction
