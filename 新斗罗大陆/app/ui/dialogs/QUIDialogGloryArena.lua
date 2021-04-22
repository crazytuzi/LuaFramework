--
-- Author: wkwang
-- Date: 2015-01-14 20:06:17
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogGloryArena = class("QUIDialogGloryArena", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIWidgetHeroHead = import("..widgets.QUIWidgetHeroHead")
local QUIViewController = import("..QUIViewController")
local QUIWidgetGloryArena = import("..widgets.QUIWidgetGloryArena")
local QShop = import("...utils.QShop")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QTutorialDirector = import("...tutorial.QTutorialDirector")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QVIPUtil = import("...utils.QVIPUtil")
local QQuickWay = import("...utils.QQuickWay")
local QGloryArenaArrangement = import("...arrangement.QGloryArenaArrangement")


local QUIWidgetAvatar = import("..widgets.QUIWidgetAvatar")
local QUIGestureRecognizer = import("..QUIGestureRecognizer")
local QUIDialogUnionAnnouncement = import("..dialogs.QUIDialogUnionAnnouncement")
local QUIWidgetTopStatusShow = import("..widgets.QUIWidgetTopStatusShow")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QUIWidgetActorDisplay = import("..widgets.actorDisplay.QUIWidgetActorDisplay")
local QUIDialogBuyCount = import("..dialogs.QUIDialogBuyCount")

local QGloryDefenseArrangement = import("...arrangement.QGloryDefenseArrangement")


QUIDialogGloryArena.NO_FIGHT_HEROES = "还未设置战队，无法参加战斗！现在就设置战队？"

function QUIDialogGloryArena:ctor(options)
 	local ccbFile = "ccb/Dialog_GloryArena.ccbi"
    local callBacks = {
        {ccbCallbackName = "onTriggerIntroduce", callback = handler(self, self._onTriggerIntroduce)},
        {ccbCallbackName = "onTriggerRank", callback = handler(self, self._onTriggerRank)},
        {ccbCallbackName = "onTriggerShop", callback = handler(self, self._onTriggerShop)},
        {ccbCallbackName = "onTriggerRecord", callback = handler(self, self._onTriggerRecord)},
        {ccbCallbackName = "onTriggertHistoryGlory", callback = handler(self, self._onTriggertHistoryGlory)},
        {ccbCallbackName = "onTriggerRankAwards", callback = handler(self, self._onTriggerRankAwards)},
		{ccbCallbackName = "onTriggerScorePanel", callback = handler(self, self._onTriggerScorePanel)},
		{ccbCallbackName = "onTriggerAutoWorship", callback = handler(self, self._onTriggerAutoWorship)},
       
        {ccbCallbackName = "onTriggerTeam", callback = handler(self, self._onTriggerTeam)},
        {ccbCallbackName = "onTriggerRefresh", callback = handler(self, self._onTriggerRefresh)},
        {ccbCallbackName = "onPlus", callback = handler(self, self._onPlus)},
        {ccbCallbackName = "onTriggerLook", callback = handler(self, self._onTriggerLook)},
		{ccbCallbackName = "onTriggerClickPVP", callback = handler(self, self._onTriggerClickPVP)}
    }
    QUIDialogGloryArena.super.ctor(self, ccbFile, callBacks, options)
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    page:setAllUIVisible(false)
    page:setScalingVisible(false)
    page.topBar:showWithTower()

	self._schedulers = {}

 	-- CalculateBattleUIPosition(self._ccbOwner.node_map , true)
 	-- CalculateBattleUIPosition(self._ccbOwner.node_avatar , true)

	-- self:resetAll()
	-- self._ccbOwner.record_tips:setVisible(remote.arena:getTips(false))
	-- remote.arena:setTips(true, false)

	-- self._touchWidth = display.ui_width--self._ccbOwner.touch_layer:getContentSize().width --适配全面屏
	self._touchWidth = display.width
	self._pageWidth = self._touchWidth
	self._orginPosX = -self._pageWidth/2
	self._touchHeight = self._ccbOwner.touch_layer:getContentSize().height
	self._touchLayer = QUIGestureRecognizer.new()
	self._touchLayer:setSlideRate(0.3)
	self._touchLayer:setAttachSlide(true)
	self._touchLayer:attachToNode(self._ccbOwner.touch_node, self._touchWidth, self._touchHeight, self._ccbOwner.touch_layer:getPositionX(),
		self._ccbOwner.touch_layer:getPositionY(), handler(self, self.onTouchEvent))
  
	local config = QStaticDatabase:sharedDatabase():getConfiguration()
	self._totalCount = config.COMPETION_FREE_FIGHT_COUNT.value or 0
	self._buyCount = 1
	self._farRate = 0.6

    self._pvpNodePosX = self._ccbOwner.node_pvp:getPositionX()

	self._cdTime = QStaticDatabase:sharedDatabase():getConfiguration().COMPETION_CD.value
	self._refreshCount = remote.tower.gloryArenaRefreshTimes
	self:adjustIcon()

    -- self:checkSelfShopRedTips()
end

function QUIDialogGloryArena:adjustIcon( ... )
	-- body
	self._canJoin = remote.tower.canJoinGloryArena

	self:avatarTalkHandler()
	self:render()
	
	if not self._canJoin then
		self._ccbOwner.myRankInfo:setVisible(false)
		self._ccbOwner.cannotJoinNode:setVisible(true)
		self._ccbOwner.canJoinNode:setVisible(false)
	else
		self._ccbOwner.btn_convert:setVisible(true)
		self._ccbOwner.btn_wangzhe:setPositionX(-355.0)
		self._ccbOwner.btn_jifen:setPositionX(-455.0)
		self._ccbOwner.btn_autoWorship:setPositionX(-555.0)

		self._ccbOwner.cannotJoinNode:setVisible(false)
		self._ccbOwner.canJoinNode:setVisible(true)
		self._ccbOwner.tf_rank:setString(0)
		self._ccbOwner.tf_defens_force:setString(0)
		self._ccbOwner.tf_count:setString("")
		self._ccbOwner.node_time:setVisible(false)
		self:setFightCount()
    	self:setRank()
    	self:resetTimeHandler(true)
    	self:timeCount()
	end	
	self:setForceInfo()
end


function QUIDialogGloryArena:checkRedTips( ... )
	-- body
end


function QUIDialogGloryArena:viewDidAppear()
    QUIDialogGloryArena.super.viewDidAppear(self)
  	self:addBackEvent(false)
    self._touchLayer:enable()
    self._touchLayer:addEventListener(QUIGestureRecognizer.EVENT_SLIDE_GESTURE, handler(self, self.onTouchEvent))
	self.towerEventProxy = cc.EventProxy.new(remote.tower)
    self.towerEventProxy:addEventListener(remote.tower.GLORY_ARENA_REFRESH, handler(self, self._onRefresh))	
	self.towerEventProxy:addEventListener(remote.tower.EVENT_TOWER_STATE_STATUS_CHANGE, handler(self, self._onGloryOver))
	self.towerEventProxy:addEventListener(remote.tower.EVENT_TOWER_AUTOWORSHIP, handler(self, self._onAutoWorship))

	QNotificationCenter.sharedNotificationCenter():addEventListener(QNotificationCenter.EVENT_EXIT_FROM_BATTLE, self.exitFromBattleHandler, self)
end



function QUIDialogGloryArena:_onRefresh( event )
	-- body
	if not event then
		event = {}
	end
	self:render(event.isNotRefreshAvatar)
end


function QUIDialogGloryArena:_onGloryOver(  )
	-- body
	if not remote.tower:isTowerFightOpen() then
        if self:checkInBattle() == false then
            self:removeSelfDialog()
        end
        return
    end
end

function QUIDialogGloryArena:checkInBattle()
    if app.battle then
        return true
    end
    return false
end 

function QUIDialogGloryArena:removeSelfDialog() 
    self._removeScheduler = scheduler.performWithDelayGlobal(function()
            app.tip:floatTip("争霸赛已结束，正在结算奖励")
            self:popSelf()
        end, 0)
end


function QUIDialogGloryArena:updateRedTips( ... )
	-- body
	if remote.tower:checkGloryArenaScoreAwardRedtips() then
		self._ccbOwner.score_tips:setVisible(true)
	else
		self._ccbOwner.score_tips:setVisible(false)
	end
	
	if remote.tower:checkGloryArenaShopRedTips() then
		self._ccbOwner.shop_tips:setVisible(true)
	else
		self._ccbOwner.shop_tips:setVisible(false)
	end

	if remote.tower:checkAutoWorshipRedTips() then
		self._ccbOwner.autoWorship_tips:setVisible(true)
	else
		self._ccbOwner.autoWorship_tips:setVisible(false)
	end
end

function QUIDialogGloryArena:render(isNotRefreshAvatar)
	-- body
	if self.fighterResult then
		if self.fighterResult.gloryCompetitionResponse.mySelf.rank < self.fighterResult.gloryCompetitionResponse.mySelf.lastRank  then
			self:kickAnimationHandler()
			return
		end
	end
	self.worship = clone(remote.tower.gloryArenaWorshipFighter)
	self.rivals = clone(remote.tower.gloryArenaRivals)
	self.myInfo = clone(remote.tower.gloryArenaMyInfo)
	if not isNotRefreshAvatar then
		self:competitorHandler()
	end
	self._refreshCount = remote.tower.gloryArenaRefreshTimes
	self:timeCount()
	self:setFightCount()
	self:updateRedTips()
	self:setForceInfo()
	self:setRank()
	
	self.isManualRefresh = nil
end



function QUIDialogGloryArena:viewWillDisappear()
    QUIDialogGloryArena.super.viewWillDisappear(self)
	self:removeBackEvent()
  
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

	self.towerEventProxy:removeAllEventListeners()
    self.towerEventProxy = nil
end



function QUIDialogGloryArena:exitFromBattleHandler(evt)
	if evt.options.isReplay and not evt.options.isQuick then
		self:competitorHandler()

		if not remote.tower:isTowerFightOpen() then
	        if self:checkInBattle() == false then
	            self:removeSelfDialog()
	        end
	        return
    	end
    	
		return
	end

	local fighterResult, rivalId = remote.tower:getTopRankUpdate()
	if fighterResult and rivalId then
		self.fighterResult = fighterResult
		self.rivalId = rivalId	
		local isIn = false
		for index,value in pairs(self.rivals) do
			if value.userId == self.rivalId then
				self._rival = value
				isIn = true
			end
		end	
		if not isIn then
			self.fighterResult = nil
			self.rivalId = nil
		end 

		if self.fighterResult then
			if self.fighterResult.gloryCompetitionResponse.mySelf.rank >= self.fighterResult.gloryCompetitionResponse.mySelf.lastRank  then
				self.fighterResult = nil
				self.rivalId = nil
			end
		end
	end
	self:competitorHandler()

	self.isManualRefresh = true
	if not remote.tower:isTowerFightOpen() then
        if self:checkInBattle() == false then
            self:removeSelfDialog()
        end
        return
    end
	remote.tower:requestGloryArenaInfo()
end


function QUIDialogGloryArena:setForceInfo()
    local force = remote.teamManager:getBattleForceForAllTeam(remote.teamManager.GLORY_DEFEND_TEAM, false)
    local fontInfo = QStaticDatabase:sharedDatabase():getForceColorByForce(tonumber(force), true)
    local num, unit
    num,unit = q.convertLargerNumber(force)
    self._ccbOwner.tf_defens_force:setString(num..(unit or ""))
	local color = string.split(fontInfo.force_color, ";")
	self._ccbOwner.tf_defens_force:setColor(ccc3(color[1], color[2], color[3]))
	self._ccbOwner.sp_team_tips:setVisible(not remote.teamManager:checkTeamStormIsFull(remote.teamManager.GLORY_DEFEND_TEAM))

	self._ccbOwner.node_pvp:setVisible(ENABLE_PVP_FORCE)
	self._ccbOwner.node_pvp:setPositionX( self._pvpNodePosX + self._ccbOwner.tf_defens_force:getContentSize().width)
end


function QUIDialogGloryArena:setFightCount(  )
	-- body
	local count = (self._totalCount + self.myInfo.fightBuyCount * self._buyCount)-self.myInfo.fightCount

	self._ccbOwner.tf_count:setString(count)

    local totalVIPNum = QVIPUtil:getCountByWordField("competion_times_limit", QVIPUtil:getMaxLevel())
    local totalNum = QVIPUtil:getCountByWordField("competion_times_limit")
    local buyCount = self.myInfo.fightBuyCount or 0
    self._ccbOwner.node_btn_plus:setVisible(totalVIPNum > totalNum or totalNum > buyCount)
end

function QUIDialogGloryArena:setRank(  )
	-- body
	self._ccbOwner.tf_rank:setString(self.myInfo.rank)
end
--战队信息处理


--对手信息处理 --todo
function QUIDialogGloryArena:competitorHandler()
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
	self._CellWidth = 235
	if self.worship.fighter ~= nil then
		for index,value in ipairs(self.worship.fighter) do
			table.insert(self._virtualFrame, {index = index, value = value, isWorship = true, posX = self._index * self._CellWidth + self._CellWidth/2})
			self._totalWidth = self._totalWidth + self._CellWidth
			self._index = self._index + 1
		end
	end
	for index,value in ipairs(self.rivals) do
		table.insert(self._virtualFrame, {value = value, isWorship = false, posX = self._index * self._CellWidth + self._CellWidth/2, isManualRefresh = self.isManualRefresh, rivalId = self.rivalId})
		self._totalWidth = self._totalWidth + self._CellWidth
		self._index = self._index + 1
	end
	self:moveTo(-(self._totalWidth - self._pageWidth)+self._orginPosX, false, true)
	self:stopAvatarTalk()
	self._talkSchedulerHandler = scheduler.performWithDelayGlobal(handler(self, self.avatarTalkTime), 2)

end

function QUIDialogGloryArena:onTouchEvent(event)
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

function QUIDialogGloryArena:_removeAction()
	if self._actionHandler ~= nil then
		self._ccbOwner.node_team:stopAction(self._actionHandler)		
		self._actionHandler = nil
	end
	if self._actionFarHandler ~= nil then
		self._ccbOwner.node_team:stopAction(self._actionFarHandler)		
		self._actionFarHandler = nil
	end	
end

function QUIDialogGloryArena:moveTo(posX, isAnimation, isCheck, delayTime)
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

function QUIDialogGloryArena:_contentRunAction(posX,posY,delayTime)
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

function QUIDialogGloryArena:onEnterFrame()
	self:exitEnterFrame()
	self._onEnterFrameHandler = scheduler.scheduleGlobal(handler(self, self._renderFrame), 0)
end

function QUIDialogGloryArena:exitEnterFrame()
	if self._onEnterFrameHandler ~= nil then
		scheduler.unscheduleGlobal(self._onEnterFrameHandler)
	end
end

function QUIDialogGloryArena:_renderFrame(isForce)
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

function QUIDialogGloryArena:framRenderHandler(frame, isShow, isForce)
	if frame.isShow == isShow and isForce ~= true then
		return
	end
	frame.isShow = isShow
	if isShow == true then
		if frame.widget == nil then
			frame.widget = self:getEmptyFrame()
		end

		frame.widget:setPositionX(frame.posX)
		frame.widget:setInfo(frame.value, frame.isWorship, frame.index, remote.tower:gloryArenaTodayWorshipByPos(frame.index), frame.isManualRefresh, frame.rivalId, self.fighterResult, self._rival)
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

function QUIDialogGloryArena:getEmptyFrame()
	if #self._emptyBox > 0 then
		return table.remove(self._emptyBox)
	end
	local userCell = QUIWidgetGloryArena.new()
	-- userCell:setFightLable("扫荡")
	userCell:addEventListener(userCell.EVENT_WORSHIP, handler(self, self.worshipHandler))
	userCell:addEventListener(userCell.EVENT_BATTLE, handler(self, self.startBattleHandler))
	userCell:addEventListener(userCell.EVENT_QUICK_BATTLE, handler(self, self.quickBattleHandler))
	userCell:addEventListener(userCell.EVENT_VISIT, handler(self, self.clickCellHandler))
	userCell:addEventListener(userCell.EVENT_ANIMATION, handler(self, self.animationEndHandler))
	self._ccbOwner.node_avtar:addChild(userCell)
	return userCell
end


----------------------处理avatar气泡部分-------------------
function QUIDialogGloryArena:avatarTalkHandler()
	self._avatarWord = {}
	self:removeTalkHandler()
end

function QUIDialogGloryArena:removeTalkHandler()
	if self._talkSchedulerHandler ~= nil then 
		scheduler.unscheduleGlobal(self._talkSchedulerHandler)
	end
end

function QUIDialogGloryArena:avatarTalkTime()
	local totalCount = #self._avatarWord
	if totalCount <= 0 then return end
	local count = math.random(1, totalCount)
	self:startAvatarTalk(self._avatarWord[count].widget)
end

function QUIDialogGloryArena:startAvatarTalk(widget, word)
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

function QUIDialogGloryArena:stopAvatarTalk()
	self:removeTalkHandler()
	for index,value in ipairs(self._avatarWord) do
		if value.istalk == true then
			value.widget:removeWord()
			value.istalk = false
		end
	end
end

function QUIDialogGloryArena:addAvatarTalk(widget)
	table.insert(self._avatarWord, {widget = widget, istalk = false})
end

function QUIDialogGloryArena:removeAvatarTalk(widget)
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

function QUIDialogGloryArena:removeAllAvatarTalk()
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

function QUIDialogGloryArena:timeCount()
	self:removeTimeCount()
	local timeFun = function()
			local passTime = q.serverTime() - (self.myInfo.lastFrozenTime or 0)/1000
			if passTime <= self._cdTime and (not app.unlock:checkLock("UNLOCK_GLORY_TOWER_UNFREEZE")) then
				local needTime = self._cdTime - passTime 
				self._ccbOwner.node_time:setVisible(true)
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
function QUIDialogGloryArena:resetTimeHandler(b)
	-- if self._resetCount == b then return end
	self._resetCount = b
	-- makeNodeFromGrayToNormal(self._ccbOwner.node_refresh)
	if b == true then
		self._ccbOwner.tf_refresh:setString("换一批")
		if self._refreshCount >= QStaticDatabase:sharedDatabase():getConfiguration().COMPETION_FREE_REFRESH_TIME.value then
			self._ccbOwner.tf_token:setString(QStaticDatabase:sharedDatabase():getConfiguration().COMPETION_TIME_COST.value)
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

function QUIDialogGloryArena:removeTimeCount()
	if self._timeHandler ~= nil then
		scheduler.unscheduleGlobal(self._timeHandler)
	end
end

function QUIDialogGloryArena:startBattle(userId)
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
	local battleFunc = function()
		local teams = remote.teamManager:getActorIdsByKey(remote.teamManager.GLORY_DEFEND_TEAM)
		if teams == nil or #teams == 0 then
			local teamVO = remote.teamManager:getTeamByKey(remote.teamManager.INSTANCE_TEAM)
		    remote.teamManager:saveTeamToLocal(teamVO, remote.teamManager.GLORY_DEFEND_TEAM)
		end

		local arenaArrangement = QGloryArenaArrangement.new({rivalInfo = rivalInfo, rivalsPos = rivalsPos, myInfo = self.myInfo, info = self:getOptions()})
		app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogTeamArrangement",
			options = {arrangement = arenaArrangement}})
	end

	remote.tower:towerFightStartCheckRequest(self.myInfo.userId, self.myInfo.rank, rivalInfo.userId, rivalInfo.rank, function(data)
			if self:safeCheck() then
				if data.gfStartCheckResponse and data.gfStartCheckResponse.towerFightStartCheckResponse and (data.gfStartCheckResponse.towerFightStartCheckResponse.isRivalPosChanged or data.gfStartCheckResponse.towerFightStartCheckResponse.isSelfPosChanged) then
					app:alert({content = "排名发生了变化，确认刷新后重新开始挑战", callback = function (state)
						if state == ALERT_TYPE.CONFIRM then
							remote.tower:requestGloryArenaInfo()
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

function QUIDialogGloryArena:autoBattle(userId)
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

	local teams = remote.teamManager:getTeamByKey(remote.teamManager.GLORY_TEAM)
	local heroIdList = teams:getAllTeam()
	if heroIdList == nil or heroIdList[1] == nil or heroIdList[1].actorIds == nil then
		teams = remote.teamManager:getTeamByKey(remote.teamManager.INSTANCE_TEAM)
	    remote.teamManager:saveTeamToLocal(teams, remote.teamManager.GLORY_TEAM)
	    heroIdList = teams:getAllTeam()
	end
	
	local battleFunc = function()
		local arenaArrangement = QGloryArenaArrangement.new({rivalInfo = rivalInfo, rivalsPos = rivalsPos, myInfo = self.myInfo, info = self:getOptions()})
		app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogTeamArrangement",
			options = {arrangement = arenaArrangement}})
	end

	 --阵容合理性判断
    if heroIdList == nil or #heroIdList == 0 then
        app:alert({content = QUIDialogGloryArena.NO_FIGHT_HEROES, title = "系统提示", 
            callback = function(state)
                if state == ALERT_TYPE.CONFIRM then
                    if battleFunc then
                        battleFunc()
                    end
                end
            end})
        return 
    end


	local arenaArrangement = QGloryArenaArrangement.new({rivalInfo = rivalInfo, rivalsPos = rivalsPos, isNeedCallback = true, myInfo = self.myInfo, info = self:getOptions()})
	local oldGloryMoney = remote.user.towerMoney
	local oldScore = self.myInfo.arenaRewardIntegral
	local success = function(data)
		remote.tower:setTopRankUpdate(data, userId)
	
		if self:safeCheck() then
			self.rivalId = nil
			local batchAwards = {}
			local awards = {}

			table.insert(awards,{id = nil, typeName = ITEM_TYPE.TOWER_MONEY, count = (remote.user.towerMoney - oldGloryMoney)})
			--节日掉落
			if data.extraExpItem and type(data.extraExpItem) == "table" then
                for _, value in pairs(data.extraExpItem or {}) do
                    table.insert(awards, {id = value.id or 0, typeName = value.type, count = value.count or 0})
                end
            end
			-- table.insert(batchAwards, {awards = awards})
			local activityYield = remote.activity:getActivityMultipleYield(611)
			if data.isTowerFightWin or data.gfEndResponse.isWin then
				app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogWin", 
                    options = {awards = awards, yield = data.gloryCompetitionFightEndResponse.yield or 1, activityYield = activityYield, userComeBackRatio = data.userComeBackRatio or 1, callback = function()
                        self:disableTouchSwallowTop()
			    		if self:safeCheck() then
			    			self.isManualRefresh = true
							remote.tower:requestGloryArenaInfo()
						end
                    end}}, {isPopCurrentDialog = true})
			else
				app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogLose", 
					options = {awards = awards, yield = data.gloryCompetitionFightEndResponse.yield or 1, activityYield = activityYield, userComeBackRatio = data.userComeBackRatio or 1,callback = function()
		                self:disableTouchSwallowTop()
			    		if self:safeCheck() then
			    			self.isManualRefresh = true
							remote.tower:requestGloryArenaInfo()
						end
		            end}}, {isPopCurrentDialog = true})
			end
		end
	end
	local failed = function( ... )
		self.rivalId = nil
		self:disableTouchSwallowTop()
	end

	local soulMaxNum = teams:getSpiritsMaxCountByIndex(1)
    if soulMaxNum > 0 and heroIdList[1].spiritIds ~= nil and #heroIdList[1].spiritIds < soulMaxNum then
        app:alert({content="有主力魂灵未上阵，确定开始战斗吗？",title="系统提示", callback = function (state)
            if state == ALERT_TYPE.CONFIRM then
                remote.tower:towerFightStartCheckRequest(self.myInfo.userId, self.myInfo.rank, rivalInfo.userId, rivalInfo.rank, function(data)
					if self:safeCheck() then
						if data.gfStartCheckResponse and data.gfStartCheckResponse.towerFightStartCheckResponse and (data.gfStartCheckResponse.towerFightStartCheckResponse.isRivalPosChanged or data.gfStartCheckResponse.towerFightStartCheckResponse.isSelfPosChanged) then
							app:alert({content = "排名发生了变化，确认刷新后重新开始挑战", callback = function (state)
								if state == ALERT_TYPE.CONFIRM then
									remote.tower:requestGloryArenaInfo()
								end
							end})
						else
							arenaArrangement:startAutoFight(heroIdList,success,failed)
						end
					end
				end, function()
					arenaArrangement:startAutoFight(heroIdList,success,failed)
				end)
            end
        end})
    else
    	remote.tower:towerFightStartCheckRequest(self.myInfo.userId, self.myInfo.rank, rivalInfo.userId, rivalInfo.rank, function(data)
			if self:safeCheck() then
				if data.gfStartCheckResponse and data.gfStartCheckResponse.towerFightStartCheckResponse and (data.gfStartCheckResponse.towerFightStartCheckResponse.isRivalPosChanged or data.gfStartCheckResponse.towerFightStartCheckResponse.isSelfPosChanged) then
					app:alert({content = "排名发生了变化，确认刷新后重新开始挑战", callback = function (state)
						if state == ALERT_TYPE.CONFIRM then
							remote.tower:requestGloryArenaInfo()
						end
					end})
				else
					arenaArrangement:startAutoFight(heroIdList,success,failed)
				end
			end
		end, function()
			arenaArrangement:startAutoFight(heroIdList,success,failed)
		end)
    end
