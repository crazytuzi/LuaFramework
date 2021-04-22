--
-- Author: Kumo.Wang
-- 仙品养成空界面
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetHeroMagicHerbEmpty = class("QUIWidgetHeroMagicHerbEmpty", QUIWidget)
local QUIViewController = import("..QUIViewController")

function QUIWidgetHeroMagicHerbEmpty:ctor(options)
	local ccbFile = "ccb/Widget_MagicHerb_Empty.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerTouch", callback = handler(self, QUIWidgetHeroMagicHerbEmpty._onTriggerTouch)},
	}
	QUIWidgetHeroMagicHerbEmpty.super.ctor(self,ccbFile,callBacks,options)
end

function QUIWidgetHeroMagicHerbEmpty:setInfo(actorId, pos)
	self._actorId = actorId
	self._pos = pos
end

function QUIWidgetHeroMagicHerbEmpty:_onTriggerTouch(e)
	if e ~= nil then
		app.sound:playSound("common_common")
	end
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMagicHerbCheckroom", 
        options = {actorId = self._actorId, pos = self._pos}})
end

return QUIWidgetHeroMagicHerbEmpty