-- 
-- Kumo.Wang
-- 戰鬥失敗推薦提升
-- 

local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetFightEndLostHelp = class("QUIWidgetFightEndLostHelp", QUIWidget)

QUIWidgetFightEndLostHelp.EVENT_GO_CLICK = "QUIWIDGETFIGHTENDLOSTHELP.EVENT_GO_CLICK"

function QUIWidgetFightEndLostHelp:ctor(options)
	local ccbFile = "ccb/Widget_FightEnd_Lost.ccbi"
	local callBack = {
		{ccbCallbackName = "onTriggerClick", callback = handler(self, self._onTriggerClick)},
	}
	QUIWidgetFightEndLostHelp.super.ctor(self, ccbFile, callBack, options)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
end

function QUIWidgetFightEndLostHelp:resetAll()
	self._ccbOwner.sp_icon:setVisible(false)
	self._ccbOwner.tf_name:setVisible(false)
	self._ccbOwner.node_evaluation:setVisible(false)
	self._ccbOwner.btn_click:setVisible(true)
end

function QUIWidgetFightEndLostHelp:setInfo(info)
	QPrintTable(info)
	self:resetAll()
	if not info or not next(info) then return end
	self._info = info

	if info.icon then
		-- QSetDisplayFrameByPath(self._ccbOwner.sp_icon, info.icon)
		QSetDisplaySpriteByPath(self._ccbOwner.sp_icon, info.icon)
		self._ccbOwner.sp_icon:setVisible(true)
	end

	if info.name then
		self._ccbOwner.tf_name:setString(info.name)
		self._ccbOwner.tf_name:setVisible(true)
		local scale = 140/self._ccbOwner.tf_name:getContentSize().width
		scale = scale >= 1 and 1 or scale
		self._ccbOwner.tf_name:setScale(scale)
	end

	local value = remote.strongerUtil:getStageByStandard(info)
	self._ccbOwner.node_evaluation:setVisible(value < 0.6)
end

function QUIWidgetFightEndLostHelp:_onTriggerClick()
    app.sound:playSound("common_switch")
	self:dispatchEvent({name = QUIWidgetFightEndLostHelp.EVENT_GO_CLICK, info = self._info})
end

return QUIWidgetFightEndLostHelp