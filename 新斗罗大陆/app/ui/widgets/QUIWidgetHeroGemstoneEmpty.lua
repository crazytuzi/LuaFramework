local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetHeroGemstoneEmpty = class("QUIWidgetHeroGemstoneEmpty", QUIWidget)
local QUIViewController = import("..QUIViewController")

function QUIWidgetHeroGemstoneEmpty:ctor(options)
	local ccbFile = "ccb/Widget_Baoshi_Qianghua_1.ccbi"
	local callBacks = {
			{ccbCallbackName = "onTriggerTouch", callback = handler(self, QUIWidgetHeroGemstoneEmpty._onTriggerTouch)},
		}
	QUIWidgetHeroGemstoneEmpty.super.ctor(self,ccbFile,callBacks,options)
	-- setShadow5(self._ccbOwner.tf_desc)
end

function QUIWidgetHeroGemstoneEmpty:setInfo(actorId, gemstoneSid, gemstonePos)
	self._actorId = actorId
	self._gemstoneSid = gemstoneSid
	self._gemstonePos = gemstonePos
end

function QUIWidgetHeroGemstoneEmpty:_onTriggerTouch(e)
	if e ~= nil then
		app.sound:playSound("common_common")
	end
	local UIHeroModel = remote.herosUtil:getUIHeroByID(self._actorId)
	local gemstoneInfo = UIHeroModel:getGemstoneInfoByPos(self._gemstonePos)
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogGemstoneFastBag", 
        options = {canType = gemstoneInfo.canType, actorId = self._actorId, pos = self._gemstonePos}})
end

return QUIWidgetHeroGemstoneEmpty