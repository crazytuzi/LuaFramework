-- @Author: xurui
-- @Date:   2017-04-28 14:24:10
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2019-11-11 16:02:35
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogDragonWarFastBattle = class("QUIDialogDragonWarFastBattle", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QScrollView = import("...views.QScrollView")
local QUIWidgetDragonWarFastBattleClient = import("..widgets.QUIWidgetDragonWarFastBattleClient")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")

function QUIDialogDragonWarFastBattle:ctor(options)
	local ccbFile = "ccb/Dialog_EliteBattleAgain_yijiangoumai.ccbi"
	local callBack = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
		{ccbCallbackName = "onTriggerStop", callback = handler(self, self._onTriggerStop)},
	}
	QUIDialogDragonWarFastBattle.super.ctor(self, ccbFile, callBack, options)
	self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
	
	q.setButtonEnableShadow(self._ccbOwner.btn_close)
	self._normalAwards = ""
	self._addAwards = ""
	if options then
		self._normalAwards = options.normalAward or "" -- "11000001^147;11000002^1"
		self._addAwards = options.addAward or "" --"11000001^59;11000002^59"
	end

	self._isDone = false
	self._ccbOwner.frame_tf_title:setString("武魂战扫荡")
	self._ccbOwner.tf_one:setString("确 定")

	self:initScrollView()
end

function QUIDialogDragonWarFastBattle:viewDidAppear()
	QUIDialogDragonWarFastBattle.super.viewDidAppear(self)

	self:setAwardsInfo()
end

function QUIDialogDragonWarFastBattle:viewWillDisappear()
	QUIDialogDragonWarFastBattle.super.viewWillDisappear(self)
end

function QUIDialogDragonWarFastBattle:initScrollView()
	local contentSize = self._ccbOwner.sheet_layout:getContentSize()

	self._scrollView = QScrollView.new(self._ccbOwner.sheet, contentSize, {bufferMode = 1, sensitiveDistance = 10, isNoTouch = true})
	self._scrollView:setHorizontalBounce(false)
	self._scrollView:setVerticalBounce(true)

    self._scrollView:addEventListener(QScrollView.GESTURE_MOVING, handler(self, self._onScrollViewMoving))
    self._scrollView:addEventListener(QScrollView.GESTURE_BEGAN, handler(self, self._onScrollViewBegan))
end

function QUIDialogDragonWarFastBattle:setAwardsInfo()
	self._awards = {}
	self._awards[1] = {}

	local normalAwards = string.split(self._normalAwards, ";")
	local addAwards = string.split(self._addAwards, ";")
	for i = 1, 2 do
		if normalAwards[i] then
			local itemsInfo = string.split(normalAwards[i], "^")
			table.insert(self._awards[1], {id = itemsInfo[1], count = itemsInfo[2], title = "基础奖励" })
		end
		if addAwards[i] then
			local itemsInfo = string.split(addAwards[i], "^")
			table.insert(self._awards[1], {id = itemsInfo[1], count = itemsInfo[2], title = "伤害奖励" })
		end
	end 

	local row = 0
	self._totalWidth = 0
	self._totalHeight = 0
	local contentSize = CCSize(0, 0)

	for i = 1, #self._awards do
		local client = QUIWidgetDragonWarFastBattleClient.new()
		contentSize = client:getContentSize()
		local positionX = -3
		local positionY = -contentSize.height * row
		client:setPosition(ccp(positionX, positionY))
		self._scrollView:addItemBox(client)

		client:setClientInfo(self._awards[i])

		row = row + 1

		self._totalHeight = self._totalHeight + contentSize.height
		self._totalWidth = contentSize.width
	end

	self._scrollView:setRect(0, -self._totalHeight, 0, self._totalWidth)
 
	scheduler.performWithDelayGlobal(function()
			self:_autoMoveWithFinishedAnimation()
		end, 0.26)
end

function QUIDialogDragonWarFastBattle:_autoMoveWithFinishedAnimation()
    local ccbProxy = CCBProxy:create()
    local ccbOwner = {}

	local itemEffect = QUIWidgetAnimationPlayer.new()
    self._scrollView:addItemBox(itemEffect)
    itemEffect:setPosition(ccp(self._totalWidth/2, -self._totalHeight-70))
	itemEffect:playAnimation("ccb/effects/saodangwancheng.ccbi", function()
			self._isDone = true
		end, function()
		end, false)
	self._scrollView:setRect(0, -self._totalHeight, 0, self._totalWidth+70)
end

function QUIDialogDragonWarFastBattle:_onTriggerStop(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_stop) == false then return end
	self:_onTriggerClose()
end

function QUIDialogDragonWarFastBattle:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogDragonWarFastBattle:_onTriggerClose(event)
	-- if q.buttonEventShadow(event, self._ccbOwner.frame_btn_close) == false then return end
	app.sound:playSound("common_close")

	if self._isDone then
		self:playEffectOut()
	end
end

function QUIDialogDragonWarFastBattle:viewAnimationOutHandler()
	self:popSelf()
end


return QUIDialogDragonWarFastBattle