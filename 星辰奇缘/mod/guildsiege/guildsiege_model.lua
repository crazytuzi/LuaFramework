-- @author 黄耀聪
-- @date 2017年2月25日

GuildSiegeModel = GuildSiegeModel or BaseClass(BaseModel)

function GuildSiegeModel:__init()
    self.unknownString = TI18N("1.本对手信息将在第一次进攻后显示\n2.摧毁<color='#ffff00'>瞭望塔</color>所有布阵暴露")

    self.hasShowMy = true
    self.hasShowStat = true

    self.statRes = {
        {
            name = nil,
            star3 = nil,
            star2 = nil,
            star1 = nil,
            score = nil,
            all_atk_times = nil,
            win_rate = nil,
            destroy_rate = nil,
            best_attack = nil,
            best_defend = nil,
        }, {}
    }
end

function GuildSiegeModel:__delete()
end

function GuildSiegeModel:OpenCastleWindow(args)
    if self.castleWin == nil then
        self.castleWin = GuildSiegeCastleWindow.New(self)
    end
    -- self.castleWin:Show(args)
    self.castleWin:Open(args)
end

function GuildSiegeModel:ClearStatus()
    self.targetTime = nil
    self.statusData = nil
    self.myCastle = nil
    self.showAllForce = false
    self.guard_attack_log = nil
    self.enemy_attack_log = nil
end

-- 19101 协议数据处理，整理状态
function GuildSiegeModel:SetStatus(data)
    local statusData = self.statusData or {}
    self.statusData = statusData

    local roledata = RoleManager.Instance.RoleData
    local selfType = 1

    for i,guild in ipairs(data.guild_match_list) do
        for j,castle in ipairs(guild.castle_list) do
            if roledata.id == castle.r_id and roledata.platform == castle.r_plat and roledata.zone_id == castle.r_zone then
                self:SetMyCastle(castle)
                castle.type = 1
                selfType = i
            end
        end
    end

    local myGuild = GuildManager.Instance.model.my_guild_data or {}
    local guild = (data.guild_match_list or {})[1] or {}
    if guild.guild_rid == myGuild.GuildId and guild.guild_plat == myGuild.PlatForm and guild.guild_zone == myGuild.ZoneId then
        selfType = 1
    else
        guild = (data.guild_match_list or {})[2] or {}
        if guild.guild_rid == myGuild.GuildId and guild.guild_plat == myGuild.PlatForm and guild.guild_zone == myGuild.ZoneId then
            selfType = 2
        else
            selfType = nil
        end
    end

    if selfType ~= nil then
        local tab = {data.guild_match_list[1], data.guild_match_list[2]}
        data.guild_match_list[1] = tab[selfType]
        if selfType == 1 then
            data.guild_match_list[2] = tab[2]
        else
            data.guild_match_list[2] = tab[1]
        end
    end

    statusData.round = data.round
    statusData.match_id = data.match_id
    statusData.lev_group = data.lev_group

    -- 是否产生结果
    statusData.has_result = data.has_result

    -- 胜利公会
    statusData.win_guild_rid = data.win_guild_rid
    statusData.win_guild_plat = data.win_guild_plat
    statusData.win_guild_zone = data.win_guild_zone

    statusData.guild_match_list = statusData.guild_match_list or {}

    for i,guild in ipairs(data.guild_match_list) do
        local tab = statusData.guild_match_list[i] or {}
        statusData.guild_match_list[i] = tab

        tab.guild_rid = guild.guild_rid
        tab.guild_plat = guild.guild_plat
        tab.guild_zone = guild.guild_zone
        tab.guild_name = guild.guild_name
        tab.guild_lev = guild.guild_lev
        tab.win_star_3 = guild.win_star_3
        tab.win_star_2 = guild.win_star_2
        tab.win_star_1 = guild.win_star_1
        tab.atk_times = guild.atk_times
        tab.win_times = guild.win_times
        tab.score = guild.score
        tab.castle_num = guild.castle_num
        tab.best_atk_name = guild.best_atk_name
        tab.a_replay_id = guild.a_replay_id
        tab.a_replay_plat = guild.a_replay_plat
        tab.a_replay_zone = guild.a_replay_zone
        tab.best_def_name = guild.best_def_name
        tab.best_atk_name = guild.best_atk_name
        tab.d_replay_id = guild.d_replay_id
        tab.d_replay_plat = guild.d_replay_plat
        tab.d_replay_zone = guild.d_replay_zone

        tab.castle_list = tab.castle_list or {}
        for j,castle in ipairs(guild.castle_list) do
            local tab1 = tab.castle_list[j] or {}
            tab.castle_list[j] = tab1
            tab1.r_id = castle.r_id
            tab1.r_plat = castle.r_plat
            tab1.r_zone = castle.r_zone
            tab1.order = castle.order
            tab1.name = castle.name
            tab1.lev = castle.lev
            tab1.classes = castle.classes
            tab1.sex = castle.sex
            tab1.type = i
            tab1.lev_break_times = castle.lev_break_times
            tab1.loss_star = castle.loss_star
            tab1.def_times = castle.def_times
            tab1.def_win_times = castle.def_win_times
            tab1.atk_times = castle.atk_times
            tab1.atk_win_times = castle.atk_win_times
            tab1.is_combat = castle.is_combat
            tab1.formation_lev = castle.formation_lev
            tab1.formation = castle.formation
            tab1.guards = castle.guards
        end
    end

    -- BaseUtils.dump(self.myCastle, "<color='#ff0000'>model.myCastle</color>")
    -- print(selfType)
    -- if self.myCastle == nil and selfType ~= nil then
    -- GuildSiegeManager.Instance:send19108()
    -- end
