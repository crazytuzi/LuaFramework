
-------------------------------------------------------
module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_hideWeaponActiveSkillLock = i3k_class("wnd_hideWeaponActiveSkillLock",ui.wnd_base)

function wnd_hideWeaponActiveSkillLock:ctor()

end

function wnd_hideWeaponActiveSkillLock:configure()
	local widgets = self._layout.vars
	widgets.close:onClick(self, self.onCloseUI)
end

function wnd_hideWeaponActiveSkillLock:refresh(wid, isMax)
	self:setInfo(wid, isMax)
end

function wnd_hideWeaponActiveSkillLock:setInfo(wid, isMax)
	local widgets = self._layout.vars

	local anqiCfg = i3k_db_anqi_base[wid]
	local skillID = anqiCfg.skillID
	widgets.name:setText(anqiCfg.name)

	local finalSkillLvl = g_i3k_game_context:GetHideWeaponFinalActiveSkillLvl(wid)
	local skillLvl = g_i3k_game_context:GetHideWeaponActiveSkillLvl(wid)

	if skillLvl ~= finalSkillLvl then
		widgets.unlock_des:setText(finalSkillLvl .. "级(+"..(finalSkillLvl - skillLvl)..")")
	else
		widgets.unlock_des:setText(finalSkillLvl .. "级")
	end

	local text = isMax and i3k_get_string(17322) or i3k_get_string(17321)
	widgets.tips:setText(text)

	widgets.des:setText(self:getSkillDesc(skillID, finalSkillLvl))

	--local skill = i3k_db_skills[skillID]
	local path = g_i3k_db.i3k_db_get_anqi_skin_skillId_by_skinID(wid, skillID)
	widgets.img:setImage(path)
end

function wnd_hideWeaponActiveSkillLock:getSkillDesc(skillID, skillLvl)
	local spArgs1 = i3k_db_skill_datas[skillID][skillLvl].spArgs1
	local spArgs2 = i3k_db_skill_datas[skillID][skillLvl].spArgs2
	local spArgs3 = i3k_db_skill_datas[skillID][skillLvl].spArgs3
	local spArgs4 = i3k_db_skill_datas[skillID][skillLvl].spArgs4
	local spArgs5 = i3k_db_skill_datas[skillID][skillLvl].spArgs5
	local commonDesc = i3k_db_skills[skillID].common_desc
	local skillDesc = string.format(commonDesc, spArgs1, spArgs2, spArgs3, spArgs4, spArgs5)
	return skillDesc
end

function wnd_create(layout, ...)
	local wnd = wnd_hideWeaponActiveSkillLock.new()
	wnd:create(layout, ...)
	return wnd;
end

