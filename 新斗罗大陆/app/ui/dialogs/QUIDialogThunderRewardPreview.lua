--
-- Author: xurui
-- Date: 2015-08-11 16:46:52
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogThunderRewardPreview = class("QUIDialogThunderRewardPreview", QUIDialog)

local QUIWidgetThunderRewardPreviewClient = import("..widgets.QUIWidgetThunderRewardPreviewClient")
local QScrollView = import("...views.QScrollView") 
local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")

function QUIDialogThunderRewardPreview:ctor(options)
	local ccbFile = "ccb/Dialog_ThunderKing_Reward.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
	}
	QUIDialogThunderRewardPreview.super.ctor(self, ccbFile, callBacks, options)
	self.isAnimation = true

	self._ccbOwner.frame_tf_title:setString("奖励预览")
	local thunderInfo = remote.thunder:getThunderFighter()
	self._floor = tonumber(options.floor)
	self._currentStar = thunderInfo.thunderCurrentFloorStar

	self._totalHeight = 0

	self._itemWidth = self._ccbOwner.sheet_layout:getContentSize().width
	self._itemHeight = self._ccbOwner.sheet_layout:getContentSize().height
	self._scrollView = QScrollView.new(self._ccbOwner.sheet, CCSize(self._itemWidth, self._itemHeight), {sensitiveDistance = 10})
	self._scrollView:setVerticalBounce(true)
    self._scrollView:addEventListener(QScrollView.GESTURE_MOVING, handler(self, self._onScrollViewMoving))

	self:setRewards()
	self:setStar()
end

function QUIDialogThunderRewardPreview:viewDidAppear()
	QUIDialogThunderRewardPreview.super.viewDidAppear(self)
end 

function QUIDialogThunderRewardPreview:viewWillDisappear()
	QUIDialogThunderRewardPreview.super.viewWillDisappear(self)
end

function QUIDialogThunderRewardPreview:setRewards()
	local rewardIndexs = QStaticDatabase:sharedDatabase():getThunderConfigByLayer(self._floor)

	self.rewardClients = {}
	local lineDistance = 0
	local index = 3
	for i = 1, 3, 1 do
		local rewardClient = QUIWidgetThunderRewardPreviewClient.new({star = index})
		self._scrollView:addItemBox(rewardClient)
		rewardClient:setItems(rewardIndexs["box_star"..(index * 3)])

		local content = rewardClient:getContentSize()
		local positionY = (content.height + lineDistance) * (i - 1)
		rewardClient:setPosition(ccp(3, -positionY))
		self._totalHeight = self._totalHeight + content.height + lineDistance

		table.insert(self.rewardClients, rewardClient) 
		index = index - 1
	end

	self._scrollView:setRect(0, -self._totalHeight, 0, self._itemWidth)
end

function QUIDialogThunderRewardPreview:setStar()
	self._ccbOwner.currentStar:setString(self._currentStar or 0)
	self._ccbOwner.level:setString(((self._floor-1) * 3 + 1).."-"..(self._floor * 3))
end 

function QUIDialogThunderRewardPreview:_onScrollViewMoving(event)
	if event.name == QScrollView.GESTURE_MOVING then
		self.isMoving = true
		for _, value in pairs(self.rewardClients) do
			if value.prompt ~= nil then
   				value.prompt:stopMonsterPrompt()
   			end
		end
	elseif event.name == QScrollView.GESTURE_END then
		self.isMoving = false
	end
end

function QUIDialogThunderRewardPreview:_backClickHandler()
	 self:_onTriggerClose()
end

function QUIDialogThunderRewardPreview:_onTriggerClose()
	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogThunderRewardPreview:viewAnimationOutHandler()
	app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
end

return QUIDialogThunderRewardPreview