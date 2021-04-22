--
-- Author: Kumo.Wang
-- 图鉴列表
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogHandBookClient = class("QUIDialogHandBookClient", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QListView = import("...views.QListView")

local QUIWidgetHandBookCell = import("..widgets.QUIWidgetHandBookCell")

QUIDialogHandBookClient.TOTAL_BOOK_CELL = 10

function QUIDialogHandBookClient:ctor(options)
	local ccbFile = "ccb/Dialog_HandBook_Client.ccbi"
	local callBack = {}
	QUIDialogHandBookClient.super.ctor(self, ccbFile, callBack, options)
    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    page:setAllUIVisible(false)
    page:setScalingVisible(true)

    CalculateUIBgSize(self._ccbOwner.sp_bg)
    CalculateUIBgSize(self._ccbOwner.sp_mask)

    if page.topBar then
        page.topBar:showWithMainPage()
    end

    self._isHandBookItemRuning = false
    self._sheetLeyoutWidth = self._ccbOwner.sheet_layout:getContentSize().width

    remote.handBook:handBookInfoRequest(self:safeHandler(function()
            if self:safeCheck() then
                self:_initListView()
            end
        end))
    self:_init()
end

function QUIDialogHandBookClient:viewDidAppear()
	QUIDialogHandBookClient.super.viewDidAppear(self)
    self:addBackEvent(false)

    -- self:_initListView()

    local actorId = self:getOptions().selectedActorId
    if actorId then
        self:_selectHeroByActorId(actorId)
        self:getOptions().selectedActorId = nil
    end
end

function QUIDialogHandBookClient:viewWillDisappear()
	QUIDialogHandBookClient.super.viewWillDisappear(self)
    self:removeBackEvent()
    remote.handBook.showActorId = nil

    if self._handBookItemRunInScheduler ~= nil then
        scheduler.unscheduleGlobal(self._handBookItemRunInScheduler)
        self._handBookItemRunInScheduler = nil
    end

    if self._handBookItemRunOutScheduler ~= nil then
        scheduler.unscheduleGlobal(self._handBookItemRunOutScheduler)
        self._handBookItemRunOutScheduler = nil
    end

end

function QUIDialogHandBookClient:_init()
    self._allHerosID = remote.handBook:getAllHerosID()
    self._onlineHerosID = remote.handBook:getOnlineHerosID()

    self._multiItems = 5
    self._spaceX = 10
    local width = 188
    local totalWidth = width * self._multiItems + self._spaceX * (self._multiItems )
    self._ccbOwner.sheet_layout:setContentSize(totalWidth, self._ccbOwner.sheet_layout:getContentSize().height - 77)
    self._sheetLeyoutWidth = self._ccbOwner.sheet_layout:getContentSize().width
end

function QUIDialogHandBookClient:_initListView()
    if not self._listView then
        local cfg = {
            renderItemCallBack = function( list, index, info )
                local isCacheNode = true
                local itemData = self._allHerosID[index]
                local item = list:getItemFromCache()
                if not item then
                    item = QUIWidgetHandBookCell.new()
                    isCacheNode = false
                end
                item:setInfo({actorId = itemData})
                info.item = item
                info.size = item:getContentSize()

                list:registerBtnHandler(index, "btn_admire", handler(self, self._clickAdmireHandler))
                list:registerBtnHandler(index, "btn_handBookCell", handler(self, self._clickHandBookCellHandler))
                
                return isCacheNode
            end,
            isVertical = true,
            multiItems = self._multiItems,
            spaceX = self._spaceX,
            spaceY = 10,
            curOriginOffset = 20,
            enableShadow = false,
            ignoreCanDrag = true,  
            totalNumber = #self._allHerosID,
        }
        self._listView = QListView.new(self._ccbOwner.sheet_layout, cfg)
    else
        self._listView:reload({totalNumber = #self._allHerosID})
    end

    self:_startScrollByActorId()
    
end

function QUIDialogHandBookClient:handBookItemRunOutAction()
    if self._isHandBookItemRuning == true then return end
    self._listView:setCanNotTouchMove(true)
    self._isHandBookItemRuning = true
    for i = 1, QUIDialogHandBookClient.TOTAL_BOOK_CELL do
        local item
        if self._listView then
            item = self._listView:getItemByIndex(i)
        end
        if item ~= nil then
            local posx, posy = item:getPosition()
            item:setPosition(ccp(posx + self._sheetLeyoutWidth, posy))  
        end 
    end

    self.func1 = function()
        self._handBookItemRunInScheduler = scheduler.performWithDelayGlobal(function()
            if self:safeCheck() then
                self:handBookItemRunInAction()
            end
        end, 0.02)
    end
    self.func1()
end 

function QUIDialogHandBookClient:handBookItemRunInAction()
    self._isHandBookItemRuning = true
    local time = 0.14
    local i = 1
    local maxIndex = QUIDialogHandBookClient.TOTAL_BOOK_CELL / (QUIDialogHandBookClient.TOTAL_BOOK_CELL / self._multiItems)
    self.func2 = function()
        if i <= maxIndex then
            local item1 = self._listView:getItemByIndex(i)
            local item2 = self._listView:getItemByIndex(i + self._multiItems)

            if item1 ~= nil then
                local array1 = CCArray:create()
                array1:addObject(CCCallFunc:create(function()
                        makeNodeFadeToOpacity(item1, time)
                    end))

                array1:addObject(CCEaseSineOut:create(CCMoveBy:create(time, ccp(-self._sheetLeyoutWidth, 0))))

                local array2 = CCArray:create()
                array2:addObject(CCSpawn:create(array1))
                item1:runAction(CCSequence:create(array2))
            end

            if item2 ~= nil then
                local array1 = CCArray:create()
                array1:addObject(CCCallFunc:create(function()
                        makeNodeFadeToOpacity(item2, time)
                    end))
                array1:addObject(CCEaseSineOut:create(CCMoveBy:create(time, ccp(-self._sheetLeyoutWidth, 0))))

                local array2 = CCArray:create()
                array2:addObject(CCDelayTime:create(0.08))
                array2:addObject(CCSpawn:create(array1))
                item2:runAction(CCSequence:create(array2))
            end

            i = i + 1
            self._handBookItemRunOutScheduler = scheduler.performWithDelayGlobal(self.func2, 0.05)
        else
            self._isHandBookItemRuning = false
            self._listView:setCanNotTouchMove(false)
        end
    end
    self.func2()
end 

function QUIDialogHandBookClient:_clickHandBookCellHandler( x, y, touchNode, listView )
    app.sound:playSound("common_others")
    local touchIndex = listView:getCurTouchIndex()
    local selectActorId = self._allHerosID[touchIndex]
    self:_selectHeroByActorId(selectActorId)
end

function QUIDialogHandBookClient:_clickAdmireHandler( x, y, touchNode, listView )
    app.sound:playSound("common_others")
    local touchIndex = listView:getCurTouchIndex()
    local selectActorId = self._allHerosID[touchIndex]
    self:_admireHeroByActorId(selectActorId, touchIndex)
end

function QUIDialogHandBookClient:_selectHeroByActorId(selectActorId)
    -- 选择英雄
    local selectActorId = tostring(selectActorId)
    local pos = 0
    for i, actorId in ipairs(self._onlineHerosID) do
        if actorId == selectActorId then
            pos = i
            break
        end
    end
    if pos > 0 then
        app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogHandBookMain",
            options = {herosID = self._onlineHerosID, pos = pos}})
    else
        app.tip:floatTip("敬请期待")
    end
end

function QUIDialogHandBookClient:_startScrollByActorId()
    local showActorId = tostring(remote.handBook.showActorId)
    local pos = 0
    for i, actorId in ipairs(self._allHerosID) do
        if actorId == showActorId then
            pos = i
            break
        end
    end
    -- print("QUIDialogHandBookClient:_startScrollByActorId() showActorId = ", showActorId, pos, remote.handBook.showActorId)
    if pos > 5 then
        self._listView:startScrollToIndex(pos, false, 100, nil, -40)
    else
        self:handBookItemRunOutAction()
    end
end

function QUIDialogHandBookClient:_admireHeroByActorId(admireActorId, touchIndex)
    -- 点赞
    remote.handBook:handBookAdmireRequest(admireActorId, 0, admireActorId, self:safeHandler(function()
            local item = self._listView:getItemByIndex(touchIndex)
            if item and item.refreshAdmireInfo then
                item:refreshAdmireInfo(true)
            end
        end))
end

-- function QUIDialogHandBookClient:_backClickHandler()
--     self:playEffectOut()
-- end

function QUIDialogHandBookClient:viewAnimationOutHandler()
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_SPECIFIC_CONTROLLER, nil, self)
end

return QUIDialogHandBookClient