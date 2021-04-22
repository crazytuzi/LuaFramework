-- @Author: liaoxianbo
-- @Date:   2020-04-08 14:28:46
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-09-27 14:57:51
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogSoulTowerMain = class("QUIDialogSoulTowerMain", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QUIViewController = import("..QUIViewController")
local QUIWidget = import("...ui.widgets.QUIWidget")
local QUIWidgetSoulTowerFloor = import("...ui.widgets.QUIWidgetSoulTowerFloor")
local QUIGestureRecognizer = import("..QUIGestureRecognizer")
local QUIWidgetSoulTowerMonster = import("...ui.widgets.QUIWidgetSoulTowerMonster")
local QSoulTowerArrangement = import("...arrangement.QSoulTowerArrangement")
local QUIWidgetSoulTowerAwards = import("...ui.widgets.QUIWidgetSoulTowerAwards")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")

function QUIDialogSoulTowerMain:ctor(options)
	local ccbFile = "ccb/Dialog_Soul_tower_main.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerShop", callback = handler(self, self._onTriggerShop)},
		{ccbCallbackName = "onTriggerClickRank", callback = handler(self, self._onTriggerClickRank)},
		{ccbCallbackName = "onTriggerAward", callback = handler(self, self._onTriggerAward)},
		{ccbCallbackName = "onTriggerRule", callback = handler(self, self._onTriggerRule)},
		{ccbCallbackName = "onTriggerStartBattle", callback = handler(self, self._onTriggerStartBattle)},
		{ccbCallbackName = "onTriggerBossInfo", callback = handler(self, self._onTriggerBossInfo)},
		{ccbCallbackName = "onTriggerLockRank", callback = handler(self, self._onTriggerLockRank)},
		{ccbCallbackName = "onTriggerReplay" ,	callback = handler(self, self._onTriggerReplay)},
    }
    QUIDialogSoulTowerMain.super.ctor(self, ccbFile, callBacks, options)

	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	if page.setAllUIVisible then page:setAllUIVisible(false) end
    if page.setScalingVisible then page:setScalingVisible(false) end
	page.topBar:showWithBlackRock()

    CalculateUIBgSize(self._ccbOwner.sp_bg)
    CalculateUIBgSize(self._ccbOwner.sp_yun_right)
    CalculateUIBgSize(self._ccbOwner.sp_yun_left)

    self._spBgScaleX = self._ccbOwner.sp_bg:getScaleX()
    self._spBgScaleY = self._ccbOwner.sp_bg:getScaleY()

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
	self:initButtonState()

    self._pageWidth = self._ccbOwner.node_mask:getContentSize().width
    self._pageHeight = self._ccbOwner.node_mask:getContentSize().height

    self._moveing = false
    self._cloudsLocked = false
    self._isMoveFloor = false

    self._showMonsterAnimal = {}

    self._soulTowerFloorCells = {}
	self._soulTowerFloor = remote.soultower:getAllSoulTowerFloorsByRound()

	self._totalHeight = 0
	self._orginPosY = self._ccbOwner.node_norm:getPositionY()

	self._cellHeight = 118
	local isLock,historyFloor,historyWave = remote.soultower:getHistoryLockFloorWave()

	for index,v in pairs(self._soulTowerFloor) do
		local floorBtn = QUIWidgetSoulTowerFloor.new()
		floorBtn:addEventListener(QUIWidgetSoulTowerFloor.SOULTOWER_BTN_CLICK, handler(self, self.touchFloorEvent))
		local cellSize = floorBtn:getContentSize()
		self._ccbOwner.node_btns:addChild(floorBtn)
		floorBtn:setFloorInfo(v)
		self._totalHeight = self._totalHeight + self._cellHeight
		self._soulTowerFloorCells[index] = floorBtn
	end

	for _,widgetFloor in pairs(self._soulTowerFloorCells) do
		local floorInfo = widgetFloor:getFloorInfo()
		local compareDungen = historyWave + 1
		if historyWave == remote.soultower:getMaxFloorDungenNum() then
			compareDungen = historyWave
		end
		if floorInfo and floorInfo.floor == historyFloor and floorInfo.dungeon == compareDungen then
			self._chooseFloorInfo = floorInfo
		end
	end

	self._totalHeight = self._totalHeight + 180
	self._normY = self._orginPosY - self._pageHeight/2 - 90
	self._ccbOwner.node_norm:setPositionY(self._normY)

	self:initToucherLayer()

	self._normY = 0
	if self:getOptions().defaultPos then
		self:moveTo(self:getOptions().defaultPos, false)
		self._normY = self._ccbOwner.node_norm:getPositionY()
	else
		self:renderFrame()
	end

	self:updateSoulTowerBackGround()
