local OctetsStream = require("netio.OctetsStream")
local QingYuanConst = class("QingYuanConst")
QingYuanConst.NOT_MAKE_QING_YUAN = 0
QingYuanConst.YES_MAKE_QING_YUAN = 1
QingYuanConst.ON_LINE = -1
function QingYuanConst:ctor()
end
function QingYuanConst:marshal(os)
end
function QingYuanConst:unmarshal(os)
end
return QingYuanConst
