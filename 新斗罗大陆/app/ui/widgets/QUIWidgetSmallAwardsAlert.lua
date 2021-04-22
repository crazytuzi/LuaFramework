--
-- Author: xurui
-- Date: 2016-02-24 09:55:04
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetSmallAwardsAlert = class("QUIWidgetSmallAwardsAlert", QUIWidget)

local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QRichText = import("...utils.QRichText")

function QUIWidgetSmallAwardsAlert:ctor(options)
	local ccbFile = "ccb/Dialog_Panjun_jiangli.ccbi"
	local callBacks = {}
	QUIWidgetSmallAwardsAlert.super.ctor(self, ccbFile, callBacks, options)

	if options then
		self._awards = options.awards
		self._title = options.title
		self._index = options.index
		self._callBack = options.callBack
		self._isLabel = options.isLabel or false
	end

	self._ccbOwner.tf_content:setVisible(false)

	if self._isLabel == false then
		self:setAwardsItem()
		self:setTitle()
	else
		self:setLabel(self._title)
	end

	self._scheduler = scheduler.performWithDelayGlobal(function()
			if self._callBack then
				self._callBack(self._index)
			end
		end, 2.3)
end

function QUIWidgetSmallAwardsAlert:onEnter()
end

function QUIWidgetSmallAwardsAlert:onExit()
	-- if self._callBack then
	-- 	self._callBack()
	-- end
	if self._scheduler ~= nil then
    	scheduler.unscheduleGlobal(self._scheduler)
    	self._scheduler = nil
    end
end

function QUIWidgetSmallAwardsAlert:setAwardsItem()
	if next(self._awards) == nil then return end 

	local awardsNum = #self._awards
	local startPositionX = - (awardsNum-1)*(100+30)/2

	local index = 1
	while index <= awardsNum do
		local itemBox = QUIWidgetItemsBox.new()
		local itemType = remote.items:getItemType(self._awards[index].typeName)
		itemBox:setGoodsInfo(self._awards[index].id, itemType, self._awards[index].count)
		-- itemBox:showItemName()
		self._ccbOwner.item_node:addChild(itemBox) 

		local contentSize = itemBox:getContentSize()
		itemBox:setPositionX(startPositionX+(index-1)*(100+30))

		index = index + 1
	end
end

function QUIWidgetSmallAwardsAlert:setTitle()
	if self._title ~= nil then
		self._ccbOwner.tf_title:setString(self._title)
	end
end

function QUIWidgetSmallAwardsAlert:setLabel()
	self._ccbOwner.tf_title:setString("")
	local richText = QRichText.new({
            {oType = "font", content = "魂师商店可以刷出 ",size = 22,color = ccc3(255,255,255),strokeColor=ccc3(0,0,0)},
            {oType = "font", content = "S级魂师碎片",size = 22,color = ccc3(255, 228, 0),strokeColor=ccc3(0,0,0)},
            {oType = "font", content = "了哟，快快搜集吧！嘻嘻~~~",size = 22,color = ccc3(255,255,255),strokeColor=ccc3(0,0,0)},
        },380,{autoCenter = true})

    self._ccbOwner.node_label:addChild(richText)
end

return QUIWidgetSmallAwardsAlert