end
 
function QUIDialogSoulTowerMain:initButtonState( )
    q.setButtonEnableShadow(self._ccbOwner.btn_battle)
    q.setButtonEnableShadow(self._ccbOwner.button_data)
    q.setButtonEnableShadow(self._ccbOwner.btn_award)
    q.setButtonEnableShadow(self._ccbOwner.btn_lock)
    q.setButtonEnableShadow(self._ccbOwner.btn_replay)
end

function QUIDialogSoulTowerMain:initToucherLayer( )

    self._pageContent = self._ccbOwner.node_btns
    self._orginalPosition = ccp(self._pageContent:getPosition())
    print("初始位置-----",self._orginalPosition.x,self._orginalPosition.y)
    local layerColor = CCLayerColor:create(ccc4(0,0,0,255),self._pageWidth,self._pageHeight)
    local ccclippingNode = CCClippingNode:create()
    layerColor:setPositionX(self._ccbOwner.node_mask:getPositionX())
    layerColor:setPositionY(self._ccbOwner.node_mask:getPositionY())
    ccclippingNode:setStencil(layerColor)
    self._pageContent:removeFromParent()
    ccclippingNode:addChild(self._pageContent)

    self._ccbOwner.node_sheet:addChild(ccclippingNode)

    self._touchWidth = self._ccbOwner.node_mask:getContentSize().width
	self._touchHeight = self._ccbOwner.node_mask:getContentSize().height
    self._touchLayer = QUIGestureRecognizer.new()
    self._touchLayer:setAttachSlide(true)
    self._touchLayer:attachToNode(self._ccbOwner.node_sheet,self._pageWidth, self._pageHeight, 0, 
    -self._pageHeight, handler(self, self.onTouchEvent))

    
end

function QUIDialogSoulTowerMain:viewDidAppear()
	QUIDialogSoulTowerMain.super.viewDidAppear(self)
	self:addBackEvent(true)
	QNotificationCenter.sharedNotificationCenter():addEventListener(QNotificationCenter.EVENT_EXIT_FROM_BATTLE, self.exitFromBattleHandler, self)

    self._touchLayer:enable()
    self._touchLayer:addEventListener(QUIGestureRecognizer.EVENT_SLIDE_GESTURE, handler(self, self.onTouchEvent))

    self._soulTowerProxy = cc.EventProxy.new(remote.soultower)
    self._soulTowerProxy:addEventListener(remote.soultower.EVENT_UPDATE_READTIPS, handler(self, self.checkRedTips))


	local isLock,historyFloor,historyWave = remote.soultower:getHistoryLockFloorWave()
	print("初始层数-----",historyFloor,historyWave)
	self:moveToByFloor(historyFloor,true)	

	self:setRoundTime()
	self:checkSeasonAward()	
end

function QUIDialogSoulTowerMain:viewWillDisappear()
  	QUIDialogSoulTowerMain.super.viewWillDisappear(self)
	self:removeBackEvent()
	QNotificationCenter.sharedNotificationCenter():removeEventListener(QNotificationCenter.EVENT_EXIT_FROM_BATTLE, self.exitFromBattleHandler, self)

    self._touchLayer:removeAllEventListeners()
    self._touchLayer:disable()
    self._touchLayer:detach()

    if self._soulTowerProxy ~= nil then 
        self._soulTowerProxy:removeAllEventListeners()
        self._soulTowerProxy = nil
    end

	if self._timeScheduler then
		scheduler.unscheduleGlobal(self._timeScheduler)
		self._timeScheduler = nil
	end   

	CCTextureCache:sharedTextureCache():removeUnusedTextures() 
