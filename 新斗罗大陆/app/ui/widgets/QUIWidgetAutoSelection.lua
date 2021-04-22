--
-- Author: Kumo.Wang
-- 通用選擇界面Cell
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetAutoSelection = class("QUIWidgetAutoSelection", QUIWidget)

QUIWidgetAutoSelection.CLICK = "QUIWIDGETAUTOSELECTION.CLICK"

function QUIWidgetAutoSelection:ctor(options)
	local ccbFile = "ccb/Widget_AutoSelection.ccbi"
	local callBacks = {
        {ccbCallbackName = "onTriggerSelect", callback = handler(self, QUIWidgetAutoSelection._onTriggerSelect)},
	}
	QUIWidgetAutoSelection.super.ctor(self, ccbFile, callBacks, options)
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	if options then
		self._plan = options.plan
		self._index = options.index
	end

	self._isSelected = false
	
	self:_initView()
end

function QUIWidgetAutoSelection:setSelectState( b )
	self._isSelected = b
    self:_updateSelectState()
end

function QUIWidgetAutoSelection:_initView()
	self._ccbOwner.tf_title_name:setString(self._plan.titleName)
	self._ccbOwner.tf_instruction:setString(self._plan.instruction)
    self:_updateSelectState()
end

function QUIWidgetAutoSelection:_updateSelectState()
	self._ccbOwner.sp_on:setVisible(self._isSelected)
end

function QUIWidgetAutoSelection:_onTriggerSelect(e)
	if e ~= nil then
        app.sound:playSound("common_small")
    end
    self._isSelected = not self._isSelected
    self:_updateSelectState()
    self:dispatchEvent({name = QUIWidgetAutoSelection.CLICK, index = self._index, isSelected = self._isSelected})
end

return QUIWidgetAutoSelection