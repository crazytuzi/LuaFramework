--
-- Author: wkwang
-- Date: 2015-01-14 20:06:17
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogArena = class("QUIDialogArena", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIWidgetHeroHead = import("..widgets.QUIWidgetHeroHead")
local QUIViewController = import("..QUIViewController")
local QUIWidgetArena = import("..widgets.QUIWidgetArena")
local QShop = import("...utils.QShop")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QTutorialDirector = import("...tutorial.QTutorialDirector")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QVIPUtil = import("...utils.QVIPUtil")
local QQuickWay = import("...utils.QQuickWay")
local QArenaArrangement = import("...arrangement.QArenaArrangement")
local QArenaDefenseArrangement = import("...arrangement.QArenaDefenseArrangement")
local QUIWidgetAvatar = import("..widgets.QUIWidgetAvatar")
local QUIGestureRecognizer = import("..QUIGestureRecognizer")
local QUIDialogUnionAnnouncement = import("..dialogs.QUIDialogUnionAnnouncement")
local QUIWidgetTopStatusShow = import("..widgets.QUIWidgetTopStatusShow")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QUIWidgetActorDisplay = import("..widgets.actorDisplay.QUIWidgetActorDisplay")
local QUIDialogBuyCount = import("..dialogs.QUIDialogBuyCount")



function QUIDialogArena:ctor(options)
 	local ccbFile = "ccb/Dialog_Arena.ccbi"
    local callBacks = {
        {ccbCallbackName = "onTriggerIntroduce", callback = handler(self, QUIDialogArena._onTriggerIntroduce)},
        {ccbCallbackName = "onTriggerRecord", callback = handler(self, QUIDialogArena._onTriggerRecord)},
        {ccbCallbackName = "onTriggerRank", callback = handler(self, QUIDialogArena._onTriggerRank)},
        {ccbCallbackName = "onTriggerShop", callback = handler(self, QUIDialogArena._onTriggerShop)},
        {ccbCallbackName = "onTriggerTeam", callback = handler(self, QUIDialogArena._onTriggerTeam)},
        {ccbCallbackName = "onTriggerWord", callback = handler(self, QUIDialogArena._onTriggerWord)},
        {ccbCallbackName = "onTriggerRefresh", callback = handler(self, QUIDialogArena._onTriggerRefresh)},
        {ccbCallbackName = "onTriggerScorePanel", callback = handler(self, QUIDialogArena._onTriggerScorePanel)},
        {ccbCallbackName = "onPlus", callback = handler(self, QUIDialogArena._onTriggerBuyCount)},
        {ccbCallbackName = "onTriggerClickPVP", callback = handler(self, self._onTriggerClickPVP)},   
    }
    QUIDialogArena.super.ctor(self, ccbFile, callBacks, options)
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	if page.setAllUIVisible then page:setAllUIVisible(false) end
	if page.topBar then page.topBar:showWithArena() end

	self._schedulers = {}

    self:checkRankChangeInfo()

	self:resetAll()
	self._ccbOwner.record_tips:setVisible(remote.arena:getTips(false))
	remote.arena:setTips(true, false)
 	CalculateBattleUIPosition(self._ccbOwner.node_map , true)
 	CalculateBattleUIPosition(self._ccbOwner.node_avatar , true)
	-- self._touchWidth = display.width--self._ccbOwner.touch_layer:getContentSize().width --适配全面屏
	self._touchWidth = self._ccbOwner.touch_layer:getContentSize().width 
	self._pageWidth = self._touchWidth
	self._orginPosX = 0
	-- self._ccbOwner.touch_layer:setPositionX(-self._pageWidth/2) --适配全面屏
	self._touchHeight = self._ccbOwner.touch_layer:getContentSize().height
	self._touchLayer = QUIGestureRecognizer.new()
	self._touchLayer:setSlideRate(0.3)
	self._touchLayer:setAttachSlide(true)
	self._touchLayer:attachToNode(self._ccbOwner.touch_node, self._touchWidth, self._touchHeight, self._ccbOwner.touch_layer:getPositionX(),
		self._ccbOwner.touch_layer:getPositionY(), handler(self, self.onTouchEvent))
  
	local config = QStaticDatabase:sharedDatabase():getConfiguration()
	self._totalCount = config.ARENA_FREE_FIGHT_COUNT.value or 0
	self._buyCount = 1
	self._farRate = 0.6
	self._fansPos = {}
    self:avatarTalkHandler()

    self:checkSelfShopRedTips()
    self._defaultPos = options.defaultPos

    self._pvpNodePosX = self._ccbOwner.node_pvp:getPositionX()
end

function QUIDialogArena:viewDidAppear()
    QUIDialogArena.super.viewDidAppear(self)
  	self:addBackEvent(false)
 
	self:refreshArena()
	self.arenaEventProxy = cc.EventProxy.new(remote.arena)
    self.arenaEventProxy:addEventListener(remote.arena.EVENT_UPDATE, handler(self, self.arenaResponseHandler))
    self.arenaEventProxy:addEventListener(remote.arena.EVENT_UPDATE_SELF, handler(self, self.responseSelfHandler))
    self.arenaEventProxy:addEventListener(remote.arena.EVENT_UPDATE_TEAM, handler(self, self.responseTeamHandler))
    self.arenaEventProxy:addEventListener(remote.arena.EVENT_SELF_RANK, handler(self, self.selfRankChangeHandler))
	QNotificationCenter.sharedNotificationCenter():addEventListener(QNotificationCenter.EVENT_EXIT_FROM_BATTLE, self.exitFromBattleHandler, self)
    self.arenaEventProxy:addEventListener(remote.arena.EVENT_UPDATE_WORSHIP, handler(self, self.worshipUpdateHandler))
    self.arenaEventProxy:addEventListener(remote.arena.EVENT_SCORE_CHANGE, handler(self, self.checkSelfShopRedTips))

    self._touchLayer:enable()
    self._touchLayer:addEventListener(QUIGestureRecognizer.EVENT_SLIDE_GESTURE, handler(self, self.onTouchEvent))
end

function QUIDialogArena:viewWillDisappear()
    QUIDialogArena.super.viewWillDisappear(self)
	self:removeBackEvent()

	if self.arenaEventProxy then
    	self.arenaEventProxy:removeAllEventListeners()
    	self.arenaEventProxy = nil
    end

    self._ccbOwner.touch_layer:setTouchEnabled(false)
  	self._ccbOwner.touch_layer:removeNodeEventListenersByEvent(cc.NODE_TOUCH_EVENT)
	if self._users ~= nil then
		for _,value in pairs(self._users) do
			value:removeAllEventListeners()
			value:removeFromParent()
		end
		self._users = nil
	end
	self:removeTimeCount()

	QNotificationCenter.sharedNotificationCenter():removeEventListener(QNotificationCenter.EVENT_EXIT_FROM_BATTLE, self.exitFromBattleHandler, self)
    self._touchLayer:removeAllEventListeners()
    self._touchLayer:disable()
    self._touchLayer:detach()
    self:exitEnterFrame()
	self:removeTalkHandler()
	if self._schedulerHandler ~= nil then
		scheduler.unscheduleGlobal(self._schedulerHandler)
		self._schedulerHandler = nil
	end
	for handler,_ in pairs(self._schedulers) do
		scheduler.unscheduleGlobal(handler)
	end
end

function QUIDialogArena:resetAll()
	self._totalWidth = 0
	self._ccbOwner.tf_rank:setString(0)
	self._ccbOwner.tf_defens_force:setString(0)

	self._ccbOwner.tf_count:setString("")
	self._ccbOwner.node_have:setVisible(false)
	self._ccbOwner.record_tips:setVisible(false)

	self._ccbOwner.node_time:setVisible(false)
end

function QUIDialogArena:exitFromBattleHandler()
	self:refreshArena()
end

--战队刷新
function QUIDialogArena:refreshArena(isForce)
	local options = self:getOptions()
	if options == nil then
		options = {}
		self:setOptions(options)
	end
	if options.arenaResponse ~= nil and isForce ~= true and remote.arena:getInBattle() == false then
		self.worship = options.arenaResponse.worshipFighter or {}
		self.myInfo = remote.arena:madeReciveData("self").arenaResponse.mySelf
		self:myTeamHandler()
		--手动刷新需动画
		local isManualRefresh = options.arenaResponse.isManualRefresh
		--战斗结束刷新
		local fighterResult, rivalId = remote.arena:getTopRankUpdate()
		remote.arena:setTopRankUpdate(nil,nil)
		if isManualRefresh == true or fighterResult ~= nil then
			if fighterResult ~= nil then
				self.rivals = options.arenaResponse.oldRivals or {}
				self:arenaRefreshWithAnimation(fighterResult, rivalId)
			else
				self:moveTo(-(self._totalWidth - self._pageWidth)+self._orginPosX, true, true)
				self._schedulerHandler = scheduler.performWithDelayGlobal(function ()
					self._schedulerHandler = nil
					self:competitorHandler()
					self.isManualRefresh = false
				end, 0.3)
				self.isManualRefresh = isManualRefresh
			end
			self.rivals = clone(options.arenaResponse.rivals or {})
			self.isManualRefresh = isManualRefresh
		else
			self.rivals = clone(options.arenaResponse.rivals or {})
			self:competitorHandler()
		end
	else
		remote.arena:setInBattle(false)
		remote.arena:requestArenaInfo(nil, isForce)
	end
end

function QUIDialogArena:arenaResponseHandler(event)
	local data = event.data
	self.worship = data.arenaResponse.worshipFighter or {}
	self.myInfo = clone(data.arenaResponse.mySelf)
	self:myTeamHandler()
	--手动刷新需动画
	local isManualRefresh = data.arenaResponse.isManualRefresh
	data.arenaResponse.isManualRefresh = false
	--战斗结束刷新
	local fighterResult, rivalId = remote.arena:getTopRankUpdate()
	remote.arena:setTopRankUpdate(nil,nil)
	local options = self:getOptions()
	options.arenaResponse = data.arenaResponse
	if isManualRefresh == true or fighterResult ~= nil then
		if fighterResult ~= nil then
			self.rivals = clone(data.arenaResponse.oldRivals or {})
			self:arenaRefreshWithAnimation(fighterResult, rivalId)
		else
			self:moveTo(-(self._totalWidth - self._pageWidth)+self._orginPosX, true, true)
			local handler = scheduler.performWithDelayGlobal(function ()
				self._schedulers[handler] = nil
				self:competitorHandler()
				self.isManualRefresh = false
			end, 0.3)
			self._schedulers[handler] = 1
			self.isManualRefresh = isManualRefresh
		end
		self.rivals = clone(data.arenaResponse.rivals or {})
	else
		self.rivals = clone(data.arenaResponse.rivals or {})
		self:competitorHandler()
	end
    self:checkSelfShopRedTips()
end

--一般用于战斗结束或者扫荡人物刷新的动画处理
function QUIDialogArena:arenaRefreshWithAnimation(fighterResult, rivalId)
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	if page.topBar then
		page.topBar:setDisableTopClick(true)
	end
	self:competitorHandler()
	self.fighterResult = fighterResult
	self.rivalId = rivalId
	--如果挑战对手不在挑战列表内
	local isInRival = false
	for index,value in pairs(self.rivals) do
		if value.userId == self.rivalId then
			self._rival = value
			isInRival = true
		end
	end
	self:competitorHandler()
	if isInRival == false then
		local handler = scheduler.performWithDelayGlobal(function ()
			self._schedulers[handler] = nil
			self:animationEndHandler()
		end,0)
		self._schedulers[handler] = 1
	elseif self.fighterResult.arenaResponse.mySelf.lastRank > self.fighterResult.arenaResponse.mySelf.rank then --播放踢人动画
		self:kickAnimationHandler()
	else
		local handler = scheduler.performWithDelayGlobal(function ()
			self._schedulers[handler] = nil
			self:animationEndHandler()
		end,0)
		self._schedulers[handler] = 1
	end
end

function QUIDialogArena:responseSelfHandler(event)
	local data = event.data
	self.myInfo = clone(data.arenaResponse.mySelf)
	self:myTeamHandler()
end

function QUIDialogArena:responseTeamHandler(event)
	local data = event.data
	self.myInfo = clone(data.arenaResponse.mySelf)
	self:myTeamHandler()
end

function QUIDialogArena:selfRankChangeHandler(event)
	self._ccbOwner.record_tips:setVisible(remote.arena:getTips(false))
	remote.arena:setTips(true, false)
end

function QUIDialogArena:worshipUpdateHandler(event)
	self:_renderFrame(true)
end

--战队信息处理
function QUIDialogArena:myTeamHandler()
	--设置战队成员
	-- set local instance team to server, server will save at frist time
	-- if server response team not compare local , then save local to server
	remote.arena:checkArenaDefenseTeam()

	-- set self info
	self:todayWorshipPosHandler(self.myInfo.todayWorshipPos)
	self._ccbOwner.tf_rank:setString(self.myInfo.rank)
	local force = remote.teamManager:getBattleForceForAllTeam(remote.teamManager.ARENA_DEFEND_TEAM, false)
	local fontInfo = QStaticDatabase:sharedDatabase():getForceColorByForce(tonumber(force),true)
	local num, unit = q.convertLargerNumber(force)
	self._ccbOwner.tf_defens_force:setString(num..(unit or ""))
	local color = string.split(fontInfo.force_color, ";")
	self._ccbOwner.tf_defens_force:setColor(ccc3(color[1], color[2], color[3]))
	self._ccbOwner.node_pvp:setPositionX( self._pvpNodePosX + self._ccbOwner.tf_defens_force:getContentSize().width)

	self._ccbOwner.node_pvp:setVisible(ENABLE_PVP_FORCE)
	self._ccbOwner.sp_team_tips:setVisible(not remote.teamManager:checkTeamStormIsFull(remote.teamManager.ARENA_DEFEND_TEAM))

	local config = QStaticDatabase:sharedDatabase():getConfiguration()

	self._refreshCount = remote.arena:getArenaRefreshCount()
	self._cdTime = config.ARENA_CD.value
	-- if self.myInfo.fightCount < (self._totalCount + self.myInfo.fightBuyCount * self._buyCount) then
	self._ccbOwner.node_have:setVisible(true)

	local fightBuyCount = self.myInfo.fightBuyCount or 0
	local count = (self._totalCount + fightBuyCount * self._buyCount)-(self.myInfo.fightCount or 0)
	self._ccbOwner.tf_count:setString(count)

	local totalVIPNum = QVIPUtil:getCountByWordField("arena_times_limit", QVIPUtil:getMaxLevel())
	local totalNum = QVIPUtil:getCountByWordField("arena_times_limit")
	self._ccbOwner.node_btn_plus:setVisible(totalVIPNum > totalNum or totalNum > fightBuyCount)
	
	local passTime = (self.myInfo.lastFrozenTime or 0)/1000 + self._cdTime
	if passTime > q.serverTime() and (self.myInfo.fightCount or 0) > 0 and (not app.unlock:checkLock("UNLOCK_ARENA_UNFREEZE")) then
		self._ccbOwner.node_time:setVisible(true)
		self:timeCount()
		self:resetTimeHandler(false)
	else
		self._ccbOwner.node_time:setVisible(false)
		self:resetTimeHandler(true)
	end
end

function QUIDialogArena:todayWorshipPosHandler(worshipPos)
	self._fansPos = {}
	if worshipPos ~= nil then
		local pos = string.split(worshipPos, ";")
		for _,value in ipairs(pos) do
			if value ~= "" then
				self._fansPos[tonumber(value)+1] = true
			end
		end
	end
end

--对手信息处理 --todo
function QUIDialogArena:competitorHandler()
	self._totalWidth = 0
	if self._emptyBox == nil then
		self._emptyBox = {}
	end
	if self._virtualFrame ~= nil then
		for _,frame in ipairs(self._virtualFrame) do
			if frame.widget ~= nil and frame.widget.setVisible then
				table.insert(self._emptyBox, frame.widget)
				frame.widget:setVisible(false)
				frame.widget = nil
			end
		end
	end
	self._virtualFrame = {}
	self._index = 0
	self._CellWidth = 215
	if self.worship.fighter ~= nil then
		for index,value in pairs(self.worship.fighter) do
			table.insert(self._virtualFrame, {index = index, value = value, isWorship = true, posX = self._index * self._CellWidth + self._CellWidth/2})
			self._totalWidth = self._totalWidth + self._CellWidth
			self._index = self._index + 1
		end
	end
	for index,value in pairs(self.rivals) do
		table.insert(self._virtualFrame, {value = value, isWorship = false, posX = self._index * self._CellWidth + self._CellWidth/2, isManualRefresh = self.isManualRefresh, rivalId = self.rivalId})
		self._totalWidth = self._totalWidth + self._CellWidth
		self._index = self._index + 1
	end
	if self._defaultPos ~= nil then
		self:moveTo(self._defaultPos, false, true)
		self._defaultPos = nil
	else
		self:moveTo(-(self._totalWidth - self._pageWidth)+self._orginPosX, false, true)
	end
	self:stopAvatarTalk()
	self._talkSchedulerHandler = scheduler.performWithDelayGlobal(handler(self, self.avatarTalkTime), 2)
end

function QUIDialogArena:onTouchEvent(event)
	if self.rivalId ~= nil then return end
	if event == nil or event.name == nil then
        return
    end
    if event.name == QUIGestureRecognizer.EVENT_SLIDE_GESTURE then
    	if self._startX == nil or self._pageX == nil then
    		return
    	end
		self:moveTo(event.distance.x, true, true)
  	elseif event.name == "began" then
  		self:_removeAction()
  		self._startX = event.x
  		self._pageX = self._ccbOwner.node_team:getPositionX()
    elseif event.name == "moved" then
    	if self._startX == nil or self._pageX == nil then
    		return
    	end
    	local offsetX = self._pageX + event.x - self._startX
        if math.abs(event.x - self._startX) > 10 then
            self._isMove = true
        end
		if self._totalWidth > self._pageWidth then
			if offsetX < -(self._totalWidth - self._pageWidth)+self._orginPosX then
				offsetX = -(self._totalWidth - self._pageWidth)+self._orginPosX
			elseif offsetX > self._orginPosX then
				offsetX = self._orginPosX
			end
			self:moveTo(offsetX, false)
		end
	elseif event.name == "ended" then
    	local handler = scheduler.performWithDelayGlobal(function ()
			self._schedulers[handler] = nil
    		self._isMove = false
    		end,0)
		self._schedulers[handler] = 1
    end
end

function QUIDialogArena:_removeAction()
	if self._actionHandler ~= nil then
		self._ccbOwner.node_team:stopAction(self._actionHandler)		
		self._actionHandler = nil
	end
	if self._actionFarHandler ~= nil then
		self._ccbOwner.node_team:stopAction(self._actionFarHandler)		
		self._actionFarHandler = nil
	end	
end

function QUIDialogArena:moveTo(posX, isAnimation, isCheck, delayTime)
	local targetX = posX
	local contentX = self._ccbOwner.node_team:getPositionX()
	local contenFartX = self._ccbOwner.node_far:getPositionX()
	if isCheck == true then
		if self._totalWidth <= self._pageWidth then
			targetX = self._orginPosX
		elseif contentX + posX < -(self._totalWidth - self._pageWidth)+self._orginPosX then
			targetX = -(self._totalWidth - self._pageWidth) + self._orginPosX
		elseif contentX + posX > self._orginPosX then
			targetX = self._orginPosX
		else
			targetX = contentX + posX
		end
	end
	if isAnimation == false then
		self._ccbOwner.node_team:setPositionX(targetX)
		self._ccbOwner.node_far:setPositionX(contenFartX + (targetX - contentX) * self._farRate)
		self:_renderFrame()
		return 
	end
	self:_contentRunAction(targetX, 0, delayTime)
end

function QUIDialogArena:_contentRunAction(posX,posY,delayTime)
	self:onEnterFrame()
	if delayTime == nil then delayTime = 0.5 end
    local actionArrayIn = CCArray:create()
    local curveMove = CCMoveTo:create(delayTime, ccp(posX,posY))
	local speed = CCEaseExponentialOut:create(curveMove)
	actionArrayIn:addObject(speed)
    actionArrayIn:addObject(CCCallFunc:create(function () 
    											self:_removeAction()
    											self:exitEnterFrame()
    											self:_renderFrame()
                                            end))
    local ccsequence = CCSequence:create(actionArrayIn)
    self._actionHandler = self._ccbOwner.node_team:runAction(ccsequence)

	local contentX = self._ccbOwner.node_team:getPositionX()
	local contenFartX = self._ccbOwner.node_far:getPositionX()
    local actionArrayIn = CCArray:create()
    local curveMove = CCMoveTo:create(delayTime, ccp(contenFartX + (posX - contentX) * self._farRate,posY))
	local speed = CCEaseExponentialOut:create(curveMove)
	actionArrayIn:addObject(speed)
    local ccsequence = CCSequence:create(actionArrayIn)
    self._actionFarHandler = self._ccbOwner.node_far:runAction(ccsequence)
end

function QUIDialogArena:onEnterFrame()
	self:exitEnterFrame()
	self._onEnterFrameHandler = scheduler.scheduleGlobal(handler(self, self._renderFrame), 0)
end

function QUIDialogArena:exitEnterFrame()
	if self._onEnterFrameHandler ~= nil then
		scheduler.unscheduleGlobal(self._onEnterFrameHandler)
	end
end

function QUIDialogArena:_renderFrame(isForce)
	local contentX = self._ccbOwner.node_team:getPositionX()
	if self._virtualFrame == nil then
		self:exitEnterFrame()
		return
	end
	for _,frame in ipairs(self._virtualFrame) do
		if frame.posX + contentX <= (self._orginPosX - self._CellWidth/2) or frame.posX + contentX >= (self._orginPosX + self._pageWidth + self._CellWidth/2) then
			self:framRenderHandler(frame, false, isForce)
		end
	end
	for _,frame in ipairs(self._virtualFrame) do
		if frame.posX + contentX > (self._orginPosX - self._CellWidth/2) and frame.posX + contentX < (self._orginPosX + self._pageWidth + self._CellWidth/2) then
			self:framRenderHandler(frame, true, isForce)
		end
	end
end

function QUIDialogArena:framRenderHandler(frame, isShow, isForce)
	if frame.isShow == isShow and isForce ~= true then
		return
	end
	frame.isShow = isShow
	if isShow == true then
		if frame.widget == nil then
			frame.widget = self:getEmptyFrame()
		end
		frame.widget:setPosition(frame.posX, -10)
		frame.widget:setInfo(frame.value, frame.isWorship, frame.index, self._fansPos[frame.index], frame.isManualRefresh, frame.rivalId, self.fighterResult, self._rival)
		frame.isManualRefresh = false
		frame.rivalId = nil
		frame.widget:setVisible(true)
		self:addAvatarTalk(frame.widget)
		return
	end
	if isShow == false then
		if frame.widget ~= nil then
			table.insert(self._emptyBox, frame.widget)
			frame.widget:setVisible(false)
			self:removeAvatarTalk(frame.widget)
			frame.widget = nil
		end
		return
	end
end

function QUIDialogArena:getEmptyFrame()
	if #self._emptyBox > 0 then
		return table.remove(self._emptyBox)
	end
	local userCell = QUIWidgetArena.new()
	userCell:addEventListener(userCell.EVENT_WORSHIP, handler(self, self.worshipHandler))
	userCell:addEventListener(userCell.EVENT_BATTLE, handler(self, self.startBattleHandler))
	userCell:addEventListener(userCell.EVENT_QUICK_BATTLE, handler(self, self.quickBattleHandler))
	userCell:addEventListener(userCell.EVENT_VISIT, handler(self, self.clickCellHandler))
	userCell:addEventListener(userCell.EVENT_ANIMATION, handler(self, self.animationEndHandler))
	userCell:setScale(0.95)
	self._ccbOwner.node_avtar:addChild(userCell)
	return userCell
end

-- 检查商店小红点
function QUIDialogArena:checkSelfShopRedTips()
	self._ccbOwner.shop_tips:setVisible(false)

	if remote.stores:checkFuncShopRedTips(SHOP_ID.arenaShop) then
		self._ccbOwner.shop_tips:setVisible(true)
	end
	self._ccbOwner.score_tips:setVisible(remote.arena:dailyRewardCanGet())
end

----------------------处理avatar气泡部分-------------------
function QUIDialogArena:avatarTalkHandler()
	self._avatarWord = {}
	self:removeTalkHandler()
end

function QUIDialogArena:removeTalkHandler()
	if self._talkSchedulerHandler ~= nil then 
		scheduler.unscheduleGlobal(self._talkSchedulerHandler)
	end
end

function QUIDialogArena:avatarTalkTime()
	local totalCount = #self._avatarWord
	if totalCount <= 0 then return end
	local count = math.random(1, totalCount)
	self:startAvatarTalk(self._avatarWord[count].widget)
end

function QUIDialogArena:startAvatarTalk(widget, word)
	self:stopAvatarTalk()
	for index,value in ipairs(self._avatarWord) do
		if value.widget == widget then
			widget:showWord(word)
			value.istalk = true
			break
		end
	end
	self._talkSchedulerHandler = scheduler.performWithDelayGlobal(handler(self, self.avatarTalkTime), 8)
end

function QUIDialogArena:stopAvatarTalk()
	self:removeTalkHandler()
	for index,value in ipairs(self._avatarWord) do
		if value.istalk == true then
			value.widget:removeWord()
			value.istalk = false
		end
	end
end

function QUIDialogArena:addAvatarTalk(widget)
	table.insert(self._avatarWord, {widget = widget, istalk = false})
end

function QUIDialogArena:removeAvatarTalk(widget)
	for index,value in ipairs(self._avatarWord) do
		if value.widget == widget then
			if value.istalk == true then
				self:stopAvatarTalk()
				self._talkSchedulerHandler = scheduler.performWithDelayGlobal(handler(self, self.avatarTalkTime), 2)
			end
			table.remove(self._avatarWord, index)
			return
		end
	end
end

function QUIDialogArena:removeAllAvatarTalk()
	if self._avatarWord ~= nil then
		for index,value in ipairs(self._avatarWord) do
			if value.widget == widget then
				value.widget:removeWord()
			end
		end
	end
	self._avatarWord = {}
end

-----------------------------------------------------------
function QUIDialogArena:timeCount()
	self:removeTimeCount()
	local timeFun = function()
			local passTime = q.serverTime() - (self.myInfo.lastFrozenTime or 0)/1000
			if passTime <= self._cdTime and (not app.unlock:checkLock("UNLOCK_ARENA_UNFREEZE"))then
				local needTime = self._cdTime - passTime 
				self._ccbOwner.tf_time:setString(string.format("%02d:%02d后", math.floor(needTime/60),math.floor(needTime%60)))
				self:resetTimeHandler(false)
			else
				self._ccbOwner.node_time:setVisible(false)
				self:removeTimeCount()
				self:resetTimeHandler(true)
			end
		end
	self._timeHandler = scheduler.scheduleGlobal(timeFun, 1)
	timeFun()
end

--显示斗魂场的重置CD
function QUIDialogArena:resetTimeHandler(b)
	-- print(debug.traceback())
	-- if self._resetCount == b then return end
	self._resetCount = b
	-- makeNodeFromGrayToNormal(self._ccbOwner.node_refresh)
	if b == true then
		self._ccbOwner.tf_refresh:setString("换一批")
		if self._refreshCount >= QStaticDatabase:sharedDatabase():getConfiguration().ARENA_FREE_REFRESH_TIME.value then
			self._ccbOwner.tf_token:setString(QStaticDatabase:sharedDatabase():getConfiguration().ARENA_TIME_COST.value)
		else
			self._ccbOwner.tf_token:setString("免费")
		end
	else
		self._ccbOwner.tf_refresh:setString("重置")
		self._ccbOwner.tf_token:setString(QStaticDatabase:sharedDatabase():getConfiguration().ARENA_CD_REMOVE.value)
		-- if QVIPUtil:canResetArenaCD() == false then
		-- 	makeNodeFromNormalToGray(self._ccbOwner.node_refresh)
		-- end
	end
end

function QUIDialogArena:removeTimeCount()
	if self._timeHandler ~= nil then
		scheduler.unscheduleGlobal(self._timeHandler)
	end
end

function QUIDialogArena:startBattle(userId)
	local rivalInfo = nil
	local rivalsPos = 0
	for _,value in pairs(self.rivals) do
		if value.userId ~= remote.user.userId then
	      	rivalsPos = rivalsPos + 1
			if value.userId == userId then
				rivalInfo = value
				break
			end
		end
	end
	if rivalInfo == nil then
		rivalsPos = 1
		for _,value in pairs(self.worship.fighter) do
			if value.userId == userId then
				rivalInfo = value
				break
			end
		end
	end
	if rivalInfo == nil then
		return 
	end

	local battleFunc = function ()
		local teams = remote.teamManager:getActorIdsByKey(remote.teamManager.ARENA_ATTACK_TEAM)
		if teams == nil or #teams == 0 then
			local teamVO = remote.teamManager:getTeamByKey(remote.teamManager.INSTANCE_TEAM)
		    remote.teamManager:saveTeamToLocal(teamVO, remote.teamManager.ARENA_ATTACK_TEAM)
		end
		
		local arenaArrangement = QArenaArrangement.new({rivalInfo = rivalInfo, rivalsPos = rivalsPos, myInfo = self.myInfo, info = self:getOptions()})
		app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogTeamArrangement",
			options = {arrangement = arenaArrangement}})
	end

	remote.arena:arenaFightStartCheckRequest(self.myInfo.userId, self.myInfo.rank, rivalInfo.userId, rivalInfo.rank, function(data)
			if self:safeCheck() then
				if data.gfStartCheckResponse and data.gfStartCheckResponse.arenaFightStartCheckResponse and (data.gfStartCheckResponse.arenaFightStartCheckResponse.isRivalPosChanged or data.gfStartCheckResponse.arenaFightStartCheckResponse.isSelfPosChanged) then
					app:alert({content = "排名发生了变化，确认刷新后重新开始挑战", callback = function (state)
						if state == ALERT_TYPE.CONFIRM then
							remote.arena:requestArenaInfo(nil, false)
						end
					end})
				else
					if battleFunc then
						battleFunc()
					end
				end
			end
		end, function()
			if battleFunc then
				battleFunc()
			end
		end)