end

function QUIDialogSoulTowerMain:setRoundTime()
	if self._timeScheduler then
		scheduler.unscheduleGlobal(self._timeScheduler)
		self._timeScheduler = nil
	end
	local rundInfo = remote.soultower:getSoulTowerMyRoundInfo() or {}
	local endTime = rundInfo.endAt or 0

	local timeFunc
	timeFunc = function ( )
		local lastTime = endTime/1000 - q.serverTime()
		if self:safeCheck() then
			if lastTime > 0 then
				local timeStr = q.timeToDayHourMinute(lastTime)
				self._ccbOwner.tf_endtime:setString(timeStr)
			else
				if self._timeScheduler then
					scheduler.unscheduleGlobal(self._timeScheduler)
					self._timeScheduler = nil
				end
				self._ccbOwner.tf_endtime:setString("轮次已结束")
			end
		end
	end

	self._timeScheduler = scheduler.scheduleGlobal(timeFunc, 1)
	timeFunc()
end

--赛季奖励为被领取时需要弹脸显示并领取奖励
function QUIDialogSoulTowerMain:checkSeasonAward()
	local awardInfo = remote.soultower:getSoulTowerRoundEndAward()
	if q.isEmpty(awardInfo) == false then
        app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSoulTowerRoundSeanAwards", options = {info = awardInfo}})
	end
end

function QUIDialogSoulTowerMain:checkRedTips(event)
	self._ccbOwner.award_tips:setVisible(remote.soultower:checkPassAwardTips())
	self._ccbOwner.shop_tips:setVisible(remote.stores:checkFuncShopRedTips(SHOP_ID.blackRockShop))
end

function QUIDialogSoulTowerMain:exitFromBattleHandler(event)
	self._isMoveFloor = true
	self._newspBgScaleX = self._spBgScaleX
	self._newspBgScaleY = self._spBgScaleY

	self._ccbOwner.sp_bg:setScale(1.48)
	CalculateUIBgSize(self._ccbOwner.sp_bg)

	remote.soultower:getSoulTowerMainInfoRequest(function()
		local isLock,curFloor,curWave = remote.soultower:getHistoryLockFloorWave()
		for index, floorCell in ipairs(self._soulTowerFloorCells) do
			floorCell:updateFloorInfo()
		end	
		local compareDungen = curWave + 1
		if curWave == remote.soultower:getMaxFloorDungenNum() then
			compareDungen = curWave
		end
		if self._chooseFloorInfo.floor == curFloor and self._chooseFloorInfo.dungeon  < compareDungen then
			for index,boss in pairs(self._showMonsterAnimal) do
				boss:showBossDeathEffect(index,function()
					if self:safeCheck() then
						self:playMoveAnimation(function( )
							self:updateMianSoulTowerInfo()
						end,true)
					end
				end,function()
					local bossNode = self._ccbOwner["node_boss_"..index]
					if bossNode then
						bossNode:setVisible(false)
					end
				end)
			end
		else
			if isLock and curFloor > self._chooseFloorInfo.floor then
				for index,boss in pairs(self._showMonsterAnimal) do
					boss:showBossDeathEffect(index,function()
						if self:safeCheck() then
							self:moveToByFloor(curFloor)	
						end
					end,function()
						local bossNode = self._ccbOwner["node_boss_"..index]
						if bossNode then
							bossNode:setVisible(false)
						end
					end)
				end		
			else
				self:updateMianSoulTowerInfo()
			end	
		end
	end,function()
		self._isMoveFloor = false
	end)
end

