-- @Author: xurui
-- @Date:   2019-12-25 16:50:42
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-02-26 16:16:58
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogTotemChallengeMain = class("QUIDialogTotemChallengeMain", QUIDialog)

local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QUIWidgetTotemChallengeClient = import("..widgets.QUIWidgetTotemChallengeClient")
local QListView = import("...views.QListView")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QUIWidgetFcaAnimation = import("..widgets.actorDisplay.QUIWidgetFcaAnimation")
local QTutorialEvent = import("...tutorial.event.QTutorialEvent")

function QUIDialogTotemChallengeMain:ctor(options)
	local ccbFile = "ccb/Dialog_totemChallenge_main.ccbi"
    local callBacks = {
        {ccbCallbackName = "onTriggerStore", callback = handler(self, self._onTriggerStore)},
        {ccbCallbackName = "onTriggerRule", callback = handler(self, self._onTriggerRule)},
    }
    QUIDialogTotemChallengeMain.super.ctor(self, ccbFile, callBacks, options)
    self._page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    if self._page.setManyUIVisible then self._page:setManyUIVisible() end
    if self._page.topBar.showWithStyle then 
    	self._page.topBar:showWithStyle({TOP_BAR_TYPE.MONEY, TOP_BAR_TYPE.TOKEN_MONEY, TOP_BAR_TYPE.GOD_ARM_MONEY, TOP_BAR_TYPE.BATTLE_FORCE})
    end

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
    CalculateUIBgSize(self._ccbOwner.sp_bg)

	self._userInfoDict = {}
	self._rivalsList = {}
	self._awardItemBox = {}
	self._awardNumTF = {}

	q.setButtonEnableShadow(self._ccbOwner.btn_store)
	self._ccbOwner.sheet_layout:setContentSize(CCSize(display.ui_width, 520))
	self._ccbOwner.sheet_layout:setPositionY(-315)

	self:requestInfo()

	self._ccbOwner.tf_reset_time:setString("")

	self:initListView()
end

function QUIDialogTotemChallengeMain:viewDidAppear()
	QUIDialogTotemChallengeMain.super.viewDidAppear(self)

	QNotificationCenter.sharedNotificationCenter():addEventListener(QNotificationCenter.EVENT_EXIT_FROM_BATTLE, self._exitFromBattle, self)

	self._totemChallengeEventProxy = cc.EventProxy.new(remote.totemChallenge)
	self._totemChallengeEventProxy:addEventListener(remote.totemChallenge.UPDATE_EVENT, handler(self, self._update))
	self._totemChallengeEventProxy:addEventListener(remote.totemChallenge.UPDATE_RESET_TIME_STR, handler(self, self.setResetTime))

	self:updateInfo()
	self:_checkPoster()
	self:addBackEvent(true)
end

function QUIDialogTotemChallengeMain:viewWillDisappear()
  	QUIDialogTotemChallengeMain.super.viewWillDisappear(self)

	QNotificationCenter.sharedNotificationCenter():removeEventListener(QNotificationCenter.EVENT_EXIT_FROM_BATTLE, self._exitFromBattle, self)

	self._totemChallengeEventProxy:removeAllEventListeners()

	self:removeBackEvent()
end

function QUIDialogTotemChallengeMain:_exitFromBattle()
	if self:safeCheck() == false then return end

	self:updateInfo()

	local passRivalPos = remote.totemChallenge:getDungeonPassRivalPos()
	local config = remote.totemChallenge:getDungeonConfigById(passRivalPos)
	if config then
		local floorRewardConfig = remote.totemChallenge:getFloorRewardConfigByFloor(config.level)
		if tostring(floorRewardConfig.id) == tostring(config.id) then
			self:showFloorAwards(config)
		else
			self:showPassEffect(config)
		end
	end
end

function QUIDialogTotemChallengeMain:_update()
	self:updateInfo()
	self:_checkPoster()
end

function QUIDialogTotemChallengeMain:updateInfo()
	if self:safeCheck() == false then return end

	self:updateCurrentDungeonInfo()

	self:setTitleInfo()

	self:initListView()

	self:checkShopTip()
end

