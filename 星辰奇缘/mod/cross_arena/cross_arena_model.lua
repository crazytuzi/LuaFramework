CrossArenaModel = CrossArenaModel or BaseClass(BaseModel)

function CrossArenaModel:__init()
	self.crossArenaIcon = nil
	self.crossArenaWindow = nil
	self.crossArenaRoomListWindow = nil
    self.crossArenaRoomWindow = nil
    self.crossArenaLogWindow = nil
	self.crossArenaCreateTeamWindow = nil
    self.crossArenaInvitationWindow = nil
    self.crossArenaFighterWindow = nil

    self:InitData()
end

function CrossArenaModel:InitData()
    self.room_check = 1 -- 旗鼓相当 0: 不检查，1：检查，2：检查但是为空自动重置为0
    self.book_check = 1 -- 战书等级相符
    self.video_check = 1 -- 录像等级相符

    self.roomList = {}
    self.letterOfWarList = {}
    self.battleRoomList = {}
    self.myRoomData = nil

    self.currentSHList = {}
    self.guardId1 = 0
    self.guardId2 = 0
    self.guardId3 = 0
    self.guardId4 = 0

    self.myLogData = {} -- 我的录像

    self.battleFriendList = {}
    self.fcFriendList = {}

    self.invitationAndCreateRoomData = nil
    self.invitationAndCreateRoomType = nil
end

function CrossArenaModel:__delete()

end

function CrossArenaModel:OpenCrossArenaIcon()
    if self.crossArenaIcon == nil then
        self.crossArenaIcon = CrossArenaIcon.New(self)
    end
    self.crossArenaIcon:Show()
end

function CrossArenaModel:CloseCrossArenaIcon()
    if self.crossArenaIcon ~= nil then
        self.crossArenaIcon:DeleteMe()
        self.crossArenaIcon = nil
    end
end

function CrossArenaModel:OpenCrossArenaWindow(args)
    -- -- 在房间内时，直接打开房间面版
    -- if RoleManager.Instance.RoleData.event == RoleEumn.Event.ProvocationRoom then
    --     self:OpenCrossArenaRoomWindow()
    --     return
    -- end

    if self.crossArenaWindow == nil then
        self.crossArenaWindow = CrossArenaWindow.New(self)
    end
    self.crossArenaWindow:Open(args)
end

function CrossArenaModel:CloseCrossArenaWindow()
    if self.crossArenaWindow ~= nil then
        self.crossArenaWindow:DeleteMe()
        self.crossArenaWindow = nil
    end
end

function CrossArenaModel:OpenCrossArenaRoomListWindow(args)
    -- -- 在房间内时，直接打开房间面版
    -- if RoleManager.Instance.RoleData.event == RoleEumn.Event.ProvocationRoom then
    --     self:OpenCrossArenaRoomWindow()
    --     return
    -- end

    if self.crossArenaRoomListWindow == nil then
        self.crossArenaRoomListWindow = CrossArenaRoomListWindow.New(self)
    end
    self.crossArenaRoomListWindow:Open(args)
end

function CrossArenaModel:CloseCrossArenaRoomListWindow()
    if self.crossArenaRoomListWindow ~= nil then
        self.crossArenaRoomListWindow:DeleteMe()
        self.crossArenaRoomListWindow = nil
    end
end

function CrossArenaModel:OpenCrossArenaRoomWindow(args)
    if self.crossArenaRoomWindow == nil then
        self.crossArenaRoomWindow = CrossArenaRoomWindow.New(self)
    end
    self.crossArenaRoomWindow:Show(args)
end

function CrossArenaModel:CloseCrossArenaRoomWindow()
    if self.crossArenaRoomWindow ~= nil then
        self.crossArenaRoomWindow:DeleteMe()
        self.crossArenaRoomWindow = nil
    end
end

function CrossArenaModel:OpenCrossArenaLogWindow(args)
    if self.crossArenaLogWindow == nil then
        self.crossArenaLogWindow = CrossArenaLogWindow.New(self)
    end
    self.crossArenaLogWindow:Open(args)
end

function CrossArenaModel:CloseCrossArenaLogWindow()
    if self.crossArenaLogWindow ~= nil then
        self.crossArenaLogWindow:DeleteMe()
        self.crossArenaLogWindow = nil
    end
end

