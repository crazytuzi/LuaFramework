-- @Author: xurui
-- @Date:   2019-03-21 15:22:03
-- @Last Modified by:   xurui
-- @Last Modified time: 2019-03-26 14:58:25
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetAwardsChoose = class("QUIWidgetAwardsChoose", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")

QUIWidgetAwardsChoose.EVENT_CLICK_CHOOSE = "EVENT_CLICK_CHOOSE"

function QUIWidgetAwardsChoose:ctor(options)
	local ccbFile = "ccb/Widget_Archaeology_AwardChoose.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerChoose", callback = handler(self, self._onTriggerChoose)},
    }
    QUIWidgetAwardsChoose.super.ctor(self, ccbFile, callBacks, options)
  
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
end

function QUIWidgetAwardsChoose:onEnter()
end

function QUIWidgetAwardsChoose:onExit()
end

function QUIWidgetAwardsChoose:setInfo(info, isCanGet)
	self._ccbOwner.sp_on:setVisible(false)
	self._ccbOwner.sp_off:setVisible(true)

	self._info = info
	local itemConfig = db:getItemByID( info.id )
	self._ccbOwner.node_gou:setVisible(isCanGet)
	self._ccbOwner.tf_name:setString( itemConfig.name )

	if not self._itemBox then
		self._itemBox = QUIWidgetItemsBox.new()
		self._ccbOwner.node_item:removeAllChildren()
		self._ccbOwner.node_item:addChild( self._itemBox )
    	self._itemBox:setPromptIsOpen(true)
	end
	self._itemBox:setGoodsInfo(info.id, info.type, info.num)
end

function QUIWidgetAwardsChoose:setSelectId(id)
	local isSelect = self._info.id == id
	self._ccbOwner.sp_on:setVisible(isSelect)
	self._ccbOwner.sp_off:setVisible(not isSelect)
end

function QUIWidgetAwardsChoose:getContentSize()
	return self._ccbOwner.node_size:getContentSize()
end

function QUIWidgetAwardsChoose:_onTriggerChoose()
	self:dispatchEvent({name = QUIWidgetAwardsChoose.EVENT_CLICK_CHOOSE, info = self._info})
end

return QUIWidgetAwardsChoose
