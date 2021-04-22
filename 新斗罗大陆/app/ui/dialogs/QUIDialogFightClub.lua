--
-- zxs
-- 搏击俱乐部主场景
--
local QUIDialog = import(".QUIDialog")
local QUIDialogFightClub = class("QUIDialogFightClub", QUIDialog)

local QUIGestureRecognizer = import("..QUIGestureRecognizer")
local QNavigationController = import("...controllers.QNavigationController")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QUIViewController = import("..QUIViewController")
local QFightClubArrangement = import("...arrangement.QFightClubArrangement")
local QFightClubDefenseArrangement = import("...arrangement.QFightClubDefenseArrangement")
local QUIWidgetFightClub = import("..widgets.QUIWidgetFightClub")
local QUIDialogFightClubMatchOpponent = import(".QUIDialogFightClubMatchOpponent")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetFloorIcon = import("..widgets.QUIWidgetFloorIcon")
local QUIWidgetFightClubRise = import("..widgets.QUIWidgetFightClubRise")
local QQuickWay = import("...utils.QQuickWay")
local QColorLabel = import("...utils.QColorLabel")
local QReplayUtil = import("...utils.QReplayUtil")

function QUIDialogFightClub:ctor(options)
	local ccbFile = "ccb/Dialog_fight_club.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerRule", callback = handler(self, self._onTriggerRule)},
		{ccbCallbackName = "onTriggerRecord", callback = handler(self, self._onTriggerRecord)},
		{ccbCallbackName = "onTriggerRank", callback = handler(self, self._onTriggerRank)},
		{ccbCallbackName = "onTriggerRise", callback = handler(self, self._onTriggerRise)},
		{ccbCallbackName = "onTriggerQuick", callback = handler(self, self._onTriggerQuick)},
		{ccbCallbackName = "onTriggerTeam", callback = handler(self, self._onTriggerTeam)},
		{ccbCallbackName = "onTriggerShop", callback = handler(self, self._onTriggerShop)},
		{ccbCallbackName = "onTriggerRefresh", callback = handler(self, self._onTriggerRefresh)},
		{ccbCallbackName = "onTriggerChest", callback = handler(self, self._onTriggerChest)},
		{ccbCallbackName = "onTriggerFast", callback = handler(self, self._onTriggerFast)},
		{ccbCallbackName = "onTriggerClickOneKeyFightAll", callback = handler(self, self._onTriggerClickOneKeyFightAll)},
        {ccbCallbackName = "onTriggerClickPVP", callback = handler(self, self._onTriggerClickPVP)},   
	}
	QUIDialogFightClub.super.ctor(self, ccbFile, callBacks, options)

	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	page:setAllUIVisible(false)
    page:setScalingVisible(false)
    page.topBar:showWithFightClub()
 	CalculateBattleUIPosition(self._ccbOwner.node_map , true)
 	CalculateBattleUIPosition(self._ccbOwner.node_avatar , true)
    self._ccbOwner.touch_layer:setContentSize(CCSize(display.width, display.height))
    self._touchWidth = display.width
    
	self._touchHeight = self._ccbOwner.touch_layer:getContentSize().height
    self._touchLayer = QUIGestureRecognizer.new()
	self._touchLayer:setSlideRate(0.3)
	self._touchLayer:setAttachSlide(true)
	self._touchLayer:attachToNode(self._ccbOwner.touch_node, self._touchWidth, self._touchHeight, self._ccbOwner.touch_layer:getPositionX(),
	self._ccbOwner.touch_layer:getPositionY(), handler(self, self.onTouchEvent))
  
  	self._nodeFarPosx = self._ccbOwner.node_far:getPositionX()
  	self._nodeTeamPosx = self._ccbOwner.node_team:getPositionX()
	self._pageWidth = self._touchWidth
	self._totalWidth = 0
	self._orginPosX = 0
	self._farRate = 0.6
	self._riseCount = db:getConfiguration()["FIGHT_CLUB_NUM"].value or 9

    self._pvpNodePosX = self._ccbOwner.node_pvp:getPositionX()

    self._isEnd = false
    self._defaultPos = nil
	self._schedulers = {}
	self._emptyBox = {}
    self._avatarWord = {}
	self:removeTalkHandler()

	self:resetAll()
    self:render()
	self:startCountdownSchedule()
    self:checkAward()
    self:checkQuickFight()
	self:checkDefenseUpdate()

	-- self:checkRankChangeInfo()
	self:checkWineglassLess(handler(self,self.checkRankChangeInfo))
end

function QUIDialogFightClub:viewDidAppear()
    QUIDialogFightClub.super.viewDidAppear(self)
	QNotificationCenter.sharedNotificationCenter():addEventListener(QNotificationCenter.EVENT_EXIT_FROM_BATTLE, self.exitFromBattleHandler, self)
    self:addBackEvent(false)

    self._touchLayer:enable()
    self._touchLayer:addEventListener(QUIGestureRecognizer.EVENT_SLIDE_GESTURE, handler(self, self.onTouchEvent))

    self.fightClubEventProxy = cc.EventProxy.new(remote.fightClub)
    self.fightClubEventProxy:addEventListener(remote.fightClub.FIGHT_CLUB_REFRESH, handler(self, self._onRefresh))	
    self.fightClubEventProxy:addEventListener(remote.fightClub.FIGHT_CLUB_RESET, handler(self, self._onReset))	
   	self.fightClubEventProxy:addEventListener(remote.fightClub.FIGHT_CLUB_AWARD_UPDATE, handler(self, self.checkAward))
end

