--
-- Author: Your Name
-- Date: 2015-01-17 11:36:24
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogFirstRecharge = class("QUIDialogFirstRecharge", QUIDialog)

local QUIViewController = import("..QUIViewController")
local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QVIPUtil = import("...utils.QVIPUtil")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QLogFile = import("...utils.QLogFile")

function QUIDialogFirstRecharge:ctor(options)
    local ccbFile = "ccb/Dialog_FirstValue.ccbi"
    local callBacks = {
        {ccbCallbackName = "onTriggerRecharge", callback = handler(self, QUIDialogFirstRecharge._onTriggerRecharge)},
        {ccbCallbackName = "onTriggerDraw", callback = handler(self, QUIDialogFirstRecharge._onTriggerDraw)},
        {ccbCallbackName = "onTriggerPreview", callback = handler(self, QUIDialogFirstRecharge._onTriggerPreview)},
        {ccbCallbackName = "onTriggerClose", callback = handler(self, QUIDialogFirstRecharge._onTriggerClose)},
        {ccbCallbackName = "onTriggerGotoBuy", callback = handler(self, QUIDialogFirstRecharge._onTriggerGotoBuy)},
        {ccbCallbackName = "onTriggerHeroIntroduce", callback = handler(self, QUIDialogFirstRecharge._onTriggerHeroIntroduce)},
    }
    QUIDialogFirstRecharge.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true --是否动画显示

    self._type = options.type
    self._callBack = options.callBack

    self._ccbOwner.node_shouchong:setVisible(false)
    self._ccbOwner.node_kfjj:setVisible(false)
    self._ccbOwner.node_vip:setVisible(false)
    self._ccbOwner.node_vip4:setVisible(false)
    self._ccbOwner.node_vip10:setVisible(false)
    self._ccbOwner.node_introduce:setVisible(false)
    self._ccbOwner.node_item:setVisible(false)
    for i = 1, 4 do
        if self._ccbOwner["node"..i] then
            self._ccbOwner["node"..i]:setVisible(false)
        end
    end
   
    self._isShowItems = false

    self:_init()
end

function QUIDialogFirstRecharge:_init()
    if self._type == 1 then
        self._ccbOwner.node_shouchong:setVisible(true)

        self._ccbOwner.recharge:setVisible(remote.recharge.firstRecharge == false)
        self._ccbOwner.draw:setVisible(remote.recharge.firstRecharge == true)
        self._ccbOwner.red_tip:setVisible(remote.recharge.firstRecharge == true)
        self._ccbOwner.node_introduce:setVisible(true)

        self._ccbOwner.node_item:setPosition(0, 0)
        self._itemId = QStaticDatabase:sharedDatabase():getLuckyDraw("shoucichongzhi").id_1
        self._isShowItems = true
    elseif self._type == 2 then
        self._ccbOwner.node_kfjj:setVisible(true)
    elseif self._type == 3 then
        self._ccbOwner.node_yueka:setVisible(true)
    elseif self._type == 4 then
        self._ccbOwner.node_vip:setVisible(true)
        self._ccbOwner.node_vip4:setVisible(true)
        self._ccbOwner.node_introduce:setVisible(true)

        self._ccbOwner.node_item:setPosition(40, 60)
        self._itemId = QStaticDatabase:sharedDatabase():getGoodsGroupByGroupId(QVIPUtil:getShopIdByVIP(4)).id_1
        self._isShowItems = true
    elseif self._type == 5 then
        self._ccbOwner.node_vip:setVisible(true)
        self._ccbOwner.node_vip10:setVisible(true)
        self._ccbOwner.node_introduce:setVisible(true)

        self._ccbOwner.node_item:setPosition(40, 60)
        self._itemId = QStaticDatabase:sharedDatabase():getGoodsGroupByGroupId(QVIPUtil:getShopIdByVIP(8)).id_1
        self._isShowItems = true
    end
    

    
    if self._isShowItems then
        self._ccbOwner.node_item:setVisible(true)
        local index = 1
        if self._itemId then
            local item = QStaticDatabase:sharedDatabase():getItemByID(self._itemId)
            local itemList = string.split(item.content, ";")
            for k, v in ipairs(itemList) do
                if self._ccbOwner["node"..index] then
                    local i = string.find(v, "%^")
                    local itemId = string.sub(v, 0, i - 1)
                    local itemCount = string.sub(v, i - string.len(v))
                    local itemType = remote.items:getItemType(itemId)
                    if itemType == nil then
                        itemType = ITEM_TYPE.ITEM
                    end

                    local box = QUIWidgetItemsBox.new()
                    box:setGoodsInfo(itemId, itemType, itemCount, true)
                    self._ccbOwner["node"..index]:addChild(box, -1)
                    self._ccbOwner["node"..index]:setVisible(true)
                    index = index + 1
                end
            end
        end

        if index <= 4 then
            local itemGap = 100
            self._ccbOwner.node_item:setPositionX( (5-index) * itemGap / 2 )
        end
    end
    
    
