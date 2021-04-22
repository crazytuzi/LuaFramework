--
-- Kumo.Wang
-- 西尔维斯大斗魂场组队列表界面
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogSilvesArenaRoomList = class("QUIDialogSilvesArenaRoomList", QUIDialog)

local QListView = import("...views.QListView")
local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")

local QUIWidgetSilvesArenaRoomList = import("..widgets.QUIWidgetSilvesArenaRoomList")

QUIDialogSilvesArenaRoomList.ROOM_LIST = "ROOM_LIST"
QUIDialogSilvesArenaRoomList.APPLIED_ROOM = "APPLIED_ROOM"

function QUIDialogSilvesArenaRoomList:ctor(options)
    local ccbFile = "ccb/Dialog_SilvesArena_RoomList.ccbi"
    local callBacks = {
        {ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
        {ccbCallbackName = "onTriggerCreate", callback = handler(self, self._onTriggerCreate)},
        {ccbCallbackName = "onTriggerSearch", callback = handler(self, self._onTriggerSearch)},
        {ccbCallbackName = "onTriggerSelectForce", callback = handler(self, self._onTriggerSelectForce)},
        {ccbCallbackName = "onTriggerSelectFull", callback = handler(self, self._onTriggerSelectFull)},

        {ccbCallbackName = "onTriggerRoomList", callback = handler(self, self._onTriggerRoomList)},
        {ccbCallbackName = "onTriggerAppliedRoom", callback = handler(self, self._onTriggerAppliedRoom)},
    }
    QUIDialogSilvesArenaRoomList.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

    q.setButtonEnableShadow(self._ccbOwner.btn_create)
    q.setButtonEnableShadow(self._ccbOwner.btn_search)

    self._ccbOwner.sp_room_list_tips:setVisible(false)
    self._ccbOwner.sp_applied_room_tips:setVisible(false)

    self._ccbOwner.frame_tf_title:setString("队伍列表")
    
    if options then
        self._callback = options.callback
        self._tab = options.tab
    end

    if not self._tab then
        self._tab = QUIDialogSilvesArenaRoomList.ROOM_LIST
    end

    self:_init()
end

function QUIDialogSilvesArenaRoomList:viewDidAppear()
    QUIDialogSilvesArenaRoomList.super.viewDidAppear(self)

    self:_updateSelectState()
end

function QUIDialogSilvesArenaRoomList:viewAnimationInHandler()
    QUIDialogSilvesArenaRoomList.super.viewAnimationInHandler(self)

    remote.silvesArena:silvesArenaGetRoomListRequest(function ()
        if self:safeCheck() then
            self:_update()
        end
    end)
end

function QUIDialogSilvesArenaRoomList:viewWillDisappear()
    QUIDialogSilvesArenaRoomList.super.viewWillDisappear(self)
end

function QUIDialogSilvesArenaRoomList:_init()
    self._teamInfoList = {}
    self._searchTeamSymbol = -1
    
    self._ccbOwner.node_empty:setVisible(false)

    self:_setButtonState()
end

function QUIDialogSilvesArenaRoomList:_updateRoomList()
    local notAppliedTbl = {}
    local appliedTbl = {}

    if not q.isEmpty(remote.silvesArena.teamInfo) then
        for _, info in ipairs(remote.silvesArena.teamInfo) do
            local isAdd = false
            if not q.isEmpty(remote.silvesArena.userInfo) then
                for _, teamId in ipairs(remote.silvesArena.userInfo.myApplyIdList or {}) do
                    if teamId == info.teamId then
                        isAdd = true
                        table.insert(appliedTbl, info)
                    end
                end
            end

            if not isAdd then
                table.insert(notAppliedTbl, info)
            end
        end
    end

    if self._tab == QUIDialogSilvesArenaRoomList.ROOM_LIST then
        return notAppliedTbl
    else
        return appliedTbl
    end
end

function QUIDialogSilvesArenaRoomList:_update(searchTeamInfo)
    self:_setButtonState()

    local roomList = self:_updateRoomList()
    local tbl = {}
    if q.isEmpty(roomList) then
        if self._searchTeamSymbol and self._searchTeamSymbol ~= -1 then
            if q.isEmpty(searchTeamInfo) then
                self._searchTeamSymbol = -1
                app.tip:floatTip("房间不存在")
                self:_update()
                return
            else
                table.insert(tbl, searchTeamInfo)
            end
        else
            if self._tab == QUIDialogSilvesArenaRoomList.ROOM_LIST then
                self._ccbOwner.tf_empty:setString("魂师大人，当前还没有合适\n的队伍，建议您可以创建队\n伍等待别人的加入哦～")
            else
                self._ccbOwner.tf_empty:setString("魂师大人，当前您还没有申请\n的队伍，快去申请队伍吧")
            end
        end
    else
        for _, info in ipairs(roomList) do
            local _info = {}

            if self._searchTeamSymbol and self._searchTeamSymbol ~= -1 then
                if info.symbol == self._searchTeamSymbol then
                    _info = clone(info)
                    if not q.isEmpty(remote.silvesArena.userInfo) then
                        for _, teamId in ipairs(remote.silvesArena.userInfo.myApplyIdList or {}) do
                            if teamId == info.teamId then
                                _info.isApplied = true
                            end
                        end
                    end
                    table.insert(tbl, _info)
                end
            else
                local isAdd = true
                if not q.isEmpty(remote.silvesArena.userInfo) then
                    for _, teamId in ipairs(remote.silvesArena.userInfo.myApplyIdList or {}) do
                        if teamId == info.teamId then
                            _info = clone(info)
                            _info.isApplied = true
                        end
                    end
                end

                if q.isEmpty(_info) then
                    -- if remote.silvesArena.isSelectedForce and remote.herosUtil:getMostHeroBattleForce() < (info.teamMinForce or 0) then
                    local defensForce = remote.teamManager:getBattleForceForAllTeam(remote.teamManager.SILVES_ARENA_TEAM, false)
                    if remote.silvesArena.isSelectedForce and (defensForce or 0) < (info.teamMinForce or 0) then
                        isAdd = false
                    elseif remote.silvesArena.isSelectedFull and (info.memberCnt or 0) >= remote.silvesArena.MAX_TEAM_MEMBER_COUNT then
                        isAdd = false
                    end
                end

                if isAdd then
                    if q.isEmpty(_info) then
                        _info = clone(info)
                    end
                    table.insert(tbl, _info)
                end
            end
        end


        if q.isEmpty(tbl) then
            if self._searchTeamSymbol and self._searchTeamSymbol ~= -1 then
                if q.isEmpty(searchTeamInfo) then
                    self._searchTeamSymbol = -1
                    app.tip:floatTip("房间不存在")
                    self:_update()
                    return
                else
                    table.insert(tbl, searchTeamInfo)
                end
            end
        end
    end

    if self._listViewLayout then 
        self._listViewLayout:clear(true)
        self._listViewLayout = nil
    end
    if q.isEmpty(tbl) then
        self._ccbOwner.node_empty:setVisible(true)
        return
    else
        self._ccbOwner.node_empty:setVisible(false)
    end

    self._teamInfoList = tbl

    table.sort(self._teamInfoList, function(a, b)
        local aTtotalForce, aTotalNumber = 0, 0
        local bTtotalForce, bTotalNumber = 0, 0

        if not q.isEmpty(a.leader) then
            aTtotalForce = aTtotalForce + (a.leader.force or 0)
            if a.leader.force and a.leader.force > 0 then
                aTotalNumber = aTotalNumber + 1
            end
        end
        if not q.isEmpty(a.member1) then
            aTtotalForce = aTtotalForce + (a.member1.force or 0)
            if a.member1.force and a.member1.force > 0 then
                aTotalNumber = aTotalNumber + 1
            end
        end
        if not q.isEmpty(a.member2) then
            aTtotalForce = aTtotalForce + (a.member2.force or 0)
            if a.member2.force and a.member2.force > 0 then
                aTotalNumber = aTotalNumber + 1
            end
        end
        if not q.isEmpty(b.leader) then
            bTtotalForce = bTtotalForce + (b.leader.force or 0)
            if b.leader.force and b.leader.force > 0 then
                bTotalNumber = bTotalNumber + 1
            end
        end
        if not q.isEmpty(b.member1) then
            bTtotalForce = bTtotalForce + (b.member1.force or 0)
            if b.member1.force and b.member1.force > 0 then
                bTotalNumber = bTotalNumber + 1
            end
        end
        if not q.isEmpty(b.member2) then
            bTtotalForce = bTtotalForce + (b.member2.force or 0)
            if b.member2.force and b.member2.force > 0 then
                bTotalNumber = bTotalNumber + 1
            end
        end

        local _aTotalForce = 0
        if a.totalForce and a.totalForce > 0 then
            _aTotalForce = a.totalForce
        else
            _aTotalForce = aTtotalForce
        end

        local _bTotalForce = 0
        if b.totalForce and b.totalForce > 0 then
            _bTotalForce = b.totalForce
        else
            _bTotalForce = bTtotalForce
        end

        local aForce = _aTotalForce/aTotalNumber
        local bForce = _bTotalForce/bTotalNumber

        if a.isApplied ~= b.isApplied then
            return a.isApplied
        -- elseif a.totalForce ~= b.totalForce then
        --     return a.totalForce > b.totalForce
        -- elseif aTtotalForce ~= bTtotalForce then
        --     return aTtotalForce > bTtotalForce
        elseif aForce ~= bForce then
            return aForce > bForce
        else
            return a.symbol < b.symbol
        end
    end)

    print("[Kumo] QUIDialogSilvesArenaRoomList [Room count] ", #self._teamInfoList)

    self:_updateListView()
end

function QUIDialogSilvesArenaRoomList:_updateListView()
    if not self._listViewLayout then
        local cfg = {
            renderItemCallBack = handler(self, self._renderItemHandler),
            isVertical = true,
            ignoreCanDrag = true,
            spaceY = 0,
            totalNumber = #self._teamInfoList,
        }
        self._listViewLayout = QListView.new(self._ccbOwner.sheet_layout, cfg)
    else
        self._listViewLayout:reload({#self._teamInfoList})
    end
end

function QUIDialogSilvesArenaRoomList:_renderItemHandler(list, index, info )
    local isCacheNode = true
    local itemData = self._teamInfoList[index]

    local item = list:getItemFromCache()
    if not item then
        item = QUIWidgetSilvesArenaRoomList.new()
        isCacheNode = false
    end

    item:setInfo(itemData)
    info.item = item
    info.size = item:getContentSize()

    list:registerBtnHandler(index, "btn_apply", handler(self, self._onTriggerApply), nil, true)

    return isCacheNode
end

function QUIDialogSilvesArenaRoomList:_onTriggerApply( x, y, touchNode, listView )
    app.sound:playSound("common_small")
    local touchIndex = listView:getCurTouchIndex()
    local item = listView:getItemByIndex(touchIndex)
    if item and item.getInfo then
        local info = item:getInfo()
        if not q.isEmpty(info) and info.teamId then
            if info.isApplied then
                remote.silvesArena:silvesArenaApplyTeamRequest(info.teamId, true, function()
                        if self:safeCheck() then
                            self:_update()
                            -- if item.update then
                            --     info.isApplied = false
                            --     item:update(info)
                            -- end
                        end
                    end, function ()
                        if self:safeCheck() then
                            self:_update()
                        end
                    end)
            else
                local curApplyCnt = remote.silvesArena.userInfo and remote.silvesArena.userInfo.myApplyIdList and #remote.silvesArena.userInfo.myApplyIdList or 0
                local maxApplyCnt = db:getConfigurationValue("silves_arena_user_apply_max_count")
                if curApplyCnt >= maxApplyCnt then
                    app.tip:floatTip("最多可申请"..maxApplyCnt.."个队伍")
                    return
                else
                    remote.silvesArena:silvesArenaApplyTeamRequest(info.teamId, false, function()
                        if self:safeCheck() then
                            app.tip:floatTip("申请成功")
                            self:_update()
                            -- if item.update then
                            --     info.isApplied = true
                            --     item:update(info)
                            -- end
                        end
                    end, function ()
                        if self:safeCheck() then
                            self:_update()
                        end
                    end)
                end
            end
        else
            self:_update()
        end
    end
end

function QUIDialogSilvesArenaRoomList:_updateSelectState()
    self._ccbOwner.sp_select_force:setVisible(remote.silvesArena.isSelectedForce)
    self._ccbOwner.sp_select_full:setVisible(remote.silvesArena.isSelectedFull)

    self:_update()
end

function QUIDialogSilvesArenaRoomList:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogSilvesArenaRoomList:_onTriggerClose(event)
    if q.buttonEventShadow(event, self._ccbOwner.frame_btn_close) == false then return end
    if event then
        app.sound:playSound("common_cancel")
    end
    self:playEffectOut()
end

function QUIDialogSilvesArenaRoomList:_onTriggerSelectForce(event)
    if event then
        app.sound:playSound("common_cancel")
    end
    remote.silvesArena.isSelectedForce = not remote.silvesArena.isSelectedForce
    self:_updateSelectState()
end

function QUIDialogSilvesArenaRoomList:_onTriggerSelectFull(event)
    if event then
        app.sound:playSound("common_cancel")
    end
    remote.silvesArena.isSelectedFull = not remote.silvesArena.isSelectedFull
    self:_updateSelectState()
end

function QUIDialogSilvesArenaRoomList:_onTriggerSearch(event)
    if event then
        app.sound:playSound("common_cancel")
    end
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSilvesArenaSearchRoom", 
        options = {callback = handler(self, self._onSearch)}}, {isPopCurrentDialog = false})
end

function QUIDialogSilvesArenaRoomList:_onSearch( teamSymbol )
    if tonumber(teamSymbol) == nil then
        return
    end
    self._searchTeamSymbol = tonumber(teamSymbol)
    -- self:_update()
    remote.silvesArena:silvesGetTargetTeamRequest(self._searchTeamSymbol, function(data)
            local info = {}
            if data and data.silvesArenaGetTargetTeamResponse and data.silvesArenaGetTargetTeamResponse.myRankInfo then
                info = data.silvesArenaGetTargetTeamResponse.myRankInfo
            end
            if self:safeCheck() then
                self:_update(info)
            end
        end)
end

function QUIDialogSilvesArenaRoomList:_onTriggerCreate(event)
    if event then
        app.sound:playSound("common_cancel")
    end
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSilvesArenaCreateRoom", 
        options = {callback = handler(self, self._onCreate)}}, {isPopCurrentDialog = false})
