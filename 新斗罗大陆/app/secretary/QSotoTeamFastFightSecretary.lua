-- @Author: liaoxianbo
-- @Date:   2020-06-04 10:40:05
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-06-24 11:21:05

local QBaseSecretary = import(".QBaseSecretary")
local QSotoTeamFastFightSecretary = class("QSotoTeamFastFightSecretary", QBaseSecretary)

local QUIWidgetSecretarySettingTitle = import("..ui.widgets.QUIWidgetSecretarySettingTitle")
local QUIWidgetSecretarySetting = import("..ui.widgets.QUIWidgetSecretarySetting")

function QSotoTeamFastFightSecretary:ctor(options)
	QSotoTeamFastFightSecretary.super.ctor(self, options)
end

function QSotoTeamFastFightSecretary:_onTriggerSelect( )

    local sotoTeamInfo = remote.secretary:getSecretaryInfo().sotoTeamSecretary or {}
    if (sotoTeamInfo.rank and sotoTeamInfo.rank >= 10000 ) or sotoTeamInfo.rank == nil or (sotoTeamInfo.rank and sotoTeamInfo.rank == 0 ) then
        local setting = {}
        setting.isOpen = false
        remote.secretary:updateSecretarySetting(self._secretaryId, setting)
        app.tip:floatTip("云顶排名已重置，提升名次才可使用小助手哦~")
        return
    end     
 
    local curSetting = remote.secretary:getSettingBySecretaryId(self._secretaryId)
    local isOpen = curSetting.isOpen or false
    local setting = {}
    setting.isOpen = not isOpen
    remote.secretary:updateSecretarySetting(self._secretaryId, setting)
end
-- 云顶扫荡
function QSotoTeamFastFightSecretary:executeSecretary()
    local callback = function(data)
    	QPrintTable(data)
        if data.secretaryItemsLogResponse then
            local countTbl = string.split(data.secretaryItemsLogResponse.secretaryLog.param, ";")
            local count = tonumber(countTbl[1]) or 1
            remote.user:addPropNumForKey("todaySotoTeamFightCount", count)
            app.taskEvent:updateTaskEventProgress(app.taskEvent.SOTO_TEAM_TASK_EVENT, count, false, true)
        end
        remote.secretary:updateSecretaryLog(data) 
        remote.secretary:nextTaskRunning()
    end

    local secretaryInfo = remote.secretary:getSecretaryInfo()
    local arenaInfo = secretaryInfo.sotoTeamSecretary or {}
    local curSetting = remote.secretary:getSettingBySecretaryId(self._config.id)
    local chooseNum = curSetting.chooseNum or 1
    local autoGetScore = true

	local nowTime = q.serverTime() 
    local nowDateTable = q.date("*t", nowTime)
	if ( nowDateTable.hour == 21 and nowDateTable.min < 16 ) then
		remote.secretary:nextTaskRunning()
		return
	end

    -- 排名10000以内表示打过了云顶
    if arenaInfo.rank < 10000 then
        self:sotormQuickFightBySecretaryRequest(chooseNum == 2, callback)
    else
        remote.secretary:nextTaskRunning()
    end
end

-- 云顶一键扫荡
function QSotoTeamFastFightSecretary:sotormQuickFightBySecretaryRequest(buyFiveCount, success)
    local sotoTeamQuickFightRequest = {rivalUserId = -1, pos = -1,buyFiveCount = buyFiveCount,isSecretary = true}
    local gfQuickRequest = {battleType = BattleTypeEnum.SOTO_TEAM, isSecretary = true,sotoTeamQuickFightRequest = sotoTeamQuickFightRequest}
    local request = {api = "GLOBAL_FIGHT_QUICK", gfQuickRequest = gfQuickRequest}
    local fail = function(data)
        remote.secretary:executeInterruption()
    end
    
    app:getClient():requestPackageHandler("GLOBAL_FIGHT_QUICK", request, success, fail)
end

function QSotoTeamFastFightSecretary:refreshWidgetData(widget, itemData, index)
    QSotoTeamFastFightSecretary.super.refreshWidgetData(self, widget, itemData, index)
    if widget then
		local stormInfo = remote.secretary:getSecretaryInfo().sotoTeamSecretary or {}
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

function QSotoTeamFastFightSecretary:getSettingWidgets()
	local widgets = {}

	local titleWidget = QUIWidgetSecretarySettingTitle.new()
	titleWidget:setInfo("云顶设置")
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
	self._scoreWidget:setInfo({desc = "领取积分奖励"})
	self._scoreWidget:setPosition(ccp(60, -totalHeight))
	self._scoreWidget:setSelected(true)
	self._scoreWidget:setNotChooseState(true)
	table.insert(widgets, self._scoreWidget)

	return widgets
end

function QSotoTeamFastFightSecretary:chooseItemClickHandler(event)
    if not event or not event.index then
        return
    end
    self._curChoose = event.index
    self:updateChooseInfo()
end

function QSotoTeamFastFightSecretary:updateChooseInfo()
    for i, widget in pairs(self._chooseWidgetList) do
        local index = widget:getIndex()
        widget:setSelected(self._curChoose == index)
    end
end

function QSotoTeamFastFightSecretary:saveSecretarySetting()
    local setting = {}
	setting.chooseNum = self._curChoose
	setting.autoGetScore = self._autoGetScore
    remote.secretary:updateSecretarySetting(self._config.id, setting)
end

return QSotoTeamFastFightSecretary