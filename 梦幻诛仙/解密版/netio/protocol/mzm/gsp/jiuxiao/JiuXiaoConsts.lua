local OctetsStream = require("netio.OctetsStream")
local JiuXiaoConsts = class("JiuXiaoConsts")
JiuXiaoConsts.ENTER_JIU_XIAO_MAP_SERVICEID = 150205001
JiuXiaoConsts.ENTER_JIU_XIAO_ROOM_SERVICEID = 150205000
JiuXiaoConsts.JIU_XIAO_WAIT_STAGE = 0
JiuXiaoConsts.JIU_XIAO_ENTER_STAGE = 1
JiuXiaoConsts.JIU_XIAO_TIP_STAGE = 2
function JiuXiaoConsts:ctor()
end
function JiuXiaoConsts:marshal(os)
end
function JiuXiaoConsts:unmarshal(os)
end
return JiuXiaoConsts
