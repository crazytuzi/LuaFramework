local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetNightmareBadgeList = class("QUIWidgetNightmareBadgeList", QUIWidget)

function QUIWidgetNightmareBadgeList:ctor(options)
 	local ccbFile = "ccb/Widget_Nightmare_huizhang.ccbi"
	local callBacks = {
	    -- {ccbCallbackName = "onTriggerClose", callback = handler(self, QUIWidgetNightmareBadgeList._onTriggerClose)},
	    -- {ccbCallbackName = "onTriggerConfirm", callback = handler(self, QUIWidgetNightmareBadgeList._onTriggerConfirm)},
	}
	QUIWidgetNightmareBadgeList.super.ctor(self, ccbFile, callBacks, options)

end

function QUIWidgetNightmareBadgeList:setInfo(value)
	self._ccbOwner.tf_name:setString(string.format("%s（累积通关%s可激活）", value.badge_name, value.number))
	local currentCount = math.min(remote.user.nightmareDungeonPassCount, value.number)
	self._ccbOwner.tf_progress:setString(string.format("进度%s/%s", currentCount, value.number))

	local isDone = (remote.user.nightmareDungeonPassCount or 0) >= value.number
	self._ccbOwner.node_weiwancheng:setVisible(not isDone)
	self._ccbOwner.node_done:setVisible(isDone)
	self._ccbOwner.sp_badge:setTexture(CCTextureCache:sharedTextureCache():addImage(value.alphaicon))
	self._ccbOwner.tf_prop1:setString("攻击＋"..value.attack_value)
	self._ccbOwner.tf_prop2:setString("生命＋"..value.hp_value)
	self._ccbOwner.tf_prop3:setString("物防＋"..value.armor_physical)
	self._ccbOwner.tf_prop4:setString("法防＋"..value.armor_magic)
end

function QUIWidgetNightmareBadgeList:getContentSize()
	return self._ccbOwner.normal_banner:getContentSize()
end

return QUIWidgetNightmareBadgeList