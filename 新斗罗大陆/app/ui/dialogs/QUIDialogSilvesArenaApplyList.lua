--
-- Kumo.Wang
-- 西尔维斯大斗魂场申请列表
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogSilvesArenaApplyList = class("QUIDialogSilvesArenaApplyList", QUIDialog)

local QListView = import("...views.QListView")
local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")

local QUIWidgetSilvesArenaApplyList = import("..widgets.QUIWidgetSilvesArenaApplyList")

function QUIDialogSilvesArenaApplyList:ctor(options)
    local ccbFile = "ccb/Dialog_SilvesArena_PlayerList.ccbi"
    local callBacks = {
        {ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
        {ccbCallbackName = "onTriggerOK", callback = handler(self, self._onTriggerOK)},
    }
    QUIDialogSilvesArenaApplyList.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

    q.setButtonEnableShadow(self._ccbOwner.btn_ok)

    self._ccbOwner.frame_tf_title:setString("申请列表")
    self._ccbOwner.tf_btn_ok:setString("刷 新")

    if options then
        self._callback = options.callback
    end

    self:_init()
end

function QUIDialogSilvesArenaApplyList:viewDidAppear()
    QUIDialogSilvesArenaApplyList.super.viewDidAppear(self)
end

function QUIDialogSilvesArenaApplyList:viewAnimationInHandler()
    QUIDialogSilvesArenaApplyList.super.viewAnimationInHandler(self)
    
    remote.silvesArena:silvesArenaGetApplyListRequest(function()
        if self:safeCheck() then
            self:_update(true)
        end
    end)
end

function QUIDialogSilvesArenaApplyList:viewWillDisappear()
    QUIDialogSilvesArenaApplyList.super.viewWillDisappear(self)
end

function QUIDialogSilvesArenaApplyList:_init()
    self._applyInfoList = {}
end

function QUIDialogSilvesArenaApplyList:_update( isForce )
    if q.isEmpty(remote.silvesArena.applyInfo) or q.isEmpty(remote.silvesArena.applyInfo.applyFighter) then
        if self._listViewLayout then 
            self._listViewLayout:clear(true)
            self._listViewLayout = nil
        end
    else
        if self._listViewLayout then 
            self._listViewLayout:clear(true)
            self._listViewLayout = nil
        end

        if isForce then
            self._applyInfoList = {}
        end

        if q.isEmpty(self._applyInfoList) then
            self._applyInfoList = remote.silvesArena.applyInfo.applyFighter
        end

        table.sort(self._applyInfoList, function(a, b)
            if a.force ~= b.force then
                return a.force > b.force 
            elseif a.level ~= b.level then
                return a.level > b.level
            elseif a.vip ~= b.vip then
                return a.vip > b.vip
            end
        end)
        
        self:_updateListView()
    end
end

function QUIDialogSilvesArenaApplyList:_updateListView()
    if not self._listViewLayout then
        local cfg = {
            renderItemCallBack = handler(self, self._renderItemHandler),
            isVertical = true,
            ignoreCanDrag = true,
            spaceY = 0,
            totalNumber = #self._applyInfoList,
        }
        self._listViewLayout = QListView.new(self._ccbOwner.sheet_layout, cfg)
    else
        self._listViewLayout:reload({#self._applyInfoList})
    end
end

function QUIDialogSilvesArenaApplyList:_renderItemHandler(list, index, info )
    local isCacheNode = true
    local itemData = self._applyInfoList[index]

    local item = list:getItemFromCache()
    if not item then
        item = QUIWidgetSilvesArenaApplyList.new()
        isCacheNode = false
    end

    item:setInfo(itemData)
    info.item = item
    info.size = item:getContentSize()

    list:registerBtnHandler(index, "btn_promise", handler(self, self._onTriggerPromise), nil, true)
    list:registerBtnHandler(index, "btn_refuse", handler(self, self._onTriggerRefuse), nil, true)
    list:registerBtnHandler(index, "btn_hero_info", handler(self, self._onTriggerHeroInfo))

    return isCacheNode
end

function QUIDialogSilvesArenaApplyList:_onTriggerPromise( x, y, touchNode, listView )
    app.sound:playSound("common_small")
    local touchIndex = listView:getCurTouchIndex()
    local item = listView:getItemByIndex(touchIndex)
    if item and item.getInfo then
        local info = item:getInfo()
        if not q.isEmpty(info) and info.userId then
            remote.silvesArena:silvesArenaPromissTeamRequest(info.userId, false, function()
                if self:safeCheck() then
                    app.tip:floatTip("通过成功")
                    self:_delApplyInfo(info.userId)
                end
            end)
        else
            self:_update()
        end
    end
end

function QUIDialogSilvesArenaApplyList:_delApplyInfo(delUserId)
    if not delUserId then return end
    local delIndex = 0
    for index, info in ipairs(self._applyInfoList) do
        if info.userId == delUserId then
            delIndex = index
            break
        end
    end
    if delIndex > 0 then
        table.remove(self._applyInfoList, delIndex)
        self:_update()
    end
end

function QUIDialogSilvesArenaApplyList:_onTriggerRefuse( x, y, touchNode, listView )
    app.sound:playSound("common_small")
    local touchIndex = listView:getCurTouchIndex()
    local item = listView:getItemByIndex(touchIndex)
    if item and item.getInfo then
        local info = item:getInfo()
        if not q.isEmpty(info) and info.userId then
            remote.silvesArena:silvesArenaPromissTeamRequest(info.userId, true, function()
                if self:safeCheck() then
                    self:_delApplyInfo(info.userId)
                end
            end)
        else
            self:_update()
        end
    end
end

function QUIDialogSilvesArenaApplyList:_onTriggerHeroInfo( x, y, touchNode, listView )
    app.sound:playSound("common_small")
    local touchIndex = listView:getCurTouchIndex()
    local item = listView:getItemByIndex(touchIndex)
    if item and item.getInfo then
        local info = item:getInfo()
        if not q.isEmpty(info) and info.userId then
            remote.silvesArena:silvesLookUserDetail(info.userId)
        end
    end
end

function QUIDialogSilvesArenaApplyList:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogSilvesArenaApplyList:_onTriggerClose(event)
    if q.buttonEventShadow(event, self._ccbOwner.frame_btn_close) == false then return end
    if event then
        app.sound:playSound("common_cancel")
    end
    self:playEffectOut()
end

function QUIDialogSilvesArenaApplyList:_onTriggerOK(event)
    if event then
        app.sound:playSound("common_small")
    end
    
    remote.silvesArena:silvesArenaGetApplyListRequest(function()
        if self:safeCheck() then
            self:_update(true)
        end
    end)
end

function QUIDialogSilvesArenaApplyList:viewAnimationOutHandler()
    local callback = self._callback

    self:popSelf()
    
    if callback then
        callback()
    end
end

return QUIDialogSilvesArenaApplyList
