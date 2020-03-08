local OctetsStream = require("netio.OctetsStream")
local SSPReqType = class("SSPReqType")
SSPReqType.REQ_REPORT_ROLE_BASE_INFO = 1
SSPReqType.REQ_UPDATE_SPACE_STYLE = 2
SSPReqType.REQ_TREAD_SPACE = 3
SSPReqType.REQ_PLACE_TREASURE = 4
SSPReqType.REQ_GIVE_GIFT = 5
SSPReqType.REQ_UPDATE_FRIENDS = 7
SSPReqType.REQ_UPDATE_BLACK_LIST = 9
SSPReqType.REQ_UPDATE_ROLE_IMPORTANT_INFO = 12
function SSPReqType:ctor()
end
function SSPReqType:marshal(os)
end
function SSPReqType:unmarshal(os)
end
return SSPReqType
