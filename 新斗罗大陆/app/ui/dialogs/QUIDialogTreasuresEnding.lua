--
-- Kumo.Wang
-- 资源夺宝转盘结束后展示奖励
--

local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogTreasuresEnding = class("QUIDialogTreasuresEnding", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QQuickWay = import("...utils.QQuickWay")
local QListView = import("...views.QListView")

local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")

function QUIDialogTreasuresEnding:ctor(options)
	local ccbFile = "ccb/Dialog_Treasures_Ending.ccbi"
	local callBack = {
        {ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
        {ccbCallbackName = "onTriggerOK", callback = handler(self, self._onTriggerOK)},
        {ccbCallbackName = "onTriggerGoon", callback = handler(self, self._onTriggerGoon)},
	}
	QUIDialogTreasuresEnding.super.ctor(self, ccbFile, callBack, options)

	self._ccbOwner.frame_tf_title:setString("夺得奖励")

    q.setButtonEnableShadow(self._ccbOwner.btn_ok)
    q.setButtonEnableShadow(self._ccbOwner.btn_goon)

    if options then
    	self._awards = options.awards
    	self._playCount = options.playCount
    	self._callback = options.callback
	end

	self.isAnimation = true --是否动画显示

    self._resourceTreasuresModule = remote.activityRounds:getRoundInfoByType(remote.activityRounds.LuckyType.RESOURCE_TREASURES)

    self:_init()
end

function QUIDialogTreasuresEnding:viewDidAppear()
	QUIDialogTreasuresEnding.super.viewDidAppear(self)
end

function QUIDialogTreasuresEnding:viewWillDisappear()
	QUIDialogTreasuresEnding.super.viewWillDisappear(self)
end

function QUIDialogTreasuresEnding:_init()
	self._rewardBoxList = {}

	self:_updateBtnView()
	self:_updateRewards()
end

function QUIDialogTreasuresEnding:_updateBtnView()
	if not self._priceItemId or not self._priceItemCount then
		local config = db:getConfigurationValue("treasure_cost")
		local tbl = string.split(config, ",")
	    if not q.isEmpty(tbl) then
	        self._priceItemId = tbl[1]
	        self._priceItemCount = tonumber(tbl[2])
	    end
   	end

   	local itemConfig = db:getItemByID(self._priceItemId)
   	local haveNum = remote.items:getItemsNumByID(self._priceItemId)
   	if not q.isEmpty(itemConfig) then
   		self._ccbOwner.node_price_goon:setVisible(true)
		if not QSetDisplayFrameByPath(self._ccbOwner.sp_price_goon, itemConfig.icon_1 or itemConfig.icon) then
			QSetDisplaySpriteByPath(self._ccbOwner.sp_price_goon, itemConfig.icon_1 or itemConfig.icon)
		end
		self._ccbOwner.tf_price_goon:setString((self._priceItemCount * self._playCount).." / "..haveNum)
	end

	self._ccbOwner.node_btn_goon:setVisible(true)
	self._ccbOwner.tf_btn_goon:setString("继续夺宝")
end

function QUIDialogTreasuresEnding:_updateRewards()
	for _, info in ipairs(self._awards) do
		local itemsBox = QUIWidgetItemsBox.new()
    	itemsBox:setPromptIsOpen(true)
    	itemsBox:setGoodsInfo(info.id, info.type, info.count)
    	table.insert(self._rewardBoxList, itemsBox)
    	self._ccbOwner.node_rewards_list:addChild(itemsBox)
	end

	self:_updateRewardBoxView()
end

function QUIDialogTreasuresEnding:_updateRewardBoxView()
	if q.isEmpty(self._rewardBoxList) then return end
	for index, box in pairs(self._rewardBoxList) do
		local size = box:getContentSize()
		box:setPosition((size.width + 10) * (index - 1), 0)
	end
	self._ccbOwner.node_rewards_list:setPosition(-(#self._rewardBoxList - 1) * 45, 45)
end

function QUIDialogTreasuresEnding:_onTriggerOK()
	app.sound:playSound("common_small")
	self:_onTriggerClose()
end

function QUIDialogTreasuresEnding:_onTriggerGoon()
	app.sound:playSound("common_small")
	self._isGoon = true
	self:_onTriggerClose()
end

function QUIDialogTreasuresEnding:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogTreasuresEnding:_onTriggerClose(e)
	if q.buttonEventShadow(e, self._ccbOwner.frame_btn_close) == false then return end
	if e then
		app.sound:playSound("common_small")
	end
	self:playEffectOut()
end

function QUIDialogTreasuresEnding:viewAnimationOutHandler()
	local callback = nil
	local playCount = nil
	if self._isGoon then
		callback = self._callback
		playCount = self._playCount
	end

    app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_SPECIFIC_CONTROLLER, nil, self)

    if callback then
    	callback(playCount)
    end
end

return QUIDialogTreasuresEnding