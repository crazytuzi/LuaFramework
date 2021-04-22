--
-- Kumo.Wang
-- 新首充界面
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogFirstRechargeNew = class("QUIDialogFirstRechargeNew", QUIDialog)

local QUIViewController = import("..QUIViewController")
local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetFirstRechargeNew = import("..widgets.QUIWidgetFirstRechargeNew")
local QListView = import("...views.QListView")

function QUIDialogFirstRechargeNew:ctor(options)
    local ccbFile = "ccb/Dialog_FirstRecharge.ccbi"
    local callBacks = {
        {ccbCallbackName = "onTriggerClose", callback = handler(self, QUIDialogFirstRechargeNew._onTriggerClose)},
    }
    QUIDialogFirstRechargeNew.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true --是否动画显示

    local configs = QStaticDatabase.sharedDatabase():getStaticByName("first_recharge_new")
    self._configList = {}
    for _, config in pairs(configs) do
        table.insert(self._configList, config)
    end
    table.sort(self._configList, function(a, b)
            return a.id < b.id
        end)

    self:_init()
end

function QUIDialogFirstRechargeNew:update()
    -- if not remote.firstRecharge or not remote.firstRecharge.firstRechargeReward or #remote.firstRecharge.firstRechargeReward < #self._configList then
        self:_init()
    -- else
        -- self:_onTriggerClose()
    -- end
end

function QUIDialogFirstRechargeNew:_init()
    self._data = {}
    local configList = self._configList

    if not remote.firstRecharge or not remote.firstRecharge.firstRechargeReward or #remote.firstRecharge.firstRechargeReward < #configList then
        local completeNum = 0
        local rewardDic = {}
        for _, id in ipairs(remote.firstRecharge.firstRechargeReward or {}) do
            completeNum = completeNum + id
            rewardDic[id] = true
        end

        if not self._level then
            local level = 0
            if completeNum < 3 then
                level = 1
            else
                level = 2
            end
            self._level = level -- 1, 2
        end

        if self._level == 1 then
            for _, config in ipairs(configList) do
                if config.id < 3 then
                    config.isComplete = rewardDic[config.id]
                    table.insert(self._data, config)
                end
            end
        elseif self._level == 2 then
            for _, config in ipairs(configList) do
                if config.id >= 3 then
                    config.isComplete = rewardDic[config.id]
                    table.insert(self._data, config)
                end
            end
        end

        table.sort(self._data, function(a, b)
                if a.isComplete ~= b.isComplete then
                    return b.isComplete
                else
                    return a.id < b.id
                end
            end)

        QSetDisplayFrameByPath(self._ccbOwner.sp_level, QResPath("firstRechargeTitle")[self._level])
        QSetDisplayFrameByPath(self._ccbOwner.sp_img, QResPath("firstRechargeImg")[self._level])
    elseif #remote.firstRecharge.firstRechargeReward >= #configList then
        self._level = 2
        for _, config in ipairs(configList) do
            if config.id >= 3 then
                config.isComplete = true
                table.insert(self._data, config)
            end
        end
        table.sort(self._data, function(a, b)
                if a.isComplete ~= b.isComplete then
                    return b.isComplete
                else
                    return a.id < b.id
                end
            end)
        QSetDisplayFrameByPath(self._ccbOwner.sp_level, QResPath("firstRechargeTitle")[self._level])
        QSetDisplayFrameByPath(self._ccbOwner.sp_img, QResPath("firstRechargeImg")[self._level])
    else
        self._isOver = true
        return
    end
    if self._level == 2 then
        self._ccbOwner.sp_img:setPositionX(-268)
    end
        
    self:_initListView()
end

function QUIDialogFirstRechargeNew:_initListView()
    if self._listView == nil then
        local cfg = {
            renderItemCallBack = handler(self, self._renderItemCallBack),
            isVertical = true,
            ignoreCanDrag = true,
            enableShadow = false,
            spaceY = 5,
            totalNumber = #self._data
        }
        self._listView = QListView.new(self._ccbOwner.sheet_layout, cfg)
    else
        self._listView:reload({totalNumber = #self._data})
    end
end

function QUIDialogFirstRechargeNew:_renderItemCallBack(list, index, info)
    local isCacheNode = true
    local data = self._data[index]
    local item = list:getItemFromCache()
    if not item then            
        item = QUIWidgetFirstRechargeNew.new()
        isCacheNode = false
    end
    item:setInfo(data)
    info.item = item
    info.size = item:getContentSize()
    list:registerTouchHandler(index, "onTouchListView")
    list:registerBtnHandler(index, "btn_ok", "onTriggerOK", nil, true)
    list:registerBtnHandler(index, "btn_go", "onTriggerGo", nil, true)

    return isCacheNode
end

function QUIDialogFirstRechargeNew:viewDidAppear()
    QUIDialogFirstRechargeNew.super.viewDidAppear(self)
end

function QUIDialogFirstRechargeNew:viewAnimationInHandler()
    QUIDialogFirstRechargeNew.super.viewAnimationInHandler(self)
    if self._isOver then
        self:_onTriggerClose()
    end
end


function QUIDialogFirstRechargeNew:viewWillDisappear()
    QUIDialogFirstRechargeNew.super.viewWillDisappear(self)
end

function QUIDialogFirstRechargeNew:_onTriggerRecharge()
    app.sound:playSound("common_small")
    if not remote.recharge.firstRecharge then
        if ENABLE_CHARGE() then
            app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogVIPRecharge"})
        end
    end
end

function QUIDialogFirstRechargeNew:_backClickHandler()
    self:_onTriggerClose()
end

-- 关闭对话框
function QUIDialogFirstRechargeNew:_onTriggerClose(e)
    if e then
        if q.buttonEventShadow(e, self._ccbOwner.btn_close) == false then return end
        app.sound:playSound("common_cancel")
    end
    self:playEffectOut()
end

function QUIDialogFirstRechargeNew:viewAnimationOutHandler()
    app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)

    local dialog = app:getNavigationManager():getController(app.middleLayer):getTopDialog()
    if dialog and dialog.class.__cname == "QUIDialogFirstRechargePoster" then
        -- print(dialog.class.__cname)
        dialog:viewAnimationOutHandler()
    end
end

return QUIDialogFirstRechargeNew