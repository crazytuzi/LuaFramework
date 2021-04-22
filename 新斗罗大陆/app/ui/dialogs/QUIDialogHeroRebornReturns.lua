--
-- Author: qinyuanji
-- Date: 2015-04-02 17:14:49
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogHeroRebornReturns = class("QUIDialogHeroRebornReturns", QUIDialog)
local QNavigationController = import("...controllers.QNavigationController")
local QScrollView = import("...views.QScrollView")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QUIWidgetItemsBoxGem = import("..widgets.QUIWidgetItemsBoxGem")
local QUIWidgetMagicHerbBox = import("..widgets.QUIWidgetMagicHerbBox")

QUIDialogHeroRebornReturns.MARGIN = 20
QUIDialogHeroRebornReturns.GAP = 45
QUIDialogHeroRebornReturns.COLUMN_NUMBER = 5

function QUIDialogHeroRebornReturns:ctor(options)
	local ccbFile = "ccb/Dialog_HeroRecover_Return.ccbi"
	local callBacks = {
        {ccbCallbackName = "onTriggerUpper", callback = handler(self, QUIDialogHeroRebornReturns._onTriggerCancel)},
        {ccbCallbackName = "onTriggerBottom", callback = handler(self, QUIDialogHeroRebornReturns._onTriggerCancel)},
	}
	QUIDialogHeroRebornReturns.super.ctor(self,ccbFile,callBacks,options)

    self._compensations = options.compensations
    self._pageWidth = self._ccbOwner.sheet_layout:getContentSize().width
    self._pageHeight = self._ccbOwner.sheet_layout:getContentSize().height
    self._itemProperWidth = (self._pageWidth - QUIDialogHeroRebornReturns.GAP * (QUIDialogHeroRebornReturns.COLUMN_NUMBER - 1)
        - 2*QUIDialogHeroRebornReturns.MARGIN)/QUIDialogHeroRebornReturns.COLUMN_NUMBER
    self._subtitle = options.subtitle
    self._type = options.type

    self._ccbOwner.recycle:setVisible(self._type == 2)
    self._ccbOwner.reborn:setVisible(self._type == 1)
    self._ccbOwner.gemRecycle:setVisible(self._type == 3)
    self._ccbOwner.gemReborn:setVisible(self._type == 4)
    self._ccbOwner.mountReborn:setVisible(self._type == 5)
    self._ccbOwner.mountRecycle:setVisible(self._type == 6)
    self._ccbOwner.sparRecycle:setVisible(self._type == 7)
    self._ccbOwner.sparReborn:setVisible(self._type == 8)
    self._ccbOwner.magicHerbReborn:setVisible(self._type == 9)
    self._ccbOwner.magicHerbPiece:setVisible(self._type == 10)
    self._ccbOwner.soulSpiritPiece:setVisible(self._type == 11)
    self._ccbOwner.soulSpiritReborn:setVisible(self._type == 12)
    self._ccbOwner.soulGradeReturn:setVisible(self._type == 13)
    self._ccbOwner.godarmGradeReturn:setVisible(self._type == 14)
    self._ccbOwner.godarmreclyReturn:setVisible(self._type == 15)
    self._ccbOwner.soulOccultReset:setVisible(self._type == 16)
    self._ccbOwner.awakeningRebirth:setVisible(self._type == 17)
    self._ccbOwner.subtitle:setString(self._subtitle)

    self:initScrollView()
end

function QUIDialogHeroRebornReturns:viewDidAppear()
    QUIDialogHeroRebornReturns.super.viewDidAppear(self)

    self:showCompensations()
end

function QUIDialogHeroRebornReturns:viewWillDisappear()
    QUIDialogHeroRebornReturns.super.viewWillDisappear(self)
end

function QUIDialogHeroRebornReturns:initScrollView()
    self._scrollView = QScrollView.new(self._ccbOwner.sheet, self._ccbOwner.sheet_layout:getContentSize(), {bufferMode = 1, sensitiveDistance = 10})

    self._scrollView:addEventListener(QScrollView.GESTURE_MOVING, handler(self, self._onScrollViewMoving))
    self._scrollView:addEventListener(QScrollView.GESTURE_BEGAN, handler(self, self._onScrollViewBegan))
end

function QUIDialogHeroRebornReturns:showCompensations()
    assert(self._compensations, "Compensation list is empty")

--    self._scrollView:setGradient(true)

    local i = 0
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
            box:setNeedshadow( false )
            box:setNameVisibility(true)
        elseif item and (item.type == ITEM_CONFIG_TYPE.GARNET or item.type == ITEM_CONFIG_TYPE.OBSIDIAN) then
            itemType = ITEM_TYPE.SPAR
            box = QUIWidgetItemsBox.new()
            box:setPromptIsOpen(true)
            box:setGoodsInfo(v.id, itemType, v.value, true)
            box:setNeedshadow( false )
            box:showItemName()
        elseif item and item.type == ITEM_CONFIG_TYPE.MAGICHERB_WILD then
            -- 破碎仙草
            box = QUIWidgetMagicHerbBox.new()
            box:setItemByItemId(v.id, v.value)
            box:setPromptIsOpen(true)
            box:setTouchEnabled(true)
        else
            box = QUIWidgetItemsBox.new()
            box:setPromptIsOpen(true)
            box:setGoodsInfo(v.id, itemType, v.value, true)
            box:setNeedshadow( false )
            box:showItemName()
        end

        local x = QUIDialogHeroRebornReturns.MARGIN + (QUIDialogHeroRebornReturns.GAP + self._itemProperWidth) * (i % QUIDialogHeroRebornReturns.COLUMN_NUMBER) + 
                    self._itemProperWidth/2
        y = (QUIDialogHeroRebornReturns.GAP + self._itemProperWidth) * (math.modf(i / QUIDialogHeroRebornReturns.COLUMN_NUMBER)) + 
                    self._itemProperWidth/2 --+ QUIDialogHeroRebornReturns.GAP
        box:setPosition(x, -y)

        self._scrollView:addItemBox(box)
        i = i + 1
    end

    self._scrollView:setRect(0, -(y + 120), 0, self._pageWidth)
end

function QUIDialogHeroRebornReturns:_onScrollViewMoving()
    self._isMove = true
end

function QUIDialogHeroRebornReturns:_onScrollViewBegan()
    self._isMove = false
end

function QUIDialogHeroRebornReturns:_backClickHandler()
    -- if self._isMove then return end
    self:_onTriggerCancel()
end

function QUIDialogHeroRebornReturns:_onTriggerCancel()
    app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    page:checkGuiad()
end

return QUIDialogHeroRebornReturns
