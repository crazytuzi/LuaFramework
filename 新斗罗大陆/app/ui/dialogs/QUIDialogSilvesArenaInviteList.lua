--
-- Kumo.Wang
-- 西尔维斯大斗魂场邀请列表
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogSilvesArenaInviteList = class("QUIDialogSilvesArenaInviteList", QUIDialog)

local QListView = import("...views.QListView")
local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")

local QUIWidgetSilvesArenaInviteList = import("..widgets.QUIWidgetSilvesArenaInviteList")

function QUIDialogSilvesArenaInviteList:ctor(options)
    local ccbFile = "ccb/Dialog_SilvesArena_PlayerList.ccbi"
    local callBacks = {
        {ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
        {ccbCallbackName = "onTriggerOK", callback = handler(self, self._onTriggerOK)},
    }
    QUIDialogSilvesArenaInviteList.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

    q.setButtonEnableShadow(self._ccbOwner.btn_ok)

    self._ccbOwner.frame_tf_title:setString("邀请队员")
    self._ccbOwner.tf_btn_ok:setString("邀 请")

    if options then
        self._callback = options.callback
    end

    self:_init()
end

function QUIDialogSilvesArenaInviteList:viewDidAppear()
    QUIDialogSilvesArenaInviteList.super.viewDidAppear(self)
end

function QUIDialogSilvesArenaInviteList:viewAnimationInHandler()
    QUIDialogSilvesArenaInviteList.super.viewAnimationInHandler(self)
    
    remote.silvesArena:silvesArenaGetOnlineUserRequest(function()
        if self:safeCheck() then
            self:_update()
        end
    end)
end

function QUIDialogSilvesArenaInviteList:viewWillDisappear()
    QUIDialogSilvesArenaInviteList.super.viewWillDisappear(self)
end

function QUIDialogSilvesArenaInviteList:_init()
    self._onlineUserInfoList = {}
    self._selectedIdList = {}
end

function QUIDialogSilvesArenaInviteList:_update()
    if q.isEmpty(remote.silvesArena.onlineUserInfo) and q.isEmpty(remote.silvesArena.onlineUserInfo.onlineFighter)then
        if self._listViewLayout then 
            self._listViewLayout:clear(true)
            self._listViewLayout = nil
        end
    else
        if self._listViewLayout then 
            self._listViewLayout:clear(true)
            self._listViewLayout = nil
        end

        if not q.isEmpty(remote.silvesArena.myTeamInfo) then
            for _, info in ipairs(remote.silvesArena.onlineUserInfo.onlineFighter) do
                if not ((remote.silvesArena.myTeamInfo.leader and info.userId == remote.silvesArena.myTeamInfo.leader.userId) 
                    or (remote.silvesArena.myTeamInfo.member1 and info.userId == remote.silvesArena.myTeamInfo.member1.userId)
                    or (remote.silvesArena.myTeamInfo.member2 and info.userId == remote.silvesArena.myTeamInfo.member2.userId)) then
                    table.insert(self._onlineUserInfoList, info)
                end
            end
        else
            self._onlineUserInfoList = remote.silvesArena.onlineUserInfo.onlineFighter
        end

        self:_updateListView()
    end
end

function QUIDialogSilvesArenaInviteList:_updateListView()
    if not self._listViewLayout then
        local cfg = {
            renderItemCallBack = handler(self, self._renderItemHandler),
            isVertical = true,
            ignoreCanDrag = true,
            spaceY = 0,
            totalNumber = #self._onlineUserInfoList,
        }
        self._listViewLayout = QListView.new(self._ccbOwner.sheet_layout, cfg)
    else
        self._listViewLayout:reload({#self._onlineUserInfoList})
    end
end

function QUIDialogSilvesArenaInviteList:_renderItemHandler(list, index, info )
    local isCacheNode = true
    local itemData = self._onlineUserInfoList[index]

    local item = list:getItemFromCache()
    if not item then
        item = QUIWidgetSilvesArenaInviteList.new()
        isCacheNode = false
    end

    item:setInfo(itemData)
    info.item = item
    info.size = item:getContentSize()

    list:registerBtnHandler(index, "btn_select_invite", handler(self, self._onTriggerSelectInvite))

    return isCacheNode
end

function QUIDialogSilvesArenaInviteList:_onTriggerSelectInvite( x, y, touchNode, listView )
    app.sound:playSound("common_small")
    local touchIndex = listView:getCurTouchIndex()
    local item = listView:getItemByIndex(touchIndex)
    if item and item.getInfo then
        local info = item:getInfo()
        if not q.isEmpty(info) and info.userId then
            if info.isSelected then
                info.isSelected = false
                local delIndex = 0
                for index, uid in ipairs(self._selectedIdList) do
                    if uid == info.userId then
                        delIndex = index
                        break
                    end
                end
                if delIndex > 0 then
                    table.remove(self._selectedIdList, delIndex)
                end
            else
                info.isSelected = true
                table.insert(self._selectedIdList, info.userId)
            end

            if item.update then
                item:update(info)
            end
        else
            self:_update()
        end
    end
end

function QUIDialogSilvesArenaInviteList:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogSilvesArenaInviteList:_onTriggerClose(event)
    if q.buttonEventShadow(event, self._ccbOwner.frame_btn_close) == false then return end
    if event then
        app.sound:playSound("common_cancel")
    end
    self:playEffectOut()
end

function QUIDialogSilvesArenaInviteList:_onTriggerOK(event)
    if event then
        app.sound:playSound("common_small")
    end
    
    if q.isEmpty(self._selectedIdList) then
        app.tip:floatTip("请选择邀请的成员～")
        return
    else
        if remote.silvesArena.myTeamInfo then
            local existUidDic = {} 
            local tbl = {}
            for _, uid in ipairs(self._selectedIdList) do
                if not existUidDic[uid] then
                    table.insert(tbl, uid)
                    existUidDic[uid] = true
                end
            end
            local teamId = remote.silvesArena.myTeamInfo.teamId
            if teamId then
                remote.silvesArena:silvesArenaInviteRequest(tbl, teamId, function()
                    if self:safeCheck() then
                        self:_onTriggerClose()
                    end
                end)
            else
                self:_onTriggerClose()
            end
        else
            self:_onTriggerClose()
        end
    end
end

function QUIDialogSilvesArenaInviteList:viewAnimationOutHandler()
    local callback = self._callback

    self:popSelf()
    
    if callback then
        callback()
    end
end

return QUIDialogSilvesArenaInviteList
