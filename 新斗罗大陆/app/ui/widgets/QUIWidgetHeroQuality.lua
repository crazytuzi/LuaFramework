local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetHeroQuality = class("QUIWidgetHeroQuality", QUIWidget)

function QUIWidgetHeroQuality:ctor(options)
	local ccbFile = "ccb/effects/Hero_pingzhi_big.ccbi"
	local callBacks = {
    }
	QUIWidgetHeroQuality.super.ctor(self, ccbFile, callBacks, options)

    self._animationManager = tolua.cast(self._ccbView:getUserObject(), "CCBAnimationManager")
    self._animationManager:runAnimationsForSequenceNamed("staticShow")
end

function QUIWidgetHeroQuality:setQuality(quality)
    q.setAptitudeShow(self._ccbOwner, quality)
end

function QUIWidgetHeroQuality:cleanQuality()
    q.setAptitudeShow(self._ccbOwner)
end

return QUIWidgetHeroQuality