end

function QUIDialogGloryArena:quickBattle(userId)
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
	local oldGloryMoney = remote.user.towerMoney
	local oldScore = self.myInfo.arenaRewardIntegral
	self:enableTouchSwallowTop()
	remote.tower:requestGloryArenaQuickFight(userId, rivalsPos, function (data)

        remote.user:addPropNumForKey("todayTowerFightCount")
        remote.user:addPropNumForKey("c_towerFightCount")
		remote.tower:setTopRankUpdate(data, userId)
		remote.activity:updateLocalDataByType(552, 1)
		-- if data.gfEndResponse and data.gfEndResponse.isWin then
  --       end
		if self:safeCheck() then
			self.rivalId = nil
			local batchAwards = {}
			local awards = {}

			table.insert(awards, {type = ITEM_TYPE.TOWER_MONEY ,count = (remote.user.towerMoney - oldGloryMoney)})
			--节日掉落
			if type(data.extraExpItem) == "table" then
				for k, v in pairs(data.extraExpItem)do
					table.insert(awards, v)
				end
			end
			table.insert(batchAwards, {awards = awards})
			local activityYield = remote.activity:getActivityMultipleYield(611)
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogUnityFastBattle", 
				options = {fast_type = FAST_FIGHT_TYPE.RANK_FAST,awards = batchAwards, yield = data.gloryCompetitionFightEndResponse.yield or 1, activityYield = activityYield, userComeBackRatio = data.userComeBackRatio or 1, score = data.gloryCompetitionResponse.mySelf.arenaRewardIntegral - oldScore, name = "争霸赛扫荡", callback = function ()
					self:disableTouchSwallowTop()
		    		if self:safeCheck() then
		    			self.isManualRefresh = true
						remote.tower:requestGloryArenaInfo()
					end
				end}},{isPopCurrentDialog = false})
		end
	end,function ()
		self.rivalId = nil
		self:disableTouchSwallowTop()
	end)