function CrossArenaModel:OpenCrossArenaCreateTeamWindow(args)
    if self.crossArenaCreateTeamWindow == nil then
        self.crossArenaCreateTeamWindow = CrossArenaCreateTeamWindow.New(self)
    end
    self.crossArenaCreateTeamWindow:Show(args)
end

function CrossArenaModel:CloseCrossArenaCreateTeamWindow()
    if self.crossArenaCreateTeamWindow ~= nil then
        self.crossArenaCreateTeamWindow:DeleteMe()
        self.crossArenaCreateTeamWindow = nil
    end
end

function CrossArenaModel:OpenCrossArenaInvitationWindow(args)
    if self.crossArenaInvitationWindow == nil then
        self.crossArenaInvitationWindow = CrossArenaInvitationWindow.New(self)
    end
    self.crossArenaInvitationWindow:Show(args)
end

function CrossArenaModel:CloseCrossArenaInvitationWindow()
    if self.crossArenaInvitationWindow ~= nil then
        self.crossArenaInvitationWindow:DeleteMe()
        self.crossArenaInvitationWindow = nil
    end
end

-- 显示战队胜利或失败
function CrossArenaModel:OpenCountInfowindow(args)
    if self.fightResult == nil then
        self.fightResult = CrossArenaCountInfo.New(self)
    end
    self.fightResult:Show(args)
end

function CrossArenaModel:CloseCountInfowindow()
    if self.fightResult ~= nil then
        self.fightResult:DeleteMe()
        self.fightResult = nil
    end
end

function CrossArenaModel:OpenCrossArenaFighterWindow(args)
    if self.crossArenaFighterWindow == nil then
        self.crossArenaFighterWindow = CrossArenaFighterWindow.New(self)
    end
    self.crossArenaFighterWindow:Show(args)
end

function CrossArenaModel:CloseCrossArenaFighterWindow()
    if self.crossArenaFighterWindow ~= nil then
        self.crossArenaFighterWindow:DeleteMe()
        self.crossArenaFighterWindow = nil
    end
end
---------------------

function CrossArenaModel:GetRoomList(type)
    local result = {}
    if type == 1 then
        for i, v in ipairs(self.roomList) do
            if v.status ~= 4 then
                table.insert(result, BaseUtils.copytab(v))
            end
        end
        return result
    elseif type == 2 then
        return self.letterOfWarList
    elseif type == 3 then
        for i, v in ipairs(self.battleRoomList) do
            if v.status == 4 then
                table.insert(result, BaseUtils.copytab(v))
            end
        end
        return result
    end
    return BaseUtils.copytab(self.roomList)
end

function CrossArenaModel:GetMyLetter()
    local roleData = RoleManager.Instance.RoleData
    for i, v in ipairs(self.battleRoomList) do
        if v.rid == roleData.id and v.platform == roleData.platform and v.zone_id == roleData.zone_id then
            return BaseUtils.copytab(v)
        end
    end
end

function CrossArenaModel:FindMyState()
    local mySide = 0
    local isTeamLeader = false
    local isRoomOwner = false
    local roleData = RoleManager.Instance.RoleData
    for side, sideData in ipairs(self.myRoomData.provocation_team) do
        for index, team_mate in ipairs(sideData.team_mate) do
            if team_mate.rid == roleData.id and team_mate.platform == roleData.platform and team_mate.zone_id == roleData.zone_id then
                mySide = side
                if team_mate.status == 1 then
                    isTeamLeader = true
                end

                -- 特殊处理，这里服务端发来的数据是错误的，客户端当列表长度为1的时候需要把自己当做是队长
                if team_mate.status == 3 and #sideData.team_mate == 1 then
                    isTeamLeader = true
                end
            end
        end
    end
    if self.myRoomData.rid == roleData.id and self.myRoomData.platform == roleData.platform and self.myRoomData.zone_id == roleData.zone_id then
        isRoomOwner = true
    end
    return mySide, isTeamLeader, isRoomOwner
end

function CrossArenaModel:GetMember(side)
    if self.myRoomData == nil then
        return nil
    end
    local result = {}
    local sideData = self.myRoomData.provocation_team[side]
    for i, v in ipairs(sideData.order) do
        for _, team_mate in ipairs(sideData.team_mate) do
            if team_mate.rid == v.rid and team_mate.platform == v.platform and team_mate.zone_id == v.zone_id then
                table.insert(result, team_mate)
            end
        end
    end
    return result
