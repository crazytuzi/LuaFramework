-- @Author: zhouxiaoshu
-- @Date:   2019-08-28 15:49:56
-- @Last Modified by:   xurui
-- @Last Modified time: 2020-10-14 15:32:10
local QBaseSecretary = import(".QBaseSecretary")
local QSunWarSecretary = class("QSunWarSecretary", QBaseSecretary)

local QVIPUtil = import("..utils.QVIPUtil")
local QUIViewController = import("..ui.QUIViewController")
local QUIWidgetSecretarySettingTitle = import("..ui.widgets.QUIWidgetSecretarySettingTitle")
local QUIWidgetSecretarySetting = import("..ui.widgets.QUIWidgetSecretarySetting") 
local QUIWidgetSecretarySettingBuy = import("..ui.widgets.QUIWidgetSecretarySettingBuy")
local QSunwarSecretaryArrangement = import("..arrangement.QSunwarSecretaryArrangement")
local QNavigationController = import("..controllers.QNavigationController")

local typeName = ITEM_TYPE.SUNWAR_REVIVE_COUNT

function QSunWarSecretary:ctor(options)
	QSunWarSecretary.super.ctor(self, options)
end

function QSunWarSecretary:executeSecretary()
    app:getClient():sunwarInfoRequest(function( data )
			remote.sunWar:responseHandler(data)
            local isMapFirstAppearance = remote.sunWar:getIsMapFirstAppearance()
            if not isMapFirstAppearance  then
                remote.sunWar:setCurrentMapID( remote.sunWar:getNextMapID() )
            end
            self:preStartSunWarFight()
		end)
end

function QSunWarSecretary:preStartSunWarFight()
    -- 判断有没有宝箱开启
    local isAwardBox, chestId = self:chechAwardBox()
    if isAwardBox then
        self:openWaveAwardBox(chestId, function()
            self:preStartSunWarFight()
        end)
        return
    end

    -- 章节奖励
    local mapId = remote.sunWar:getCurrentMapID()
    local isChaptersAwarded = remote.sunWar:IsChaptersAwardedByMapID(mapId)
    if remote.sunWar:isMapChestAllOpened(mapId) and not isChaptersAwarded then
        self:getChapterAward(mapId, function()
            self:preStartSunWarFight()
        end)
        return
    end

    -- 自动战斗阵容检查
    local waveId = remote.sunWar:getCurrentWaveID()
    local info = remote.sunWar:getWaveFigtherByWaveID( waveId )
    local teamKey = remote.teamManager.SUNWAR_ATTACK_TEAM
    local sunwellArrangement = QSunwarSecretaryArrangement.new({dungeonInfo = info, teamKey = teamKey, callback = function()
            app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
            self:startSunWarFight()
        end})

    local callback = function()
        app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogTeamArrangement",
            options = {arrangement = sunwellArrangement, backCallback = function()
                remote.secretary:nextTaskRunning()
            end}})
    end

    local failCallback = function()
        remote.secretary:nextTaskRunning()
    end
    
    --初始阵容合理性判断
    local teamVO = remote.teamManager:getTeamByKey(teamKey)
    local heroIdList = teamVO:getAllTeam()
    if sunwellArrangement:teamValidity(heroIdList[1].actorIds, nil, callback, nil, failCallback) == false then 
        return
    end

	self:startSunWarFight()
end

