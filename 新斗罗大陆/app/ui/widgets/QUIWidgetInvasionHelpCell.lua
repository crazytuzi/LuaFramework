
--[[	
	文件名称：QUIWidgetInvasionHelpCell.lua
	创建时间：2016-08-27 17:15:58
	作者：nieming
	描述：QUIWidgetInvasionHelpCell
]]

local QUIWidget = import(".QUIWidget")
local QUIWidgetInvasionHelpCell = class("QUIWidgetInvasionHelpCell", QUIWidget)
local QUIWidgetItemsBox = import(".QUIWidgetItemsBox")
local QRichText = import("...utils.QRichText")

--初始化
function QUIWidgetInvasionHelpCell:ctor(options)
	local ccbFile = "Widget_Panjun_Rlue2.ccbi"
	local callBacks = {
	}
	QUIWidgetInvasionHelpCell.super.ctor(self,ccbFile,callBacks,options)
	--代码
	self._itemBox = {}
end

--describe：setInfo 
function QUIWidgetInvasionHelpCell:setInfo(info)
	--代码
	if not info.rankStr then
		self._ccbOwner.rankStr:setVisible(false)
		self._ccbOwner.rewardNodes:setPositionX(35)
	else
		self._ccbOwner.rankStr:setString(info.rankStr)
		self._ccbOwner.rankStr:setVisible(true)
		self._ccbOwner.rewardNodes:setPositionX(190)
	end

	for k = 1, 5 do 
		local award = info.awardsArr[k];
		local itemNodeName = "item"..k
		local itemCountLabel = "reward_nums"..k
		if award then
			if not self._itemBox[k] then
				self._itemBox[k] = QUIWidgetItemsBox.new()
				self._ccbOwner[itemNodeName]:addChild(self._itemBox[k])
			end
			self._itemBox[k]:setGoodsInfoByID(award.id)
			self._itemBox[k]:setScale(0.4)
			self._ccbOwner[itemNodeName]:setVisible(true)
			self._ccbOwner[itemCountLabel]:setVisible(true)
			self._ccbOwner[itemCountLabel]:setString("x"..award.count)
		else
			self._ccbOwner[itemNodeName]:setVisible(false)
			self._ccbOwner[itemCountLabel]:setVisible(false)
		end
	end 
end

function QUIWidgetInvasionHelpCell:adjustPosition( pos, size )
	-- body
	self._ccbOwner.parentNode:setPosition(pos)
	self._ccbOwner.cellSize:setContentSize(size)
end

--describe：getContentSize 
function QUIWidgetInvasionHelpCell:getContentSize()
	--代码
	return self._ccbOwner.cellSize:getContentSize()
end

return QUIWidgetInvasionHelpCell
