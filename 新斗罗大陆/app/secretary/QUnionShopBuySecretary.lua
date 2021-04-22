-- @Author: xurui
-- @Date:   2019-08-07 16:17:49
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2019-09-09 14:59:18
local QBaseSecretary = import(".QBaseSecretary")
local QUnionShopBuySecretary = class("QUnionShopBuySecretary", QBaseSecretary)

local QUIViewController = import("..ui.QUIViewController")

function QUnionShopBuySecretary:ctor(options)
	QUnionShopBuySecretary.super.ctor(self, options)
end

-- 刷新商店购买
function QUnionShopBuySecretary:executeSecretary()
	if self:checkSecretaryIsNotActive() then
		remote.secretary:nextTaskRunning()
		return
	end

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

    if next(tbl) then
        local refushCount = 0
        if shopId == SHOP_ID.soulShop then
            refushCount = app:getUserOperateRecord():getStoreQuickRefreshCount()
            if refushCount == nil then
                refushCount = QStaticDatabase:sharedDatabase():getConfigurationValue("HERO_SHOP_EASYBUY_AUTO")
            end  
            if refushCount == 0 then
                app.tip:floatTip("您还未设置魂师商店刷新次数~")
                return
            end          
        end

        app:getClient():shopQuickBuyRequest(shopId, tbl, true, refushCount,callback)
    else
        remote.secretary:nextTaskRunning()
    end
end

function QUnionShopBuySecretary:checkSecretaryIsNotActive()
    if remote.union:checkHaveUnion() == false then
        return true, "尚未加入宗门"
    end
    
    return false
end

--刷新widget数据
function QUnionShopBuySecretary:refreshWidgetData(widget, itemData, index)
    QUnionShopBuySecretary.super.refreshWidgetData(self, widget, itemData, index)
    if widget and not self:checkSecretaryIsNotActive() then
        widget:setResourseIcon()
    end
end

function QUnionShopBuySecretary:_onTriggerSet()
	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogStoreQuickBuy", 
		options = {isSecretary = true, shopId = self._config.shopId}}, {isPopCurrentDialog = false})
end

return QUnionShopBuySecretary
