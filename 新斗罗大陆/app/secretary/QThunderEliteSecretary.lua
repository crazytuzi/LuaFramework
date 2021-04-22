-- @Author: xurui
-- @Date:   2019-08-12 09:49:33
-- @Last Modified by:   Kai Wang
-- @Last Modified time: 2019-12-16 11:01:40
local QBaseSecretary = import(".QBaseSecretary")
local QThunderEliteSecretary = class("QThunderEliteSecretary", QBaseSecretary)
local QUIWidgetSecretarySettingTitle = import("..ui.widgets.QUIWidgetSecretarySettingTitle")
local QUIWidgetSecretarySetting = import("..ui.widgets.QUIWidgetSecretarySetting") 
local QUIWidgetSecretarySettingBuy = import("..ui.widgets.QUIWidgetSecretarySettingBuy")

function QThunderEliteSecretary:ctor(options)
	QThunderEliteSecretary.super.ctor(self, options)
end


function QThunderEliteSecretary:executeSecretary()
    local callback = function()
        self:startThunderEliteFight()
    end
    -- 是否已经请求过雷电信息
    local thunderInfo = remote.thunder:getThunderFighter()
    if thunderInfo then
        callback()
    else
        remote.thunder:thunderInfoRequest(callback)
    end
end

function QThunderEliteSecretary:getCurrentFightCount()
    local thunderInfo = remote.thunder:getThunderFighter()
    local configuration = db:getConfiguration()
    local num = tonumber(configuration["THUNDER_ELITE_DEFAULT"].value) +  tonumber(thunderInfo.thunderEliteChallengeBuyCount) - tonumber(thunderInfo.thunderEliteChallengeTimes)

    return num
end

-- 精英完成在重置扫荡
function QThunderEliteSecretary:startThunderEliteFight()
    local callback = function(data)
        remote.secretary:updateSecretaryLog(data) 
        self:startThunderEliteFight()
    end
    
    local curSetting = remote.secretary:getSettingBySecretaryId(self._config.id)
    local thunderInfo = remote.thunder:getThunderFighter()
    local buyCount = thunderInfo.thunderEliteChallengeBuyCount or 0
    local config = db:getTokenConsume("thunder_elite", buyCount+1)
    local cost = config.money_num or 0
    local currentNum = self:getCurrentFightCount()
    --当前有次数就进行扫荡，否则进入购买次数逻辑
    if currentNum > 0 then 
        local curSetting = remote.secretary:getSettingBySecretaryId(self._config.id)
        local curChoose = curSetting.curChoose
        if curChoose == nil then
            curChoose = self:getMaxDungeon()
        end
        if curChoose and curChoose > 0 then
            remote.thunder:thunderEliteQuickFight(BattleTypeEnum.THUNDER_ELITE, tostring(curChoose), remote.thunder.ELITE_WAVE, true, nil, nil, curChoose, true, true, callback)
        else
            remote.secretary:nextTaskRunning()
        end
    else
        --当前购买次数小于设置的购买次数则购买次数再扫荡，否则就结束
        local challengeNum = curSetting.challengeNum or 0
        if buyCount < challengeNum then
            if cost <= (remote.user.token or 0) then
                remote.thunder:thunderBuyEliteRequest(callback)
            else
                app.tip:floatTip("钻石不足, 精英扫荡购买次数失败~")
                remote.secretary:nextTaskRunning() 
            end
        else
            remote.secretary:nextTaskRunning()
        end
    end   
end


function QThunderEliteSecretary:refreshWidgetData(widget, itemData, index)
    QThunderEliteSecretary.super.refreshWidgetData(self, widget, itemData, index)
    if widget then

	    local curSetting = remote.secretary:getSettingBySecretaryId(self._config.id)
	    local curChoose = curSetting.curChoose
	    if curChoose == nil then
	    	curChoose = self:getMaxDungeon()
	    end
        if curChoose then
            widget:setDescStr("第"..curChoose.."关")
        end
    end
end

--已通关最高关卡
function QThunderEliteSecretary:getMaxDungeon()
	local thunderFighter = remote.thunder:getThunderFighter() or {}
	local winNpcs = string.split(thunderFighter.thunderEliteAlreadyWinNpc, ";")
	local maxIndex = 0
	for _, value in ipairs(winNpcs) do
		local num = tonumber(value) or 0
		if maxIndex == 0 or num > maxIndex then
			maxIndex = num
		end
	end

	return maxIndex
