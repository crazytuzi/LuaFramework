-- @Author: xurui
-- @Date:   2020-01-21 15:36:31
-- @Last Modified by:   xurui
-- @Last Modified time: 2020-01-21 15:42:05
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetTitelEffect = class("QUIWidgetTitelEffect", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")

function QUIWidgetTitelEffect:ctor(options)
	local ccbFile = "ccb/effects/js_mb_1.ccbi"
    local callBacks = {
		-- {ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
    }
    QUIWidgetTitelEffect.super.ctor(self, ccbFile, callBacks, options)
  
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._animationManager = tolua.cast(self:getCCBView():getUserObject(), "CCBAnimationManager")
    self._animationManager:runAnimationsForSequenceNamed("Default Timeline")
end

function QUIWidgetTitelEffect:onEnter()
end

function QUIWidgetTitelEffect:onExit()
end

function QUIWidgetTitelEffect:setInfo()
end

return QUIWidgetTitelEffect
