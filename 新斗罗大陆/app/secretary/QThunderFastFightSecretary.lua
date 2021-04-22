-- @Author: xurui
-- @Date:   2019-08-07 15:47:11
-- @Last Modified by:   zhouxiaoshu
-- @Last Modified time: 2019-09-11 10:09:42
local QBaseSecretary = import(".QBaseSecretary")
local QThunderFastFightSecretary = class("QThunderFastFightSecretary", QBaseSecretary)

local QUIViewController = import("..ui.QUIViewController")
local QUIWidgetSecretarySettingTitle = import("..ui.widgets.QUIWidgetSecretarySettingTitle")
local QUIWidgetSecretarySetting = import("..ui.widgets.QUIWidgetSecretarySetting") 
local QUIWidgetSecretarySettingBuy = import("..ui.widgets.QUIWidgetSecretarySettingBuy")

function QThunderFastFightSecretary:ctor(options)
	QThunderFastFightSecretary.super.ctor(self, options)
end

function QThunderFastFightSecretary:executeSecretary()
    local callback = function()
        self:startThunderFastFight()
    end
    -- 是否已经请求过雷电信息
    local thunderInfo = remote.thunder:getThunderFighter()
    if thunderInfo then
        callback()
    else
        remote.thunder:thunderInfoRequest(callback)
    end
end

-- 主关卡
function QThunderFastFightSecretary:startThunderFastFight()
    local thunderInfo = remote.thunder:getThunderFighter()
    local reset = thunderInfo.thunderResetCount or 0

    local curSetting = remote.secretary:getSettingBySecretaryId(self._config.id)
    local resetCount = curSetting.resetNum or 1

    local thunderFighter, layerConfig, lastIndex, buyPreciousTimes = remote.thunder:getThunderFighter()
    local buff = remote.thunder:getBuffByLayer(layerConfig.thunder_floor)


    local preciousTimes = remote.thunder:getPreciousTimes()
    -- 秘宝选择
    if thunderFighter.thunderLastChallengeIsFail then
        -- 已经购买
        self:thunderReset()
        return
    --开启宝箱
    elseif q.isEmpty(preciousTimes) == false then
        self:thunderOpenSecret()
        return
    end
    -- 不是战斗出来，也不是扫荡
    if not remote.thunder:getIsBattle() and not remote.thunder:getIsFast() then
        --选择星数属性
        if not buff and lastIndex == 3 then
            self:thunderChooseStar()
            return
        -- 开宝箱
        elseif buyPreciousTimes > 0 then
            self:thunderFinishOpenSecret()
            return
        end
    end

    -- 一键扫荡
    self:thunderFastFight()
end

-- 一键扫荡，开宝箱
function QThunderFastFightSecretary:thunderFastFight()
    local callback = function(data)
        remote.thunder:setIsFast(false,true)

        remote.secretary:updateSecretaryLog(data) 

        self:thunderOpenSecret()
    end

    -- 没有可以扫荡的关卡时，则看看有没有设置重置，有则结束扫荡，否则结束流程 
    local thunderFighter = remote.thunder:getThunderFighter()
    local thunderHistoryEveryWaveStar = thunderFighter.thunderHistoryEveryWaveStar or {}
    local curWaveIndex = remote.thunder:getIndexByLayer(thunderFighter.thunderLastWinFloor, thunderFighter.thunderLastWinWave)
    local advanceIndex = #thunderHistoryEveryWaveStar
    if curWaveIndex >= advanceIndex then
        -- 一关都没有打
        local thunderFighter, layerConfig, lastIndex, buyPreciousTimes = remote.thunder:getThunderFighter()
        if layerConfig.thunder_floor == 1 and lastIndex == 0 then
            remote.secretary:nextTaskRunning()
            return
        end

        self:thunderFightEnd()
    else
        -- 有可以扫荡的关卡时，扫完开宝箱
        remote.thunder:thunderLevelWaveFastFight(2, true, callback)
    end
end

-- 重置雷电，一键扫荡
function QThunderFastFightSecretary:thunderReset()
    local callback = function(data)
        remote.activity:updateLocalDataByType(524, 1) 
        remote.user:addPropNumForKey("c_thunderResetCount")
        
        remote.secretary:updateSecretaryLog(data) 
        self:thunderFastFight()
    end

    -- 重置费用
    local thunderInfo = remote.thunder:getThunderFighter()
    local reset = thunderInfo.thunderResetCount or 0
    local config = db:getTokenConsume("refresh_thunder", reset+1)
    local cost = config.money_num 
    local curSetting = remote.secretary:getSettingBySecretaryId(self._config.id)
    if reset < (curSetting.resetNum or 1) then
        if cost > remote.user.token then
            app.tip:floatTip("钻石不足, 重置杀戮之都失败~")
            remote.secretary:nextTaskRunning() 
        else
            remote.thunder:thunderResetRequest(true, callback)
        end
    else
        remote.secretary:nextTaskRunning() 
    end