end

-- 攻城战结果
function GuildSiegeModel:FinalResult()
    if self.statusData == nil or self.statusData.has_result ~= 1 then
        return GuildSiegeEumn.ResultType.None
    else
        local myGuild = ((self.statusData or {}).guild_match_list or {})[1] or {}
        if myGuild.guild_rid == self.statusData.win_guild_rid and myGuild.guild_plat == self.statusData.win_guild_plat and myGuild.guild_zone == self.statusData.win_guild_zone then
            -- 我赢了
            if self.statusData.guild_match_list[1].score == 0 or self.statusData.guild_match_list[1].score / self.statusData.guild_match_list[2].score <= 1.2 then
                -- 险胜
                return GuildSiegeEumn.ResultType.Win
            else
                -- 完胜
                return GuildSiegeEumn.ResultType.Victory
            end
        else
            -- 我输了
            if self.statusData.guild_match_list[2].score == 0 or self.statusData.guild_match_list[2].score / self.statusData.guild_match_list[1].score <= 1.2 then
                -- 惜败
                return GuildSiegeEumn.ResultType.Fail
            else
                -- 完败
                return GuildSiegeEumn.ResultType.Loss
            end
        end
    end
    -- elseif self.statusData.guild_match_list[1].score == self.statusData.guild_match_list[2].score then
    --     return GuildSiegeEumn.ResultType.Draw
    -- elseif self.statusData.guild_match_list[1].score == 0 then
    --     return GuildSiegeEumn.ResultType.Loss
    -- elseif self.statusData.guild_match_list[1].score < self.statusData.guild_match_list[2].score then
    --     return GuildSiegeEumn.ResultType.Fail
    -- elseif self.statusData.guild_match_list[2].score == 0 then
    --     return GuildSiegeEumn.ResultType.Victory
    -- elseif self.statusData.guild_match_list[1].score > self.statusData.guild_match_list[2].score then
    --     return GuildSiegeEumn.ResultType.Win
    -- else
    --     return GuildSiegeEumn.ResultType.None
    -- end
end

function GuildSiegeModel:SetCastle(castle)
    self.statusData = self.statusData or {guild_match_list = {}}
    if self.statusData.guild_match_list == nil then 
        self.statusData.guild_match_list = {}
    end
    self.statusData.guild_match_list[castle.flag] = self.statusData.guild_match_list[castle.flag] or {castle_list = {}}
    local tab = nil
    for _,v in pairs(self.statusData.guild_match_list[castle.flag].castle_list) do
        if castle.r_id == v.r_id and castle.r_plat == v.r_plat and castle.r_zone then
            tab = v
        end
    end
    if tab ~= nil then
        tab.type = castle.flag
        tab.r_id = castle.r_id
        tab.r_plat = castle.r_plat
        tab.r_zone = castle.r_zone
        tab.order = castle.order
        tab.name = castle.name
        tab.lev = castle.lev
        tab.classes = castle.classes
        tab.sex = castle.sex
        tab.lev_break_times = castle.lev_break_times
        tab.loss_star = castle.loss_star
        tab.def_times = castle.def_times
        tab.def_win_times = castle.def_win_times
        tab.atk_times = castle.atk_times
        tab.atk_win_times = castle.atk_win_times
        tab.can_look = castle.can_look
        tab.formation = castle.formation
        tab.formation_lev = castle.formation_lev
        tab.guards = castle.guards
        tab.castle_log = tab.castle_log or {}
        tab.is_combat = castle.is_combat

        for k,log in ipairs(castle.castle_log) do
            local tab2 = tab.castle_log[k] or {}
            tab.castle_log[k] = tab2

            for key,value in pairs(log) do
                tab2[key] = value
            end
        end

        table.sort(castle.castle_log, function(a,b) return a.time < b.time end)
    end