function QUIDialogSoulTowerMain:updateSoulTowerBackGround()
	if q.isEmpty(self._chooseFloorInfo) then return end
	local isLock,curFloor,curWave = remote.soultower:getHistoryLockFloorWave()
	if self._chooseFloorInfo and self._chooseFloorInfo.show_pic then
		QSetDisplaySpriteByPath(self._ccbOwner.sp_bg, self._chooseFloorInfo.show_pic)
	end

	local floorDungenNum = remote.soultower:getMaxFloorDungenNum()
	print("isLock,curFloor,curWave",isLock,curFloor,curWave,floorDungenNum)
	local isUnlock = false
	if curFloor > self._chooseFloorInfo.floor 
		or (curFloor == self._chooseFloorInfo.floor and curWave >= floorDungenNum) then --已通关
		self._ccbOwner.sp_pass:setVisible(true)
		self._ccbOwner.node_btn_info:setVisible(false)
		self._ccbOwner.node_battle:setVisible(false)

		self._chooseFloorState = remote.soultower.STATE_PASSED
	else
		self._ccbOwner.sp_pass:setVisible(false)
		self._ccbOwner.node_btn_info:setVisible(true)
		self._ccbOwner.node_battle:setVisible(true)
		if curFloor == self._chooseFloorInfo.floor and curWave < floorDungenNum then
			self._chooseFloorState = remote.soultower.STATE_LOCK_NOPASS
		else
			isUnlock = true
			self._chooseFloorState = remote.soultower.STATE_UNLOCK
		end
	end

	if self._chooseFloorState == remote.soultower.STATE_PASSED and self._chooseFloorInfo.floor == remote.soultower:getMaxFloor() then
		self._ccbOwner.sp_pass:setVisible(false)
		self._ccbOwner.node_btn_info:setVisible(true)
		self._ccbOwner.node_battle:setVisible(true)
	end

	local showMonsterStr = self._chooseFloorInfo.show_monster
	if showMonsterStr then
		local tabStr = string.split(showMonsterStr,",")
		for index, bossId in pairs(tabStr) do
			if bossId ~= "" and bossId ~= nil then
				local bossNode = self._ccbOwner["node_boss_"..index]
				if bossNode then
					bossNode:setVisible(true)
					if self._showMonsterAnimal[index] == nil then
						bossNode:removeAllChildren()
						local boss = QUIWidgetSoulTowerMonster.new()
						bossNode:addChild(boss)	
						self._showMonsterAnimal[index] = boss	
					end
				end

				self._showMonsterAnimal[index]:setMonserInfo(bossId,self._chooseFloorInfo)
			end
		end
	end

	self:showCloudsAction(isUnlock)
	self:showFloorWaveAwards()
	self:checkRedTips()
	self:showCurtenProcess()
end

function QUIDialogSoulTowerMain:showCurtenProcess()
	if q.isEmpty(self._chooseFloorInfo) then 
		self._ccbOwner.node_guanka:setVisible(false)
		return 
	end
	self._ccbOwner.node_guanka:setVisible(true)
	local curFloor = self._chooseFloorInfo.floor
	local dungeon = self._chooseFloorInfo.dungeon
	if self._chooseFloorState == remote.soultower.STATE_UNLOCK then
		dungeon = 1
	elseif self._chooseFloorState == remote.soultower.STATE_PASSED then
		dungeon = 10
	end
	local guankaStr = "第 "..curFloor.."-"..dungeon.." 关"
	self._ccbOwner.tf_guanka:setString(guankaStr)
	q.autoLayerNode({self._ccbOwner.tf_guanka,self._ccbOwner.node_btn},"x",10) 
end

function QUIDialogSoulTowerMain:showFloorWaveAwards( )
	local historyFloor,historyWave = remote.soultower:getHistoryPassFloorWave()
	
	local awardTbl = remote.soultower:getAwardsByfloorWave(historyFloor,historyWave)

	local curentStr = "当前"..historyFloor.."-"..historyWave.."累计"
	self._ccbOwner.node_floor_awards:removeAllChildren()
	local floorAward = QUIWidgetSoulTowerAwards.new({title = curentStr,targetAwardTbl = awardTbl,isTable = true,isProess = true})
	self._ccbOwner.node_floor_awards:addChild(floorAward)


	local isLock,targetFloor,showTargetWave = remote.soultower:getHistoryLockFloorWave()
	local targetWave = 10
	if showTargetWave >= 0 and showTargetWave < 5 then
		targetWave = 5
	end
	local targetStr = "达到"..targetFloor.."-"..targetWave.."可得"

	local targetAwardTbl = remote.soultower:getAwardsByfloorWave(targetFloor,targetWave)

	self._ccbOwner.node_wave_awards:removeAllChildren()
	local waveAward = QUIWidgetSoulTowerAwards.new({title = targetStr,targetAwardTbl = targetAwardTbl,isTable = true})
	self._ccbOwner.node_wave_awards:addChild(waveAward)

	local myRank = remote.soultower:getMySeverRank()
	if myRank == 0 then
		self._ccbOwner.tf_myRank:setString("无")
	else
		self._ccbOwner.tf_myRank:setString(myRank)
	end

	local rankAwards = remote.soultower:getMySoultowerRankAward(myRank)
	-- if rankAwards and rankAwards.global_rank_reward then
	self._ccbOwner.node_myrank_awards:removeAllChildren()
	local rankwidget = QUIWidgetSoulTowerAwards.new({title = "我的奖励",targetAwardTbl = rankAwards.local_rank_reward,isTable = false})
	self._ccbOwner.node_myrank_awards:addChild(rankwidget)
	-- end
