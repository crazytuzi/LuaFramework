-- @Author: xurui
-- @Date:   2016-12-22 16:31:16
-- @Last Modified by:   xurui
-- @Last Modified time: 2016-12-29 14:02:20
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetPlunderRegionalRecord = class("QUIWidgetPlunderRegionalRecord", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QRichText = import("...utils.QRichText")

function QUIWidgetPlunderRegionalRecord:ctor(options)
	local ccbFile = "ccb/Widget_plunder_zb.ccbi"
	local callBacks = {
	}
	QUIWidgetPlunderRegionalRecord.super.ctor(self, ccbFile, callBacks, options)

	self._parent = options.parent
	self._time = options.time or -1
	self._type = REPORT_TYPE.SILVERMINE
	self._replayId = options.replay
	self._mineId = options.mineId
	self._winnerIsAttacker = options.winnerIsAttacker
	self._nickNameWin = options.nickNameWin
	self._forceWin = options.forceWin or 0
	self._forceLose = options.forceLose or 0
	self._nickNameLose = options.nickNameLose
	self._areaNameWin = options.areaNameWin or ""
	self._areaNameLose = options.areaNameLose or ""
	self._reportType = options.reportType or 0  -- 1, 占领； 2，掠夺
	self._score = options.score

	self:_setInfo(self._time, self._mineId, self._nickNameWin, self._forceWin, self._nickNameLose, self._forceLose, self._winnerIsAttacker)
	self._ccbOwner.node_bg:setVisible(options.bgVisible)
end

function QUIWidgetPlunderRegionalRecord:_setInfo(time, mineId, nickNameWin, forceWin, nickNameLose, forceLose, winnerIsAttacker)
	local richText = QRichText.new(nil, 640, {stringType = 1, defaultColor = COLORS.j, defaultSize = 20})
	richText:setAnchorPoint(0,1)
	self._ccbOwner.content:addChild(richText)

	local mineConfig = remote.plunder:getMineConfigByMineId(self._mineId)
	if mineConfig == nil then return end
	local stringFormat = "##n%s %s ##e%s（战力%s,%s）##n击败了 ##K%s（战力%s,%s）##n%s"
	local time = q.date("%H:%M", time/1000)
	local verb = winnerIsAttacker and "占领了" or "守住了"
	if self._reportType == 1 then
		local mineQuality = remote.plunder:getMineCNNameByQuality(mineConfig.mine_quality)
		verb = verb.."##e"..mineQuality
	else
		if winnerIsAttacker then
			verb = "掠夺了##e"..self._score.."##n冰髓"
		else
			verb = "防守成功"
		end
	end

	local forceWin, unit = q.convertLargerNumber(forceWin)
	forceWin = tostring(forceWin)..(unit or "")
	local forceLose, unit = q.convertLargerNumber(forceLose)
	forceLose = tostring(forceLose)..(unit or "")
	stringFormat = string.format(stringFormat, time, mineConfig.mine_name, nickNameWin, forceWin, self._areaNameWin, nickNameLose, forceLose, self._areaNameLose, verb)
	richText:setString(stringFormat)
end

function QUIWidgetPlunderRegionalRecord:getContentSize()
	return self._ccbOwner.node_bg:getContentSize()
end

return QUIWidgetPlunderRegionalRecord