end

function QUIDialogArena:quickBattle(userId)
	local rivalsPos = 0
	for _,value in pairs(self.rivals) do
		if value.userId ~= remote.user.userId then
	      	rivalsPos = rivalsPos + 1
			if value.userId == userId then
				break
			end
		end
	end
	self.rivalId = userId
	local oldArenaMoney = remote.user.arenaMoney
	local oldScore = self.myInfo.arenaRewardIntegral
	self:enableTouchSwallowTop()
	local battleType = BattleTypeEnum.ARENA
	app:getClient():arenaQuickFightRequest(battleType, userId, rivalsPos, function (data)
        remote.activity:updateLocalDataByType(543, 1)
		if self:safeCheck() then
			self.rivalId = nil
			remote.user:addPropNumForKey("todayArenaFightCount")
			remote.user:addPropNumForKey("addupArenaFightCount")
			remote.arena:setInBattle(true)
			remote.arena:setTopRankUpdate(data, userId)

			app.taskEvent:updateTaskEventProgress(app.taskEvent.ARENA_TASK_EVENT, 1, false, true)

			local batchAwards = {}
			local awards = data.extraExpItem or {}
			table.insert(awards, {type = ITEM_TYPE.ARENA_MONEY ,count = (remote.user.arenaMoney - oldArenaMoney)})
			table.insert(batchAwards, {awards = awards})
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogUnityFastBattle", 
				options = {awards = batchAwards, yield = data.arenaMoneyYield, activityYield = data.arenaMoneyActivityYield, userComeBackRatio = data.userComeBackRatio, score = data.arenaResponse.mySelf.arenaRewardIntegral - oldScore, name = "斗魂场扫荡", callback = function ()
					self:disableTouchSwallowTop()
		    		if self:safeCheck() then
						self:refreshArena()
					end
				end}},{isPopCurrentDialog = false})
		end
	end,function ()
		self.rivalId = nil
		self:disableTouchSwallowTop()
	end)
