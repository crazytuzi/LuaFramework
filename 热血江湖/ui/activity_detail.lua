module(..., package.seeall)

local require = require;

local ui = require("ui/base");


wnd_activity_detail = i3k_class("wnd_activity_detail", ui.wnd_base)

local WIPE_ITEM_ID = g_i3k_db.i3k_db_get_common_cfg().wipe.itemid
local WIDGET_HDLX2T = "ui/widgets/hdlx2t"
-- 按钮三种状态 普通，选中，未解锁
local NORMAL_ICON = i3k_db_common.activity.normalIcon
local SELECT_ICON = i3k_db_common.activity.selectIcon
local DISABLE_ICON = i3k_db_common.activity.disableIcon

function wnd_activity_detail:ctor()
	self._needLvl = 0
	self._dungeonTable = {}
	self._is_wipe = false
	self._logs = {}
end

function wnd_activity_detail:configure()
	self._layout.vars.closeBtn:onClick(self, self.onCloseUI)

	local widgets = self._layout.vars

	self._layout.vars.petSet:onClick(self, self.toSetPets)
	self._layout.vars.sweepBtn:disableWithChildren()
	self.historyMax = self._layout.vars.historyMax
	self.maxProcess = self._layout.vars.maxProcess
	self.wipeRoot	= widgets.wipeRoot
	self._wipeCount = widgets.wipeCount
	self._wipeIcon = widgets.wipeIcon

	self.diffcultScroll = widgets.diffcultScroll
end

function wnd_activity_detail:refresh(groupId, dungeonName, logs)
	self._groupId = groupId
	self._logs = logs
	self:loadData(groupId, dungeonName)
	self:sortActivityGroup(groupId)
	self:loadDiffcultScroll(groupId)
end

function wnd_activity_detail:loadData(groupId, dungeonName)
	self._layout.vars.desc:setText(i3k_get_string(i3k_db_activity[groupId].descTextId))
	self._layout.vars.name:setText(dungeonName)
	for k,v in ipairs(i3k_db_activity_wipe[#i3k_db_activity_wipe].groupIds) do
		if v == self._groupId then
			self._is_wipe = true
			break
		end
	end
	self:updateWipeWidget()
end

function wnd_activity_detail:updateWipeWidget()
	self._wipeIcon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(WIPE_ITEM_ID, g_i3k_game_context:IsFemaleRole()))
	self._wipeCount:setText(g_i3k_game_context:GetCommonItemCanUseCount(WIPE_ITEM_ID))
end

function wnd_activity_detail:sortActivityGroup(groupId)
	for i,v in pairs(i3k_db_activity_cfg) do
		if v.groupId == groupId then
			table.insert(self._dungeonTable, v)
		end
	end
	table.sort(self._dungeonTable, function (a, b)
		return a.difficulty<b.difficulty
	end)
end

function wnd_activity_detail:loadDiffcultScroll(groupId)
	self.diffcultScroll:removeAllChildren()
	local jumpNode
	for i, e in ipairs(self._dungeonTable) do
		local node = require(WIDGET_HDLX2T)()
		node.difficultyTag = e.difficulty
		local widget = node.vars
		local isBeforeFinish = false
		local isCanClick = true
		if e.beforeDungeon~=0 then
			isBeforeFinish = g_i3k_game_context:getActivityMapIsFinished(groupId, e.beforeDungeon)
		end
		widget.lock:hide()
		widget.difficultyBtn:setImage(g_i3k_db.i3k_db_get_icon_path(NORMAL_ICON[e.difficulty]))
		if i==1 or (e.beforeDungeon~=0 and isBeforeFinish and g_i3k_game_context:GetLevel() >= e.needLvl) then
			jumpNode = e.difficulty
			widget.lock:hide()
		elseif e.beforeDungeon~=0 and not isBeforeFinish then
			widget.lock:hide()
			widget.difficultyBtn:setImage(g_i3k_db.i3k_db_get_icon_path(DISABLE_ICON[e.difficulty]))
		end
		if i==1 or (e.beforeDungeon~=0 and isBeforeFinish) then
			self._maxDifficult = e.difficulty
		end
		widget.difficultyBtn:onClick(self, self.onSelectDifficulty, {difficult = e.difficulty, isCanClick = e.difficulty <= self._maxDifficult})
		self.diffcultScroll:addItem(node)
	end
	if jumpNode then
		self:selectDifficulty(jumpNode)
		self.diffcultScroll:jumpToChildWithIndex(jumpNode)
	end
end

function wnd_activity_detail:onWipeDungeon(sender, mapId)
	local cfg = i3k_db_activity_cfg[mapId]
	local roleLvl = g_i3k_game_context:GetLevel()
	if cfg then
		if roleLvl < cfg.needLvl then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15459))
			return false
		end
	end
	if cfg.specialSweepType ~= 0 and cfg.groupId ~= 8 then
		if not self:canSweep(mapId) then
			return false
		end
	else
		if cfg.groupId == 8 then--秘宝矿洞特殊逻辑
			local actRecord = g_i3k_game_context:getActMapRecord(i3k_db_activity_cfg[mapId].groupId, mapId)
			if actRecord >= 10000 then
				local monsterID = cfg.specialWinCondition5.monsterID
				local logs = self._logs[mapId]
				if not(logs and logs.monsters and logs.monsters[monsterID] and logs.monsters[monsterID] > 0) then
					g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1314))
					return false
				end
			end
		end
		if g_i3k_game_context:getActMapRecord(i3k_db_activity_cfg[mapId].groupId, mapId) < 10000 then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(827))
			return false
		end
	end
	local needWizardLvl = g_i3k_db.i3k_db_get_need_wizard_lvl(self._groupId)
	if needWizardLvl then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(830, needWizardLvl, i3k_db_activity_cfg[mapId].desc))
		return false
	end
	g_i3k_logic:OpenDungeonWipe(mapId)
