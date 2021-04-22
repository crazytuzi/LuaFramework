--
-- Author: Kumo.Wang
-- 宗门红包普通奖励获得界面
--

local QUIDialog = import(".QUIDialog")
local QUIDialogRedpacketAchievementReward = class("QUIDialogRedpacketAchievementReward", QUIDialog)
local QNavigationController = import("...controllers.QNavigationController")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")

function QUIDialogRedpacketAchievementReward:ctor(options)
	local ccbFile = "ccb/Dialog_Society_Redpacket_Reward.ccbi"
	local callBacks = {}
	QUIDialogRedpacketAchievementReward.super.ctor(self, ccbFile, callBacks, options)
	self.isAnimation = true
    -- local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    -- page.topBar:setAllSound(false)

	local config = options.config
	local index = 1
	while true do
		local node = self._ccbOwner["node_item_"..index]
		if node then
			node:removeAllChildren()
			index = index + 1
		else
			break
		end
	end
	if config.lucky_draw then
		local id, typeName, count = remote.redpacket:getLuckyDrawItemInfoById(config.lucky_draw)
		local itemBox = QUIWidgetItemsBox.new()
		itemBox:setPromptIsOpen(true)
		itemBox:setGoodsInfo(id, typeName, count)
		self._ccbOwner.node_item_1:addChild(itemBox)
		self._ccbOwner.node_item_1:setVisible(true)
	end
end

function QUIDialogRedpacketAchievementReward:viewDidAppear()
	QUIDialogRedpacketAchievementReward.super.viewDidAppear(self)
end 

function QUIDialogRedpacketAchievementReward:viewWillDisappear()
	QUIDialogRedpacketAchievementReward.super.viewWillDisappear(self)
end 

function QUIDialogRedpacketAchievementReward:_backClickHandler()
	self:_onTriggerClose()
end

function QUIDialogRedpacketAchievementReward:_onTriggerClose()
	app.sound:playSound("common_cancel")
   	self:playEffectOut()
end

function QUIDialogRedpacketAchievementReward:viewAnimationOutHandler()
	app:getNavigationManager():popViewController(app.topLayer, QNavigationController.POP_TOP_CONTROLLER)
end

return QUIDialogRedpacketAchievementReward
