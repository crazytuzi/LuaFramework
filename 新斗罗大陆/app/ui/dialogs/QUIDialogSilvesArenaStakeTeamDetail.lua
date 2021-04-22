-- 
-- Kumo.Wang
-- 押注阵容对比界面
--

local QUIDialog = import(".QUIDialog")
local QUIDialogSilvesArenaStakeTeamDetail = class("QUIDialogSilvesArenaStakeTeamDetail", QUIDialog)

local QListView = import("...views.QListView")
local QReplayUtil = import("...utils.QReplayUtil")
local QUIViewController = import("..QUIViewController")
local QUIWidgetAvatar = import("..widgets.QUIWidgetAvatar")

local QUIWidgetSilvesArenaStakeTeamDetail = import("..widgets.QUIWidgetSilvesArenaStakeTeamDetail")

QUIDialogSilvesArenaStakeTeamDetail.EVENT_CLICK_SHARED = "EVENT_CLICK_SHARED"

function QUIDialogSilvesArenaStakeTeamDetail:ctor(options)
    local ccbFile = "ccb/Dialog_SilvesArena_Stake_Team_Detail.ccbi"
    local callBack = {
        {ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
    }
    QUIDialogSilvesArenaStakeTeamDetail.super.ctor(self, ccbFile, callBack, options)
    self.isAnimation = true

    self._ccbOwner.frame_node_center_top:setVisible(true)
    self._ccbOwner.frame_tf_title:setString("阵容对比")

    if options then
        self._teamInfo = options.teamInfo
    end
    
    self:_initInfo()
    self:_initData()
end

function QUIDialogSilvesArenaStakeTeamDetail:_initInfo()
    if q.isEmpty(self._teamInfo) or #self._teamInfo < 2 then
        self:_onTriggerClose()
        return
    end

    local team1Info = self._teamInfo[1]
    local team2Info = self._teamInfo[2]

    if q.isEmpty(team1Info) or q.isEmpty(team2Info) then return end

    if not q.isEmpty(team1Info.leader) then
        self._ccbOwner.node_team1_head1:removeAllChildren()
        local head = QUIWidgetAvatar.new(team1Info.leader.avatar)
        head:setSilvesArenaPeak(team1Info.leader.championCount)
        self._ccbOwner.node_team1_head1:addChild(head)
    end
    if not q.isEmpty(team1Info.member1) then
        self._ccbOwner.node_team1_head2:removeAllChildren()
        local head = QUIWidgetAvatar.new(team1Info.member1.avatar)
        head:setSilvesArenaPeak(team1Info.member1.championCount)
        self._ccbOwner.node_team1_head2:addChild(head)
    end
    if not q.isEmpty(team1Info.member2) then
        self._ccbOwner.node_team1_head3:removeAllChildren()
        local head = QUIWidgetAvatar.new(team1Info.member2.avatar)
        head:setSilvesArenaPeak(team1Info.member2.championCount)
        self._ccbOwner.node_team1_head3:addChild(head)
    end

    if not q.isEmpty(team2Info.leader) then
        self._ccbOwner.node_team2_head1:removeAllChildren()
        local head = QUIWidgetAvatar.new(team2Info.leader.avatar)
        head:setSilvesArenaPeak(team2Info.leader.championCount)
        self._ccbOwner.node_team2_head1:addChild(head)
    end
    if not q.isEmpty(team2Info.member1) then
        self._ccbOwner.node_team2_head2:removeAllChildren()
        local head = QUIWidgetAvatar.new(team2Info.member1.avatar)
        head:setSilvesArenaPeak(team2Info.member2.championCount)
        self._ccbOwner.node_team2_head2:addChild(head)
    end
    if not q.isEmpty(team2Info.member2) then
        self._ccbOwner.node_team2_head3:removeAllChildren()
        local head = QUIWidgetAvatar.new(team2Info.member2.avatar)
        head:setSilvesArenaPeak(team2Info.member2.championCount)
        self._ccbOwner.node_team2_head3:addChild(head)
    end

    if team1Info.teamName and team1Info.teamName ~= "" then
        self._ccbOwner.tf_team1_name:setString(team1Info.teamName)
        self._ccbOwner.tf_team1_name:setVisible(true)
    else
        self._ccbOwner.tf_team1_name:setVisible(false)
    end

    if team2Info.teamName and team2Info.teamName ~= "" then
        self._ccbOwner.tf_team2_name:setString(team2Info.teamName)
        self._ccbOwner.tf_team2_name:setVisible(true)
    else
        self._ccbOwner.tf_team2_name:setVisible(false)
    end
end

function QUIDialogSilvesArenaStakeTeamDetail:_initData()
    if q.isEmpty(self._teamInfo) or #self._teamInfo < 2 then
        self:_onTriggerClose()
        return
    end

    self._data = {}
    local team1Info = self._teamInfo[1]
    local team2Info = self._teamInfo[2]

    if q.isEmpty(team1Info) or q.isEmpty(team2Info) then return end

    local tbl1 = {}
    if team1Info.leader then
        table.insert(tbl1, team1Info.leader)
    end
    if team1Info.member1 then
        table.insert(tbl1, team1Info.member1)
    end
    if team1Info.member2 then
        table.insert(tbl1, team1Info.member2)
    end
    table.sort(tbl1, function(a, b)
        return a.silvesArenaFightPos < b.silvesArenaFightPos
    end)

    local tbl2 = {}
    if team2Info.leader then
        table.insert(tbl2, team2Info.leader)
    end
    if team2Info.member1 then
        table.insert(tbl2, team2Info.member1)
    end
    if team2Info.member2 then
        table.insert(tbl2, team2Info.member2)
    end
    table.sort(tbl2, function(a, b)
        return a.silvesArenaFightPos < b.silvesArenaFightPos
    end)

    -- 由于押注的时候，显示全部3组阵容
    for i = 1, remote.silvesArena.MAX_TEAM_MEMBER_COUNT, 1 do
        self._data[i] = {player1 = tbl1[i], player2 = tbl2[i]}
    end

    self:_initListView()
end

function QUIDialogSilvesArenaStakeTeamDetail:_initListView()
    if not self._listView then
        local cfg = {
            renderItemCallBack = function( list, index, info )
                local isCacheNode = true
                local itemData = self._data[index]
                local item = list:getItemFromCache()

                if not item then
                    item = QUIWidgetSilvesArenaStakeTeamDetail.new()
                    isCacheNode = false
                end

                item:setInfo(itemData)
                info.item = item
                info.size = item:getContentSize()
                
                list:registerBtnHandler(index, "btn_one_replay", handler(self, self._onTriggerReplay), nil, true)

                return isCacheNode
            end,
            ignoreCanDrag = true,
            enableShadow = false,
            totalNumber = #self._data,
        }  
        self._listView = QListView.new(self._ccbOwner.sheet_layout, cfg)
    else
        self._listView:reload({totalNumber = #self._data})
    end
end

function QUIDialogSilvesArenaStakeTeamDetail:_backClickHandler()
    self:playEffectOut()
end

function QUIDialogSilvesArenaStakeTeamDetail:_onTriggerClose(event)
    if q.buttonEventShadow(event, self._ccbOwner.frame_btn_close) == false then return end
    app.sound:playSound("common_cancel")
    self:playEffectOut()
end

return QUIDialogSilvesArenaStakeTeamDetail

