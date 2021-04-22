--
-- Author: Kumo
-- Date: 2014-07-14 15:41:41
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetSecretaryLog = class("QUIWidgetSecretaryLog", QUIWidget)

local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")

local CELL_WIDTH = 92
local CELL_HEIGHT = 100
local ITEM_SCALE = 0.9
local DESC_MAX_WIDTH = 550

function QUIWidgetSecretaryLog:ctor(options)
	local ccbFile = "ccb/Widget_Secretary_log.ccbi"
	local callbacks = {}
	QUIWidgetSecretaryLog.super.ctor(self, ccbFile, callbacks, options)

	self:resetData()
end

function QUIWidgetSecretaryLog:resetData()
	self._itemsBox = {}
	self._ccbOwner.tf_title1:setString("")
	self._ccbOwner.tf_title2:setString("")
	self._cellHeight = self._ccbOwner.node_size:getContentSize().height
	self._ccbOwner.goods:removeAllChildren()
	self._ccbOwner.node_cost:setVisible(false)
end

function QUIWidgetSecretaryLog:getContentSize()
	local size = self._ccbOwner.node_size:getContentSize()
	size.height = self._cellHeight
	return size
end

function QUIWidgetSecretaryLog:setInfo(info)
	self:resetData()
	local dis_between = 30
	self._ccbOwner.tf_title1:setString(info.title2 or "")
	local desc_width = self._ccbOwner.tf_title1:getContentSize().width
	local desc_height = 0
	
	self._ccbOwner.tf_title1:setString(info.title1 or "")
	self._ccbOwner.tf_title2:setString(info.title2 or "")

	-- 描述文字多出一行
	local titleHeight = 0
	local height = self._ccbOwner.tf_title2:getContentSize().height
	if height > 30 then
		titleHeight = 30
	elseif height > 60 then
		titleHeight = 60
	end
	if desc_width > DESC_MAX_WIDTH then
		desc_width = desc_width%DESC_MAX_WIDTH + 20
	end

	local taskId = info.taskId or 0
	local config = remote.secretary:getMySecretaryConfigById(taskId)
	if config and config.showResource then
	 	self._ccbOwner.node_cost:setVisible(true)
	 	self._ccbOwner.tf_money:setVisible(false)
	 	self._ccbOwner.sp_money:setVisible(false)
	 	self._ccbOwner.tf_token:setVisible(false)
	 	self._ccbOwner.sp_token:setVisible(false)
	 	self._ccbOwner.sp_money_1:setVisible(false)
	 	self._ccbOwner.tf_money_1:setVisible(false)
	 	if info.token and info.token > 0 then
		 	self._ccbOwner.tf_token:setVisible(true)
		 	self._ccbOwner.sp_token:setVisible(true)
	 		self._ccbOwner.tf_token:setString(info.token or 0)
	 		desc_width = desc_width + self._ccbOwner.sp_token:getContentSize().width * 0.5 + 10
	 		self._ccbOwner.sp_token:setPositionX(desc_width)
	 		self._ccbOwner.sp_token:setPositionY(-(55 + titleHeight))
	 		desc_width = desc_width + dis_between
	 		self._ccbOwner.tf_token:setPositionX(desc_width)
	 		self._ccbOwner.tf_token:setPositionY(-(55 + titleHeight))
	 		desc_width = self._ccbOwner.tf_token:getContentSize().width  + desc_width
	 	end
	 	if info.money and info.money > 0 then
		 	self._ccbOwner.tf_money:setVisible(true)
		 	self._ccbOwner.sp_money:setVisible(true)
		 	self._ccbOwner.tf_money:setString(info.money or 0)
		 	local iconPath = remote.items:getWalletByType(config.resourceType).alphaIcon
		 	self._ccbOwner.sp_money:setTexture(CCTextureCache:sharedTextureCache():addImage(iconPath))

	 		desc_width = desc_width + self._ccbOwner.sp_money:getContentSize().width * 0.5 + 10
	 		self._ccbOwner.sp_money:setPositionX(desc_width)
	 		self._ccbOwner.sp_money:setPositionY(-(55 + titleHeight))
	 		desc_width = desc_width + dis_between
	 		self._ccbOwner.tf_money:setPositionX(desc_width)
	 		self._ccbOwner.tf_money:setPositionY(-(55 + titleHeight))
	 		desc_width = self._ccbOwner.tf_money:getContentSize().width  + desc_width		 	
	 	end
	 	if info.money_1 and info.money_1 > 0 then
		 	self._ccbOwner.tf_money_1:setVisible(true)
		 	self._ccbOwner.sp_money_1:setVisible(true)
			local items = QStaticDatabase:sharedDatabase():getItemByID(22)
		 	self._ccbOwner.tf_money_1:setString(info.money_1 or 0)
			if items and items.icon_1 then
		 		self._ccbOwner.sp_money_1:setTexture(CCTextureCache:sharedTextureCache():addImage(items.icon_1))
		 	end
	 		desc_width = desc_width + self._ccbOwner.sp_money_1:getContentSize().width * 0.5 + 10
	 		self._ccbOwner.sp_money_1:setPositionX(desc_width)
	 		desc_width = desc_width + dis_between
	 		self._ccbOwner.tf_money_1:setPositionX(desc_width)
	 		desc_width = self._ccbOwner.tf_money_1:getContentSize().width  + desc_width	

	 	end	 	
	end

	local awards = info.awards or {}
	local index = 0
	for _, value in pairs(awards) do
		local item = QUIWidgetItemsBox.new({ccb = "small"})
		item:setGoodsInfo(value.id, value.typeName, value.count)
		item:setVisible(false)
		item:setPromptIsOpen(true)

		local itemType = remote.items:getItemType(value.typeName)
		if itemType == ITEM_TYPE.HERO or itemType == ITEM_TYPE.GEMSTONE or itemType == ITEM_TYPE.ZUOQI then
			item:showBoxEffect("effects/Auto_Skill_light.ccbi", true)
		elseif itemType == ITEM_TYPE.ITEM then
			local itemInfo = db:getItemByID(value.id)
			if itemInfo.highlight == 1 or itemInfo.type == ITEM_CONFIG_TYPE.GEMSTONE then
				item:showBoxEffect("effects/Auto_Skill_light.ccbi", true, 0, -5, 1.2)
			end
		elseif itemType == ITEM_TYPE.PRIZE_WHEEL_MONEY then
			item:setAwardName("活动")
		end

		local posX = (index%6)*CELL_WIDTH
		local posY = (math.floor(index/6))*CELL_HEIGHT+titleHeight
		item:setPosition(ccp(posX, -posY))
		self._ccbOwner.goods:addChild(item)

		index = index + 1
		self._itemsBox[index] = item
	end

	local itemRows = math.floor((index-1)/6) + 1
	self._cellHeight = self._cellHeight + itemRows * CELL_HEIGHT + titleHeight 
	self:_startPlayItemAnimation()
