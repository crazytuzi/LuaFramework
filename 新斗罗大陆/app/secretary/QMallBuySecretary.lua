-- @Author: xurui
-- @Date:   2020-03-15 15:20:52
-- @Last Modified by:   DELL
-- @Last Modified time: 2020-04-07 14:51:54
local QBaseSecretary = import(".QBaseSecretary")
local QMallBuySecretary = class("QMallBuySecretary", QBaseSecretary)

local QUIWidgetSecretarySettingTitle = import("..ui.widgets.QUIWidgetSecretarySettingTitle")
local QUIWidgetSecretarySettingBuy = import("..ui.widgets.QUIWidgetSecretarySettingBuy")
local QUIViewController = import("..ui.QUIViewController")
local QVIPUtil = import("..utils.QVIPUtil")

function QMallBuySecretary:ctor(options)
	QMallBuySecretary.super.ctor(self, options)
end

-- 魂师碎片扫荡
function QMallBuySecretary:executeSecretary()
	local settingData = remote.secretary:getSettingBySecretaryId(self._secretaryId)
	if q.isEmpty(settingData) then
        remote.secretary:nextTaskRunning()
        return
	end

	local shopItems = self:getShopItems()

	local buyItems = {}
	local showTokenTips = false
	local totalToken = 0
	local buyCountDict = {}
	for _, value in ipairs(shopItems) do
		local itemId = value.id
		if itemId == nil or itemId == 0 then
			itemId = value.itemType
		end
		local setting = settingData[tostring(itemId)] or {}
		if setting and setting.selected and (setting.buyCount or 0) > 0 then
			local tokenIsEnough, buyNum, needMoney = self:getBuyCost(value, setting.buyCount, totalToken)
			totalToken = totalToken + needMoney
			if buyNum > 0 then
				buyCountDict[value.id] = buyNum - (value.buy_count or 0)
				buyItems[#buyItems+1] = {shopId = SHOP_ID.itemShop, pos = value.position, itemId = value.id, count = value.count, buyCount = buyNum}
			end
			if tokenIsEnough == false then
				showTokenTips = true
			end
		end
	end
	
	self:requestBuyItems(buyItems, showTokenTips, buyCountDict)
end

function QMallBuySecretary:convertSecretaryAwards(itemLog, logNum,info)
    QMallBuySecretary.super:convertSecretaryAwards(itemLog, logNum,info)
    local countTbl = string.split(itemLog.param, ";")

    if self._config.showResource ~= nil then
        info.token = tonumber(countTbl[1]) or 0
        info.money = tonumber(countTbl[2]) or 0    
    end
    return info
end

function QMallBuySecretary:requestBuyItems(itemList, showTokenTips, buyCountDict)
	if q.isEmpty(itemList) then
		if showTokenTips then
        	app.tip:floatTip("货币不足无法购买")
		end
        remote.secretary:nextTaskRunning()
        return
	end

	app:getClient():requestBuyShopItems(itemList, true, function(data)
		local totalBuyCount = 0
		for key, value in pairs(buyCountDict) do
			local itemId = tostring(key)
			if itemId == "160" then
				remote.activity:updateLocalDataByType(556, value)
			end
			if itemId == "10000006" then
				remote.activity:updateLocalDataByType(558, value)
			end
			if itemId == "10000013" then
				remote.activity:updateLocalDataByType(559, value)
			end
			totalBuyCount = totalBuyCount + value
		end
		app.taskEvent:updateTaskEventProgress(app.taskEvent.MALL_BUY_TASK_EVENT, totalBuyCount, false, false)
		
        remote.secretary:updateSecretaryLog(data) 
        if showTokenTips then
        	app.tip:floatTip("货币不足无法购买")
        end
        remote.secretary:nextTaskRunning()

	end, function()
        remote.secretary:nextTaskRunning()
	end)
end

function QMallBuySecretary:getShopItems()
	local shopItems = remote.stores:getStoresById(SHOP_ID.itemShop)
	local datas = {}
	for i = 1, #shopItems do
		local limitLevel = 0
		if shopItems[i].itemType == "item"  then
			limitLevel = db:getItemByID(shopItems[i].id).level
		else
			local currencyInfo = remote.items:getWalletByType(shopItems[i].itemType) or {}
			currencyInfo = db:getItemByID(currencyInfo.item) or {}
			limitLevel = currencyInfo.level or 0
		end

		if ( shopItems[i].id == tonumber(ITEM_TYPE.DRAGON_STONE) or shopItems[i].id == tonumber(ITEM_TYPE.DRAGON_SOUL) ) then
			if app.unlock:checkLock("TUTENG_DRAGON") then
				table.insert(datas, shopItems[i])
			end
		--魂骨宝箱去掉
		elseif shopItems[i].id == GEMSTONE_SHOP_ID then
		
		elseif limitLevel <= remote.user.level then
			table.insert(datas, shopItems[i])
		end
	end
	table.sort(datas, function(a, b)
		if a.position ~= b.position then
			return a.position > b.position
		else
			return false
		end
	end)

	return datas
end

function QMallBuySecretary:getBuyCost(itemInfo, num, totalToken)
	local needMoney = 0
	local tokenIsEnough = true
	local currentBuyCount = itemInfo.buy_count or 0
	local groupId = itemInfo.good_group_id
	local percent = itemInfo.sale or 1
	local haveMoney = remote.user.token
	local currencyInfo = self:getBuyMoneyByBuyCount(groupId)
	local canBuyNum = 0

	for i = currentBuyCount + 1, num do
		local data = currencyInfo[i] or {}
		if q.isEmpty(data) and q.isEmpty(currencyInfo) == false then
			data = currencyInfo[#currencyInfo]
		end

		local currentNum = needMoney + math.floor((data.money_num or 0) * percent)
		if currentNum + totalToken <= haveMoney then
			needMoney = currentNum
			canBuyNum = i
		else
			tokenIsEnough = false
			break
		end
	end

	return tokenIsEnough, canBuyNum, needMoney
end

function QMallBuySecretary:getBuyMoneyByBuyCount(groupId)
	local moneyInfo = db:getTokenConsumeByType(tostring(groupId))
	local currencyInfo = {}
	if moneyInfo ~= nil then
		for _, value in pairs(moneyInfo) do
			currencyInfo[value.consume_times] = {}
			currencyInfo[value.consume_times].money_num = value.money_num
			currencyInfo[value.consume_times].money_type = value.money_type
		end
	end

	return currencyInfo
end

--刷新widget数据
function QMallBuySecretary:refreshWidgetData(widget, itemData, index)
    QMallBuySecretary.super.refreshWidgetData(self, widget, itemData, index)
    if widget and not self:checkSecretaryIsNotActive() then
        widget:setResourseIcon()
    end
end

function QMallBuySecretary:_onTriggerSet()
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMallSecretarySetting", 
		options = {secretaryId = self._secretaryId, callback = handler(self, self.saveSecretarySetting)}}, {isPopCurrentDialog = false})
end

function QMallBuySecretary:saveSecretarySetting(setting)
    if setting == nil then return end

	remote.secretary:updateSecretarySetting(self._config.id, setting)
end

return QMallBuySecretary
