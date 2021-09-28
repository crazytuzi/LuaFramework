local p = require "protocoldef.knight.gsp.activity.gumumijing.sgumudrawaward"
function p:process()
    if GetBattleManager() and not GetBattleManager():IsInBattle() then
        require("ui.gumumijing.gumumijingbtn").getInstanceAndShow():process(self.lefttime)
    else
        p.reShow = 1
    end
end



local p = require "protocoldef.knight.gsp.activity.gumumijing.sgumubutton"
function p:process()
    require("ui.gumumijing.gumumijinglarenbtn").process(self.activitystatus)
end


