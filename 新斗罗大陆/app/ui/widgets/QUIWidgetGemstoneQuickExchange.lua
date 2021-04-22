-- @Author: xurui
-- @Date:   2019-09-18 20:29:12
-- @Last Modified by:   xurui
-- @Last Modified time: 2019-09-19 16:35:18
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetGemstoneQuickExchange = class("QUIWidgetGemstoneQuickExchange", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QUIWidgetGemstonesBox = import("..widgets.QUIWidgetGemstonesBox")
local QUIWidgetSparBox = import("..widgets.spar.QUIWidgetSparBox")

QUIWidgetGemstoneQuickExchange.EVENT_CLICK_SELECT = "EVENT_CLICK_SELECT"

function QUIWidgetGemstoneQuickExchange:ctor(options)
	local ccbFile = "ccb/Widget_gemstone_box.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerTouch", callback = handler(self, self._onTriggerTouch)},
    }
    QUIWidgetGemstoneQuickExchange.super.ctor(self, ccbFile, callBacks, options)
  
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
end

function QUIWidgetGemstoneQuickExchange:onEnter()
end

function QUIWidgetGemstoneQuickExchange:onExit()
end

function QUIWidgetGemstoneQuickExchange:initGLLayer()
	self._glLayerIndex = glLayerIndex or 1

	if self._itemBox and self._itemBox.initGLLayer then
		self._glLayerIndex = self._itemBox:initGLLayer(self._glLayerIndex)
	end

	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.btn_touch, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_no_select, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_select, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.btn_select, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.ly_1, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.ly_2, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.tf_duplicate, self._glLayerIndex)
end

function QUIWidgetGemstoneQuickExchange:setInfo(info)
	self._info = info

	if self._itemBox ~= nil then
		self._itemBox:removeFromParent()
		self._itemBox = nil
	end

	if self._info.gemstoneInfo then
		self._itemBox = QUIWidgetGemstonesBox.new()
		self._ccbOwner.node_item:addChild(self._itemBox)
		self._itemBox:setGemstoneInfo(self._info.gemstoneInfo)
		self._itemBox:setPos(self._info.gemstoneType)
	elseif self._info.sparInfo then
		self._itemBox = QUIWidgetSparBox.new()
		self._ccbOwner.node_item:addChild(self._itemBox)
		self._itemBox:setGemstoneInfo(self._info.sparInfo, self._info.sparType)
		self._itemBox:setNameVisible(false)
	end

	self:initGLLayer()

	self:setSelectState()

	self:setDuplicateState()
end

function QUIWidgetGemstoneQuickExchange:setSelectState()
	self._ccbOwner.sp_select:setVisible(self._info.isSelect)
end

function QUIWidgetGemstoneQuickExchange:setDuplicateState()
	self._ccbOwner.node_duplicate:setVisible(self._info.isDuplicate)
	self._ccbOwner.node_select:setVisible(not self._info.isDuplicate)
	if self._itemBox then
		if self._itemBox.setGray then
			self._itemBox:setGray(self._info.isDuplicate)
		elseif self._itemBox.setGrayState then
			self._itemBox:setGrayState(self._info.isDuplicate)
		end
	end
end

function QUIWidgetGemstoneQuickExchange:_onTriggerTouch()
	if self._info.isDuplicate then return end

	self._info.isSelect = not self._info.isSelect

	self:dispatchEvent({name = QUIWidgetGemstoneQuickExchange.EVENT_CLICK_SELECT, info = self._info})

	self:setSelectState()
end

function QUIWidgetGemstoneQuickExchange:getContentSize()
	return CCSize(130, 130)
end

return QUIWidgetGemstoneQuickExchange
