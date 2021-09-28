local p = require "protocoldef.knight.gsp.faction.enhance.sgetallenhanceattr"
function p:process()
	require "ui.faction.factionxiulian":GetSingletonDialogAndShowIt():Process(self.attrs,self.maxlevel)
end

local p = require "protocoldef.knight.gsp.faction.enhance.senhanceattr"
function p:process()
	local dlg = require "ui.faction.factionxiulian":getInstanceOrNot()
	if not dlg then
		return
	end
	dlg:UpdateAssistSkill(self.attrid,self.level,self.exp)
	dlg:OneAttrProcess(self.attrid,self.level,self.exp)
end