end

function QUIDialogArena:_teamIsNil()
  	app:alert({content="还未设置战队，无法参加战斗！现在就设置战队？",title="系统提示",callback= function(state)
  		if state == ALERT_TYPE.CONFIRM then
			self:_onTriggerTeam()
		end
  	end})
end

function QUIDialogArena:_onTriggerIntroduce(event)
    app.sound:playSound("common_small")
  	app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogArenaHelp",
    options = {info = self.myInfo}})
end

function QUIDialogArena:clickCellHandler(event)
	if self.rivalId ~= nil then return end
	if self._isMove then return end
    app.sound:playSound("common_small")

	event.info.text = "胜利场数："
	local rivalsPos = 0
	if event.info.userId ~= remote.user.userId then
		for _,value in pairs(self.rivals) do
			if value.userId ~= remote.user.userId then
		      	rivalsPos = rivalsPos + 1
				if value.userId == event.info.userId then
					break
				end
			end
		end
		if rivalsPos == nil then
			rivalsPos = 1
		end
	end
	
	app:getClient():arenaQueryFighterRequest(event.info.userId, function(data)
			local fighter = data.arenaResponse.fighter
			local count = remote.arena:getArenaMoneyByRivals(rivalsPos, event.info.rank)
	    	local typeName = "arenaMoney"
	    	local award = { {typeName = typeName, count = count} }
	  		app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogPlayerInfo",
	                options = {fighter = fighter, specialTitle1 = "胜利场数：", specialValue1 = fighter.victory, 
	                awardTitle2 = "胜利奖励：", awardValue2 = award, forceTitle = "防守战力：", isPVP = true}}, {isPopCurrentDialog = false})
		end)