end

function QThunderEliteSecretary:getSettingWidgets()
    local widgets = {}
    local curSetting = remote.secretary:getSettingBySecretaryId(self._config.id)
    self._curChoose = curSetting.curChoose
    local maxIndex = self:getMaxDungeon()
    if self._curChoose == nil then
    	self._curChoose = maxIndex
    end

    local totalHeight = 0
    local resetTitleWidget = QUIWidgetSecretarySettingTitle.new()
    resetTitleWidget:setInfo("购买次数")
    totalHeight = totalHeight + resetTitleWidget:getContentSize().height
    table.insert(widgets, resetTitleWidget)

    local resetBuyWidget = QUIWidgetSecretarySettingBuy.new()
    resetBuyWidget:setResourceIcon(self._config.resourceType)
    resetBuyWidget:setMinNum(0)
    resetBuyWidget:setInfo(self._config.id, curSetting.challengeNum or 0, handler(self, self._challengeCost))
    resetBuyWidget:setPositionY(-totalHeight)
    totalHeight = totalHeight + resetBuyWidget:getContentSize().height
    table.insert(widgets, resetBuyWidget)

    local thunderTitleWidget = QUIWidgetSecretarySettingTitle.new()
    thunderTitleWidget:setInfo("选择难度")
    thunderTitleWidget:setPositionY(-totalHeight)
    totalHeight = totalHeight + thunderTitleWidget:getContentSize().height
    table.insert(widgets, thunderTitleWidget)


	local index = 1
	local monsterInfos = {}
	local monsetrInfo = db:getDungeonConfigByID("thunder_elite_"..index)
	while monsetrInfo and index <= maxIndex do
		table.insert(monsterInfos, monsetrInfo)
		index = index + 1
		monsetrInfo = db:getDungeonConfigByID("thunder_elite_"..index)
	end

    self._chooseWidgetList = {}
    for i = #monsterInfos, 1, -1 do
        local chooseWidget = QUIWidgetSecretarySetting.new()
        chooseWidget:addEventListener(QUIWidgetSecretarySetting.EVENT_SELECT_CLICK, handler(self, self.itemClickHandler))
        chooseWidget:setInfo(monsterInfos[i])
        chooseWidget:setIndex(i)
		local rewards = string.split(monsterInfos[i].thunder_drop, "^")
		if rewards and q.isEmpty(rewards) == false then
			local items = db:getItemByID(tonumber(rewards[1]))
        	chooseWidget:setSelectTitle(monsterInfos[i].name.."("..items.name.."x"..(rewards[2] or 0)..")")
    	end
        local height = chooseWidget:getContentSize().height
        chooseWidget:setPositionX(280)
        chooseWidget:setPositionY(-totalHeight)
        totalHeight = totalHeight+height

        table.insert(widgets, chooseWidget)
        table.insert(self._chooseWidgetList, chooseWidget)
    end
    self:updateChooseInfo()

    return widgets, totalHeight
end

function QThunderEliteSecretary:itemClickHandler(event)
    if not event or not event.index then
        return
    end
    self._curChoose = event.index
    self:updateChooseInfo()
end

function QThunderEliteSecretary:updateChooseInfo()
    for i, widget in pairs(self._chooseWidgetList) do
        local index = widget:getIndex()
        widget:setSelected(self._curChoose == index)
    end
end

function QThunderEliteSecretary:_challengeCost(num)
    self._challengeNum = num

    local needMoney = 0
    local buyNum = db:getConfigurationValue("THUNDER_ELITE_BUY")
    local thunderFighter = remote.thunder:getThunderFighter()
    thunderFighter = thunderFighter or {}
    local buyCount = thunderFighter.thunderEliteChallengeBuyCount or 0
    local fightCount = thunderFighter.thunderEliteChallengeTimes or 0
    for i = buyCount + 1, num do
        local tokenConfig = db:getTokenConsume("thunder_elite", i)
        needMoney = needMoney + (tokenConfig.money_num or 0)
    end

    return needMoney, buyNum
end

function QThunderEliteSecretary:saveSecretarySetting()
    local setting = {}
    setting.challengeNum = self._challengeNum
    setting.curChoose = self._curChoose
    remote.secretary:updateSecretarySetting(self._config.id, setting)
end

return QThunderEliteSecretary
