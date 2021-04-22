--
-- Author: Kumo.Wang
-- Date: Thu May 19 17:52:33 2016
-- 宗门副本的二级场景
--
local QUIDialogBaseUnion = import(".QUIDialogBaseUnion")
local QUIDialogSocietyDungeon = class("QUIDialogSocietyDungeon", QUIDialogBaseUnion)

local QUIViewController = import("..QUIViewController")
local QUIWidgetSocietyDungeonBoss = import("..widgets.QUIWidgetSocietyDungeonBoss")
local QUIWidgetChest = import("..widgets.QUIWidgetChest")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QNavigationController = import("...controllers.QNavigationController")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QUIWidgetSocietyDungeonMap = import("..widgets.QUIWidgetSocietyDungeonMap")
local QVIPUtil = import("...utils.QVIPUtil")
local QUIGestureRecognizer = import("..QUIGestureRecognizer")


function QUIDialogSocietyDungeon:ctor(options)
	local ccbFile = "ccb/Dialog_society_fuben_new.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerRule", callback = handler(self, self._onTriggerRule)},
		{ccbCallbackName = "onTriggerReset", callback = handler(self, self._onTriggerReset)},
		{ccbCallbackName = "onTriggerAward", callback = handler(self, self._onTriggerAward)},
		{ccbCallbackName = "onTriggerPlus", callback = handler(self, self._onTriggerPlus)},
		{ccbCallbackName = "onTriggerClickRank", callback = handler(self, self._onTriggerClickRank)},
		{ccbCallbackName = "onTriggerShop", callback = handler(self, self._onTriggerShop)},
		{ccbCallbackName = "onTriggerSetting", callback = handler(self, self._onTriggerSetting)},
		{ccbCallbackName = "onTriggerOneOpen", callback = handler(self, self._onTriggerOneOpen)},
		{ccbCallbackName = "onTriggerValidRank", callback = handler(self, self._onTriggerValidRank)},
	}
	QUIDialogSocietyDungeon.super.ctor(self, ccbFile, callBacks, options)
	self._touchLayer = nil
	q.setButtonEnableShadow(self._ccbOwner.btn_valid_rank)
end

function QUIDialogSocietyDungeon:viewDidAppear()
	QUIDialogSocietyDungeon.super.viewDidAppear(self)
	remote.union:unionGetBossListRequest(function(data)
			if self:safeCheck() then
				self:_updateValidInfo(data)
			end
		end)
	self.unionProxy = cc.EventProxy.new(remote.union)
    self.unionProxy:addEventListener(remote.union.SOCIETY_BUY_FIGHT_COUNT_SUCCESS, handler(self, self.updateUnionHandler))
    self.unionProxy:addEventListener(remote.union.SOCIETY_RECEIVED_AWARD_SUCCESS, handler(self, self.updateUnionHandler))
    self.unionProxy:addEventListener(remote.union.SOCIETY_RECEIVED_CHEST_SUCCESS, handler(self, self.updateUnionHandler))
    self.unionProxy:addEventListener(remote.union.SOCIETY_BOSS_DEAD, handler(self, self.updateUnionHandler))
    self.unionProxy:addEventListener(remote.union.NEW_DAY, handler(self, self.updateUnionHandler))
    self.unionProxy:addEventListener(remote.union.SOCIETY_EXIT_ROBOT, handler(self, self._exitFromBattle))
    QNotificationCenter.sharedNotificationCenter():addEventListener(QNotificationCenter.EVENT_EXIT_FROM_BATTLE, self._exitFromBattle, self)


    self:madeTouchLayer()
    
  --   remote.flag:get({remote.flag.FLAG_FRIST_ROBOTFORSOCIETY}, function (tbl)
		-- 	if tbl[remote.flag.FLAG_FRIST_ROBOTFORSOCIETY] == "" then
		-- 		self._ccbOwner.node_effect:setVisible(true)
		-- 	end
		-- end)
    if not app.unlock:checkLock("UNLOCK_ZONGMENYIJIANKAIXIANG", false) then
        self._ccbOwner.node_yjkx:setVisible(false)
    else
        self._ccbOwner.node_yjkx:setVisible(true)
        self._ccbOwner.node_yjkx_effect:setVisible(not app:getUserData():getValueForKey("UNLOCK_ZONGMENYIJIANKAIXIANG"..remote.user.userId))
    end	

    self:showOneOpenRedTips()

end

function QUIDialogSocietyDungeon:viewWillDisappear()
	QUIDialogSocietyDungeon.super.viewWillDisappear(self)

	self.unionProxy:removeAllEventListeners()
	QNotificationCenter.sharedNotificationCenter():removeEventListener(QNotificationCenter.EVENT_EXIT_FROM_BATTLE, self._exitFromBattle, self)

	if self._scheduler then
		scheduler.unscheduleGlobal(self._scheduler)
		self._scheduler = nil
	end

	if self._chestScheduler then
		scheduler.unscheduleGlobal(self._chestScheduler)
		self._chestScheduler = nil
	end
	
	for _, manager in pairs(self._aniManagers or {} ) do
        manager:stopAnimation()
        manager = nil
    end
    self._aniManagers = {}

    for _, view in pairs(self._aniCcbViews or {} ) do
        view:removeFromParent()
        view = nil
    end
    self._aniCcbViews = {}
    if self._touchLayer then
	    self._touchLayer:removeAllEventListeners()
	    self._touchLayer:disable()
	    self._touchLayer:detach()
    end

end

function QUIDialogSocietyDungeon:onTriggerBackHandler()
	if self._isAnimationPlaying then return end
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
end

function QUIDialogSocietyDungeon:_onTriggerChest( wave )
	app.sound:playSound("common_small")
	if self._isAnimationPlaying then return end
	remote.union:unionGetBossListRequest(function (data)
		if self:safeCheck() then
			self:_updateValidInfo(data)
		end
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSocietyDungeonChest", options = {wave = wave, callBack = handler(self, self._initBossInfo)}}, {isPopCurrentDialog = false})
	end, function ()
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSocietyDungeonChest", options = {wave = wave, callBack = handler(self, self._initBossInfo)}}, {isPopCurrentDialog = false})
		app.tip:floatTip("魂师大人，当前网络不稳定，宝藏信息可能出现滞后现象")
	end)
end

function QUIDialogSocietyDungeon:_onTriggerRule()
	app.sound:playSound("common_small")
	if self._isAnimationPlaying then return end
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSocietyDungeonRuleNew"})
end

function QUIDialogSocietyDungeon:_onTriggerReset()
	app.sound:playSound("common_small")
	if self._isAnimationPlaying then return end
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSocietyDungeonReset", options = {resetMode = 0}}, {isPopCurrentDialog = false})
end

