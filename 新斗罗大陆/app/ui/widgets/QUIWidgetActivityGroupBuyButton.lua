--
--	团购按钮
--	zxs
--

local QUIWidget = import(".QUIWidget")
local QUIWidgetActivityGroupBuyButton = class("QUIWidgetActivityGroupBuyButton", QUIWidget)
local QUIWidgetItemsBox = import(".QUIWidgetItemsBox")

--初始化
function QUIWidgetActivityGroupBuyButton:ctor(options)
	local ccbFile = "Widget_Groupbuy_prop.ccbi"
	local callBacks = {}
	QUIWidgetActivityGroupBuyButton.super.ctor(self,ccbFile,callBacks,options)
end

function QUIWidgetActivityGroupBuyButton:hidAllDiscountLabel()
	self._ccbOwner.node_sale:setVisible(false)
end

function QUIWidgetActivityGroupBuyButton:setInfo(info, isSelected)
	self._info = info
	self._ccbOwner.sp_liang:setVisible(isSelected)

	if not self._itembox then
		self._itembox = QUIWidgetItemsBox.new()
		self._ccbOwner.node_icon:addChild(self._itembox)
	end
	self._itembox:setGoodsInfoByID(info.id, info.count)

	self:hidAllDiscountLabel()
	local curDiscount = info.curDiscount or 100 
	if curDiscount >= 100 then
		self._ccbOwner.node_sale:setVisible(false)
	else
		self._ccbOwner.node_sale:setVisible(true)
		self._ccbOwner.discountStr:setString(string.format("%s", curDiscount/10))
	end

	if info.maxBuyCount >= info.alreadyBuyCount or remote.user.level < info.levelLimit  then
		self._ccbOwner.sp_red_tip:setVisible(false)
	else
		self._ccbOwner.sp_red_tip:setVisible(true)
	end
end

function QUIWidgetActivityGroupBuyButton:setSelected( isSelected )
	self._ccbOwner.sp_liang:setVisible(isSelected)
end

function QUIWidgetActivityGroupBuyButton:getContentSize()
	return self._ccbOwner.node_size:getContentSize()
end

return QUIWidgetActivityGroupBuyButton