-- 进入功能后的各种弹脸
function QUIDialogTotemChallengeMain:_checkPoster()
	-- print("QUIDialogTotemChallengeMain:_checkPoster()")
	if not self:_checkWeekAward() then
		local awardInfo = remote.totemChallenge:getTotemChallengeFloorAward()
		-- QKumo(awardInfo)
		if not q.isEmpty(awardInfo) then
			return
		end
		self._userInfoDict = remote.totemChallenge:getTotemUserDungeonInfo()
		-- QKumo(self._userInfoDict)
		if self._userInfoDict and self._userInfoDict.totalNum == remote.totemChallenge.NO_ID 
			and (not self._userInfoDict.intoLayer or self._userInfoDict.intoLayer == remote.totemChallenge.NO_TYPE)
			and remote.totemChallenge:checkUnlockModelChooseByFloor(tonumber(self._userInfoDict.currentFloor) + 1) then
				self:_showModelChoose()
		else
			self._userInfoDict = remote.totemChallenge:getTotemUserDungeonInfo()
			if self._userInfoDict then
				local config = remote.totemChallenge:getDungeonConfigById(self._userInfoDict.totalNum or 1)
				if config and remote.totemChallenge:hasHardModelByFloor(config.level) then
					-- 有可攻打关卡,且是有困难模式的层级
					self:_checkTutorialTotemChallengeQuickPass()
				end
			end
		end
	end
end

function QUIDialogTotemChallengeMain:_checkTutorialTotemChallengeQuickPass()
	 if app.tutorial and app.tutorial:isTutorialFinished() == false then
        local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
        if page.buildLayer then
            page:buildLayer()
        end
        local haveTutorial = false
        if app.tutorial:getStage().totemChallengeQuickPass == app.tutorial.Guide_Start then
            haveTutorial = app.tutorial:startTutorial(app.tutorial.Statge_TotemChallengeQuickPass)
        end
        if haveTutorial == false and page.cleanBuildLayer then
            page:cleanBuildLayer()
        end
    end
end

function QUIDialogTotemChallengeMain:requestInfo()
	remote.totemChallenge:requestTotemChallengeMainInfo(function()
		self:updateInfo()
	end)
end

function QUIDialogTotemChallengeMain:updateCurrentDungeonInfo()
	self._userInfoDict = remote.totemChallenge:getTotemUserDungeonInfo()
	self._rivalsList = remote.totemChallenge:getTotemChallengeRivals()
	table.sort(self._rivalsList, function(a, b)
		if a.rivalPos ~= b.rivalPos then
			return a.rivalPos < b.rivalPos
		else
			return false
		end
	end)

	self._levelConfig = remote.totemChallenge:getDungeonConfigByLevel(self._userInfoDict.currentFloor) or {}
end