function QUIDialogSocietyDungeon:_onTriggerAward()
	app.sound:playSound("common_small")
	if self._isAnimationPlaying then return end
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogSocietyDungeonAward"}, {isPopCurrentDialog = false} )
end

function QUIDialogSocietyDungeon:_onTriggerShop()
	app.sound:playSound("common_small")
	if self._isAnimationPlaying then return end
	remote.stores:openShopDialog(SHOP_ID.consortiaShop)
end 

function QUIDialogSocietyDungeon:_onTriggerPlus(e)
	if q.buttonEventShadow(e, self._ccbOwner.btn_plus) == false then return end
	if e then
		app.sound:playSound("common_small")
	end
	if self._isAnimationPlaying then return end

	if remote.union:checkUnionDungeonIsOpen(true) == false then
		return
	end
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogBuyCountBase", options = {cls = "QBuyCountUnionInstance"}})
end

function QUIDialogSocietyDungeon:_onTriggerClickRank()
	-- remote.union:newDayUpdate()
	app.sound:playSound("common_small")
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogRank", 
		options = {initRank = "union", initChildRank = 3}}, {isPopCurrentDialog = false})
end

function QUIDialogSocietyDungeon:_onTriggerValidRank()
	app.sound:playSound("common_small")
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSocietyDungeonValidInfo", 
		options = {}})
end

function QUIDialogSocietyDungeon:_onTriggerSetting()
	app.sound:playSound("common_small")

    if remote.union:checkUnionRight() then
        app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogSocietyDungeonSetting", 
			options = {callback = handler(self, self._initBossInfo)}})
    else
        app.tip:floatTip("只有宗主可以设置")
    end
end

function QUIDialogSocietyDungeon:_onTriggerOneOpen(e)
	if q.buttonEventShadow(e, self._ccbOwner.btn_yjkx) == false then return end
	app.sound:playSound("common_small")
	
	if not app:getUserData():getValueForKey("UNLOCK_ZONGMENYIJIANKAIXIANG"..remote.user.userId) then
		app:getUserData():setValueForKey("UNLOCK_ZONGMENYIJIANKAIXIANG"..remote.user.userId, "true")
        self._ccbOwner.node_yjkx_effect:setVisible(false)
	end

	if remote.union:checkUnionDungeonIsOpen(true) == false then
		return
	end
	
	remote.union:unionBossGetAllWaveRewardRequest(false, function(response )
		-- 开启宝箱成功，播放获奖界面动画，更新宝箱的状态
		if response.consortiaGetAllWaveRewardResponse then

			local rewardResponse = response.consortiaGetAllWaveRewardResponse
			local awards = self:switchAwards(response.consortiaGetAllWaveRewardResponse)
		    self:_showOpenChestAwrdsInfo(awards)
		  --   local items = {}
		  --   for _, value in pairs(awards) do
				-- table.insert(items, {type = tonumber(value.id), count = tonumber(value.count)})
		  --   end	   
		    if response.items then 
		    	remote.items:setItems(response.items) 
		    end

			local wallet = {}
			remote.user:update( wallet )
	
		    -- remote.items:setItems( items ) 
	

		    self:showOneOpenRedTips()
		else
			app.tip:floatTip("当前没有可以打开的宝箱！")
		end
	end,function()
		app.tip:floatTip("当前没有可以打开的宝箱！")
	end)	
end
-- function QUIDialogSocietyDungeon:_onTriggerRight()
-- 	app.sound:playSound("common_small")
-- 	if self._isAnimationPlaying then return end
-- 	self._chapter = self._chapter + 1
-- 	remote.union:setShowChapter(self._chapter)
-- 	self:_showCloud()
-- end

function QUIDialogSocietyDungeon:switchAwards( awards )
	if not awards or table.nums(awards) == 0 then return end

    local tbl = {}
    local awardList = {}
	local luckAwardList = {}
    for _, value in pairs(awards.waveRewards) do
    	if self._chapter == value.chapter then
	    	if self._chestList[value.wave] then 
	    		self._chestList[value.wave]:setOpened()
	    	end
    	end
    	luckAwardList = remote.union:analyseLuckAwards(value.wave, value.chapter)
        local b = value.reward
        tbl = {}
        local s, e = string.find(b, "%^")
        local idOrType = string.sub(b, 1, s - 1)
        local itemCount = tonumber(string.sub(b, e + 1))
        local itemType = remote.items:getItemType(idOrType) or ITEM_TYPE.ITEM
        local isLucky = false
        for _,v in pairs(luckAwardList) do
        	if tonumber(v.itemCount) == itemCount then
        		isLucky = true
        		break
        	end
        end

		table.insert(awardList, {id = idOrType, typeName = itemType, count = itemCount,isLucky = isLucky})
    end
    return awardList
end

function QUIDialogSocietyDungeon:updateUnionHandler( event )
	if event.name == remote.union.SOCIETY_BUY_FIGHT_COUNT_SUCCESS then
		self:_updateMapInfo()
	elseif event.name == remote.union.SOCIETY_RECEIVED_AWARD_SUCCESS then
		-- 刷新通关奖励小红点
		-- if remote.union:checkSocietyDungeonAwardRedTips() then
		-- 	self._ccbOwner.award_tips:setVisible(true)
		-- else
		-- 	self._ccbOwner.award_tips:setVisible(false)
		-- end
	elseif event.name == remote.union.SOCIETY_RECEIVED_CHEST_SUCCESS then
		-- 刷新宝箱奖励小红点
		-- if remote.union:checkSocietyDungeonChestRedTips(self._chapter) then
		-- 	self._ccbOwner.sp_yjkx_tips:setVisible(true)
		-- else
		-- 	self._ccbOwner.sp_yjkx_tips:setVisible(false)
		-- end
	elseif event.name == remote.union.SOCIETY_BOSS_DEAD then
		self:_updateBossHp(true)
		self:_initBossInfo()
	    self:_updateMapInfo()
	    self:showOneOpenRedTips()
	elseif event.name == remote.union.NEW_DAY then
		self:_showCloud()
	end
end

function QUIDialogSocietyDungeon:_exitFromBattle()
	print("QUIDialogSocietyDungeon:_exitFromBattle()", remote.union.consortia.exp)
	local _, wave = remote.union:getSocietyDungeonFightInfo()
	remote.union:setSocietyDungeonFightInfo(false, 0, 0)
	local checkSpecial =  self:_updateBossHp()
	self:_initBossInfo()
    self:_updateMapInfo()
	remote.union:unionGetBossListRequest(function(data)
			if self:safeCheck() then
				self:_updateValidInfo(data)
			end
		end)
    self:showOneOpenRedTips()

	if checkSpecial then
		self:_checkShowSpecialAward()
	end

    QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QNotificationCenter.UNION_WIDGET_NAME_UPDATE})