end

-- 结束挑战，购买秘宝, 不购买则重置关卡
function QThunderFastFightSecretary:thunderFightEnd()
    local callback = function(data)
        remote.secretary:updateSecretaryLog(data) 

        local curSetting = remote.secretary:getSettingBySecretaryId(self._config.id)
        local fighter = data.apiThunderFightEndResponse.fighter
        local failAward = fighter.thunderFailAward
        if curSetting.getAward and failAward and failAward.awards then   
            local awards = failAward.awards[1]
            app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogThunderChestBuy", 
                options = {itemInfo = awards, isSecretary = true, callback = function(closeType) 
                    self:thunderReset()
                end}}, {isPopCurrentDialog = false})
        else
            self:thunderReset()
        end
    end
    remote.thunder:thunderQuickEnd(callback)
end

-- 结束开宝箱, 继续扫荡 或 结束扫荡 或 结束流程
function QThunderFastFightSecretary:thunderFinishOpenSecret()
    local callback = function(data)
        -- 没有可以扫荡的关卡则结束扫荡  
        local thunderFighter = remote.thunder:getThunderFighter()
        local thunderHistoryEveryWaveStar = thunderFighter.thunderHistoryEveryWaveStar or {}
        local curWaveIndex = remote.thunder:getIndexByLayer(thunderFighter.thunderLastWinFloor, thunderFighter.thunderLastWinWave)
        local advanceIndex = #thunderHistoryEveryWaveStar

        local curSetting = remote.secretary:getSettingBySecretaryId(self._config.id)
        local resetCount = thunderFighter.thunderResetCount or 0
        
        if curWaveIndex >= advanceIndex then
            self:thunderFightEnd()
        else
            self:thunderFastFight()
        end
    end

    remote.thunder:thunderBuyAllPreciousRequest(false, 0, true, callback)
end

-- 开完宝箱，结束开宝箱
function QThunderFastFightSecretary:thunderOpenSecret()
    local callback = function(data)
        remote.secretary:updateSecretaryLog(data) 
        self:thunderFinishOpenSecret()
    end

    local curSetting = remote.secretary:getSettingBySecretaryId(self._config.id)
    local secretCount = curSetting.buyBoxNum or 1
    local thunderFighter = remote.thunder:getThunderFighter()
    local layerCount = thunderFighter.thunderHistoryMaxFloor or 0
    
    local curCount = 0
    -- 开启费用
    local cost = 0
    for i = 1, secretCount do
        local config = db:getTokenConsume("fulminous_price", i)
        cost = cost + config.money_num*layerCount
        if cost > remote.user.token then
            break
        end
        curCount = curCount + 1
    end
    
    if curCount > 0 then
        remote.thunder:thunderBuyAllPreciousRequest(true, curCount, true, callback)
    else
        self:thunderFinishOpenSecret()
    end
end

-- 选择星数属性
function QThunderFastFightSecretary:thunderChooseStar()
    local callback = function()
        remote.secretary:updateSecretaryLog(data) 
        self:thunderFastFight()
    end

    local fighter = remote.thunder:getThunderFighter()
    local buffs = fighter.thunderRandBuffs
    buffs = string.split(buffs, ";")
    local chooseBuffs = {}
    for _,buff in pairs(buffs) do
        if buff ~= "" then
            local buffConfig = db:getThunderBuffById(buff)
            local index = buffConfig.star/3
            chooseBuffs[index] = buffConfig
        end
    end

    local starNum = fighter.thunderCurrentStar - fighter.thunderCurrentUsed
    local idIndex = 1
    if starNum >= 9 then
        idIndex = 3
    elseif starNum >= 6 then
        idIndex = 2
    else
        idIndex = 1
    end
    remote.thunder:thunderBuyBuffRequest(chooseBuffs[idIndex].id, callback)
end

function QThunderFastFightSecretary:refreshWidgetData(widget, itemData, index)
    QThunderFastFightSecretary.super.refreshWidgetData(self, widget, itemData, index)
    local thunderFighter = remote.thunder:getThunderFighter()
    if widget and thunderFighter then
		local thunderHistoryEveryWaveStar = thunderFighter.thunderHistoryEveryWaveStar or {}
		local advanceIndex = #thunderHistoryEveryWaveStar
        if advanceIndex then
            widget:setDescStr(advanceIndex.."关")
        end
    end
end