function QUIDialogTotemChallengeMain:setTitleInfo()
	local config = self._levelConfig[tostring(self._userInfoDict.totalNum or 1)] or {}
	if q.isEmpty(config) then
		self._ccbOwner.tf_dungeon_title:setString("已全部通关")
		self._ccbOwner.tf_dungeon_title:setPositionY(-108)
		self._ccbOwner.tf_name:setVisible(false)
		self._ccbOwner.tf_type:setVisible(false)
		self._ccbOwner.node_award:removeAllChildren()
		self._ccbOwner.tf_award_title:setVisible(false)
		self._awardNumTF = {}
		self._awardItemBox = {}
		return
	end
	
	self._ccbOwner.tf_type:setVisible(false)
	self._ccbOwner.tf_name:setVisible(true)
	self._ccbOwner.tf_award_title:setVisible(true)
	self._ccbOwner.tf_dungeon_title:setPositionY(-96)
	self._ccbOwner.tf_dungeon_title:setString((config.name or "")..":")
	local nameStr = string.format("%s-%s", (self._userInfoDict.currentFloor or 1), (self._userInfoDict.currentDungeon or 1))
	-- if config.type == remote.totemChallenge.HARD_TYPE then
	-- 	nameStr = nameStr.."（困难）"
	-- end
	self._ccbOwner.tf_name:setString(nameStr)
	local titleContentSize = self._ccbOwner.tf_dungeon_title:getContentSize()
	self._ccbOwner.tf_name:setPositionX(17 + titleContentSize.width + 5)
	if config.type == remote.totemChallenge.HARD_TYPE then
		self._ccbOwner.tf_type:setVisible(true)
		self._ccbOwner.tf_type:setString("（困难）")
		local nameContentSize = self._ccbOwner.tf_name:getContentSize()
		self._ccbOwner.tf_type:setPositionX(self._ccbOwner.tf_name:getPositionX() + nameContentSize.width + 5)
	end

	for i, value in ipairs(self._awardItemBox) do
		value:setVisible(false)
		if self._awardNumTF[i] then
			self._awardNumTF[i]:setVisible(false)
		end
	end
	local scale = 0.4
	local totalWidth = 0
	local rewardConfig = remote.totemChallenge:getFloorRewardConfigByFloor(self._userInfoDict.currentFloor or 1)
	local reward = db:getLuckyDrawAwardTable(rewardConfig.chapter_reward)
	for i, value in ipairs(reward) do
		if self._awardItemBox[i] == nil then
			self._awardItemBox[i] = QUIWidgetItemsBox.new()
			self._ccbOwner.node_award:addChild(self._awardItemBox[i])
			self._awardItemBox[i]:setScale(scale)
			
			if self._awardNumTF[i] == nil then
				self._awardNumTF[i] = CCLabelTTF:create("", global.font_default, 20)
				self._ccbOwner.node_award:addChild(self._awardNumTF[i])
				self._awardNumTF[i]:setAnchorPoint(ccp(0, 0.5))
			end
		end
		self._awardItemBox[i]:setGoodsInfo(value.id, value.itemType, 0)
		self._awardItemBox[i]:setVisible(true)
		self._awardNumTF[i]:setString(string.format("%s", value.count))
		self._awardNumTF[i]:setVisible(true)

		self._awardItemBox[i]:setPositionX(totalWidth)
		local itemContentSize = self._awardItemBox[i]:getContentSize()
		totalWidth = totalWidth + (itemContentSize.width * scale)/2 + 10

		self._awardNumTF[i]:setPositionX(totalWidth)
		local tffContentSize = self._awardNumTF[i]:getContentSize()
		totalWidth = totalWidth + tffContentSize.width + 30
	end
end

function QUIDialogTotemChallengeMain:setResetTime(event)
	if event == nil then return end

	local isReset = event.isReset 
	if isReset then
		self:updateInfo()
		self:_checkPoster()
	end

	local timeStr = event.timeStr
	if timeStr then
		self._ccbOwner.tf_reset_time:setString(timeStr)
	end
end

function QUIDialogTotemChallengeMain:initListView()
	local headIndex = (self._userInfoDict.currentDungeon or 1) - 1
	headIndex = headIndex > 3 and 3 or headIndex
	local totalNumber = #self._rivalsList or 0

	if not self._listView then
		local cfg = {
			renderItemCallBack = function( list, index, info )
	            -- body
	            local isCacheNode = true
	            local itemData = self._rivalsList[index]
	            local item = list:getItemFromCache(itemData.oType)
	            if not item then
	            	item = QUIWidgetTotemChallengeClient.new()
	            	item:addEventListener(QUIWidgetTotemChallengeClient.EVENT_CLICK_CHALLENGE, handler(self, self._onEvent))
	            	item:addEventListener(QUIWidgetTotemChallengeClient.EVENT_CLICK_VISIT, handler(self, self._onEvent))
	            	isCacheNode = false
	            end
	            item:setInfo(itemData, index)
	            info.tag = itemData.oType
	            info.item = item
	            info.size = item:getContentSize()
 
	            list:registerBtnHandler(index, "btn_visit", "_onTriggerVisit", nil, true)
	            list:registerBtnHandler(index, "btn_challenge", "_onTriggerChallenge", nil, true)
	            list:registerBtnHandler(index, "btn_click", "_onTriggerChallenge")

	            return isCacheNode
	        end,
	        curOriginOffset = 5,
	        curOffset = 20,
	        enableShadow = false,
	      	ignoreCanDrag = true,
	        totalNumber = totalNumber,
	        isVertical = false,
	        spaceX = -5,
		}
		self._listView = QListView.new(self._ccbOwner.sheet_layout,cfg)
	else
		self._listView:reload({totalNumber = totalNumber, headIndex = headIndex})
	end