end

function QUIDialogSocietyDungeon:showOneOpenRedTips()
	if remote.union:checkSocietyDungeonChestRedTips(self._chapter) then
		self._ccbOwner.sp_yjkx_tips:setVisible(true)
	else
		self._ccbOwner.sp_yjkx_tips:setVisible(false)
	end
end
function QUIDialogSocietyDungeon:madeTouchLayer()
	self._size = self._ccbOwner.node_mask:getContentSize()
	self._pageWidth = display.width
	self._pageHeight = self._size.height
	self._mapContent = self._ccbOwner.node_map
	self._orginalPosition = ccp(self._mapContent:getPosition())
	self._orginalPosition = ccp(0,0)
    CalculateBattleUIPosition(self._ccbOwner.node_offside , true)

	-- print(" QUIDialogSocietyDungeon:madeTouchLayer(1) " , self._orginalPosition.x, self._orginalPosition.y)
	-- print(" QUIDialogSocietyDungeon:madeTouchLayer(2) " , self._pageWidth, self._pageHeight)
	self._touchLayer = QUIGestureRecognizer.new()
	self._touchLayer:setSlideRate(0.3)
	self._touchLayer:setAttachSlide(true)
    self._touchLayer:attachToNode(self._ccbOwner.map_touchLayer,self._size.width,self._size.height,-self._size.width/2,-self._size.height/2, handler(self, self.onTouchEvent))

    self._touchLayer:enable()
    self._touchLayer:addEventListener(QUIGestureRecognizer.EVENT_SLIDE_GESTURE, handler(self, self.onTouchEvent))
end

-- 处理各种touch event
function QUIDialogSocietyDungeon:onTouchEvent(event)
    if event == nil or event.name == nil then
        return
    end
    if self._totleWidth <= self._pageWidth then
        return 
    end
    if event.name == QUIGestureRecognizer.EVENT_SLIDE_GESTURE then
    elseif event.name == "began" then
        self._startX = event.x
        self._pageX = self._mapContent:getPositionX()
        -- print(" onTouchEvent (1): ", self._startX, self._pageX)
    elseif event.name == "moved" then
        if math.abs(event.x - self._startX) < 5 then return end
        local offsetX = self._pageX + event.x - self._startX
        -- print(" onTouchEvent : ", event.x, offsetX, self._orginalPosition.x, self._totleWidth, self._pageWidth)
        if offsetX > self._orginalPosition.x then
            offsetX = self._orginalPosition.x
        elseif offsetX < -(self._totleWidth - self._pageWidth + math.abs(self._orginalPosition.x) - 50 ) then
            offsetX = -(self._totleWidth - self._pageWidth + math.abs(self._orginalPosition.x) - 50 )
        end
        self._mapContent:setPositionX(offsetX)
    elseif event.name == "ended" then
    end
end

function QUIDialogSocietyDungeon:_init(options)
	-- self._initTotalHpScaleX = self._ccbOwner.sp_progress:getScaleX()
	local barClippingNode = q.newPercentBarClippingNode(self._ccbOwner.sp_progress)
    self._stencil = barClippingNode:getStencil()
    self._totalStencilWidth = self._stencil:getContentSize().width * self._stencil:getScaleX()
    self._stencil:setPositionX(-self._totalStencilWidth + 0 * self._totalStencilWidth)

	remote.union:setShowChapter(options.chapter or remote.union:getFightChapter())

	-- self._bossPreHPDic = {}
	
 	local userConsortia = remote.user:getPropForKey("userConsortia")
 	QPrintTable(userConsortia)
    if userConsortia.rank == SOCIETY_OFFICIAL_POSITION.BOSS or userConsortia.rank == SOCIETY_OFFICIAL_POSITION.ADJUTANT then
    	self._ccbOwner.node_setting:setVisible(true)
    else
        self._ccbOwner.node_setting:setVisible(false)
    end
    
	self:_updateInit()
end

function QUIDialogSocietyDungeon:_updateChapter()
	self._chapter = remote.union:getShowChapter()
	if self._chapter <= 0 then
		remote.union:setShowChapter(remote.union:getFightChapter())
		self._chapter = remote.union:getFightChapter()
	end
end

function QUIDialogSocietyDungeon:_updateInit()
	self._aniManagers = {}
    self._aniCcbViews = {}
    self:_updateChapter()
	self._bossList = {}
	self._chestList = {}
	self._buffList = {}
	self._buffInMapList = {}
	self._activityBuffList = {}
	self._finalBoss = nil

	-- self._ccbOwner.award_tips:setVisible(false)

	-- local tbl = remote.union:getSocietyDataByChapter(self._chapter)
	-- if tbl and tbl[1] and tbl[1].color_type then
	-- 	local color_type = tonumber(tbl[1].color_type)
	-- 	local index = color_type > 4 and color_type - 4 or color_type
	-- 	self._ccbOwner["node_color_"..index]:setVisible(true)
	-- else
	-- 	self._ccbOwner["node_color_"..1]:setVisible(true)
	-- end
	self:_initMap()
	self:_updateValidInfo()

	-- if self._cloudManager then
 --        self._cloudManager:runAnimationsForSequenceNamed("open")
 --    end
end

function QUIDialogSocietyDungeon:_initMap()
	local scoietyChapterConfig = QStaticDatabase.sharedDatabase():getScoietyChapter(self._chapter)
	local mapIndex = scoietyChapterConfig[1].color_type
	self._map = QUIWidgetSocietyDungeonMap.new( { mapIndex = mapIndex, config = scoietyChapterConfig } ) 
	if not self._map then
		mapIndex = 1
		self._map = QUIWidgetSocietyDungeonMap.new( { mapIndex = mapIndex } ) 
	end
	self._totleWidth = self._map:getMapWidth()
	self._ccbOwner.map_content:addChild( self._map )

	self._scoietyChapterConfig = {}
	for _, config in ipairs(scoietyChapterConfig) do
		self._scoietyChapterConfig[config.wave] = config
	end

	self:_initBossInfo()
	self:_initMapInfo()
end