end

function QUIWidgetSecretaryLog:registerItemBoxPrompt( index, list )
	-- body
	for k, v in pairs(self._itemsBox) do
		list:registerItemBoxPrompt(index, k, v)
	end
end

function QUIWidgetSecretaryLog:_startPlayItemAnimation()
	if #self._itemsBox == 0 then
		if self._animationEndCallback ~= nil then
			self._animationEndCallback()
		end
	else
		self:_playItemAnimation(1)
	end
end

function QUIWidgetSecretaryLog:_playItemAnimation(index)
	if #self._itemsBox < index then
		if self._yieldAnimation ~= nil then
			self._yieldAnimation:setVisible(true)
		end
		if self._animationEndCallback ~= nil then
			self._animationEndCallback()
		end
	else
		local widgetItem = self._itemsBox[index]
		widgetItem:setVisible(true)
		widgetItem:setScaleX(0)
		widgetItem:setScaleY(0)
	    local actionArrayIn = CCArray:create()
        actionArrayIn:addObject(CCEaseBackInOut:create(CCScaleTo:create(0.02, ITEM_SCALE, ITEM_SCALE)))
        actionArrayIn:addObject(CCCallFunc:create(function ()
	        self:_playItemAnimation(index + 1)
        end))
	    local ccsequence = CCSequence:create(actionArrayIn)
		widgetItem:runAction(ccsequence)
	end
end

return QUIWidgetSecretaryLog