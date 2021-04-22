--
-- Author: qinyuanji
-- Date: 2015-04-02 17:14:49
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogHeroRebornCompensation = class("QUIDialogHeroRebornCompensation", QUIDialog)
local QNavigationController = import("...controllers.QNavigationController")
local QScrollView = import("...views.QScrollView")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QUIWidgetMagicHerbBox = import("..widgets.QUIWidgetMagicHerbBox")
local QUIWidgetItemsBoxGem = import("..widgets.QUIWidgetItemsBoxGem")
local QUIViewController = import("..QUIViewController")
local QQuickWay = import("...utils.QQuickWay")

QUIDialogHeroRebornCompensation.MARGIN = 20
QUIDialogHeroRebornCompensation.GAP = 30
QUIDialogHeroRebornCompensation.COLUMN_NUMBER = 5

QUIDialogHeroRebornCompensation.RECYCLE = "QUIDialogHeroRebornCompensation.RECYCLE"

function QUIDialogHeroRebornCompensation:ctor(options)
	local ccbFile = "ccb/Dialog_HeroRecover_Preview.ccbi"
	local callBacks = {
        {ccbCallbackName = "onTriggerClose", callback = handler(self, QUIDialogHeroRebornCompensation._onTriggerClose)},
        {ccbCallbackName = "onTriggerCancel", callback = handler(self, QUIDialogHeroRebornCompensation._onTriggerCancel)},
        {ccbCallbackName = "onTriggerConfirm", callback = handler(self, QUIDialogHeroRebornCompensation._onTriggerConfirm)},
	}
	QUIDialogHeroRebornCompensation.super.ctor(self,ccbFile,callBacks,options)
    self.isAnimation = true --是否动画显示

    self._preview = options.preview
    self._token = options.token
    self._compensations = options.compensations
    self._callFunc = options.callFunc
    if options.tips then
        self._tips = options.tips
    else
        self._tips = ""
    end
    if options.title then
        self._title = options.title
    else
        self._title = ""
    end

    self._height = self._ccbOwner.sheet_layout:getContentSize().height
    self._width = self._ccbOwner.sheet_layout:getContentSize().width
    self._itemProperWidth = (self._width - QUIDialogHeroRebornCompensation.GAP * (QUIDialogHeroRebornCompensation.COLUMN_NUMBER - 1)
         - 2*QUIDialogHeroRebornCompensation.MARGIN)/QUIDialogHeroRebornCompensation.COLUMN_NUMBER

    self:showCompensations()
end

function QUIDialogHeroRebornCompensation:viewDidAppear()
    QUIDialogHeroRebornCompensation.super.viewDidAppear(self)

    self.prompt = app:promptTips()
    self.prompt:addItemEventListener(self)
    self._scrollViewProxy = cc.EventProxy.new(self._scrollView)
    self._scrollViewProxy:addEventListener(QScrollView.GESTURE_MOVING, handler(self, self._onScrollViewMoving))
end

function QUIDialogHeroRebornCompensation:viewWillDisappear()
    QUIDialogHeroRebornCompensation.super.viewWillDisappear(self)

    self.prompt:removeItemEventListener()
    if self._scrollViewProxy then
        self._scrollViewProxy:removeAllEventListeners()
        self._scrollViewProxy = nil
    end
end

function QUIDialogHeroRebornCompensation:showCompensations()
    assert(self._compensations, "Compensation list is empty")

    -- QPrintTable(self._compensations)
    self._scrollView = QScrollView.new(self._ccbOwner.sheet, CCSize(self._width, self._height), {sensitiveDistance = 10})
--    self._scrollView:setGradient(true)
    self._scrollView:setVerticalBounce(true)

    local i = 0
    local offsetX = 5
    local offsetY = 20
    local y = 0
    for _, v in ipairs(self._compensations) do
        local itemType = remote.items:getItemType(v.id)
        if itemType == nil then
            itemType = ITEM_TYPE.ITEM
        end

        local box = nil 
        local item = QStaticDatabase:sharedDatabase():getItemByID(v.id)
        if item and item.type == 18 then
            box = QUIWidgetItemsBoxGem.new()
            itemType = ITEM_TYPE.GEMSTONE_PIECE
            box:setPromptIsOpen(true)
            box:setGoodsInfo(v.id, itemType, v.value, true)
            box:setNameVisibility(false)
        elseif item and (item.type == ITEM_CONFIG_TYPE.GARNET or item.type == ITEM_CONFIG_TYPE.OBSIDIAN) then
            itemType = ITEM_TYPE.SPAR
            box = QUIWidgetItemsBox.new()
            box:setPromptIsOpen(true)
            box:setGoodsInfo(v.id, itemType, v.value, true)
        elseif item and item.type == ITEM_CONFIG_TYPE.MAGICHERB_WILD then
            -- 破碎仙草
            box = QUIWidgetMagicHerbBox.new()
            box:setItemByItemId(v.id, v.value)
            box:setPromptIsOpen(true)
            box:setTouchEnabled(true)
            box:hideName()
        else
            box = QUIWidgetItemsBox.new()
            box:setPromptIsOpen(true)
            box:setGoodsInfo(v.id, itemType, v.value, true)
        end

        box:setBoxScale(self._itemProperWidth/box:getContentSize().width)
        local x = QUIDialogHeroRebornCompensation.MARGIN + (QUIDialogHeroRebornCompensation.GAP + self._itemProperWidth) * (i % QUIDialogHeroRebornCompensation.COLUMN_NUMBER) + 
                    self._itemProperWidth/2
        y = (QUIDialogHeroRebornCompensation.GAP + self._itemProperWidth) * (math.modf(i / QUIDialogHeroRebornCompensation.COLUMN_NUMBER)) + 
                    self._itemProperWidth/2 + QUIDialogHeroRebornCompensation.GAP
        box:setPosition(x + offsetX, -y + offsetY)

        self._scrollView:addItemBox(box)
        i = i + 1
    end

    self._scrollView:setRect(0, -(y + self._itemProperWidth/2 + QUIDialogHeroRebornCompensation.GAP), 0, self._width)

    self._ccbOwner.tf_tips:setString(self._tips)
    self._ccbOwner.tf_title:setString(self._title)

end

function QUIDialogHeroRebornCompensation:_onTriggerClose(event)
    if q.buttonEventShadow(event, self._ccbOwner.frame_btn_close) == false then return end
    app.sound:playSound("common_cancel")
    self:_onTriggerCancel()
end

function QUIDialogHeroRebornCompensation:_onTriggerConfirm(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_confirm) == false then return end
    if self._preview then
        self:_onTriggerCancel()
    else
        app.sound:playSound("common_confirm")
        if self._token and remote.user.token < self._token then
            app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
            QQuickWay:addQuickWay(QQuickWay.TOKEN_DROP_WAY, nil)
            return
        end

        assert(self._callFunc, "Reborn API is not available")
        if self._callFunc then
            self._callFunc(self._compensations)
        end
    end
end

function QUIDialogHeroRebornCompensation:_onScrollViewMoving()
    self.prompt:stopMonsterPrompt()
end

function QUIDialogHeroRebornCompensation:_onTriggerCancel(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_cancel_bg) == false then return end
    self:playEffectOut()
end

function QUIDialogHeroRebornCompensation:_backClickHandler()
    self:_onTriggerCancel()
end

function QUIDialogHeroRebornCompensation:viewAnimationOutHandler()
    app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
end

return QUIDialogHeroRebornCompensation