function QUIDialogSocietyDungeon:_initBossInfo()
	print("[Kumo] QUIDialogSocietyDungeon:_initBossInfo()")
	if self._bossList and #self._bossList > 0 then
		for _, value in pairs(self._bossList) do
			value:removeFromParentAndCleanup(true)
			-- value:removeAllEventListeners()
			-- value:cleanUp()
			value = nil
		end
		self._bossList = {}
	end

	local bossList = remote.union:getConsortiaBossList(self._chapter)
	if not bossList or #bossList == 0 then return end
	local bossDeadList = {}
	table.sort(bossList, function(a, b)
			return a.setFocusedTime < b.setFocusedTime
		end)
	local isFocused = false
	for _, value in pairs(bossList) do
		if value.bossHp == 0 then
			bossDeadList[value.wave] = true
		end
		value.isSetting = false
		local bossNode = self._map:getBossNodeByIndex(value.wave)
		print("[Kumo] QUIDialogSocietyDungeon:_initBossInfo  ", value.wave, bossNode, value.isSetting)
		if bossNode then
			local boss = QUIWidgetSocietyDungeonBoss.new(value)
			boss:addEventListener(QUIWidgetSocietyDungeonBoss.EVENT_CLICK, handler(self, self._onEvent))
			boss:addEventListener(QUIWidgetSocietyDungeonBoss.EVENT_ROBOT, handler(self, self._onEvent))
			boss:addEventListener(QUIWidgetSocietyDungeonBoss.EVENT_DEAD, handler(self, self._onEvent))
			if value.setFocusedTime ~= remote.union.FOCUSED_TIME and isFocused == false and value.bossHp > 0 then
				isFocused = true
				boss:setRecommend(true)
			end
			
			bossNode:removeAllChildren()
			bossNode:addChild(boss)
			bossNode:setVisible(true)
			self._bossList[value.wave] = boss
		end

		self:_initChest(value.wave, value.chapter, value.bossHp)
		self:_initBuff(value.wave, value.chapter)
	end

	local isCurChapterPass = remote.union:getCurBossHpByChapter(remote.union:getFightChapter()) == 0
	local totalChapter = table.nums(QStaticDatabase.sharedDatabase():getAllScoietyChapter())
	local finalBossInfo, finalBossConfig = remote.union:getConsortiaFinalBossInfo()
	
	if isCurChapterPass and self._chapter == totalChapter and q.isEmpty(finalBossInfo) == false then
		if self._bossList[finalBossConfig.wave_pre] then
			self._bossList[finalBossConfig.wave_pre]:removeFromParentAndCleanup(true)
			self._bossList[finalBossConfig.wave_pre] = nil
		end
		local bossNode = self._map:getBossNodeByIndex(finalBossConfig.wave_pre)

		if bossNode then
			local boss = QUIWidgetSocietyDungeonBoss.new(finalBossInfo, true)
			boss:addEventListener(QUIWidgetSocietyDungeonBoss.EVENT_CLICK, handler(self, self._onEvent))
			boss:addEventListener(QUIWidgetSocietyDungeonBoss.EVENT_ROBOT, handler(self, self._onEvent))
			boss:addEventListener(QUIWidgetSocietyDungeonBoss.EVENT_DEAD, handler(self, self._onEvent))
			boss:setRecommend(false)
			boss:makeColorNormal()
			
			bossNode:removeAllChildren()
			bossNode:addChild(boss)
			bossNode:setVisible(true)
			self._finalBoss = boss
		end


	    if app:getUserOperateRecord():compareCurrentTimeWithRecordeTime(DAILY_TIME_TYPE.MONOPOLY)  then 
	    	app:getUserOperateRecord():recordeCurrentTime(DAILY_TIME_TYPE.MONOPOLY)
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSocietyDungeonFinalPass",options = {callBack =  handler(self, self._finishBossAction)}}, {isPopCurrentDialog = false})
		else
			self._finalBoss:setSoulState()
		end

	end

	-- QPrintTable(bossDeadList)
	for _, value in pairs(self._scoietyChapterConfig) do
		local boss = self._bossList[value.wave]
		if boss then 
			if value.wave_pre and not bossDeadList[value.wave_pre] and not bossDeadList[value.wave] then
				boss:makeColorGray()
			else
				boss:makeColorNormal()
			end
		end
	end
end

function QUIDialogSocietyDungeon:_finishBossAction()

	local offsetX = -(self._totleWidth - self._pageWidth + math.abs(self._orginalPosition.x) - 50)
	local arr = CCArray:create()
	arr:addObject(CCMoveTo:create(0.5, ccp(offsetX, self._mapContent:getPositionY())))
	arr:addObject(CCCallFunc:create(
		function ()
			if self._finalBoss then
				self._finalBoss:playFinishBossDead()
			end
		end))
	self._mapContent:runAction(CCSequence:create(arr))

end


function QUIDialogSocietyDungeon:_initChest( wave, chapter, bossHp )
	if self._chestList and self._chestList[wave] then
		self._chestList[wave]:removeFromParent()
		self._chestList[wave] = nil
	end

	local scoietyWaveConfig = QStaticDatabase.sharedDatabase():getScoietyWave(wave, chapter)
	local chestNode = self._map:getChestNodeByIndex(wave)
	-- print("[Kumo] QUIDialogSocietyDungeon:_initChest  ", wave, chapter, chestNode)
	if chestNode and scoietyWaveConfig and scoietyWaveConfig.sociaty_box then
		local chestType = scoietyWaveConfig.is_final_boss and 4 or 1
		local chest = QUIWidgetChest.new({chestType = chestType, index = scoietyWaveConfig.wave})
		chest:addEventListener(QUIWidgetChest.CHEST_CLICK, handler(self, self._onEvent))
		chest:setClose()
		chestNode:addChild(chest)
		chestNode:setVisible(true)
		self._chestList[wave] = chest

		if scoietyWaveConfig.box_scale then
       		chestNode:setScale(scoietyWaveConfig.box_scale)
       	else
       	 	chestNode:setScale(1)
   	 	end 

   	 	if bossHp == 0 then 
   	 		if remote.union:isReceived( wave, chapter ) then
   	 			-- if self._bossPreHPDic[wave] and self._bossPreHPDic[wave] > 0 then
   	 			-- 	chest:setOpen()
   	 			-- else
   	 				chest:setOpened()
   	 			-- end
   	 		else
   	 			chest:setReady()
   	 		end
   	 	end

   	 	-- self._bossPreHPDic[wave] = bossHp
	end
end

