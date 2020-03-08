local OctetsStream = require("netio.OctetsStream")
local CrossBattleFightType = class("CrossBattleFightType")
CrossBattleFightType.SELECTION = 1
CrossBattleFightType.FINAL = 2
function CrossBattleFightType:ctor()
end
function CrossBattleFightType:marshal(os)
end
function CrossBattleFightType:unmarshal(os)
end
return CrossBattleFightType