function QSunWarSecretary:startSunWarFight()
    collectgarbageCollect()
    -- 判断有没有宝箱开启
    local isAwardBox, chestId = self:chechAwardBox()
    if isAwardBox then
        self:openWaveAwardBox(chestId, function()
            self:startSunWarFight()
        end)
        return
    end

    local isMapFirstAppearance = remote.sunWar:getIsMapFirstAppearance()
    if not isMapFirstAppearance  then
        remote.sunWar:setCurrentMapID( remote.sunWar:getNextMapID() )
    end

    -- 章节奖励
    local mapId = remote.sunWar:getCurrentMapID()
    local isChaptersAwarded = remote.sunWar:IsChaptersAwardedByMapID(mapId)
    if remote.sunWar:isMapChestAllOpened(mapId) and not isChaptersAwarded then
        self:getChapterAward(mapId, function()
            self:startSunWarFight()
        end)
        return
    end

    local callback = function(data)
        if data.secretaryItemsLogResponse then
            local isWin = true
            if data.gfEndResponse then
                isWin = data.gfEndResponse.isWin
            end
            if isWin then 
                remote.secretary:updateSecretaryLog(data, 1)
                remote.activity:updateLocalDataByType(548, 1)
                --remote.trailer:updateTaskProgressByTaskId("4000021", 1)
                remote.user:addPropNumForKey("todayBattlefieldFightCount")
                app.taskEvent:updateTaskEventProgress(app.taskEvent.SUN_WAR_TASK_EVENT, 1, false, true)
                
                self:startSunWarFight()
            else
                remote.secretary:updateSecretaryLog(data, 6)
                -- 输了直接复活
                self:sunwarHeroRevive(function()
                    self:startSunWarFight()
                end)
            end
        else
            remote.secretary:nextTaskRunning()
        end
    end
    -- 失败直接返回
    local fail = function()
        remote.secretary:nextTaskRunning()
    end

    -- 每次都看看是否可以扫荡
    local waveId = remote.sunWar:getCurrentWaveID()
    local canFast = remote.sunWar:checkSunWarWaveCanFastFight(waveId)
    if canFast then
        local battleType = BattleTypeEnum.BATTLEFIELD
        remote.sunWar:requestSunWarFastFight(battleType, waveId, true, callback, fail)

    else
        local teamKey = remote.sunWar:getSunWarTeamKey()
        local teamVO = remote.teamManager:getTeamByKey(teamKey)
        local heros = clone(remote.teamManager:getActorIdsByKey(teamKey))
        for _, actorId in pairs(heros) do
            local heroInfo = remote.sunWar:getMyHeroInfoByActorID(actorId)
            if heroInfo ~= nil and heroInfo.currHp and heroInfo.currHp <= 0 then
                teamVO:delHeroByIndex(1, actorId)
            end
        end
        if remote.godarm:checkGodArmUnlock() then
            local godarmIds = teamVO:getTeamGodarmByIndex(remote.teamManager.TEAM_INDEX_GODARM)
            for _, godarmId in ipairs(godarmIds) do
                local godarmInfo = remote.godarm:getGodarmById(godarmId) or {}
                if q.isEmpty(godarmInfo) then
                    teamVO:delGodarmsIndex(remote.teamManager.TEAM_INDEX_GODARM, godarmId)
                end
            end
        end

        remote.teamManager:saveTeamToLocal(teamVO, teamKey)

        --当前阵容合理性判断
        local info = remote.sunWar:getWaveFigtherByWaveID( waveId )
        local sunwellArrangement = QSunwarSecretaryArrangement.new({dungeonInfo = info, teamKey = teamKey})
        local heroIdList = teamVO:getAllTeam()
        if sunwellArrangement:teamValidity(heroIdList[1].actorIds, nil, nil, true) == false then
            -- 有复活次数，主力死亡直接复活
            self:sunwarHeroRevive(function()
                self:startSunWarFight()
            end)
        else
            sunwellArrangement:setIsLocal(true)
            sunwellArrangement:startAutoFight(callback, fail)
        end
    end
end

-- 是否有未领取的宝箱
function QSunWarSecretary:chechAwardBox()
    local waveId = remote.sunWar:getCurrentWaveID()
    local mapId = remote.sunWar:getCurrentMapID()
    local mapInfo = remote.sunWar:getMapInfoByMapID(mapId)
    local todayPassedWaves = remote.sunWar:getTodayPassedWaves()
    local waveTbl = mapInfo.waves
    for i = 1, #waveTbl do
        local vaveInfo = waveTbl[i]
        if vaveInfo.chest_id then
            local isOpen = remote.sunWar:getIsChestOpenedByWaveID( vaveInfo.wave )
            if not isOpen then
                local isMaxWave = remote.sunWar:isLastMapLastWaveByWaveID( vaveInfo.wave )
                local isFind = false
                for _, id in pairs(todayPassedWaves) do
                    if id == vaveInfo.wave then
                        -- 说明是今天打的，而不是之前打的
                        isFind = true
                    end
                end
                if (vaveInfo.wave < waveId) or (isMaxWave and isFind) then
                    return true, vaveInfo.wave
                end
            end 
        end
    end
    return false
end

-- 开宝箱
function QSunWarSecretary:openWaveAwardBox(waveId, fightCallback)
    local callback = function(data)
        remote.sunWar:responseHandler(data)
        if data.secretaryItemsLogResponse then
            remote.secretary:updateSecretaryLog(data, 2)
        end
        fightCallback()
    end
    app:getClient():sunwarGetWaveAwardRequest(waveId, true, callback)
end

-- 购买复活次数
function QSunWarSecretary:sunwarBuyReviveCountRequest(fightCallback)
    local callback = function(data)
        remote.sunWar:responseHandler(data)
        if data.secretaryItemsLogResponse then
            remote.secretary:updateSecretaryLog(data, 3)
        end
        fightCallback()
    end

    local curSetting = remote.secretary:getSettingBySecretaryId(self._config.id)
    local reviveNum = curSetting.reviveNum or 1
    local buyCount = remote.sunWar:getHeroReviveBuyCnt() or 0
    if buyCount + 1 >= reviveNum then
        remote.secretary:nextTaskRunning()
        return
    end 
    local config = db:getTokenConsume(typeName, buyCount + 1)
    if config.money_num <= remote.user.token then
        app:getClient():sunwarBuyReviveCountRequest(true, callback)
    else
        if not remote.secretary:isShowTips() then
            remote.secretary:setShowTips(true)
            app.tip:floatTip("钻石不足，复活失败")
        end
        remote.secretary:nextTaskRunning()
    end
