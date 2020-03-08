local OctetsStream = require("netio.OctetsStream")
local CrossBattleActivityStage = class("CrossBattleActivityStage")
CrossBattleActivityStage.STAGE_CLOSE = -1
CrossBattleActivityStage.STAGE_REGISTER = 0
CrossBattleActivityStage.STAGE_VOTE = 1
CrossBattleActivityStage.STAGE_ROUND_ROBIN = 2
CrossBattleActivityStage.STAGE_ZONE_DIVIDE = 3
CrossBattleActivityStage.STAGE_ZONE_POINT = 4
CrossBattleActivityStage.STAGE_SELECTION = 5
CrossBattleActivityStage.STAGE_FINAL = 6
function CrossBattleActivityStage:ctor()
end
function CrossBattleActivityStage:marshal(os)
end
function CrossBattleActivityStage:unmarshal(os)
end
return CrossBattleActivityStage