end

function QUIDialogGloryArena:_teamIsNil()
  	app:alert({content="还未设置战队，无法参加战斗！现在就设置战队？",title="系统提示",callback= function(state)
  		if state == ALERT_TYPE.CONFIRM then
			self:_onTriggerTeam()
		end
  	end})
end

function QUIDialogGloryArena:_onTriggerIntroduce(event)
	if self.rivalId ~= nil then return end
    app.sound:playSound("common_small")
  	app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogGloryArenaHelp"})
end

function QUIDialogGloryArena:clickCellHandler(event)
	if self.rivalId ~= nil then return end
	if self._isMove then return end
    app.sound:playSound("common_small")

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
	local isLong = true
	if event.info.userId == remote.user.userId or not self._canJoin then
		isLong = false
	end
  
	app:getClient():topGloryArenaRankUserRequest(event.info.userId, function(data)
			local fighter = (data.towerFightersDetail or {})[1] or {}
	  		if isLong then
		  		local count = remote.tower:getGloryArenaMoneyByRivals(rivalsPos, fighter.rank)
		  		local typeName = "towerMoney"
		  		local award = { { typeName = typeName, count = count } }
				app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogPlayerInfo",
	                options = {fighter = fighter, specialTitle1 = "胜利场数：", specialValue1 = fighter.victory, awardTitle2 = "胜利奖励：", awardValue2 = award, forceTitle = "防守战力：", isPVP = true}}, {isPopCurrentDialog = false})
			else
				app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogPlayerInfo",
	                options = {fighter = fighter, specialTitle1 = "胜利场数：", specialValue1 = fighter.victory, forceTitle = "防守战力：", isPVP = true}}, {isPopCurrentDialog = false})
			end
		end)

