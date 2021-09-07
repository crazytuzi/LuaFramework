AgendaModel = AgendaModel or BaseClass(BaseModel)

function AgendaModel:__init()
    self.win = nil
    self.weekRewardPanel = nil
    self.currTab = nil
    self.agendaMgr = AgendaManager.Instance
    self.autoPathFight = false
end

function AgendaModel:OpenWindow(tab)
    if self.win == nil then
        self.win = AgendaWindow.New(self)
    end

    self.currTab = tab
    self.win:Open(self.currTab)
    self.agendaMgr:Require12004()
end

function AgendaModel:CloseWin()
    if self.win ~= nil then
        WindowManager.Instance:CloseWindow(self.win)
    end
end

function AgendaModel:OpenWeekRewardPanel(args)
    if self.weekRewardPanel == nil then
        self.weekRewardPanel = AgendaWeekRewardPanel.New(self)
    end

    self.weekRewardPanel:Show(args)
end

function AgendaModel:CloseWeekRewardPanel()
    if self.weekRewardPanel ~= nil then
        self.weekRewardPanel:OnHide()
        self.weekRewardPanel:DeleteMe()
        self.weekRewardPanel = nil
    end
end

function AgendaModel:ChangeTab(tab)
    self.currTab = tab
    self.win:OnTabChange(tab)
end

function AgendaModel:SetReward(data)
    if self.win ~= nil then
        self.win:SetRewardData(data)
    end
end

function AgendaModel:SetPoint()
    if self.win ~= nil then
        self.win:SetDoublePoint()
    end
end

function AgendaModel:SetDungeonStatus(data)
    if self.win ~= nil then
        self.win:SetDungeonTips(data)
    end
end

function AgendaModel:SetConstellationArea(data)
    if self.win ~= nil then
        self.win:SetConstellationArea(data)
    end
end

function AgendaModel:GetButtonByID(id)
    if self.win ~= nil then
        self.win:GetStartBtnByID(id)
    end
end

function AgendaModel:UpdateTimes()
    if self.win ~= nil then
        -- self.win:GetStartBtnByID(id)
        self.win:RefreshCurrPage()
    end
end