end

--[[
	播放死亡动画结束
]]
function QUIDialogArena:animationEndHandler(event) 
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	if page.topBar then
		page.topBar:setDisableTopClick(false)
	end

	if self.fighterResult ~= nil and self.fighterResult.arenaResponse.mySelf.lastRank > self.fighterResult.arenaResponse.mySelf.topRank and self.fighterResult.arenaResponse.arenaTopRankAward > 0 then
	  	app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogArenaRankTop",
	    	options = {myInfo = self.fighterResult.arenaResponse.mySelf, token = self.fighterResult.arenaResponse.arenaTopRankAward, callBack = function ()
				self.rivalId = nil
	    		if self:safeCheck() then
	    			if self._rivalAvatar ~= nil then 
	    				self._rivalAvatar:removeFromParent()
	    				self._rivalAvatar = nil
	    			end
	    			if self._selfAvatar ~= nil then 
	    				self._selfAvatar:removeFromParent()
	    				self._selfAvatar = nil
	    			end
					self:competitorHandler()
					self.isManualRefresh = false
				end
	    	end}}, {isPopCurrentDialog = false})
		self.isManualRefresh = true
  	else
		if self._rivalAvatar ~= nil then 
			self._rivalAvatar:removeFromParent()
			self._rivalAvatar = nil
		end
		if self._selfAvatar ~= nil then 
			self._selfAvatar:removeFromParent()
			self._selfAvatar = nil
		end
		self.rivalId = nil
		self.isManualRefresh = true
		self:competitorHandler()
		self.isManualRefresh = false
	end
	self.fighterResult = nil