end

function CrossArenaModel:GetGuards(side)
    if self.myRoomData == nil then
        return nil
    end
    local result = {}
    local sideData = self.myRoomData.provocation_team[side]
    -- for i, v in ipairs(sideData.order) do
    --     for _, team_mate in ipairs(sideData.team_mate) do
    --         if team_mate.rid == v.rid and team_mate.platform == v.platform and team_mate.zone_id == v.zone_id then
    --             table.insert(result, team_mate)
    --         end
    --     end
    -- end
    for i = 1, 5 - #sideData.order do
        if sideData.guards[i] ~= nil and sideData.guards[i].war_id == 1 then
            table.insert(result, sideData.guards[i])
        end
    end
    return result
end

function CrossArenaModel:GetMemberNameById(rid, platform, zone_id)
    if self.myRoomData ~= nil then
        for _, sideData in ipairs(self.myRoomData.provocation_team) do
            for __, team_mate in ipairs(sideData.team_mate) do
                if team_mate.rid == rid and team_mate.platform == platform and team_mate.zone_id == zone_id then
                    return team_mate.name
                end
            end
        end
    end
    return ""
end

function CrossArenaModel:SendInvitationFriend(list)
    if self.myRoomData == nil then
        return nil
    end

    local roleData = RoleManager.Instance.RoleData
    local room_str = string.format("{crossarena_1,%s,%s,%s,%s,%s,%s}", self.myRoomData.id, TI18N("点击加入"), self.myRoomData.password, roleData.id, roleData.platform, roleData.zone_id)
    local str = string.format(TI18N("<color='#ffff00'>跨服约战邀请：</color>我已创建好房间，一起组队干翻对面 %s"), room_str)
    for i, v in ipairs(list) do
        FriendManager.Instance:SendMsg(v.id, v.platform, v.zone_id, str)
        CrossArenaManager.Instance:Send20720(v.id, v.platform, v.zone_id, 1)
    end
end

function CrossArenaModel:SendInvitation(list)
    if self.myRoomData == nil then
        return nil
    end

    local roleData = RoleManager.Instance.RoleData
    local room_str = string.format("{crossarena_2,%s,%s,%s,%s,%s,%s}", self.myRoomData.id, TI18N("点击加入"), self.myRoomData.password, roleData.id, roleData.platform, roleData.zone_id)
    local str = string.format(TI18N("<color='#ffff00'>跨服约战邀请：</color>我已创建好房间，快来大战三百回合 %s"), room_str)
    for i, v in ipairs(list) do
        FriendManager.Instance:SendMsg(v.id, v.platform, v.zone_id, str)
        CrossArenaManager.Instance:Send20720(v.id, v.platform, v.zone_id, 2)
    end
end

function CrossArenaModel:AcceptInvitation(invitationData)
    local data = NoticeConfirmData.New()
    data.type = ConfirmData.Style.Normal
    if invitationData.type == 1 then
        data.content = string.format(TI18N("<color='#23F0F7'>%sLv.%s</color>邀请您组队共赴<color='#00ff00'>跨服约战</color>，是否立即加入？"), invitationData.name, invitationData.lev)
        data.sureLabel = TI18N("立即加入")
        data.cancelLabel = TI18N("稍后再说")
        data.sureCallback = function() 
            CrossArenaManager.Instance:Send20722(invitationData.rid, invitationData.platform, invitationData.zone_id, 1, invitationData.type)
        end
    elseif invitationData.type == 2 then
        data.content = string.format(TI18N("<color='#23F0F7'>%sLv.%s</color>邀请您组队共赴<color='#00ff00'>跨服约战</color>，是否立即应战？"), invitationData.name, invitationData.lev)

        if invitationData.room_type == 0 then
            data.content = string.format(TI18N("<color='#23F0F7'>%sLv.%s</color>邀请您进行<color='#00ff00'>跨服约战（友谊赛）</color>，是否立即迎战？"), invitationData.name, invitationData.lev)
        elseif invitationData.room_type == 1 then
            data.content = string.format(TI18N("<color='#23F0F7'>%sLv.%s</color>对你发起了<color='#00ff00'>跨服约战（决斗模式）</color>，是否立即应战？"), invitationData.name, invitationData.lev)
        elseif invitationData.room_type == 2 then
            data.content = string.format(TI18N("<color='#23F0F7'>%sLv.%s</color>对你发起了<color='#00ff00'>跨服约战（决斗模式）</color>，是否立即应战？（30分钟内不应战则默认逃跑）"), invitationData.name, invitationData.lev)
        end

        data.sureLabel = TI18N("立即应战")
        data.cancelLabel = TI18N("稍后再说")
        data.sureCallback = function() 
            CrossArenaManager.Instance:Send20722(invitationData.rid, invitationData.platform, invitationData.zone_id, 1, invitationData.type)
        end
    end
    data.cancelCallback = function() NoticeManager.Instance:FloatTipsByString(TI18N("已<color='#ffff00'>暂时拒绝</color>，可通过<color='#ffff00'>私聊邀请参与</color>")) end

    NoticeManager.Instance:ConfirmTips(data)
