--
-- Author: MOUSECUTE
-- Date: 2016-07-28
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetSilverRegionalRecord = class("QUIWidgetSilverRegionalRecord", QUIWidget)
local QRichText = import("...utils.QRichText")

QUIWidgetSilverRegionalRecord.GAP = 6

function QUIWidgetSilverRegionalRecord:ctor(options)
	local ccbFile = "ccb/Widget_SilverMine_kqzb.ccbi"
	local callBacks = {
	}
	QUIWidgetSilverRegionalRecord.super.ctor(self, ccbFile, callBacks, options)

	self._parent = options.parent
	self._record = options.record
	self._time = options.time or -1
	self._type = REPORT_TYPE.SILVERMINE
	self._replayId = options.replay
	self._mineId = options.mineId
	self._winnerIsAttacker = options.winnerIsAttacker
	self._nickNameWin = options.nickNameWin
	self._forceWin = options.forceWin or 0
	self._nickNameLose = options.nickNameLose
	self._forceLose = options.forceLose or 0

	self:_setInfo(self._time, self._mineId, self._nickNameWin, self._forceWin, self._nickNameLose, self._forceLose, self._winnerIsAttacker)
	self._ccbOwner.node_bg:setVisible(options.bgVisible)
end

function QUIWidgetSilverRegionalRecord:_setInfo(time, mineId, nickNameWin, forceWin, nickNameLose, forceLose, winnerIsAttacker)
	local richText = QRichText.new(nil, 650, {stringType = 1, defaultColor = COLORS.j, defaultSize = 20})
	richText:setAnchorPoint(0,1)
	self._ccbOwner.content:addChild(richText)

	local mineConfig = remote.silverMine:getMineConfigByMineId(self._mineId)
	if mineConfig == nil then return end
	local stringFormat = "##n%s %s ##e%s（战力%s）##n击败了 ##K%s（战力%s）##n%s了%s"
	local time = q.date("%H:%M", time/1000)
	local verb = winnerIsAttacker and "夺得" or "守住"
	local mineQuality = remote.silverMine:getMineCNNameByQuality(mineConfig.mine_quality)
	local forceWin, unit = q.convertLargerNumber(forceWin)
	forceWin = tostring(forceWin)..(unit or "")
	local forceLose, unit = q.convertLargerNumber(forceLose)
	forceLose = tostring(forceLose)..(unit or "")
	stringFormat = string.format(stringFormat, time, mineConfig.mine_name, nickNameWin, forceWin, nickNameLose, forceLose, verb, mineQuality)
	richText:setString(stringFormat)
end

function QUIWidgetSilverRegionalRecord:getContentSize()
	return self._ccbOwner.node_bg:getContentSize()
end

return QUIWidgetSilverRegionalRecord