end

--播放踢人的动画
function QUIDialogArena:kickAnimationHandler()
local rivalFrame = nil
	local selfFrame = nil
	for  _,frame in ipairs(self._virtualFrame) do
		if frame.isWorship == false then
			if frame.value.userId == self.rivalId then
				rivalFrame = frame
			elseif frame.value.userId == remote.user.userId then
				selfFrame = frame
			end
		end
	end
	if rivalFrame == nil or selfFrame == nil then --没找到直接结束
		self:animationEndHandler()
		return
	end
 	if rivalFrame.widget ~= nil then
 		rivalFrame.widget:setGag(true)
 		rivalFrame.widget:removeWord()
 	end
 	if selfFrame.widget ~= nil then
 		selfFrame.widget:setGag(true)
 		selfFrame.widget:removeWord()
 	end

 	local rivalActorId 
	local selfActorId 
 	if rivalFrame.value.defaultActorId and rivalFrame.value.defaultActorId ~= 0 then 
		rivalActorId = rivalFrame.value.defaultActorId
	end
	if not rivalActorId then
		local rivalActorInfo = remote.herosUtil:getMaxForceByHeros(rivalFrame.value)
		if not rivalActorInfo then
			self:animationEndHandler()
			return
		else
			rivalActorId = rivalActorInfo.actorId
		end
	end

	local selfInfo = self.fighterResult.arenaResponse.mySelf
	if selfInfo.defaultActorId and selfInfo.defaultActorId ~= 0 then 
		selfActorId = selfInfo.defaultActorId
	end

	if not selfActorId then
		local selfActorInfo = remote.herosUtil:getMaxForceByHeros(selfInfo)
		if not selfActorInfo then
			self:animationEndHandler()
			return
		else
			selfActorId = selfActorInfo.actorId
		end
	end
	
	self._rivalAvatar = QUIWidgetActorDisplay.new(rivalActorId, {heroInfo = {skinId = rivalFrame.value.defaultSkinId}})
	self._rivalAvatar:setScaleX(-1.3)
	self._rivalAvatar:setScaleY(1.3)
	local rivalPos = ccp(rivalFrame.posX+9, -82)
	self._rivalAvatar:setPositionX(rivalPos.x)
	self._rivalAvatar:setPositionY(rivalPos.y)
	self._ccbOwner.node_avtar:addChild(self._rivalAvatar, -1)
	self._selfAvatar = QUIWidgetActorDisplay.new(selfActorId, {isSelf = true, heroInfo = {skinId = selfInfo.defaultSkinId}})
	self._selfAvatar:setScaleX(-1.3)
	self._selfAvatar:setScaleY(1.3)
	local selfPos = ccp(selfFrame.posX+9, -82)
	self._selfAvatar:setPositionX(selfPos.x)
	self._selfAvatar:setPositionY(selfPos.y)
	self._ccbOwner.node_avtar:addChild(self._selfAvatar, -1) 

	--自己移动
	local arr = CCArray:create()
    arr:addObject(CCMoveTo:create(0.2,ccp(selfPos.x+8, selfPos.y+47)))
    arr:addObject(CCMoveTo:create(0.4,ccp(rivalPos.x, rivalPos.y)))
    arr:addObject(CCRotateTo:create(0.05, 10))
    arr:addObject(CCRotateTo:create(0.05, 0))
    arr:addObject(CCRotateTo:create(0.05, 10))
    arr:addObject(CCRotateTo:create(0.05, 0))
    arr:addObject(CCCallFunc:create(function()
    	if rivalFrame.widget ~= nil then
    		rivalFrame.widget:hideBaseInfo(false, function ()
    			if rivalFrame.widget then
	    			rivalFrame.widget:changeBaseInfo(selfFrame.value)
	    			rivalFrame.widget:hideBaseInfo(true, function ()
	    				if self._selfAvatar then
	    					self._selfAvatar:displayWithBehavior(ANIMATION_EFFECT.VICTORY)
	    				end
	    			end)
	    		end
    		end)
    	end
    	if selfFrame.widget ~= nil then
    		selfFrame.widget:hideBaseInfo(false)
    	end
    	end))
    arr:addObject(CCDelayTime:create(3))
    arr:addObject(CCCallFunc:create(function()
	  	self:animationEndHandler()
    	end))
    self._selfAvatar:runAction(CCSequence:create(arr))

    --对手移动
	local arr2 = CCArray:create()
    arr2:addObject(CCDelayTime:create(0.5))
    arr2:addObject(CCCallFunc:create(function()
    	local rivalAnimationPlayer = QUIWidgetAnimationPlayer.new()
    	rivalAnimationPlayer:playAnimation("ccb/effects/Arena_sg.ccbi", nil,nil,true)
    	rivalAnimationPlayer:setPositionX(rivalPos.x)
    	rivalAnimationPlayer:setPositionY(rivalPos.y+40)
    	self._ccbOwner.node_avtar:addChild(rivalAnimationPlayer)
    end))
    arr2:addObject(CCMoveTo:create(0,ccp(rivalPos.x-100, rivalPos.y+20)))
    local arr3 = CCArray:create()
    arr3:addObject(CCMoveTo:create(0.6, ccp(rivalPos.x-500, rivalPos.y+600)))
    arr3:addObject(CCRotateTo:create(0.6, 1080))
    arr2:addObject(CCSpawn:create(arr3))
    arr2:addObject(CCCallFunc:create(function()
		if self._rivalAvatar ~= nil then 
			self._rivalAvatar:removeFromParent()
			self._rivalAvatar = nil
		end
    end))
    self._rivalAvatar:runAction(CCSequence:create(arr2))

    --界面移动
    local oldIndex = 0
    for index,rival in ipairs(self.rivals) do
    	if rival.userId == self.rivalId then
    		oldIndex = index
    	end
    end
    local arr4 = CCArray:create()
    arr4:addObject(CCDelayTime:create(0.2))
    arr4:addObject(CCCallFunc:create(function()
	    local newIndex = 0
	    for index,rival in ipairs(self.rivals) do
	    	if rival.userId == remote.user.userId then
	    		newIndex = index
	    	end
	    end
	    local offset = newIndex - oldIndex
	    if offset < 0 then
	    	offset = 0
	    end
    	self:moveTo(-(self._totalWidth - self._pageWidth) + self._orginPosX + offset * (self._CellWidth or 0),true,false,0.4)
    end))
    self:getView():runAction(CCSequence:create(arr4))
