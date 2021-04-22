--
-- Kumo.Wang
-- 回收站主界面
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogRecycle = class("QUIDialogRecycle", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QUIWidgetRecycleMenuButton = import("..widgets.QUIWidgetRecycleMenuButton")
local QListView = import("...views.QListView")

function QUIDialogRecycle:ctor(options)
	local ccbFile = "ccb/Dialog_Recycle.ccbi"
	local callBacks = {
	}
    QUIDialogRecycle.super.ctor(self,ccbFile,callBacks,options)
    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    page:setManyUIVisible()
    page.topBar:showWithHeroReborn()

    self._ccbOwner.frame_tf_title:setString("重生和分解")

    self:_init()
end

function QUIDialogRecycle:viewDidAppear()
    QUIDialogRecycle.super.viewDidAppear(self)
    self:addBackEvent()

    self:_initMenuButtonListView()
    self:_initClient()
end

function QUIDialogRecycle:viewWillDisappear()
    QUIDialogRecycle.super.viewWillDisappear(self)
	self:removeBackEvent()
end

function QUIDialogRecycle:_init()
    self._menuBtnData = remote.recycle:getRecycleMenuButtonData()
    if not self._menuBtnData or #self._menuBtnData == 0 then return end

    self._isNeedReload = false
    self._curSelectedId = self:getOptions().id or self._menuBtnData[1].id
    self._curShowId = self._curSelectedId

    -- 校准self._curSelectedId和self._curShowId
    local btnType = remote.recycle:getRecycleButtonTypeById(self._curSelectedId)
    if btnType == remote.recycle.PARENT then
        -- 父按鈕
        self:_addSubmenuData(self._curSelectedId)
    elseif btnType == remote.recycle.CHILD then
        -- 子按鈕
        local parentId = remote.recycle:getRecycleParentIdByChildId(self._curSelectedId)
        if parentId then
            self._curShowId = parentId
            self:_addSubmenuData(parentId)
        else
            -- 傳入的初始化id，不存在或者未解鎖
            self:getOptions().id = self._menuBtnData[1].id
            self._curSelectedId = self:getOptions().id
            self._curShowId = nil
        end
    else
        -- 點擊非父非子按鈕
        for _, value in ipairs(self._menuBtnData) do
            value.isSelected = false
            if value.id == self._curSelectedId then
                value.isSelected = true
            end
        end
    end
end

function QUIDialogRecycle:_isCanDrag()
    if not self._maxMenuHeight then
        self._maxMenuHeight = self._ccbOwner.sheet_layout_menu:getContentSize().height
    end
    if not self._unitMenuHeight then
        local item = QUIWidgetRecycleMenuButton.new()
        self._unitMenuHeight = item:getContentSize().height
    end

    return self._unitMenuHeight * #self._menuBtnData > self._maxMenuHeight
end

function QUIDialogRecycle:_initMenuButtonListView()
    print("[QUIDialogRecycle:_initMenuButtonListView()] ", self._menuBtnListView, self._curShowId, self._curSelectedId)
    if not self._menuBtnListView then
        local cfg = {
            renderItemCallBack = function( list, index, info )
                local isCacheNode = true
                local itemData = self._menuBtnData[index]
                local item = list:getItemFromCache()
                if not item then
                    item = QUIWidgetRecycleMenuButton.new()
                    item:addEventListener(QUIWidgetRecycleMenuButton.EVENT_CLICK, handler(self, self._onMenuButtonClickHandler))
                    isCacheNode = false
                end
                item:setInfo(itemData)

                info.item = item
                info.size = item:getContentSize()

                list:registerBtnHandler(index, "widget_btn_menu", "onTriggerClick", nil, true)

                return isCacheNode
            end,
            ignoreCanDrag = true,
            enableShadow = false,
            totalNumber = #self._menuBtnData 
        }
        self._menuBtnListView = QListView.new(self._ccbOwner.sheet_layout_menu, cfg)      

        local _headIndex = self:_getScrollToIndex()
        self:_startScrollToIndex(_headIndex)
    else
       
        if self._isNeedReload then
            self._isNeedReload = false
            -- 當菜單成員有變化的時候，需要reload
            self._menuBtnListView:reload({totalNumber = #self._menuBtnData})
            -- reload之後，需要定位一下
            local _headIndex = self:_getScrollToIndex()
            self:_startScrollToIndex(_headIndex)
        else
            self._menuBtnListView:refreshData()
        end
    end
end

function QUIDialogRecycle:_getScrollToIndex()
    if not self._menuBtnListView or not self._curShowId or not self:_isCanDrag() then return 1 end
    
    for index, value in ipairs(self._menuBtnData) do
        if value.id == self._curShowId then
            self._curShowId = nil
            return index
        end
    end

    return 1
end

function QUIDialogRecycle:_startScrollToIndex(index)
    if not self._menuBtnListView or not index or not self:_isCanDrag() then return end
    self._menuBtnListView:startScrollToIndex(index, false, 100)
end

function QUIDialogRecycle:_onMenuButtonClickHandler(e)
    print("[QUIDialogRecycle:_onMenuButtonClickHandler()] ", self._menuBtnListView)
    if not self._menuBtnListView then return end

    if e.info.member then
        -- 點擊父按鈕
        self._curShowId = e.info.id
        self:_addSubmenuData(e.info.id)
        self:_initMenuButtonListView()
        self:_initClient()
        return
    elseif e.info.isSubmenu then
        -- 點擊子按鈕
        self._curShowId = e.info.parentId
        self._curSelectedId = e.info.id
    else
        -- 點擊非父非子按鈕
        local lastMenuCount = #self._menuBtnData
        self._menuBtnData = remote.recycle:getRecycleMenuButtonData()
        if lastMenuCount ~= #self._menuBtnData then
            self._isNeedReload = true
        end
        self._curShowId = e.info.id
        self._curSelectedId = e.info.id
    end

    for _, value in ipairs(self._menuBtnData) do
        value.isSelected = false
        if e.info.id == value.id then
            value.isSelected = true
        elseif e.info.isSubmenu and e.info.parentId == value.id then
            -- 點擊子按鈕的父按鈕
            value.isSelected = true
        end
    end

    self:_initMenuButtonListView()
    self:_initClient()
end

function QUIDialogRecycle:_addSubmenuData(parentId)
    self._menuBtnData = remote.recycle:getRecycleMenuButtonData()
    local submenuData = remote.recycle:getRecycleSubmenuButtonDataByParentId(parentId)
    if not submenuData or next(submenuData) == nil then return end

    local tbl = {}
    for index, value in ipairs(self._menuBtnData) do
        table.insert(tbl, value)
        value.isSelected = false
        if value.id == parentId then
            -- 點擊子按鈕的父按鈕
            value.isSelected = true
            for i, data in ipairs(submenuData) do
                data.isSelected = false
                if i == 1 then
                    data.isSelected = true
                    self._curSelectedId = data.id
                end
                table.insert(tbl, data)
            end
        end
    end

    self._isNeedReload = true
    self._menuBtnData = tbl
end

function QUIDialogRecycle:_getMenuDataById(id)
    for _, value in ipairs(self._menuBtnData) do
        if value.id == id then
            return value
        end
    end

    return {}
end

function QUIDialogRecycle:_initClient()
    print("[QUIDialogRecycle:_initClient()] ", self._curSelectedId)
    if not self._widgetClient or self._widgetClient:getWidgetId() ~= self._curSelectedId then
        self._ccbOwner.node_client:removeAllChildren()
        local config = self:_getMenuDataById(self._curSelectedId)
        QKumo(config)
        self._widgetClient = nil
        if not config or not config.class then return end

        local widgetClass = import(app.packageRoot .. ".ui.widgets." .. config.class)
        self._widgetClient = widgetClass.new({widgetId = self._curSelectedId})
        self._ccbOwner.node_client:addChild(self._widgetClient)
        self:getOptions().id = self._curSelectedId
    end
end

function QUIDialogRecycle:onTriggerBackHandler(tag)
	-- if self._widget._playing then return end
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
end

function QUIDialogRecycle:onTriggerHomeHandler(tag)
	-- if self._widget._playing then return end
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
end

return QUIDialogRecycle