function QUIDialogSocietyDungeon:_initBuff( wave, chapter )
	local scoietyWaveConfig = QStaticDatabase.sharedDatabase():getScoietyWave(wave, chapter)
	local chestNode = self._map:getChestNodeByIndex(wave)
	if chestNode and scoietyWaveConfig and scoietyWaveConfig.buff_des_id then
		local buffConfig = QStaticDatabase.sharedDatabase():getScoietyDungeonBuff(scoietyWaveConfig.buff_des_id)
		local sprite
		local btn
		local spriteFrame = QSpriteFrameByPath(buffConfig.ICON)
		if spriteFrame then
        	sprite = CCSprite:createWithSpriteFrame(spriteFrame)
        end
        if sprite then
        	btn = q.addSpriteButton(sprite, handler(self, self._onBuffBtnEvent2))
        	self._buffInMapList[wave] = {id = buffConfig.id, des = buffConfig.buff_des, target = btn}
        	local lbName = CCLabelTTF:create(buffConfig.name, global.font_default, 20)
        	lbName:setColor(ccc3(255, 255, 255))
        	-- local spName = CCSprite:createWithSpriteFrame(QSpriteFrameByKey("societyBuffNameBg", buffConfig.buff_type or 1))
        	local spNamePath = QResPath("societyBuffNameBg")[buffConfig.buff_type or 1]
        	local spName = CCScale9Sprite:create(spNamePath)
        	local lbSize = lbName:getContentSize()
			spName:setContentSize(CCSize(lbSize.width, lbSize.height))
        	local h = btn:getContentSize().height
        	spName:setPositionY(-h/2)
        	spName:setScale(0.8)
        	lbName:setPositionY(-h/2)
        	lbName:setScale(0.8)
        	chestNode:addChild(spName)
        	chestNode:addChild(lbName)
        	chestNode:addChild(btn)
        	chestNode:setVisible(true)
       	end

       	if scoietyWaveConfig.buff_scale then
       		chestNode:setScale(scoietyWaveConfig.buff_scale)
       	else
       	 	chestNode:setScale(1)
   	 	end 
	end
end

function QUIDialogSocietyDungeon:_initMapInfo( totalBossHp )
	local userConsortia = remote.user:getPropForKey("userConsortia")
	-- QPrintTable(userConsortia)

	-- 初始化可挑战BOSS次数
	self._fightCounts = userConsortia.consortia_boss_fight_count
	self._ccbOwner.tf_count:setString( self._fightCounts )
    local buyCount = userConsortia.consortia_boss_buy_count or 0
	if userConsortia.consortia_boss_buy_at ~= nil and q.refreshTime(remote.user.c_systemRefreshTime) > userConsortia.consortia_boss_buy_at then
		buyCount = 0
	end
	local totalVIPNum = QVIPUtil:getCountByWordField("sociaty_chapter_times", QVIPUtil:getMaxLevel())
	local totalNum = QVIPUtil:getCountByWordField("sociaty_chapter_times")
	self._ccbOwner.node_btn_plus:setVisible(totalVIPNum > totalNum or totalNum > buyCount)

	-- 和时间有关的数据
	self:_updateTime()
	if self._scheduler then
		scheduler.unscheduleGlobal(self._scheduler)
		self._scheduler = nil
	end
	self._scheduler = scheduler.scheduleGlobal(function ()
		self:_updateTime()
	end, 1)

	-- 初始化副本的进度
	self._maxTotalBossHp = 0
	local curTotalBossHp = 0
	self._ccbOwner.tf_progress:setString("0/0")
	for _, boss in pairs(self._bossList) do
		self._maxTotalBossHp = self._maxTotalBossHp + boss:getTotalHp()
	end
	local bossList = remote.union:getConsortiaBossList(self._chapter)
	if bossList and #bossList > 0 then
		for _, value in pairs(bossList) do
			curTotalBossHp = curTotalBossHp + value.bossHp
		end
	end
	-- local sx = (self._maxTotalBossHp - curTotalBossHp) / self._maxTotalBossHp * self._initTotalHpScaleX
	-- print("[Kumo] 地图所有BOSS总血条 ", curTotalBossHp, self._maxTotalBossHp, sx, self._initTotalHpScaleX)
	-- self._ccbOwner.sp_progress:setScaleX( sx )
	self._stencil:setPositionX(-self._totalStencilWidth + (self._maxTotalBossHp - curTotalBossHp) / self._maxTotalBossHp * self._totalStencilWidth)
	self._ccbOwner.tf_progress:setString( math.floor(((self._maxTotalBossHp - curTotalBossHp) / self._maxTotalBossHp)* 100) .."%" )
	-- self._ccbOwner.tf_progress:setString( string.format("%.2f", (curTotalBossHp / self._maxTotalBossHp)* 100) .."%" )
	-- self._ccbOwner.tf_progress:setString(curTotalBossHp.."/"..self._maxTotalBossHp)

	-- 初始化地图关卡和名字
	self._ccbOwner.tf_name:setString("")
	local scoietyChapterConfig = QStaticDatabase.sharedDatabase():getScoietyChapter(self._chapter)
	if scoietyChapterConfig and #scoietyChapterConfig > 0 then
		-- local id = q.numToWord(self._chapter)
		local id = self._chapter
		self._ccbOwner.tf_name:setString("第 "..id.." 章  "..scoietyChapterConfig[1].chapter_name)
	end

	-- 初始化通关奖励小红点
	-- if remote.union:checkSocietyDungeonAwardRedTips() then
	-- 	self._ccbOwner.award_tips:setVisible(true)
	-- end

	-- 初始化宝箱奖励小红点
	-- if remote.union:checkSocietyDungeonChestRedTips(self._chapter) then
	-- 	self._ccbOwner.chest_tips:setVisible(true)
	-- end

	-- if remote.union:checkUnionShopRedTips() then
 --        self._ccbOwner.shop_tips:setVisible(true)
 --    else
 --    	self._ccbOwner.shop_tips:setVisible(false)
 --    end

    self:_initBuffInfo()
end