end

function QUIDialogTotemChallengeMain:_onEvent(event)
	if event == nil then return end
	
	local callback = event.callback
	remote.totemChallenge:requestTotemChallengeFighterInfo(event.info.rivalPos, function(data)
		local fighterInfo = data.totemChallengeQueryFightResponse.battle or {}
		if event.name == QUIWidgetTotemChallengeClient.EVENT_CLICK_CHALLENGE then
		app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogTotemChallengeFighterInfo", 
				options = {dungeonInfo = event.info, fighterInfo = fighterInfo}},{isPopCurrentDialog = true})
		elseif event.name == QUIWidgetTotemChallengeClient.EVENT_CLICK_VISIT then
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogStromArenaPlayerInfo",
		    	options = {fighterInfo = fighterInfo.fighter or {}}}, {isPopCurrentDialog = false})
		end
		if callback then
			callback()
		end
	end)
end

function QUIDialogTotemChallengeMain:checkShopTip()
	self._ccbOwner.sp_store_tips:setVisible(remote.totemChallenge:checkStoreTips())
end

function QUIDialogTotemChallengeMain:_checkWeekAward()
	local awardInfo = remote.totemChallenge:getTotemChallengeWeekAward()
	if q.isEmpty(awardInfo) == false then
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass="QUIDialoTotemChallengeWeekAward",
	    	options = {callback = self:safeHandler(handler(self, self._checkSkipAward))}}, {isPopCurrentDialog = false})
		return true
	end
	return false
end

function QUIDialogTotemChallengeMain:_checkSkipAward()
    self._userInfoDict = remote.totemChallenge:getTotemUserDungeonInfo()
	if self._userInfoDict.stairsNum > 1 then
		local tbl = {}
		local awards = {}
		for i = 1, self._userInfoDict.stairsNum, 1 do
			local rewardConfig = remote.totemChallenge:getDungeonRewardConfigById(i)
			local rewardTbl = db:getLuckyDrawAwardTable(rewardConfig.reward)
			for _, value in pairs(rewardTbl) do
				if value.id then
					local count = (tbl[value.id] and tbl[value.id].count or 0) + value.count
					tbl[value.id] =  {id = value.id, itemType = value.itemType, count = count}
				else
					local count = (tbl[value.itemType] and tbl[value.itemType].count or 0) + value.count
					tbl[value.itemType] =  {id = value.id, itemType = value.itemType, count = count}
				end
			end
			if rewardConfig.chapter_reward then
				local chapterRewardTbl = db:getLuckyDrawAwardTable(rewardConfig.chapter_reward)
				for _, value in pairs(chapterRewardTbl) do
					if value.id then
						local count = (tbl[value.id] and tbl[value.id].count or 0) + value.count
						tbl[value.id] =  {id = value.id, itemType = value.itemType, count = count}
					else
						local count = (tbl[value.itemType] and tbl[value.itemType].count or 0) + value.count
						tbl[value.itemType] =  {id = value.id, itemType = value.itemType, count = count}
					end
				end
			end
		end
		for _, v in pairs(tbl) do
			table.insert(awards, {id = v.id, typeName = v.itemType, count = v.count})
		end

		if #awards > 0 then
			local id = self._userInfoDict.totalNum ~= remote.totemChallenge.NO_ID and self._userInfoDict.totalNum or self._userInfoDict.stairsNum
			local config = remote.totemChallenge:getDungeonConfigById(id)
			local text = ""
			if config then
				text = "魂师大人，由于您上周在圣柱挑战的出色成绩，本周您将从关卡"..config.level.."-"..config.wave.."开始挑战，且奖励已发放到背包"
			else
				text = "魂师大人，由于您上周在圣柱挑战的出色成绩，本周您将新的起点开始挑战，且奖励已发放到背包"
			end
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass="QUIDialogTotemChallengeSkipAward",
	    		options = {awards = awards, text = text, callback = self:safeHandler(handler(self, self._checkPoster))}}, {isPopCurrentDialog = false})
			return
		end
	end
	self:_checkPoster()
