knight_gsp_skill = {}

function knight_gsp_skill.SUpdateAssistSkill_Lua_Process(p)
	local proto = KnightClient.toSUpdateAssistSkill(p)
	local dlg = require "ui.faction.factionxiulian":getInstanceOrNot()
	if dlg then
		dlg:UpdateAssistSkill(proto.assistskill.id, proto.assistskill.level, proto.assistskill.exp)
	end
	return true
end