end

--[[
	播放死亡动画结束
]]
function QUIDialogGloryArena:animationEndHandler(event)
	
	if self._rivalAvatar ~= nil then 
		self._rivalAvatar:stopAllActions()
		self._rivalAvatar:removeFromParent()
		self._rivalAvatar = nil
	end
	if self._selfAvatar ~= nil then 
		self._selfAvatar:stopAllActions()
		self._selfAvatar:removeFromParent()
		self._selfAvatar = nil
	end
	self.rivalId = nil
	self.fighterResult = nil
	self.isManualRefresh = true
	self:render()
	self.isManualRefresh = nil 
end

--播放踢人的动画
function QUIDialogGloryArena:kickAnimationHandler()
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

	if selfFrame.value.defaultActorId and selfFrame.value.defaultActorId ~= 0 then 
		selfActorId = selfFrame.value.defaultActorId
	end

	if not selfActorId then
		local selfActorInfo = remote.herosUtil:getMaxForceByHeros(selfFrame.value)
		if not selfActorInfo then
			self:animationEndHandler()
			return
		else
			rivalActorId = selfActorInfo.actorId
		end
	end
	
	self._rivalAvatar = QUIWidgetActorDisplay.new(rivalActorId, {heroInfo = {skinId = rivalFrame.value.defaultSkinId}})
	self._rivalAvatar:setScaleX(-1.3)
	self._rivalAvatar:setScaleY(1.3)
	local rivalPos = ccp(rivalFrame.posX+9, -82)
	self._rivalAvatar:setPositionX(rivalPos.x)
	self._rivalAvatar:setPositionY(rivalPos.y)
	self._ccbOwner.node_avtar:addChild(self._rivalAvatar, -1)
	self._selfAvatar = QUIWidgetActorDisplay.new(selfActorId, {isSelf = true, heroInfo = {skinId = selfFrame.value.defaultSkinId}})
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
    			rivalFrame.widget:changeBaseInfo(selfFrame.value)
    			rivalFrame.widget:hideBaseInfo(true, function ()
    				if self._selfAvatar then
    					self._selfAvatar:displayWithBehavior(ANIMATION_EFFECT.VICTORY)
    				end
    			end)
    		end)
    	end
    	if selfFrame.widget ~= nil then
    		selfFrame.widget:hideBaseInfo(false)
    	end
    	end))
    arr:addObject(CCDelayTime:create(3))
    arr:addObject(CCCallFunc:create(function()
	  --   local aniamtionPlayer = QUIWidgetAnimationPlayer.new()
	  --   aniamtionPlayer:playAnimation("ccb/effects/zhandoushengli.ccbi", nil, function ()
			-- self:animationEndHandler()
	  --   end)
	  --   self:getView():addChild(aniamtionPlayer)
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


-- 获取一键膜拜列表
function QUIDialogGloryArena:_getAutoWorshipList()
	local worshipList = {}

	for index,value in ipairs(self.worship.fighter) do
		if remote.tower:gloryArenaTodayWorshipByPos(index) ~= true then
			local item = {}
			item.index = index
			item.value = value
			if self._virtualFrame[index] and self._virtualFrame[index].widget then
				item.widget = self._virtualFrame[index].widget
			end
			table.insert(worshipList, item)
		end
	end
	return worshipList
end

function QUIDialogGloryArena:_onTriggerAutoWorship()
	if self.rivalId ~= nil then return end
	app.sound:playSound("common_small")

	if remote.tower:checkAutoWorshipRedTips() then
		remote.tower:autoWorship()
	else
		app.tip:floatTip("魂师大人，您目前没有可以膜拜的玩家哦~")
	end
end

-- 展示一键膜拜的结果弹窗
function QUIDialogGloryArena:_showAutoWorshipResult(worshipTotalCount, worshipBJCount, worshipXYBJCount, addMoney)
	if self._worshipAnimationPlayer ~= nil then
		self._worshipAnimationPlayer:disappear()
		self:getView():removeChild(self._worshipAnimationPlayer)
		self._worshipAnimationPlayer = nil
	end

	self._worshipAnimationPlayer = QUIWidgetAnimationPlayer.new()
	self._worshipAnimationPlayer:playAnimation("ccb/effects/Auto_mobai.ccbi", function (ccbOwner)
		if worshipBJCount > 0 or worshipXYBJCount > 0 then
			ccbOwner.node_baoji:setVisible(true)
		else
			ccbOwner.node_baoji:setVisible(false)
		end

		local infoStr = string.format("膜拜成功%d次", worshipTotalCount)
		if worshipBJCount > 0 and worshipXYBJCount == 0 then
			infoStr = infoStr .. string.format(" （暴击%d次）", worshipBJCount)
		elseif worshipXYBJCount > 0 and worshipBJCount == 0 then
			infoStr = infoStr .. string.format(" （幸运暴击%d次）", worshipXYBJCount)
		elseif worshipBJCount > 0 and worshipXYBJCount > 0 then
			infoStr = infoStr .. string.format(" （暴击%d次，幸运暴击%d次）", worshipBJCount, worshipXYBJCount)
		end

		ccbOwner.tf_info:setString(infoStr)
		ccbOwner.tf_count:setString(string.format("大魂师币+%d", addMoney))
	end)

	self:getView():addChild(self._worshipAnimationPlayer)
end

-- 一键膜拜
function QUIDialogGloryArena:_onAutoWorship(event)
	local targetList = event.targetList or {}
	local worshipTotalCount = #targetList							-- 总次数
	local worshipBJCount = event.worshipBJCount or 0				-- 暴击次数
	local worshipXYBJCount = event.worshipXYBJCount or 0			-- 幸运暴击次数
	local addMoney = event.addMoney or 0

	local frame = nil
	for _, value in ipairs(targetList) do
		frame = self._virtualFrame[value.pos + 1]
		if frame.isWorship and frame.widget then
			frame.widget:showFans()
		end
	end

	self:_showAutoWorshipResult(worshipTotalCount, worshipBJCount, worshipXYBJCount, addMoney)
	self._ccbOwner.autoWorship_tips:setVisible(false)
end

function QUIDialogGloryArena:worshipHandler(event)
	if self._isMove then return end
    app.sound:playSound("common_small")
	if remote.tower:gloryArenaTodayWorshipByPos(event.index) == true then
        app.tip:floatTip("今日已经膜拜过了") 
    else
    	local widget = event.widget
    	local oldTowerMoney = remote.user.towerMoney
		remote.tower:requestGloryArenaWorship(event.info.userId, event.index-1, function (data)
			local money = data.wallet.towerMoney - oldTowerMoney
			-- remote.user:update({money = data.gloryCompetitionWorshipResponse.money})
			if self:safeCheck() then
				remote.tower:setGloryArenaTodayWorshipInfo(data.gloryCompetitionWorshipResponse.todayWorshipPos)
				widget:showFans()
				if self._worshipAnimationPlayer ~= nil then
					self._worshipAnimationPlayer:disappear()
					self:getView():removeChild(self._worshipAnimationPlayer)
					self._worshipAnimationPlayer = nil
				end
				self._worshipAnimationPlayer = QUIWidgetAnimationPlayer.new()
				if data.gloryCompetitionWorshipResponse.yield > 1 then
					self._worshipAnimationPlayer:playAnimation("ccb/effects/Baoji_mobai.ccbi", function (ccbOwner)
						ccbOwner.tf_money:setString(money)
						ccbOwner.tf_2:setString(" 大魂师币")
						ccbOwner.tf_2:setPositionX(ccbOwner.tf_money:getPositionX() + ccbOwner.tf_money:getContentSize().width/2 + 10)
						-- ccbOwner.tf_2:setString(" x"..data.gloryCompetitionWorshipResponse.yield.." 金魂币")
						if data.gloryCompetitionWorshipResponse.yield > 2 then
							ccbOwner.sp_title1:setVisible(false)
						else
							ccbOwner.sp_title2:setVisible(false)
						end
					end)
				else
					self._worshipAnimationPlayer:playAnimation("ccb/effects/team_arena.ccbi", function (ccbOwner)
						ccbOwner.tf_2:setString("大魂师币")
						ccbOwner.tf_money:setString(money)
					end)
				end
				self:getView():addChild(self._worshipAnimationPlayer)
			end
		end)
	end
end

function QUIDialogGloryArena:startBattleHandler(event)
	if self.rivalId ~= nil then return end
	if self._isMove then return  end
    app.sound:playSound("common_small")
	self:checkCanBattle(event, handler(self, self.startBattle))
end

function QUIDialogGloryArena:quickBattleHandler(event)
	if self.rivalId ~= nil then return end
	if self._isMove then return  end
    app.sound:playSound("common_confirm")
	if app.unlock:checkLock("UNLOCK_ARENA_QUICK_FIGHT") == false then
		app.unlock:tipsLock("UNLOCK_ARENA_QUICK_FIGHT", "斗魂场扫荡", true)
		return
	end
	local fighterResult, rivalId = remote.tower:getTopRankUpdate()
	local topRank = remote.tower.gloryArenaMyInfo.rank
	if topRank > event.info.rank then
		self:checkCanBattle(event, handler(self, self.autoBattle))
	else
		self:checkCanBattle(event, handler(self, self.quickBattle))
	end
	
end

function QUIDialogGloryArena:checkCanBattle(event, startHandler)
	if not self._canJoin then
		app.tip:floatTip("本次未获取参赛资格！")
		return
	end

	if event.info.userId == remote.user.userId then
		app.tip:floatTip("不能挑战自己！")
		return
	end
	if event.isWorship == true and self.myInfo.rank > 20 then
		app.tip:floatTip("太不自量力了，先冲到前20名再来挑战我吧！")
        -- self:startAvatarTalk(event.widget, "太不自量力了，先冲到前20名再来挑战我吧！")
        return 
	end

	if ((self._totalCount + self.myInfo.fightBuyCount * self._buyCount) - self.myInfo.fightCount) <= 0 then
    	self:_onTriggerBuyCount()
		return 
	end

	local actorIds = remote.teamManager:getActorIdsByKey(remote.teamManager.GLORY_DEFEND_TEAM)
  	if q.isEmpty(actorIds) then
    	self:_teamIsNil()
    	return 
  	end

	local passTime = q.serverTime() - (self.myInfo.lastFrozenTime or 0)/1000
	local config = QStaticDatabase:sharedDatabase():getConfiguration()
	if passTime <= self._cdTime and self.myInfo.fightCount > 0 and (not app.unlock:checkLock("UNLOCK_GLORY_TOWER_UNFREEZE")) then
  		if app.unlock:checkLock("ARENA_RESET") == false then
			app.unlock:tipsLock("ARENA_RESET", "争霸赛CD重置")
			return
		else
  			local CDToken = config.COMPETION_CD_REMOVE.value
			app:alert({content=string.format("挑战时间在冷却中，消除冷却时间需花费%d钻石\n是否消除CD直接挑战对方？", CDToken),title="系统提示",callback=function(state)
					if state == ALERT_TYPE.CONFIRM then
						if CDToken > remote.user.token then
							QQuickWay:addQuickWay(QQuickWay.TOKEN_DROP_WAY, nil)
						else
							remote.tower:requestGloryArenaCleanFightCD(function (data)
								if self:safeCheck() then
									remote.tower:gloryArenaRefresh(data)
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

function QUIDialogGloryArena:_onTriggerRecord(event)
	if self.rivalId ~= nil then return end
    app.sound:playSound("common_small")
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogAgainstRecord", options = {reportType = REPORT_TYPE.GLORY_ARENA}}, 
		{isPopCurrentDialog = false})
end

function QUIDialogGloryArena:_onTriggerRank(event)
	if self.rivalId ~= nil then return end
    app.sound:playSound("common_small")
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogRank", 
		options = {initRank = "gloryArena"}}, 
		{isPopCurrentDialog = false})
end

function QUIDialogGloryArena:_onTriggerShop(event)
	if self.rivalId ~= nil then return end
    app.sound:playSound("common_small")
    remote.stores:openShopDialog(SHOP_ID.gloryTowerShop)
end

--
function QUIDialogGloryArena:_onTriggerTeam(event)
	if q.buttonEventShadow(event,self._ccbOwner.btn_team) == false then return end
	if self.rivalId ~= nil then return end
	if event ~= nil then
    	app.sound:playSound("common_small")
    end
    
	local arenaArrangement = QGloryDefenseArrangement.new({selectSkillHero = self.myInfo.activeSubActorId, selectSkillHero2 = self.myInfo.activeSub2ActorId, teamKey = remote.teamManager.GLORY_DEFEND_TEAM})
	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogTeamArrangement",
		options = {arrangement = arenaArrangement, isBattle = true}})