end

-- 复活
function QSunWarSecretary:sunwarHeroRevive(fightCallback)
    local callback = function(data)
        remote.sunWar:responseHandler(data)
        if data.secretaryItemsLogResponse then
            remote.secretary:updateSecretaryLog(data, 4)
        end
        fightCallback()
    end

    if remote.sunWar:getCanReviveCount() > 0 then
        app:getClient():sunwarHeroReviveRequest(true, callback)
    else
        self:sunwarBuyReviveCountRequest(function()
            self:sunwarHeroRevive(fightCallback)
        end)
    end
end

-- 章节奖励
function QSunWarSecretary:getChapterAward(mapId, fightCallback)
    local callback = function(data)
        remote.sunWar:responseHandler(data)
        if data.secretaryItemsLogResponse then
            remote.secretary:updateSecretaryLog(data, 5)
        end
        fightCallback()
    end
    app:getClient():sunwarGetChapterAwardRequest(mapId, true, callback)
end

function QSunWarSecretary:refreshWidgetData(widget, itemData, index)
    QSunWarSecretary.super.refreshWidgetData(self, widget, itemData, index)
    if widget then
        local curSetting = remote.secretary:getSettingBySecretaryId(self._config.id)
        local reviveNum = curSetting.reviveNum or 1
        widget:setDescStr("复活"..reviveNum.."次")
    end
end

function QSunWarSecretary:getSettingWidgets()
    local totalHeight = 0
    local height = 0
    local widgets = {}

    local curSetting = remote.secretary:getSettingBySecretaryId(self._config.id)
	self._reviveNum = curSetting.reviveNum or 1

	local titleWidget = QUIWidgetSecretarySettingTitle.new()
	titleWidget:setInfo("复活次数")
	table.insert(widgets, titleWidget)
	height = titleWidget:getContentSize().height
	totalHeight = totalHeight + height

	local buyWidget = QUIWidgetSecretarySettingBuy.new()
	buyWidget:setResourceIcon(self._config.resourceType)
	buyWidget:setInfo(self._config.id, self._reviveNum)
	buyWidget:setPositionY(-totalHeight)
	table.insert(widgets, buyWidget)
	height = buyWidget:getContentSize().height
	totalHeight = totalHeight + height

    return widgets, totalHeight
end

function QSunWarSecretary:getBuyCost(num)
	self._reviveNum = num
    local needMoney = 0
    local freeCount = 1
    local maxCount = QVIPUtil:getBuyVirtualCount(typeName) + freeCount
    local buyCount = remote.sunWar:getHeroReviveBuyCnt() or 0
    for i = buyCount + 1, self._reviveNum - freeCount do
        local config = db:getTokenConsume(typeName, i)
        needMoney = needMoney + config.money_num
    end
    return needMoney, maxCount
end

function QSunWarSecretary:saveSecretarySetting()
    local setting = {}
    setting.reviveNum = self._reviveNum
    remote.secretary:updateSecretarySetting(self._config.id, setting)
end

function QSunWarSecretary:getNameStr(taskId, idCount, logNum)
    local nameStr = ""
    if logNum == 1 or logNum == 6 then
        local isFirst = remote.sunWar:getIsWaveFirstWin()
        local num1 = math.ceil(idCount/9)
        local num2 = (idCount-1)%9 + 1
        if isFirst then
            nameStr = num1.."-"..num2.."(首通)"
        else
            nameStr = num1.."-"..num2
        end
    elseif logNum == 2 then
        local num = (idCount%9)/3
        if num == 1 then
            nameStr = "绿色"
        elseif num == 2 then
            nameStr = "蓝色"
        else
            nameStr = "金色"
        end
    else
        nameStr = idCount
    end    

    return nameStr
end

function QSunWarSecretary:convertSecretaryAwards(itemLog, logNum,info)
    QSunWarSecretary.super:convertSecretaryAwards(itemLog, logNum,info)
    local taskId = itemLog.taskType
    local secrataryConfig = remote.secretary:getSecretaryConfigById(taskId)

    local countTbl = string.split(itemLog.param, ";")

    if self._config.showResource ~= nil then
        info.token = 0
        info.money = tonumber(countTbl[3]) or 0
        if info.money > 0 then
            info.title2 = info.title2.."并消耗："
        end        
    end
    return info
end

return QSunWarSecretary

