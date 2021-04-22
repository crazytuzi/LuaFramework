--
-- Kumo.Wang
-- 回收站菜单按钮组件
--

local QUIWidget = import(".QUIWidget")
local QUIWidgetRecycleMenuButton = class("QUIWidgetRecycleMenuButton", QUIWidget)

QUIWidgetRecycleMenuButton.EVENT_CLICK = "QUIWIDGETRECYCLEMENUBUTTON.EVENT_CLICK"

QUIWidgetRecycleMenuButton.SUBMENU_SCALE = 0.9

function QUIWidgetRecycleMenuButton:ctor(options)
	local ccbFile = "Widget_Recycle_Menu_Button.ccbi"
	QUIWidgetRecycleMenuButton.super.ctor(self, ccbFile, callBacks, options)
	cc.GameObject.extend(self)
   	self:addComponent("components.behavior.EventProtocol"):exportMethods()
end

function QUIWidgetRecycleMenuButton:setInfo(info)
	self._info = info
	if not self._info then return end

	self._ccbOwner.widget_btn_menu:setTitleForState(CCString:create(self._info.name), CCControlStateNormal)
	self._ccbOwner.widget_btn_menu:setTitleForState(CCString:create(self._info.name), CCControlStateHighlighted)
	self._ccbOwner.widget_btn_menu:setTitleForState(CCString:create(self._info.name), CCControlStateDisabled)

	if self._info.isSubmenu then
		-- 子菜单
		self._ccbOwner.node_widget:setScale(QUIWidgetRecycleMenuButton.SUBMENU_SCALE)
	else
		-- 主菜单
		self._ccbOwner.node_widget:setScale(1)
	end

	self._ccbOwner.widget_btn_menu:setEnabled(not self._info.isSelected)
end

function QUIWidgetRecycleMenuButton:getContentSize()
	local size = CCSize(self._ccbOwner.node_size:getContentSize().width * self._ccbOwner.node_widget:getScaleX(), self._ccbOwner.node_size:getContentSize().height * self._ccbOwner.node_widget:getScaleY())
	return size
end

function QUIWidgetRecycleMenuButton:onTriggerClick()
	app.sound:playSound("common_switch")
	self:dispatchEvent({name = QUIWidgetRecycleMenuButton.EVENT_CLICK, info = self._info})
end

return QUIWidgetRecycleMenuButton