-- 日程特殊处理
function AgendaModel:SpecialDaily(id)
    if id == 1000 then
        -- 悬赏任务
        QuestManager.Instance.model:DoOffer()
        self:CloseWin()
        return true
    elseif id == 1001 then
        -- 职业任务特殊处理
        QuestManager.Instance.model:DoCycle()
        self:CloseWin()
        return true
    elseif id == 1004 or id == 1022  then
        DungeonManager.Instance:EnterTower(1)
        self:CloseWin()
        return true
    elseif id == 1008 then
        ParadeManager.Instance:EatCheckIn()
        self:CloseWin()
        return true
    elseif id == 1009 and ShippingManager.Instance.status ~= 3 and ShippingManager.Instance.status ~= 4 then
            -- 远航商人特殊处理
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.shippingwindow)
        self:CloseWin()
        return true
    elseif id == 1009 and (ShippingManager.Instance.status == 4 or RoleManager.Instance.RoleData.status ~= RoleEumn.Status.Normal or TeamManager.Instance:MyStatus() == RoleEumn.TeamStatus.Follow or RoleManager.Instance.RoleData.event ~= RoleEumn.Event.None) then
            -- 远航商人特殊处理
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.shipwindow)
        -- self:CloseWin()
        return true
    elseif id == 1011 then
        -- 宝图任务
        QuestManager.Instance.model:DoTreasuremap()
        self:CloseWin()
        return true
    elseif id == 1012 or id == 2003 or id == 2004 then
            -- 公会活动特殊处理
        print("公会盗贼特殊处理")
        self:CloseWin()
        Connection.Instance:send(11128, {})
        return true
    elseif id == 1013 then
            -- 公会活动特殊处理
        print("公会活动特殊处理")
        QuestManager.Instance.model:DoGuild()
        self:CloseWin()
        return true
    elseif id == 1014 then
        -- if RoleManager.Instance:CheckCross() then
        --     return
        -- end

        local cmp = 9999
        local map_id = -1
        for k,v in ipairs(DataTreasure.data_map) do
            if map_id == -1 and RoleManager.Instance.RoleData.lev >= v.min_lev and RoleManager.Instance.RoleData.lev <= v.max_lev then
                map_id = v.map_base_id
            end
        end
        local option = 31
        if RoleManager.Instance.RoleData.lev >100 then
            option = 39
        elseif RoleManager.Instance.RoleData.lev >94 then
            option = 38
        elseif RoleManager.Instance.RoleData.lev >84 then
            option = 37
        elseif RoleManager.Instance.RoleData.lev > 74 then
            option = 36
        elseif RoleManager.Instance.RoleData.lev > 64 then
            option = 35
        elseif RoleManager.Instance.RoleData.lev > 54 then
            option = 34
        elseif RoleManager.Instance.RoleData.lev > 44 then
            option = 33
        elseif RoleManager.Instance.RoleData.lev > 34 then
            option = 32
        elseif RoleManager.Instance.RoleData.lev > 24 then
            option = 31
        end
        local first = DataTeam.data_match[option].tab_id
        local second = DataTeam.data_match[option].id
        if map_id ~= -1 then
            local leader = function()
                TeamManager.Instance.TypeOptions = {}
                TeamManager.Instance.TypeOptions[first] = second
                TeamManager.Instance.LevelOption = 1
                TeamManager.Instance:Send11701()
                LuaTimer.Add(200, function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.team, {1}) end)
            end
            local member = function()
                TeamManager.Instance.TypeOptions = {}
                TeamManager.Instance.TypeOptions[first] = second
                TeamManager.Instance.LevelOption = 1
                WindowManager.Instance:OpenWindowById(WindowConfig.WinID.team, {1})
            end
            if not TeamManager.Instance:HasTeam() then
                local info = {
                    Desc = TI18N("上古妖魔在场景中<color='#ffff00'>随机出现</color>，可在四周找找看{face_1,16}"),
                    Ltxt = TI18N("我要当队长"),
                    Mtxt = "",
                    Rtxt = TI18N("我要当队员"),
                    LGreen = true,
                    MGreen = false,
                    RGreen = false,
                    LCallback = leader,
                    MCallback = nil,
                    RCallback = member,
                }
                LuaTimer.Add(800, function()
                    TipsManager.Instance:ShowTeamUp(info)
                end)
            elseif TeamManager.Instance.teamNumber < 5 then
                local info = {
                    Desc = TI18N("上古妖魔在场景中<color='#ffff00'>随机出现</color>，可在四周找找看{face_1,16}"),
                    Ltxt = "",
                    Mtxt = TI18N("招募队员"),
                    Rtxt = "",
                    LGreen = false,
                    MGreen = true,
                    RGreen = false,
                    LCallback = nil,
                    MCallback = member,
                    RCallback = nil,
                }
                LuaTimer.Add(800, function()
                    TipsManager.Instance:ShowTeamUp(info)
                end)
            end
            SceneManager.Instance.sceneElementsModel:Self_CancelAutoPath()
            -- SceneManager.Instance.sceneElementsModel:Self_Change_Top_Effect(1)
            self.autoPathFight = true
            SceneManager.Instance.sceneElementsModel:Self_Transport(map_id, 0, 0)
        end
        self:CloseWin()
        return true
    elseif id == 1018 then
        -- 伴侣任务特殊处理
        QuestManager.Instance.model:DoCouple()
        self:CloseWin()
        return true
    elseif id == 1021 then
        print("传送到42000")
        SceneManager.Instance.sceneElementsModel:Self_Transport(42000, 0, 0)
        self:CloseWin()
        return true
    elseif id == 1099 then
        local data = nil
        for i,v in ipairs(self.agendaMgr.day_list) do
            if v.id == 1099 then
                data = v
            end
        end
        self.win:ShowTips(1, data)
        return true
    elseif id == 2005 then
        ClassesChallengeManager.Instance.model:ClassesCheckIn()
        self:CloseWin()
        return true
    elseif id == 2006 then
        --彩虹冒险
        if RoleManager.Instance.RoleData.cross_type == 1 then
            -- 如果处在中央服，先回到本服在参加活动
            local confirmData = NoticeConfirmData.New()
            confirmData.type = ConfirmData.Style.Normal
            confirmData.sureSecond = -1
            confirmData.cancelSecond = 180
            confirmData.sureLabel = TI18N("确认")
            confirmData.cancelLabel = TI18N("取消")
            RoleManager.Instance.jump_over_call = function()
                FairyLandManager.Instance:request14601()
            end
            confirmData.sureCallback = SceneManager.Instance.quitCenter
            confirmData.content = string.format("<color='#ffff00'>%s</color>%s", TI18N("智慧闯关半决赛"), TI18N("活动已开启，是否<color='#ffff00'>返回原服</color>参加？"))
            NoticeManager.Instance:ConfirmTips(confirmData)
        else
            FairyLandManager.Instance:request14601()
        end
        return true
    elseif id == 2007 then
        WindowManager.Instance:CloseWindowById(WindowConfig.WinID.agendamain)
        ExamManager.Instance:request14501(79843)
        return true
    elseif id == 2008 then
        if RoleManager.Instance.RoleData.cross_type == 1 then
            -- 如果处在中央服，先回到本服在参加活动
            local confirmData = NoticeConfirmData.New()
            confirmData.type = ConfirmData.Style.Normal
            confirmData.sureSecond = -1
            confirmData.cancelSecond = 180
            confirmData.sureLabel = TI18N("确认")
            confirmData.cancelLabel = TI18N("取消")
            RoleManager.Instance.jump_over_call = function()
                WindowManager.Instance:CloseWindowById(WindowConfig.WinID.agendamain)
                local npc_data = ExamManager.Instance.model:get_npc_data_by_date()
                local id_battle_id = BaseUtils.get_unique_npcid(npc_data[1], 12)
                SceneManager.Instance.sceneElementsModel:Self_CancelAutoPath()
                SceneManager.Instance.sceneElementsModel:Self_Change_Top_Effect(1)
                SceneManager.Instance.sceneElementsModel:Self_AutoPath(npc_data[2], id_battle_id)
            end
            confirmData.sureCallback = SceneManager.Instance.quitCenter
            confirmData.content = string.format("<color='#ffff00'>%s</color>%s", TI18N("智慧闯关半决赛"), TI18N("活动已开启，是否<color='#ffff00'>返回原服</color>参加？"))
            NoticeManager.Instance:ConfirmTips(confirmData)
        else
            WindowManager.Instance:CloseWindowById(WindowConfig.WinID.agendamain)
            local npc_data = ExamManager.Instance.model:get_npc_data_by_date()
            local id_battle_id = BaseUtils.get_unique_npcid(npc_data[1], 12)
            SceneManager.Instance.sceneElementsModel:Self_CancelAutoPath()
            SceneManager.Instance.sceneElementsModel:Self_Change_Top_Effect(1)
            SceneManager.Instance.sceneElementsModel:Self_AutoPath(npc_data[2], id_battle_id)
        end
        return true
    elseif id == 2009 then
        if RoleManager.Instance.RoleData.cross_type == 1 then
            -- 如果处在中央服，先回到本服在参加活动
            local confirmData = NoticeConfirmData.New()
            confirmData.type = ConfirmData.Style.Normal
            confirmData.sureSecond = -1
            confirmData.cancelSecond = 180
            confirmData.sureLabel = TI18N("确认")
            confirmData.cancelLabel = TI18N("取消")
            RoleManager.Instance.jump_over_call = function()
                local npc_data = ExamManager.Instance.model:get_npc_data_by_date()
                local id_battle_id = BaseUtils.get_unique_npcid(npc_data[1], 12)
                SceneManager.Instance.sceneElementsModel:Self_CancelAutoPath()
                SceneManager.Instance.sceneElementsModel:Self_Change_Top_Effect(1)
                SceneManager.Instance.sceneElementsModel:Self_AutoPath(npc_data[2], id_battle_id)
            end
            confirmData.sureCallback = SceneManager.Instance.quitCenter
            confirmData.content = string.format("<color='#ffff00'>%s</color>%s", TI18N("智慧闯关决赛"), TI18N("活动已开启，是否<color='#ffff00'>返回原服</color>参加？"))
            NoticeManager.Instance:ConfirmTips(confirmData)
        else
            local npc_data = ExamManager.Instance.model:get_npc_data_by_date()
            local id_battle_id = BaseUtils.get_unique_npcid(npc_data[1], 12)
            SceneManager.Instance.sceneElementsModel:Self_CancelAutoPath()
            SceneManager.Instance.sceneElementsModel:Self_Change_Top_Effect(1)
            SceneManager.Instance.sceneElementsModel:Self_AutoPath(npc_data[2], id_battle_id)
        end
    elseif id == 2010 then
        WarriorManager.Instance:CheckIn()
        self:CloseWin()
        return true
    elseif id == 2019 then
        HeroManager.Instance:HeroCheckIn()
        self:CloseWin()
        return true
    elseif id == 2020 then
        GuildFightEliteManager.Instance:GuildFightEliteCheckIn()
        self:CloseWin()
        return true
    elseif id == 2014 then
        TopCompeteManager.Instance:TopCheckIn()
        self:CloseWin()
        return true
    elseif (id == 2011 or id == 2017) and RoleManager.Instance.RoleData.cross_type == 1 then
        local confirmData = NoticeConfirmData.New()
        confirmData.type = ConfirmData.Style.Normal
        confirmData.sureSecond = -1
        confirmData.cancelSecond = 180
        confirmData.sureLabel = TI18N("返回原服")
        confirmData.cancelLabel = TI18N("取消")
        RoleManager.Instance.jump_over_call = function()
            local id_battle_id = DataAgenda.data_list[id].npc_id
            SceneManager.Instance.sceneElementsModel:Self_CancelAutoPath()
            SceneManager.Instance.sceneElementsModel:Self_Change_Top_Effect(1)
            SceneManager.Instance.sceneElementsModel:Self_PathToTarget(id_battle_id)
        end
        confirmData.sureCallback = SceneManager.Instance.quitCenter
        confirmData.content = string.format("<color='#ffff00'>%s</color>%s", TI18N("六一活动"), TI18N("是否<color='#ffff00'>返回原服</color>参加本活动？"))
        NoticeManager.Instance:ConfirmTips(confirmData)
        return true
    elseif (id == 2036 or id == 2037) and (GuildManager.Instance.model.my_guild_data == nil or GuildManager.Instance.model.my_guild_data.GuildId == 0) then
        print(GuildManager.Instance.model.my_guild_data.GuildId)
        NoticeManager.Instance:FloatTipsByString(TI18N("请先加入一个公会"))
        return true
    elseif id == 2047 then
        MatchManager.Instance:Require18301(1000)
        return true
    elseif id == 2048 then
        UnlimitedChallengeManager.Instance:Require17201()
        return true
    -- elseif id == 1028 and RoleManager.Instance.RoleData.cross_type == 1 then
        -- local confirmData = NoticeConfirmData.New()
        -- confirmData.type = ConfirmData.Style.Normal
        -- confirmData.sureSecond = -1
        -- confirmData.cancelSecond = 180
        -- confirmData.sureLabel = TI18N("返回原服")
        -- confirmData.cancelLabel = TI18N("取消")
        -- RoleManager.Instance.jump_over_call = function()
        --     local id_panel_id = DataAgenda.data_list[id].panel_id
        --     WindowManager.Instance:OpenWindowById(id_panel_id)
        -- end
        -- confirmData.sureCallback = SceneManager.Instance.quitCenter
        -- confirmData.content = string.format("<color='#ffff00'>%s</color>%s", TI18N("挑战副本"), TI18N("是否<color='#ffff00'>返回原服</color>参加本活动？"))
        -- NoticeManager.Instance:ConfirmTips(confirmData)
        -- return true
    elseif id == 1030 then
        -- 公会副本特殊处理
        GuildDungeonManager.Instance.model:OpenWindow(args)
        self:CloseWin()
        return true
    elseif id == 2057 or id == 2058 or id == 2059 or id == 2060 then
        --龙王试炼
        StarChallengeManager.Instance.model:EnterScene()
        self:CloseWin()
        return true
    elseif id == 2061 or id == 2062 then
        ExquisiteShelfManager.Instance:EnterReady()
        self:CloseWin()
        return true
    elseif id == 2065 then
        -- 公会魔龙挑战
        GuildDragonManager.Instance:Enter()
        self:CloseWin()
        return true
    elseif id == 2068 then
        --诸神膜拜
        GodsWarWorShipManager.Instance:GodsWarWorShipEnter()
        self:CloseWin()
        return true
    elseif id == 2072 then
        --银月贤者
        NoticeManager.Instance:FloatTipsByString("银月贤者就在某个地方，快去拜访他们吧{face_1,25}")
        --NoticeManager.Instance:FloatTipsByString("稍候开放，敬请期待")
        return true
    elseif id == 2073 or id == 2074 or id == 2075 or id == 2076 then
        --天启试炼
        ApocalypseLordManager.Instance.model:EnterScene()
        self:CloseWin()
        return true
    elseif id == 2106 then
        if RoleManager.Instance.RoleData.event == RoleEumn.Event.CanYon or RoleManager.Instance.RoleData.event == RoleEumn.Event.CanYonReady then
            local npcBase = DataUnit.data_unit[20060]
            npcBase.buttons = {}
            npcBase.plot_talk = TI18N("已经在活动中")
            MainUIManager.Instance:OpenDialog({baseid = npcBase.id, name = npcBase.name}, {base = npcBase}, true, true)
        else
            CanYonManager.Instance:Send21101()
        end
        self:CloseWin()
        return true
    elseif id == 2082 then
        --星月灵兽
        NoticeManager.Instance:FloatTipsByString("幻月灵兽就在某个地方，快去拜访他们吧{face_1,25}")
        return true
    elseif id == 2110 then
        --真心话大冒险
        NoticeManager.Instance:FloatTipsByString("活动时间，可在<color='#ffff00'>公会频道</color>直接参与哦~")
        return true
    end
    
    return false
end

function AgendaModel:DoDaily(id)
    local data = DataAgenda.data_list[id]
    if self:SpecialDaily(data.id) then
        return
    end
    if data.panel_id~=0 then
        self:CloseWin()
        WindowManager.Instance:OpenWindowById(data.panel_id)
    elseif data.npc_id~=0 then
        local uid = string.format("%s_1", tostring(data.npc_id))
        self:CloseWin()
        SceneManager.Instance.sceneElementsModel:Self_CancelAutoPath()
        SceneManager.Instance.sceneElementsModel:Self_Change_Top_Effect(1)
        SceneManager.Instance.sceneElementsModel:Self_PathToTarget(uid)
    end
end