end

function QUIDialogSoulTowerMain:showCloudsAction(isUnlock )
	if self._cloudsLocked == isUnlock then
		return
	end
	self._cloudsLocked = isUnlock
	self._ccbOwner.sp_yun_left:stopAllActions()
	self._ccbOwner.sp_yun_right:stopAllActions()
	if isUnlock then
		self._ccbOwner.sp_yun_left:setOpacity(0)
		self._ccbOwner.sp_yun_left:setPositionX(-display.width/2)
		self._ccbOwner.sp_yun_right:setOpacity(0)
		self._ccbOwner.sp_yun_right:setPositionX(display.width/2)

	    local arrleft = CCArray:create()
	    arrleft:addObject(CCMoveBy:create(0.5, ccp(display.width/2,0)))
	    arrleft:addObject(CCFadeTo:create(0.5, 255))
		self._ccbOwner.sp_yun_left:runAction(CCSpawn:create(arrleft))
	    local arrRight = CCArray:create()
	    arrRight:addObject(CCMoveBy:create(0.5, ccp(-display.width/2,0)))
	    arrRight:addObject(CCFadeTo:create(0.5, 255))		
		self._ccbOwner.sp_yun_right:runAction(CCSpawn:create(arrRight))

	else
		self._ccbOwner.sp_yun_left:setOpacity(255)
		self._ccbOwner.sp_yun_left:setPositionX(0)
		self._ccbOwner.sp_yun_right:setOpacity(255)
		self._ccbOwner.sp_yun_right:setPositionX(0)

	    local arrleft = CCArray:create()
	    arrleft:addObject(CCMoveBy:create(0.5, ccp(-display.width/2,0)))
	    arrleft:addObject(CCFadeTo:create(0.5, 0))
		self._ccbOwner.sp_yun_left:runAction(CCSpawn:create(arrleft))
	    local arrRight = CCArray:create()
	    arrRight:addObject(CCMoveBy:create(0.5, ccp(display.width/2,0)))
	    arrRight:addObject(CCFadeTo:create(0.5, 0))		
		self._ccbOwner.sp_yun_right:runAction(CCSpawn:create(arrRight))		
	end
end

function QUIDialogSoulTowerMain:updateMianSoulTowerInfo( )
	self._isMoveFloor = false
	for index, floorCell in ipairs(self._soulTowerFloorCells) do
		if floorCell:getIsChoose() then
			self._chooseFloorInfo = floorCell:getFloorInfo()
			self:updateSoulTowerBackGround()
			return
		end
	end
end

function QUIDialogSoulTowerMain:moveToByFloor(floor,isInit)
	if floor == nil then return end
	local touchIndex
	local chooseIndex 
	local delayTime = 0.15
	for index, floorCell in ipairs(self._soulTowerFloorCells) do
		if floorCell:getIsChoose() then
			chooseIndex = index
		end
		local floorInfo  = floorCell:getFloorInfo()
		if floorInfo and floorInfo.floor == floor then
			touchIndex = index
		end
	end
	if touchIndex and chooseIndex and chooseIndex ~= touchIndex then
		self._isMoveFloor = true
		local touchY = self:getFloorPosY(touchIndex,self._ccbOwner.node_norm:getPositionY())
		local chooseY = self:getFloorPosY(chooseIndex,self._ccbOwner.node_norm:getPositionY())

		local offsetY = chooseY-touchY
		if isInit then
			self._normY = self._ccbOwner.node_norm:getPositionY()
			delayTime = 1
		end
		self:moveTo(offsetY,true,delayTime,function( )
			self:updateMianSoulTowerInfo()
		end)
	end
