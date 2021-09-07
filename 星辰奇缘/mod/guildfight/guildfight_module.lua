-- @author zgs
GuildfightModel = GuildfightModel or BaseClass(BaseModel)

function GuildfightModel:__init()
    self.gaWin = nil

    self.guildFightScorePanel = nil
    self.guildfightSetTimePanel = nil

    self.sceneListener2 = function() self:OnMapLoadedForPlantFlower() end
    self.sceneListener3 = function() self:UnitListUpdateForPlantFlower() end

    self.isNeedOpenPanel = false
    self.isShowGuildFightTeamIcon = true --是否显示公会战准备区组队图标
    self:InitHandlerTeamEvent()
end

function GuildfightModel:InitHandlerTeamEvent()
    self.CheckTeam = function ()
        self:CheckTeamVisible()
    end
    EventMgr.Instance:AddListener(event_name.team_create, self.CheckTeam)
    EventMgr.Instance:AddListener(event_name.team_leave, self.CheckTeam)
    EventMgr.Instance:AddListener(event_name.team_update, self.CheckTeam)
    EventMgr.Instance:AddListener(event_name.begin_fight, self.CheckTeam)
    EventMgr.Instance:AddListener(event_name.end_fight, self.CheckTeam)
end

function GuildfightModel:CheckTeamVisible()
    -- print(RoleManager.Instance.RoleData.event .. "#####")
    -- BaseUtils.dump(GuildFightEliteManager.Instance.eliteWarInfo)
    if RoleManager.Instance.RoleData.event == RoleEumn.Event.GuildFightReady then
        --公会战准备区
        if self.isShowGuildFightTeamIcon == true and (TeamManager.Instance:MyStatus() == RoleEumn.TeamStatus.None
            or (TeamManager.Instance:MyStatus() == RoleEumn.TeamStatus.Leader and TeamManager.Instance:MemberCount() < 5)) then
            --显示
            self:ShowGuildFightTeamWindow(true,1)
        else
            --不显示
            self:ShowGuildFightTeamWindow(false)
        end
    elseif RoleManager.Instance.RoleData.event == RoleEumn.Event.GuildEliteFight then
        --公会英雄战
        if self.isShowGuildFightTeamIcon == true and (TeamManager.Instance:MyStatus() == RoleEumn.TeamStatus.None
            or (TeamManager.Instance:MyStatus() == RoleEumn.TeamStatus.Leader and TeamManager.Instance:MemberCount() < 5)) then
            --显示
            self:ShowGuildFightTeamWindow(true,2)
        else
            --不显示
            self:ShowGuildFightTeamWindow(false)
        end
    elseif RoleManager.Instance.RoleData.event == RoleEumn.Event.GuildZone then
        --在公会领地
        if (TeamManager.Instance:MyStatus() == RoleEumn.TeamStatus.None or (TeamManager.Instance:MyStatus() == RoleEumn.TeamStatus.Leader and TeamManager.Instance:MemberCount() < 5))
            and UnitStateManager.Instance.hasRobber == true and CombatManager.Instance.isFighting == false then
            --显示
            self:ShowGuildFightTeamWindow(true,3)
        else
            --不显示
            self:ShowGuildFightTeamWindow(false)
        end
    else
        --不显示
        self:ShowGuildFightTeamWindow(false)
    end
end

function GuildfightModel:__delete()
    EventMgr.Instance:RemoveListener(event_name.team_create, self.CheckTeam)
    EventMgr.Instance:RemoveListener(event_name.team_leave, self.CheckTeam)
    EventMgr.Instance:RemoveListener(event_name.team_update, self.CheckTeam)
     EventMgr.Instance:RemoveListener(event_name.begin_fight, self.CheckTeam)
    EventMgr.Instance:RemoveListener(event_name.end_fight, self.CheckTeam)
    if self.gaWin then
        self.gaWin = nil
    end
end

function GuildfightModel:OpenWindow(args)
    if self.gaWin == nil then
        self.gaWin = GuildfightWindow.New(self)
    end
    self.gaWin:Open(args)
end

function GuildfightModel:UpdateWindow()
    if self.gaWin ~= nil then
        self.gaWin:updateWindow(self.gaWin.selectIndex)
    end
end

function GuildfightModel:CloseMain()
    WindowManager.Instance:CloseWindow(self.gaWin, true)
end

function GuildfightModel:OpenGuildFightIntegralPanel(args)
    if self.gfip == nil then
        self.gfip = GuildFightIntegralPanel.New(self)
    end
    self.gfip:Show(args)
end

function GuildfightModel:ShowGuildFightRemainEnemyPanel(bo,args)
    if bo == true then
        if self.guild_fight_remain_enemy_panel == nil then
            self.guild_fight_remain_enemy_panel = GuildfightRemainEnemyPanel.New(self)
        end
        self.guild_fight_remain_enemy_panel:Show(args)
    else
        if self.guild_fight_remain_enemy_panel ~= nil then
            self.guild_fight_remain_enemy_panel:Hiden()
        end
    end
end

function GuildfightModel:ShowGuildFightTeamWindow(bo,args)
    if bo == true then
        if self.guild_fight_team_win == nil then
            self.guild_fight_team_win = GuildfightTeamWindow.New(self)
        end
        self.guild_fight_team_win:Show(args)
    else
        if self.guild_fight_team_win ~= nil then
            -- WindowManager.Instance:CloseWindow(self.guild_fight_team_win, true)
            self.guild_fight_team_win:Hiden()
        end
    end