function QUIDialogFightClub:viewWillDisappear()
    QUIDialogFightClub.super.viewWillDisappear(self)
	QNotificationCenter.sharedNotificationCenter():removeEventListener(QNotificationCenter.EVENT_EXIT_FROM_BATTLE, self.exitFromBattleHandler, self)
	self:removeBackEvent()

	self._touchLayer:removeAllEventListeners()
	self._touchLayer:disable()
	self._touchLayer:detach()

	self.fightClubEventProxy:removeAllEventListeners()

	if self._countdownSchedule then
		self:getScheduler().unscheduleGlobal(self._countdownSchedule)
		self._countdownSchedule = nil
	end
	if self._closeSchedule then
		self:getScheduler().unscheduleGlobal(self._closeSchedule)
		self._closeSchedule = nil
	end

	self:removeTimeScheduler()

	remote.fightClub:setShowPlunderTips(false)
end

function QUIDialogFightClub:chcekSeasonFight()
	-- 赛季结算
	if not remote.fightClub:checkCanFight() then
		if self._closeSchedule then
			self:getScheduler().unscheduleGlobal(self._closeSchedule)
			self._closeSchedule = nil
		end
		self._closeSchedule = self:getScheduler().scheduleGlobal(function ()
				local errorCode = db:getErrorCode("FIGHT_CLUB_CLOSED")
        		app.tip:floatTip(errorCode.desc)
				self:onTriggerHomeHandler()
			end, 0)

		return false
	end

	return true
end

function QUIDialogFightClub:resetAll()
	self._totalWidth = 0
	self._ccbOwner.tf_left_time:setString(0)
	self._ccbOwner.tf_cur_rank:setString(0)
	self._ccbOwner.tf_all_rank:setString(0)
	self._ccbOwner.tf_ranking:setString(0)
	self._ccbOwner.tf_defens_force:setString(0)

	self._ccbOwner.sp_rise_tips:setVisible(false)
	self._ccbOwner.sp_quick_tips:setVisible(false)
	self._ccbOwner.sp_team_tips:setVisible(false)
	self._ccbOwner.sp_record_tips:setVisible(false)
	self._ccbOwner.sp_shop_tips:setVisible(false)
	self._ccbOwner.node_icon:removeAllChildren()
	self._ccbOwner.node_rise_tips:setVisible(false)

	for i = 1, 4 do
		self._ccbOwner["icon_"..i]:removeAllChildren()
		self._ccbOwner["num_"..i]:setString("")
	end
end

--检查是否有奖励
function QUIDialogFightClub:checkSeasonAward()
	local seasonReward = remote.fightClub:getSeasonReward()
	if seasonReward or not self.rivals or not next(self.rivals) then
		local seasonWidget = QUIWidgetFightClubRise.new(seasonReward)
		seasonWidget:setScale(0.95)
		self._ccbOwner.touch_node:addChild(seasonWidget)
		seasonWidget:setPositionX(display.width * 0.5)
		self._ccbOwner.btn_team:setEnabled(false)
		self._ccbOwner.btn_rule:setEnabled(false)
		self._ccbOwner.btn_rank:setEnabled(false)
		self._ccbOwner.btn_record:setEnabled(false)
		self._ccbOwner.btn_shop:setEnabled(false)
		self._ccbOwner.btn_rise:setEnabled(false)
		self._ccbOwner.btn_quick:setEnabled(false)
		self._ccbOwner.btn_refresh:setEnabled(false)

		self._touchLayer:removeAllEventListeners()
		self._touchLayer:disable()
		self._touchLayer:detach()

		self._isEnd = true
		return true
	end

	return false
end

--检查是否有奖励
function QUIDialogFightClub:checkAward()
	local awardInfo = remote.fightClub:getAwardInfo()
	if awardInfo then
        app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogFightClubRise", options = {info = awardInfo}})
	else
		self:checkSeasonAward()
	end
end

--检查是否有未打完的快速挑战对手
function QUIDialogFightClub:checkQuickFight() 
	-- if true then 
	-- 	return 
	-- end 

	local quickFightInfo = remote.fightClub:getFightClubQuickFightInfo()
	if quickFightInfo and quickFightInfo.userId == remote.user.userId then
		local fightType = remote.fightClub.QUICK_FIGHT
		if quickFightInfo.floor < 6 then
			fightType = remote.fightClub.FAST_FIGHT
		end
		if quickFightInfo.fighter and #quickFightInfo.fighter > 0 then
			remote.fightClub:updateMainLastInfo()
    		remote.fightClub:updateMyLastInfo()
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogFightClubBattle", 
				options = {quickFightInfo = quickFightInfo, fightType = fightType}})
		end
	end
end