end

function QUIDialogArena:worshipHandler(event)
	if self._isMove then return end
    app.sound:playSound("common_small")
	if self._fansPos[event.index] == true then
        app.tip:floatTip("今日已经膜拜过了") 
    else
    	local widget = event.widget
		remote.arena:arenaWorshipRequest(event.info.userId, event.index-1, function (data)
			local money = data.arenaWorshipResponse.money - remote.user.money
			remote.user:update({money = data.arenaWorshipResponse.money})
			if self:safeCheck() then
				self:todayWorshipPosHandler(data.arenaWorshipResponse.todayWorshipPos)
				widget:showFans()
				if self._worshipAnimationPlayer ~= nil then
					self._worshipAnimationPlayer:disappear()
					self:getView():removeChild(self._worshipAnimationPlayer)
					self._worshipAnimationPlayer = nil
				end
				self._worshipAnimationPlayer = QUIWidgetAnimationPlayer.new()
				if data.arenaWorshipResponse.yield > 1 then
					self._worshipAnimationPlayer:playAnimation("ccb/effects/Baoji_mobai.ccbi", function (ccbOwner)
						ccbOwner.tf_money:setString(money)
						ccbOwner.tf_2:setString(" 金魂币")
						ccbOwner.tf_2:setPositionX(ccbOwner.tf_money:getPositionX() + ccbOwner.tf_money:getContentSize().width/2 + 10)
						-- ccbOwner.tf_2:setString(" x"..data.arenaWorshipResponse.yield.." 金魂币")
						if data.arenaWorshipResponse.yield > 2 then
							ccbOwner.sp_title1:setVisible(false)
						else
							ccbOwner.sp_title2:setVisible(false)
						end
					end)
				else
					self._worshipAnimationPlayer:playAnimation("ccb/effects/team_arena.ccbi", function (ccbOwner)
						ccbOwner.tf_2:setString(" 金魂币")
						ccbOwner.tf_money:setString(money)
					end)
				end
				self:getView():addChild(self._worshipAnimationPlayer)
			end
		end)
	end