end

function QUIDialogGloryArena:_onPlus(event)
	if q.buttonEventShadow(event,self._ccbOwner.btn_plus) == false then return end
	app.sound:playSound("common_small")
	self:_onTriggerBuyCount()
end

function QUIDialogGloryArena:_onTriggerBuyCount(event)
	if self.rivalId ~= nil then return end
	if event ~= nil then
    	app.sound:playSound("common_small")
    end
	if self.myInfo.fightBuyCount >= QVIPUtil:getGloryArenaResetCount() then
		self:_showVipAlert(3)
	else
		-- app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogBuyCount",
		-- 	options = {typeName = QUIDialogBuyCount["BUY_TYPE_10"], buyCount = self.myInfo.fightBuyCount, buyCallback = function () 
		-- 		-- remote.activity:updateLocalDataByType(505,1)
				
		-- 	end}})
	    app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogBuyCountBase",
	        options = {cls = "QBuyCountGloryArena"}})
	end
end

function QUIDialogGloryArena:_onTriggerRefresh(event)
	if q.buttonEventShadow(event,self._ccbOwner.btn_refresh) == false then return end
	if self.rivalId ~= nil then return end
    app.sound:playSound("common_small")
	if self._resetCount == false then
		if app.unlock:checkLock("ARENA_RESET") == false then
			app.unlock:tipsLock("ARENA_RESET", "争霸赛CD重置")
			return
		else
			local CDToken = QStaticDatabase:sharedDatabase():getConfiguration().COMPETION_CD_REMOVE.value
			if CDToken > remote.user.token then
				QQuickWay:addQuickWay(QQuickWay.TOKEN_DROP_WAY, nil)
			else
				remote.tower:requestGloryArenaCleanFightCD(function (data)
					if self:safeCheck() then
						 remote.tower:gloryArenaRefresh(data)
					end
				end)
			end
		end
	else
		if self._refreshCount >= QVIPUtil:getGloryArenaRefreshCount() then
			self:_showVipAlert(1)
			return
		else
			-- self:refreshArena(true)
			self.isManualRefresh = true
			remote.tower:requestGloryArenaInfo(true)
		end
	end
