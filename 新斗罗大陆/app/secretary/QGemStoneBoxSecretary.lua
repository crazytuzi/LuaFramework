-- @Author: xurui
-- @Date:   2019-08-07 15:19:38
-- @Last Modified by:   xurui
-- @Last Modified time: 2019-08-09 11:47:41
local QBaseSecretary = import(".QBaseSecretary")
local QGemStoneBoxSecretary = class("QGemStoneBoxSecretary", QBaseSecretary)

local QUIWidgetSecretarySettingTitle = import("..ui.widgets.QUIWidgetSecretarySettingTitle")
local QUIWidgetSecretarySettingBuy = import("..ui.widgets.QUIWidgetSecretarySettingBuy")
local QVIPUtil = import("..utils.QVIPUtil")

function QGemStoneBoxSecretary:ctor(options)
	QGemStoneBoxSecretary.super.ctor(self, options)
end

-- 免费魂骨宝箱
function QGemStoneBoxSecretary:executeSecretary()
    local callback = function(data)  
        if data.secretaryItemsLogResponse then
            local countTbl = string.split(data.secretaryItemsLogResponse.secretaryLog.param, ";")
            local count = tonumber(countTbl[1]) or 1
            remote.activity:updateLocalDataByType(556, count)
        end
        remote.secretary:updateSecretaryLog(data)
        remote.secretary:nextTaskRunning()
    end

    local itemInfo = {}
    local shopItems = remote.stores:getStoresById(SHOP_ID.itemShop)
    for i, v in pairs(shopItems) do
        if v.id == GEMSTONE_SHOP_ID then
            itemInfo = v
            break
        end
    end

    if itemInfo then
        local curSetting = remote.secretary:getSettingBySecretaryId(self._config.id)
        local buyCount = curSetting.buyCount or 1
        local count = buyCount - itemInfo.buy_count
        if count > 0 then
            local buySuccessed = function(data)
                if not data.items or not data.items[1] or data.items[1].count <= 0 then
                    remote.secretary:nextTaskRunning()
                    return
                end
                -- 开启个数限制
                local item = data.items[1]
                if count > item.count then
                    count = item.count
                end
                self:openItemPackageSecretaryRequest(item.type, count, function(data)
                        callback(data)
                    end)
            end
            local fail = function( data )
                remote.secretary:nextTaskRunning()
            end

            self:buyShopItemSecretaryRequest(SHOP_ID.itemShop, itemInfo.position, itemInfo.id, itemInfo.count, count, buySuccessed, fail)   
            return
        end
    end
    remote.secretary:nextTaskRunning()
end

-- 打开宝箱
function QGemStoneBoxSecretary:openItemPackageSecretaryRequest(itemId, count, success, fail, status)
    local itemOpenRequest = {itemId = itemId, count = count, isSecretary = true}
    local request = {api = "ITEM_OPEN", itemOpenRequest = itemOpenRequest}
    app:getClient():requestPackageHandler("ITEM_OPEN", request, success, fail)
end

-- 购买宝箱
function QGemStoneBoxSecretary:buyShopItemSecretaryRequest(shopId, pos, itemId, count, buyCount, success, fail, status)
    local shopBuyRequest = {shopId = shopId, pos = pos, itemId = itemId, count = count, buyCount = buyCount, isSecretary = true}
    local request = {api = "SHOP_BUY", shopBuyRequest = shopBuyRequest}
    app:getClient():requestPackageHandler("SHOP_BUY", request, success, fail)
end

--刷新widget数据
function QGemStoneBoxSecretary:refreshWidgetData(widget, itemData, index)
	QGemStoneBoxSecretary.super.refreshWidgetData(self, widget, itemData, index)
	if widget then
		local curSetting = remote.secretary:getSettingBySecretaryId(self._secretaryId)
		if curSetting.buyCount == nil then
			widget:setDescStr("免费一次")
		end
	end
end

function QGemStoneBoxSecretary:getSettingWidgets()
	local widgets = {}
    local curSetting = remote.secretary:getSettingBySecretaryId(self._setId)

	local titleWidget = QUIWidgetSecretarySettingTitle.new()
	titleWidget:setInfo("购买次数")
	local titleHeight = titleWidget:getContentSize().height
	table.insert(widgets, titleWidget)

	local buyWidget = QUIWidgetSecretarySettingBuy.new()
	buyWidget:setResourceIcon(self._config.resourceType)
	buyWidget:setInfo(self._config.id, curSetting.buyCount)
	buyWidget:setPositionY(-titleHeight)
	table.insert(widgets, buyWidget)

	return widgets
end

function QGemStoneBoxSecretary:getBuyCost(num)
	self._currentNum = num
    local needMoney = 0
    local maxCount = 9999
    local itemInfo = {}
    local shopItems = remote.stores:getStoresById(SHOP_ID.itemShop)
    for i, v in pairs(shopItems) do
        if v.id == GEMSTONE_SHOP_ID then
            itemInfo = v
            break
        end
    end

    if itemInfo then
        local percent = itemInfo.sale or 1
        for i = itemInfo.buy_count, num - 1 do
            local currentMoney = remote.stores:getBuyMoneyByBuyCount(i, itemInfo.good_group_id)
            needMoney = needMoney + currentMoney*percent
        end
        maxCount = QVIPUtil:getMallItemMaxCountByVipLevel(itemInfo.good_group_id, QVIPUtil:VIPLevel())
    end
    return needMoney, maxCount
end

function QGemStoneBoxSecretary:saveSecretarySetting()
    local setting = {}
	setting.buyCount = self._currentNum or 0
	remote.secretary:updateSecretarySetting(self._config.id, setting)
end

return QGemStoneBoxSecretary