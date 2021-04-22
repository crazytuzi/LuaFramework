local QUIDialog = import(".QUIDialog")
local QUIDialogMystoryStoreAppear = class("QUIDialogMystoryStoreAppear", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QTips = import("...utils.QTips")
local QUIViewController = import("..QUIViewController")
local QVIPUtil = import("...utils.QVIPUtil")
local QUIWidgetHeroInformation = import("..widgets.QUIWidgetHeroInformation")
-- local QSkeletonViewController = import("...controllers.QSkeletonViewController")

QUIDialogMystoryStoreAppear.FIND_GOBLIN_SHOP = "FIND_GOBLIN_SHOP"
QUIDialogMystoryStoreAppear.FIND_BLACK_MARKET_SHOP = "FIND_BLACK_MARKET_SHOP"


function QUIDialogMystoryStoreAppear:ctor(options)
  local ccbFile = "ccb/Dialog_Heishishangren.ccbi"
  local callBacks = {
        {ccbCallbackName = "onTriggerCancel", callback = handler(self, self._onTriggerCancel)},
        {ccbCallbackName = "onTriggerBlackShop", callback = handler(self, self._onTriggerBlackShop)},
    }
    QUIDialogMystoryStoreAppear.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true
    QTips.UNLOCK_TIP_ISTRUE = true

    self:setContent(options.type)
end

function QUIDialogMystoryStoreAppear:setContent(type)
    local information = app.tip:getUnlockTipInformation(type)
    self._ccbOwner.content:setString(information.description)
end

function QUIDialogMystoryStoreAppear:_onTriggerCancel(e)
    if q.buttonEventShadow(e, self._ccbOwner.btn_cancel) == false then return end
    self:_onTriggerClose()
end

function QUIDialogMystoryStoreAppear:_onTriggerBlackShop(e)
    if q.buttonEventShadow(e, self._ccbOwner.btn_go) == false then return end
    app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
    self:viewAnimationOutHandler()
    if remote.stores:checkMystoryStore(SHOP_ID.blackShop) and 
        (remote.stores:checkMystoryStoreTimeOut(SHOP_ID.blackShop) or QVIPUtil:enableBlackMarketPermanent()) then
        
        app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogStore", options = {type = SHOP_ID.blackShop}},{isPopCurrentDialog = true})
    end
end

function QUIDialogMystoryStoreAppear:_onTriggerClose()
    app.sound:playSound("common_close")

    self:playEffectOut()
end

function QUIDialogMystoryStoreAppear:viewAnimationOutHandler()
    QTips.UNLOCK_TIP_ISTRUE = false
    app:getNavigationManager():popViewController(app.topLayer, QNavigationController.POP_TOP_CONTROLLER, {isPopCurrentDialog = false})
    app.tip._unlockTip = nil
    app.tip:showNextTip()
end

return QUIDialogMystoryStoreAppear