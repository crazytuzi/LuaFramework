local sdamagerank = require "protocoldef.knight.gsp.binglinchengxia.sdamagerank"
function sdamagerank:process()
	require("ui.binglinchengxia.binglinchengxialistdlg").getInstanceAndShow():process(self.damagerank,self.mydamage,self.myrank,self.iscangetdamageprize,self.iscangetrankprize)
end

local sactinterface = require "protocoldef.knight.gsp.binglinchengxia.sactinterface"
function sactinterface:process()
    if GetScene():GetMapID() ~= 1577 then return end
    if GetBattleManager() and not GetBattleManager():IsInBattle() then
        require("ui.binglinchengxia.binglinchengxiadlg").getInstanceAndShow():process(self.bossid,self.bosshp,self.lefttime,self.status)
    end
end


local sonebattleinfo = require "protocoldef.knight.gsp.binglinchengxia.sonebattleinfo"
function sonebattleinfo:process()
	require("ui.binglinchengxia.binglinchengxiadlg").PushBattleInfo(self.battleinfo,1)

end
local sallbattleinfo = require "protocoldef.knight.gsp.binglinchengxia.sallbattleinfo"
function sallbattleinfo:process()
	require("ui.binglinchengxia.binglinchengxiadlg").PushBattleInfo(self.battleinfo,2)
end

