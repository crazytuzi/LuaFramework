-- 冠军联赛 manager
-- hzf
-- 8/29

GuildLeagueManager  = GuildLeagueManager or BaseClass(BaseManager)

function GuildLeagueManager:__init()
    if GuildLeagueManager.Instance then
        Log.Error("不可以对单例对象重复实例化")
        return
    end
    GuildLeagueManager.Instance = self
    self.ready_time = 0     --准备时间
    self.cannonCd = 0 -- 大炮cd
    self.is_win = 0

    self.loading = false --处理动态遮挡区域中
    self.fightInfo = nil --对阵信息
    self.my_guild_name = nil
    self.my_guild_totem = nil
    self.my_guild_side = nil
    self.other_guild_name = nil
    self.other_guild_totem = nil
    self.other_guild_side = nil
    self.self_leagueinfo = nil
    self.fight_schedule_info = {}
    self.leaguGroupData = {}
    self.kingTeam = {}
    self.collectstatus = {}
    self.voteData = {}
    self.championHistory = {}
    self.kingGuildData = nil
    self.worshed = false

    self.currData = nil --当前个人行动力信息
    self.towerData = nil -- 当前水晶塔状态

    self.model = GuildLeagueModel.New()

    self.LeagueFightInfoUpdate = EventLib.New() -- 对战信息更新
    self.LeagueStatusChange = EventLib.New()    -- 活动状态更新
    self.LeagueMovabilityChange = EventLib.New()    -- 行动力更新
    self.LeagueTowerChange = EventLib.New() -- 战场塔血量更新
    self.LeagueTeamChange = EventLib.New()  -- 王牌队伍更新
    self.LeagueMemberFightInfoChange = EventLib.New()  -- 成员战绩更新
    self.LeagueSummaryUpdate = EventLib.New()  -- 联赛公会详细更新
    self.LeagueFightScheduleUpdate = EventLib.New()  -- 对阵赛程更新
    self.LeagueRankUpdate = EventLib.New()  -- 赛季排名更新
    self.LeagueKingGuildUpdate = EventLib.New()  -- 冠军组更新
    self.guessDataUpdate = EventLib.New()  -- 竞猜数据更新
    self.liveDataRefresh = EventLib.New()  -- 直播数据更新

    self.collection = GuildLeagueCollectPanel.New()
    self.on_role_event_change = function()
        self:RoleEventChange()
        self:SceneEnter()
    end
    self.soundcfg = {
        ready = 566,
        start = 567,
        cannon = 568,
        selfbroken = 569,
        otherbroken = 570,
        win = 571,
        fire = 666,
        hit = 667
    }
    self.CannonPosition = Vector2(7.49, 11.57)
    self:InitHandler()
end

function GuildLeagueManager:InitHandler()
    self:AddNetHandler(17600, self.On17600)
    self:AddNetHandler(17601, self.On17601)
    self:AddNetHandler(17602, self.On17602)
    self:AddNetHandler(17603, self.On17603)
    self:AddNetHandler(17604, self.On17604)
    self:AddNetHandler(17605, self.On17605)
    self:AddNetHandler(17606, self.On17606)
    self:AddNetHandler(17607, self.On17607)
    self:AddNetHandler(17608, self.On17608)
    self:AddNetHandler(17609, self.On17609)
    self:AddNetHandler(17610, self.On17610)
    self:AddNetHandler(17611, self.On17611)
    self:AddNetHandler(17612, self.On17612)
    self:AddNetHandler(17613, self.On17613)
    self:AddNetHandler(17614, self.On17614)
    self:AddNetHandler(17615, self.On17615)
    self:AddNetHandler(17616, self.On17616)
    self:AddNetHandler(17617, self.On17617)
    self:AddNetHandler(17618, self.On17618)
    self:AddNetHandler(17619, self.On17619)
    self:AddNetHandler(17620, self.On17620)
    self:AddNetHandler(17621, self.On17621)
    self:AddNetHandler(17622, self.On17622)
    self:AddNetHandler(17623, self.On17623)
    self:AddNetHandler(17624, self.On17624)
    self:AddNetHandler(17625, self.On17625)
    self:AddNetHandler(17626, self.On17626)
    self:AddNetHandler(17627, self.On17627)
    self:AddNetHandler(17628, self.On17628)
    self:AddNetHandler(17629, self.On17629)
    self:AddNetHandler(17630, self.On17630)
    self:AddNetHandler(17631, self.On17631)

    self:InitArenaInfo()
    -- EventMgr.Instance:AddListener(event_name.role_event_change, self.on_role_event_change)
    EventMgr.Instance:AddListener(event_name.scene_load, function() self:SceneEnter() end)
    EventMgr.Instance:AddListener(event_name.mainui_loaded, function()
        EventMgr.Instance:AddListener(event_name.role_event_change, self.on_role_event_change)
        self.on_role_event_change()
    end)
    EventMgr.Instance:AddListener(event_name.enter_guild_succ, function()
        self:Require17600()
        self:Require17619()
    end)
    EventMgr.Instance:AddListener(event_name.begin_fight, function()
        if self.collection.running then
            self.collection:Cancel()
        end
    end)
    self.LeagueSummaryUpdate:AddListener(function()
        GuildManager.Instance:on_show_red_point()
    end)
end

function GuildLeagueManager:ReqOnConnect()
    self.model:StopTowerControll()
    self.model:CloseFightInfoPanel()
    self:Require17600()
    self:Require17619()
    self:Require17631()
