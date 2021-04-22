--[[	
	文件名称：QUIWidgetActivityTurntableAward.lua
	创建时间：2016-07-30 09:55:23
	作者：nieming
	描述：QUIWidgetActivityTurntableAward
]]

local QUIWidget = import(".QUIWidget")
local QUIWidgetActivityTurntableAward = class("QUIWidgetActivityTurntableAward", QUIWidget)
local QUIWidgetItemsBox = import(".QUIWidgetItemsBox")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("...ui.QUIViewController")
--初始化
function QUIWidgetActivityTurntableAward:ctor(options)
	local ccbFile = "Widget_WineGod_jifen.ccbi"
	local callBacks = {
	}
	QUIWidgetActivityTurntableAward.super.ctor(self,ccbFile,callBacks,options)
	--代码
end

--describe：onEnter 
--function QUIWidgetActivityTurntableAward:onEnter()
	----代码
--end

--describe：onExit 
--function QUIWidgetActivityTurntableAward:onExit()
	----代码
--end

--describe：setInfo 
function QUIWidgetActivityTurntableAward:setInfo(info, isCommon, rankType)
	--代码
	self._info = info
	self._ccbOwner.title:setString(info.description)

	local myRank
	if rankType and rankType == "divination" then
		myRank = isCommon and remote.activityRounds:getDivination():getCurServerRank() or remote.activityRounds:getDivination():getAllServerRank()
	else
		myRank = isCommon and remote.activityRounds:getTurntable():getCommonRank() or remote.activityRounds:getTurntable():getEliteRank()
	end

	
	if myRank ~= 0 then
		self._ccbOwner.rank:setString(string.format("我的排名：%d",myRank))
	else
		self._ccbOwner.rank:setString(string.format("我的排名：未上榜"))
	end
	
	if myRank >= info.rank_1 and myRank <= info.rank_2 then
		self._ccbOwner.notFinish:setVisible(false)
		self._ccbOwner.finish:setVisible(true)
	else
		self._ccbOwner.notFinish:setVisible(true)
		self._ccbOwner.finish:setVisible(false)
	end

	if not self._itemBoxs then
		self._itemBoxs = {}
	end

	for i=1,4 do
		if info.awards[i] then
			local v = info.awards[i]
			printTable(v)
			self._ccbOwner["item"..i]:setVisible(true)
			local itemBox = self._itemBoxs[i]
			if not itemBox then
				itemBox = QUIWidgetItemsBox.new()
				
				self._itemBoxs[i] = itemBox
				self._ccbOwner["item"..i]:addChild(itemBox)
			end

			local itemType 
			if v.typeName then
				itemType = remote.items:getItemType(v.typeName)
			else
				itemType = remote.items:getItemType(v.id)
			end
			
			if itemType ~= nil and itemType ~= ITEM_TYPE.ITEM then
				itemBox:setGoodsInfo(v.id, itemType, v.count)		
			else
				itemBox:setGoodsInfo(v.id, ITEM_TYPE.ITEM, v.count)
			end
		else
			self._ccbOwner["item"..i]:setVisible(false)
		end
	end

end

--describe：getContentSize 
function QUIWidgetActivityTurntableAward:getContentSize()
	--代码
	return self._ccbOwner.cellsize:getContentSize()
end

function QUIWidgetActivityTurntableAward:registerItemBoxPrompt( index, list )
	-- body
	for k, v in pairs(self._itemBoxs) do
		list:registerItemBoxPrompt(index,k,v,nil, "showItemInfo")
	end
end

function QUIWidgetActivityTurntableAward:showItemInfo(x, y, itemBox, listView)
	app.tip:itemTip(itemBox._itemType, itemBox._itemID, true)
end


return QUIWidgetActivityTurntableAward
