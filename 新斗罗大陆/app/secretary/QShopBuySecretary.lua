-- @Author: xurui
-- @Date:   2019-08-07 15:49:11
-- @Last Modified by:   DELL
-- @Last Modified time: 2020-04-07 16:10:01
local QBaseSecretary = import(".QBaseSecretary")
local QShopBuySecretary = class("QShopBuySecretary", QBaseSecretary)

local QUIViewController = import("..ui.QUIViewController")

function QShopBuySecretary:ctor(options)
	QShopBuySecretary.super.ctor(self, options)
end

function QShopBuySecretary:convertSecretaryAwards(itemLog, logNum,info)
    QShopBuySecretary.super:convertSecretaryAwards(itemLog, logNum,info)

    local lastItems = remote.items:getItemsNumByID(22)
    info.money_1 = remote.secretary:getSoulResfresh() - lastItems

    QPrintTable(info)
    return info
end

-- 刷新商店购买
function QShopBuySecretary:executeSecretary()
    local shopId = self._config.shopId
    local chooseItem = app:getUserOperateRecord():getShopQuickBuyConfiguration(shopId)

    if q.isEmpty(chooseItem) then
        local curConfig = remote.secretary:getSecretaryConfigById(self._config.id)
        if not remote.secretary:isShowTips() then
            remote.secretary:setShowTips(true)
            app.tip:floatTip("魂师大人，您在"..(curConfig.name or "商店").."没有选中任何商品~")
        end
        remote.secretary:nextTaskRunning()
        return
    end

    chooseItem = remote.secretary:recheckChooseItem(shopId, chooseItem)
    -- 后端无法解析数据结构，需要前端重新包装
    local tbl = {}
    for _, list in pairs(chooseItem) do
        for _, value in ipairs(list) do
            if tonumber(value.id) then
                table.insert(tbl, {id = value.id, itemType = "item", moneyType = value.moneyType, moneyNum = tonumber(value.moneyNum)})
            else
                table.insert(tbl, {itemType = value.id, moneyType = value.moneyType, moneyNum = tonumber(value.moneyNum)})
            end
        end
    end

    local callback = function(data)
        if data and data.shopQuickBuyResponse and data.shopQuickBuyResponse.ShopQuickBuyList then
            -- 记录任务完成进度
            for _, value in ipairs(data.shopQuickBuyResponse.ShopQuickBuyList) do
                if value.selectItems then
                    app.taskEvent:updateTaskEventProgress(app.taskEvent.THUNDER_STORE_BUY_TASK_EVENT, #value.selectItems)
                end
            end

            if  shopId == SHOP_ID.soulShop then
                remote.user:addPropNumForKey("c_soulShopConsumeCount",data.shopQuickBuyResponse.buyCount)
                remote.activity:updateLocalDataByType(525, data.shopQuickBuyResponse.buyCount)

                remote.user:addPropNumForKey("todayRefreshShop501Count",data.shopQuickBuyResponse.refreshCount)
                remote.user:addPropNumForKey("c_resetSoulShopCount",data.shopQuickBuyResponse.refreshCount)
                remote.activity:updateLocalDataByType(526, data.shopQuickBuyResponse.refreshCount)
            end
            
        end
        local stopType = data.shopQuickBuyResponse.stop_type or 0
        if not remote.secretary:isShowTips() then
            if stopType == 1 or stopType == 2 then
                app.tip:floatTip("货币不足~")
                remote.secretary:setShowTips(true)
            end
        end
        remote.secretary:updateSecretaryLog(data) 
        remote.secretary:nextTaskRunning()
    end

    local failCallback = function()
        remote.secretary:featuresNotOpen()
    end

    if next(tbl) then
        local refushCount = 0
        if shopId == SHOP_ID.soulShop then
            refushCount = app:getUserOperateRecord():getStoreQuickRefreshCount()
            if refushCount == nil then
                refushCount = db:getConfigurationValue("HERO_SHOP_EASYBUY_AUTO")
            end
            if refushCount == 0 then
                app.tip:floatTip("您的魂师商店还未设置刷新次数~")
                remote.secretary:featuresNotOpen()
                return
            end
        end

        app:getClient():shopQuickBuyRequest(shopId, tbl, true, refushCount,callback,failCallback)
    else
        remote.secretary:nextTaskRunning()
    end
end

--刷新widget数据
function QShopBuySecretary:refreshWidgetData(widget, itemData, index)
    QShopBuySecretary.super.refreshWidgetData(self, widget, itemData, index)
    if widget and not self:checkSecretaryIsNotActive() then
        widget:setResourseIcon()
    end
end

function QShopBuySecretary:_onTriggerSet()
	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogStoreQuickBuy", 
		options = {isSecretary = true, shopId = self._config.shopId}}, {isPopCurrentDialog = false})
end

return QShopBuySecretary
