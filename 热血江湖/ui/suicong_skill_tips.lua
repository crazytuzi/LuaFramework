-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_suicong_skill_tips = i3k_class("wnd_suicong_skill_tips", ui.wnd_base)

function wnd_suicong_skill_tips:ctor()

end

function wnd_suicong_skill_tips:configure()
	local widgets = self._layout.vars
	self._layout.vars.close_btn:onClick(self,self.onCloseUI)
end

function wnd_suicong_skill_tips:refresh(skillId, petId, index, tips_str)
	local str = tips_str or (index ~= 4 and "在战斗中自动施放" or "奥义需要手动释放")
	self._layout.vars.tips:setText(str)
	self._layout.vars.skill_name:setText(i3k_db_skills[skillId].name)
	local spArgs1 = i3k_db_skill_datas[skillId][1].spArgs1
	local spArgs2 = i3k_db_skill_datas[skillId][1].spArgs2
	local spArgs3 = i3k_db_skill_datas[skillId][1].spArgs3
	local spArgs4 = i3k_db_skill_datas[skillId][1].spArgs4
	local spArgs5 = i3k_db_skill_datas[skillId][1].spArgs5
	local commonDesc = i3k_db_skills[skillId].common_desc
	local tmp_str = string.format(commonDesc,spArgs1,spArgs2,spArgs3,spArgs4,spArgs5)
	self._layout.vars.skill_desc:setText(tmp_str)
	--[[
	self.uplvl_desc:setVisible(true)
	local friendLvl = g_i3k_game_context:getPetFriendLvl(petId)
	if islock and islock == true then
		friendLvl = 1
		self.uplvl_desc:setVisible(false)
	end
	if friendLvl == 0 then
		friendLvl = 1
	end
	local temp = string.format("activeSkill%sLvl",index)
	local starlvl = i3k_db_suicong_relation[petId][friendLvl][temp]
	local desc  = i3k_db_skill_datas[skillId][starlvl].desc
	
	
	self.skillName:setText(i3k_db_skills[skillId].name)
	local tmp_str = string.format("等级：%s",starlvl)
	self.skillLevel:setText(tmp_str)
	
	self.skillDesc2:setText("在战斗中自动施放")
	self.mark:setVisible(index == 4)
	if index == 4 then
		self.skillDesc2:setText("奥义需要手动释放")
	end
	
	local name
	for k,v in ipairs(i3k_db_suicong_relation[petId]) do
		if v[temp] > starlvl then
			name = v.name
			break
		end
	end
	if not i3k_db_suicong_relation[petId][friendLvl+1] then
		self.uplvl_desc:setText("武功已达最高级别")
	else
		local tmp_str = string.format("合修等级达到<c=yellow>%s级</c>后升级",friendLvl+1)
		self.uplvl_desc:setText(tmp_str)
	end]]
end

function wnd_create(layout)
	local wnd = wnd_suicong_skill_tips.new()
	wnd:create(layout)
	return wnd
end

