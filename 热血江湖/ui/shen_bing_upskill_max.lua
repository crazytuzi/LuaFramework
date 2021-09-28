-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_shen_bing_upskill_max = i3k_class("wnd_shen_bing_upskill_max", ui.wnd_base)


function wnd_shen_bing_upskill_max:ctor( )

end

function wnd_shen_bing_upskill_max:configure( )
	local widgets = self._layout.vars
	self.skill_lvl = widgets.skill_lvl
	self.skill_desc = widgets.skill_desc
	self.skill_name = widgets.skill_name
	self.close_btn = widgets.close_btn
	self.close_btn:onClick(self,self.onCloseUI)
		
end

function wnd_shen_bing_upskill_max:refresh(shenbingId,skillId,skillLvl,skillDescId)

	self:SetShenBingUpSkillMaxData(shenbingId,skillId,skillLvl,skillDescId)
end

function wnd_shen_bing_upskill_max:SetShenBingUpSkillMaxData(shenbingId,skillId,skillLvl,skillDescId)
	self.skill_name:setText(i3k_db_skills[skillDescId].name)
	self.skill_lvl:setText(skillLvl.."级")

	local spArgs1 = i3k_db_skill_datas[skillDescId][skillLvl].spArgs1
	local spArgs2 = i3k_db_skill_datas[skillDescId][skillLvl].spArgs2
	local spArgs3 = i3k_db_skill_datas[skillDescId][skillLvl].spArgs3
	local spArgs4 = i3k_db_skill_datas[skillDescId][skillLvl].spArgs4 
	local spArgs5 = i3k_db_skill_datas[skillDescId][skillLvl].spArgs5
	local commonDesc = i3k_db_skills[skillDescId].common_desc
	local tmp_str = string.format(commonDesc,spArgs1,spArgs2,spArgs3,spArgs4,spArgs5)
	self.skill_desc:setText(tmp_str)
end

function wnd_create(layout)
	local wnd = wnd_shen_bing_upskill_max.new()
	wnd:create(layout)
	return wnd
end
