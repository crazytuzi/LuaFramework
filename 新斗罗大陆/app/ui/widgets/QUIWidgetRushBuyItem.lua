--[[	
	文件名称：QUIWidgetRushBuyItem.lua
	创建时间：2017-02-10 17:51:25
	作者：nieming
	描述：QUIWidgetRushBuyItem
]]

local QUIWidget = import(".QUIWidget")
local QUIWidgetRushBuyItem = class("QUIWidgetRushBuyItem", QUIWidget)
local QUIWidgetItemsBox = import(".QUIWidgetItemsBox")

--初始化
function QUIWidgetRushBuyItem:ctor(options)
	local ccbFile = "Widget_SixYuan.ccbi"
	local callBacks = {
	}
	QUIWidgetRushBuyItem.super.ctor(self,ccbFile,callBacks,options)
	--代码
end

--describe：onEnter 
--function QUIWidgetRushBuyItem:onEnter()
	----代码
--end

--describe：onExit 
--function QUIWidgetRushBuyItem:onExit()
	----代码
--end

--describe：setInfo 
function QUIWidgetRushBuyItem:setInfo(info, isSelected, data)

	----代码
	self._info = info
	self._data = data

	local imp = remote.activityRounds:getRushBuy()
	self._ccbOwner.itemBtn:setHighlighted(isSelected)
	self._ccbOwner.itemBtn:setEnabled(not isSelected)

	if not self._itembox then
		self._itembox = QUIWidgetItemsBox.new()
		self._ccbOwner.item:addChild(self._itembox)
	end
	self._itembox:setGoodsInfoByID(info.item, info.num)

	if not self._scoresBarMask then
		self._scoresBarMask = self:_addScoresBarMaskLayer(self._ccbOwner.progressSprite, self._ccbOwner.progressBarParent)
	end
	self._scoresBarMask:setScaleX(info.allBuyCount/info.price)


	if info.myBuyCount and info.myBuyCount > 0 and imp.isActivityNotEnd then
		self._ccbOwner.alreadyJoin:setVisible(true)
	else
		self._ccbOwner.alreadyJoin:setVisible(false)
	end

	if info.allBuyCount ==  info.price then
		self._ccbOwner.empty:setVisible(true)
	else
		self._ccbOwner.empty:setVisible(false)
	end

	self._ccbOwner.redTips:setVisible(info.isRedTips and info.allBuyCount ~=  info.price and info.myBuyCount and info.myBuyCount == 0  and imp.isActivityNotEnd )

	self._ccbOwner.progressLabel:setString(string.format("%s/%s", info.allBuyCount, info.price))

	if isSelected and info.isRedTips then
		info.isRedTips = false
		self._ccbOwner.redTips:setVisible(false)
		if imp and imp.isOpen then
			app:getUserOperateRecord():setRushBuyRedTips(imp.activityId ,self._info.roundId)
		end
		if self._data then
			local isAllItemClicked = true
			for k, t in pairs(self._data) do
				if isAllItemClicked and t.isRedTips and  t.allBuyCount ~=  t.price and t.myBuyCount and t.myBuyCount == 0 and imp.isActivityNotEnd then
					isAllItemClicked = false
					break
				end
			end
			imp:setAllItemClicked(isAllItemClicked)
		end
	end

	-- if not imp.isActivityNotEnd then
	-- 	self._ccbOwner.progressLabel:setVisible(false)
	-- 	self._ccbOwner.progressBarParent:setVisible(false)
	-- else
	-- 	self._ccbOwner.progressLabel:setVisible(true)
	-- end

end

function QUIWidgetRushBuyItem:_addScoresBarMaskLayer(ccb, mask)

    local width = ccb:getContentSize().width * ccb:getScaleX()
    self._barWidth = width
    local height = ccb:getContentSize().height * ccb:getScaleY()
    local maskLayer = CCLayerColor:create(ccc4(0,0,0,150), width, height)
    maskLayer:setAnchorPoint(ccp(0, 0))
    maskLayer:setPosition(ccp(0, 0))

    local ccclippingNode = CCClippingNode:create()
    ccclippingNode:setStencil(maskLayer)
    ccb:retain()
    ccb:removeFromParent()
    ccb:setPosition(ccp(0, 0))
    ccclippingNode:addChild(ccb)
    ccb:release()

    mask:addChild(ccclippingNode)
    return maskLayer
end

--describe：getContentSize 
function QUIWidgetRushBuyItem:getContentSize()
	--代码
	return self._ccbOwner.cellSize:getContentSize()
end

function QUIWidgetRushBuyItem:setSelected( isSelected )
	-- body
	self._ccbOwner.itemBtn:setHighlighted(isSelected)
	self._ccbOwner.itemBtn:setEnabled(not isSelected)

	if isSelected and self._info.isRedTips then
		self._info.isRedTips = false
		self._ccbOwner.redTips:setVisible(false)
		local imp = remote.activityRounds:getRushBuy()
		if imp and imp.isOpen then
			app:getUserOperateRecord():setRushBuyRedTips(imp.activityId ,self._info.roundId)
		end
		if self._data then
			local isAllItemClicked = true
			for k, t in pairs(self._data) do
				if isAllItemClicked and t.isRedTips and  t.allBuyCount ~=  t.price and t.myBuyCount and t.myBuyCount == 0 and imp.isActivityNotEnd then
					isAllItemClicked = false
					break
				end
			end
			imp:setAllItemClicked(isAllItemClicked)
		end
	end
end

return QUIWidgetRushBuyItem