end

function QUIDialogSoulTowerMain:touchFloorEvent(event)
	print("self._moveing--",self._moveing)
	if self._moveing then return end
	if self._exitbattleAction then return end
	if event.name == QUIWidgetSoulTowerFloor.SOULTOWER_BTN_CLICK then
		self._chooseFloorInfo = event.floorInfo 
		self:moveToByFloor(self._chooseFloorInfo.floor)
	end
end

function QUIDialogSoulTowerMain:onEnterFrame()
	self:exitEnterFrame()
	self._onEnterFrameHandler = scheduler.scheduleGlobal(handler(self, self.renderFrame), 0)
end

function QUIDialogSoulTowerMain:exitEnterFrame()
	if self._onEnterFrameHandler ~= nil then
		scheduler.unscheduleGlobal(self._onEnterFrameHandler)
		self._onEnterFrameHandler = nil
	end
end

function QUIDialogSoulTowerMain:getFloorPosY(index, normPosY)
	-- 点高度
	-- local arcLength = 70 + (index - 1) * self._cellHeight+normPosY
	local arcLength = index * self._cellHeight+normPosY
	return arcLength
end

function QUIDialogSoulTowerMain:renderFrame()
	if not self._ccbOwner.node_norm then
		return
	end
	local normPosY = self._ccbOwner.node_norm:getPositionY()
	self:getOptions().defaultPos = normPosY

	for index, floorCell in ipairs(self._soulTowerFloorCells) do
		local posY = self:getFloorPosY(index, normPosY)
		floorCell:setPosition(ccp(-170, posY))
		if posY < 70 + self._cellHeight /2 
			and posY > 70 - self._cellHeight /2 then
			floorCell:setSelect(true)
		else
			floorCell:setSelect(false)
		end
	end
end

function QUIDialogSoulTowerMain:contentRunAction(offsetY, delayTime, callback)
	self:onEnterFrame()
	if delayTime == nil then delayTime = 1.5 end
    local actionArrayIn = CCArray:create()
    local curveMove = CCMoveTo:create(delayTime, ccp(self._orginalPosition.x, offsetY))
    local speed
    speed = CCEaseExponentialOut:create(curveMove)
	actionArrayIn:addObject(speed)
    actionArrayIn:addObject(CCCallFunc:create(function () 
    		if self:safeCheck() then
				self:exitEnterFrame()
				self:renderFrame()
				self._isMoveFloor = false
				if callback then
					callback()
				end
			end
        end))
    local ccsequence = CCSequence:create(actionArrayIn)
	self._ccbOwner.node_norm:stopAllActions()		
    self._ccbOwner.node_norm:runAction(ccsequence)

end

function QUIDialogSoulTowerMain:moveTo(posY, isAnimation, delayTime, callback)
	local targetY = self._normY + posY
	local downHeight = -self._totalHeight + self._pageHeight
	local upHeight = self._orginPosY + self._pageHeight/2 - 90
	if targetY < -self._totalHeight + self._pageHeight/2  - self._cellHeight/2 then
		targetY = -self._totalHeight + self._pageHeight/2 - self._cellHeight/2
	elseif targetY > upHeight then
		targetY = upHeight
	end
	if isAnimation then
		self:contentRunAction(targetY, delayTime, callback, isUniform)
	else
		self._ccbOwner.node_norm:setPositionY(targetY)
		self:renderFrame()
	end
end

function QUIDialogSoulTowerMain:checkOffsetY(offsetY)
	local distanceY = offsetY		
	local normalCellIndex = math.floor(math.abs(distanceY)/self._cellHeight) + 1
	local movePosY = 0
	if distanceY < 0 then	
		movePosY = -1* self._cellHeight*normalCellIndex
	else
		movePosY = self._cellHeight*normalCellIndex			
	end

	return movePosY
end

