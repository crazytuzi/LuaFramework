
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogThunderChestBuy = class("QUIDialogThunderChestBuy", QUIDialog)
local QNavigationController = import("...controllers.QNavigationController")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIDialogAwardsAlert = import("..dialogs.QUIDialogAwardsAlert")
local QUIViewController = import("..QUIViewController")

function QUIDialogThunderChestBuy:ctor(options)
    local ccbFile = "ccb/Dialog_ThunderKing_Treasure.ccbi"
    local callBacks = {
        {ccbCallbackName = "onTriggerClose", callback = handler(self, QUIDialogThunderChestBuy._onTriggerClose)},
        {ccbCallbackName = "onTriggerCancel", callback = handler(self, QUIDialogThunderChestBuy._onTriggerClose)},
        {ccbCallbackName = "onTriggerConfirm", callback = handler(self, QUIDialogThunderChestBuy._onTriggerConfirm)},
    }

    QUIDialogThunderChestBuy.super.ctor(self,ccbFile,callBacks,options)

    self.isAnimation = true
    self.itemInfo = options.itemInfo
    self._callback = options.callback
    self._closeType = "close"

    local itemConfig = QStaticDatabase:sharedDatabase():getItemByID(self.itemInfo.id)
    local itemBox = QUIWidgetItemsBox.new()
    itemBox:setPromptIsOpen(true)
    self._ccbOwner.node_item:addChild(itemBox)

    self._ccbOwner.frame_tf_title:setString("杀戮之都秘宝")

    itemBox:setGoodsInfo(self.itemInfo.id, ITEM_TYPE.ITEM, self.itemInfo.count)
    local globalConfig = QStaticDatabase:sharedDatabase():getConfiguration()
    self._ccbOwner.tf_price:setString(self.itemInfo.money_num)
    self._ccbOwner.tf_discount:setString(math.floor(self.itemInfo.money_num * globalConfig.THUNDER_FAILED_BUY.value/100))
    self._ccbOwner.tf_item_name:setString(itemConfig.name)

    local fighter = remote.thunder:getThunderFighter()
    self._ccbOwner.tf_star_num:setString(fighter.thunderCurrentStar)

    if fighter.thunderFailAwardhasGet ~= false then
        self._ccbOwner.sp_buy:setVisible(true)
        self._ccbOwner.btn_ok:setVisible(false)
        self._ccbOwner.node_btn_cancel:setVisible(false)
    else
        self._ccbOwner.sp_buy:setVisible(false)
        self._ccbOwner.btn_ok:setVisible(true)
        self._ccbOwner.node_btn_cancel:setVisible(true)
        self._ccbOwner.bt_confirm:setEnabled(true)
    end
    q.setButtonEnableShadow(self._ccbOwner.btn_close)
    q.setButtonEnableShadow(self._ccbOwner.btn_cancel)
end

function QUIDialogThunderChestBuy:viewDidAppear()
    QUIDialogThunderChestBuy.super.viewDidAppear(self)
    self.prompt = app:promptTips()
    self.prompt:addItemEventListener(self)
    self.prompt:addMonsterEventListener()
    -- body
end

function QUIDialogThunderChestBuy:viewWillDisappear()
    QUIDialogThunderChestBuy.super.viewWillDisappear(self)
    self.prompt:removeItemEventListener()
    self.prompt:removeMonsterEventListener()
end

function QUIDialogThunderChestBuy:_onTriggerConfirm(event)
    if q.buttonEventShadow(event, self._ccbOwner.bt_confirm) == false then return end
    app.sound:playSound("common_confirm")
    remote.thunder:thunderBuyFailAwardRequest(function (data)
        self._ccbOwner.bt_confirm:setEnabled(false)
        -- makeNodeFromNormalToGray(self._ccbOwner.btn_buy)
        local awards = {}
        local prizes = data.apiThunderBuyFailureAwardResponse.luckyDraw.prizes or {}
        for _,value in ipairs(prizes) do
            table.insert(awards, {id = value.id, typeName = value.type, count = value.count})
        end
        app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert", options = {awards = awards,
            callBack = function ()
            self._closeType = "confirm"
            self:playEffectOut()
        end}}, {isPopCurrentDialog = false} )
    end)
end

function QUIDialogThunderChestBuy:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogThunderChestBuy:_onTriggerClose(event)
    -- if q.buttonEventShadow(event, self._ccbOwner.btn_cancel) == false then return end
    self._closeTyp = "close"
    self:playEffectOut()
end

function QUIDialogThunderChestBuy:viewAnimationOutHandler()
    remote.thunder:setIsBattle(false, false)

    local callback = self._callback
    app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)

    if self._callback then
        self._callback(self._closeType)
    end
end

return QUIDialogThunderChestBuy