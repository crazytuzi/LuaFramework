local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetThunderKingMysteriousMany = class("QUIWidgetThunderKingMysteriousMany", QUIWidget)

QUIWidgetThunderKingMysteriousMany.EVENT_CLICK = "QUIWidgetThunderKingMysteriousMany_event_click"

function QUIWidgetThunderKingMysteriousMany:ctor(options)
	local ccbFile = "ccb/Widget_ThunderKing_haoyunbaoxiang.ccbi"
  	local callBacks = {
		{ccbCallbackName = "onTriggerClick", callback = handler(self, QUIWidgetThunderKingMysteriousMany._onTriggerClick)},
	}
	QUIWidgetThunderKingMysteriousMany.super.ctor(self,ccbFile,callBacks,options)
  	cc.GameObject.extend(self)
  	self:addComponent("components.behavior.EventProtocol"):exportMethods()

end

function QUIWidgetThunderKingMysteriousMany:setInfo(layer, count)
	self._layer = layer
	self._ccbOwner.tf_layer:setString("第"..q.numToWord(layer).."层")
	self._ccbOwner.tf_count:setString((count-1).."/20")
end

function QUIWidgetThunderKingMysteriousMany:setChestState(isOpen)
	if isOpen == nil then isOpen = false end
	-- 控制宝箱CCB
	local animationManager = tolua.cast(self._ccbOwner.ccb_chest:getUserObject(), "CCBAnimationManager")
	if animationManager ~= nil then
		if isOpen == true then
			animationManager:runAnimationsForSequenceNamed("open")
		else
			animationManager:runAnimationsForSequenceNamed("normal")
			animationManager:pauseAnimation()
		end
	end
end

function QUIWidgetThunderKingMysteriousMany:_onTriggerClick(e)
	self:dispatchEvent({name = QUIWidgetThunderKingMysteriousMany.EVENT_CLICK, layer = self._layer})
end

return QUIWidgetThunderKingMysteriousMany