--重新绘制主界面
function QUIDialogFightClub:render( )
	self.rivals = remote.fightClub:getRivalFighter()
	self.myInfo = remote.fightClub:getMyInfo()
	self.mainInfo = remote.fightClub:getMainInfo()

	self:competitorHandler()
	self:updateForceInfo()
	self:updateMyFloorInfo()
	self:_renderFrame()

	local cdTime = remote.fightClub:getQuickFightTimeLimit() or 0
	local maxRank = remote.fightClub:getFightClubMaxRank()
	if (self.mainInfo.floor or 0) >= maxRank then
		self._ccbOwner.sp_quick_tips:setVisible(false)
		self._ccbOwner.node_rise_tips:setVisible(false)
		self._ccbOwner.node_rise:setVisible(false)
		self._ccbOwner.node_quick:setVisible(true)
		self._ccbOwner.node_btn_fast:setVisible(false)
		self._ccbOwner.node_effect:setVisible(false)
		self._ccbOwner.node_btn_onekey:setVisible(false)
		self._ccbOwner.tf_rise_tips:setVisible(false)
		if cdTime > 0 then
			makeNodeFromNormalToGray(self._ccbOwner.btn_quick)
			self._ccbOwner.tf_quick_btn_title:disableOutline()
			self:createTimeScheduler(self._ccbOwner.tf_quick_btn_title, cdTime, function()
					self._ccbOwner.tf_quick_btn_title:setString("快速挑战")
					makeNodeFromGrayToNormal(self._ccbOwner.btn_quick)
					self._ccbOwner.tf_quick_btn_title:enableOutline()
				end)
		end
	else
		self._ccbOwner.node_btn_fast:setVisible(false)
		self._ccbOwner.node_effect:setVisible(false)
		self._ccbOwner.node_quick:setVisible(false)
		self._ccbOwner.node_rise:setVisible(true)
		self._ccbOwner.node_rise_tips:setVisible(false)
		self._ccbOwner.tf_rise_tips:setVisible(true)
		self._ccbOwner.node_btn_onekey:setVisible(false)

		local winCount = self.myInfo.fightClubWinCount or 0
		if winCount >= self._riseCount then
			self._ccbOwner.node_rise_tips:setVisible(true)
		end

		if app.unlock:checkLock("UNLOCK_FIGHT_CLUB_YIJIANTIAOZHAN") then
			print("app.unlock:checkLock(UNLOCK_FIGHT_CLUB_YIJIANTIAOZHAN)")
			self._ccbOwner.node_btn_fast:setVisible(true)
			self._ccbOwner.node_effect:setVisible(true)
			-- self._ccbOwner.node_btn_onekey:setVisible(true)
			self._ccbOwner.node_quick_effect:setVisible(not app:getUserData():getValueForKey("UNLOCK_FIGHT_CLUB_YIJIANTIAOZHAN"..remote.user.userId))
			
			if cdTime > 0 then
				makeNodeFromNormalToGray(self._ccbOwner.btn_fast)
				self._ccbOwner.tf_fast_btn_title:disableOutline()
				self:createTimeScheduler(self._ccbOwner.tf_fast_btn_title, cdTime, function()
						self._ccbOwner.tf_fast_btn_title:setString("一键挑战")
						makeNodeFromGrayToNormal(self._ccbOwner.btn_fast)
						self._ccbOwner.tf_fast_btn_title:enableOutline()
					end)
			end
		end
	end

	self._ccbOwner.sp_record_tips:setVisible(remote.fightClub:getWinCountTips())

end

function QUIDialogFightClub:createTimeScheduler(tfNode, endTime, endFunc)
	local timeFunc
	timeFunc = function()
		endTime = endTime - 1
		if endTime > 0 then
			tfNode:setString(q.timeToHourMinuteSecond(endTime, true))
		else
			self:removeTimeScheduler()
			if endFunc then
				endFunc()
			end
		end
	end

	timeFunc()
	self._quickTimeScheduler = self:getScheduler().scheduleGlobal(timeFunc, 1)
end

function QUIDialogFightClub:removeTimeScheduler()
	if self._quickTimeScheduler then
		self:getScheduler().unscheduleGlobal(self._quickTimeScheduler)
		self._quickTimeScheduler = nil
	end
end

--战斗结束
function QUIDialogFightClub:exitFromBattleHandler()
	self._defaultPos = self:getOptions().defaultPos
	self:render()
end

--刷新
function QUIDialogFightClub:_onRefresh( event )
	self:render()
end

--刷新
function QUIDialogFightClub:_onReset( event )
	app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogFightClub"})
end

----------------------处理avatar气泡部分-------------------
function QUIDialogFightClub:removeTalkHandler()
	if self._talkSchedulerHandler ~= nil then 
		self:getScheduler().unscheduleGlobal(self._talkSchedulerHandler)
	end
end

function QUIDialogFightClub:avatarTalkTime()
	local totalCount = #self._avatarWord
	if totalCount <= 0 then return end
	local count = math.random(1, totalCount)
	self:startAvatarTalk(self._avatarWord[count].widget)
end

function QUIDialogFightClub:startAvatarTalk(widget, word)
	self:stopAvatarTalk()
	for index,value in ipairs(self._avatarWord) do
		if value.widget == widget then
			widget:showWord(word)
			value.istalk = true
			break
		end
	end
	self._talkSchedulerHandler = self:getScheduler().performWithDelayGlobal(handler(self, self.avatarTalkTime), 8)
end

function QUIDialogFightClub:stopAvatarTalk()
	self:removeTalkHandler()
	for index,value in ipairs(self._avatarWord) do
		if value.istalk == true then
			value.widget:removeWord()
			value.istalk = false
		end
	end
end

function QUIDialogFightClub:addAvatarTalk(widget)
	table.insert(self._avatarWord, {widget = widget, istalk = false})
end

function QUIDialogFightClub:removeAvatarTalk(widget)
	for index,value in ipairs(self._avatarWord) do
		if value.widget == widget then
			if value.istalk == true then
				self:stopAvatarTalk()
				self._talkSchedulerHandler = self:getScheduler().performWithDelayGlobal(handler(self, self.avatarTalkTime), 2)
			end
			table.remove(self._avatarWord, index)
			return
		end
	end
end

function QUIDialogFightClub:removeAllAvatarTalk()
	if self._avatarWord ~= nil then
		for index,value in ipairs(self._avatarWord) do
			if value.widget == widget then
				value.widget:removeWord()
			end
		end
	end
	self._avatarWord = {}
end

