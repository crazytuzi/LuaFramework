--
-- Author: Kumo.Wang
-- Date: Fri Mar 11 13:03:07 2016
-- 魂力试炼序章
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetSoulTrialFirst = class("QUIWidgetSoulTrialFirst", QUIWidget)

QUIWidgetSoulTrialFirst.SOULTRIAL_CLICK = "SOULTRIAL_CLICK"

function QUIWidgetSoulTrialFirst:ctor(options)
	local ccbFile = "ccb/Widget_SoulTrial_First.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClick", callback = handler(self, QUIWidgetSoulTrialFirst._onTriggerClick)}
	}
	QUIWidgetSoulTrialFirst.super.ctor(self, ccbFile, callBacks, options)
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._isClick = false
	self:_init()
end

function QUIWidgetSoulTrialFirst:onEnter()
end

function QUIWidgetSoulTrialFirst:onExit()
end

function QUIWidgetSoulTrialFirst:_init()
	local ccbFile = "ccb/effects/soulTrial_first.ccbi"
	local proxy = CCBProxy:create()
	self._aniCcbOwner = {}
   	local aniCcbView = CCBuilderReaderLoad(ccbFile, proxy, self._aniCcbOwner)
    self._ccbOwner.node_effect:addChild(aniCcbView)

    self._effectManager = tolua.cast(aniCcbView:getUserObject(), "CCBAnimationManager")
    self._effectManager:runAnimationsForSequenceNamed("daiji")
    self._effectManager:connectScriptHandler(handler(self, self.viewAnimationEndHandler))
end

function QUIWidgetSoulTrialFirst:viewAnimationEndHandler(name)
	if name == "moqiu" then
		self._effectManager:disconnectScriptHandler()
		self:dispatchEvent({name = QUIWidgetSoulTrialFirst.SOULTRIAL_CLICK})
	end
end

function QUIWidgetSoulTrialFirst:_onTriggerClick()
	if self._isClick then
		return 
	end
	self._isClick = true
	local index = 1
	while true do
		local fca_animtion = self._aniCcbOwner["fca_baozha_"..index]
		if fca_animtion then
			local fca = tolua.cast(fca_animtion, "QFcaSkeletonView_cpp")
			fca:stopAnimation()
			fca:playAnimation(string.split(fca:getAvailableAnimationNames(), ";")[1], false)
			index = index + 1
		else
			break
		end
	end
	
	self._effectManager:runAnimationsForSequenceNamed("moqiu")
end

return QUIWidgetSoulTrialFirst
