-- @Author: xurui
-- @Date:   2019-08-07 15:46:35
-- @Last Modified by:   DELL
-- @Last Modified time: 2020-04-03 19:12:05
local QBaseSecretary = import(".QBaseSecretary")
local QWisdomChallengeSecretary = class("QWisdomChallengeSecretary", QBaseSecretary)

local QUIWidgetSecretarySettingTitle = import("..ui.widgets.QUIWidgetSecretarySettingTitle")
local QUIWidgetSecretarySetting = import("..ui.widgets.QUIWidgetSecretarySetting")

function QWisdomChallengeSecretary:ctor(options)
	QWisdomChallengeSecretary.super.ctor(self, options)

    self._activity = ACTIVITY_DUNGEON_TYPE.WISDOM_CHALLENGE
end

function QWisdomChallengeSecretary:executeSecretary()
    local maxCount = remote.activityInstance:getAttackMaxCountByType(self._activity)
    self:activitySapiential(maxCount)
end

function QWisdomChallengeSecretary:getNameStr(taskId, idCount, logNum)
    local dungenMap = remote.activityInstance:getDungeonByIntId(idCount) or {}
    local dungenConfig = db:getDungeonConfigByIntID(idCount) or {}
    local name1 = dungenMap.instance_name or idCount
    local name2 = dungenConfig.name or ""
    nameStr = name1..name2

    return nameStr
end

-- 智慧试炼SAPIENTIAL
function QWisdomChallengeSecretary:activitySapiential(num)
    if num <= 0 then
        remote.secretary:nextTaskRunning()
        return
    end

    -- 每周时间选择
    if self:checkSecretaryIsNotActive() then
        remote.secretary:nextTaskRunning()
        return
    end

    if self:checkSecretaryIsComplete() then
        remote.secretary:nextTaskRunning()
        return
    end

    local callback = function(data)   
        if data.secretaryItemsLogResponse then
            remote.secretary:updateSecretaryLog(data) 
            remote.activity:updateLocalDataByType(555, 1)
            remote.union.unionActive:updateActiveTaskProgress(20004, 6)
        end
        self:activitySapiential(num-1)
    end

    local curSetting = remote.secretary:getSettingBySecretaryId(self._config.id)
    local chooseNum = curSetting.chooseNum

    -- 获取已通过的最大关卡
    local curDungeon = nil
    local config = remote.activityInstance:getInstanceListById(self._activity)
    for i, dungeon in pairs(config) do
        local passInfo = remote.activityInstance:getPassInfoById(dungeon.dungeon_id)
        if passInfo and passInfo.star == 3 then
            curDungeon = dungeon
            if chooseNum and chooseNum == i then
                break
            end
        end
    end
    if curDungeon and remote.secretary:checkEnergy() then
        local battleType = BattleTypeEnum.DUNGEON_ACTIVITY
        app:getClient():fightActivityDungeonQuickRequest(battleType, curDungeon.dungeon_id, 1, true, callback)
    else
        remote.secretary:nextTaskRunning()
    end
end

function QWisdomChallengeSecretary:checkSecretaryIsComplete()
    local maxCount = remote.activityInstance:getAttackMaxCountByType(self._activity)
    local attackCount = remote.activityInstance:getAttackCountByType(self._activity)
    return attackCount >= maxCount
end

function QWisdomChallengeSecretary:checkSecretaryIsNotActive()
    local weekday = tonumber(q.date("%w", q.serverTime()-(remote.user.c_systemRefreshTime*HOUR)))
    if weekday == 1 or weekday == 3 or weekday == 5 then
        return true, "每周二，四，六，日开启"
    end
    
    return false
end

function QWisdomChallengeSecretary:refreshWidgetData(widget, itemData, index)
    QWisdomChallengeSecretary.super.refreshWidgetData(self, widget, itemData, index)
    if widget then
        local curSetting = remote.secretary:getSettingBySecretaryId(self._secretaryId)
        local chooseNum = curSetting.chooseNum
        if not chooseNum then
            local data = self:getInstanceData()
            chooseNum = #data
        end
        local levelStr = remote.secretary.SETTING_LEVEL[chooseNum]
        if levelStr then
            widget:setDescStr("难度"..levelStr)
        end
    end
end

function QWisdomChallengeSecretary:getInstanceData()
    local instanceData = {}
    local activity = ACTIVITY_DUNGEON_TYPE.WISDOM_CHALLENGE
    local config = remote.activityInstance:getInstanceListById(activity)
    local instanceData = {}
    for i, dungeon in pairs(config) do
        local passInfo = remote.activityInstance:getPassInfoById(dungeon.dungeon_id)
        if passInfo and passInfo.star == 3 then
            local levelStr = remote.secretary.SETTING_LEVEL[i]
            local info = {}
            info.index = i
            info.desc = "难度"..levelStr
            table.insert(instanceData, info)
        end
    end

    return instanceData
end

function QWisdomChallengeSecretary:getSettingWidgets()
    local widgets = {}

    local totalHeight = 0
    local titleWidget = QUIWidgetSecretarySettingTitle.new()
    titleWidget:setInfo("难度选择")
    totalHeight = totalHeight + titleWidget:getContentSize().height
    table.insert(widgets, titleWidget)

    local instanceData = self:getInstanceData()
    self._chooseWidgetList = {}
    local row = 0
    for i, setInfo in pairs(instanceData) do
        local chooseWidget = QUIWidgetSecretarySetting.new()
        chooseWidget:addEventListener(QUIWidgetSecretarySetting.EVENT_SELECT_CLICK, handler(self, self.itemClickHandler))
        chooseWidget:setInfo(setInfo)
        local height = chooseWidget:getContentSize().height
        chooseWidget:setPositionX(160*row)
        chooseWidget:setPositionY(-totalHeight)

        row = row + 1
        if row%3 == 0 then
            totalHeight = totalHeight+height
            row = 0
        end
        table.insert(widgets, chooseWidget)
        table.insert(self._chooseWidgetList, chooseWidget)
    end

    local curSetting = remote.secretary:getSettingBySecretaryId(self._config.id)
    self._curChoose = curSetting.chooseNum or #instanceData
    self:updateChooseInfo()

    return widgets
end

function QWisdomChallengeSecretary:itemClickHandler(event)
    if not event or not event.index then
        return
    end
    self._curChoose = event.index
    self:updateChooseInfo()
end

function QWisdomChallengeSecretary:updateChooseInfo()
    for i, widget in pairs(self._chooseWidgetList) do
        local index = widget:getIndex()
        widget:setSelected(self._curChoose == index)
    end
end

function QWisdomChallengeSecretary:saveSecretarySetting()
    local setting = {}
     setting.chooseNum = self._curChoose
    remote.secretary:updateSecretarySetting(self._config.id, setting)
end

return QWisdomChallengeSecretary