end

--进入公会战场景
function GuildfightModel:EnterScene()
    -- Log.Error("----------------GuildfightModel:EnterScene()------------")
    -- Log.Debug("GuildfightModel:EnterScene()"..debug.traceback())
    if self.guildFightScorePanel == nil then
        self.guildFightScorePanel = GuildfightScorePanel.New(self)
    end
    self.guildFightScorePanel:Show()

    local t = MainUIManager.Instance.MainUIIconView

    if t ~= nil then
        t:Set_ShowTop(false, {17})
    end
    -- if RoleManager.Instance.RoleData.lev <= RoleManager.Instance.world_lev - 20 then
    --     NoticeManager.Instance:FloatTipsByString("由于你的等级低于世界等级20级以上，行动力减少为100。")
    -- elseif RoleManager.Instance.RoleData.lev <= RoleManager.Instance.world_lev - 15 then
    --     NoticeManager.Instance:FloatTipsByString("由于你的等级低于世界等级15级以上，行动力减少为300。")
    -- elseif RoleManager.Instance.RoleData.lev <= RoleManager.Instance.world_lev - 10 then
    --     NoticeManager.Instance:FloatTipsByString("由于你的等级低于世界等级10级以上，行动力减少为400。")
    -- elseif RoleManager.Instance.RoleData.lev <= RoleManager.Instance.world_lev - 5 then
    --     NoticeManager.Instance:FloatTipsByString("由于你的等级低于世界等级5级以上，行动力减少为600。")
    -- end
end
--退出公会战场景
function GuildfightModel:ExitScene()
    if self.guildFightScorePanel ~= nil then
        -- Log.Debug("GuildfightModel:EnterScene()"..debug.traceback())
        self.guildFightScorePanel:Hiden()
        self.guildFightScorePanel:DeleteMe()
        self.guildFightScorePanel = nil

        local t = MainUIManager.Instance.MainUIIconView

        if t ~= nil then
            t:Set_ShowTop(true, {})
        end
    end
end

function GuildfightModel:OnMapLoadedForPlantFlower()
    EventMgr.Instance:RemoveListener(event_name.scene_load, self.sceneListener2)
    self:ReachAreaThenGoToTarge()
end

function GuildfightModel:UnitListUpdateForPlantFlower()
    EventMgr.Instance:RemoveListener(event_name.npc_list_update, self.sceneListener3)
    self:ReachAreaThenGoToTarge()
end

function GuildfightModel:GoToGuildArea()
    if SceneManager.Instance:CurrentMapId() == 30001 then
        self:ReachAreaThenGoToTarge()
    else
        EventMgr.Instance:AddListener(event_name.scene_load, self.sceneListener2)
        EventMgr.Instance:AddListener(event_name.npc_list_update, self.sceneListener3)
        QuestManager.Instance:Send(11128, {})
    end
end

function GuildfightModel:ReachAreaThenGoToTarge()
    local dataList = SceneManager.Instance.sceneElementsModel:GetSceneData_Npc()
    -- BaseUtils.dump(dataList,"GuildfightModel:ReachAreaThenGoToTarge()")
    for i,v in ipairs(dataList) do
        if v.baseid == 79713 or v.baseid == 79722 then
            SceneManager.Instance.sceneElementsModel:Self_Change_Top_Effect(1)
            SceneManager.Instance.sceneElementsModel:Self_CancelAutoPath()
            local pos = SceneManager.Instance.sceneModel:transport_small_pos(v.x, v.y)
            SceneManager.Instance.sceneElementsModel:Self_MoveToPoint(pos.x,pos.y)
            local key = BaseUtils.get_unique_npcid(v.id, v.battleid)
            SceneManager.Instance.sceneElementsModel.target_uniqueid = key
            -- Log.Error(key.."===========GuildfightModel:ReachAreaThenGoToTarge()========="..pos.x..","..pos.y)
            -- SceneManager.Instance.sceneElementsModel:Self_MoveToTarget(key)
            break
        end
    end
end

function GuildfightModel:Send11177ForInfo()
    self.isNeedOpenPanel = true
    GuildManager.Instance:request11177()
end

function GuildfightModel:OpenGuildFightSetTimePanelFrom11177()
    if self.isNeedOpenPanel == true then
        self.isNeedOpenPanel = false
        if GuildManager.Instance.model.guildTreasure.can_open == 0 then
            if GuildManager.Instance.model.guildTreasure.setting_chance <=0 then
                NoticeManager.Instance:FloatTipsByString(TI18N("设定次数已用完"))
                return
            end
            if self.guildfightSetTimePanel == nil then
                self.guildfightSetTimePanel = GuildfightSetTimePanel.New(self)
            end
            self.guildfightSetTimePanel:Show()
        elseif GuildManager.Instance.model.guildTreasure.can_open == 1 then
            GuildManager.Instance:request11179()
        end
    end
end

-- function GuildfightModel:CloseGuildFightSetTimePanel()
--     if self.guildfightSetTimePanel ~= nil then
--         self.guildfightSetTimePanel:Hide()
--     end
-- end