function QUIDialogSocietyDungeon:_updateMapInfo()
	local userConsortia = remote.user:getPropForKey("userConsortia")

	-- 刷新可挑战BOSS次数
	self._fightCounts = userConsortia.consortia_boss_fight_count
	self._ccbOwner.tf_count:setString( self._fightCounts )
    self:_updateChapter()

	-- 刷新副本的进度
	local curTotalBossHp = 0
	self._ccbOwner.tf_progress:setString("0/0")
	local bossList = remote.union:getConsortiaBossList(self._chapter)
	if bossList and #bossList > 0 then
		for _, value in pairs(bossList) do
			curTotalBossHp = curTotalBossHp + value.bossHp
		end
	end
	-- local sx = (self._maxTotalBossHp - curTotalBossHp) / self._maxTotalBossHp * self._initTotalHpScaleX
	-- print("[Kumo] 地图所有BOSS总血条 ", curTotalBossHp, self._maxTotalBossHp, sx, self._initTotalHpScaleX)
	-- self._ccbOwner.sp_progress:setScaleX( sx )
	self._stencil:setPositionX(-self._totalStencilWidth + (self._maxTotalBossHp - curTotalBossHp) / self._maxTotalBossHp * self._totalStencilWidth)
	self._ccbOwner.tf_progress:setString( math.floor(((self._maxTotalBossHp - curTotalBossHp) / self._maxTotalBossHp)* 100) .."%" )
	-- self._ccbOwner.tf_progress:setString( string.format("%.2f", (curTotalBossHp / self._maxTotalBossHp)* 100) .."%" )
	-- self._ccbOwner.tf_progress:setString(curTotalBossHp.."/"..self._maxTotalBossHp)

	-- 刷新通关奖励小红点
	-- if remote.union:checkSocietyDungeonAwardRedTips() then
	-- 	self._ccbOwner.award_tips:setVisible(true)
	-- else
	-- 	self._ccbOwner.award_tips:setVisible(false)
	-- end

	-- 刷新宝箱奖励小红点
	-- if remote.union:checkSocietyDungeonChestRedTips(self._chapter) then
	-- 	self._ccbOwner.chest_tips:setVisible(true)
	-- else
	-- 	self._ccbOwner.chest_tips:setVisible(false)
	-- end

	-- if remote.union:checkUnionShopRedTips() then
 --        self._ccbOwner.shop_tips:setVisible(true)
 --    else
 --    	self._ccbOwner.shop_tips:setVisible(false)
 --    end

    self:_updateBuff()
end

function QUIDialogSocietyDungeon:_initBuffInfo()
	local scoietyChapterConfig = QStaticDatabase.sharedDatabase():getScoietyChapter(self._chapter)
	-- QPrintTable(scoietyChapterConfig)
	local i = 0
	for _, config in ipairs(scoietyChapterConfig) do
		if config and config.buff_des_id then
			local buffConfig = QStaticDatabase.sharedDatabase():getScoietyDungeonBuff(config.buff_des_id)
			local sprite
			local btn
			local spriteFrame = QSpriteFrameByPath(buffConfig.effect)
			if spriteFrame then
	        	sprite = CCSprite:createWithSpriteFrame(spriteFrame)
	        end
	        if sprite then
	        	i = i + 1
	        	local node = self._ccbOwner["node_buff"..i]
	        	if node then
	        		btn = q.addSpriteButton(sprite, handler(self, self._onBuffBtnEvent))
		            -- node:addChild(sprite)
		            node:addChild(btn)
		            makeNodeFromNormalToGray(node)
		        end
		        -- self._buffList[config.wave] = {id = buffConfig.id, target = sprite}
		        self._buffList[config.wave] = {id = buffConfig.id, des = buffConfig.buff_des, target = btn}
	       	end
		end
	end

	self:_updateBuff()
end

function QUIDialogSocietyDungeon:_updateBuff()
	local bossList = remote.union:getConsortiaBossList(self._chapter) or {}
	for _, boss in ipairs(bossList) do
		if boss.bossHp == 0 and self._buffList[boss.wave] then
			local buff = self._buffList[boss.wave].target
			if buff then
				makeNodeFromGrayToNormal(buff:getParent())
			end
			self._activityBuffList[boss.wave] = self._buffList[boss.wave].id
		end
	end
end

function QUIDialogSocietyDungeon:_updateValidInfo(data)
	print("[QUIDialogSocietyDungeon:_updateValidInfo(data)]")
	local todayValidCountLimit
	local todayAlreadyValidCount
	if data and data.consortia then
		todayValidCountLimit = data.consortia.todayValidCountLimit and data.consortia.todayValidCountLimit or remote.union.consortia.todayValidCountLimit or 0
		todayAlreadyValidCount = data.consortia.todayAlreadyValidCount and data.consortia.todayAlreadyValidCount or remote.union.consortia.todayAlreadyValidCount or 0
	else
		todayValidCountLimit = remote.union.consortia.todayValidCountLimit or 0
		todayAlreadyValidCount = remote.union.consortia.todayAlreadyValidCount or 0
	end

	self._ccbOwner.tf_valid_count:setString(todayAlreadyValidCount.."/"..todayValidCountLimit)



end

function QUIDialogSocietyDungeon:_updateBossHp(skipDeadAni)
	local bossList = remote.union:getConsortiaBossList(self._chapter)
	local fightWave = remote.union:getFightWave()
	local checkSpecial = true
	if remote.union:checkIsFinalWave(self._chapter, fightWave) then
		if self._finalBoss then
			if skipDeadAni == nil then
				self._finalBoss:_onTriggerClick()
				checkSpecial = false
			end
		end
	else
		if bossList and #bossList > 0 then
			for _, value in pairs(bossList) do
                if self._bossList[value.wave] then
    				local isDead = self._bossList[value.wave]:updateHp(value.bossHp, skipDeadAni)
    				if isDead == false and skipDeadAni == nil and fightWave == value.wave then
    					self._bossList[value.wave]:_onTriggerClick()
    					checkSpecial = false
    				end
                end
			end
		end

	end

	return checkSpecial
end

function QUIDialogSocietyDungeon:_onBuffBtnEvent(e, target)
	for index, value in pairs(self._buffList) do
		if target == value.target then
			print("wave : ", index)
			local isActive = 0
			-- if self._activityBuffList[index] then
			-- 	isActive = 1
			-- else
			-- 	isActive = 2
			-- end
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass="QUIDialogSocietyDungeonBuffTips", options = {des = value.des, isActive = isActive}})
		end
	end
end

function QUIDialogSocietyDungeon:_onBuffBtnEvent2(e, target)
	for index, value in pairs(self._buffInMapList) do
		if target == value.target then
			print("wave : ", index)
			local isActive = 0
			if self._activityBuffList[index] then
				isActive = 1
			else
				isActive = 2
			end
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass="QUIDialogSocietyDungeonBuffTips", options = {des = value.des, isActive = isActive}})
		end
	end
end