end

function QUIDialogArena:startBattleHandler(event)
	if self.rivalId ~= nil then return end
	if self._isMove then return  end
    app.sound:playSound("common_small")
	self:checkCanBattle(event, handler(self, self.startBattle))
end

function QUIDialogArena:quickBattleHandler(event)
	if self.rivalId ~= nil then return end
	if self._isMove then return  end
    app.sound:playSound("common_confirm")
	if app.unlock:checkLock("UNLOCK_ARENA_QUICK_FIGHT") == false then
		app.unlock:tipsLock("UNLOCK_ARENA_QUICK_FIGHT", "斗魂场扫荡", true)
		return
	end
	self:checkCanBattle(event, handler(self, self.quickBattle))
end

function QUIDialogArena:checkCanBattle(event, startHandler)
	if event.info.userId == remote.user.userId then
		app.tip:floatTip("不能挑战自己！")
		return
	end
	if event.isWorship == true and self.myInfo.rank > 20 then
		app.tip:floatTip("太不自量力了，先冲到前20名再来挑战我吧！")
        -- self:startAvatarTalk(event.widget, "太不自量力了，先冲到前20名再来挑战我吧！")
        return 
	end
	if ((self._totalCount + (self.myInfo.fightBuyCount or 0) * self._buyCount) - self.myInfo.fightCount) <= 0 then
    	self:_onTriggerBuyCount()
		return 
	end
	local actorIds = remote.teamManager:getActorIdsByKey(remote.teamManager.ARENA_DEFEND_TEAM)
  	if q.isEmpty(actorIds) then
    	self:_teamIsNil()
    	return 
  	end

	local passTime = q.serverTime() - (self.myInfo.lastFrozenTime or 0)/1000
	local config = QStaticDatabase:sharedDatabase():getConfiguration()
	if passTime <= self._cdTime and self.myInfo.fightCount > 0 and (not app.unlock:checkLock("UNLOCK_ARENA_UNFREEZE"))  then
  		if app.unlock:checkLock("ARENA_RESET") == false then
			app.unlock:tipsLock("ARENA_RESET", "斗魂场CD重置")
			return
		else
  			local CDToken = config.ARENA_CD_REMOVE.value
			app:alert({content=string.format("是否花费%d钻石消除冷却时间直接挑战对方?", CDToken),title="系统提示",
				callback=function(state)
					if state == ALERT_TYPE.CONFIRM then
						if CDToken > remote.user.token then
							QQuickWay:addQuickWay(QQuickWay.TOKEN_DROP_WAY, nil)
						else
							remote.arena:arenaClearFrozenTimeRequest(function ()
								if self:safeCheck() then
									startHandler(event.info.userId)
								end
							end)
						end
					end
				end})
			return 
		end
	end
	startHandler(event.info.userId)