--对手信息处理 --todo
function QUIDialogFightClub:competitorHandler()
	self._totalWidth = self._ccbOwner.map1:getContentSize().width * 1.25 * 2 - 5 --由于map大小为奇数在计算位移时可以出现偏差 减少5像素防止漏边
	self._cellWidth = self._totalWidth / 10
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
	local defaultPos = 1
	for index, value in pairs(self.rivals) do
		local posY = -100+60*(self._index%2)
		local posX = self._index * self._cellWidth + self._cellWidth/2+30
		table.insert(self._virtualFrame, {value = value, posX = posX, posY = posY })
		self._index = self._index + 1

		if value.userId == remote.user.userId then
			defaultPos = posX - self._pageWidth/2
		end
	end

	-- 没有设置默认就默认自己
	if not self._defaultPos then
		self._defaultPos = defaultPos
	end

	if self._defaultPos ~= nil then
		self._ccbOwner.node_far:setPositionX(self._nodeFarPosx)
		self._ccbOwner.node_team:setPositionX(self._nodeTeamPosx)
		self:moveTo(-self._defaultPos, false, true)
		self._defaultPos = nil
	else
		self:moveTo(-(self._totalWidth - self._pageWidth)+self._orginPosX, false, true)
	end
	self:stopAvatarTalk()
	self._talkSchedulerHandler = self:getScheduler().performWithDelayGlobal(handler(self, self.avatarTalkTime), 2)
end

function QUIDialogFightClub:onTouchEvent(event)
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
    	local handler = self:getScheduler().performWithDelayGlobal(function ()
			self._schedulers[handler] = nil
    		self._isMove = false
    		end,0)
		self._schedulers[handler] = 1
    end
end

function QUIDialogFightClub:_removeAction()
	if self._actionHandler ~= nil then
		self._ccbOwner.node_team:stopAction(self._actionHandler)		
		self._actionHandler = nil
	end
	if self._actionFarHandler ~= nil then
		self._ccbOwner.node_far:stopAction(self._actionFarHandler)		
		self._actionFarHandler = nil
	end	
end

function QUIDialogFightClub:moveTo(posX, isAnimation, isCheck, delayTime)
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

function QUIDialogFightClub:_contentRunAction(posX,posY,delayTime)
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

function QUIDialogFightClub:onEnterFrame()
	self:exitEnterFrame()
	self._onEnterFrameHandler = self:getScheduler().scheduleGlobal(handler(self, self._renderFrame), 0)
end

function QUIDialogFightClub:exitEnterFrame()
	if self._onEnterFrameHandler ~= nil then
		self:getScheduler().unscheduleGlobal(self._onEnterFrameHandler)
	end
end

function QUIDialogFightClub:_renderFrame(isForce)
	local contentX = self._ccbOwner.node_team:getPositionX()
	if self._virtualFrame == nil then
		self:exitEnterFrame()
		return
	end
	for _,frame in ipairs(self._virtualFrame) do
		if frame.posX + contentX <= (self._orginPosX - self._cellWidth/2) or frame.posX + contentX >= (self._orginPosX + self._pageWidth + self._cellWidth/2) then
			self:framRenderHandler(frame, false, isForce)
		end
	end
	for _,frame in ipairs(self._virtualFrame) do
		if frame.posX + contentX > (self._orginPosX - self._cellWidth/2) and frame.posX + contentX < (self._orginPosX + self._pageWidth + self._cellWidth/2) then
			self:framRenderHandler(frame, true, isForce)
		end
	end
end

function QUIDialogFightClub:framRenderHandler(frame, isShow, isForce)
	if frame.isShow == isShow and isForce ~= true then
		return
	end
	frame.isShow = isShow
	if isShow == true then
		if frame.widget == nil then
			frame.widget = self:getEmptyFrame()
		end
		frame.widget:setPosition(frame.posX, frame.posY)
		frame.widget:setInfo(frame.value)
		frame.rivalId = nil
		frame.widget:setVisible(true)
		return
	end
	if isShow == false then
		if frame.widget ~= nil then
			table.insert(self._emptyBox, frame.widget)
			frame.widget:setVisible(false)
			frame.widget = nil
		end
		return
	end
end

function QUIDialogFightClub:getEmptyFrame()
	if #self._emptyBox > 0 then
		return table.remove(self._emptyBox)
	end
	local userCell = QUIWidgetFightClub.new()
	userCell:addEventListener(userCell.EVENT_BATTLE, handler(self, self.startBattleHandler))
	userCell:addEventListener(userCell.EVENT_VISIT, handler(self, self.clickCellHandler))
	self._ccbOwner.node_avatar:addChild(userCell)
	return userCell
end

function QUIDialogFightClub:checkDefenseUpdate()
	remote.fightClub:checkDefenseUpdate()
end

function QUIDialogFightClub:updateForceInfo()
    local force = remote.teamManager:getBattleForceForAllTeam(remote.teamManager.FIGHT_CLUB_DEFEND_TEAM, false)
    local fontInfo = db:getForceColorByForce(force, true)
    local num, unit = q.convertLargerNumber(force)
    self._ccbOwner.tf_defens_force:setString(num..(unit or ""))
	local color = string.split(fontInfo.force_color, ";")
	self._ccbOwner.tf_defens_force:setColor(ccc3(color[1], color[2], color[3]))
	self._ccbOwner.sp_team_tips:setVisible(not remote.teamManager:checkTeamStormIsFull(remote.teamManager.FIGHT_CLUB_DEFEND_TEAM))

	self._ccbOwner.node_pvp:setVisible(ENABLE_PVP_FORCE)
	self._ccbOwner.node_pvp:setPositionX( self._pvpNodePosX + self._ccbOwner.tf_defens_force:getContentSize().width)