-- {
    -- sec: 40
    -- min: 27
    -- day: 28
    -- isdst: false
    -- wday: 7
    -- yday: 149
    -- year: 2016
    -- month: 5
    -- hour: 16
-- }
function QUIDialogSocietyDungeon:_updateTime()
	if (not remote.user.userConsortia.consortiaId or remote.user.userConsortia.consortiaId == "") then return end
	
	local curTimeTbl = q.date("*t", q.serverTime())
	local h,m,s = 0,0,0
	local timeStr = ""
	m = 59 - curTimeTbl.min
	s = 60 - curTimeTbl.sec
	-----------------------------------------------------------------------------
	local startTime = remote.union:getSocietyDungeonStartTime()
	local endTime = remote.union:getSocietyDungeonEndTime()
	local count = remote.union:getSocietyCount()
	local cd = remote.union:getSocietyCD()

	if curTimeTbl.hour == startTime and curTimeTbl.min == 0 and curTimeTbl.sec == 0 then
		self._fightCounts = count
		local userConsortia = remote.user:getPropForKey("userConsortia")
		userConsortia.consortia_boss_fight_count = self._fightCounts
		self._ccbOwner.tf_count:setString( self._fightCounts )
	elseif (curTimeTbl.hour == startTime + cd and curTimeTbl.min == 0 and curTimeTbl.sec == 0) or
		(curTimeTbl.hour == startTime + cd * 2 and curTimeTbl.min == 0 and curTimeTbl.sec == 0) or
		(curTimeTbl.hour == startTime + cd * 3 and curTimeTbl.min == 0 and curTimeTbl.sec == 0) or
		(curTimeTbl.hour == startTime + cd * 4 and curTimeTbl.min == 0 and curTimeTbl.sec == 0) or
		(curTimeTbl.hour == startTime + cd * 5 and curTimeTbl.min == 0 and curTimeTbl.sec == 0) or
		(curTimeTbl.hour == startTime + cd * 6 and curTimeTbl.min == 0 and curTimeTbl.sec == 0) then
		if curTimeTbl.hour < endTime then
			self._fightCounts = self._fightCounts + 1
			local userConsortia = remote.user:getPropForKey("userConsortia")
			userConsortia.consortia_boss_fight_count = self._fightCounts
			self._ccbOwner.tf_count:setString( self._fightCounts )
		end
	end

	if curTimeTbl.hour < startTime or curTimeTbl.hour >= endTime then
		self._fightCounts = 0
		local userConsortia = remote.user:getPropForKey("userConsortia")
		userConsortia.consortia_boss_fight_count = self._fightCounts
		self._ccbOwner.tf_count:setString( self._fightCounts )
	end
	
	if curTimeTbl.hour >= startTime and curTimeTbl.hour < startTime + cd then
		h = startTime + cd - 1 - curTimeTbl.hour
	elseif curTimeTbl.hour >= startTime + cd and curTimeTbl.hour < startTime + cd * 2 then
		h = startTime + cd * 2 - 1 - curTimeTbl.hour
	elseif curTimeTbl.hour >= startTime + cd * 2 and curTimeTbl.hour < startTime + cd * 3 then
		h = startTime + cd * 3 - 1 - curTimeTbl.hour
	elseif curTimeTbl.hour >= startTime + cd * 3 and curTimeTbl.hour < startTime + cd * 4 then
		h = startTime + cd * 4 - 1 - curTimeTbl.hour
	elseif curTimeTbl.hour >= startTime + cd * 4 and curTimeTbl.hour < startTime + cd * 5 then
		h = startTime + cd * 5 - 1 - curTimeTbl.hour
	elseif curTimeTbl.hour >= startTime + cd * 5 and curTimeTbl.hour < startTime + cd * 6 then
		h = startTime + cd * 6 - 1 - curTimeTbl.hour
	else
		h = -1
	end

	if h >= 0 and not app.unlock:checkLock("UNLOCK_ZONGMENFUBEN_CD", false) then -- 宗门副本cd在解锁状态下不显示倒计时
		self._ccbOwner.node_time:setVisible(true)
		timeStr = string.format("%02d:%02d:%02d", h, m, s)
		self._ccbOwner.tf_time:setString("( "..timeStr.." )")
	else
		self._ccbOwner.node_time:setVisible(false)
		self._ccbOwner.tf_time:setString("")
	end
	-- self._ccbOwner.node_time:setVisible(false)
	-----------------------------------------------------------------------------
	if curTimeTbl.hour > 4 then
		h = 24 - curTimeTbl.hour + 4
	else
		h = 4 - curTimeTbl.hour
	end
	-- m = 59 - curTimeTbl.min
	-- s = 60 - curTimeTbl.sec
	timeStr = string.format("%02d:%02d:%02d", h, m, s)
	-- print("===============")
	-- print(string.format("%02d:%02d:%02d", curTimeTbl.hour, curTimeTbl.min, curTimeTbl.sec))
	-- print(timeStr)
	-- print("===============")
	local consortia  = remote.union.consortia
	local maxChapter = consortia.max_chapter
	local mapID = 0
	-- // 宗门更新每日刷新类型 1为最远关卡 2为最远关卡前一关卡
	if consortia.bossResetType == 1 then
		mapID = maxChapter
	else
		-- 这里不考虑"maxChapter == 1"的情况，这个放在重置选择界面里做规避。当maxChapter为1的时候，不让宗主选择第2种重置方式
		mapID = maxChapter - 1
	end
	self._ccbOwner.tf_reset_time:setString("")
	self._ccbOwner.tf_reset_info:setString("")
	-- local scoietyChapterConfig = QStaticDatabase.sharedDatabase():getScoietyChapter(mapID)
	-- if not scoietyChapterConfig or #scoietyChapterConfig == 0 then return end
	-- self._ccbOwner.tf_reset_info:setString(timeStr.."后重置至"..scoietyChapterConfig[1].chapter_name)
	self._ccbOwner.tf_reset_time:setString(timeStr)
	self._ccbOwner.tf_reset_info:setString("后重置至第 "..mapID.." 章")
end