end

function GuildLeagueManager:Require17600()
    Connection.Instance:send(17600,{})
end


function GuildLeagueManager:On17600(data)
    BaseUtils.dump(data, "<color='#00ff00'>on17600</color>")
    self.cannonCd = 0
    self.currstatus = data.status
    self.season_id = data.season_id
    self.LeagueStatusChange:Fire()

    local cfg_data = DataSystem.data_daily_icon[118]
    MainUIManager.Instance:DelAtiveIcon(cfg_data.id)

    --未达到开放条件
    if cfg_data.lev > RoleManager.Instance.RoleData.lev or RoleManager.Instance.world_lev < 70 then
        return
    end

    if self.iconEffect ~= nil then
        self.iconEffect:DeleteMe()
    end

    local callback = function()
            local teamNumber = TeamManager.Instance.teamNumber
            if TeamManager.Instance:HasTeam() and teamNumber ~= 1 then
                local npcBase = DataUnit.data_unit[20060]
                npcBase.buttons = {}
                if self:GetTeamSameGroup() then
                    self:Require17602()
                else
                    npcBase.plot_talk = TI18N("队伍中存在玩家不是同一等级段（70~89，90~100，101~119，120及以上），无法进入")
                    MainUIManager.Instance:OpenDialog({baseid = npcBase.id, name = npcBase.name}, {base = npcBase}, true, true)
                end
            else
                self:Require17602()
            end
        end

    -- AgendaManager.Instance:SetCurrLimitID(2028, data.status == 2)
    if data.status == 0 then

    elseif data.status == 1 or data.status == 2 then        --进行中
        self:Require17601()

        --动态图标
        MainUIManager.Instance:DelAtiveIcon(cfg_data.id)
        local iconData = AtiveIconData.New()
        iconData.id = cfg_data.id
        iconData.iconPath = cfg_data.res_name
        iconData.clickCallBack = callback
        iconData.sort = cfg_data.sort
        iconData.lev = cfg_data.lev
        if data.status == 1 then
            self.ready_time = data.timeout + Time.time
            iconData.text = TI18N("准备中")
        else
            iconData.timestamp = data.timeout + Time.time
        end
        iconData.timeoutCallBack = function() self:Require17600() end


        --动态图标特效
        self.icon = MainUIManager.Instance:AddAtiveIcon(iconData)
        if BaseUtils.isnull(self.icon) then
            if self.iconEffect ~= nil then
                self.iconEffect:DeleteMe()
                self.iconEffect = nil
            end
        else
            if self.iconEffect == nil then 
                self.iconEffect = BaseUtils.ShowEffect(20256,self.icon.transform,Vector3(1,1,1),Vector3(0, 32, -400))
            end
        end


        --活动开启提示框
        if RoleManager.Instance.RoleData.lev >= cfg_data.lev and not (RoleManager.Instance.RoleData.event == RoleEumn.Event.Guildleague or RoleManager.Instance.RoleData.event == RoleEumn.Event.GuildleagueReady) and not(GuildManager.Instance.model.my_guild_data == nil or GuildManager.Instance.model.my_guild_data.GuildId == 0) then
            local data = NoticeConfirmData.New()
            data.type = ConfirmData.Style.Normal
            data.content = TI18N("<color='#ffff00'>峡谷之巅</color>活动正在进行中，是否前往参加？")
            data.sureLabel = TI18N("确定")
            data.cancelLabel = TI18N("取消")
            data.cancelSecond = 180
            data.sureCallback = callback
            NoticeManager.Instance:ActiveConfirmTips(data)
        end
    end

    self.model.activity_time = data.timeout + Time.time
end


function GuildLeagueManager:Require17601()
    Connection.Instance:send(17601,{})
end


function GuildLeagueManager:On17601(data)
    self.fightInfo = data.guild_league_alliance
    self.is_win = 0
    if GuildManager.Instance.model.my_guild_data == nil then
        LuaTimer.Add(300, self:On17601(data))
        return
    end
    local selfname = GuildManager.Instance.model.my_guild_data.Name
    local infolist = GuildLeagueManager.Instance.fightInfo
    if infolist == nil then
        return
    end
    for _,v in pairs(infolist) do
        for _,vv in pairs(v.names) do
            if selfname == vv.name then
                self.my_guild_name = vv.name
                self.my_guild_totem = v.totems[1].totem
                self.my_guild_side = v.side
                self.self_remain_num = v.remain_num
                self.self_member_num = v.member_num
                self.self_leagueinfo = v
                self.is_win = v.is_win
            else
                self.other_guild_name = vv.name
                self.other_guild_totem = v.totems[1].totem
                self.other_guild_side = v.side
                self.other_remain_num = v.remain_num
                self.other_member_num = v.member_num
            end
        end
    end
    if data.status == 2 and RoleManager.Instance.RoleData.event == RoleEumn.Event.Guildleague then
        self.model:OpenFightInfoPanel()
        self:Require17605()
    end
    self.LeagueFightInfoUpdate:Fire()
end
function GuildLeagueManager:Require17602()
    Connection.Instance:send(17602,{})
end


function GuildLeagueManager:On17602(data)
    if data.flag == 1 then
        if self.currstatus == 1 then
            SoundManager.Instance:PlayCombatChat(self.soundcfg.ready)
        elseif self.currstatus == 2 then
            SoundManager.Instance:PlayCombatChat(self.soundcfg.start)
        end
    end
    -- NoticeManager.Instance:FloatTipsByString(data.msg)
