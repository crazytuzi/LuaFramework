--
-- Author: xurui
-- Date: 2015-08-11 17:11:45
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetThunderRewardPreviewClient = class("QUIWidgetThunderRewardPreviewClient", QUIWidget)

local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox") 
local QStaticDatabase = import("...controllers.QStaticDatabase")

function QUIWidgetThunderRewardPreviewClient:ctor(options)
	local ccbFile = "ccb/Widget_ThunderKing_Reward_Client.ccbi"
	local callBacks = {}
	QUIWidgetThunderRewardPreviewClient.super.ctor(self, ccbFile, callBacks, options)

	if options ~= nil then
		self._starNum = options.star
	end
	self._ccbOwner.star_num:setString((self._starNum * 3) or 1)
end

function QUIWidgetThunderRewardPreviewClient:onEnter()
    self.prompt = app:promptTips()
    self.prompt:addItemEventListener(self)
end

function QUIWidgetThunderRewardPreviewClient:onExit()
   	if self.prompt ~= nil then
   		self.prompt:removeItemEventListener()
   	end
end 

function QUIWidgetThunderRewardPreviewClient:setItems(layer)
	if layer == nil then return end
	local rewards = QStaticDatabase:sharedDatabase():getLuckyDraw(layer)

	local index = 1
	while rewards["id_"..index] ~= nil or rewards["type_"..index] ~= nil do
		local item = QUIWidgetItemsBox.new()
		item:setGoodsInfo(rewards["id_"..index], rewards["type_"..index], rewards["num_"..index])
		self._ccbOwner["item_node"..index]:addChild(item)
		item:setPromptIsOpen(true)
		index = index + 1
	end
end

function QUIWidgetThunderRewardPreviewClient:getContentSize()
	return self._ccbOwner.normal_banner:getContentSize()
end 

return QUIWidgetThunderRewardPreviewClient