end

function QUIDialogFightClub:startCountdownSchedule()
	if self._countdownSchedule then
		self:getScheduler().unscheduleGlobal(self._countdownSchedule)
		self._countdownSchedule = nil
	end
	self:updateCountdown()
	self._countdownSchedule = self:getScheduler().scheduleGlobal(function (  )
		if self:safeCheck() then
			self:updateCountdown()
		end
	end, 1)
end

function QUIDialogFightClub:updateCountdown()
	local isInSeason, timeStr, color = remote.fightClub:updateTime()
	if isInSeason then
		self._ccbOwner.tf_left_time:setString(timeStr)
		self._ccbOwner.tf_left_time:setColor(color)
	end

	self:chcekSeasonFight()
end

function QUIDialogFightClub:updateMyFloorInfo()
	local myFloor = self.mainInfo.floor or 0
    local envRank = self.mainInfo.envRank or 1
    local allRank = self.mainInfo.rank or 1
    local roomPersonNum = self.mainInfo.roomPersonNum or 1
    local roomRank = self.myInfo.fightClubRoomRank or 1
    local winCount = self.myInfo.fightClubWinCount or 0

    local map = remote.fightClub:getMapInfo(myFloor)
    self._ccbOwner.map1:setTexture(map)
    self._ccbOwner.map2:setTexture(map)
    self._ccbOwner.map1:setScale(1.25)
    self._ccbOwner.map2:setScaleX(-1.25)
    self._ccbOwner.map2:setScaleY(1.25)

	self._ccbOwner.node_icon:removeAllChildren()
	local floorNode = QUIWidgetFloorIcon.new({floor = myFloor, isLarge = true})
	floorNode:setColor(COLORS.b)
 	self._ccbOwner.node_icon:addChild(floorNode)
    self._ccbOwner.tf_cur_rank:setString(envRank)
	self._ccbOwner.tf_all_rank:setString(allRank)

	local roomState = remote.fightClub:getRoomState(myFloor, roomRank)
	local stateStr = "保级"
	if roomState == remote.fightClub.STATE_DOWN then
		stateStr = "降级"
		self._ccbOwner.tf_ranking:setColor(COLORS.b)
	elseif roomState == remote.fightClub.STATE_KEEP then
		stateStr = "保级"
		self._ccbOwner.tf_ranking:setColor(COLORS.B)
	elseif roomState == remote.fightClub.STATE_UP then
		stateStr = "晋级"
		self._ccbOwner.tf_ranking:setColor(COLORS.G)
	end

	local rankStr = string.format("%d (%s)", roomRank, stateStr)
	local maxRank = remote.fightClub:getFightClubMaxRank()
	if myFloor >= maxRank then
		self._ccbOwner.tf_win_count:setString(winCount)
    	if roomRank > 50 then
    		rankStr = string.format("%d (降级)", roomRank)
    	end
    	self._ccbOwner.node_map1:setVisible(false)
    	self._ccbOwner.node_map2:setVisible(true)
	else
		self._ccbOwner.node_map1:setVisible(true)
    	self._ccbOwner.node_map2:setVisible(false)
		self._ccbOwner.tf_win_count:setString(winCount.."/"..self._riseCount)
	end
    self._ccbOwner.tf_ranking:setString(rankStr)
    local posX = self._ccbOwner.tf_ranking:getPositionX()
    posX = posX + self._ccbOwner.tf_ranking:getContentSize().width+8
    local totalCount = string.format("##j共##w%d##j人", roomPersonNum)
	local buffText = QColorLabel:create(totalCount, nil, nil, nil, 22)
	self._ccbOwner.node_number:removeAllChildren()
	self._ccbOwner.node_number:addChild(buffText)
	self._ccbOwner.node_number:setPositionX(posX)
	buffText:setPosition(ccp(0, 0))

    local awards = remote.fightClub:getAwardByFloorRank(myFloor, roomRank)
	for i = 1, 4 do
		if awards[i] then
            local itemBox = QUIWidgetItemsBox.new()
            itemBox:setGoodsInfo(awards[i].id, awards[i].typeName, 0)
            self._ccbOwner["icon_"..i]:addChild(itemBox)
            self._ccbOwner["icon_"..i]:setScale(0.42)
            self._ccbOwner["num_"..i]:setString("x"..awards[i].count)
        else
            self._ccbOwner["num_"..i]:setString("")
            self._ccbOwner["icon_"..i]:removeAllChildren()
        end
	end

	local itemInfo
	local shopItems = remote.stores:getStoresById(SHOP_ID.itemShop)
	for i, v in pairs(shopItems) do
		if v.id == GEMSPAR_SHOP_ID then
			itemInfo = v
			break
		end
	end
	self._ccbOwner.tf_sale:setVisible(false)
	local chestSale = remote.stores:getSaleByShopItemInfo(itemInfo)
	if chestSale <= 1.5 then
		self._ccbOwner.tf_sale:setVisible(true)
		self._ccbOwner.tf_sale:setString(chestSale.."折")
	end
end

-- 
function QUIDialogFightClub:clickCellHandler(event)
	if self._isMove then return end
    app.sound:playSound("common_small")

    local userId = event.info.userId
	remote.fightClub:requestQueryFightClubDefendTeam(userId, function(data)
			local rivalInfo = (data.towerFightersDetail or {})[1] 
			if rivalInfo == nil then
				return 
			end
			remote.fightClub:updateFighterDefenseTeam(rivalInfo)
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogPlayerInfo",
	    		options = {showAssist = true, fighter = rivalInfo, forceTitle1 = "防守战力：", model = GAME_MODEL.NORMAL, isPVP = true}}, {isPopCurrentDialog = false})
		end)
