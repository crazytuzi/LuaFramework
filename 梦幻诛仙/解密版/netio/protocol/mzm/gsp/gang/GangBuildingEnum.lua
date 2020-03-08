local OctetsStream = require("netio.OctetsStream")
local GangBuildingEnum = class("GangBuildingEnum")
GangBuildingEnum.XIANGFANG = 0
GangBuildingEnum.CANGKU = 1
GangBuildingEnum.JINKU = 2
GangBuildingEnum.YAODIAN = 3
GangBuildingEnum.GANG = 4
GangBuildingEnum.SHUYUAN = 5
function GangBuildingEnum:ctor()
end
function GangBuildingEnum:marshal(os)
end
function GangBuildingEnum:unmarshal(os)
end
return GangBuildingEnum
