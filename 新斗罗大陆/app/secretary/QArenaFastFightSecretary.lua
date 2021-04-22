-- @Author: xurui
-- @Date:   2019-08-07 15:47:49
-- @Last Modified by:   xurui
-- @Last Modified time: 2020-01-20 21:04:20
local QBaseSecretary = import(".QBaseSecretary")
local QArenaFastFightSecretary = class("QArenaFastFightSecretary", QBaseSecretary)

local QUIWidgetSecretarySettingTitle = import("..ui.widgets.QUIWidgetSecretarySettingTitle")
local QUIWidgetSecretarySetting = import("..ui.widgets.QUIWidgetSecretarySetting")

function QArenaFastFightSecretary:ctor(options)
	QArenaFastFightSecretary.super.ctor(self, options)
end

-- 竞技场扫荡
function QArenaFastFightSecretary:executeSecretary()
    local callback = function(data)
        if data.arenaResponse then
            remote.arena:updateSelf(data.arenaResponse.mySelf)
        end
        if data.secretaryItemsLogResponse then
            local countTbl = string.split(data.secretaryItemsLogResponse.secretaryLog.param, ";")
            local count = tonumber(countTbl[1]) or 1
            remote.user:addPropNumForKey("todayArenaFightCount", count)
            remote.user:addPropNumForKey("addupArenaFightCount", count)
            
            remote.activity:updateLocalDataByType(543, count)

            app.taskEvent:updateTaskEventProgress(app.taskEvent.ARENA_TASK_EVENT, count, false, true)
        end
        remote.secretary:updateSecretaryLog(data, 2) 
        remote.secretary:nextTaskRunning()
    end

    local secretaryInfo = remote.secretary:getSecretaryInfo()
    local arenaInfo = secretaryInfo.arenaSecretary or {}
    local freeCount = db:getConfiguration().ARENA_FREE_FIGHT_COUNT.value or 0
    local curSetting = remote.secretary:getSettingBySecretaryId(self._config.id)
    local chooseNum = curSetting.chooseNum or 1
    local autoGetScore = curSetting.autoGetScore or true
    local count = freeCount + arenaInfo.fightCountBuy - arenaInfo.fightCount

    -- 10次是扫荡限制条件
    if arenaInfo.fightCount < 10 then
        self:arenaQuickFightBySecretaryRequest(chooseNum == 2, autoGetScore, callback)
    else
        remote.secretary:nextTaskRunning()
    end
end

-- 竞技场一键扫荡
function QArenaFastFightSecretary:arenaQuickFightBySecretaryRequest(buyFiveCount, getIntegralReward, success)
    local battleType = BattleTypeEnum.ARENA
    local arenaQuickFightBySecretaryRequest = {buyFiveCount = buyFiveCount, getIntegralReward = getIntegralReward}
    local gfQuickRequest = {battleType = battleType, isSecretary = true, arenaQuickFightBySecretaryRequest = arenaQuickFightBySecretaryRequest}
    local request = {api = "GLOBAL_FIGHT_QUICK", gfQuickRequest = gfQuickRequest}

    local fail = function(data)
        remote.secretary:executeInterruption()
    end

    app:getClient():requestPackageHandler("GLOBAL_FIGHT_QUICK", request, success, fail)
end

function QArenaFastFightSecretary:refreshWidgetData(widget, itemData, index)
    QArenaFastFightSecretary.super.refreshWidgetData(self, widget, itemData, index)
    if widget then
		local arenaInfo = remote.secretary:getSecretaryInfo().arenaSecretary or {}
		widget:setRankStr(true, arenaInfo.rank or 0)

        local curSetting = remote.secretary:getSettingBySecretaryId(self._secretaryId)
		local chooseNum = curSetting.chooseNum or 1
		if chooseNum == 2 then
			widget:setDescStr("扫荡10次")
		else
			widget:setDescStr("扫荡5次")
		end
    end
end

function QArenaFastFightSecretary:getSettingWidgets()
	local widgets = {}

	local titleWidget = QUIWidgetSecretarySettingTitle.new()
	titleWidget:setInfo("斗魂设置")
	local titleHeight = titleWidget:getContentSize().height
	table.insert(widgets, titleWidget)

    self._chooseWidgetList = {}
    local curSetting = remote.secretary:getSettingBySecretaryId(self._config.id)
	self._curChoose = curSetting.chooseNum or 1
	self._autoGetScore = curSetting.autoGetScore
	if self._autoGetScore == nil then
		self._autoGetScore = true
	end

	local totalHeight = titleHeight
	local data = {}
    table.insert(data, {desc = "扫荡5次", index = 1})
    table.insert(data, {desc = "扫荡10次", index = 2})
    local height = 0
	for i, setInfo in pairs(data) do
		local chooseWidget = QUIWidgetSecretarySetting.new()
        chooseWidget:addEventListener(QUIWidgetSecretarySetting.EVENT_SELECT_CLICK, handler(self, self.chooseItemClickHandler))
		chooseWidget:setInfo(setInfo)
		chooseWidget:setSelected(self._curChoose == setInfo.index)
		
		height = chooseWidget:getContentSize().height
		chooseWidget:setPositionX(60)
		chooseWidget:setPositionY(-totalHeight)
		if i == 2 then
			chooseWidget:setPositionX(280)
		end
		table.insert(widgets, chooseWidget)
		table.insert(self._chooseWidgetList, chooseWidget)
	end
    self:updateChooseInfo()
	totalHeight = totalHeight+height

	self._scoreWidget = QUIWidgetSecretarySetting.new()
    self._scoreWidget:addEventListener(QUIWidgetSecretarySetting.EVENT_SELECT_CLICK, handler(self, self.scoreItemClickHandler))
	self._scoreWidget:setInfo({desc = "领取积分奖励"})
	self._scoreWidget:setPosition(ccp(60, -totalHeight))
	self._scoreWidget:setSelected(self._autoGetScore)
	table.insert(widgets, self._scoreWidget)

	return widgets
end

function QArenaFastFightSecretary:chooseItemClickHandler(event)
    if not event or not event.index then
        return
    end
    self._curChoose = event.index
    self:updateChooseInfo()
end

function QArenaFastFightSecretary:scoreItemClickHandler(event)
	self._autoGetScore = not self._autoGetScore
	self._scoreWidget:setSelected(self._autoGetScore)
end

function QArenaFastFightSecretary:updateChooseInfo()
    for i, widget in pairs(self._chooseWidgetList) do
        local index = widget:getIndex()
        widget:setSelected(self._curChoose == index)
    end
end

function QArenaFastFightSecretary:saveSecretarySetting()
    local setting = {}
	setting.chooseNum = self._curChoose
	setting.autoGetScore = self._autoGetScore
    remote.secretary:updateSecretarySetting(self._config.id, setting)
end

return QArenaFastFightSecretary
