local QUIWidget = import("...widgets.QUIWidget")
local QUIWidgetSparFieldSmallChest = class("QUIWidgetSparFieldSmallChest", QUIWidget)

QUIWidgetSparFieldSmallChest.EVENT_CLICK = "EVENT_CLICK"
QUIWidgetSparFieldSmallChest.EVENT_PLAY_END = "EVENT_PLAY_END"
QUIWidgetSparFieldSmallChest.EVENT_DISAPPEAR = "EVENT_DISAPPEAR"

function QUIWidgetSparFieldSmallChest:ctor(options)
	local ccbFile = "ccb/effects/Dialog_sparfield_xiaobaoxiang_001.ccbi"
  	local callBacks = {
      	{ccbCallbackName = "onTriggerClick", callback = handler(self, QUIWidgetSparFieldSmallChest._onTriggerClick)},
  	}
	QUIWidgetSparFieldSmallChest.super.ctor(self,ccbFile,callBacks,options)
  	cc.GameObject.extend(self)
  	self:addComponent("components.behavior.EventProtocol"):exportMethods()
    self._animationManager = tolua.cast(self._ccbView:getUserObject(), "CCBAnimationManager")
    self._animationManager:connectScriptHandler(handler(self, self.animationHandler))
	self._ccbOwner.node_root:setCascadeOpacityEnabled(true)
end

function QUIWidgetSparFieldSmallChest:onExit()
	QUIWidgetSparFieldSmallChest.super.onExit(self)
    self._animationManager:stopAnimation()
    self._animationManager = nil
end

function QUIWidgetSparFieldSmallChest:animationHandler(name)
	if name == "kaiqi" then
		local arr = CCArray:create()
		arr:addObject(CCFadeOut:create(1))
		arr:addObject(CCCallFunc:create(function ()
			self:dispatchEvent({name = QUIWidgetSparFieldSmallChest.EVENT_DISAPPEAR})
		end))
		self._ccbOwner.node_root:runAction(CCSequence:create(arr))
	end
	self:dispatchEvent({name = QUIWidgetSparFieldSmallChest.EVENT_PLAY_END, animationName = name})
end

function QUIWidgetSparFieldSmallChest:playAnimationByName(name)
    self._animationManager:runAnimationsForSequenceNamed(name)
end

function QUIWidgetSparFieldSmallChest:_onTriggerClick()
	self:dispatchEvent({name = QUIWidgetSparFieldSmallChest.EVENT_CLICK})
end

return QUIWidgetSparFieldSmallChest