end

function QUIDialogFirstRecharge:viewDidAppear( ... )
    QUIDialogFirstRecharge.super.viewDidAppear(self)
end

function QUIDialogFirstRecharge:viewWillDisappear( ... )
    QUIDialogFirstRecharge.super.viewWillDisappear(self)
end

function QUIDialogFirstRecharge:_onTriggerGotoBuy( ... )
    app.sound:playSound("common_small")
    if self._type == 1 then
        return
    elseif self._type == 2 then
        app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogActivityPanel", 
            options = {themeId = 1, curActivityID = "a_kfjj"}}) 
    elseif self._type == 3 then
        app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogActivityPanel", 
            options = {themeId = 1, curActivityID = "a_yueka"}})
    elseif self._type == 4 then
        app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogVip", 
            options = {vipContentLevel = 4}})
    elseif self._type == 5 then
        app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogVip", 
            options = {vipContentLevel = 8}})
    end
end

function QUIDialogFirstRecharge:_onTriggerDraw( ... )
    app.sound:playSound("common_small")
    if remote.recharge.firstRecharge then
        local itemId = QStaticDatabase:sharedDatabase():getLuckyDraw("shoucichongzhi").id_1
        app:getClient():getFirstRecharge(function ( ... )
            app:getClient():openItemPackage(itemId, 1, function()
                self:drawCallback(itemId)
            end)
        end)
    end
end

function QUIDialogFirstRecharge:_onTriggerRecharge( ... )
    app.sound:playSound("common_small")
    if not remote.recharge.firstRecharge then
        if ENABLE_CHARGE() then
            app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogVIPRecharge"})
        end
    end
end

function QUIDialogFirstRecharge:_onTriggerPreview( ... )
    app.sound:playSound("common_small")
    if self._type == 1 then
        if not remote.recharge.firstRecharge then
            if self._itemId then
                app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogXuanzejiangli", 
                    options = {chooseType = 2, awardsId = self._itemId,  explainStr = "获得以下奖励", titleText = "奖   励"}},{isPopCurrentDialog = false})
            end
        else
            self:_onTriggerDraw()
        end
    elseif self._type == 4 then
        if self._itemId then
            app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogXuanzejiangli", 
                options = {chooseType = 2, awardsId = self._itemId,  explainStr = "获得以下奖励", titleText = "奖   励"}},{isPopCurrentDialog = false})
        end
    elseif self._type == 5 then
        if self._itemId then
            app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogXuanzejiangli", 
                options = {chooseType = 2, awardsId = self._itemId,  explainStr = "获得以下奖励", titleText = "奖   励"}},{isPopCurrentDialog = false})
        end
    end
end


function QUIDialogFirstRecharge:drawCallback(itemId)
    local info = QStaticDatabase:sharedDatabase():getItemByID(itemId)
    local awardIds = string.split(info.content, ";") or {}

    local awards = {}
    for k, v in pairs(awardIds) do
        local itemInfo = string.split(v, "^")
        local itemType = ITEM_TYPE.ITEM
        local itemId = itemInfo[1]
        if tonumber(itemId) == nil then
            itemType = remote.items:getItemType(itemId)
        end
        table.insert(awards, {id = itemId, count = tonumber(itemInfo[2]), typeName = itemType})
    end

    app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert",
        options = {awards = awards, callBack = function()
            app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
            app:getNavigationManager():getController(app.mainUILayer):getTopPage():_checkFirstRechargeState()
            app:getNavigationManager():getController(app.mainUILayer):getTopPage():quickButtonAutoLayout()
        end }},{isPopCurrentDialog = false})
    
end

function QUIDialogFirstRecharge:_onTriggerHeroIntroduce()
    app.sound:playSound("common_small")
    if self._type == 1 then
        app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogBossIntroduce",
            options = {bossId = 3587, enemyTips = 1000}})
    elseif self._type == 4 then
        app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogBossIntroduce",
            options = {bossId = 1021, enemyTips = 1003}})
    elseif self._type == 5 then
       app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogBossIntroduce",
            options = {bossId = 1020, enemyTips = 1004}})
    end
end

function QUIDialogFirstRecharge:_backClickHandler()
    self:_onTriggerClose()
end

-- 关闭对话框
function QUIDialogFirstRecharge:_onTriggerClose()
    app.sound:playSound("common_cancel")
    self:playEffectOut()

    if self._callBack then
        self._callBack()
    end
end

function QUIDialogFirstRecharge:viewAnimationOutHandler()
    app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
end

return QUIDialogFirstRecharge