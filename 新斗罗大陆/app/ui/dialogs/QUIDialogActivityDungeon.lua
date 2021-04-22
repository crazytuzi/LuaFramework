--
-- Author: Your Name
-- Date: 2014-12-01 15:49:22
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogActivityDungeon = class("QUIDialogActivityDungeon", QUIDialog)

local QUIViewController = import("..QUIViewController")
local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetMonsterHead = import("..widgets.QUIWidgetMonsterHead")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QDungeonArrangement = import("...arrangement.QDungeonArrangement")
local QUIWidgetHeroInformation = import("..widgets.QUIWidgetHeroInformation")
local QVIPUtil = import("...utils.QVIPUtil")
local QUIDialogBuyCount = import("..dialogs.QUIDialogBuyCount")

function QUIDialogActivityDungeon:ctor(options)
	local ccbFile = "ccb/Dialog_TimeMachine_info.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerTeam", 				callback = handler(self, QUIDialogActivityDungeon._onTriggerTeam)},
		{ccbCallbackName = "onTriggerQuickFightOne", 		callback = handler(self, QUIDialogActivityDungeon._onTriggerQuickFightOne)},
	}
	QUIDialogActivityDungeon.super.ctor(self,ccbFile,callBacks,options)
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	page:setManyUIVisible()
	page:setScalingVisible(true)
    page.topBar:showWithMainPage()

	self.info = options.info
	local passInfo = remote.activityInstance:getPassInfoById(self.info.dungeon_id)
		if passInfo then
			printTable(passInfo)
		end
	if passInfo ~= nil and passInfo.star ~= nil and passInfo.lastPassAt > 0 then
		self._ccbOwner.btn_fastbattle:setVisible(true)
	else
		self._ccbOwner.btn_fastbattle:setVisible(false)
	end
	self._name = ""
	self.dungeonInfo = QStaticDatabase:sharedDatabase():getDungeonConfigByID(self.info.dungeon_id)
	if self.dungeonInfo ~= nil then
		self._name = remote.activityInstance:getInstanceGroupNameByType(self.info.dungeon_type).."·"..self.info.instance_name.."    "..self.dungeonInfo.name
		self._ccbOwner.tf_title_name:setString(self._name)
		self._ccbOwner.tf_energy:setString(self.dungeonInfo.energy)
		self:getItemConfig()
		self:getMonsterConfig()
	end
	self._maxCount = remote.activityInstance:getAttackMaxCountByType(self.info.instance_id)

	self._ccbOwner.sp_activity_1:setVisible(self.info.instance_id == ACTIVITY_DUNGEON_TYPE.TREASURE_BAY)
	self._ccbOwner.sp_activity_2:setVisible(self.info.instance_id == ACTIVITY_DUNGEON_TYPE.STRENGTH_CHALLENGE)
	self._ccbOwner.sp_activity_3:setVisible(self.info.instance_id == ACTIVITY_DUNGEON_TYPE.BLACK_IRON_BAR)
	self._ccbOwner.sp_activity_4:setVisible(self.info.instance_id == ACTIVITY_DUNGEON_TYPE.WISDOM_CHALLENGE)

	self:_userUpdateHandler()
end

function QUIDialogActivityDungeon:viewDidAppear()
	QUIDialogActivityDungeon.super.viewDidAppear(self)
	self.prompt = app:promptTips()
	self.prompt:addItemEventListener(self)
	self.prompt:addMonsterEventListener()
	self:addBackEvent()
end

function QUIDialogActivityDungeon:viewWillDisappear()
  	QUIDialogActivityDungeon.super.viewWillDisappear(self)
 	self.prompt:removeItemEventListener()
    self.prompt:removeMonsterEventListener()
	self:removeBackEvent()
end

--获取关卡掉落信息
function QUIDialogActivityDungeon:getItemConfig()
	self._items = {}
	local dropItems = self.dungeonInfo.drop_item
	local dropItems = string.split(dropItems, ";")
	self._heroBreakNeedItems = remote.herosUtil:getAllHeroBreakNeedItem()
	for _,id in pairs(dropItems) do
        self:_setBoxInfo(id,ITEM_TYPE.ITEM,0)
	end
end