function QThunderFastFightSecretary:getSettingWidgets()
    local widgets = {}
    local curSetting = remote.secretary:getSettingBySecretaryId(self._config.id)

    local totalHeight = 0
    local resetTitleWidget = QUIWidgetSecretarySettingTitle.new()
    resetTitleWidget:setInfo("重置次数")
    totalHeight = totalHeight + resetTitleWidget:getContentSize().height
    table.insert(widgets, resetTitleWidget)

    local resetBuyWidget = QUIWidgetSecretarySettingBuy.new()
    resetBuyWidget:setResourceIcon(self._config.resourceType)
    resetBuyWidget:setInfo(self._config.id, curSetting.resetNum, handler(self, self._resetCost))
    resetBuyWidget:setPositionY(-totalHeight)
    totalHeight = totalHeight + resetBuyWidget:getContentSize().height
    table.insert(widgets, resetBuyWidget)

    local dungeonTitleWidget = QUIWidgetSecretarySettingTitle.new()
    dungeonTitleWidget:setInfo("宝箱开启次数")
    dungeonTitleWidget:setPositionY(-totalHeight)
    totalHeight = totalHeight + dungeonTitleWidget:getContentSize().height
    table.insert(widgets, dungeonTitleWidget)

    local buyBoxWidget = QUIWidgetSecretarySettingBuy.new()
    buyBoxWidget:setResourceIcon(self._config.resourceType)
    buyBoxWidget:setInfo(self._config.id, curSetting.buyBoxNum, handler(self, self._buyBoxCost))
    buyBoxWidget:setBuyTitle("本轮还需消耗：")
    buyBoxWidget:setPositionY(-totalHeight)
    totalHeight = totalHeight + buyBoxWidget:getContentSize().height
    table.insert(widgets, buyBoxWidget)

    local thunderTitleWidget = QUIWidgetSecretarySettingTitle.new()
    thunderTitleWidget:setInfo("杀戮秘宝设置")
    thunderTitleWidget:setPositionY(-totalHeight)
    totalHeight = totalHeight + thunderTitleWidget:getContentSize().height
    table.insert(widgets, thunderTitleWidget)

    self._awardWidget = QUIWidgetSecretarySetting.new()
    self._awardWidget:addEventListener(QUIWidgetSecretarySetting.EVENT_SELECT_CLICK, handler(self, self.awardItemClickHandler))
    self._awardWidget:setInfo({desc = "显示杀戮秘宝"})
    self._awardWidget:setPosition(ccp(100, -totalHeight))
    self._awardWidget:setSelected(curSetting.getAward)
    totalHeight = totalHeight + self._awardWidget:getContentSize().height
    table.insert(widgets, self._awardWidget)

    return widgets, totalHeight
end

function QThunderFastFightSecretary:awardItemClickHandler(event)
    self._getAward = not self._getAward
    self._awardWidget:setSelected(self._getAward)
end

function QThunderFastFightSecretary:_resetCost(num)
    self._resetNum = num

    local needMoney = 0
    local maxNum = db:getConfigurationValue("THUNDER_RESET_LIMIT")
    local thunderFighter = remote.thunder:getThunderFighter()
    local resetCount = thunderFighter.thunderResetCount or 0
    for i = resetCount + 1, num do
        local tokenConfig = db:getTokenConsume("refresh_thunder", i)
        needMoney = needMoney + (tokenConfig.money_num or 0)
    end 

    return needMoney, maxNum
end

function QThunderFastFightSecretary:_buyBoxCost(num)
    self._buyBoxNum = num
        
    local needMoney = 0
    local maxNum = 20
    local thunderFighter, layerConfig, lastIndex = remote.thunder:getThunderFighter()
    local resetCount = thunderFighter.thunderResetCount or 0
    local lastFloor = (thunderFighter.thunderBuyPreciousMaxFloor or 0)
    if thunderFighter.thunderLastChallengeIsFail then
        lastFloor = 0
    end
    local thunderHistoryEveryWaveStar = thunderFighter.thunderHistoryEveryWaveStar or {}
    local advanceIndex = #thunderHistoryEveryWaveStar
    local floorCount = math.floor(advanceIndex / 3)

    local preciousTimes = remote.thunder:getPreciousTimes()
    if q.isEmpty(preciousTimes) == false then
        for _,value in ipairs(preciousTimes) do
            for i = value.count, num do
                local tokenConfig = db:getTokenConsume("fulminous_price", i)
                needMoney = needMoney + (tokenConfig.money_num or 0)
            end
        end
    else
        for i = lastFloor + 1, floorCount do
            local startCount = 1
            if i == 1 and (thunderFighter.thunderBuyPreciousTimes or 0) > 0 then
                startCount = thunderFighter.thunderBuyPreciousTimes
            end
            for j = startCount, num do
                local tokenConfig = db:getTokenConsume("fulminous_price", j)
                needMoney = needMoney + (tokenConfig.money_num or 0)
            end
        end
    end

    return needMoney, maxNum
end


function QThunderFastFightSecretary:saveSecretarySetting()
    local setting = {}
    setting.resetNum = self._resetNum
    setting.buyBoxNum = self._buyBoxNum
    setting.getAward = self._getAward
    remote.secretary:updateSecretarySetting(self._config.id, setting)
end

return QThunderFastFightSecretary