end

function CrossArenaModel:AcceptInvitationByMessage(room_id, password, msgType, rid, platform, zone_id)
    local roleData = RoleManager.Instance.RoleData
    -- if roleData.id ~= rid or roleData.platform ~= platform or roleData.zone_id ~= zone_id then
        if msgType ~= 3 then
            CrossArenaManager.Instance:Send20722(rid, platform, zone_id, 1, msgType)
        else
            CrossArenaManager.Instance:Send20729(room_id)
        end
    -- end
end

function CrossArenaModel:InvitationAndCreateRoom(data, type)
    self.invitationAndCreateRoomData = data
    self.invitationAndCreateRoomType = type

    if self.levelLimitType == 1 then
        room_lev_min = 0
        min_lev_break = 0
        room_lev_max = 200
        max_lev_break = 1
    end

    local roomNameList = {}
    for i,v in pairs(DataCrossArena.data_room_name) do
        if v.num == 1 then
            table.insert(roomNameList, v.name)
        end
    end

    CrossArenaManager.Instance:Send20703(roomNameList[math.random(1, #roomNameList)], 1, 0, 0, 200, 1, "", 0)
end

function CrossArenaModel:PublicRecruit(type, channel)
    ChatManager.Instance.model:ShowChatWindow({channel})

    -- 改了需求暂时废弃
    -- local roleData = RoleManager.Instance.RoleData
    -- local element = {}
    -- element.type = MsgEumn.AppendElementType.CrossArena
    -- element.cross_arena_room_id = self.myRoomData.id
    -- element.cross_arena_room_name = self.myRoomData.name
    -- element.cross_arena_room_password = self.myRoomData.password
    -- element.cross_arena_room_rid = roleData.id
    -- element.cross_arena_room_platform = roleData.platform
    -- element.cross_arena_room_zone_id = roleData.zone_id
    -- element.cross_arena_msg_type = 3

    -- local sendString = TI18N("发起约战")
    -- element.showString = string.format("[%s]", TI18N("跨服约战房间邀请"))
    -- element.sendString = string.format("%s：{string_2, #248813, 『%s』}    {crossarena_3,%s,%s,%s,%s,%s,%s}", sendString, element.cross_arena_room_name, element.cross_arena_room_id, element.cross_arena_room_name, element.cross_arena_room_password, element.cross_arena_room_rid, element.cross_arena_room_platform, element.cross_arena_room_zone_id)
    -- element.matchString = string.format("%%[%s%%]", TI18N("跨服约战房间邀请"))

    -- LuaTimer.Add(500, function() 
    --     ChatManager.Instance:AppendInputElement(element, MsgEumn.ExtPanelType.Chat) 
    -- end)

    -- channel,   "频道1：世界 2：队伍 3：地图 4：工会 8：跨服世界"
    if channel == MsgEumn.ChatChannel.World then
        CrossArenaManager.Instance:Send20709(1, 1)
    elseif channel == MsgEumn.ChatChannel.Scene then
        CrossArenaManager.Instance:Send20709(3, 1)
    elseif channel == MsgEumn.ChatChannel.Guild then
        CrossArenaManager.Instance:Send20709(4, 1)
    elseif channel == MsgEumn.ChatChannel.MixWorld then
        CrossArenaManager.Instance:Send20709(8, 1)
    end    
end

function CrossArenaModel:ShowMsg(channel, rid, platform, zone_id, text, BubbleID)
    if self.crossArenaRoomWindow ~= nil then
        self.crossArenaRoomWindow:ShowMsg(channel, rid, platform, zone_id, text, BubbleID)
    end
end