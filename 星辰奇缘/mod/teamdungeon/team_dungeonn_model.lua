-- 组队副本 model
-- ljh 20170205
TeamDungeonModel = TeamDungeonModel or BaseClass(BaseModel)

function TeamDungeonModel:__init()
    self.window = nil
    self.rewardWindow = nil
    self.teamDungeonIcon = nil
    
    self:InitData()
    EventMgr.Instance:AddListener(event_name.role_event_change, function(event, old_event) self:UpdateEvent(event, old_event) end)
end

function TeamDungeonModel:InitData()
    self.recruitIndex = 1

    self.dun_id = 0
    self.dungeon_team = nil
    self.dungeon_enlistment = {}
    self.status = 0
    self.quickJionMark = false

    self.pass_list = {} -- 副本通关
    self.rewards_list = {} -- 副本预计奖励
    self.passTimes = 0

    self.recruitFreezeIndexTime = nil

    self.DataTeamDungeon = {}
    for _, value in pairs(DataDungeon.data_get) do
        if value.team_dungeon == 1 then
            local data = BaseUtils.copytab(value)
            for __, value2 in ipairs(data.cond_enter) do
                if value2.label == "lev" then
                    if value2.op == "ge" then
                        data.lev_min = value2.val[1]
                    -- elseif value2.op == "le" then
                    --     data.lev_max = value2.val[1]
                    end
                end
            end
            table.insert(self.DataTeamDungeon, data)
        end
    end
    local function sortfun(a,b)
        return a.id < b.id
    end

    table.sort(self.DataTeamDungeon, sortfun)
end

function TeamDungeonModel:__delete()
    if self.window ~= nil then
        self.window:DeleteMe()
        self.window = nil
    end
end

function TeamDungeonModel:OpenTeamDungeonWindowByHand(args)
    if TeamManager.Instance:MyStatus() ~= RoleEumn.TeamStatus.None and TeamManager.Instance:MyStatus() ~= RoleEumn.TeamStatus.Leader then
        NoticeManager.Instance:FloatTipsByString(TI18N("只有队长或单人才能进入副本大厅"))
        return
    end
    self:OpenTeamDungeonWindow(args)
end

function TeamDungeonModel:OpenTeamDungeonWindow(args)
    if RoleManager.Instance.RoleData.event ~= RoleEumn.Event.None and RoleManager.Instance.RoleData.event ~= RoleEumn.Event.TeamDungeon_Recruit_Matching then
        NoticeManager.Instance:FloatTipsByString(TI18N("当前状态无法进入副本大厅"))
        return
    end

    local lev, name = self:GetTeamLev()
    if lev < 35 then
        NoticeManager.Instance:FloatTipsByString(string.format(TI18N("%s等级不足35级，无法进入副本大厅"), name))
        return
    end

    self:JustDoItOpenTeamDungeonWindow(args)
    -- self:ShowTeamDungeonIcon()
end

function TeamDungeonModel:JustDoItOpenTeamDungeonWindow(args)
    -- print("JustDoItOpenTeamDungeonWindow")
    -- print(debug.traceback())
    if self.window == nil then
        self.window = TeamDungeonWindow.New(self)
    end
    self.window:Show(args)
    TreasureMazeManager.Instance.model:CloseMazeWindow()
end

function TeamDungeonModel:CloseTeamDungeonWindow()
    if self.window ~= nil then
        self.window:DeleteMe()
        self.window = nil
    end
    -- self:HideTeamDungeonIcon()
end

function TeamDungeonModel:OpenTeamDungeonRewardWindow(args)
    if self.rewardWindow == nil then
        self.rewardWindow = TeamDungeonRewardWindow.New(self)
    end
    self.rewardWindow:Show(args)
end

function TeamDungeonModel:CloseTeamDungeonRewardWindow()
    if self.rewardWindow ~= nil then
        self.rewardWindow:DeleteMe()
        self.rewardWindow = nil
    end
end

function TeamDungeonModel:ShowTeamDungeonIcon()
    if self.teamDungeonIcon == nil then
        self.teamDungeonIcon = TeamDungeonIcon.New(self)
    end
    self.teamDungeonIcon:Show()
end

function TeamDungeonModel:HideTeamDungeonIcon()
    if self.teamDungeonIcon ~= nil then
        self.teamDungeonIcon:Hide()
    end
end

function TeamDungeonModel:Recruit(data)
    if data.type == 1 then
        local str = string.format(TI18N("%s副本马上开车，快上车{face_1, 16}{face_1, 16}"), "某某副本")
        local msgData = MessageParser.GetMsgData(str)
        local chatData = ChatData.New()
        chatData:Update(data)
        chatData.showType = MsgEumn.ChatShowType.TeamDungeon
        chatData.id = chatData.rid
        chatData.msgData = msgData
        chatData.channel = MsgEumn.ChatChannel.Private
        chatData.prefix = MsgEumn.ChatChannel.Private
        ChatManager.Instance.model:ShowMsg(chatData)
    else
        local str = string.format(TI18N("%s副本马上开车，快上车{face_1, 16}{face_1, 16}"), "某某副本")
        local btnOffestY = 0
        local msgData = MsgData.New()
        msgData.sourceString = str
        msgData.showString = str
        NoticeManager.Instance.model.calculator:ChangeFoneSize(17)
        local allWidth = NoticeManager.Instance.model.calculator:SimpleGetWidth(msgData.sourceString)
        msgData.allWidth = allWidth
        local chatData = ChatData.New()
        chatData.showType = MsgEumn.ChatShowType.TeamDungeon
        chatData.msgData = msgData
        data.id = self.recruitIndex
        self.recruitIndex = self.recruitIndex + 1
        data.btnOffestY = btnOffestY
        chatData.extraData = data
        chatData.prefix = MsgEumn.ChatChannel.Guild
        chatData.channel = MsgEumn.ChatChannel.Guild
        -- self.chatShowMatchTab[data.id] = chatData

        ChatManager.Instance.model:ShowMsg(chatData)
    end
end

function TeamDungeonModel:UpdateEvent(event, old_event)
    if event == RoleEumn.Event.TeamDungeon_Recruit_Matching and old_event ~= RoleEumn.Event.TeamDungeon_Recruit_Matching then
        if self.window == nil then
            self:OpenTeamDungeonWindow()
        end
    end

    if event == RoleEumn.Event.TeamDungeon_Recruit_Matching then
        self:ShowTeamDungeonIcon()
    else
        self:HideTeamDungeonIcon()
    end
end

function TeamDungeonModel:GetTeamLev()
    local lev = RoleManager.Instance.RoleData.lev
    local name = RoleManager.Instance.RoleData.name
    if self.dungeon_team ~= nil then
        for key, value in pairs(self.dungeon_team.dungeon_mate) do
            if lev > value.lev then
                lev = value.lev
                name = value.name
            end
        end
    end
    if TeamManager.Instance:MyStatus() == RoleEumn.TeamStatus.Leader then
        for key, value in pairs(TeamManager.Instance.memberTab) do
            if lev > value.lev then
                lev = value.lev
                name = value.name
            end
        end
    end

    return lev, name
end

function TeamDungeonModel:ShowMsg(rid, platform, zone_id, text, BubbleID)
    if self.window ~= nil then
        self.window:ShowMsg(rid, platform, zone_id, text, BubbleID)
    end
end