end

-- 统计数据
function GuildSiegeModel:Stat()
    if self.statusData == nil then
        local key = {}
        for k,v in pairs(self.statRes[1]) do
            if v ~= nil then key[k] = 1 end
        end
        for k,v in pairs(self.statRes[2]) do
            if v ~= nil then key[k] = 1 end
        end
        for k,_ in pairs(key) do
            self.statRes[1][k] = nil
            self.statRes[2][k] = nil
        end
    else
        for type,guild in ipairs(self.statusData.guild_match_list or {}) do
            self.statRes[type].name = guild.guild_name
            self.statRes[type].star1 = guild.win_star_1
            self.statRes[type].star2 = guild.win_star_2
            self.statRes[type].star3 = guild.win_star_3
            self.statRes[type].all_atk_times = guild.atk_times

            print(string.format("%s-%s",guild.win_times, guild.atk_times))
            if guild.atk_times == 0 then
                self.statRes[type].win_rate = 0
            else
                self.statRes[type].win_rate = guild.win_times / guild.atk_times
            end
            local des = 0
            for _,castle in pairs(guild.castle_list or {}) do
                if castle.loss_star == 3 then
                    des = des + 1
                end
            end
            if guild.castle_num == 0 then
                self.statRes[type].destroy_rate = 0
            else
                self.statRes[type].destroy_rate = string.format("%s/%s", des, guild.castle_num)
            end
            self.statRes[type].best_attack = {name = guild.best_atk_name, id = guild.atk_rid, platform = guild.atk_plat, zone_id = atk_zone, replay_id = guild.a_replay_id, replay_plat = guild.a_replay_plat, replay_zone = guild.a_replay_zone}
            self.statRes[type].best_defend = {name = guild.best_def_name, id = guild.def_rid, platform = guild.def_plat, zone_id = def_zone, replay_id = guild.d_replay_id, replay_plat = guild.d_replay_plat, replay_zone = guild.d_replay_zone}
            self.statRes[type].score = guild.score
        end
    end
end

-- 设置我的信息
function GuildSiegeModel:SetMyCastle(data)
    self.myCastle = self.myCastle or {}
    self.myCastle.r_id = data.r_id or self.myCastle.r_id
    self.myCastle.r_zone = data.r_zone or self.myCastle.r_zone
    self.myCastle.r_plat = data.r_plat or self.myCastle.r_plat
    self.myCastle.order = data.order or self.myCastle.order
    self.myCastle.name = data.name or self.myCastle.name
    self.myCastle.lev = data.lev or self.myCastle.lev
    self.myCastle.classes = data.classes or self.myCastle.classes
    self.myCastle.sex = data.sex or self.myCastle.sex
    self.myCastle.lev_break_times = data.lev_break_times or self.myCastle.lev_break_times
    self.myCastle.loss_star = data.loss_star or self.myCastle.loss_star
    self.myCastle.def_times = data.def_times or self.myCastle.def_times
    self.myCastle.def_win_times = data.def_win_times or self.myCastle.def_win_times
    self.myCastle.atk_times = data.atk_times or self.myCastle.atk_times
    self.myCastle.atk_win_times = data.atk_win_times or self.myCastle.atk_win_times
    self.myCastle.is_combat = data.is_combat or self.myCastle.is_combat
    self.myCastle.formation = data.formation or self.myCastle.formation
    self.myCastle.formation_lev = data.formation_lev or self.myCastle.formation_lev
    self.myCastle.pet_id = data.pet_base_id or self.myCastle.pet_id
    self.myCastle.guards = data.guards or self.myCastle.guards
end

function GuildSiegeModel:CloseCastleWindow()
    if self.castleWin ~= nil then
        self.castleWin:DeleteMe()
        self.castleWin = nil
    end
end

function GuildSiegeModel:OpenSettle(args)
    if self.settleWin == nil then
        self.settleWin = GuildSiegeSettle.New(self)
    end
    self.settleWin:Open(args)
end

function GuildSiegeModel:OnAttack(castle)
    BaseUtils.dump(castle)
    if castle.is_combat == 1 then
        GuildSiegeManager.Instance:send19112(castle.type, castle.order)
    else
        if self.castleWin ~= nil then
            self.castleWin:OnAttack(castle)
        end
    end
end

function GuildSiegeModel:ShowPlayer(castle)
    if self.castleWin ~= nil then
        self.castleWin:ShowPlayer(castle)
    end
end