end

function QUIDialogFightClub:startBattle(userId)
	remote.fightClub:requestQueryFightClubDefendTeam(userId, function(data)
			local rivalInfo = (data.towerFightersDetail or {})[1] 
			if rivalInfo == nil then
				return 
			end
			remote.fightClub:updateFighterDefenseTeam(rivalInfo)
			local fightArrangement = QFightClubArrangement.new({rivalInfo = rivalInfo, myInfo = self.myInfo, teamKey = remote.teamManager.FIGHT_CLUB_ATTACK_TEAM })
			local teams = fightArrangement:getExistingHeroes()
			app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogTeamArrangement",
				options = {arrangement = fightArrangement, isShowQuickBtn = (#teams > 0)}})
		end)
end

function QUIDialogFightClub:startBattleHandler(event)
	if self.rivalId ~= nil then return end
	if self._isMove then return  end
	if self._isEnd then return  end
    app.sound:playSound("common_small")

    local userId = event.info.userId
	self._rivalId = userId
	if userId == remote.user.userId then
		app.tip:floatTip("不能挑战自己！")
		return
	end

	local rivalInfo = nil
	for index, value in pairs(self.rivals) do
		if value.userId == userId then
			rivalInfo = value
			local posX = index * self._cellWidth - self._cellWidth/2+30
			self:getOptions().defaultPos = posX - self._pageWidth/2
			break
		end
	end

	if rivalInfo == nil then
		app.tip:floatTip("对手不存在！")
		return 
	end

	local actorIds = remote.teamManager:getActorIdsByKey(remote.teamManager.FIGHT_CLUB_ATTACK_TEAM)
  	if q.isEmpty(actorIds) then
    	self:_teamIsNil()
    	return 
  	end

	self:startBattle(userId)
end

function QUIDialogFightClub:_teamIsNil()
  	app:alert({content="还未设置战队，无法参加战斗！现在就设置战队？", title="系统提示", callback=function(state)
		if state == ALERT_TYPE.CONFIRM then
		print("_teamIsNil")
		return
			self:onAttackTeam()
		end
  	end})
end

function QUIDialogFightClub:_quickFightTeamIsNil(callback)
	print("_quickFightTeamIsNil")
  	app:alert({content="还未设置战队，无法参加战斗！现在就设置战队？",title="系统提示", callback=function(state)
		if state == ALERT_TYPE.CONFIRM then
			if callback then
				callback()
			end
		end
  	end})
end

function QUIDialogFightClub:_onTriggerTeam(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_team) == false then return end
    app.sound:playSound("common_small")
	local arenaArrangement = QFightClubDefenseArrangement.new({teamKey = remote.teamManager.FIGHT_CLUB_DEFEND_TEAM})
	local teams = arenaArrangement:getExistingHeroes()
	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogTeamArrangement",
		options = {arrangement = arenaArrangement, defense = true, isShowQuickBtn = (#teams > 0)}})
end

function QUIDialogFightClub:onAttackTeam(isQuick)
    app.sound:playSound("common_small")
    
    if isQuick then
    	local callback = function () self:_onQuickFight() end
    	local arenaArrangement = QFightClubArrangement.new({rivalInfo = rivalInfo, myInfo = self.myInfo, isQuick = true, teamKey = remote.teamManager.FIGHT_CLUB_ATTACK_TEAM, callback = callback})
		local teams = arenaArrangement:getExistingHeroes()
		app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogTeamArrangement",
			options = {arrangement = arenaArrangement, isShowQuickBtn = (#teams > 0)}})
    else
		self:startBattle(self._rivalId)
	end
end
 
function QUIDialogFightClub:_onQuickFight()
	remote.fightClub:requestFightClubQuickFight(function() 	
			local quickFightInfo = remote.fightClub:getFightClubQuickFightInfo()
			app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogFightClubMatchOpponent", 
				options = {quickFightInfo = quickFightInfo}})
		end)
end

function QUIDialogFightClub:_onFastFight(fighters)
	remote.fightClub:requestFightClubQuickFight(function() 	
		local quickFightInfo = remote.fightClub:getFightClubQuickFightInfo()
		app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogFightClubMatchOpponent", 
			options = {quickFightInfo = quickFightInfo, fightType = remote.fightClub.FAST_FIGHT, callback = function()

			end}})
		end)
	
end


function QUIDialogFightClub:_onOneKeyFastFight()
    print("_onOneKeyFastFight")
	remote.fightClub:requestFightClubQuickFight(function() 	
		app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
	
	    -- 计算所以未挑战的玩家
	    local userDataList = {}
		-- local rivals = remote.fightClub:getRivalFighter()
		local FightInfo = remote.fightClub:getFightClubQuickFightInfo()
		local wave = 0
		--for _, value in ipairs(rivals) do
		for _, value in ipairs(FightInfo.fighter) do
			wave = wave + 1
			if value.userId ~= remote.user.userId then
				local bFail = remote.fightClub:getIsRivalFailed(value.userId)
				if not bFail then
					print("value.userId not bFail")
					local  repalyInfo = QReplayUtil:_createReplayFighterFromFighter(value)
					local buff = app:getProtocol():encodeMessageToBuffer("cc.qidea.wow.client.battle.ReplayFighter", repalyInfo)
					local fight_replayData = crypto.encodeBase64(buff)
					userDataList[#userDataList+1] = {userId = value.userId , wave = wave , replayData = fight_replayData}
				end
			end
		end
		local myData_repalyInfo = QReplayUtil:createReplayFighterBuffer(remote.teamManager.FIGHT_CLUB_ATTACK_TEAM)
		myData_repalyInfo = crypto.encodeBase64(myData_repalyInfo)	
		local myData =  {userId = remote.user.userId , wave = 0 , replayData = myData_repalyInfo}
		remote.fightClub:fightClubQuickFightRequest(myData ,userDataList, function() 	
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogFightClubQuick", 
					options = {}})

		end)
	end)


	-- remote.fightClub:requestFightClubQuickFight(function() 	
	-- 	app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
	-- 	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogFightClubQuick", 
	-- 					options = {}})
	-- end)