end

function QUIDialogTotemChallengeMain:showFloorAwards(passRivalConfig)
	local awardInfo = remote.totemChallenge:getTotemChallengeFloorAward()

	if q.isEmpty(awardInfo) == false then
		remote.totemChallenge:setTotemChallengeFloorAward({})
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogTotemChallengeFloorAward",
    		options = {awardInfo = awardInfo, config = passRivalConfig, callback = self:safeHandler(handler(self, self._checkPoster))}}, {isPopCurrentDialog = false})
	end
end

function QUIDialogTotemChallengeMain:_showModelChoose()
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass="QUIDialogTotemChallengeChoose",
		options = {}}, {isPopCurrentDialog = false})
	self:_checkTutorialTotemChallengeChoose()
end

function QUIDialogTotemChallengeMain:_checkTutorialTotemChallengeChoose()
    if app.tutorial and app.tutorial:isTutorialFinished() == false then
        local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
        if page.buildLayer then
            page:buildLayer()
        end
        local haveTutorial = false
        if app.tutorial:getStage().totemChallengeChoose == app.tutorial.Guide_Start then
            haveTutorial = app.tutorial:startTutorial(app.tutorial.Statge_TotemChallengeChoose)
        end
        if haveTutorial == false and page.cleanBuildLayer then
            page:cleanBuildLayer()
        end
    end
end

function QUIDialogTotemChallengeMain:showPassEffect(passRivalConfig)
	local passIndex = tonumber(passRivalConfig.wave)
	local currentIndex = tonumber(passRivalConfig.wave) + 1
 
	if self._listView then
		self:enableTouchSwallowTop()
		local passItemClient = self._listView:getItemByIndex(passIndex)
		local currentItemClient = self._listView:getItemByIndex(currentIndex)
		if passItemClient and currentItemClient then
			currentItemClient:setDungeonState(false)
			passItemClient:setDungeonState(true)

			--盖章
			passItemClient:showPassEffect(function()
				local passEffectNode = passItemClient:getEffectNode()
				local currentEffectNode = currentItemClient:getEffectNode()
				local startPos = passEffectNode:convertToWorldSpaceAR(ccp(0, 0))
				startPos = ccp(startPos.x - display.cx, startPos.y - display.cy)
				local endPos = currentEffectNode:convertToWorldSpaceAR(ccp(0, 0))
				endPos = ccp(endPos.x - display.cx, endPos.y - display.cy)

				local rotation = 7.9
				if passIndex%2 ~= 0 then
					rotation = -rotation
				end
				local fcaAnimation1 = QUIWidgetFcaAnimation.new("fca/szgk_jdt", "res")
				fcaAnimation1:playAnimation("animation", false)
				fcaAnimation1:setEndCallback(function( )
					fcaAnimation1:removeFromParent()
					local fcaAnimation2 = QUIWidgetFcaAnimation.new("fca/szgk_chuxian", "res")
					fcaAnimation2:playAnimation("animation", false)
					self:getView():addChild(fcaAnimation2)
					fcaAnimation2:setPosition(endPos)
					fcaAnimation2:setScale(0.25)
					fcaAnimation2:setEndCallback(function( )
						currentItemClient:setDungeonState(true)
						fcaAnimation2:removeFromParent()
						self:disableTouchSwallowTop()
					end)
				end)
				fcaAnimation1:setRotation(rotation)
				fcaAnimation1:setPosition(startPos)
				self:getView():addChild(fcaAnimation1)
			end)
		end
	end
end

function QUIDialogTotemChallengeMain:_onTriggerStore()
	app.sound:playSound("common_small")

	remote.stores:openShopDialog(SHOP_ID.godarmShop)
end

function QUIDialogTotemChallengeMain:_onTriggerRule()
	app.sound:playSound("common_small")

	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogTotemChallengeHelp",
		options = {info = self.myInfo}})
end

return QUIDialogTotemChallengeMain
