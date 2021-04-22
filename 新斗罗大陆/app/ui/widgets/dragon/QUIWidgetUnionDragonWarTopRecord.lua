-- @Author: xurui
-- @Date:   2017-03-06 09:49:26
-- @Last Modified by:   zhouxiaoshu
-- @Last Modified time: 2019-06-04 10:27:29
local QUIWidget = import("...widgets.QUIWidget")
local QUIWidgetUnionDragonWarTopRecord = class("QUIWidgetUnionDragonWarTopRecord", QUIWidget)

local QNavigationController = import("....controllers.QNavigationController")
local QUIViewController = import("...QUIViewController")
local QUIWidgetAvatar = import("...widgets.QUIWidgetAvatar")
local QUIWidgetFloorIcon = import("...widgets.QUIWidgetFloorIcon")
local QReplayUtil = import("....utils.QReplayUtil")

QUIWidgetUnionDragonWarTopRecord.EVENT_SHARE = "EVENT_SHARE"
QUIWidgetUnionDragonWarTopRecord.EVENT_REPLAY = "EVENT_REPLAY"

local REPLAY_CD_LIMIT = "%d分钟内只允许发送%d条战报，%s后可以发送"
local REPLAY_CD = 5 -- 5m
local REPLAY_COUNT = 5

function QUIWidgetUnionDragonWarTopRecord:ctor(options)
	local ccbFile = "ccb/Widget_TopRecord_longzhan.ccbi"
	local callBack = {
		{ccbCallbackName = "onTriggerShare", callback = handler(self, self._onTriggerShare)},
		{ccbCallbackName = "onTriggerReplay", callback = handler(self, self._onTriggerReplay)},
	}
	QUIWidgetUnionDragonWarTopRecord.super.ctor(self, ccbFile, callBack, options)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
end

function QUIWidgetUnionDragonWarTopRecord:setInfo(info)
	self._info = info
	local paramTbl = string.split(info.param, ":")
	local hurtNum = tonumber(paramTbl[1]) or 0

	if not self._head then
		self._head = QUIWidgetAvatar.new()
		self._ccbOwner.node_avatar:addChild(self._head)
	end
	self._head:setInfo(info.fighter1.avatar)
	self._head:setSilvesArenaPeak(info.fighter1.championCount)

	local nameStr = string.format("LV.%d %s", info.fighter1.level, info.fighter1.name or "")
	self._ccbOwner.tf_name:setString(nameStr)

    local force, unit = q.convertLargerNumber(hurtNum)
	self._ccbOwner.tf_num:setString(force..unit)
end

function QUIWidgetUnionDragonWarTopRecord:getContentSize()
	return self._ccbOwner.background:getContentSize()
end

function QUIWidgetUnionDragonWarTopRecord:_onTriggerHead()
    app.sound:playSound("common_small")

    local reportType = REPORT_TYPE.DRAGON_WAR
    local reportId = self._info.fightReportId
    QReplayUtil:downloadReplay(reportId, function (replay, replayInfo)
        if replayInfo then
            local fighter = QReplayUtil:getFighterFromReplayInfo(replayInfo, true)
            app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogPlayerInfo",
    			options = {fighter = fighter}}, {isPopCurrentDialog = false})
        end
    end, nil, reportType, true)
end

function QUIWidgetUnionDragonWarTopRecord:_onTriggerShare()
    app.sound:playSound("common_small")
	
	local paramTbl = string.split(self._info.param, ":")
	local reportType = REPORT_TYPE.DRAGON_WAR
	local reportId = self._info.fightReportId
	local nickname = self._info.fighter1.name
	local unionName = paramTbl[2]
	QReplayUtil:getReplayInfo(reportId, function (data)
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogReplayShare", 
			options = {rivalName = unionName, myNickName = nickname, replayId = reportId, replayType = reportType}}, {isPopCurrentDialog = false})
	end, nil, reportType)
end

function QUIWidgetUnionDragonWarTopRecord:_onTriggerReplay()
    app.sound:playSound("common_small")
	app:triggerBuriedPoint(21613)

	local reportType = REPORT_TYPE.DRAGON_WAR
	local reportId = self._info.fightReportId
	QReplayUtil:getReplayInfo(reportId, function (data)
		QReplayUtil:downloadReplay(reportId, function (replay)
			QReplayUtil:play(replay, data.scoreList, data.fightReportStats, true)
		end, nil, reportType)
	end, nil, reportType)
end

return QUIWidgetUnionDragonWarTopRecord