function QUIDialogActivityDungeon:_userUpdateHandler()
	self._attackCount = remote.activityInstance:getAttackCountByType(self.info.instance_id)
	self._ccbOwner.tf_count:setString(self._maxCount - self._attackCount)
	self._ccbOwner.tf_count_tips:setString("剩余次数：")
	self._ccbOwner.tf_count_tips:setColor(UNITY_COLOR.yellow)

	--xurui:检查扫荡功能解锁提示
	self._ccbOwner.node_reduce_effect:setVisible(app.tip:checkReduceUnlokState("activeFastBattle"))
end

function QUIDialogActivityDungeon:_setBoxInfo(itemID,itemType,num)
	local itemConfig = QStaticDatabase:sharedDatabase():getItemByID(itemID)
	if itemConfig == nil then return end
	local box = QUIWidgetItemsBox.new()
    box:setGoodsInfo(itemID,itemType,num)
    box:setPromptIsOpen(true)
    if self._heroBreakNeedItems[tonumber(itemID)] ~= nil and self._heroBreakNeedItems[tonumber(itemID)] > 0 then
    	box:showGreenTips(true)
    end
    self._ccbOwner["node_items"..(#self._items+1)]:addChild(box)
	table.insert(self._items, box)
end

--获取怪物配置生成怪物信息
function QUIDialogActivityDungeon:getMonsterConfig()
	self._ccbOwner.node_monster:setVisible(false)
	local monsterConfig = QStaticDatabase:sharedDatabase():getMonstersById(self.dungeonInfo.monster_id)
	local monsterData = {}
	if monsterConfig ~= nil and #monsterConfig > 0 then
		for i,value in pairs(monsterConfig) do
			-- TOFIX: SHRINK
			local value = q.cloneShrinkedObject(value)
			value.npc_index = i
			table.insert(monsterData, value)
		end
		table.sort(monsterData,function (a, b)
				if a.wave ~= b.wave then
					return a.wave > b.wave
				else
					return a.is_boss or false
				end
			end)
		--过滤重复的怪物
		local tempData = {}
		local tempData2 = {}
		for i,value in pairs(monsterData) do
			local npc_id = app:getBattleRandomNpcID(self.dungeonInfo.monster_id, value.npc_index, value.npc_id)
			if tempData[npc_id] == nil then
				tempData[npc_id] = 1
				local clone_value = clone(value)
				clone_value.npc_id = npc_id
				table.insert(tempData2,clone_value)
			end
		end
		monsterData = tempData2
	end
	
	--找出第一个显示avatar的怪物
	local avatarValue = nil
	for _,value in pairs(monsterData) do
		if value.display == true then
			avatarValue = value
			break
		end
		if avatarValue == nil then
			avatarValue = value
		end
	end
	self._monster = {}
	local count = 1
	for _,value in pairs(monsterData) do
		if count < 5 and value ~= avatarValue then
			self:generateMonster(value, self._ccbOwner["node_monster"..count], count)
			count = count + 1
		end
	end

	self._ccbOwner.node_monster:setVisible(true)
	local character = QStaticDatabase:sharedDatabase():getCharacterByID(avatarValue.npc_id)
	local characterData = QStaticDatabase:sharedDatabase():getCharacterData(avatarValue.npc_id, character.data_type, avatarValue.npc_difficulty, avatarValue.npc_level)
	self._ccbOwner.sp_boss:setVisible(avatarValue.is_boss == true)
	local breakthroughLevel,color = remote.herosUtil:getBreakThrough(characterData.breakthrough)
	self._ccbOwner.tf_name:setString("LV."..characterData.npc_level.."  "..character.name)
	self._ccbOwner.tf_name:setColor(BREAKTHROUGH_COLOR_LIGHT[color])
	if self._avatar == nil then
		self._avatar = QUIWidgetHeroInformation.new()
		self._avatar:setAvatar(avatarValue.npc_id, (character.boss_size or 1))
		local height = character.stars_high or 0
		self._avatar:setStarPositionOffset(160, height)
		if character.position ~= nil then
			local pos = string.split(character.position, ",")
			self._avatar:setPositionX(tonumber(pos[1] or 0))
			self._avatar:setPositionY(tonumber(pos[2] or 0))
		end
	    self._avatar:setNameVisible(false)
	    self._avatar:setBackgroundVisible(false)
	    self._avatar:setStarVisible(false)
		self._ccbOwner.node_avatar:addChild(self._avatar)
	end
	self._ccbOwner.tf_word:setString(self.dungeonInfo.description or "")
end

--生成怪物头像
function QUIDialogActivityDungeon:generateMonster(value, contain, index)
	if contain == nil then return end
	local index = #self._monster
	local character = QStaticDatabase:sharedDatabase():getCharacterByID(value.npc_id)
	local characterData = QStaticDatabase:sharedDatabase():getCharacterData(value.npc_id, character.data_type, value.npc_difficulty, value.npc_level)
	self._monster[index] = QUIWidgetMonsterHead.new(value)
	self._monster[index]:setHero(value.npc_id)
	self._monster[index]:setStar(characterData.grade or 0)
	self._monster[index]:setBreakthrough(characterData.breakthrough or 0)
	if value.is_boss == true then
		self._monster[index]:setIsBoss(true)
	else
		self._monster[index]:setIsBoss(false)
	end
	contain:addChild(self._monster[index])
end

function QUIDialogActivityDungeon:_onTriggerTeam(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_battle) == false then return end
	local isCanFast1, time = remote.activityInstance:checkCDTimeByType(self.info.instance_id)
	if isCanFast1 == false then
		app.tip:floatTip(q.timeToHourMinuteSecond(time, true) .. "后可再次挑战")
		return
	end

	local buyCount = remote.activityInstance:getBuyCountByType(self.info.instance_id)
	local vipCount = remote.activityInstance:getMaxBuyCountByType(self.info.instance_id)
	if self._attackCount >=  self._maxCount then
		if buyCount < vipCount then
			local num = remote.activityInstance:convertTypeToNum(self.info.instance_id)
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogBuyCount",
				options = {typeName = QUIDialogBuyCount["BUY_TYPE_" .. num], buyCallback = self:safeHandler(function () 
						self:_userUpdateHandler()
						self:_onTriggerQuickFightOne()
					end)}})
		else
			app.tip:floatTip("今日挑战次数已用完")
		end
	else
		local teamKey = nil
		if self.info.instance_id == ACTIVITY_DUNGEON_TYPE.TREASURE_BAY or self.info.instance_id == ACTIVITY_DUNGEON_TYPE.BLACK_IRON_BAR then
			teamKey = remote.teamManager.TIME_MACHINE_TEAM
		elseif self.info.instance_id == ACTIVITY_DUNGEON_TYPE.STRENGTH_CHALLENGE then
			teamKey = remote.teamManager.POWER_TEAM
		elseif self.info.instance_id == ACTIVITY_DUNGEON_TYPE.WISDOM_CHALLENGE then
			teamKey = remote.teamManager.INTELLECT_TEAM
		end

	    local team = remote.teamManager:getActorIdsByKey(teamKey, 1)
		if team == nil or #team == 0 then
			local teamVO = remote.teamManager:getTeamByKey(remote.teamManager.INSTANCE_TEAM)
		    remote.teamManager:saveTeamToLocal(teamVO, teamKey)
		end

		local dungeonArrangement = QDungeonArrangement.new({teamKey = teamKey, dungeonId = self.info.dungeon_id})
	    app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogTeamArrangement",
	     	options = {arrangement = dungeonArrangement}})
	end