end

function QUIDialogSilvesArenaRoomList:_onCreate( teamName, teamForceLimit )
    if not teamName or not teamForceLimit then
        return
    end
    remote.silvesArena:silvesArenaCreateTeamRequest(teamName, teamForceLimit, function()
        if self:safeCheck() then
            self:playEffectOut()
        end
    end)
end

function QUIDialogSilvesArenaRoomList:viewAnimationOutHandler()
    local callback = self._callback

    self:popSelf()
    
    if callback then
        callback()
    end
end

function QUIDialogSilvesArenaRoomList:_onTriggerRoomList(event)
    if event then
        app.sound:playSound("common_cancel")
    end
    self._tab = QUIDialogSilvesArenaRoomList.ROOM_LIST

    self:_update()
end

function QUIDialogSilvesArenaRoomList:_onTriggerAppliedRoom(event)
    if event then
        app.sound:playSound("common_cancel")
    end
    self._tab = QUIDialogSilvesArenaRoomList.APPLIED_ROOM

    self:_update()
end

function QUIDialogSilvesArenaRoomList:_setButtonState()
    self._ccbOwner.btn_room_list:setHighlighted(false)
    self._ccbOwner.btn_room_list:setEnabled(true)

    self._ccbOwner.btn_applied_room:setHighlighted(false)
    self._ccbOwner.btn_applied_room:setEnabled(true)

    if self._tab == QUIDialogSilvesArenaRoomList.ROOM_LIST then
        self._ccbOwner.btn_room_list:setHighlighted(true)
        self._ccbOwner.btn_room_list:setEnabled(false)
        self._ccbOwner.node_btn_search:setVisible(true)
    elseif self._tab == QUIDialogSilvesArenaRoomList.APPLIED_ROOM then
        self._ccbOwner.btn_applied_room:setHighlighted(true)
        self._ccbOwner.btn_applied_room:setEnabled(false)
        self._ccbOwner.node_btn_search:setVisible(false)
    end
end

return QUIDialogSilvesArenaRoomList
