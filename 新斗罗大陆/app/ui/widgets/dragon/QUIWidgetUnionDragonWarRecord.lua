-- @Author: xurui
-- @Date:   2017-03-06 09:49:26
-- @Last Modified by:   zhouxiaoshu
-- @Last Modified time: 2019-06-20 11:34:26
local QUIWidget = import("...widgets.QUIWidget")
local QUIWidgetUnionDragonWarRecord = class("QUIWidgetUnionDragonWarRecord", QUIWidget)

local QNavigationController = import("....controllers.QNavigationController")
local QUIViewController = import("...QUIViewController")
local QUnionAvatar = import("....utils.QUnionAvatar")
local QUIWidgetFloorIcon = import("...widgets.QUIWidgetFloorIcon")
local QReplayUtil = import("....utils.QReplayUtil")

QUIWidgetUnionDragonWarRecord.EVENT_SHARE = "EVENT_SHARE"
QUIWidgetUnionDragonWarRecord.EVENT_REPLAY = "EVENT_REPLAY"

local REPLAY_CD_LIMIT = "%d分钟内只允许发送%d条战报，%s后可以发送"
local REPLAY_CD = 5 -- 5m
local REPLAY_COUNT = 5

function QUIWidgetUnionDragonWarRecord:ctor(options)
	local ccbFile = "ccb/Widget_society_dragontrain_zhanbao.ccbi"
	local callBack = {
		{ccbCallbackName = "onTriggerShare", callback = handler(self, self._onTriggerShare)},
		{ccbCallbackName = "onTriggerDetail", callback = handler(self, self._onTriggerDetail)},
	}
	QUIWidgetUnionDragonWarRecord.super.ctor(self, ccbFile, callBack, options)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
end

function QUIWidgetUnionDragonWarRecord:setInfo(info)
	self._info = info or {}
	self._replayId = info.matchingId

	local winState = false
	if self._info.consortiaBattle1.consortiaId == remote.user.userConsortia.consortiaId then
		self._info.consortia = self._info.consortiaBattle2 or {}
		winState = remote.unionDragonWar:getFightResult(self._info.consortiaBattle1, self._info.consortiaBattle2)
	else
		self._info.consortia = self._info.consortiaBattle1 or {}
		winState = remote.unionDragonWar:getFightResult(self._info.consortiaBattle2, self._info.consortiaBattle1)
	end

	self._ccbOwner.win_flag:setVisible(winState)
	self._ccbOwner.lose_flag:setVisible(not winState)

	local name = self._info.consortia.consortiaName or ""
	local areaName = self._info.consortia.gameAreaName or ""
	local level = self._info.consortia.level or 0
	local icon = self._info.consortia.icon or -1
 	local floor = self._info.consortia.floor or 1
	local endAt = self._info.consortia.dragonKilledAt or 0
	self._ccbOwner.tf_union_level:setString("LV."..(level or ""))
	self._ccbOwner.tf_union_name:setString(name or "")
	self._ccbOwner.tf_sever:setString(areaName)
	self._ccbOwner.tf_fight_end_time:setString(q.date("%Y.%m.%d", endAt/1000))

	if self._unionAvatar == nil then
		self._unionAvatar = QUnionAvatar.new()
		self._ccbOwner.node_avatar:addChild(self._unionAvatar)
		self._ccbOwner.node_avatar:setScale(0.7)
	end
	self._unionAvatar:setInfo(icon)
	self._unionAvatar:setConsortiaWarFloor(self._info.consortia.consortiaWarFloor)

	-- 段位icon
	if self._floorIcon == nil then
		self._floorIcon = QUIWidgetFloorIcon.new({isLarge = true})
		self._ccbOwner.node_floor:removeAllChildren()
 		self._ccbOwner.node_floor:addChild(self._floorIcon)
 	end
	self._floorIcon:setInfo(floor, "unionDragonWar")
	self._floorIcon:setShowName(false)
end

function QUIWidgetUnionDragonWarRecord:getContentSize()
	return self._ccbOwner.background:getContentSize()
end

function QUIWidgetUnionDragonWarRecord:_onTriggerShare()
    app.sound:playSound("common_small")

	local earliestTime, replayCount = app:getServerChatData():getEarliestReplaySentTime()
	if replayCount >= REPLAY_COUNT and q.serverTime() - earliestTime < REPLAY_CD * 60 then
		app.tip:floatTip(string.format(REPLAY_CD_LIMIT, REPLAY_CD, REPLAY_COUNT, q.timeToHourMinuteSecond(REPLAY_CD * 60 - (q.serverTime() - earliestTime), true)))
		return
	end

	local nickName = self._info.consortia.consortiaName or ""
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogReplayShare", 
		options = {rivalName = nickName, myNickName = remote.user.userConsortia.consortiaName, replayId = self._replayId, replayType = REPORT_TYPE.DRAGON_WAR}}, {isPopCurrentDialog = false})
end

function QUIWidgetUnionDragonWarRecord:_onTriggerDetail()
    app.sound:playSound("common_small")
	
	remote.unionDragonWar:openUnionDragonWarFightReport(self._replayId)
end

return QUIWidgetUnionDragonWarRecord