end

function QUIDialogArena:checkRankChangeInfo()
	remote.userDynamic:openDynamicDialog(1, function(isConfirm)
			if self:safeCheck() then
				if isConfirm == false then
					remote.arena:setTips(false, true)
				else
					self:_onTriggerRecord()
				end
			end
		end)
end

function QUIDialogArena:_onTriggerRecord(event)
	if self.rivalId ~= nil then return end
    app.sound:playSound("common_small")
	remote.arena:setTips(false, false)
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogAgainstRecord", options = {reportType = REPORT_TYPE.ARENA}}, 
		{isPopCurrentDialog = false})
end

function QUIDialogArena:_onTriggerRank(event)
	if self.rivalId ~= nil then return end
    app.sound:playSound("common_small")
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogRank", 
		options = {initRank = "arena"}}, {isPopCurrentDialog = false})
end

function QUIDialogArena:_onTriggerShop(event)
	if self.rivalId ~= nil then return end
    app.sound:playSound("common_small")
    remote.stores:openShopDialog(SHOP_ID.arenaShop)
end

function QUIDialogArena:_onTriggerTeam(event)
	if self.rivalId ~= nil then return end
	if q.buttonEventShadow(event, self._ccbOwner.btn_team) == false then return end
	if event ~= nil then
    	app.sound:playSound("common_small")
    end
    -- QPrintTable(self.myInfo)
	local arenaDefenseArrangement = QArenaDefenseArrangement.new({selectSkillHero = self.myInfo.activeSubActorId, selectSkillHero2 = self.myInfo.activeSub2ActorId, teamKey = remote.teamManager.ARENA_DEFEND_TEAM})
	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogTeamArrangement",
		options = {arrangement = arenaDefenseArrangement, isBattle = true, backCallback = function()
               	if remote.arena:getNeedRefreshMark() then
					remote.arena:requestArenaInfo()
					remote.arena:setNeedRefreshMark(false)
               	end
            end}})
end

--宣言
function QUIDialogArena:_onTriggerWord(event)
	if self.rivalId ~= nil then return end
    app.sound:playSound("common_small")


	local declaration = remote.user.declaration
	if self.myInfo.declaration == nil or self.myInfo.declaration == "" then
		declaration = "这家伙很懒， 什么也没有留下"
	end

    app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogUnionAnnouncement", 
        options = {type = QUIDialogUnionAnnouncement.TYPE_ARENA_WORD, word = declaration, confirmCallback = function (word)
        	if #word > 0 then
            	remote.arena:arenaSetDeclarationRequest(word, function (data)
            		self.myInfo.declaration = data.arenaSetDeclarationResponse.fighter.declaration
            		remote.arena:refreshWordById(self.myInfo.userId, self.myInfo.declaration)
					app.tip:floatTip("恭喜您, 成功修改宣言")
            	end)
            else
				app.tip:floatTip("请输入内容！")
            end
        end}}, {isPopCurrentDialog = false})
end

function QUIDialogArena:_onTriggerBuyCount(event)
	if self.rivalId ~= nil then return end
	if q.buttonEventShadow(event, self._ccbOwner.btn_plus) == false then return end
	if event ~= nil then
    	app.sound:playSound("common_small")
    end
	if (self.myInfo.fightBuyCount or 0) >= QVIPUtil:getArenaResetCount() then
		self:_showVipAlert(3)
	else
		-- app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogBuyCount",
		-- 	options = {typeName = QUIDialogBuyCount["BUY_TYPE_8"], buyCount = self.myInfo.fightBuyCount, buyCallback = function () 
		-- 		remote.activity:updateLocalDataByType(505,1)
		-- 	end}})
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogBuyCountBase",
			options = {cls = "QBuyCountArena"}})
	end
end

function QUIDialogArena:_onTriggerClickPVP(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_pvp) == false then return end
    app.sound:playSound("common_small")

    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogPVPPropTip", 
        options = {teamKey = remote.teamManager.ARENA_DEFEND_TEAM}}, {isPopCurrentDialog = false})
end

function QUIDialogArena:_onTriggerRefresh(event)
	if self.rivalId ~= nil then return end
	if q.buttonEventShadow(event, self._ccbOwner.btn_refresh) == false then return end
    app.sound:playSound("common_small")
	if self._resetCount == false then
		if app.unlock:checkLock("ARENA_RESET") == false then
			app.unlock:tipsLock("ARENA_RESET", "斗魂场CD重置")
			return
		else
			local CDToken = QStaticDatabase:sharedDatabase():getConfiguration().ARENA_CD_REMOVE.value
			if CDToken > remote.user.token then
				QQuickWay:addQuickWay(QQuickWay.TOKEN_DROP_WAY, nil)
			else
				remote.arena:arenaClearFrozenTimeRequest()
			end
		end
	else
		if self._refreshCount >= QVIPUtil:getArenaRefreshCount() then
			self:_showVipAlert(1)
			return
		else
			self:refreshArena(true)
		end
	end
end

function QUIDialogArena:onTriggerBackHandler(tag)
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
end

function QUIDialogArena:onTriggerHomeHandler(tag)
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
end

function QUIDialogArena:_showVipAlert( model )
	if model == 1 then
		-- 刷新
		app:vipAlert({title = "斗魂场可刷新次数", textType = VIPALERT_TYPE.NOT_ENOUGH, model = VIPALERT_MODEL.ARENA_REFRESH_COUNT}, false)
	elseif model == 3 then
		-- 挑战
		app:vipAlert({title = "斗魂场可购买挑战次数", textType = VIPALERT_TYPE.NOT_ENOUGH, model = VIPALERT_MODEL.ARENA_RESET_COUNT}, false)
	end
end

function QUIDialogArena:_onTriggerScorePanel()
	if self.rivalId ~= nil then return end
    app.sound:playSound("common_small")
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogArenaScore"})
end

return QUIDialogArena