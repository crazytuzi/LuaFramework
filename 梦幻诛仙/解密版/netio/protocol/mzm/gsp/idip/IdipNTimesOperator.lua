local OctetsStream = require("netio.OctetsStream")
local IdipNTimesOperator = class("IdipNTimesOperator")
IdipNTimesOperator.UN_INSTALL_BUFF = 0
IdipNTimesOperator.INSTALL_BUFF = 1
function IdipNTimesOperator:ctor()
end
function IdipNTimesOperator:marshal(os)
end
function IdipNTimesOperator:unmarshal(os)
end
return IdipNTimesOperator