end

function wnd_activity_detail:canSweep(mapId)
	for _, v in pairs(self._logs) do
		if v.mapID == mapId then
			local cfg = i3k_db_activity_cfg[mapId]
			if i3k_db_activity_cfg[mapId].specialSweepType == 1 then
				if v.drops and next(v.drops) then
			return true
				end
			elseif i3k_db_activity_cfg[mapId].specialSweepType == 2 then
				if v.mines and next(v.mines) then
					return true
				end
			elseif i3k_db_activity_cfg[mapId].specialSweepType == 3 then
				if v.monsters and next(v.monsters) then
					return true
				else
					g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1312))
					return false
				end
			end
			break
		end
	end
	g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1314))
	return false
end

function wnd_activity_detail:onStart(sender, v)
	local function func()
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_ActivityDetail,"startCB",v)
	end
	g_i3k_game_context:CheckMulHorse(func)
end

function wnd_activity_detail:startCB(v)
	local func3 = function () -- 随从
		local allPets = g_i3k_game_context:GetYongbingData()
		local allCount = 0
		for _,_ in pairs(allPets) do
			allCount = allCount + 1
		end
		--已经上阵的数量
		local fightPets = g_i3k_game_context:GetActivityPets()
		local fightCount = #fightPets

		--总共能上阵几个随从
		local roleLvl = g_i3k_game_context:GetLevel()
		local totalCount = 0
		if roleLvl >= i3k_db_common.posUnlock.first and roleLvl < i3k_db_common.posUnlock.second then
			totalCount = 1
		elseif roleLvl >= i3k_db_common.posUnlock.second and roleLvl < i3k_db_common.posUnlock.third then
			totalCount = 2
		else
			totalCount = 3
		end
		if fightCount<allCount and fightCount<totalCount then
			local fun = function(isOk)
				if isOk then
					g_i3k_logic:OpenActivityPetsUI()
				else
					self:starActivity(v)
				end
			end
			g_i3k_ui_mgr:ShowMessageBox2(i3k_get_string(286), fun)
		else
			self:starActivity(v)
		end
	end

	local func2 = function ()  --队伍
		local teamId = g_i3k_game_context:GetTeamId()
		if teamId~=0 then
			local function callback(isOk)
				if isOk then
					func3()
				end
			end
			g_i3k_ui_mgr:ShowMessageBox2(i3k_get_string(141), callback)
		else
			func3()
		end
	end

	local func1 = function ()  --相依相偎
		if g_i3k_game_context:IsInRoom() then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(142))
			return
		end
		func2()
	end

	func1()
end

function wnd_activity_detail:starActivity(v)
	if g_i3k_game_context:getMatchState() ~= 0 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(142))
		return
	end
	if g_i3k_game_context:GetLevel() < self._needLvl then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(163, self._needLvl))
	elseif g_i3k_game_context:GetVit() < v.needTili then
		g_i3k_logic:GotoOpenBuyVitUI()
	else
		if i3k_check_resources_downloaded(v.id) then
			local fun = function(ok)
				if ok then
					i3k_sbean.activitymap_start(v.id, v.needTili)
				end
			end
			g_i3k_game_context:CheckJudgeEmailIsFull(fun, true)
		end
	end
end

function wnd_activity_detail:onSelectDifficulty(sender, data)
	if data.isCanClick then
		self:selectDifficulty(data.difficult)
	end
end

