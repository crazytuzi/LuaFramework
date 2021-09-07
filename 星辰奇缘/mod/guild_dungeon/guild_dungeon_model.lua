-- 公会副本 model
-- ljh 20170301
GuildDungeonModel = GuildDungeonModel or BaseClass(BaseModel)

function GuildDungeonModel:__init()
    self.window = nil
    self.bossWindow = nil
    self.soldierWindow = nil
    self.heroRankWindow = nil
    self.title = nil
    self.settlementWindow = nil

    self:InitData()

    self._scene_load = function(mapid) self:scene_load(mapid) end
    EventMgr.Instance:AddListener(event_name.scene_load, self._scene_load)

    EventMgr.Instance:AddListener(event_name.role_event_change, function(event, old_event) self:UpdateEvent(event, old_event) end)

    -- self._EndFight = function() self:EndFight() end
end

function GuildDungeonModel:InitData()
    self.guild_dungeon_chapter = {}
    self.heroRankData = {}
    self.rankData = {}
    self.guildDungeonMapData = {}
    self.timerId = nil
    self.bossMapData = {}
    self.bossData = {}
    self.fight_timerId = nil
    self.fightMapData = {}
    self.fightData = {}

    for index, data_unit in pairs(DataGuildDungeon.data_unit) do
        if data_unit.map_id ~= nil and data_unit.map_id ~= 0 then
            self.guildDungeonMapData[data_unit.map_id] = { chapter_id = data_unit.chapter_id, strongpoint_id = data_unit.strongpoint_id, monster_id = data_unit.id, unique = data_unit.unique, head_type = data_unit.head_type, head_id = data_unit.head_id, name = DataUnit.data_unit[data_unit.id].name, exp_id = data_unit.exp_id, exp_ratio = data_unit.exp_ratio }
        end
    end

    self.colorList = {
        Color(218/255, 72/255, 72/255),
        Color(159/255, 55/255, 231/255),
        Color(103/255, 81/255, 207/255),
        Color(198/255, 248/255, 254/255)
    }
end

function GuildDungeonModel:__delete()
    if self.window ~= nil then
        self.window:DeleteMe()
        self.window = nil
    end
end

function GuildDungeonModel:OpenWindow(args)
    if not GuildManager.Instance.model:has_guild() then
        NoticeManager.Instance:FloatTipsByString(TI18N("当前你没加入公会，请加入公会再尝试"))
        return
    end
    if RoleManager.Instance.world_lev < 65 then
        NoticeManager.Instance:FloatTipsByString(TI18N("世界等级65级及以上时，才可挑战英雄副本哦"))
        return
    end
    if self.window == nil then
        self.window = GuildDungeonWindow.New(self)
    end
    self.window:Open(args)
end

function GuildDungeonModel:CloseWindow()
    if self.window ~= nil then
        self.window:DeleteMe()
        self.window = nil
    end
end

function GuildDungeonModel:OpenBossWindow(args)
    if self.bossWindow == nil then
        self.bossWindow = GuildDungeonBossWindow.New(self)
    end
    self.bossWindow:Open(args)
end

function GuildDungeonModel:CloseBossWindow()
    if self.bossWindow ~= nil then
        self.bossWindow:DeleteMe()
        self.bossWindow = nil
    end
end

function GuildDungeonModel:OpenSoldierWindow(args)
    if self.soldierWindow == nil then
        self.soldierWindow = GuildDungeonSoldierWindow.New(self)
    end
    self.soldierWindow:Open(args)
end

function GuildDungeonModel:CloseSoldierWindow()
    if self.soldierWindow ~= nil then
        self.soldierWindow:DeleteMe()
        self.soldierWindow = nil
    end
end

function GuildDungeonModel:OpenHeroRankWindow(args)
    if self.heroRankWindow == nil then
        self.heroRankWindow = GuildDungeonHeroRankWindow.New(self)
    end
    self.heroRankWindow:Open(args)
end

function GuildDungeonModel:CloseHeroRankWindow()
    if self.heroRankWindow ~= nil then
        self.heroRankWindow:DeleteMe()
        self.heroRankWindow = nil
    end
end

function GuildDungeonModel:OpenGuildDungeonSettlementWindow(args)
    if self.settlementWindow == nil then
        self.settlementWindow = GuildDungeonSettlementWindow.New(self)
    end
    self.settlementWindow:Show(args)
end

function GuildDungeonModel:CloseGuildDungeonSettlementWindow()
    if self.settlementWindow ~= nil then
        self.settlementWindow:DeleteMe()
        self.settlementWindow = nil
    end
end

function GuildDungeonModel:ShowTitle()
    if self.title == nil then
        self.title = GuildDungeonBossTitle.New(self)
    end
    self.title:Show()
end

function GuildDungeonModel:HideTitle()
    if self.title ~= nil then
        self.title:Hide()
    end
end

function GuildDungeonModel:DeleteTitle()
    if self.title ~= nil then
        self.title:DeleteMe()
        self.title = nil
    end
end


