local OctetsStream = require("netio.OctetsStream")
local InstanceConst = class("InstanceConst")
InstanceConst.OFF = 0
InstanceConst.ON = 1
function InstanceConst:ctor()
end
function InstanceConst:marshal(os)
end
function InstanceConst:unmarshal(os)
end
return InstanceConst
