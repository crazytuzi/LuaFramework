-- @Author: xurui
-- @Date:   2019-05-15 11:37:54
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2019-11-08 10:46:54
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetActivitySoulLetterTaskClient = class("QUIWidgetActivitySoulLetterTaskClient", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QUIWidgetFcaAnimation = import(".actorDisplay.QUIWidgetFcaAnimation")

QUIWidgetActivitySoulLetterTaskClient.EVENT_CLICK_RECIVE = "EVENT_CLICK_RECIVE"
QUIWidgetActivitySoulLetterTaskClient.EVENT_CLICK_GO = "EVENT_CLICK_GO"

function QUIWidgetActivitySoulLetterTaskClient:ctor(options)
	local ccbFile = "ccb/Widget_Battle_Pass_mission.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerRecive", callback = handler(self, self._onTriggerRecive)},
		{ccbCallbackName = "onTriggerGo", callback = handler(self, self._onTriggerGo)},
    }
    QUIWidgetActivitySoulLetterTaskClient.super.ctor(self, ccbFile, callBacks, options)
  
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._showEffect = false
end

function QUIWidgetActivitySoulLetterTaskClient:onEnter()
end

function QUIWidgetActivitySoulLetterTaskClient:onExit()
end

function QUIWidgetActivitySoulLetterTaskClient:setInfo(info, activityProxy)
	self._info = info
	self._activityProxy = activityProxy
	self._progress, self._curStep, self._isMultiple = self._activityProxy:getTaskMultipleInfo(self._info)

	self._ccbOwner.tf_title:setString(self._info.name or "")
	self._ccbOwner.tf_desc:setString(self._info.des or "")

	if self._icon == nil then
		self._icon = CCSprite:create()
		self._icon:setScale(0.90)
		self._ccbOwner.node_icon:addChild(self._icon)
	end
	QSetDisplayFrameByPath(self._icon, self._info.icon)

	--set progress
	local curNum = self._progress.process or 0
	local maxNum = self._info.num or 0
	if curNum > maxNum then
		curNum = maxNum
	end
	self._ccbOwner.tf_progress:setString(string.format("进度:%s/%s", curNum, maxNum))
	self._ccbOwner.sp_exp_bar:setScaleX(curNum/maxNum)

	self:setExpInfo(self._info.exp)
	self:setTaskStatus()
end

function QUIWidgetActivitySoulLetterTaskClient:setExpInfo(exp)
	--self._ccbOwner.node_up:setVisible(self._isMultiple)
	-- self._ccbOwner.node_exp_2:setVisible(self._isMultiple)
	-- self._ccbOwner.node_exp_1:setVisible(not self._isMultiple)

	exp = exp or 0
	self._ccbOwner.tf_exp_1:setString(exp)

	self._ccbOwner.sp_exp_double:setVisible(self._isMultiple)
	self._ccbOwner.sp_fanbei:setVisible(self._isMultiple)
	if self._isMultiple then
		local doublePos = self._ccbOwner.tf_exp_1:getPositionX()
		doublePos = doublePos + self._ccbOwner.tf_exp_1:getContentSize().width
		self._ccbOwner.sp_exp_double:setPositionX(doublePos)

		-- 居中
		local tfWidth = doublePos + self._ccbOwner.sp_exp_double:getContentSize().width
		self._ccbOwner.node_exp_1:setPositionX(-tfWidth * 0.5)
	end

	if self._isMultiple then
		local multipleNum = db:getConfigurationValue("shouzha_multiple") or 2
		local multipleStr = q.numToWord(multipleNum)
		if multipleNum == 2 then
			multipleStr = "双"
		end
		self._ccbOwner.tf_exp_multiple:setString("EXP"..multipleStr .. "倍")
		self._ccbOwner.tf_exp_up:setString(multipleStr .. "倍")
		self._ccbOwner.tf_exp_2:setString(exp * multipleNum)
	end
end

-- 返回此任务是否多倍
function QUIWidgetActivitySoulLetterTaskClient:getIsMultiple()
	return self._isMultiple
end

function QUIWidgetActivitySoulLetterTaskClient:setTaskStatus()
	local expIsFull = self._activityProxy:checkWeekExpIsFull()
	local curNum = self._progress.process or 0
	local isComplete = curNum >= (self._info.num or 0)
	local isAllComplete = (self._curStep == nil)
	
	if isAllComplete then
		self._ccbOwner.sp_achieve:setVisible(true)
		self._ccbOwner.node_do:setVisible(false)
		self._ccbOwner.node_up:setVisible(false)
	else
		self._ccbOwner.sp_achieve:setVisible(false)
		if isComplete then
			self._ccbOwner.node_do:setVisible(true)
			self._ccbOwner.sp_limit:setVisible(false)
			self._ccbOwner.node_btn_go:setVisible(false)
			self._ccbOwner.node_btn_recive:setVisible(true)
		else
			if expIsFull then
				self._ccbOwner.node_do:setVisible(false)
				self._ccbOwner.sp_limit:setVisible(true)
			else
				self._ccbOwner.node_do:setVisible(true)
				self._ccbOwner.sp_limit:setVisible(false)
				self._ccbOwner.node_btn_go:setVisible(true)
				self._ccbOwner.node_btn_recive:setVisible(false)
			end
		end
	end
end

function QUIWidgetActivitySoulLetterTaskClient:showRefreshEffet(callback)
	if self._refreshEffect then
		self._refreshEffect:removeFromParent()
		self._refreshEffect = nil
	end
	self._showEffect = true
	self._refreshEffect = QUIWidgetFcaAnimation.new("fca/xiancao_appear_effect", "res")
	self._refreshEffect:playAnimation("animation", false)
	self._refreshEffect:setEndCallback(function()
		if self._refreshEffect then
			self._refreshEffect:removeFromParent()
			self._refreshEffect = nil
		end
		self._showEffect = false
		if callback then
			callback()
		end
	end)
	self._ccbOwner.node_effect:addChild(self._refreshEffect)
end

function QUIWidgetActivitySoulLetterTaskClient:_onTriggerRecive( ... )
	if self._showEffect == false then
		self:dispatchEvent({name = QUIWidgetActivitySoulLetterTaskClient.EVENT_CLICK_RECIVE, info = self._info, target = self})
	end
end

function QUIWidgetActivitySoulLetterTaskClient:_onTriggerGo( ... )
    if app.unlock:checkLock(self._info.unlock, true) then
		self:dispatchEvent({name = QUIWidgetActivitySoulLetterTaskClient.EVENT_CLICK_GO, info = self._info})
	end
end

function QUIWidgetActivitySoulLetterTaskClient:getContentSize()
	return self._ccbOwner.sp_bg:getContentSize()
end

function QUIWidgetActivitySoulLetterTaskClient:getInfo()
	return self._info
end

return QUIWidgetActivitySoulLetterTaskClient