function wnd_activity_detail:selectDifficulty(difficult)
	local showSchedule = i3k_db_activity[self._groupId].showSchedule
	local rolePower = g_i3k_game_context:GetRolePower()
	for _,v in ipairs(self._dungeonTable) do
		if v.groupId==self._groupId and difficult==v.difficulty then
			local historyMax = g_i3k_game_context:GetActivityKillMaxCount(self._groupId,v.id)
			self.historyMax:setText(string.format("历史最高击杀：%s",historyMax))
			self.historyMax:setVisible(i3k_db_activity_cfg[v.id].showMax == 1)
			if not showSchedule  then
				self.maxProcess:hide()
			else
				self.maxProcess:show()
				local actRecord = g_i3k_game_context:getActMapRecord(i3k_db_activity_cfg[v.id].groupId, v.id)
				actRecord = actRecord > 10000 and 10000 or actRecord
				self.maxProcess:setText(string.format("最高进度：%s%%", actRecord/100))
			end
			if v.groupId == 8 then--秘宝矿洞
				self._layout.vars.catchCount:show()
				local catchCount = self._logs[v.id] and self._logs[v.id].monsters and self._logs[v.id].monsters[v.specialWinCondition5.monsterID] or 0
				local maxCount = v.specialWinCondition5.initCount
				self._layout.vars.catchCount:setText(string.format("抓住盗矿者：%d/%d", catchCount, maxCount))
			else
				self._layout.vars.catchCount:hide()
			end
			self.wipeRoot:setVisible(self._is_wipe)
			if self._is_wipe then
				self._layout.vars.sweepBtn:enableWithChildren()
			end
			self._layout.vars.sweepBtn:setVisible(self._is_wipe)
			self._layout.vars.enterBtn:onClick(self, self.onStart, v)
			self._layout.vars.sweepBtn:onClick(self, self.onWipeDungeon, v.id)
			self._layout.vars.tiliLabel:setText("x"..v.needTili)
			self._layout.vars.needLvl:setText(v.needLvl)

			self._layout.vars.needDesc:setTextColor(g_i3k_get_cond_color(g_i3k_game_context:GetLevel() >= v.needLvl))
			self._layout.vars.needLvl:setTextColor(g_i3k_get_cond_color(g_i3k_game_context:GetLevel() >= v.needLvl))
			self._needLvl = v.needLvl

			self._layout.vars.powerLabel:setText(v.powerRecommend)
			self._layout.vars.powerName:setTextColor(g_i3k_get_cond_color(rolePower>=v.powerRecommend))
			self._layout.vars.powerLabel:setTextColor(g_i3k_get_cond_color(rolePower>=v.powerRecommend))
			self:reloadRewardItems(v.rewardItems)
		end
	end
	self:updateDifficultyState(difficult)
end

function wnd_activity_detail:reloadRewardItems(rewardItems)
	self._layout.vars.scroll:removeAllChildren()
	for k, e in ipairs(rewardItems) do
		local id = e.rewardId
		if id ~= 0 then
			local node = require("ui/widgets/hdlx1t")()
			node.vars.itemIcon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(id, g_i3k_game_context:IsFemaleRole()))
			node.vars.itemBg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(id))
			node.vars.itemBtn:onClick(self, self.checkItemGrade, e.rewardId)
			self._layout.vars.scroll:addItem(node)
		end
	end
	self._layout.vars.scroll:setBounceEnabled(true)
end

function wnd_activity_detail:updateDifficultyState(difficult)
	for i, e in pairs(self.diffcultScroll:getAllChildren()) do
		local widget = e.vars
		widget.isSelect:setVisible(e.difficultyTag == difficult)
		if e.difficultyTag == difficult then
			widget.difficultyBtn:setImage(g_i3k_db.i3k_db_get_icon_path(SELECT_ICON[i]))
		elseif self._maxDifficult then
			if e.difficultyTag <= self._maxDifficult then
				widget.difficultyBtn:setImage(g_i3k_db.i3k_db_get_icon_path(NORMAL_ICON[i]))
			else
				widget.difficultyBtn:setImage(g_i3k_db.i3k_db_get_icon_path(DISABLE_ICON[i]))
			end
		else
			widget.difficultyBtn:setImage(g_i3k_db.i3k_db_get_icon_path(DISABLE_ICON[i]))
		end
	end
end

function wnd_activity_detail:checkItemGrade(sender, id)
	g_i3k_ui_mgr:ShowCommonItemInfo(id)
end

function wnd_activity_detail:toSetPets(sender)
	g_i3k_logic:OpenActivityPetsUI()
end

function wnd_create(layout)
	local wnd = wnd_activity_detail.new();
	wnd:create(layout);
	return wnd;
end