-- 处理各种touch event
function QUIDialogSoulTowerMain:onTouchEvent(event)
    if event == nil or event.name == nil then
        return
    end
    if event.name == QUIGestureRecognizer.EVENT_SLIDE_GESTURE then
    	if self._startY == nil or self._normY == nil then
    		return
    	end
		local nowPosy = self._ccbOwner.node_norm:getPositionY()
		local distanceY = nowPosy - self._normY		

		local movePosY = self:checkOffsetY(distanceY)
    	if math.abs(movePosY) ~= 0 then
			self:moveTo(movePosY, true,0.3,function( )
				self:updateMianSoulTowerInfo()
			end)
		else		
			self:updateMianSoulTowerInfo()
		end
  	elseif event.name == "began" then
        self._startY = event.y
        self._normY = self._ccbOwner.node_norm:getPositionY()
    elseif event.name == "moved" then
    	if self._startY == nil or self._normY == nil then
    		return
    	end
        if math.abs(event.y - self._startY) > 20 then
            self._moveing = true
        end
    	local offsetY = event.y - self._startY
		self:moveTo(offsetY, false)
    elseif event.name == "ended" then
 		scheduler.performWithDelayGlobal(function ()
			self._moveing = false
		end, 0)
    end
end

--先播放消失动画
function QUIDialogSoulTowerMain:playBackAnimation(callback)
	self:enableTouchSwallowTop()
	local fun = function ()
		self:disableTouchSwallowTop()
		if callback ~= nil then
			callback()
		end
	end
	if self._bgCCB ~= nil then
		local bgCCB = self._bgCCB
		local oldArr = CCArray:create()
		oldArr:addObject(CCFadeOut:create(0.01))
		oldArr:addObject(CCCallFunc:create(function ()
			self._ccbOwner.sp_bg:setScale(2.2)
			fun()
		end))
		bgCCB.sp_map:runAction(CCSequence:create(oldArr))
	else
		fun()
	end
end

--播放前进动画
function QUIDialogSoulTowerMain:playMoveAnimation(callback, isAnimation)
	local animationName = "move"
	self:enableTouchSwallowTop()
	if self._bg == nil then
		self._bg = QUIWidgetAnimationPlayer.new()
		self._ccbOwner.map_content:addChild(self._bg)
	end



	self._bgCCB = self._bg:playAnimation("ccb/effects/tx_shenglingtai_bg_animation.ccbi", nil, function ()
		self:disableTouchSwallowTop()
		if self:safeCheck() then
			self:playBackAnimation(callback)		
		end
		-- if callback then
		-- 	callback()
		-- end
	end, false, animationName)

	if self._chooseFloorInfo and self._chooseFloorInfo.show_pic then
		QSetDisplaySpriteByPath(self._bgCCB.sp_map, self._chooseFloorInfo.show_pic)
	end
	CalculateUIBgSize(self._bgCCB.sp_map)	
end


-- function QUIDialogSoulTowerMain:showScreenAction(callback)
-- 	local value = 90
-- 	local actionTime = 1.2
-- 	local scaleValue1 = 1.15
-- 	local scaleValue2 = 1.3
	
-- 	local action1 = CCArray:create()
--     action1:addObject(CCMoveBy:create(actionTime/5, ccp(0, value)))
-- 	action1:addObject(CCMoveBy:create(actionTime/5, ccp(0, -value)))

-- 	self._newspBgScaleX = self._spBgScaleX*scaleValue2
-- 	self._newspBgScaleY = self._spBgScaleY*scaleValue2
-- 	local action2 = CCArray:create()
--     action2:addObject(CCScaleTo:create((actionTime/5) * 3, self._newspBgScaleX,self._newspBgScaleY))
--     action2:addObject(CCScaleTo:create((actionTime/5), self._newspBgScaleX,self._newspBgScaleY))
--     action2:addObject(CCCallFunc:create(function() 
--     	self._isMoveFloor = false
-- 		if self:safeCheck() and callback then
-- 		   	callback()
-- 		end
-- 	end))
--     self._ccbOwner.sp_bg:runAction(CCRepeat:create(CCSequence:create(action1), 2))
--     self._ccbOwner.sp_bg:runAction(CCSequence:create(action2))
-- end

