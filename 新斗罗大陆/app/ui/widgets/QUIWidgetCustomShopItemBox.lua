-- @Author: liaoxianbo
-- @Date:   2020-10-25 15:55:09
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-10-27 19:07:51
local QUIWidget = import(".QUIWidget")
local QUIWidgetCustomShopItemBox = class("QUIWidgetCustomShopItemBox", QUIWidget)
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")

QUIWidgetCustomShopItemBox.SHOW_POOL_ITEMS = "SHOW_POOL_ITEMS"
QUIWidgetCustomShopItemBox.CHOOSE_FLAY_ACTION = "CHOOSE_FLAY_ACTION"

function QUIWidgetCustomShopItemBox:ctor(options)
	local ccbFile = "ccb/Widget_CustomShop_itemBox.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClick",	callback = handler(self, self._onTriggerClick)},
	}
	QUIWidgetCustomShopItemBox.super.ctor(self,ccbFile,callBacks,options)
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()	

    self._ccbOwner.sp_is_done:setShaderProgram(qShader.Q_ProgramColorLayer)
    self._ccbOwner.sp_is_done:setColor(ccc3(0, 0, 0))
    self._ccbOwner.sp_is_done:setOpacity(0.5 * 255)

    self._ccbOwner.sp_choose_down:setVisible(false)

    self._isChooseState = false

    self:setChooseState(false)
end

function QUIWidgetCustomShopItemBox:setClickBtnSize(size)
	self._ccbOwner.btn_click:setPreferredSize(size)
end

function QUIWidgetCustomShopItemBox:setClickBtnPosition(positionX, posiitonY)
	self._ccbOwner.btn_click:setPosition(positionX, posiitonY)
end

function QUIWidgetCustomShopItemBox:setItemInfo(itemData,isPool)
	if not self._itemBox then
		self._itemBox = QUIWidgetItemsBox.new()
		self._itemBox:setPosition(ccp(50, 50))
		self._ccbOwner.parentNode:addChild(self._itemBox)
		self._ccbOwner.parentNode:setContentSize(CCSizeMake(100, 100))

	end
	self._itemData = itemData
	self._isPool = isPool

	if isPool then
		self._itemBox:isShowPlus(true)
	else
		self._itemBox:setGoodsInfo(itemData.id or 0,itemData.typeName, itemData.count)
	end
end

function QUIWidgetCustomShopItemBox:refresItemInfo(itemData)
	if self._itemBox and q.isEmpty(itemData) == false then
		self._itemBox:setGoodsInfo(itemData.id or 0,itemData.typeName, itemData.count)
	end
end

function QUIWidgetCustomShopItemBox:onTouchListView(event)
	if self._itemNode and self._itemNode.onTouchListView then
		self._itemNode:onTouchListView(event)
	end
end

function QUIWidgetCustomShopItemBox:setShowDownState(b)
	if self._itemBox then
		self._itemBox:selected(b)
	end
	self._ccbOwner.sp_choose_down:setVisible(b)
end

function QUIWidgetCustomShopItemBox:setChooseState(b )
	self._isChooseState = b
    self._ccbOwner.sp_is_done:setVisible(b)
    self._ccbOwner.sp_choose:setVisible(b)
end

function QUIWidgetCustomShopItemBox:_onTriggerClick()
	if self._isChooseState then
		return
	end
	if self._isPool then
		self:dispatchEvent({name = QUIWidgetCustomShopItemBox.SHOW_POOL_ITEMS, poolId = self._itemData})
	else
		self:dispatchEvent({name = QUIWidgetCustomShopItemBox.CHOOSE_FLAY_ACTION, itemData = self._itemData})
	end
end

return QUIWidgetCustomShopItemBox