end
function GuildLeagueManager:Require17603()
    if self.currstatus == 2 then
        local data = NoticeConfirmData.New()
        data.type = ConfirmData.Style.Normal
        data.content = TI18N("正式比赛已经开始，提前<color='#ffff00'>退出</color>将<color='#ffff00'>不能再次入场</color>")
        data.sureLabel = TI18N("退出")
        data.cancelLabel = TI18N("取消")
        data.sureCallback = function()
            Connection.Instance:send(17603,{})
        end
        NoticeManager.Instance:ConfirmTips(data)
    else
        Connection.Instance:send(17603,{})
    end
end


function GuildLeagueManager:On17603(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end
function GuildLeagueManager:Require17604(id, platform, zone_id)
    Connection.Instance:send(17604,{id = id, platform = platform, zone_id = zone_id})
end


function GuildLeagueManager:On17604(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end
function GuildLeagueManager:Require17605()
    Connection.Instance:send(17605,{})
end


function GuildLeagueManager:On17605(data)
    -- BaseUtils.dump(data, "当前自己的数据啊啊啊啊啊啊啊啊")
    self.currData = data
    self.LeagueMovabilityChange:Fire()
end
function GuildLeagueManager:Require17606(grade, season)
    print("请求17606"..tostring(grade).."  "..tostring(season))

    Connection.Instance:send(17606,{grade = grade, season = season})
end


function GuildLeagueManager:On17606(data)
    -- BaseUtils.dump(data, "17606")
    self.fight_schedule_info = {}
    for i,v in ipairs(data.guild_league_guild) do
        if v.time ~= 0 then
            local day = os.date("%d", v.time)
            local month = os.date("%m", v.time)
            local week = os.date("%w", v.time)
            if week == "0" then week = "7" end
            week = BaseUtils.NumToChn(tonumber(week))
            if week == TI18N("七") then
                week = TI18N("日")
            end
            local key = string.format("%s_%s", month, day)
            if self.fight_schedule_info[key] == nil then
                self.fight_schedule_info[key] = {}
            end
            if self.fight_schedule_info[key][v.match_id] == nil then
                self.fight_schedule_info[key][v.match_id] = {}
            end
            v.day = day
            v.month = month
            v.week = week
            table.insert(self.fight_schedule_info[key][v.match_id], v)
        else
        end
    end
    self.LeagueFightScheduleUpdate:Fire()

end
function GuildLeagueManager:Require17607()
    Connection.Instance:send(17607,{})
end


function GuildLeagueManager:On17607(data)
    -- BaseUtils.dump(data, "On17607")
    self.memberFigthInfo = data.guild_league_role
    self.LeagueMemberFightInfoChange:Fire()
    if self.model.menberfight_rankpanel ~= nil then
        self.model.menberfight_rankpanel:Show()
    end
end
function GuildLeagueManager:Require17608()
    Connection.Instance:send(17608,{})
end


function GuildLeagueManager:On17608(data)
    self.othermemberFigthInfo = data.guild_league_role
end
function GuildLeagueManager:Require17609()
    Connection.Instance:send(17609,{})
end


function GuildLeagueManager:On17609(data)
    if data.type == 0 then
        self.model:OpenResultCountWindow()
    end
end

function GuildLeagueManager:Require17610(battle_id, id)
    local real_battle_id = 0
    for k,v in pairs(SceneManager.Instance.sceneElementsModel.NpcView_List) do
        if v.data.unittype == 1 and v.data.id == id then
            real_battle_id = v.data.battleid
        end
    end
    -- print("battleid: "..tostring(real_battle_id))
    -- print("id: "..tostring(id))
    if real_battle_id == nil then
        real_battle_id = battle_id
    end
    Connection.Instance:send(17610,{battle_id = real_battle_id, id = id})
end


function GuildLeagueManager:On17610(data)
    -- BaseUtils.dump(data, "On17610,攻塔或使用大炮")
    if data.flag == 1 then
        self.collection.callback = function()
            print("完成采集")
            self.collection.cancelCallBack = nil
            self:Require17612()
        end
        self.collection.cancelCallBack = function()
            self:Require17613()
            print("取消采集")
        end
        if data.id == 7 then
            self.collection:Show({msg = "操作大炮中...", time = 20000, optype = 1})
        else
            self.collection:Show({msg = "攻塔中...", time = 20000, optype = 2})
        end
        if self.model.fightinfopanel ~= nil then
            self.model.fightinfopanel:HideIcon()
        end
    end
    NoticeManager.Instance:FloatTipsByString(data.msg)
end


function GuildLeagueManager:Require17611(battle_id, id)
    local real_battle_id = 0
    for k,v in pairs(SceneManager.Instance.sceneElementsModel.NpcView_List) do
        if v.data.unittype == 1 and v.data.id == id then
            real_battle_id = v.data.battleid
        end
    end
    if real_battle_id == nil then
        real_battle_id = battle_id
    end
    -- SceneManager.Instance.sceneElementsModel.NpcView_List
    Connection.Instance:send(17611,{battle_id = real_battle_id, id = id})
end


function GuildLeagueManager:On17611(data)
    -- BaseUtils.dump(data, "On17611,守塔或打断大炮")
    NoticeManager.Instance:FloatTipsByString(data.msg)
    if data.flag == 1 then
        self.collection.callback = function()
            -- print("完成采集")
            self.collection.cancelCallBack = nil
            self:Require17612()
        end
        self.collection.cancelCallBack = function()
            self:Require17613()
            -- print("取消采集")
        end
        self.collection:Show({msg = "守塔中...", time = 6000000, optype = 3})
    end
    -- if self.model.fightinfopanel ~= nil then
    --     self.model.fightinfopanel:HideIcon()
    -- end
end

function GuildLeagueManager:Require17612()
    Connection.Instance:send(17612,{})
end


function GuildLeagueManager:On17612(data)
    BaseUtils.dump(data, "On17612, 开炮结算")
    NoticeManager.Instance:FloatTipsByString(data.msg)
    if data.flag == 1 then
        self.model:FinishMotion(data.id)
        if data.id ~= 7 then
            local Confirmdata = NoticeConfirmData.New()
            Confirmdata.type = ConfirmData.Style.Sure
            if data.id == 1 or data.id == 4 then
                Confirmdata.content = TI18N("我队对敌方<color='#01c0ff'>1号水晶塔</color>造成了一定伤害{face_1,18}\n<color='#ffff00'>（队伍人数越多，造成伤害越大）</color>")
            elseif data.id == 2 or data.id == 5 then
                Confirmdata.content = TI18N("我队对敌方<color='#01c0ff'>2号水晶塔</color>造成了一定伤害{face_1,18}\n<color='#ffff00'>（队伍人数越多，造成伤害越大）</color>")
            elseif data.id == 3 or data.id == 6 then
                Confirmdata.content = TI18N("我队对敌方<color='#01c0ff'>3号水晶塔</color>造成了一定伤害{face_1,18}\n<color='#ffff00'>（队伍人数越多，造成伤害越大）</color>")
            else
                Confirmdata.content = TI18N("我队对敌方<color='#01c0ff'>水晶塔</color>造成了一定伤害{face_1,18}\n<color='#ffff00'>（队伍人数越多，造成伤害越大）</color>")
            end
            Confirmdata.sureLabel = TI18N("确定")
            Confirmdata.sureSecond = 5
            -- data.sureCallback = self.sureCallback
            NoticeManager.Instance:ConfirmTips(Confirmdata)
        end
    end
    self.collection:Cancel()
end

function GuildLeagueManager:Require17613()
    Connection.Instance:send(17613,{})
end


function GuildLeagueManager:On17613(data)
    -- BaseUtils.dump(data, "On17613, 中断操作")
    NoticeManager.Instance:FloatTipsByString(data.msg)
end


function GuildLeagueManager:Require17614()
    Connection.Instance:send(17614,{})
end


function GuildLeagueManager:On17614(data)
    -- BaseUtils.dump(data, "On17614, 水晶塔状态")
    self.towerData = data.guild_league_unit
    self.LeagueTowerChange:Fire()
end

function GuildLeagueManager:Require17615()
    Connection.Instance:send(17615,{})
end


function GuildLeagueManager:On17615(data)
    BaseUtils.dump(data, "On17615, 王牌信息")
    self.kingTeam = data.guild_league_trump
    self.LeagueTeamChange:Fire()
end

function GuildLeagueManager:Require17616(id, platform, zone_id, position)
    Connection.Instance:send(17616,{id = id, platform = platform, zone_id = zone_id, position = position})
end


function GuildLeagueManager:On17616(data)
    BaseUtils.dump(data, "On17616, 设置王牌")
    NoticeManager.Instance:FloatTipsByString(data.msg)
end


function GuildLeagueManager:On17617(data)
    BaseUtils.dump(data, "On17617, 大炮开火")
    if CombatManager.Instance.isFighting == true then
        return
    end
    -- if data.id > 3 then
        self:PlayCannonAction(data)
    -- else
    --     self:PlayCannonAction(2)
    -- end
end

function GuildLeagueManager:On17618(data)
    -- BaseUtils.dump(data, "On17618, 采集状态")
    local uniqueroleid = BaseUtils.get_unique_roleid(data.rid, data.zone_id, data.platform)
    local rv = SceneManager.Instance.sceneElementsModel.RoleView_List[uniqueroleid]
    self.collectstatus[uniqueroleid] = {status = data.status, time = Time.time}
    if rv == nil then
        return
    end
    if TeamManager.Instance:IsInMyTeam(uniqueroleid) then
        if SceneManager.Instance.sceneElementsModel.self_view ~= rv then
            self.collection.callback = function() end
            self.collection.cancelCallBack = function() end
            if data.status == 1 then
                if BaseUtils.isnull(rv.gameObject) == false then
                    local pos = rv.gameObject.transform.position
                    print(Vector2.Distance(Vector2(pos.x, pos.y), self.CannonPosition))
                    if Vector2.Distance(Vector2(pos.x, pos.y), self.CannonPosition) <= 2 then
                        self.collection:Show({msg = "操作大炮中...", time = 20000, optype = 1, special = true})
                    else
                        self.collection:Show({msg = "攻塔中...", time = 20000, optype = 2, special = true})
                    end
                end
            elseif data.status == 2 then
                self.collection:Show({msg = "守塔中...", time = 6000000, optype = 3, special = true})
            else
                self.collection:Cancel()
            end
        end
    end
    if data.status == 1 then
        rv:ShowCollectStatusEffect()
    else
        rv:ClearCollectStatusEffect()
    end
end

function GuildLeagueManager:Require17619()
    Connection.Instance:send(17619,{})
end


function GuildLeagueManager:On17619(data)
    self.guild_LeagueInfo = data
    -- BaseUtils.dump(data, "On17619, 冠军联赛信息总览")
    self:Require17623(self.guild_LeagueInfo.season_id)
    self:Require17625()
    self.LeagueSummaryUpdate:Fire()
end

function GuildLeagueManager:Require17620(grade, type)
    self.rankdatatype = type
    Connection.Instance:send(17620,{grade=grade})
end

function GuildLeagueManager:On17620(data)
    -- BaseUtils.dump(data, "17620")
    if self.rankdatatype == 1 then
        self.leagueRankData = data
    elseif self.rankdatatype == 2 then
        self.leaguGroupData = {}
        -- for i,v in ipairs(data.guild_league_summary) do
        --     -- local index = math.ceil(i/8)
        --     local index = math.ceil(v.group/2)
        --     local subindex = 1
        --     if v.group%2 == 0 then
        --         subindex = 2
        --     end
        --     -- local subindex = math.ceil((((i-1)%8)+1)/4.1)
        --     if self.leaguGroupData[index] == nil then
        --     self.leaguGroupData[index] = {}
        --     end
        --     if self.leaguGroupData[index][subindex] == nil then
        --     self.leaguGroupData[index][subindex] = {}
        --     end
        --     table.insert(self.leaguGroupData[index][subindex], v)
        -- end
        local temp = {}
        for i,v in ipairs(data.guild_league_summary) do
            if temp[v.group] == nil then
                temp[v.group] = {}
            end
            table.insert(temp[v.group], v)
        end
        local temp2 = {}
        for k,v in pairs(temp) do
            table.insert(temp2, v)
        end
        table.sort( temp2, function(a, b) return a[1].group < b[1].group end)
        for i,v in ipairs(temp2) do
            if data.grade == 4 and i >16 then
                break
            end
            local index = math.ceil(i/2)
            local subindex = (i-1)%2+1
            -- print(string.format("%s__%s  NUM: %s", tostring(index), tostring(subindex), tostring(#v)))
            if self.leaguGroupData[index] == nil then
                self.leaguGroupData[index] = {}
            end
            if self.leaguGroupData[index][subindex] == nil then
                self.leaguGroupData[index][subindex] = {}
            end
            self.leaguGroupData[index][subindex] = v
        end
        -- self.leaguGroupData = temp2
    end
    self.rankdatatype = 0
    self.LeagueRankUpdate:Fire()
end

function GuildLeagueManager:Require17621(match_id)
    Connection.Instance:send(17621,{match_id = match_id})
end

function GuildLeagueManager:On17621(data)
    -- BaseUtils.dump(data, "On17621")
    self.model:OpenResultCountWindow(data.guild_league_alliance)
end


function GuildLeagueManager:Require17622()
    Connection.Instance:send(17622,{})
end

function GuildLeagueManager:On17622(data)
    -- BaseUtils.dump(data, "On17622@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@")
    self.cannonCd = data.cd + Time.time
end

function GuildLeagueManager:Require17623(season)
    Connection.Instance:send(17623,{season = season})
end

function GuildLeagueManager:On17623(data)
    -- BaseUtils.dump(data, "On17623@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@")
    self.kingGuildData = data.guild_league_guild
    local temp = {}
    local guild = {}
    local phasedata = {}

    for k,v in pairs(data.guild_league_guild ) do
        local realgroup = v.group
        if realgroup == 2 then
            realgroup = 3
        elseif realgroup == 3 then
            realgroup = 2
        end
        local index = (realgroup-1)*4+v.order
        if v.order == 2 then
            index = (realgroup-1)*4 + 3
        elseif v.order == 3 then
            index = (realgroup-1)*4 + 2
        end
        v.index = index
        if guild[index] == nil or guild[index].phase < v.phase then
            guild[index] = v
        end
        if temp[v.phase-3] == nil then
            temp[v.phase-3] = {}
        end
        if v.is_win == 1 and  v.season_consecutive_win == v.phase-3 then
            table.insert(temp[v.phase-3], index)
        end
        if phasedata[v.phase-3] == nil then
            phasedata[v.phase-3] = {}
        end
        if (v.is_win == 1 or v.phase == 7) then
            table.insert(phasedata[v.phase-3], v)
        end
    end
    temp.guild = guild
    temp.phasedata = phasedata
    self.kingGuildData = temp
    -- BaseUtils.dump(self.kingGuildData)
    self.LeagueKingGuildUpdate:Fire()
end


function GuildLeagueManager:Require17624(guild_id, platform, zone_id, season)
    Connection.Instance:send(17624,{guild_id = guild_id, platform = platform, zone_id = zone_id, season = season})
end

function GuildLeagueManager:On17624(data)
    -- BaseUtils.dump(data, "On17624@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@")
    if #data.gid < 2 then
        NoticeManager.Instance:FloatTipsByString(TI18N("该公会已战败，无法查看"))
        return
    end
    self.model:OpenHistoryPanel(data)
end


function GuildLeagueManager:Require17625()
    Connection.Instance:send(17625,{})
end

function GuildLeagueManager:On17625(data)
    -- BaseUtils.dump(data, "On17625@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@")
    local temp = {}
    for k,v in pairs(data.guild_league_guess_choice) do
        if temp[v.phase] == nil then
            temp[v.phase] = {}
        end
        table.insert(temp[v.phase], v)
    end
    local vote = {}
    for k,v in pairs(data.guild_league_poll) do
        local key = string.format("A%s_%s_%s", v.guild_id, v.platform, v.zone_id)
        vote[key] = v.voted
    end
    self.guessData = temp
    self.voteData = vote
    self.guessDataUpdate:Fire()
end

function GuildLeagueManager:Require17626(id)
    -- BaseUtils.dump(id, "发送数据")
    Connection.Instance:send(17626,{id = id})
end

function GuildLeagueManager:On17626(data)
    -- BaseUtils.dump(data, "On17626@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@")
    NoticeManager.Instance:FloatTipsByString(data.msg)
end


function GuildLeagueManager:Require17627(id)
    BaseUtils.dump(id, "发送数据")
    Connection.Instance:send(17627,{})
end

function GuildLeagueManager:On17627(data)
    self.liveList = data.guild_league_live
    -- BaseUtils.dump(data, "On17627@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@")
    if #self.liveList == 0 then
        NoticeManager.Instance:FloatTipsByString(TI18N("当前尚未有比赛直播"))
        return
    end
    self.model:OpenLiveWindow()
end


function GuildLeagueManager:Require17628(match_id)
    -- BaseUtils.dump(id, "发送数据")
    Connection.Instance:send(17628,{match_id = match_id})
end

function GuildLeagueManager:On17628(data)
    self.currLiveData = data
    -- BaseUtils.dump(data, "On17628@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@")
    if self.currLiveData.guild_league_alliance[1] == nil then
        return
    end
    self.liveDataRefresh:Fire()
end


function GuildLeagueManager:Require17629()
    -- BaseUtils.dump(id, "发送数据")
    Connection.Instance:send(17629,{})
end

function GuildLeagueManager:On17629(data)
    self.championHistory = data.guild_league_champion
    table.sort(self.championHistory, function(a, b)
        return a.season < b.season
    end)
    BaseUtils.dump(data, "On17629@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@")
    if #self.championHistory > 0 then
        -- self.model:OpenCupWindow()
        if self.model.cupwindow ~= nil then
            self.model.cupwindow:Open()
        end
    else
        NoticeManager.Instance:FloatTipsByString(TI18N("当前尚未有冠军数据"))
        return
    end
end

function GuildLeagueManager:Require17630()
    -- BaseUtils.dump(id, "发送数据")
    Connection.Instance:send(17630,{})
end

function GuildLeagueManager:On17630(data)
    -- BaseUtils.dump(data, "On17630@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@")
    self.worshed = true
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function GuildLeagueManager:Require17631()
    -- BaseUtils.dump(id, "发送数据")
    Connection.Instance:send(17631,{})
end

function GuildLeagueManager:On17631(data)
    -- BaseUtils.dump(data, "On17631@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@")
    self.worshed = data.can_worship <= 0
end
-------------------------分割线
function GuildLeagueManager:CheckOnArena()
    if RoleManager.Instance.RoleData.event ~= 32 or self.collection.running then
        return
    end

    local selfposi = Vector2.zero
    if SceneManager.Instance.sceneElementsModel.self_view ~= nil then
        local p = SceneManager.Instance.sceneElementsModel.self_view:GetCachedTransform().localPosition
        p = SceneManager.Instance.sceneModel:transport_big_pos(p.x, p.y)
        selfposi = Vector2(p.x, p.y)
    end
    for k,v in pairs(self.pointList) do
        local dis = Vector2.Distance(selfposi, v.Position)
        if dis <= 320 then
            self.model:EnterArea(v)
            return
        end
    end
    self.model:EnterArea(nil)
end

function GuildLeagueManager:InitArenaInfo()
    self.pointList = {
        {name = "A上路水晶塔", unitytype = 1, side = 1, baseid = 79571, id = 1, Position = Vector2(1885, 1647)},
        {name = "A中路水晶塔", unitytype = 1, side = 1, baseid = 79572, id = 2, Position = Vector2(1030, 2073)},
        {name = "A下路水晶塔", unitytype = 1, side = 1, baseid = 79573, id = 3, Position = Vector2(328, 2496)},
        {name = "B上路水晶塔", unitytype = 1, side = 2, baseid = 79574, id = 4, Position = Vector2(2666, 1256)},
        {name = "B中路水晶塔", unitytype = 1, side = 2, baseid = 79575, id = 5, Position = Vector2(3471, 852)},
        {name = "B下路水晶塔", unitytype = 1, side = 2, baseid = 79576, id = 6, Position = Vector2(4349, 352)},
        {name = "大炮", unitytype = 2, side = 0, baseid = 79579, id = 7, Position = Vector2(1320, 904)},
        {name = "A基地", unitytype = 3, side = 1, baseid = 79577, id = 8, Position = Vector2(303, 2092)},
        {name = "B基地", unitytype = 3, side = 2, baseid = 79578, id = 9, Position = Vector2(3731, 266)},
    }

end

function GuildLeagueManager:RoleEventChange()
    if RoleManager.Instance.RoleData.event == RoleEumn.Event.Guildleague then
        self:Require17622()
        if self.my_guild_totem ~= nil then
            self.model:OpenFightInfoPanel()
        end
        self.model:StartTowerControll()
    else
        self.model:CloseFightInfoPanel()
    end
end

function GuildLeagueManager:SceneEnter()
    -- print(string.format("self.currstatus: %s  Event: %s  loading: %s", tostring(self.currstatus), tostring(RoleManager.Instance.RoleData.event), tostring(self.loading)))
    if SceneManager.Instance:CurrentMapId() ~= 52001 then
        return
    end
    if self.loading then
        return
    end
    if self.currstatus ~= 1 and self.currstatus ~= 2 then
        return
    end
    if RoleManager.Instance.RoleData.event ~= RoleEumn.Event.Guildleague and RoleManager.Instance.RoleData.event ~= RoleEumn.Event.GuildleagueReady then
        return
    end

    if SceneManager.Instance:CurrentMapId() == 52001 and self.currstatus == 2 then
        self.model:OpenFightInfoPanel()
        self.model:StartTowerControll()
    end
    if SceneManager.Instance:CurrentMapId() == 52001 and RoleManager.Instance.RoleData.event ~= RoleEumn.Event.Guildleague then
        NoticeManager.Instance:FloatTipsByString("战场启动中。。。请稍等")
        self.loading = true
        self.freezTimer = LuaTimer.Add(0, 200, function()
            SceneManager.Instance.sceneElementsModel:Set_isovercontroll(false)
        end)
        local datapos = {}
        local num = 1
        for i,v in ipairs(DataMap.active_region[52001]) do
            local key = math.ceil(num/100)
            if datapos[key] == nil then
                datapos[key] = {}
            end
            table.insert(datapos[key], {x = v[1], y = v[2]})
            num = num + 1
        end
        for k,v in pairs(datapos) do
            LuaTimer.Add(k*250, function()
                local data = {base_id = 52001, flag = 1, pos = v}
                SceneManager.Instance:On10102(data)
            end)
        end

        LuaTimer.Add(3500,function()
            self.loading = false
            if self.freezTimer ~= nil then
                LuaTimer.Delete(self.freezTimer)
                self.freezTimer = nil
            end
            SceneManager.Instance.sceneElementsModel:Set_isovercontroll(true)
            NoticeManager.Instance:FloatTipsByString("战场启动完成")
        end)
        -- print(num)
    elseif SceneManager.Instance:CurrentMapId() == 52001 then
        SceneManager.Instance.sceneElementsModel:Set_isovercontroll(true)
        print("关闭阻挡")
        local datapos = {}
        local num = 1
        for i,v in ipairs(DataMap.active_region[52001]) do
            local key = math.ceil(num/100)
            if datapos[key] == nil then
                datapos[key] = {}
            end
            table.insert(datapos[key], {x = v[1], y = v[2]})
            num = num + 1
        end
        for k,v in pairs(datapos) do
            LuaTimer.Add(k*350, function()
                local data = {base_id = 52001, flag = 0, pos = v}
                SceneManager.Instance:On10102(data)
            end)
        end
        -- print(num)
    end
end


function GuildLeagueManager:PlayCannonAction(data)
    local unitview = nil
    local target_unitview = nil
    for k,v in pairs(SceneManager.Instance.sceneElementsModel.NpcView_List) do
        if v.data.unittype == 1 and v.data.id == 7 then
            unitview = v
        end
        if v.data.unittype == 1 and data.id == v.data.id then
            target_unitview = v
        end
    end
    if target_unitview == nil or unitview == nil or BaseUtils.isnull(unitview.gameObject) then
        return
    end
    local selfposi = Vector2.zero
    if SceneManager.Instance.sceneElementsModel.self_view ~= nil then
        local p = SceneManager.Instance.sceneElementsModel.self_view:GetCachedTransform().position
        p = SceneManager.Instance.sceneModel:transport_big_pos(p.x, p.y)
        selfposi = Vector2(p.x, p.y)
    end
    self.ShakeAction = DramaCameraShake.New()
    self.FireAction = DramaCameraMove.New()
    self.FireAction.callback = function()
        if data.id > 3 then
            unitview:play_action_name("Hit1")
        else
            unitview:play_action_name("Hit2")
        end
        local trans = unitview:GetCachedTransform()
        -- print(trans:Find("topse"))
        self.FireEffect.transform:SetParent(trans:Find("tpose/bp_paokou"))
        self.FireEffect.transform.localScale = -Vector3.one
        self.FireEffect.transform.localPosition = Vector3.zero
        self.FireEffect.transform.localRotation = Quaternion.identity
        -- self.FireEffect.transform:Rotate(Vector3(320, 0, 0))
        Utils.ChangeLayersRecursively(self.FireEffect.transform, "Model")
        self.FireEffect.gameObject:SetActive(false)
        self.FireEffect.gameObject:SetActive(true)
        LuaTimer.Add(1000, function()
            SoundManager.Instance:PlayCombatChat(self.soundcfg.fire)
            self.ShakeAction:Show({mode = 1, time = 500})
        end)
        LuaTimer.Add(2000, function()
            local delaytime = Vector2.Distance(Vector2(target_unitview.data.x, target_unitview.data.y), self.pointList[7].Position)/3
            self.HitAction:Show({x=target_unitview.data.x, y = target_unitview.data.y, time = delaytime})
        end)
        LuaTimer.Add(3000, function()
            self.FireEffect:DeleteMe()
            self.FireEffect = nil
        end)
    end
    self.HitAction = DramaCameraMove.New()
    self.HitAction.callback = function()
        local trans = target_unitview:GetCachedTransform()
        self.HitEffect.transform:SetParent(trans:Find("tpose"))
        self.HitEffect.transform.localScale = Vector3.one
        self.HitEffect.transform.localPosition = Vector3.zero
        self.HitEffect.transform.localRotation = Quaternion.identity
        self.HitEffect.transform:Rotate(Vector3(0, 180, 0))
        Utils.ChangeLayersRecursively(self.HitEffect.transform, "Model")
        self.HitEffect.gameObject:SetActive(false)
        self.HitEffect.gameObject:SetActive(true)

        SoundManager.Instance:PlayCombatChat(self.soundcfg.hit)
        self.ShakeAction:Show({mode = 1, time = 500})
        LuaTimer.Add(1000, function()
            self.BackAction:Show({x=selfposi.x, y = selfposi.y, time = 1000})
        end)
    end
    self.BackAction = DramaCameraMove.New()
    self.BackAction.callback = function()
        DramaManager.Instance.model:ShowUIHided()
        SceneManager.Instance.MainCamera.lock = false
        self.HitEffect:DeleteMe()
        self.HitEffect = nil
        MainUIManager.Instance.MainUIIconView:hidebaseicon3()
        self.HitAction:DeleteMe()
        self.BackAction:DeleteMe()
        self.FireAction:DeleteMe()
        DramaManager.Instance.model:ShowAllUnit()
        SceneManager.Instance.sceneElementsModel:teamfollow()
    end
    local hitLoaded = function()
        local delaytime = Vector2.Distance(selfposi, self.pointList[7].Position)/3
        self.FireEffect = BaseEffectView.New({ effectId = 30145, callback = function() DramaManager.Instance.model:HideMain() self.FireAction:Show({x = self.pointList[7].Position.x, y = self.pointList[7].Position.y, time = 2000}) end })
    end
    self.HitEffect = BaseEffectView.New({ effectId = 30146, callback = hitLoaded })
end

function GuildLeagueManager:IsCollecting(uniqueroleid)
    if self.currstatus ~= 2 then
        return false
    end
    if self.collectstatus[uniqueroleid] == nil then
        return false
    elseif self.collectstatus[uniqueroleid].status ~= 0 and Time.time - self.collectstatus[uniqueroleid].time < 20 then
        return true
    elseif self.collectstatus[uniqueroleid].status ~= 0 and Time.time - self.collectstatus[uniqueroleid].time >= 20 then
        self.collectstatus[uniqueroleid].status = 0
        return false
    else
        return false
    end

end

function GuildLeagueManager:CheckRed()
    local ready = false
    if self.kingTeam ~= nil and #self.kingTeam == 3 or (GuildManager.Instance.model.my_guild_data.MyPost ~= nil and GuildManager.Instance.model.my_guild_data.MyPost < 40) then
        return false
    end
    return self.guild_LeagueInfo ~= nil and self.guild_LeagueInfo.trump_enable == 1
    -- if self.guild_LeagueInfo ~= nil and self.guild_LeagueInfo.guild_league_guild ~= nil and RoleManager.Instance.RoleData.event ~= 32 then
    --     for k,v in pairs(self.guild_LeagueInfo.guild_league_guild) do
    --         if v.is_win == 0 then
    --             ready = ready or true
    --         end
    --     end
    -- end
    -- return ready
end

function GuildLeagueManager:IsKingTeam(roleData)
    for i,v in ipairs(self.kingTeam) do
        if v.rid == roleData.Rid and v.platform == roleData.PlatForm and v.zone_id == roleData.ZoneId then
            return true, v.pos
        end
    end
    return false, 1
end

-- 可竞猜未竞猜判断
function GuildLeagueManager:CheckCanGuess()
    local can = false
    for i=1, 3 do
        if (self.kingGuildData.phasedata[i] ~= nil and #self.kingGuildData.phasedata[i] ~= 0) and
            not ((self.guessData ~= nil and self.guessData[i+4] ~= nil and next(self.guessData[i+4]) ~= nil) or
                (self.kingGuildData.phasedata[i+1] ~= nil and #self.kingGuildData.phasedata[i+1] ~= 0 and self.kingGuildData.phasedata[i+1][1].is_win ~= 0)) then
            if can == false then
                can = true
            end
        end
    end
    return can and self.currstatus == 0
end

function GuildLeagueManager:GetRate(guild_id, platform, zone_id)
    local key = string.format("A%s_%s_%s", guild_id, platform, zone_id)
    -- BaseUtils.dump(self.voteData, "投票数据")
    if self.voteData[key] ~= nil then
        return self.voteData[key]
    else
        return 1
    end
end

--根据等级得到组别
function GuildLeagueManager:GetGroupId(lev)
    local group_id = 1
    if lev < 120 then group_id = 2 end
    if lev < 101 then group_id = 3 end
    if lev < 90 then group_id = 4 end
    return group_id
end

--队伍成员是否为同一组
function GuildLeagueManager:GetTeamSameGroup()
    local teamlist = TeamManager.Instance.memberTab
    if teamlist == nil then return true end
    local lastid = nil
    for uniqueid,member in ipairs(teamlist) do
        local id = self:GetGroupId(member.lev)
        if lastid == nil then 
            lastid = id 
        elseif lastid ~= id then
            return false
        end
    end
    return true
end