end

function QUIDialogActivityDungeon:_onTriggerQuickFightOne(event)
	if q.buttonEventShadow(event, self._ccbOwner.button_fastbattle) == false then return end
	if event ~= nil then app.sound:playSound("common_small") end
	if app.unlock:checkLock("UNLOCK_ACTIVITY_QUICK_FIGHT") == false then
		app.unlock:tipsLock("UNLOCK_ACTIVITY_QUICK_FIGHT", "试炼宝屋扫荡", true)
		return
	end

	--xurui:设置扫荡功能解锁提示
	if app.tip:checkReduceUnlokState("activeFastBattle") then
		app.tip:setReduceUnlockState("activeFastBattle", 2)
		self._ccbOwner.node_reduce_effect:setVisible(false)
	end

	local buyCount = remote.activityInstance:getBuyCountByType(self.info.instance_id)
	local vipCount = remote.activityInstance:getMaxBuyCountByType(self.info.instance_id)
	if self._attackCount >=  self._maxCount then
		if buyCount < vipCount then
			local num = remote.activityInstance:convertTypeToNum(self.info.instance_id)
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogBuyCount",
				options = {typeName = QUIDialogBuyCount["BUY_TYPE_" .. num], buyCallback = self:safeHandler(function () 
						self:_userUpdateHandler()
						self:_onTriggerQuickFightOne()
					end)}})
		else
			app.tip:floatTip("今日挑战次数已用完")
		end
	else
		local startQuickBattle = function()
			local config = q.cloneShrinkedObject(self.dungeonInfo)
			local battleType = BattleTypeEnum.DUNGEON_ACTIVITY
			app:getClient():fightActivityDungeonQuickRequest(battleType, self.info.dungeon_id, 1, false,
				function(data)
					if self:safeCheck() then
						self:_userUpdateHandler()
						local isCanFast = remote.activityInstance:checkCDTimeByType(self.info.instance_id)
						local callback = nil
						-- local closeCallBack = nil
						if isCanFast == true then
							callback = handler(self, self._onTriggerQuickFightOne)
						else
							-- closeCallBack = handler(self, self.onTriggerBackHandler)
							callback = handler(self, self.onTriggerBackHandler)
						end
						if (vipCount ~= 0 and buyCount >= vipCount) or (vipCount == 0 and self._attackCount >=  self._maxCount) then
							isCanFast = false
							callback = nil
							-- closeCallBack = handler(self, self.onTriggerBackHandler)
							callback = handler(self, self.onTriggerBackHandler)
						end
						
						-- isCanFast = (buyCount < vipCount) or isCanFast
						app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogUnityFastBattle", 
							options = {fast_type = FAST_FIGHT_TYPE.DUNGEON_FAST, dungeon = config, awards = data.batchAwards, extraExpItem = data.extraExpItem, prizeWheelMoneyGot = data.prizeWheelMoneyGot, info = self.info, config = self.dungeonInfo, invasion = data.userIntrusionResponse,
							labelName = self._name, name = "连胜结算", callback = callback, isOnlyClose = true,isCanFast = isCanFast}},{isPopCurrentDialog = false})
					end
					remote.activity:updateLocalDataByType(555, 1)
			        --xurui: 更新每日宗门副本活跃任务
			        remote.union.unionActive:updateActiveTaskProgress(20004, 6)
					app.taskEvent:updateTaskEventProgress(app.taskEvent.TIMEMACHINE_TASK_EVENT, 1, false, true)
				end, nil)
		end

		local isCanFast1, time = remote.activityInstance:checkCDTimeByType(self.info.instance_id)
		if isCanFast1 == false then
			app.tip:floatTip(q.timeToHourMinuteSecond(time, true) .. "后可再次挑战")
			return
		end
		
		local passInfo = remote.activityInstance:getPassInfoById(self.info.dungeon_id)
		if passInfo.star < 3 then
			local herosInfos, count, force = remote.herosUtil:getMaxForceHeros()
			local isRecommend = force > (self.dungeonInfo.thunder_force or 0)
			local text = ""  
			if self.info.instance_id == ACTIVITY_DUNGEON_TYPE.STRENGTH_CHALLENGE or self.info.instance_id == ACTIVITY_DUNGEON_TYPE.WISDOM_CHALLENGE then
				if isRecommend then
					text = "##f您历史最高伤害是##w"..(passInfo.hisMaxHurtBossHp/10).."##f%，只能获取部分奖励。您的战队现在的魂力，可以完全击败敌人，是否继续扫荡？"
				else
					text = "##f您历史最高伤害是##w"..(passInfo.hisMaxHurtBossHp/10).."##f%，是否按照此战绩进行一次扫荡"
				end
			else
				if isRecommend then
					text = "##f您历史击杀数量为##w"..passInfo.hisMaxKillEnemyCount.."##f，只能获取部分奖励。您的战队现在的魂力，可以完全击败敌人，是否继续扫荡？"
				else
					text = "##f您历史的最高击杀为##w"..passInfo.hisMaxKillEnemyCount.."##f，是否按照此杀敌数进行一次扫荡"
				end
			end
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogTimeMachineAlert",
				options = {text = text, type = self.info.dungeon_type,
					callback = function(state)
	                    if state == ALERT_TYPE.CONFIRM then
	                        startQuickBattle()
	                    end
	                end}})
		else
			startQuickBattle()
		end
	end
end

-- 对话框退出
function QUIDialogActivityDungeon:onTriggerBackHandler(tag, menuItem)
	app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
end

-- 对话框退出
function QUIDialogActivityDungeon:onTriggerHomeHandler(tag, menuItem)
	app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
end

return QUIDialogActivityDungeon