end

function QUIDialogGloryArena:onTriggerBackHandler(tag)
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
end

function QUIDialogGloryArena:onTriggerHomeHandler(tag)
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
end

function QUIDialogGloryArena:_showVipAlert( model )
	if model == 1 then
		-- 刷新
		app:vipAlert({title = "刷新次数", textType = VIPALERT_TYPE.NOT_ENOUGH, model = VIPALERT_MODEL.GLORY_ARENA_REFRESH_COUNT}, false)
	elseif model == 3 then
		-- 挑战
		app:vipAlert({title = "挑战次数", textType = VIPALERT_TYPE.NOT_ENOUGH, model = VIPALERT_MODEL.GLORY_ARENA_RESET_COUNT}, false)
	end
end

function QUIDialogGloryArena:_onTriggerScorePanel()
	if self.rivalId ~= nil then return end
    app.sound:playSound("common_small")
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogGloryArenaScore"})
end

function QUIDialogGloryArena:_onTriggerLook(event)
	if q.buttonEventShadow(event,self._ccbOwner.btn_mine_info) == false then return end
	return self:_onTriggerIntroduce()
end


function QUIDialogGloryArena:_onTriggerRankAwards(  )
	-- body
	app:getClient():top50RankRequest("GLORY_COMPETITION_REALTIME_TOP_50", remote.user.userId, function ( data )
		-- body
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogGloryArenaRank", options={quanfuServerData = data}})

	end)
end


function QUIDialogGloryArena:_onTriggertHistoryGlory(  )
	-- body
	if self.rivalId ~= nil then return end
	-- app.sound:playSound("common_small")
  
    remote.tower:requestTowerGloryWallInfo(function(data)
        if self:safeCheck() then
        	
            app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogGloryTowerHistoryGlory", options = {historyType = 2, data = data.towerGetGloryWallInfoResponse.towerloryWallInfos}})
        end
    end)
end

function QUIDialogGloryArena:_onTriggerClickPVP(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_pvp) == false then return end
    app.sound:playSound("common_small")

    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogPVPPropTip", 
        options = {teamKey = remote.teamManager.GLORY_DEFEND_TEAM}}, {isPopCurrentDialog = false})
end

return QUIDialogGloryArena