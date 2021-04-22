--
-- Author: Your Name
-- Date: 2014-11-24 16:39:45
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetAchievementItem = class("QUIWidgetAchievementItem", QUIWidget)

local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QStaticDatabase = import("...controllers.QStaticDatabase")

QUIWidgetAchievementItem.EVENT_CLICK = "EVENT_CLICK"

function QUIWidgetAchievementItem:ctor(options)
	local ccbFile = "ccb/Widget_Achievement_client.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClick",  callback = handler(self, QUIWidgetAchievementItem._onTriggerClick)},
	}

	QUIWidgetAchievementItem.super.ctor(self, ccbFile, callBacks, options)
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	-- setShadow5(self._ccbOwner.tf_name)
	-- setShadow5(self._ccbOwner.tf_desc)

	self._iconSize = self._ccbOwner.box_icon:getContentSize()
	self:setColor("normal")
end

function QUIWidgetAchievementItem:setInfo(info)
	self._achieveInfo = info
	self:resetAll()

	if self._achieveInfo.state == remote.achieve.MISSION_DONE then
		self._ccbOwner.done_banner:setVisible(true)
		self._ccbOwner.sp_done:setVisible(true)
		self._ccbOwner.box_sp_end:setVisible(true)
		self._ccbOwner.sp_title_done:setVisible(true)
		self._ccbOwner.sp_title_normal:setVisible(false)
	else
		self._ccbOwner.normal_banner:setVisible(true)
		if self._achieveInfo.state == remote.achieve.MISSION_COMPLETE then
			self._ccbOwner.sp_complete:setVisible(true)
			self._ccbOwner.box_sp_end:setVisible(true)
		else
			self._ccbOwner.node_progress:setVisible(true)
			local totalNum = self._achieveInfo.config.num
			local stepNum = self._achieveInfo.stepNum
			if totalNum > 100000 then
				totalNum = math.floor(totalNum/10000).."万"
			end
			if stepNum > 100000 then
				stepNum = math.floor(stepNum/10000).."万"
			end
			self._ccbOwner.tf_progress:setString(stepNum.."/"..totalNum)
		end
	end
	self._ccbOwner.tf_name:setString(self._achieveInfo.config.name)
	self._ccbOwner.tf_desc:setString(self._achieveInfo.config.desc)

	self._positionX = -135.0
	self._gap = 10
	local typeName1 = remote.items:getItemType(self._achieveInfo.config.type_1)
	local typeName2 = remote.items:getItemType(self._achieveInfo.config.type_2)
	self:setIconInfo(typeName1, self._achieveInfo.config.num_1, self._achieveInfo.config.id_1, 1)
	self:setIconInfo(typeName2, self._achieveInfo.config.num_2, self._achieveInfo.config.id_2, 2)
	self:setIconInfo(ITEM_TYPE.ACHIEVE_POINT, self._achieveInfo.config.count, self._achieveInfo.config.id_3, 3)

	self:showAchievementInfo()
	local icon = self._achieveInfo.config.icon
	if icon ~= nil and icon ~= "" then
		local texture = CCTextureCache:sharedTextureCache():addImage(icon)
		self._ccbOwner.box_icon:setTexture(texture)
		self._ccbOwner.box_icon:setVisible(true)
		local size = texture:getContentSize()
		local rect = CCRectMake(0, 0, size.width, size.height)
		self._ccbOwner.box_icon:setTextureRect(rect)
		self._ccbOwner.box_icon:setScale(self._iconSize.width/size.width)

		local typeName = self._achieveInfo.config.type_1
		local wallet = remote.items:getWalletByType(typeName)
		if wallet then
			self:setColor(EQUIPMENT_QUALITY[wallet.colour])
		else
			local id = self._achieveInfo.config.id_1
			if typeName and id then
				local itemConfig = QStaticDatabase:sharedDatabase():getItemByID(id)
				if itemConfig then
					self:setColor(EQUIPMENT_QUALITY[itemConfig.colour] or "normal")
				end
			else
				self:setColor("normal")
			end
		end
	end
end

function QUIWidgetAchievementItem:setColor(name)
	-- print("[Kumo] setColor ", name)
	self:hideAllColor()
	if name ~= nil then
		self:setNodeVisible(self._ccbOwner["node_"..name],true)
	else
		-- printInfo("item id : "..self._itemID.." color name is nil!")
		self:setNodeVisible(self._ccbOwner["node_normal"],true)
	end
