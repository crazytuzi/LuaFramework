-- @Author: xurui
-- @Date:   2017-04-06 14:32:56
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2019-11-05 12:57:17
local QUIWidget = import("...widgets.QUIWidget")
local QUIWidgetHeroSparEmpty = class("QUIWidgetHeroSparEmpty", QUIWidget)
local QUIViewController = import("...QUIViewController")

function QUIWidgetHeroSparEmpty:ctor(options)
	local ccbFile = "ccb/Widget_Baoshi_Qianghua_1.ccbi"
	local callBacks = {
			{ccbCallbackName = "onTriggerTouch", callback = handler(self, QUIWidgetHeroSparEmpty._onTriggerTouch)},
		}
	QUIWidgetHeroSparEmpty.super.ctor(self,ccbFile,callBacks,options)
	-- setShadow5(self._ccbOwner.tf_desc)
	
	self._ccbOwner.tf_tips:setString("魂师大人，请为魂师装备外附魂骨")
	self._ccbOwner.tf_desc:setString("点击装备外附魂骨")

	self._ccbOwner.sp_item_bg:setVisible(false)
	if self._icon == nil then
		self._icon = CCSprite:create(QResPath("spar_item_shadow"))
		self._icon:setPosition(ccp(5, 5))
		self._ccbOwner.node_icon:addChild(self._icon)
	end
end

function QUIWidgetHeroSparEmpty:setInfo(actorId, sparId, sparPos)
	self._actorId = actorId
	self._sparId = sparId
	self._sparPos = sparPos

end

function QUIWidgetHeroSparEmpty:_onTriggerTouch(e)
	if e ~= nil then
		app.sound:playSound("common_common")
	end
	local UIHeroModel = remote.herosUtil:getUIHeroByID(self._actorId)
	local sparInfo = UIHeroModel:getSparInfoByPos(self._sparPos)

	if sparInfo.state == remote.spar.SPAR_CAN_WEAR then
	    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSparFastBag", 
	        options = {actorId = self._actorId, pos = self._sparPos}})
    elseif sparInfo.state == remote.spar.SPAR_LOCK then
		local unlockLevel = remote.spar:getUnlockHeroLevelByIndex(self._sparPos)
		app.tip:floatTip("魂师"..unlockLevel.."级才能融合外附魂骨~")
	end
end

return QUIWidgetHeroSparEmpty