end

function QUIDialogFightClub:checkWineglassLess(callback)
	if q.isEmpty(self.mainInfo) then 
		if callback then
			callback()
		end
		return
	end
	if self.mainInfo.oldFailUserName then
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogFightClubRankDown", 
			options = {oldFailUserName = self.mainInfo.oldFailUserName,callBack = function()
				if callback then
					callback()
				end
			end}})
	else
		if callback then
			callback()
		end
	end
end

function QUIDialogFightClub:checkRankChangeInfo()
	remote.userDynamic:openDynamicDialog(5, function(isConfirm)
			if self:safeCheck() then
				if isConfirm == false then
					self._ccbOwner.sp_record_tips:setVisible(true)
				else
					self:_onTriggerRecord()
				end
			end
		end)
end

function QUIDialogFightClub:_onTriggerRise(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_rise) == false then return end
	app.sound:playSound("common_small")
	local winCount = self.myInfo.fightClubWinCount or 0
	if winCount < self._riseCount then
		app.tip:floatTip("拿到"..self._riseCount.."个血腥玛丽才可以直接晋级")
		return
	end

	remote.fightClub:requestFightClubRise(function(data)
			local awards = data.prizes or {}
			local callback = function()
				if #awards > 0 then
				    local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert", 
				    	options = {awards = awards, callback = function()
								remote.fightClub:requestFightClubInfo()
				    		end}},{isPopCurrentDialog = true})
				    dialog:setTitle("恭喜获得升段奖励")
				else
					remote.fightClub:requestFightClubInfo()
				end
			end
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass= "QUIDialogFightClubShootUpWin", options = {callback = callback}})
		end)
end

