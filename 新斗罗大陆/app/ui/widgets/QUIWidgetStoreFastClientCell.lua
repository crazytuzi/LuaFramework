-- @Author: Kumo
-- 功能商店一键快速购买
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetStoreFastClientCell = class("QUIWidgetStoreFastClientCell", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")

function QUIWidgetStoreFastClientCell:ctor(options)
	local ccbFile = "ccb/Widget_EliteBattleAgain_yijiangoumai.ccbi"
	local callBack = {
		-- {ccbCallbackName = "", callback = handler(self, self._)},
	}
	QUIWidgetStoreFastClientCell.super.ctor(self, ccbFile, callBack, options)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self.hightOffset = 0
	self.itemOffset = 100
	self.line = 1
	self.row = 1
	self.itemBox = {}

	self:resetAll()
end

function QUIWidgetStoreFastClientCell:onEnter()
end

function QUIWidgetStoreFastClientCell:onExit()
end

function QUIWidgetStoreFastClientCell:resetAll()
	self._ccbOwner.node_have_item:setVisible(false)
	self._ccbOwner.node_no_item:setVisible(false)
	self._ccbOwner.node_all_item:setVisible(false)
	self._ccbOwner.node_done_effect:setVisible(false)
end

--state 1, 代表货币不足  2,代表钻石不足  3，代表刷新货币不足
function QUIWidgetStoreFastClientCell:setStopState(state)
	self._state = state 
	self._stopWord = "此次未刷新到目标货物"
	if state == 1 then
		self._stopWord = "购买停止，货币不足，无法购买指定道具"
	elseif state == 2 then 
		self._stopWord = "购买停止，钻石不足，无法购买指定道具"
	elseif state == 3 then
		self._stopWord = "购买停止，货币不足，无法刷新货物"
	end     
end

function QUIWidgetStoreFastClientCell:setInfo(shopId,items, index, currencyInfo, refreshMoney, refreshItemNum,buyToken, buyCurrency, isAll, callback)
	self.callback = callback
	if isAll == false then
		self._ccbOwner.tf_title:setString("第"..index.."次")
	else
		self._ccbOwner.tf_title:setString("已购买道具")
	end

	-- 第一次购买当前商店物品，刷新消耗默认为0	
	if index == 1 then
		refreshMoney = 0
	end

	-- sort item data
	local items = clone(items)
	local data = {}
	for _, value in pairs(items) do
		if value.id and value.id ~= 0 then
			if data[value.id] == nil then
				data[value.id] = value
			else
				data[value.id].count = data[value.id].count + value.count
			end
		elseif value.itemType then
			if data[value.itemType] == nil then
				data[value.itemType] = value
			else
				data[value.itemType].count = data[value.itemType].count + value.count
			end
		end
	end
	
	self.items = {}
	for _, value in pairs(data) do
		self.items[#self.items+1] = value
	end

	local itemNum = math.ceil(#self.items / 6)
	if itemNum > 1 then
		self.hightOffset = self.hightOffset + (self.itemOffset * (itemNum-1))
	end

	self._index = 1
	if self.items == nil or next(self.items) == nil then 
		self._ccbOwner.node_no_item:setVisible(true)
		self._ccbOwner.sp_no_item_icon:setVisible(true)

		if refreshMoney > 0 and index > 1 then
			self:setCurrencyIcon(self._ccbOwner.sp_no_item_icon, currencyInfo.alphaIcon)
			self._ccbOwner.tf_no_refresh_free:setString("")
			self._ccbOwner.no_item_refresh_num:setString(refreshMoney)
		else
			self._ccbOwner.tf_no_refresh_free:setString("免费")
			self._ccbOwner.no_item_refresh_num:setString("")
			self._ccbOwner.sp_no_item_icon:setVisible(false)
		end

		if shopId == SHOP_ID.soulShop and refreshItemNum > 0 then
			local items = QStaticDatabase:sharedDatabase():getItemByID(22)
			self:setCurrencyIcon(self._ccbOwner.sp_no_item_icon_1, items.icon_1)
			self._ccbOwner.no_item_refresh_num_1:setString(refreshItemNum or 0)

			self._ccbOwner.sp_no_item_icon_1:setVisible(true)
			self._ccbOwner.no_item_refresh_num_1:setVisible(true)

			self:setCurrencyIcon(self._ccbOwner.sp_no_item_icon, currencyInfo.alphaIcon)
			self._ccbOwner.tf_no_refresh_free:setString("")
			self._ccbOwner.no_item_refresh_num:setString(refreshMoney)
		else
			self._ccbOwner.sp_no_item_icon_1:setVisible(false)
			self._ccbOwner.no_item_refresh_num_1:setVisible(false)
		end

		if isAll then
			self.hightOffset = self.hightOffset + 150
			self._ccbOwner.node_done_effect:setVisible(true)
			self._ccbOwner.node_root:setPositionY(-150)
			if self._state ~= nil then
				self._ccbOwner.tf_no_item_special_stop:setString(self._stopWord)
			end
		end
	elseif isAll then
		self._ccbOwner.node_all_item:setVisible(true)
		self._ccbOwner.tf_refresh_num:setString((index-2).."次")

		local info = remote.items:getWalletByType("token")
		self:setCurrencyIcon(self._ccbOwner.sp_all_item_icon1, info.alphaIcon)
		self._ccbOwner.tf_all_item_icon1:setString(buyToken or 0)

		self:setCurrencyIcon(self._ccbOwner.sp_all_item_icon2, currencyInfo.alphaIcon)
		self._ccbOwner.tf_all_item_icon2:setString(buyCurrency or 0)

		if shopId == SHOP_ID.soulShop and refreshItemNum > 0 then
			local items = QStaticDatabase:sharedDatabase():getItemByID(22)
			self:setCurrencyIcon(self._ccbOwner.sp_all_item_icon3, items.icon_1)
			self._ccbOwner.tf_all_item_icon3:setString(refreshItemNum or 0)
			self._ccbOwner.node_all_item3:setVisible(true)
		else
			self._ccbOwner.node_all_item3:setVisible(false)
		end

		self.hightOffset = self.hightOffset + 150
		self._ccbOwner.node_done_effect:setVisible(true)
		self._ccbOwner.node_root:setPositionY(-150)

		self._ccbOwner.tf_special_stop:setString("")
		if self._state ~= nil then
			self.hightOffset = self.hightOffset + 30
			self._ccbOwner.tf_special_stop:setString(self._stopWord)
        	self._ccbOwner.tf_special_stop:setVisible(false)

        	local offsetY = (self.itemOffset * (itemNum-1))
			self._ccbOwner.tf_special_stop:setPositionY(-141-offsetY)
		end
	else
		self._ccbOwner.tf_have_refresh_free:setVisible(false)
		self._ccbOwner.node_have_item:setVisible(true)
		self._ccbOwner.sp_have_refresh_icon:setVisible(true)
		self:setCurrencyIcon(self._ccbOwner.sp_have_refresh_icon, currencyInfo.alphaIcon)

		if refreshMoney > 0 then
			self:setCurrencyIcon(self._ccbOwner.sp_no_item_icon, currencyInfo.alphaIcon)
			self._ccbOwner.tf_have_refresh_num:setString(refreshMoney)
		else
			self._ccbOwner.sp_have_refresh_icon:setVisible(false)
			self._ccbOwner.tf_have_refresh_num:setString("")
			self._ccbOwner.tf_have_refresh_free:setVisible(true)
		end

		if shopId == SHOP_ID.soulShop and refreshItemNum > 0 then
			local items = QStaticDatabase:sharedDatabase():getItemByID(22)
			self:setCurrencyIcon(self._ccbOwner.sp_have_refresh_icon_1, items.icon_1)
			self._ccbOwner.tf_have_refresh_num_1:setString(refreshItemNum or 0)

			self._ccbOwner.sp_have_refresh_icon_1:setVisible(true)
			self._ccbOwner.tf_have_refresh_num_1:setVisible(true)

			self:setCurrencyIcon(self._ccbOwner.sp_have_refresh_icon, currencyInfo.alphaIcon)
			self._ccbOwner.tf_no_refresh_free:setString("")
			self._ccbOwner.no_item_refresh_num:setString(0)
		else
			self._ccbOwner.sp_have_refresh_icon_1:setVisible(false)
			self._ccbOwner.tf_have_refresh_num_1:setVisible(false)
		end

		local info = remote.items:getWalletByType("token")
		self:setCurrencyIcon(self._ccbOwner.sp_have_buy_icon1, info.alphaIcon)
		self._ccbOwner.tf_have_buy1:setString(buyToken)

		self:setCurrencyIcon(self._ccbOwner.sp_have_buy_icon2, currencyInfo.alphaIcon)
		self._ccbOwner.tf_have_buy2:setString(buyCurrency)

		-- self:setItemBox()
	end

	-- set refresh info
	return self.items
end

function QUIWidgetStoreFastClientCell:setItemBox()
	if self.items == nil or next(self.items) == nil then
    	if self.callback then
    		self.callback()
    	end
    else
		self.itemBox[self._index] = QUIWidgetItemsBox.new()
		self._ccbOwner.node_item:addChild(self.itemBox[self._index])

		local positionX = self.itemOffset * (self.line-1)
		local positionY = self.itemOffset * (self.row-1)

		self.itemBox[self._index]:setPosition(ccp(positionX, -positionY))
		self.itemBox[self._index]:setGoodsInfo(self.items[self._index].id, self.items[self._index].itemType, self.items[self._index].count)
		self.itemBox[self._index]:setScaleX(0)
		self.itemBox[self._index]:setScaleY(0)

		if self.line % 6 == 0 then
			self.line = 1
			self.row = self.row + 1
		else
			self.line = self.line + 1
		end

	    local actionArrayIn = CCArray:create()
	    actionArrayIn:addObject(CCEaseBackInOut:create(CCScaleTo:create(0.11, 1, 1)))
	    actionArrayIn:addObject(CCCallFunc:create(function ()
	    	self._index = self._index + 1
	    	if self.items[self._index] then
	        	self:setItemBox()
	        else
        		self._ccbOwner.tf_special_stop:setVisible(true)
	        	if self.callback then
	        		self.callback()
	        	end
	    	end
	    end))
		local handler = self.itemBox[self._index]:runAction(CCSequence:create(actionArrayIn))
	end
end	

function QUIWidgetStoreFastClientCell:setCurrencyIcon(node, iconPath)
	if node == nil or iconPath == nil then return end

	local icon = CCTextureCache:sharedTextureCache():addImage(iconPath)
	if icon then
		node:setTexture(icon)
	end
end

function QUIWidgetStoreFastClientCell:setItemPrompt()
	if self.itemBox == nil or next(self.itemBox) == nil then return end

	for _, value in pairs(self.itemBox) do
		value:setPromptIsOpen(true)
	end
end

function QUIWidgetStoreFastClientCell:getContentSize()
	local contentSize = self._ccbOwner.node_size:getContentSize()
	
	return CCSize(contentSize.width, contentSize.height+self.hightOffset)
end


return QUIWidgetStoreFastClientCell