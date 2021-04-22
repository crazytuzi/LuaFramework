--
-- Kumo.Wang
-- 時裝繪卷主界面 -- 按鈕菜單
--

local QUIWidget = import(".QUIWidget")
local QUIWidgetFashionCombinationMainMenu = class("QUIWidgetFashionCombinationMainMenu", QUIWidget)

local QUIWidgetHeroHead = import("..widgets.QUIWidgetHeroHead")

QUIWidgetFashionCombinationMainMenu.EVENT_CLICK = "QUIWIDGETFASHIONCOMBINATIONMAINMENU.EVENT_CLICK"

function QUIWidgetFashionCombinationMainMenu:ctor(options)
	local ccbFile = "Widget_Fashion_Combination_Menu.ccbi"
	local callBacks = {}
	QUIWidgetFashionCombinationMainMenu.super.ctor(self,ccbFile,callBacks,options)
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
end

function QUIWidgetFashionCombinationMainMenu:getInfo()
	return self._info
end

function QUIWidgetFashionCombinationMainMenu:getContentSize()
	return self._ccbOwner.node_size:getContentSize()
end

function QUIWidgetFashionCombinationMainMenu:setInfo(info)
	self._info = info
	if not self._info then return end
	self:refreshInfo()
end

function QUIWidgetFashionCombinationMainMenu:refreshInfo()
	if not self._info then return end

    self._ccbOwner.tf_btn_menu:setString(self._info.name)
end

function QUIWidgetFashionCombinationMainMenu:setSelect(b)
	if b then
		self._ccbOwner.btn_menu:setEnabled(false)
		self._ccbOwner.tf_btn_menu:setColor(COLORS.k)
	else
		self._ccbOwner.btn_menu:setEnabled(true)
		self._ccbOwner.tf_btn_menu:setColor(COLORS.j)
	end
end

function QUIWidgetFashionCombinationMainMenu:onTriggerClick()
	self:dispatchEvent({name = QUIWidgetFashionCombinationMainMenu.EVENT_CLICK, info = self._info})
end

return QUIWidgetFashionCombinationMainMenu
