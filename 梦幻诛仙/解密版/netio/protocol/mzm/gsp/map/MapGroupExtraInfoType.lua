local OctetsStream = require("netio.OctetsStream")
local MapGroupExtraInfoType = class("MapGroupExtraInfoType")
MapGroupExtraInfoType.MGEIT_MARRIAGE_CFG_ID = 200
MapGroupExtraInfoType.MGEIT_MARRIAGE_PREPARE_END_SEC = 201
MapGroupExtraInfoType.MASSWEDDING_GROOMSMAN = 500
MapGroupExtraInfoType.MASSWEDDING_TRIGGER_TYPE = 501
function MapGroupExtraInfoType:ctor()
end
function MapGroupExtraInfoType:marshal(os)
end
function MapGroupExtraInfoType:unmarshal(os)
end
return MapGroupExtraInfoType
