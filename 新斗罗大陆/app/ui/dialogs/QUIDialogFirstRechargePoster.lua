--
-- Kumo.Wang
-- 首充彈臉
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogFirstRechargePoster = class("QUIDialogFirstRechargePoster", QUIDialog)

local QUIViewController = import("..QUIViewController")
local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetQlistviewItem = import("..widgets.QUIWidgetQlistviewItem")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QListView = import("...views.QListView")
local QUIWidget = import("..widgets.QUIWidget")

function QUIDialogFirstRechargePoster:ctor(options)
    local ccbFile = "ccb/Dialog_FirstRechargePoster.ccbi"
    local callBacks = {
        {ccbCallbackName = "onTriggerClose", callback = handler(self, QUIDialogFirstRechargePoster._onTriggerClose)},
        {ccbCallbackName = "onTriggerGo", callback = handler(self, QUIDialogFirstRechargePoster._onTriggerGo)},
        {ccbCallbackName = "onTriggerHeroIntroduce", callback = handler(self, QUIDialogFirstRechargePoster._onTriggerHeroIntroduce)},
    }
    QUIDialogFirstRechargePoster.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true --是否动画显示

    if options then
        self._cb = options.cb
        self._config = options.config
        self._level = options.level
    end
    
    if app:getUserOperateRecord():compareCurrentTimeWithRecordeTime(DAILY_TIME_TYPE.FIRST_RECHARGE_POSTER) then
        app:getUserOperateRecord():recordeCurrentTime(DAILY_TIME_TYPE.FIRST_RECHARGE_POSTER)
    end
    
    if self._level then
        self:_init()
    else
        self:_onTriggerClose()
    end
end

function QUIDialogFirstRechargePoster:_init()
    QSetDisplayFrameByPath(self._ccbOwner.sp_bg, QResPath("firstRechargePoster")[self._level])
    
    self._data = {}
    local index = 1
    while true do
        local rewardStr = self._config["reward_"..index]
        if rewardStr then
            local tbl = string.split(rewardStr, "^")
            local itemType = ITEM_TYPE.ITEM
            if tonumber(tbl[1]) == nil then
                itemType = remote.items:getItemType(tbl[1])
            end
            local isEffect = self._config["effect"..index] == 1
            table.insert(self._data, {id = tonumber(tbl[1]), itemType = itemType, count = tonumber(tbl[2]), isEffect = isEffect})
            index = index + 1
        else
            break
        end
    end
    
    self:_initListView()
end

function QUIDialogFirstRechargePoster:_initListView()
    if self._listView == nil then
        local cfg = {
            renderItemCallBack = handler(self, self._renderItemCallBack),
            isVertical = false,
            enableShadow = false,
            spaceX = 10,
            autoCenter = true,
            ignoreCanDrag = false,
            totalNumber = #self._data
        }
        self._listView = QListView.new(self._ccbOwner.itemsListView, cfg)
    else
        self._listView:reload({totalNumber = #self._data})
    end
end

function QUIDialogFirstRechargePoster:_renderItemCallBack(list, index, info)
    local function showItemInfo(x, y, itemBox, listView)
        app.tip:itemTip(itemBox._itemType, itemBox._itemID, true)
    end

    local isCacheNode = true
    local data = self._data[index]
    local item = list:getItemFromCache()
    if not item then            
        item = QUIWidgetQlistviewItem.new()
        isCacheNode = false
    end

    local itemX = 45
    local itemY = 45
    if not item._itemEffect then
        item._itemEffect = QUIWidget.new("ccb/effects/leiji_light.ccbi")
        item._itemEffect:setScale(0.6)
        item._itemEffect:setPosition(ccp(itemX, itemY))
        item._ccbOwner.parentNode:addChild(item._itemEffect)
    end
    item._itemEffect:setVisible(data.isEffect)

    if not item._itemBox then
        item._itemBox = QUIWidgetItemsBox.new()
        item._itemBox:setScale(1)
        item._itemBox:setPosition(ccp(itemX, itemY))
        item._ccbOwner.parentNode:addChild(item._itemBox)
        item._ccbOwner.parentNode:setContentSize(CCSizeMake(100,100))
    end
    item._itemBox:setGoodsInfo(data.id, data.itemType, data.count)
    info.item = item
    info.size = item._ccbOwner.parentNode:getContentSize()
    list:registerItemBoxPrompt(index, 1, item._itemBox, nil, showItemInfo)

    return isCacheNode
end

function QUIDialogFirstRechargePoster:viewDidAppear( ... )
    QUIDialogFirstRechargePoster.super.viewDidAppear(self)
end

function QUIDialogFirstRechargePoster:viewWillDisappear( ... )
    QUIDialogFirstRechargePoster.super.viewWillDisappear(self)
end

function QUIDialogFirstRechargePoster:_onTriggerGo(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_go) == false then return end
    
    app.sound:playSound("common_small")
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogFirstRechargeNew", 
        options = {}})
end

function QUIDialogFirstRechargePoster:_onTriggerHeroIntroduce(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_introduce) == false then return end
    app.sound:playSound("common_small")
    if self._level == 1 then
        app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogBossIntroduce",
            options = {bossId = 1028, enemyTips = 1014}})
    elseif self._level == 2 then
        app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogBossIntroduce",
            options = {bossId = 1028, enemyTips = 1014}})
    end
end

function QUIDialogFirstRechargePoster:_backClickHandler()
    self:_onTriggerClose()
end

-- 关闭对话框
function QUIDialogFirstRechargePoster:_onTriggerClose(e)
    if e then
        if q.buttonEventShadow(e, self._ccbOwner.btn_close) == false then return end
        app.sound:playSound("common_cancel")
    end
    self:playEffectOut()
end

function QUIDialogFirstRechargePoster:viewAnimationOutHandler()
    app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)

    if self._cb then
        self._cb()
    end
end

return QUIDialogFirstRechargePoster