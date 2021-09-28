-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_suicongMaxSkillLevel = i3k_class("wnd_suicongMaxSkillLevel", ui.wnd_base)

function wnd_suicongMaxSkillLevel:ctor()
end

function wnd_suicongMaxSkillLevel:configure()
	local widgets = self._layout.vars
	self._layout.vars.close_btn:onClick(self,self.onCloseUI)
end

function wnd_suicongMaxSkillLevel:refresh(skillId, petId, index)
	local str = index ~= 4 and "在战斗中自动施放" or "奥义需要手动释放"
	self._layout.vars.tips:setText(str)
	local skillLevel = g_i3k_game_context:GetMercenarySkillLevelForIndex(petId, index)
	self._layout.vars.skill_lvl:setText(skillLevel .. "级")
	self._layout.vars.skill_name:setText(i3k_db_skills[skillId].name)
	local spArgs1 = i3k_db_skill_datas[skillId][skillLevel].spArgs1
	local spArgs2 = i3k_db_skill_datas[skillId][skillLevel].spArgs2
	local spArgs3 = i3k_db_skill_datas[skillId][skillLevel].spArgs3
	local spArgs4 = i3k_db_skill_datas[skillId][skillLevel].spArgs4
	local spArgs5 = i3k_db_skill_datas[skillId][skillLevel].spArgs5
	local commonDesc = i3k_db_skills[skillId].common_desc
	local tmp_str = string.format(commonDesc,spArgs1,spArgs2,spArgs3,spArgs4,spArgs5)
	self._layout.vars.skill_desc:setText(tmp_str)
	self._layout.anis.c_dakai.play()
end

function wnd_create(layout)
	local wnd = wnd_suicongMaxSkillLevel.new()
	wnd:create(layout)
	return wnd
end

