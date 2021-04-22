--
-- Author: wkwang
-- Date: 2014-08-29 16:57:29
--
local QUIWidget = import(".QUIWidget")
local QUIWidgetEliteInfoStar = class("QUIWidgetEliteInfoStar", QUIWidget)

function QUIWidgetEliteInfoStar:ctor(options)
	local ccbFile = "ccb/Widget_EliteInfo_star.ccbi"
	local callBacks = {}
	QUIWidgetEliteInfoStar.super.ctor(self, ccbFile, callBacks, options)

    self._animationManager = tolua.cast(self._ccbView:getUserObject(), "CCBAnimationManager")
end

function QUIWidgetEliteInfoStar:showStar(num,isHide)
	if isHide == nil then 
		isHide = true
	end
	for i = 1,3,1 do
		if i <= num then
			self._ccbOwner["star"..i]:setVisible(true)
		else
			makeNodeFromNormalToGray(self._ccbOwner["star"..i])
			self._ccbOwner["star"..i]:setVisible(isHide)
	 	end 
	end
end

function QUIWidgetEliteInfoStar:stop()
    self._animationManager:runAnimationsForSequenceNamed("normal")
end

function QUIWidgetEliteInfoStar:play()
    self._animationManager:runAnimationsForSequenceNamed("play")
end

return QUIWidgetEliteInfoStar