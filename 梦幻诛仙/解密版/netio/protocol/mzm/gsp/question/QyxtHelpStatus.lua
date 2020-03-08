local OctetsStream = require("netio.OctetsStream")
local QyxtHelpStatus = class("QyxtHelpStatus")
QyxtHelpStatus.NOT_IN_HELP = 0
QyxtHelpStatus.YES_IN_HELP = 1
function QyxtHelpStatus:ctor()
end
function QyxtHelpStatus:marshal(os)
end
function QyxtHelpStatus:unmarshal(os)
end
return QyxtHelpStatus
