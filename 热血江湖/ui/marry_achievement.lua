------------------------------------------------------
module(...,package.seeall)

local require = require

local ui = require("ui/base")
------------------------------------------------------
wnd_marry_achievement = i3k_class("wnd_marry_achievement",ui.wnd_base)

local JHFQCJT = "ui/widgets/jhfqcjt"
local allRewards = 5

function wnd_marry_achievement:ctor()
	self._accumulative = false --是否有累积奖励可以领
	self._achievement = false --是否有成就任务奖励可以领
end

function wnd_marry_achievement:configure()
	self._layout.vars.close_btn:onClick(self, self.onCloseUI)
	self._layout.vars.achievement_btn:stateToPressed()
	self._layout.vars.yinyuan_btn:onClick(self, self.onYinyuanBtn)
	self._layout.vars.yinyuan_btn:stateToNormal()
	self._layout.vars.skills_btn:onClick(self, self.onSkillBtn)
	self._layout.vars.skills_btn:stateToNormal()
	self._layout.vars.help_btn:onClick(self, self.onHelpBtn)
	--self._layout.vars.divorce_btn:onClick(self, self.onDivorceBtn)
	--self._layout.vars.divorce_btn:stateToNormal()
	for k = 1, allRewards do
		if i3k_db_marry_achieveRewards[k] then
			self._layout.vars["reward_btn"..k]:onTouchEvent(self, self.onRewardBtn, k)
		end
	end
end

function wnd_marry_achievement:refresh()
	self._accumulative = false
	self._achievement = false
	self:updateAccumulativeReward()
	self:updateAchievementScroll()
	if not (self._accumulative or self._achievement) then
		g_i3k_game_context:ClearNotice(g_NOTICE_TYPE_MARRY_ACHIEVEMENT)
	end
	self._layout.vars.achieve_red:setVisible(g_i3k_game_context:GetNoticeState(g_NOTICE_TYPE_MARRY_ACHIEVEMENT))
end
function wnd_marry_achievement:onHelpBtn()
	g_i3k_ui_mgr:ShowHelp(i3k_get_string(18558, g_i3k_db.i3k_db_marryTaskCfg.loopTaskCnt))
end