function QUIDialogSoulTowerMain:_onTriggerStartBattle( )
	if self._isMoveFloor or self._moveing then return end

	print("self._chooseFloorState-",self._chooseFloorState)
	if self._chooseFloorState == remote.soultower.STATE_UNLOCK then
        app.tip:floatTip("当前层次未解锁")
        return
	end

	if self._chooseFloorInfo.floor ~= remote.soultower:getMaxFloor() and self._chooseFloorState == remote.soultower.STATE_PASSED then
        app.tip:floatTip("当前层次已通关")
        return
	end

    local herosInfos, count, force = remote.herosUtil:getMaxForceHeros()
    remote.soultower:setBattleFloor(self._chooseFloorInfo.floor)
    remote.soultower:setBattleDungenID(self._chooseFloorInfo.dungeon)
    local teamKey = remote.teamManager.SOUL_TOWER_BATTLE_TEAM

    local dungeonArrangement = QSoulTowerArrangement.new({force = force,floorInfo = self._chooseFloorInfo, teamKey = teamKey})
    app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogTeamArrangement",
        options = {arrangement = dungeonArrangement, isQuickWay = true}})
end

function QUIDialogSoulTowerMain:_onTriggerBossInfo()
	if self._isMoveFloor or self._moveing then return end
	app.sound:playSound("common_small")
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSoulTowerMonsterIntroduce", 
        options = {floorInfo = self._chooseFloorInfo}}, {isPopCurrentDialog = false})	
end

function QUIDialogSoulTowerMain:_onTriggerShop( event )
	if self._isMoveFloor or self._moveing then return end
    if q.buttonEventShadow(event, self._ccbOwner.btn_shop) == false then return end
    app.sound:playSound("common_small")
	remote.stores:openShopDialog(SHOP_ID.blackRockShop)
end

function QUIDialogSoulTowerMain:_onTriggerClickRank(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_rank) == false then return end
    app.sound:playSound("common_small")
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogRank", 
        options = {initRank = "soulTower"}}, {isPopCurrentDialog = false})
end

function QUIDialogSoulTowerMain:_onTriggerAward( event )
    app.sound:playSound("common_small")
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSoulTowerPassAward"})	
end

function QUIDialogSoulTowerMain:_onTriggerLockRank( event )
    app.sound:playSound("common_small")
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSoulTowerRankAwards"})
end

function QUIDialogSoulTowerMain:_onTriggerReplay( event)
	app.sound:playSound("common_small")
	if q.isEmpty(self._chooseFloorInfo) then return end
	local isLock,historyFloor,historyWave = remote.soultower:getHistoryLockFloorWave()
	print("isLock,historyFloor,historyWave",isLock,historyFloor,historyWave)
	local seeDungeon = self._chooseFloorInfo.dungeon 
	if historyFloor < self._chooseFloorInfo.floor then
		seeDungeon = 1
	elseif historyFloor > self._chooseFloorInfo.floor  then
		seeDungeon = 10
	end
	remote.soultower:soulTowerGetReportRequest(self._chooseFloorInfo.floor,seeDungeon,function(data)
        if self:safeCheck() and data.soulTowerGetReportsResponse then
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogMetalCityRecord",
				options = {info = data.soulTowerGetReportsResponse.reports or {},reportType = REPORT_TYPE.SOUL_TOWER}})
		end	
	end)
end

function QUIDialogSoulTowerMain:_onTriggerRule( event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_rule) == false then return end
    app.sound:playSound("common_small")
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogSoulTowerRule"})
end

function QUIDialogSoulTowerMain:viewAnimationOutHandler()
	local callback = self._callBack

	self:popSelf()

	if callback then
		callback()
	end
end


function QUIDialogSoulTowerMain:onTriggerBackHandler()
   if self._isMoveFloor or self._moveing then return end
   QUIDialogSoulTowerMain.super.onTriggerBackHandler(self)
end

function QUIDialogSoulTowerMain:onTriggerHomeHandler()
	if self._isMoveFloor or self._moveing then return end
	QUIDialogSoulTowerMain.super.onTriggerHomeHandler(self)
end

return QUIDialogSoulTowerMain
