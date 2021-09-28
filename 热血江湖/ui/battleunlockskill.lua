module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_battleUnlockSkill = i3k_class("wnd_battleUnlockSkill", ui.wnd_base)
function wnd_battleUnlockSkill:ctor()

end

function wnd_battleUnlockSkill:configure()
	self.animations = {}
	self.animations[1] = self._layout.anis.c_jiesuo1
	self.animations[2] = self._layout.anis.c_jiesuo2
	self.animations[3] = self._layout.anis.c_jiesuo3
	self.animations[4] = self._layout.anis.c_jiesuo4

	self.skills = {}
	self.skills[1] = self._layout.vars.skill1
	self.skills[2] = self._layout.vars.skill2
	self.skills[3] = self._layout.vars.skill3
	self.skills[4] = self._layout.vars.skill4
end

function wnd_battleUnlockSkill:onShow()

end

function wnd_battleUnlockSkill:refresh()
	self:showUnlockSkillAnis(g_i3k_game_context:GetRoleSelectSkills(), g_i3k_game_context:GetRoleType())
end


function wnd_battleUnlockSkill:showUnlockSkillAnis(skillList, roleType)
	local defaultSkills = g_i3k_db.i3k_db_get_character_default_skills(roleType)
	local needLvl = g_i3k_db.i3k_db_get_skill_unlock_level(defaultSkills)
	local hero = i3k_game_get_player_hero()
	local level = hero._lvl
	for i=1, 4 do
		local anis = self.animations[i]
		if anis then
			anis.stop()
			anis.play()
		end
	end
	for i,v in ipairs(skillList) do
		local widgets = self.skills[i]
		if v==0 and level>=needLvl[i] then
			widgets:show()
			local needValue = {index = i, skillId = defaultSkills[i]}
			widgets:onClick(self, self.onSkillUnlock, needValue)
		else
			widgets:hide()
		end
	end
end

function wnd_battleUnlockSkill:hideAnimation(id)
	local widgets = self.skills[id]
	widgets:hide()
end

function wnd_battleUnlockSkill:onSkillUnlock(sender, needValue)
	self:hideAnimation(needValue.index)
	local index = needValue.index
	local skillID = needValue.skillId

	local role_type = g_i3k_game_context:GetRoleType()
	local base_skills = i3k_db_generals[role_type].skills
	g_i3k_game_context:CheakRoleSkillsUnlockAndUsed(skillID ,index) 
	--i3k_sbean.goto_skill_unlock(skillID, index)
end

----------------------------------------
function wnd_create(layout)
	local wnd = wnd_battleUnlockSkill.new();
		wnd:create(layout);
	return wnd;
end
