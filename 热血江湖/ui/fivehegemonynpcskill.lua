-------------------------------------------------------
module(..., package.seeall)

local require = require

require("ui/ui_funcs")
local ui = require("ui/base")

-------------------------------------------------------
wnd_fiveHegemonyNpcSkill = i3k_class("wnd_fiveHegemonyNpcSkill", ui.wnd_base)

function wnd_fiveHegemonyNpcSkill:ctor()
end

function wnd_fiveHegemonyNpcSkill:configure()
	self._layout.vars.btnClose:onClick(self,self.onCloseUI)
end

function wnd_fiveHegemonyNpcSkill:refresh(npcID)
	self:setSkillItem(npcID)
end



--展示item
function wnd_fiveHegemonyNpcSkill:setSkillItem(npcID)
	local widgets = self._layout.vars
	local npcInfo = i3k_db_five_contend_hegemony.npcRole[npcID]
	local skills = i3k_db_five_contend_hegemony.skills
	if npcInfo then
		widgets.npcName:setText(npcInfo.name)
		for i, id in ipairs(npcInfo.skills) do
			local skill = skills[id]
			widgets["skillIcon"..i]:setImage((g_i3k_db.i3k_db_get_icon_path(skill.icon)))
			widgets["skillName"..i]:setText(skill.name)
			--widgets["skillDamage"..i]:setText(skill.damageMin.."~"..skill.damageMax)
			widgets["skillDesc"..i]:setText(skill.desc)
		end
	end
end

function wnd_create(layout)
	local wnd = wnd_fiveHegemonyNpcSkill.new()
	wnd:create(layout)
	return wnd
end