function QUIDialogFightClub:_onTriggerQuick(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_quick) == false then return end
	app.sound:playSound("common_small")

	local fightCallback = function()
		local callback = function () 
			self:_onQuickFight() 
			-- self:_onOneKeyFastFight() 
		end
    	local arenaArrangement = QFightClubArrangement.new({myInfo = self.myInfo, isQuick = true, teamKey = remote.teamManager.FIGHT_CLUB_ATTACK_TEAM, callback = callback})
		local teams = arenaArrangement:getExistingHeroes()
		app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogTeamArrangement",
			options = {arrangement = arenaArrangement, isShowQuickBtn = (#teams > 0)}})
	end

	local cdTime = remote.fightClub:getQuickFightTimeLimit() or 0
	if cdTime <= 0 then
		app:alert({content = "随机挑战10名王者榜前30名的玩家", title = "快速挑战", callback = function(state)
				if state == ALERT_TYPE.CONFIRM then
					local actorIds = remote.teamManager:getActorIdsByKey(remote.teamManager.FIGHT_CLUB_ATTACK_TEAM)
					-- 没有上阵英雄
					if q.isEmpty(actorIds) then
					    self:_quickFightTeamIsNil(function()
					    		fightCallback()
					    	end)
						return
					else
						fightCallback()
					end

				end
			end})
	else
		local timeStr = q.timeToDayHourMinute(cdTime, true)
		app.tip:floatTip(string.format("%s后可进行快速挑战", timeStr))
	end
end

function QUIDialogFightClub:_onTriggerFast(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_fast) == false then return end
	app.sound:playSound("common_small")
    print("_onTriggerFast")
    if not app:getUserData():getValueForKey("UNLOCK_FIGHT_CLUB_YIJIANTIAOZHAN"..remote.user.userId) then
        app:getUserData():setValueForKey("UNLOCK_FIGHT_CLUB_YIJIANTIAOZHAN"..remote.user.userId, "true")
        self._ccbOwner.node_quick_effect:setVisible(false)
    end 
	local fightCallback = function(fighters)
		local callback = function () 
			self:_onFastFight(fighters) 
		end
    	local arenaArrangement = QFightClubArrangement.new({myInfo = self.myInfo, isQuick = true, teamKey = remote.teamManager.FIGHT_CLUB_ATTACK_TEAM, callback = callback})
		local teams = arenaArrangement:getExistingHeroes()
		app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogTeamArrangement",
			options = {arrangement = arenaArrangement, isShowQuickBtn = (#teams > 0)}})
	end

    local fighters = {}
	local rivals = remote.fightClub:getRivalFighter()
	for _, value in ipairs(rivals) do
		if value.userId ~= remote.user.userId then
			local bFail = remote.fightClub:getIsRivalFailed(value.userId)
			if not bFail then
				fighters[#fighters+1] = value
			end
		end
	end

	local cdTime = remote.fightClub:getQuickFightTimeLimit() or 0
	if cdTime <= 0 then
		if #fighters <= 0 then
			app.tip:floatTip("当前房间内没有未战胜的玩家")
			return
		end

		app:alert({content = "挑战当前房间内所有未战胜的玩家", title = "一键挑战", callback = function(state)
				if state == ALERT_TYPE.CONFIRM then
					local actorIds = remote.teamManager:getActorIdsByKey(remote.teamManager.FIGHT_CLUB_ATTACK_TEAM)
					-- 没有上阵英雄
					if q.isEmpty(actorIds) then
					    self:_quickFightTeamIsNil(function()
					    		fightCallback(fighters)
					    	end)
						return
					else
						fightCallback(fighters)
					end
				end

			end})
	else
		local timeStr = q.timeToDayHourMinute(cdTime, true)
		app.tip:floatTip(string.format("%s后可进行一键挑战", timeStr))
	end
end

function QUIDialogFightClub:_onTriggerClickOneKeyFightAll(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_fast) == false then return end
	app.sound:playSound("common_small")
    if not app:getUserData():getValueForKey("UNLOCK_FIGHT_CLUB_YIJIANTIAOZHAN"..remote.user.userId) then
        app:getUserData():setValueForKey("UNLOCK_FIGHT_CLUB_YIJIANTIAOZHAN"..remote.user.userId, "true")
        self._ccbOwner.node_quick_effect:setVisible(false)
    end 
    print("_onTriggerClickOneKeyFightAll")
    -- 计算所以未挑战的玩家
    local fighters = {}
	local rivals = remote.fightClub:getRivalFighter()
	for _, value in ipairs(rivals) do
		if value.userId ~= remote.user.userId then
			local bFail = remote.fightClub:getIsRivalFailed(value.userId)
			if not bFail then
				fighters[#fighters+1] = value
			end
		end
	end

	--
	local fightCallback = function()
		local callback = function () 
			self:_onOneKeyFastFight() 
		end
    	local arenaArrangement = QFightClubArrangement.new({myInfo = self.myInfo, isQuick = true, teamKey = remote.teamManager.FIGHT_CLUB_ATTACK_TEAM, callback = callback})
		local teams = arenaArrangement:getExistingHeroes()
		app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogTeamArrangement",
			options = {arrangement = arenaArrangement, isShowQuickBtn = (#teams > 0)}})
	end

	local cdTime = remote.fightClub:getQuickFightTimeLimit() or 0
	if cdTime <= 0 then
		if #fighters <= 0 then
			app.tip:floatTip("当前房间内没有未战胜的玩家")
			return
		end
		app:alert({content = "挑战当前房间内所有未战胜的玩家", title = "一键挑战", callback = function(state)
				if state == ALERT_TYPE.CONFIRM then
					local actorIds = remote.teamManager:getActorIdsByKey(remote.teamManager.FIGHT_CLUB_ATTACK_TEAM)
					-- 没有上阵英雄
					if q.isEmpty(actorIds) then
					    self:_quickFightTeamIsNil(function()
					    		fightCallback()
					    	end)
						return
					else
						fightCallback()
					end
				end

			end})
	else
		local timeStr = q.timeToDayHourMinute(cdTime, true)
		app.tip:floatTip(string.format("%s后可进行一键挑战", timeStr))
	end
end


function QUIDialogFightClub:_onTriggerClickPVP(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_pvp) == false then return end
    app.sound:playSound("common_small")

    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogPVPPropTip", 
        options = {teamKey = remote.teamManager.FIGHT_CLUB_DEFEND_TEAM}}, {isPopCurrentDialog = false})
end

function QUIDialogFightClub:_onTriggerRule()
	app.sound:playSound("common_small")
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogFightClubRule"})
end

function QUIDialogFightClub:_onTriggerRecord(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_record) == false then return end
	app.sound:playSound("common_small")
	remote.fightClub:setWinCountTips(false)
	self._ccbOwner.sp_record_tips:setVisible(false)
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogAgainstRecord", options = {reportType = REPORT_TYPE.FIGHT_CLUB}}, {isPopCurrentDialog = false})
end

function QUIDialogFightClub:_onTriggerRank()
	app.sound:playSound("common_small")
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogRank", options = {initRank = "allFightClubRank"}}, {isPopCurrentDialog = false})
end

function QUIDialogFightClub:_onTriggerShop(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_shop) == false then return end
    app.sound:playSound("common_small")
    remote.stores:openShopDialog(SHOP_ID.sparShop)
end

function QUIDialogFightClub:_onTriggerRefresh(event)
    app.sound:playSound("common_small")

	local changeCount = self.mainInfo.dailyChangeCount or 0
	local consumeConfig, isExist = db:getTokenConsume("fight_club_change_times", changeCount+1)
	-- 不存在此配置
	if not isExist then
		app.tip:floatTip("您今天更换房间的次数已经用完！")
		return 
	end

	-- 钻石不足
	if consumeConfig.money_num > remote.user.token then
		QQuickWay:addQuickWay(QQuickWay.TOKEN_DROP_WAY, nil)
		return
	end

	local config = db:getTokenConsumeByType("fight_club_change_times")
	local leftCount = #config - changeCount
	local content = string.format("##n更换房间后所获得的血腥玛丽将会被清除，您今天还有##e%d##n次更换房间的机会，确认##e花费%d钻石##n更换房间？", leftCount, consumeConfig.money_num)
	app:alert({content = content, callback = function(state)
	        if state == ALERT_TYPE.CONFIRM then
				remote.fightClub:requestChangeRoom(function()
	        			app:alert({content = "换房成功，您之前获取的血腥玛丽已经被回收，请开始新的战斗~", btns = {ALERT_BTN.BTN_OK}})
					end)
	        end
	    end, colorful = true})
end

function QUIDialogFightClub:_onTriggerChest(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_box) == false then return end
    app.sound:playSound("common_small")

	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMall", options = {tab = "ITEM_MALL_TYPE", itemId = GEMSPAR_SHOP_ID}})
end

return QUIDialogFightClub