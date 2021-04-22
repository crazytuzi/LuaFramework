-- @Author: liaoxianbo
-- @Date:   2020-08-05 11:16:17
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-08-17 16:04:42
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogMazeExploreTimeDown = class("QUIDialogMazeExploreTimeDown", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QRichText = import("...utils.QRichText")

function QUIDialogMazeExploreTimeDown:ctor(options)
	local ccbFile = "ccb/Dialog_MazeExplore_Event_TimeDown.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerChoose1", callback = handler(self, self._onTriggerChoose1)},
		{ccbCallbackName = "onTriggerChoose2", callback = handler(self, self._onTriggerChoose2)},
		{ccbCallbackName = "onTriggerChoose3", callback = handler(self, self._onTriggerChoose3)},
		{ccbCallbackName = "onTriggerChoose4", callback = handler(self, self._onTriggerChoose4)},
    }
    QUIDialogMazeExploreTimeDown.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

    self._totalBarWidth = self._ccbOwner.sp_time_bar:getContentSize().width * self._ccbOwner.sp_time_bar:getScaleX()
    self._percentBarClippingNode = q.newPercentBarClippingNode(self._ccbOwner.sp_time_bar)

    self._callBack = options.callBack
    self._gridInfo = options.gridInfo
    self._untilTime = (db:getConfigurationValue("rockfall_tick") or 3 )
    self._oldClockPosX = self._ccbOwner.node_clock:getPositionX()
    self._ccbOwner.tf_time:setString(self._untilTime)
   
end

function QUIDialogMazeExploreTimeDown:viewDidAppear()
	QUIDialogMazeExploreTimeDown.super.viewDidAppear(self)

	-- self:addBackEvent(true)
	 self:initView()
end

function QUIDialogMazeExploreTimeDown:viewWillDisappear()
  	QUIDialogMazeExploreTimeDown.super.viewWillDisappear(self)

	-- self:removeBackEvent()
	if self._timeScheduler then
		scheduler.unscheduleGlobal(self._timeScheduler)
		self._timeScheduler = nil
	end	
end

function QUIDialogMazeExploreTimeDown:initView( )
	if q.isEmpty(self._gridInfo) then return end
	self._ccbOwner.tf_btnName1:setString(self._gridInfo.option_des_1 or "")
	self._ccbOwner.tf_btnName2:setString(self._gridInfo.option_des_2 or "")
	self._ccbOwner.tf_btnName3:setString(self._gridInfo.option_des_3 or "")
	self._ccbOwner.tf_btnName4:setString(self._gridInfo.option_des_4 or "")

	self._ccbOwner.node_text:removeAllChildren()
    local richTextNode = QRichText.new(nil, 400,{autoCenter = true})
    richTextNode:setString({
        {oType = "font", content = "落石正从",size = 22,color = COLORS.b,strokeColor = ccc3(87, 59, 46)},
        {oType = "font", content = self._gridInfo.answer_des or "", size = 22,color = ccc3(255, 93, 93),strokeColor = ccc3(87, 59, 46)},
        {oType = "font", content = "落下", size = 22,color = COLORS.b,strokeColor = ccc3(87, 59, 46)},
    })
    richTextNode:setAnchorPoint(ccp(0.5, 0.5))
    self._ccbOwner.node_text:addChild(richTextNode)

	self:timeDown()
end

function QUIDialogMazeExploreTimeDown:timeDown()
	if self._timeScheduler then
		scheduler.unscheduleGlobal(self._timeScheduler)
		self._timeScheduler = nil
	end

	local endTime = q.serverTime() + self._untilTime
	
	local timeFunc
	timeFunc = function ( )
		local lastTime = endTime - q.serverTime()
		if self:safeCheck() then
			if lastTime > 0 then
				local timeStr = math.ceil(lastTime)
				self._ccbOwner.tf_time:setString(timeStr)

				local stencil = self._percentBarClippingNode:getStencil()
				local posX = -self._totalBarWidth + lastTime/self._untilTime*self._totalBarWidth
				stencil:setPositionX(posX)

				self._ccbOwner.node_clock:setPositionX(self._oldClockPosX+posX)				
			else 
				if self._timeScheduler then
					scheduler.unscheduleGlobal(self._timeScheduler)
					self._timeScheduler = nil
				end
				self:_onTriggerClose()
			end
		end
	end

	self._timeScheduler = scheduler.scheduleGlobal(timeFunc, 1)
	timeFunc()
end

function QUIDialogMazeExploreTimeDown:selectBtn(btnIndex)
	-- body
	self._selectIndex = btnIndex
	self:_onTriggerClose()
end

function QUIDialogMazeExploreTimeDown:_onTriggerChoose1( )
	app.sound:playSound("common_small")
	self:selectBtn(1)
end

function QUIDialogMazeExploreTimeDown:_onTriggerChoose2( )
	app.sound:playSound("common_small")
	self:selectBtn(2)
end

function QUIDialogMazeExploreTimeDown:_onTriggerChoose3( )
	app.sound:playSound("common_small")
	self:selectBtn(3)
end

function QUIDialogMazeExploreTimeDown:_onTriggerChoose4( )
	app.sound:playSound("common_small")
	self:selectBtn(4)
end

function QUIDialogMazeExploreTimeDown:_onTriggerClose()
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogMazeExploreTimeDown:viewAnimationOutHandler()
	local callback = self._callBack

	self:popSelf()

	if callback then
		callback(self._selectIndex == self._gridInfo.parameter)
	end
end

return QUIDialogMazeExploreTimeDown
