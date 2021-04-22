--[[	
	文件名称：QUIWidgetXuanzejiangli.lua
	创建时间：2016-07-08 15:41:45
	作者：nieming
	描述：QUIWidgetXuanzejiangli
]]

local QUIWidget = import(".QUIWidget")
local QUIWidgetXuanzejiangli = class("QUIWidgetXuanzejiangli", QUIWidget)
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QUIViewController = import("..QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")

function QUIWidgetXuanzejiangli:ctor(options)
	local ccbFile = "Widget_xuanzejiangli.ccbi"
	local callBacks = {
		-- {ccbCallbackName = "onTriggerChoose", callback = handler(self, QUIWidgetXuanzejiangli._onTriggerChoose)},
	}
	QUIWidgetXuanzejiangli.super.ctor(self,ccbFile,callBacks,options)

	self._nameMaxSize = 160
end

function QUIWidgetXuanzejiangli:_onTriggerChoose()
end

function QUIWidgetXuanzejiangli:setInfo(info, chooseType, showCount, showHeroTag, heroTagColors)
	self._info = info
	if chooseType == 1 then
		self._ccbOwner.gou:setVisible(true)
	else
		self._ccbOwner.gou:setVisible(false)
	end

	if info.selected then
		self._ccbOwner.onBtn:setVisible(true)
		self._ccbOwner.offBtn:setVisible(false)
	else
		self._ccbOwner.onBtn:setVisible(false)
		self._ccbOwner.offBtn:setVisible(true)
	end

	if not self._itemBox then
		self._itemBox = QUIWidgetItemsBox.new()
		self._ccbOwner.node_item_1:addChild(self._itemBox)
	end

	local itemType, itemName = remote.items:getItemType(info.id or info.typeName)
	if itemType ~= nil and itemType ~= ITEM_TYPE.ITEM then
		self._itemBox:setGoodsInfo(info.id, itemType, info.count)	
	else
		self._itemBox:setGoodsInfo(info.id, ITEM_TYPE.ITEM, info.count)	
		local itemConfig = QStaticDatabase:sharedDatabase():getItemByID( info.id ) or {}
		itemName = itemConfig.name
		if showCount then
			local num = remote.items:getItemsNumByID(info.id) or 0
			self._itemBox:setItemCount(string.format("%d/%d", num, info.count))
		end
	end
	
	local str = tostring(itemName or "")
	if showHeroTag then
		local actorId = QStaticDatabase:sharedDatabase():getActorIdBySoulId(info.id)
		local heroInfo = QStaticDatabase:sharedDatabase():getCharacterByID(actorId)
		if q.isEmpty(heroInfo) == false then
			self._ccbOwner.tf_hero_label:setString("<"..(heroInfo.label or "")..">")
			if heroTagColors then
				self._ccbOwner.tf_hero_label:setColor(heroTagColors.fontColor)
				self._ccbOwner.tf_hero_label:setOutlineColor(heroTagColors.outlineColor)
			end

			if chooseType == 1 then
				self._ccbOwner.tf_hero_label:setPositionY(50)
				self._ccbOwner.node_item_1:setPositionY(-5)
			else
				-- 沒有勾 and 顯示職業標簽(需求by 樓金揚)
				self._ccbOwner.tf_hero_label:setPositionY(30)
				self._ccbOwner.node_item_1:setPositionY(-25)
			end
		end
		self._ccbOwner.node_special_name:setVisible(true)
		self._ccbOwner.tf_special_name:setString( str or "" )
		self._ccbOwner.text_name:setVisible(false)

		local nameWidth = self._ccbOwner.tf_special_name:getContentSize().width
		self._ccbOwner.tf_special_name:setScale(1)
		if nameWidth > self._nameMaxSize then
			self._ccbOwner.tf_special_name:setScale(1-(nameWidth - self._nameMaxSize)/self._nameMaxSize)
		end
	else
		self._ccbOwner.text_name:setVisible(true)
		self._ccbOwner.node_special_name:setVisible(false)
		self._ccbOwner["text_name"]:setString( str or "" )
		self._ccbOwner.tf_hero_label:setPositionY(50)
		self._ccbOwner.node_item_1:setPositionY(-5)
		local nameWidth = self._ccbOwner.text_name:getContentSize().width
		self._ccbOwner.text_name:setScale(1)
		if nameWidth > self._nameMaxSize then
			self._ccbOwner.text_name:setScale(1-(nameWidth - self._nameMaxSize)/self._nameMaxSize)
		end

	end
end

function QUIWidgetXuanzejiangli:getContentSize()
	return self._ccbOwner.cellsize:getContentSize()
end


function QUIWidgetXuanzejiangli:showItemInfo(x, y, itemBox, listView)
	app.tip:itemTip(itemBox._itemType, itemBox._itemID, true)
end

return QUIWidgetXuanzejiangli
