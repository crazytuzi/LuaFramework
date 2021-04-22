-- @Author: liaoxianbo
-- @Date:   2019-08-08 16:49:31
-- @Last Modified by:   vicentboo
-- @Last Modified time: 2019-08-22 18:45:15
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetSoulSpriteHead = class("QUIWidgetSoulSpriteHead", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QUIWidgetBlackRockOverView = import("..widgets.QUIWidgetBlackRockOverView")

function QUIWidgetSoulSpriteHead:ctor(options)
	local ccbFile = "ccb/Widget_SoulPriteHead.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerProduce", callback = handler(self, self.onTriggerProduce)},
    }
    QUIWidgetSoulSpriteHead.super.ctor(self, ccbFile, callBacks, options)
  
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

end

function QUIWidgetSoulSpriteHead:setSoulInfo(sourId)
	self._soulId = sourId
	local characterConfig = QStaticDatabase.sharedDatabase():getCharacterByID(sourId)
	QSetDisplayFrameByPath(self._ccbOwner.sp_soul_image,characterConfig.icon)

	local aptitudeInfo = QStaticDatabase.sharedDatabase():getSABCByQuality(characterConfig.aptitude)
	if aptitudeInfo.lower == "s" then
	    QSetDisplayFrameByPath(self._ccbOwner.sp_soul_frame ,"ui/common/hl_h_glod.png")
	else
		 QSetDisplayFrameByPath(self._ccbOwner.sp_soul_frame ,"ui/common/hl_h_purper.png")
	end
end

function QUIWidgetSoulSpriteHead:onTriggerProduce( ... )
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogBlackSoulSpiritDetail", 
        	options={id = self._soulId}})
end
function QUIWidgetSoulSpriteHead:onEnter()
end

function QUIWidgetSoulSpriteHead:onExit()
end

function QUIWidgetSoulSpriteHead:getContentSize()
end

return QUIWidgetSoulSpriteHead
