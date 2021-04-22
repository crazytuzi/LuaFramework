
local QBaseSecretary = import(".QBaseSecretary")
local QStormArenaFastFightSecretary = class("QStormArenaFastFightSecretary", QBaseSecretary)

local QUIWidgetSecretarySettingTitle = import("..ui.widgets.QUIWidgetSecretarySettingTitle")
local QUIWidgetSecretarySetting = import("..ui.widgets.QUIWidgetSecretarySetting")

function QStormArenaFastFightSecretary:ctor(options)
	QStormArenaFastFightSecretary.super.ctor(self, options)
end

function QStormArenaFastFightSecretary:_onTriggerSelect( )

    local stormInfo = remote.secretary:getSecretaryInfo().stormSecretary or {}
    if (stormInfo.rank and stormInfo.rank >= 10000 ) or stormInfo.rank == nil then
        local setting = {}
        setting.isOpen = false
        remote.secretary:updateSecretarySetting(self._secretaryId, setting)
        app.tip:floatTip("索托斗魂场排名已重置，提升名次才可使用小助手哦~")
        return
    end  
 
    local curSetting = remote.secretary:getSettingBySecretaryId(self._secretaryId)
    local isOpen = curSetting.isOpen or false
    local setting = {}
    setting.isOpen = not isOpen
    remote.secretary:updateSecretarySetting(self._secretaryId, setting)
end

-- 索托扫荡
function QStormArenaFastFightSecretary:executeSecretary()
    local callback = function(data)
    	QPrintTable(data)
        -- if data.arenaResponse then
        --     remote.arena:updateSelf(data.arenaResponse.mySelf)
        -- end
        if data.secretaryItemsLogResponse then
            local countTbl = string.split(data.secretaryItemsLogResponse.secretaryLog.param, ";")
            local count = tonumber(countTbl[1]) or 1
            remote.user:addPropNumForKey("todayStormFightCount", count)
            remote.user:addPropNumForKey("addupArenaFightCount", count)
            
            -- remote.activity:updateLocalDataByType(543, count)
            app.taskEvent:updateTaskEventProgress(app.taskEvent.STORM_ARENA_TASK_EVENT, count, false, true)
        end
        remote.secretary:updateSecretaryLog(data) 
        remote.secretary:nextTaskRunning()
    end

    local secretaryInfo = remote.secretary:getSecretaryInfo()
    local arenaInfo = secretaryInfo.stormSecretary or {}
    local freeCount = db:getConfiguration().STORM_ARENA_FREE_FIGHT_COUNT.value or 0
    local curSetting = remote.secretary:getSettingBySecretaryId(self._config.id)
    local chooseNum = curSetting.chooseNum or 1
    local autoGetScore = true

	local nowTime = q.serverTime() 
    local nowDateTable = q.date("*t", nowTime)
	if ( nowDateTable.hour == 21 and nowDateTable.min < 16 ) then
		remote.secretary:nextTaskRunning()
		return
	end

    -- 排名10000以内表示打过了索托斗魂场
    if arenaInfo.rank < 10000 then
        self:sotormQuickFightBySecretaryRequest(chooseNum == 2, callback)
    else
        remote.secretary:nextTaskRunning()
    end
end

-- 竞技场一键扫荡
function QStormArenaFastFightSecretary:sotormQuickFightBySecretaryRequest(buyFiveCount, success)
    local stormQuickFightRequest = {buyFiveCount = buyFiveCount,isSecretary = true}
    local gfQuickRequest = {battleType = BattleTypeEnum.STORM, stormQuickFightRequest = stormQuickFightRequest}
    local request = {api = "GLOBAL_FIGHT_QUICK", gfQuickRequest = gfQuickRequest}
    fail = function(data)
        remote.secretary:executeInterruption()
    end

    app:getClient():requestPackageHandler("GLOBAL_FIGHT_QUICK", request, success, fail)
end

function QStormArenaFastFightSecretary:refreshWidgetData(widget, itemData, index)
    QStormArenaFastFightSecretary.super.refreshWidgetData(self, widget, itemData, index)
    if widget then
		local stormInfo = remote.secretary:getSecretaryInfo().stormSecretary or {}
		widget:setRankStr(true, stormInfo.rank or 0)
        local curSetting = remote.secretary:getSettingBySecretaryId(self._secretaryId)
		local chooseNum = curSetting.chooseNum or 1
		if chooseNum == 2 then
			widget:setDescStr("扫荡10次")
		else
			widget:setDescStr("扫荡5次")
		end
    end
end

function QStormArenaFastFightSecretary:getSettingWidgets()
	local widgets = {}

	local titleWidget = QUIWidgetSecretarySettingTitle.new()
	titleWidget:setInfo("索托设置")
	local titleHeight = titleWidget:getContentSize().height
	table.insert(widgets, titleWidget)

    self._chooseWidgetList = {}
    local curSetting = remote.secretary:getSettingBySecretaryId(self._config.id)
	self._curChoose = curSetting.chooseNum or 1
	self._autoGetScore = true

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
    -- self._scoreWidget:addEventListener(QUIWidgetSecretarySetting.EVENT_SELECT_CLICK, handler(self, self.scoreItemClickHandler))
	self._scoreWidget:setInfo({desc = "领取积分奖励"})
	self._scoreWidget:setPosition(ccp(60, -totalHeight))
	self._scoreWidget:setSelected(true)
	table.insert(widgets, self._scoreWidget)

	return widgets
end

function QStormArenaFastFightSecretary:chooseItemClickHandler(event)
    if not event or not event.index then
        return
    end
    self._curChoose = event.index
    self:updateChooseInfo()
end

-- function QStormArenaFastFightSecretary:scoreItemClickHandler(event)
-- 	self._autoGetScore = not self._autoGetScore
-- 	self._scoreWidget:setSelected(self._autoGetScore)
-- end

function QStormArenaFastFightSecretary:updateChooseInfo()
    for i, widget in pairs(self._chooseWidgetList) do
        local index = widget:getIndex()
        widget:setSelected(self._curChoose == index)
    end
end

function QStormArenaFastFightSecretary:saveSecretarySetting()
    local setting = {}
	setting.chooseNum = self._curChoose
	setting.autoGetScore = self._autoGetScore
    remote.secretary:updateSecretarySetting(self._config.id, setting)
end

return QStormArenaFastFightSecretary