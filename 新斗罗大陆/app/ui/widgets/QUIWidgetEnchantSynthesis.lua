-- @Author: liaoxianbo
-- @Date:   2020-09-21 14:35:39
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-09-24 12:17:59
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetEnchantSynthesis = class("QUIWidgetEnchantSynthesis", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QListView = import("...views.QListView")
local QUIWidgetItemsBox = import(".QUIWidgetItemsBox")
local QUIWidgetQlistviewItem = import(".QUIWidgetQlistviewItem")

QUIWidgetEnchantSynthesis.EVENT_ENCHANT_MADE ="EVENT_ENCHANT_MADE"

function QUIWidgetEnchantSynthesis:ctor(options)
	local ccbFile = "ccb/Widget_HighTea_Menu.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
    }
    QUIWidgetEnchantSynthesis.super.ctor(self, ccbFile, callBacks, options)
  
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._ccbOwner.sp_title_normal:setVisible(false)

	self._ccbOwner.tf_ok:setString("合 成")
	self._canMake = false
end

function QUIWidgetEnchantSynthesis:onEnter()
end

function QUIWidgetEnchantSynthesis:onExit()
end

function QUIWidgetEnchantSynthesis:setInfo(info)
	self._info = info
	self:_handleData()
	self:_initListView()

	local haveNum = remote.items:getItemsNumByID(self._info.resource_item_1)
	self._canMake = haveNum >= self._info.resource_number_1 

	if self._canMake then
		makeNodeFromGrayToNormal(self._ccbOwner.node_btn)
	else
		makeNodeFromNormalToGray(self._ccbOwner.node_btn)
	end

end

function QUIWidgetEnchantSynthesis:_handleData()
	local config = remote.activity:getHighTeaFoodConfigById(id)
	self._awards = {}

	table.insert(self._awards, {oType = "item", id = self._info.resource_item_1, typeName = self._info.resource_1, count = self._info.resource_number_1 or 0 ,isSynthesis = false,isNeedShowItemCount = true})
	table.insert(self._awards, {oType = "equal", id = QResPath("sp_new_word_equal"), width = 30,scale = 1})
	table.insert(self._awards, {oType = "item", id = self._info.item_id, typeName = self._info.item_type, count = 1,isSynthesis = true})

end


function QUIWidgetEnchantSynthesis:_initListView()
	if not self._listView then
		local function showItemInfo(x, y, itemBox, listView)
			app.tip:itemTip(itemBox._itemType, itemBox._itemID, true)
		end
		local cfg = {
	        renderItemCallBack = function( list, index, info )
	            local isCacheNode = true
	          	local data = self._awards[index]
	            local item = list:getItemFromCache()
	            if not item then
	                item = QUIWidgetQlistviewItem.new()
	                isCacheNode = false
	            end
	            self:setItemInfo(item, data, index)
	            info.item = item
				info.size = item._ccbOwner.parentNode:getContentSize()
				
				--注册事件
                list:registerItemBoxPrompt(index, 1, item._itemBox, nil, showItemInfo)

	            return isCacheNode
	        end,
	        spaceX = 20,
	        isChildOfListView = true,
	        isVertical = false,
	        enableShadow = false,
	        totalNumber = #self._awards,
	        autoCenter = true,
	        autoCenterOffset = -100,
	    }  
    	self._listView = QListView.new(self._ccbOwner.itemsListView, cfg)
	else
		self._listView:reload({totalNumber = #self._awards , isCleanUp = true})
	end 
end

function QUIWidgetEnchantSynthesis:setItemInfo( item, data ,index)
	if data.oType == "item" then
		if not item._itemBox then
			item._itemBox = QUIWidgetItemsBox.new()
			item._itemBox:setScale(0.85)
			item._itemBox:setPosition(ccp(40, 40))
			item._ccbOwner.parentNode:addChild(item._itemBox)
			item._ccbOwner.parentNode:setContentSize(CCSizeMake(80, 80))
			item._itemBox:setShowGoodsNameColor(COLORS.j)
			item._itemBox:setGoodsNamePosY(-45)
			item._itemBox:setGoodsNameScale(0.8)
		end

		local id = data.id 
		local count = tonumber(data.count)
		-- local itemType = remote.items:getItemType(id)
		local itemType = data.typeName 
		local num = remote.items:getItemsNumByID(id) or 0

		if itemType ~= nil and itemType ~= ITEM_TYPE.ITEM then
			item._itemBox:setGoodsInfo(id, itemType, showNum)
		else
			item._itemBox:setGoodsInfo(id, ITEM_TYPE.ITEM, count)
			if data.isNeedShowItemCount then
				-- item._itemBox:setItemCount(string.format("%d/%d",num,count))
				item._itemBox:setNewItemCount(num,count)
			end
		end
		local name = item._itemBox:getItemName()

		item._itemBox:setName(name)
	else
		if not item._sprite then
			local sprite = CCSprite:create(data.id)
			item._sprite = sprite
			item._ccbOwner.parentNode:addChild(sprite)
		else
			local frame  = QSpriteFrameByPath(data.id)
			if frame then
				item._sprite:setDisplayFrame(frame)
			end
		end
		local width = 30
		if data.width then
			width = data.width
		end 
		if data.scale then
			item._sprite:setScale(data.scale )
		end

		item._ccbOwner.parentNode:setContentSize(CCSizeMake(width, 80))
		item._sprite:setPosition(width/2, 30)
	end
end

function QUIWidgetEnchantSynthesis:onTouchListView( event )
	if not event then
		return
	end

	if self._listView then
		self._listView:onTouch(event)
	end
end


function QUIWidgetEnchantSynthesis:_onTriggerOK(event)
	if not self._canMake then return end
	self:dispatchEvent({name = QUIWidgetEnchantSynthesis.EVENT_ENCHANT_MADE , info = self._info })
end

function QUIWidgetEnchantSynthesis:getContentSize()
	return self._ccbOwner.node_size:getContentSize()
end

return QUIWidgetEnchantSynthesis