function wnd_marry_achievement:updateAccumulativeReward()
	local achievementCfg = g_i3k_game_context:getMarryAchievementTask()
	--self._layout.vars.loading:setPercent(achievementCfg.achievePoint / i3k_db_marry_achieveRewards[#i3k_db_marry_achieveRewards].needPoint * 100)
	self._layout.vars.point:setText(achievementCfg.achievePoint)
	local value = 0
	local first = true
	for k = 1, allRewards do
		local rewardCfg = i3k_db_marry_achieveRewards[k]
		if rewardCfg then
			self._layout.anis["c_fudai"..k].stop()
			self._layout.vars["rewards"..k]:show()
			self._layout.vars["reward_txt"..k]:setText(rewardCfg.needPoint)
			if table.keyof(achievementCfg.achieveReward, k) then
				self._layout.vars["reward_get_icon"..k]:show()
				self._layout.vars["reward_icon"..k]:hide()
			elseif achievementCfg.achievePoint >= rewardCfg.needPoint then
				self._layout.vars["reward_get_icon"..k]:hide()
				self._layout.vars["reward_icon"..k]:show()
				self._layout.anis["c_fudai"..k].play()
				self._accumulative = true
			else
				self._layout.vars["reward_get_icon"..k]:hide()
				self._layout.vars["reward_icon"..k]:show()
			end
			if achievementCfg.achievePoint >= rewardCfg.needPoint then
				value = value + 1.0 / allRewards
			else
				if first then
					if k > 1 then
						value = value + 1.0 / allRewards * (achievementCfg.achievePoint - i3k_db_marry_achieveRewards[k - 1].needPoint) / (rewardCfg.needPoint - i3k_db_marry_achieveRewards[k - 1].needPoint)
					else
						value = value + 1.0 / allRewards * achievementCfg.achievePoint / rewardCfg.needPoint
					end
					first = false
				end
			end
		else
			self._layout.vars["rewards"..k]:hide()
		end
	end
	value = value * 100
	self._layout.vars.loading:setPercent(value > 100 and 100 or value)
end

function wnd_marry_achievement:sortAchievement()
	local achievementCfg = g_i3k_game_context:getMarryAchievementTask()
	local taskCfg = g_i3k_game_context:getMarryAchievement()
	local sortCfg = {}
	for k, v in pairs(i3k_db_marry_achievement) do
		local index = math.min((achievementCfg.taskReward[k] and achievementCfg.taskReward[k].curRewardLog or 0) + 1, #v)
		local sortId = k + 100 * v[index].sortId
		if (achievementCfg.taskReward[k] and achievementCfg.taskReward[k].curRewardLog or 0) >= #v then
			sortId = sortId + 100000
		else
			if (taskCfg.tasks[k] or 0) >= v[index].target then
				self._achievement = true
			else
				sortId = sortId + 5000
				if v[index].isJump == 0 then
					sortId = sortId + 10000
				end
			end
		end
		table.insert(sortCfg, {gid = k, sortId = sortId})
	end
	table.sort(sortCfg, function(a, b)
		return a.sortId < b.sortId
	end)
	return sortCfg
end
function wnd_marry_achievement:updateAchievementScroll()
	self._layout.vars.scroll:removeAllChildren()
	local achievementCfg = g_i3k_game_context:getMarryAchievementTask()
	local taskCfg = g_i3k_game_context:getMarryAchievement()
	local sortCfg = self:sortAchievement()
	for _, v in ipairs(sortCfg) do
		local index = math.min((achievementCfg.taskReward[v.gid] and achievementCfg.taskReward[v.gid].curRewardLog or 0) + 1, #i3k_db_marry_achievement[v.gid])
		local info = i3k_db_marry_achievement[v.gid][index]
		local node = require(JHFQCJT)()
		node.vars.task_icon:setImage(g_i3k_db.i3k_db_get_icon_path(info.iconId))
		node.vars.task_name:setText(info.title)
		node.vars.condition:setText(info.desc.."("..(taskCfg.tasks[v.gid] or 0).."/"..info.target..")")
		node.vars.achPoint:setVisible(true)
		node.vars.achPoint:setText("成就点数："..info.achievePoint)
		node.vars.finish_icon:hide()
		node.vars.go_btn:hide()
		node.vars.notCanJump:hide()
		node.vars.take_btn:hide()
		if (achievementCfg.taskReward[v.gid] and achievementCfg.taskReward[v.gid].curRewardLog or 0) >= #i3k_db_marry_achievement[v.gid] then
			node.vars.finish_icon:show()
		elseif (taskCfg.tasks[v.gid] or 0) >= info.target then
			node.vars.take_btn:show()
			node.vars.take_btn:onClick(self, self.onTakeRewardBtn, {gid = v.gid, index = index})
		elseif info.isJump == 1 then
			node.vars.go_btn:show()
			node.vars.go_btn:onClick(self, self.onJumpBtn, {gid = v.gid, index = index})
		else
			node.vars.notCanJump:show()
		end
		if index ~= #i3k_db_marry_achievement[v.gid] and index <= (achievementCfg.taskReward[v.gid] and achievementCfg.taskReward[v.gid].historyRewardLog or 0) then
			node.vars.not_reward_text:show()
			node.vars.not_reward_text:setText(i3k_get_string(17518))
			for i = 1, 3 do
				node.vars["image"..i]:hide()
				node.vars["count"..i]:hide()
			end
		else
			node.vars.not_reward_text:hide()
			for i = 1, 3 do
				if info.rewards[i].id > 0 and info.rewards[i].count > 0 then
					node.vars["image"..i]:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(info.rewards[i].id))
					node.vars["icon"..i]:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(info.rewards[i].id))
					node.vars["lock"..i]:setVisible(info.rewards[i].id > 0)
					node.vars["tips"..i]:onClick(self, self.onItemBtn, info.rewards[i].id)
					node.vars["count"..i]:setText("x"..info.rewards[i].count)
				else
					node.vars["image"..i]:hide()
					node.vars["count"..i]:hide()
				end
			end
		end
		self._layout.vars.scroll:addItem(node)
	end
end

function wnd_marry_achievement:onRewardBtn(sender, eventType, index)
	local achievementCfg = g_i3k_game_context:getMarryAchievementTask()
	if eventType == ccui.TouchEventType.began then
		if achievementCfg.achievePoint < i3k_db_marry_achieveRewards[index].needPoint then
			g_i3k_ui_mgr:OpenUI(eUIID_MarryAchievementShow)
			g_i3k_ui_mgr:RefreshUI(eUIID_MarryAchievementShow, index)
		end
	elseif eventType == ccui.TouchEventType.moved then
		
	else
		if achievementCfg.achievePoint < i3k_db_marry_achieveRewards[index].needPoint then
			g_i3k_ui_mgr:CloseUI(eUIID_MarryAchievementShow)
		elseif not table.keyof(achievementCfg.achieveReward, index) then
			if g_i3k_game_context:checkBagCanAddCell(1, true) then
				i3k_sbean.marriage_achieve_accumulative_reward(index)
			end
		end
	end
end

function wnd_marry_achievement:onTakeRewardBtn(sender, info)
	if g_i3k_game_context:checkBagCanAddCell(1, true) then
		i3k_sbean.marriage_achieve_receive_reward(info.gid, info.index)
	end
end

function wnd_marry_achievement:onJumpBtn(sender, info)
	if info.gid == 1 then
		g_i3k_logic:OpenDungeonUI()
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_FBLB, "onZuduiBtnClick")
		g_i3k_ui_mgr:CloseUI(eUIID_MarryAchievement)
	elseif info.gid == 2 then
		g_i3k_logic:OpenTournamentUI()
		g_i3k_ui_mgr:CloseUI(eUIID_MarryAchievement)
	elseif info.gid == 3 then
		local callback = function ()
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_Marry_Marryed_Yinyuan, "openMarriageCardUI")
		end
		g_i3k_logic:OpenMarried_Yinyuan(callback)
	elseif info.gid == 4 then
		g_i3k_logic:OpenMarried_skills()
	elseif info.gid == 5 then
		local marryTask = g_i3k_game_context:GetMarriageTaskData()
		if marryTask.open then
			g_i3k_logic:OpenTaskUI(marryTask.id, i3k_get_MrgTaskCategory())
			g_i3k_ui_mgr:CloseUI(eUIID_MarryAchievement)
		end
	elseif info.gid == 8 then
		
	elseif info.gid == 9 then
		
	end
	
end

function wnd_marry_achievement:onItemBtn(sender, itemId)
	g_i3k_ui_mgr:ShowCommonItemInfo(itemId)
end

function wnd_marry_achievement:onYinyuanBtn(sender)
	g_i3k_logic:OpenMarried_Yinyuan()
end

function wnd_marry_achievement:onSkillBtn(sender)
	g_i3k_logic:OpenMarried_skills()
end

-- function wnd_marry_achievement:onDivorceBtn(sender)
-- 	g_i3k_logic:OpenMarried_lihun()
-- end

-------------------------------------------------------
function wnd_create(layout,...)
	local wnd = wnd_marry_achievement.new()
	wnd:create(layout,...)
	return wnd
end
