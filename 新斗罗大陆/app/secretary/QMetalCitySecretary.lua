-- @Author: xurui
-- @Date:   2020-03-02 10:31:04
-- @Last Modified by:   xurui
-- @Last Modified time: 2020-05-14 17:23:32
local QBaseSecretary = import(".QBaseSecretary")
local QMetalCitySecretary = class("QMetalCitySecretary", QBaseSecretary)

local QUIWidgetSecretarySettingTitle = import("..ui.widgets.QUIWidgetSecretarySettingTitle")
local QUIWidgetSecretarySettingBuy = import("..ui.widgets.QUIWidgetSecretarySettingBuy")
local QVIPUtil = import("..utils.QVIPUtil")
local QQuickWay = import("..utils.QQuickWay")

function QMetalCitySecretary:ctor(options)
	QMetalCitySecretary.super.ctor(self, options)
end

-- 竞技场扫荡
function QMetalCitySecretary:executeSecretary()
    local callback = function(data, count)
        if data.metalCityResponse then
            remote.metalCity:updateMetalServerInfo(data.metalCityResponse)
        end
    	if count then
			remote.user:addPropNumForKey("todayMetalCityFightCount", count)
			remote.user:addPropNumForKey("totalMetalCityFightCount", count)

        	app.taskEvent:updateTaskEventProgress(app.taskEvent.METAILCITY_EVENT, count, false, true)
		end

        remote.secretary:updateSecretaryLog(data, 1) 
        remote.secretary:nextTaskRunning()
    end

	local metalCityInfo = remote.metalCity:getMetalCityMyInfo() or {}
    local freeCount = QVIPUtil:getCountByWordField("metalcity_tims1")
    local curSetting = remote.secretary:getSettingBySecretaryId(self._config.id)
    local buyNum = curSetting.buyNum or 0
    local fightCount = freeCount + buyNum - (metalCityInfo.fightCount or 0)

    local buyCount = (metalCityInfo.buyCount or 0)
    local needMoney = 0
    for i = buyCount + 1, buyNum do
        local config = db:getTokenConsume("metalcity_num2", i)
        if config.money_num + needMoney > remote.user.token then
            app.tip:floatTip("钻石不足，无法购买战斗次数")
            remote.secretary:nextTaskRunning()
            return
        else
            needMoney = needMoney + (config.money_num or 0)
        end
    end

    if fightCount > 0 then
        self:metalCityQuickFightBySecretaryRequest(fightCount, callback)
    else
        remote.secretary:nextTaskRunning()
    end
end

-- 金属之城一键扫荡
function QMetalCitySecretary:metalCityQuickFightBySecretaryRequest(fightCount, success)
    local battleType = BattleTypeEnum.METAL_CITY
    local metalCitySecretaryQuickFightRequest = {quickFightNum = fightCount}

    local fail = function(data)
        remote.secretary:executeInterruption()
    end
    
    local gfQuickRequest = {battleType = battleType, isSecretary = true, metalCitySecretaryQuickFightRequest = metalCitySecretaryQuickFightRequest}
    local request = {api = "GLOBAL_FIGHT_QUICK", gfQuickRequest = gfQuickRequest}
    app:getClient():requestPackageHandler("GLOBAL_FIGHT_QUICK", request, function(data)
    	if success then
    		success(data, fightCount)
    	end
	end, fail)
end

function QMetalCitySecretary:refreshWidgetData(widget, itemData, index)
    QMetalCitySecretary.super.refreshWidgetData(self, widget, itemData, index)
    local curSetting = remote.secretary:getSettingBySecretaryId(self._secretaryId)
	local buyNum = curSetting.buyNum or 0
    if widget then
		widget:setDescStr(string.format("购买%s次", buyNum))

        local metalCityInfo = remote.metalCity:getMetalCityMyInfo() or {}
        local metalFloor = metalCityInfo.metalNum or 1
        if metalFloor == 0 then metalFloor = 1 end
        local config = remote.metalCity:getMetalCityConfigByFloor(metalFloor)
        local maxConfig = remote.metalCity:getMetalCityConfigByFloor(metalFloor + 1)
        local userForce = remote.herosUtil:getMostHeroBattleForce()
        
        if remote.user.level >= itemData.min_level and q.isEmpty(config) == false and q.isEmpty(maxConfig) == false and userForce >= (((config.metalcity_force_saodang_1 or 0) + (config.metalcity_force_saodang_2 or 0)) * 1.2) then
            widget:setTips("战力已远超当前关卡，快去推进吧。")
        else
            widget:setTips()
        end
    end
end

function QMetalCitySecretary:_onTriggerSelect()
	local curSetting = remote.secretary:getSettingBySecretaryId(self._secretaryId)
	local isOpen = curSetting.isOpen or false
	local setting = {}
	setting.isOpen = not isOpen
	remote.secretary:updateSecretarySetting(self._secretaryId, setting)
end


function QMetalCitySecretary:getSettingWidgets()
	local widgets = {}

    local curSetting = remote.secretary:getSettingBySecretaryId(self._secretaryId)

	local titleWidget = QUIWidgetSecretarySettingTitle.new()
	titleWidget:setInfo("购买次数")
	local titleHeight = titleWidget:getContentSize().height
	table.insert(widgets, titleWidget)

	local buyWidget = QUIWidgetSecretarySettingBuy.new()
	buyWidget:setResourceIcon(self._config.resourceType)
    buyWidget:setMinNum(0)
	buyWidget:setInfo(self._config.id, curSetting.buyNum or 0)
	buyWidget:setPositionY(-titleHeight)
	table.insert(widgets, buyWidget)

	return widgets
end

function QMetalCitySecretary:getBuyCost(num)
	local metalCityInfo = remote.metalCity:getMetalCityMyInfo() or {}
    local needMoney = 0
    local maxCount = QVIPUtil:getCountByWordField("metalcity_tims2", QVIPUtil:getMaxLevel())
    local buyCount = metalCityInfo.buyCount or 0

    self._buyNum = num

    for i = buyCount + 1, num do
        local config = db:getTokenConsume("metalcity_num2", i)
        needMoney = needMoney + (config.money_num or 0)
    end

    return needMoney, maxCount
end

function QMetalCitySecretary:saveSecretarySetting()
    local setting = {}
	setting.buyNum = self._buyNum
    remote.secretary:updateSecretarySetting(self._config.id, setting)
end

return QMetalCitySecretary
