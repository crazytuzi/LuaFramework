-- @Author: xurui
-- @Date:   2017-02-14 14:49:14
-- @Last Modified by:   xurui
-- @Last Modified time: 2017-03-02 11:57:55
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetWorldBossGloryWall = class("QUIWidgetWorldBossGloryWall", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")

QUIWidgetWorldBossGloryWall.PERSONAL_RANK_TAB = "PERSONAL_RANK_TAB"
QUIWidgetWorldBossGloryWall.UNION_RANK_TAB = "UNION_RANK_TAB"

function QUIWidgetWorldBossGloryWall:ctor(options)
	local ccbFile = "ccb/Widget_panjun_Boss_rongyao.ccbi"
	local callBack = {
		{ccbCallbackName = "onTriggerPersonalGlory", callback = handler(self, self._onTriggerPersonalGlory)},
		{ccbCallbackName = "onTriggerUnionGlory", callback = handler(self, self._onTriggerUnionGlory)},
		{ccbCallbackName = "onTriggerClick", callback = handler(self, self._onTriggerClick)},
	}
	QUIWidgetWorldBossGloryWall.super.ctor(self, ccbFile, callBack, options)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._tab = QUIWidgetWorldBossGloryWall.PERSONAL_RANK_TAB

	self:resetRankInfo()
end

function QUIWidgetWorldBossGloryWall:onEnter()
end

function QUIWidgetWorldBossGloryWall:onExit()
end

function QUIWidgetWorldBossGloryWall:resetRankInfo()
	for i = 1, 5 do
		self._ccbOwner["tf_name_"..i]:setString("虚位以待")
		self._ccbOwner["tf_name_"..i]:setColor(COLORS.f)
	end
end

function QUIWidgetWorldBossGloryWall:setInfo()
	self:selectTab()
end

function QUIWidgetWorldBossGloryWall:selectTab()
	self:setButtonState()

	if self._tab == QUIWidgetWorldBossGloryWall.PERSONAL_RANK_TAB then
		self:getRankInfo("WORLD_BOSS_USER_HURT_TOP_50", 2)
	elseif self._tab == QUIWidgetWorldBossGloryWall.UNION_RANK_TAB then
		self:getRankInfo("WORLD_BOSS_CONSORTIA_HURT_TOP_50", 3)
	end
end

function QUIWidgetWorldBossGloryWall:getRankInfo(kind, awardsType)
	remote.worldBoss:requestWorldBossRank(kind, remote.user.userId, function(data)
			if self.class then
				if kind == "WORLD_BOSS_USER_HURT_TOP_50" then
					self._data = data.rankings
				elseif kind == "WORLD_BOSS_CONSORTIA_HURT_TOP_50"  then
					self._data = data.consortiaRankings
				end

				self:setRankInfo()
			end
		end)
end

function QUIWidgetWorldBossGloryWall:setRankInfo()
	if self._data == nil or next(self._data) == nil then return end

	local rankData = self._data.top50 or {}
	table.sort( rankData, function(a, b)
			return a.rank < b.rank
		end )

	for i = 1, 5 do
		if rankData[i] then
			self._ccbOwner["tf_name_"..i]:setString(rankData[i].name or "")
			self._ccbOwner["tf_name_"..i]:setColor(COLORS.b)
		else
			self._ccbOwner["tf_name_"..i]:setString("虚位以待")
			self._ccbOwner["tf_name_"..i]:setColor(COLORS.f)
		end
	end
end

function QUIWidgetWorldBossGloryWall:setButtonState()
	local personalRank = self._tab == QUIWidgetWorldBossGloryWall.PERSONAL_RANK_TAB
	local unionRank = self._tab == QUIWidgetWorldBossGloryWall.UNION_RANK_TAB

	self._ccbOwner.btn_personal_glory:setHighlighted(personalRank)
	self._ccbOwner.btn_personal_glory:setEnabled(not personalRank)

	self._ccbOwner.btn_union_glory:setHighlighted(unionRank)
	self._ccbOwner.btn_union_glory:setEnabled(not unionRank)
end

function QUIWidgetWorldBossGloryWall:_onTriggerPersonalGlory()
    app.sound:playSound("common_menu")
	if self._tab == QUIWidgetWorldBossGloryWall.PERSONAL_RANK_TAB then return end
	self._tab = QUIWidgetWorldBossGloryWall.PERSONAL_RANK_TAB

	self:selectTab()
end

function QUIWidgetWorldBossGloryWall:_onTriggerUnionGlory()
    app.sound:playSound("common_menu")
	if self._tab == QUIWidgetWorldBossGloryWall.UNION_RANK_TAB then return end
	self._tab = QUIWidgetWorldBossGloryWall.UNION_RANK_TAB

	self:selectTab()
end

function QUIWidgetWorldBossGloryWall:_onTriggerClick()
    app.sound:playSound("common_menu")

    local tab = "PERSONAL_RANK"
    if self._tab == QUIWidgetWorldBossGloryWall.UNION_RANK_TAB then
    	tab = "UNION_RANK"
    end
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogWorldBossRank",
    		options = {tab = tab}})
end

return QUIWidgetWorldBossGloryWall