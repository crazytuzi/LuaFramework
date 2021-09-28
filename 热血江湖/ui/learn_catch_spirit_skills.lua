-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_learn_catch_spirit_skills = i3k_class("wnd_learn_catch_spirit_skills", ui.wnd_base)

function wnd_learn_catch_spirit_skills:ctor()
	self._index = 0
end

function wnd_learn_catch_spirit_skills:configure()
	self._layout.vars.closeBtn:onClick(self, self.onCloseUI)
	self._layout.vars.learnBtn:onClick(self, self.onLearnSkillBtn)
	for k = 1, #i3k_db_catch_spirit_base.npc.showSkills do
		self._layout.vars["skillBtn"..k]:onClick(self, self.onChooseSkill, k)
	end
	self._state =
	{
		[0] = {skills = i3k_db_catch_spirit_base.npc.showSkills, btnName = 18630, btnEnable = true, syncArg = 1, reputation = i3k_db_catch_spirit_base.npc.needPowerLevel},
		[1] = {skills = {i3k_db_catch_spirit_base.npc.godViewSkills}, btnName = 18636, btnEnable = true, syncArg = 2, reputation = i3k_db_catch_spirit_base.npc.godViewNeedLevel},
		[2] = {skills = {i3k_db_catch_spirit_base.npc.godViewSkills}, btnName = 18635, btnEnable = false, syncArg = nil, reputation = nil},
	}
end

function wnd_learn_catch_spirit_skills:refresh(npcId)
	ui_set_hero_model(self._layout.vars.npcModel, g_i3k_db.i3k_db_get_npc_modelID(npcId))
	--self._layout.vars.skillDesc:setText(i3k_get_string(18632))
	local time = string.split(i3k_db_catch_spirit_base.common.openTime, ":")
	local startTime = tonumber(time[1]) * 3600 + tonumber(time[2]) * 60 + tonumber(time[3])
	self._layout.vars.descScroll:removeAllChildren()
	local node = require("ui/widgets/gdylxxjnt")()
	node.vars.text:setText(i3k_get_string(18632, time[1], math.floor((startTime + i3k_db_catch_spirit_base.common.lastTime)/3600)))
	g_i3k_ui_mgr:AddTask(self, {node}, function(ui)
		local size = node.rootVar:getContentSize()
		local height = node.vars.text:getInnerSize().height
		local width = size.width
		height = size.height > height and size.height or height
		node.rootVar:changeSizeInScroll(ui._layout.vars.descScroll, width, height, true)
	end, 1)
	self._layout.vars.descScroll:addItem(node)
	self:updateSkills()
end

function wnd_learn_catch_spirit_skills:updateSkills()
	self._layout.vars.scroll:removeAllChildren()
	local node = require("ui/widgets/gdylxxjnt1")()
	local index = math.random(1, #i3k_db_dialogue[i3k_db_catch_spirit_base.npc.dialogueId])
	node.vars.text:setText(i3k_db_dialogue[i3k_db_catch_spirit_base.npc.dialogueId][index].txt)
	g_i3k_ui_mgr:AddTask(self, {node}, function(ui)
		local size = node.rootVar:getContentSize()
		local height = node.vars.text:getInnerSize().height
		local width = size.width
		height = size.height > height and size.height or height
		node.rootVar:changeSizeInScroll(ui._layout.vars.scroll, width, height, true)
	end, 1)
	self._layout.vars.scroll:addItem(node)
	local ghostInfo = g_i3k_game_context:getGhostSkillInfo()
	local skillState = ghostInfo.skillFlag
	for k = 1, #i3k_db_catch_spirit_base.npc.showSkills do
		self._layout.vars["skillLock"..k]:hide()
		if self._state[skillState].skills[k] then
			self._layout.vars["skillBg"..k]:show()
			if self._index == k then
				self._layout.vars["skillSelect"..k]:show()
			else
				self._layout.vars["skillSelect"..k]:hide()
			end
			self._layout.vars["skillIcon"..k]:setImage(g_i3k_db.i3k_db_get_skill_icon_path(self._state[skillState].skills[k]))
			if skillState == 0 then
				self._layout.vars["skillName"..k]:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_catch_spirit_base.npc.skillName[k]))
			else
				self._layout.vars["skillName"..k]:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_catch_spirit_base.npc.skillName[5]))
			end
		else
			self._layout.vars["skillBg"..k]:hide()
		end
	end
	if self._state[skillState].btnEnable then
		self._layout.vars.learnBtn:enableWithChildren()
	else
		self._layout.vars.learnBtn:disableWithChildren()
	end
	self._layout.vars.learnText:setText(i3k_get_string(self._state[skillState].btnName))
	if self._state[skillState].reputation then
		self._layout.vars.needReputation:show()
		self._layout.vars.needReputation:setText(i3k_get_string(18631, i3k_db_power_reputation_level[self._state[skillState].reputation].name))
	else
		self._layout.vars.needReputation:hide()
	end
end

function wnd_learn_catch_spirit_skills:onChooseSkill(sender, index)
	if self._index ~= index then
		self._index = index
		for k = 1, #i3k_db_catch_spirit_base.npc.showSkills do
			if self._index == k then
				self._layout.vars["skillSelect"..k]:show()
			else
				self._layout.vars["skillSelect"..k]:hide()
			end
		end
		local ghostInfo = g_i3k_game_context:getGhostSkillInfo()
		local skillState = ghostInfo.skillFlag
		self._layout.vars.scroll:removeAllChildren()
		local node = require("ui/widgets/gdylxxjnt1")()
		node.vars.text:setText(i3k_db_skills[self._state[skillState].skills[self._index]].desc)
		g_i3k_ui_mgr:AddTask(self, {node}, function(ui)
			local size = node.rootVar:getContentSize()
			local height = node.vars.text:getInnerSize().height
			local width = size.width
			height = size.height > height and size.height or height
			node.rootVar:changeSizeInScroll(ui._layout.vars.scroll, width, height, true)
		end, 1)
		self._layout.vars.scroll:addItem(node)
	end
end

function wnd_learn_catch_spirit_skills:onLearnSkillBtn(sender)
	if g_i3k_game_context:GetLevel() < i3k_db_catch_spirit_base.common.openLevel then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18633, i3k_db_catch_spirit_base.common.openLevel))
		return
	end
	local ghostInfo = g_i3k_game_context:getGhostSkillInfo()
	local skillState = ghostInfo.skillFlag
	local powerRep = g_i3k_game_context:getPowerRep()
	local level = g_i3k_db.i3k_db_power_rep_get_level(powerRep.fame[i3k_db_catch_spirit_base.npc.powerRepId] or 0)
	if self._state[skillState].reputation and level < self._state[skillState].reputation then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18634, i3k_db_power_reputation_level[self._state[skillState].reputation].name))
		return
	end
	if self._state[skillState].syncArg then
		i3k_sbean.ghost_island_learn_skill(self._state[skillState].syncArg)
	end
end

function wnd_learn_catch_spirit_skills:learnSkillSuccess()
	self._layout.anis.c_desad.stop()
	self._layout.anis.c_desad.play()
	self._index = 0
end

function wnd_create(layout)
	local wnd = wnd_learn_catch_spirit_skills.new()
	wnd:create(layout)
	return wnd
end