end

function QUIWidgetAchievementItem:hideAllColor()
	self:setNodeVisible(self._ccbOwner.node_green,false)
	self:setNodeVisible(self._ccbOwner.node_blue,false)
	self:setNodeVisible(self._ccbOwner.node_orange,false)
	self:setNodeVisible(self._ccbOwner.node_purple,false)
	self:setNodeVisible(self._ccbOwner.node_white,false)
end

function QUIWidgetAchievementItem:setNodeVisible(node,b)
	if node ~= nil then
		node:setVisible(b)
	end
end

function QUIWidgetAchievementItem:setIconInfo(itemType, value, id, index)
	if index > 3 then return end
	local respath = nil
	if itemType ~= nil and value ~= nil then
		if itemType == ITEM_TYPE.ITEM then
			local itemInfo = QStaticDatabase:sharedDatabase():getItemByID(id)
			respath = itemInfo.icon
		else
			respath = remote.items:getURLForItem(itemType, "alphaIcon")
		end
	end

	if respath ~= nil then
		local icon = nil
		if itemType == ITEM_TYPE.ITEM then
			icon = QUIWidgetItemsBox.new()
			icon:setGoodsInfo(id, ITEM_TYPE.ITEM, 0)
		else
			icon = CCSprite:create()
			icon:setScale(1.6)
			icon:setTexture(CCTextureCache:sharedTextureCache():addImage(respath))
		end
		self._ccbOwner["sp_icon"..index]:removeAllChildren()
		self._ccbOwner["sp_icon"..index]:setVisible(true)
		self._ccbOwner["sp_icon"..index]:addChild(icon)

		self._positionX = self._positionX + self._ccbOwner["sp_icon"..index]:getScaleX() * icon:getContentSize().width/2 
		self._ccbOwner["sp_icon"..index]:setPositionX(self._positionX)
		self._positionX = self._positionX + self._ccbOwner["sp_icon"..index]:getScaleX() * icon:getContentSize().width/2 + self._gap
	end

	if value ~= nil then
		self._ccbOwner["tf_value"..index]:setString("x "..value)
		self._ccbOwner["tf_value"..index]:setPositionX(self._positionX)
		self._positionX = self._positionX + self._ccbOwner["tf_value"..index]:getContentSize().width + self._gap
	end
end

function QUIWidgetAchievementItem:resetAll()
	self._ccbOwner.normal_banner:setVisible(false)
	self._ccbOwner.done_banner:setVisible(false)
	self._ccbOwner.sp_title_done:setVisible(false)
	self._ccbOwner.sp_title_normal:setVisible(true)
	self._ccbOwner.sp_icon1:setVisible(false)
	self._ccbOwner.sp_icon2:setVisible(false)
	self._ccbOwner.sp_icon3:setVisible(false)
	self._ccbOwner.sp_done:setVisible(false)
	self._ccbOwner.sp_complete:setVisible(false)
	self._ccbOwner.box_sp_end:setVisible(false)
	self._ccbOwner.tf_name:setString("")
	self._ccbOwner.tf_desc:setString("")
	self._ccbOwner.tf_value1:setString("")
	self._ccbOwner.tf_value2:setString("")
	self._ccbOwner.tf_value3:setString("")
	self._ccbOwner.tf_deal_num:setString("")
	self._ccbOwner.node_progress:setVisible(false)
end

--[[
	根据不同的任务显示不同的东西
]]
function QUIWidgetAchievementItem:showAchievementInfo()
	if self._achieveInfo.state == remote.achieve.MISSION_DONE or self._achieveInfo.state == remote.achieve.MISSION_COMPLETE then
		return 
	end
	if self._achieveInfo.config.tip ~= nil then
		self._ccbOwner.tf_deal_num:setString(self._achieveInfo.config.tip)
	else
		self._ccbOwner.tf_deal_num:setString(self._achieveInfo.stepNum.."/"..self._achieveInfo.config.num)
	end
end

function QUIWidgetAchievementItem:_onTriggerClick()
	self:dispatchEvent({name = QUIWidgetAchievementItem.EVENT_CLICK, index = self._achieveInfo.config.index})
end

function QUIWidgetAchievementItem:getContentSize()
	return self._ccbOwner.node_size:getContentSize()
end

return QUIWidgetAchievementItem