local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetNightmareRecord = class("QUIWidgetNightmareRecord", QUIWidget)
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetAvatar = import("..widgets.QUIWidgetAvatar")
local QUIViewController = import("..QUIViewController")

function QUIWidgetNightmareRecord:ctor(options)
 	local ccbFile = "ccb/Widget_Nightmare_client.ccbi"
	local callBacks = {
	    {ccbCallbackName = "onTriggerUser", callback = handler(self, QUIWidgetNightmareRecord._onTriggerUser)},
	    -- {ccbCallbackName = "onTriggerConfirm", callback = handler(self, QUIWidgetNightmareRecord._onTriggerConfirm)},
	}
	QUIWidgetNightmareRecord.super.ctor(self, ccbFile, callBacks, options)

	-- self._ccbOwner.sp_first
	-- self._ccbOwner.sp_second
	-- self._ccbOwner.sp_third
	-- self._ccbOwner.tf_level
	-- self._ccbOwner.tf_name
	-- self._ccbOwner.tf_vip
	-- self._ccbOwner.tf_time
	-- self._ccbOwner.sp_badge
	-- self._ccbOwner.node_head

end

function QUIWidgetNightmareRecord:setFighter(fighter, index, isShowForce)
	self._fighter = fighter
	self._ccbOwner.sp_first:setVisible(false)
	self._ccbOwner.sp_second:setVisible(false)
	self._ccbOwner.sp_third:setVisible(false)
	if index == 1 then
		self._ccbOwner.sp_first:setVisible(true)
	elseif index == 2 then
		self._ccbOwner.sp_second:setVisible(true)
	elseif index == 3 then
		self._ccbOwner.sp_third:setVisible(true)
	end
	self._ccbOwner.tf_level:setString("LV."..(fighter.level or ""))
	self._ccbOwner.tf_name:setString(fighter.name or "")
	self._ccbOwner.tf_vip:setString("VIP "..(fighter.vip or ""))
	if isShowForce == true then
		local force = (fighter.force or 0)
		local num,unit = q.convertLargerNumber(force)
		self._ccbOwner.tf_time:setString("战力："..num..(unit or ""))
	else
		local lastTime = {}
		if fighter.lastPassAt ~= nil then
			lastTime = q.date("*t", fighter.lastPassAt/1000)
		end
		self._ccbOwner.tf_time:setString(string.format("击杀时间：%d/%d/%d  %d:%d", (lastTime.year or 0), (lastTime.month or 0), (lastTime.day or 0), (lastTime.hour or 0), (lastTime.min or 0)))
	end
	local config = QStaticDatabase:sharedDatabase():getBadgeByCount(fighter.nightmareDungeonPassCount or 0)
	if config ~= nil then
		self._ccbOwner.sp_badge:setVisible(true)
		self._ccbOwner.sp_badge:setTexture(CCTextureCache:sharedTextureCache():addImage(config.alphaicon))
	else
		self._ccbOwner.sp_badge:setVisible(false)
	end
	self._ccbOwner.node_head:removeAllChildren()
	local avatar = QUIWidgetAvatar.new(fighter.avatar)
	avatar:setSilvesArenaPeak(fighter.championCount)
	self._ccbOwner.node_head:addChild(avatar)
end

function QUIWidgetNightmareRecord:resetAll()
	self._ccbOwner.sp_first:setVisible(false)
	self._ccbOwner.sp_second:setVisible(false)
	self._ccbOwner.sp_third:setVisible(false)
	self._ccbOwner.sp_badge:setVisible(false)
	self._ccbOwner.tf_time:setString("")
end

function QUIWidgetNightmareRecord:_onTriggerUser()
	local info = {}
	info.name = self._fighter.name
	info.level = self._fighter.level
	info.vip = self._fighter.vip
	info.avatar = self._fighter.avatar
	info.number = self._fighter.level
	info.force = self._fighter.teamForce
	info.heros = self._fighter.heros or {}
	info.subheros = self._fighter.subheros or {}
	info.consortiaName = self._fighter.consortiaName
	info.sub2heros = self._fighter.sub2heros or {}
	info.sub3heros = self._fighter.sub3heros or {}
	info.text = "战队等级"

	app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogNightmareFigterInfo",
	options = {info = info}}, {isPopCurrentDialog = false})
end

return QUIWidgetNightmareRecord