function QUIDialogSocietyDungeon:_onEvent( event )
	if event.name == QUIWidgetSocietyDungeonBoss.EVENT_CLICK or event.name == QUIWidgetSocietyDungeonBoss.EVENT_ROBOT then
		if self._isAnimationPlaying then return end

		if remote.union:checkUnionDungeonIsOpen(true) == false then
			return
		end
		local op = {}
		op.activityBuffList = self._activityBuffList
		remote.union:unionGetBossListRequest(function (data)
				if self:safeCheck() == false then return end
				self:_updateValidInfo(data)

				local isFinalBoss = remote.union:checkIsFinalWave(self._chapter, event.wave)

				local bossList = remote.union:getConsortiaBossList(self._chapter)
				local bossDeadList = {}
				if isFinalBoss then
					op = remote.union:getConsortiaFinalBossInfo()
				elseif bossList and #bossList > 0 then 
					self:_updateBossHp(true)
					for _, value in pairs(bossList) do
						if value.wave == event.wave then
							op.bossHp = value.bossHp or event.bossHp
							if op.bossHp == 0 then
								app.tip:floatTip("魂师大人，BOSS已被击败了")
								return
							end
							op.chapter = value.chapter or event.chapter
							op.wave = value.wave or event.wave
						end

						if value.bossHp == 0 then
							bossDeadList[value.wave] = true
						end
					end
				end

				local isReturn = false
				if not isFinalBoss then
					for _, value in pairs(self._scoietyChapterConfig) do
						local boss = self._bossList[value.wave]
						if boss then 
							if value.wave_pre and not bossDeadList[value.wave_pre] and not bossDeadList[value.wave] then
								boss:makeColorGray()
							else
								boss:makeColorNormal()
							end
						end
					end

					for _, value in pairs(self._scoietyChapterConfig) do
						local boss = self._bossList[value.wave]
						if boss then
							if value.wave == event.wave and not boss:isCurTarget() then
								app.tip:floatTip("哎哟喂～心真大啊，先把我的先锋队解决了再来挑战我吧！")
								isReturn = true
							end
						end
					end
				end
				QPrintTable(op)
				if isReturn then return end

				if event.name == QUIWidgetSocietyDungeonBoss.EVENT_CLICK then
					if op.chapter == nil  or op.wave == nil then --当前章节界面需要刷新

					else
						app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSocietyDungeonBossInfo", options = op}, {isPopCurrentDialog = false})
					end
				elseif event.name == QUIWidgetSocietyDungeonBoss.EVENT_ROBOT then
					self._bossRobotDialog = nil
					if self._fightCounts <= 0 then
						self:_onTriggerPlus()
					else
						self._bossRobotDialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogRobotForSocietySingle", options = op}, {isPopCurrentDialog = false})
					    self._bossRobotDialog:addEventListener(self._bossRobotDialog.EVENT_EXIT, function()
					    	self._bossRobotDialog = nil
			    		end)
			    	end
				end
				self:_checkShowSpecialAward()
				
		end, function ()
			op.bossHp = event.bossHp
			if op.bossHp == 0 then
				app.tip:floatTip("魂师大人，BOSS已被击败了")
				return
			end
			op.chapter = event.chapter
			op.wave = event.wave

			app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSocietyDungeonBossInfo", options = op}, {isPopCurrentDialog = false})
			app.tip:floatTip("无法获取实时BOSS信息，请检查下当前网络是否稳定")
			self:_updateBossHp(true)
		
		end)
	elseif event.name == QUIWidgetSocietyDungeonBoss.EVENT_DEAD then	
		self:_showChestAnimationStart(event.wave)
	elseif event.name == QUIWidgetChest.CHEST_CLICK then
			self:_onTriggerChest(event.index)
	end
end

function QUIDialogSocietyDungeon:_getCurrentWave()
	local bossList = remote.union:getConsortiaBossList(self._chapter)
	if not bossList or #bossList == 0 then return end
	bossList = clone(bossList)
	table.sort(bossList, function(obj1, obj2)
		return obj1.wave < obj2.wave
	end)
	for _, value in pairs(bossList) do
		if value.bossHp > 0 then
			return value.wave
		end
	end

	return 0 -- by Kumo 4 个BOSS都死的情况
end

function QUIDialogSocietyDungeon:_showCloud()
	-- self._isAnimationPlaying = true

 --    local ccbFile = "ccb/effects/gonghui_fuben.ccbi"
 --    local proxy = CCBProxy:create()
 --    local aniCcbOwner = {}
 --    local aniCcbView = CCBuilderReaderLoad(ccbFile, proxy, aniCcbOwner)
 --    self._ccbOwner.node_guochang:addChild(aniCcbView)
 --    self._cloudManager = tolua.cast(aniCcbView:getUserObject(), "CCBAnimationManager")
 --    self._cloudManager:runAnimationsForSequenceNamed("close")
 --    self._cloudManager:connectScriptHandler(function(str)
 --            if str == "close" then
 --                self:_updateInit()
 --            elseif str == "open" then
 --                self._isAnimationPlaying = false
 --            end
 --        end)
 --    table.insert(self._aniManagers, self._cloudManager)
 --    table.insert(self._aniCcbViews, aniCcbView)
end

function QUIDialogSocietyDungeon:_showChestAnimationStart(wave)
	local node = self._ccbOwner["node_chest_"..wave]
	local pNode = self._ccbOwner["node_boss_"..wave]
	if not node or not pNode then
		self:_showChestAnimationEnd(wave)
		return 
	end
    local ccbFile = "ccb/effects/zhanchang_baoxiang_chuxian.ccbi"
    local aniPlayer = QUIWidgetAnimationPlayer.new()
    local px, py = pNode:getPosition()
    node:setPosition(px, py)
    node:addChild(aniPlayer)
    node:setVisible(true)
    aniPlayer:playAnimation(ccbFile, function(ccbOwner)
    		ccbOwner.effect_guang:setVisible(false)
    	end, function()
    		self:_moveChestAnimation(node, wave)
    	end, false)
end

function QUIDialogSocietyDungeon:_moveChestAnimation(node, wave)
	node:moveTo(0.1, -10, -40)
	self._chestScheduler = scheduler.performWithDelayGlobal(function()
			if self._chestScheduler then
				scheduler.unscheduleGlobal(self._chestScheduler)
				self._chestScheduler = nil
			end
			node:setVisible(false)
			node:removeAllChildren()
			self:_showChestAnimationEnd(wave)
		end, 0.1)
end

function QUIDialogSocietyDungeon:_showChestAnimationEnd(wave)
	if self._bossList[wave] then
		self._bossList[wave]:setAnimationEnd()
		self._bossList[wave]:updateHp(0, true)
		self:_checkChapterEnd()
	end
end

function QUIDialogSocietyDungeon:_checkChapterEnd()
	if remote.union:getCurBossHpByChapter(self._chapter) == 0 then
		app.tip:floatTip("恭喜您通关该章节，赶快去下一章节挑战吧")
	end
end

function QUIDialogSocietyDungeon:_showOpenChestAwrdsInfo(awards)
	if awards == nil or next(awards) == nil then return end
	local openCount = #awards
    local tipsStr = string.format("此次共开启了%d个宝箱", openCount)

	local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert",
        options = {awards = awards, isSort = true ,callBack = function( )
        	-- 暂时这样刷新，后面再跟服务器确认
			remote.union:unionGetBossListRequest(function (data)
				if self:safeCheck() then
					self:_updateValidInfo(data)
				end
			end, function ()
			end)		 
        end }}, {isPopCurrentDialog = false} )	    
    dialog:setTitle(tipsStr)

end


function QUIDialogSocietyDungeon:_checkShowSpecialAward()
	local specAward = remote.union:getConsortiaBossSpecAward()
	if specAward then
		remote.union:setConsortiaBossSpecAward(nil)
		local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG , uiClass = "QUIDialogAwardsAlert" ,
			options = {awards = specAward}}, {isPopCurrentDialog = false} ) 
	end
end

return QUIDialogSocietyDungeon