local snotifyplayeffect = require "protocoldef.knight.gsp.msg.snotifyplayeffect"

function snotifyplayeffect:process()
	LogInfo("snotifyplayeffect process")
	if not GetPlayRoseEffecstManager() then 
		CPlayRoseEffecst:NewInstance()
	end
	if GetPlayRoseEffecstManager() then
		GetPlayRoseEffecstManager():PlayLevelUpEffect(self.effectid, 0)	
	end
end
