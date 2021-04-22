--[[	
	文件名称：QUIWidgetBaseHelpAward.lua
	创建时间：2016-08-27 17:15:58
	作者：nieming
	描述：QUIWidgetBaseHelpAward
]]

local QUIWidget = import(".QUIWidget")
local QUIWidgetBaseHelpAward = class("QUIWidgetBaseHelpAward", QUIWidget)
local QUIWidgetItemsBox = import(".QUIWidgetItemsBox")
local QRichText = import("...utils.QRichText")
local QUIWidgetHeroTitleBox = import(".QUIWidgetHeroTitleBox")
--初始化
function QUIWidgetBaseHelpAward:ctor(options)
	local ccbFile = "Widget_Base_Help_Award.ccbi"
	local callBacks = {
	}
	QUIWidgetBaseHelpAward.super.ctor(self,ccbFile,callBacks,options)
	--代码
	self._itemBox = {}
end

--describe：onEnter 
--function QUIWidgetBaseHelpAward:onEnter()
	----代码
--end

--describe：onExit 
--function QUIWidgetBaseHelpAward:onExit()
	----代码
--end

--describe：setInfo 
function QUIWidgetBaseHelpAward:setInfo(info)
	--代码
	if not info.rankStr then
		self._ccbOwner.rankStr:setVisible(false)
		self._ccbOwner.itemParentNode:setPositionX(-160.0)
	else
		self._ccbOwner.node_color_str:removeAllChildren()
		--self._ccbOwner.rankStr:setString("")
		self._ccbOwner.rankStr:setVisible(false)
		self._strRichtext = QRichText.new(nil,300,{stringType = 1, defaultColor = ccc3(134,85,55), defaultSize = 20})
		self._ccbOwner.node_color_str:addChild(self._strRichtext)
		self._strRichtext:setAnchorPoint(ccp(0, 1))
		self._strRichtext:setString(info.rankStr)

		local offsetX = info.awardOffsetX or 0
		local offsetY = info.awardOffsetY or 0
		self._ccbOwner.itemParentNode:setPosition(ccp(offsetX, offsetY))
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
			self._ccbOwner[itemCountLabel]:setColor(ccc3(134, 85, 55))
		else
			self._ccbOwner[itemNodeName]:setVisible(false)
			self._ccbOwner[itemCountLabel]:setVisible(false)
		end
	end 
	self._ccbOwner.otherNode:removeAllChildren()

	if info.title then
		self._ccbOwner.otherNode:setVisible(true)
		local richTextConfig = {}

		table.insert(richTextConfig, {oType = "font", content = "称号奖励： ",size = 20,color = ccc3(134,85,55)})
		local titleBox = QUIWidgetHeroTitleBox.new()
	    titleBox:setTitleId(info.title)
	    titleBox:setScale(0.5)
    	local size = titleBox:boundingBox().size
        local defaultOffset = ccp(size.width/2, size.height/2+ 3)
	    table.insert(richTextConfig, {oType = "node", node = titleBox, offset= defaultOffset})
	
		self._richtext = QRichText.new(richTextConfig)
		self._richtext:setPositionX(#info.awardsArr * 120)

		self._ccbOwner.otherNode:addChild(self._richtext)
	end

end


function QUIWidgetBaseHelpAward:adjustPosition( pos, size )
	-- body
	self._ccbOwner.parentNode:setPosition(pos)
	self._ccbOwner.cellSize:setContentSize(size)

end

--describe：getContentSize 
function QUIWidgetBaseHelpAward:getContentSize()
	--代码
	return self._ccbOwner.cellSize:getContentSize()
end

return QUIWidgetBaseHelpAward