function GuildDungeonModel:On19500(data)
    self.chapter_now = data.chapter_now
    self.guild_dungeon_chapter = data
    
    self:ProcessingData()
    GuildDungeonManager.Instance.OnUpdate:Fire()

    AgendaManager.Instance:SetCurrLimitID(1030, self.guild_dungeon_chapter.times > 0 and self.guild_dungeon_chapter.boss_times > 0 and RoleManager.Instance.world_lev >= 65)

    if RoleManager.Instance.RoleData.event == RoleEumn.Event.GuildDungeonBattle then
        self.fightMapData = self:FindMyFightMapData()
        BaseUtils.dump(self.fightMapData, "self.fightMapData")
        self:MainuiTrace()
    end
end

function GuildDungeonModel:On19502(data)
    -- BaseUtils.dump(data, "On19502")
    if data.chapter_id == 0 and data.strongpoint_id == 0 then
        self.heroRankData = data.ranks
        GuildDungeonManager.Instance.OnUpdateRank:Fire()
    else
        self.rankData[string.format("%s_%s", data.chapter_id, data.strongpoint_id)] = data.ranks
        GuildDungeonManager.Instance.OnUpdateRank:Fire()
    end
end

-- 处理数据
function GuildDungeonModel:ProcessingData()
    -- self.guild_dungeon_chapter = {
    --     [1] = { chapter_id = 1, status = 0, strongpoints = {
    --             { strongpoint_id = 1, monsters = { {monster_id = 51100, percent = 800, challenge = 1}, {monster_id = 51105, percent = 800, challenge = 1}, {monster_id = 51109, percent = 800, challenge = 1} } } 
    --             ,{ strongpoint_id = 2, monsters = { {monster_id = 51100, percent = 800, challenge = 1}, {monster_id = 51105, percent = 800, challenge = 1}, {monster_id = 51109, percent = 800, challenge = 1} } } 
    --             ,{ strongpoint_id = 3, monsters = { {monster_id = 51100, percent = 800, challenge = 1}, {monster_id = 51105, percent = 800, challenge = 1}, {monster_id = 51109, percent = 800, challenge = 1} } } 
    --         }
    --     }
    -- }

    for chapterDataIndex, chapterData in ipairs(self.guild_dungeon_chapter.chapters) do
        for strongpointDataIndex, strongpointData in ipairs(chapterData.strongpoints) do
            local percent = 0
            local status = 1
            local battle = false
            local rewards = {}
            for monsterDataIndex, monsterData in ipairs(strongpointData.monsters) do
                percent = percent + monsterData.percent
                if monsterData.challenge == 2 then
                    status = 2
                end
                if monsterData.challenge == 3 then
                    battle = true
                end

                for rewardIndex, reward in ipairs(monsterData.rewards) do
                    table.insert(rewards, reward)
                end
            end
            strongpointData.percent = math.ceil(percent / #strongpointData.monsters)
            if percent == 0 then
                status = 3
            end
            strongpointData.status = status
            strongpointData.battle = battle

            strongpointData.rewards = rewards
        end
    end
end

function GuildDungeonModel:CheckRedPonint()
    if RoleManager.Instance.RoleData.lev >= 65 then
        local currentWeek = tonumber(os.date("%w", BaseUtils.BASE_TIME))
        local currentHour = tonumber(os.date("%H", BaseUtils.BASE_TIME))
        if currentWeek == 0 then currentWeek = 7 end
        if currentWeek >= 1 and currentWeek <= 6 and currentHour >= 11 and currentHour < 23 then
            if self.guild_dungeon_chapter.boss_times > 0 or self.guild_dungeon_chapter.times > 0 then
                return true
            else
                return false
            end
        else
            return false
        end
    else
        return false
    end
end

function GuildDungeonModel:CheckTime()
    local currentWeek = tonumber(os.date("%w", BaseUtils.BASE_TIME))
    local currentHour = tonumber(os.date("%H", BaseUtils.BASE_TIME))
    if currentWeek == 0 then currentWeek = 7 end
    if currentWeek >= 1 and currentWeek <= 6 and currentHour >= 11 and currentHour < 23 then
        return true
    else
        return false
    end
end

function GuildDungeonModel:CheckTeamMate(bossData)
    local list = {}
    for key, value in pairs(TeamManager.Instance.memberTab) do
        if value.status == RoleEumn.TeamStatus.Away or value.status == RoleEumn.TeamStatus.Offline then
            table.insert(list, value)
        end
    end

    if #list > 0 then
        local data = NoticeConfirmData.New()
        data.type = ConfirmData.Style.Normal
        data.content = TI18N("队伍中有队友暂离，是否继续挑战？")
        data.sureLabel = TI18N("挑战")
        data.cancelLabel = TI18N("召回")
        data.sureCallback = function() 
            GuildDungeonManager.Instance:Send19501(bossData.chapter_id, bossData.strongpoint_id, bossData.unique)
        end
        data.cancelCallback = function() 
            for index, value in ipairs(list) do
                TeamManager.Instance:Send(11709, {rid = value.rid, platform = value.platform, zone_id = value.zone_id})
            end
        end
        NoticeManager.Instance:ConfirmTips(data)
        return false     
    else
        return true
    end
end

function GuildDungeonModel:scene_load(mapid)
    -- print(debug.traceback())
    -- print(mapid)
    self.bossMapData = self.guildDungeonMapData[mapid]
    -- self.bossMapData = {chapter_id = 1, strongpoint_id = 8, monster_id = 51213}
    
    if self.bossMapData ~= nil then
        if self.timerId ~= nil then
            LuaTimer.Delete(self.timerId)
            self.timerId = nil
        end
        self.timerId = LuaTimer.Add(0, 5000, function() 
                if self.bossMapData ~= nil then
                    GuildDungeonManager.Instance:Send19505(self.bossMapData.chapter_id, self.bossMapData.strongpoint_id, self.bossMapData.unique)
                end
            end)
    else
        if self.timerId ~= nil then
            LuaTimer.Delete(self.timerId)
            self.timerId = nil
        end
    end
end

function GuildDungeonModel:EndFight()
    EventMgr.Instance:RemoveListener(event_name.end_fight, self._EndFight)
    self:OpenWindow()
end

function GuildDungeonModel:UpdateEvent(event, old_event)
    if event == RoleEumn.Event.GuildDungeon and old_event ~= RoleEumn.Event.GuildDungeon then
        self:ShowTitle()
        if MainUIManager.Instance.MainUIIconView ~= nil then
            MainUIManager.Instance.MainUIIconView:Set_ShowTop(false)
        end
    end

    if event ~= RoleEumn.Event.GuildDungeon and old_event == RoleEumn.Event.GuildDungeon then
        self:DeleteTitle()
        if MainUIManager.Instance.MainUIIconView ~= nil then
            MainUIManager.Instance.MainUIIconView:Set_ShowTop(true)
        end
    end

    if event == RoleEumn.Event.GuildDungeonBattle and old_event ~= RoleEumn.Event.GuildDungeonBattle then
        self.fightMapData = nil
        GuildDungeonManager.Instance:Send19500()
    end

    if event ~= RoleEumn.Event.GuildDungeonBattle and old_event == RoleEumn.Event.GuildDungeonBattle then
        self.fightMapData = nil
        self:MainuiTrace()
    end
end

function GuildDungeonModel:FindMyFightMapData()
    if self.guild_dungeon_chapter ~= nil then
        local roleData = RoleManager.Instance.RoleData
        local captinData = TeamManager.Instance.captinData
        for chapterDataIndex, chapterData in ipairs(self.guild_dungeon_chapter.chapters) do
            for strongpointDataIndex, strongpointData in ipairs(chapterData.strongpoints) do
                for monsterDataIndex, monsterData in ipairs(strongpointData.monsters) do
                    if monsterData.challenge == 3 and (roleData.name == monsterData.role_name or (captinData ~= nil and captinData.name == monsterData.role_name)) then
                        local data_unit = DataGuildDungeon.data_unit[string.format("%s_%s_%s", chapterData.chapter_id, strongpointData.strongpoint_id, monsterData.unique)]
                        return { chapter_id = chapterData.chapter_id, strongpoint_id = strongpointData.strongpoint_id, monster_id = monsterData.monster_id, unique = monsterData.unique, head_type = data_unit.head_type, head_id = data_unit.head_id, name = DataUnit.data_unit[data_unit.id].name, exp_id = data_unit.exp_id, exp_ratio = data_unit.exp_ratio}
                    end
                end
            end
        end
    end

    return nil
end

function GuildDungeonModel:MainuiTrace()
    if self.fightMapData ~= nil then
        if self.fight_timerId ~= nil then
            LuaTimer.Delete(self.fight_timerId)
            self.fight_timerId = nil
        end
        self.fight_timerId = LuaTimer.Add(0, 5000, function() 
                if self.fightMapData ~= nil then
                    GuildDungeonManager.Instance:Send19505(self.fightMapData.chapter_id, self.fightMapData.strongpoint_id, self.fightMapData.unique)
                end
            end)
    else
        if self.fight_timerId ~= nil then
            LuaTimer.Delete(self.fight_timerId)
            self.fight_timerId = nil
        end
    end
end

-- 获取战斗中获得的经验
-- exp_id       经验模型id
-- exp_ratio    经验系数
-- war_percent  战斗中打掉的血量
function GuildDungeonModel:GetExp(exp_id, exp_ratio, war_percent)
    local data_levupmode = DataLevup.data_levupmode[string.format("%s_%s", exp_id, RoleManager.Instance.RoleData.lev)]
    if data_levupmode == nil then
        return 0
    else
        local data = nil
        for _, exp_ratio_data in ipairs(exp_ratio) do
            if (war_percent /10) >= exp_ratio_data[1] then
                data = exp_ratio_data
            end
        end
        if data == nil then
            return 0
        else
            return data_levupmode.exp * data[2]
        end
    end
end