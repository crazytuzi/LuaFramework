local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogNightmareBadgeList = class("QUIDialogNightmareBadgeList", QUIDialog)
local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetNightmareBadgeList = import("..widgets.QUIWidgetNightmareBadgeList")
local QListView = import("...views.QListView")

function QUIDialogNightmareBadgeList:ctor(options)
	local ccbFile = "ccb/Dialog_Nightmare_huizhang.ccbi";
	local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, QUIDialogNightmareBadgeList._onTriggerClose)},
	}
	QUIDialogNightmareBadgeList.super.ctor(self,ccbFile,callBacks,options)
	self.isAnimation = true

	local config = QStaticDatabase:sharedDatabase():getBadgeByCount(remote.user.nightmareDungeonPassCount)
	if config ~= nil then
		self._ccbOwner.node_self_info:setVisible(true)
		self._ccbOwner.node_no:setVisible(false)
		self._ccbOwner.sp_badge:setTexture(CCTextureCache:sharedTextureCache():addImage(config.alphaicon))
		-- self._ccbOwner.tf_prop1:setString("攻击＋"..config.attack_value)
		-- self._ccbOwner.tf_prop2:setString("生命＋"..config.hp_value)
		-- self._ccbOwner.tf_prop3:setString("物防＋"..config.armor_physical)
		-- self._ccbOwner.tf_prop4:setString("魔防＋"..config.armor_magic)
		self._ccbOwner.tf_prop1:setString(" ＋"..config.attack_value)
		self._ccbOwner.tf_prop4:setString(" ＋"..config.hp_value)
		self._ccbOwner.tf_prop2:setString(" ＋"..config.armor_physical)
		self._ccbOwner.tf_prop3:setString(" ＋"..config.armor_magic)
		self._ccbOwner.tf_name:setString(config.badge_name)
	else
		self._ccbOwner.node_self_info:setVisible(false)
		self._ccbOwner.node_no:setVisible(true)
	end

	self._configs = {}
	for _,value in pairs(QStaticDatabase:sharedDatabase():getBadge()) do
		table.insert(self._configs, value)
	end
	local number = remote.user.nightmareDungeonPassCount or 0
	table.sort(self._configs, function (a,b)
		if a.number > number and b.number <= number then
			return true
		elseif a.number <= number and b.number > number then
			return false
		elseif a.number > number and b.number > number then
			return a.number < b.number
		elseif a.number <= number and b.number <= number then
			return a.number > b.number
		end
	end)
	local cfg = {}
	cfg.renderItemCallBack = handler(self, self.renderItemCallBack)
	cfg.totalNumber = #self._configs
	cfg.topShadow = self._ccbOwner.top_shadow
	cfg.bottomShadow = self._ccbOwner.bottom_shadow
	self._contentListView = QListView.new(self._ccbOwner.sheet_layout,cfg)
end

function QUIDialogNightmareBadgeList:renderItemCallBack( list, index, info)
	local isCacheNode = true
	local data = self._configs[index]
	local item = list:getItemFromCache(tag)
	if not item then
		item = QUIWidgetNightmareBadgeList.new()
		isCacheNode = false
	end
	item:setInfo(data)
	info.item = item
	info.size = item:getContentSize()
	info.size.height = info.size.height + 8
	return isCacheNode
end

function QUIDialogNightmareBadgeList:_backClickHandler()
	self:_onTriggerClose()
end

function QUIDialogNightmareBadgeList:_onTriggerClose(e)
	if e ~= nil then app.sound:playSound("common_cancel") end
	self:playEffectOut()
end

return QUIDialogNightmareBadgeList