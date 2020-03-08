local OctetsStream = require("netio.OctetsStream")
local ShiTuConst = class("ShiTuConst")
ShiTuConst.REFUSE_SHOUTU = 0
ShiTuConst.AGREE_SHOUTU = 1
ShiTuConst.OFF_LINE = 0
ShiTuConst.ON_LINE = 1
ShiTuConst.MASTER = 0
ShiTuConst.APPRENTICE = 1
ShiTuConst.FAIL = 0
ShiTuConst.SUCCESS = 1
ShiTuConst.NO_CHU_SHI = 0
ShiTuConst.YES_CHU_SHI = 1
ShiTuConst.NO_PAY_RESPECT = 0
ShiTuConst.YES_PAY_RESPECT = 1
ShiTuConst.PAY_RESPECT_TIME_OUT = 2
ShiTuConst.REFUSE_RECOMMEND = 0
ShiTuConst.AGREE_RECOMMEND = 1
function ShiTuConst:ctor()
end
function ShiTuConst:marshal(os)
end
function ShiTuConst:unmarshal(os)
end
return ShiTuConst
