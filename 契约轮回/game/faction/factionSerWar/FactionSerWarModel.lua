---
--- Created by  Administrator
--- DateTime: 2020/5/14 14:09
---
FactionSerWarModel = FactionSerWarModel or class("FactionSerWarModel", BaseModel)
local FactionSerWarModel = FactionSerWarModel

FactionSerWarModel.helpTex =
[[
Basic Rules:
1.After distributed in every month, the guilds whose CP rank top 2 in each server, are qualified to join the match and get the default ranking.
2.Those servers whose release days are less than 20, can not join cross-server guild war.
3.Guild War will not be available if there is a week between 2 months. Eg. 25th June to 1st July is a week between 2 months.
4.Reservation starts at 3:00 Sat to 3:00 Sun(UTC+8). Spend certain guild points to reserve while you can spend more pts to reserve the other opponents.
5.Challenge the stronger opponents and can get better rewards.
6.When you win the war you can get the reservation points back while you will loose it when you loose the game.
7.You need to optimize your opponents to get the maximum points. The monthly ranking rewards are relative to the points.
8. The eligibility for the list will be recalculated on every Thursday. If unfortunately you dropped, the points will be cleared. By default, once you return to the list you can get 1000 points.
Game Rules:
1.Guild War starts at 20:00-20:35(UTC+8) at weekend. There are 2 rounds and each round has 2 phases.
  Crystal War: Attackers need to destroy one of two crystals to enter next phase.
  Tip: Crystal can be repaired by defenders, so you need to defeat the enemies in time.
Next Phase:
Destroy the Statue
Destroy the statue of the enemies and you can win the game.

Rewards:
1.The opponent gets the higher points and you can get better rewards.
2.The winner can get ultra gears, guild points. The looser can only get seldom guild points;     Defender won't get guild points
3.Guild mates can get abundant exp, pet gear materials and guild contribution.
4.Every last week in each month(Complete Week not between 2 months), it will settle down the guild ranking after round 2 coming to an end. The rewards will be sent to guild leader.
]]



function FactionSerWarModel:ctor()
    FactionSerWarModel.Instance = self
    self:Reset()
end

--- 初始化或重置
function FactionSerWarModel:Reset()
    self.period = 1
    self.booktimes = 1
    self.my_scroe = 0
    self.nextTime = 0
    self.my_book = 0 --我预约的公会
    self.guildsInfo = {}
    self.ranking = {}
    self.winRewardTab = {}
    self.rankRewardTab = {}
    self.reds = {}
    self.isOpenHelp = false
    self.my_rank = 0
end

function FactionSerWarModel:GetInstance()
    if FactionSerWarModel.Instance == nil then
        FactionSerWarModel()
    end
    return FactionSerWarModel.Instance
end

function FactionSerWarModel:SetPeriod(data)
    self.period = data.period
    self.nextTime = data.next
end

function FactionSerWarModel:CheckIsOpen()
    local openLv = 300
    local openDay = 20
    local rolelv = RoleInfoModel:GetInstance():GetMainRoleLevel()
    if rolelv >= openLv and LoginModel:GetInstance():GetOpenTime() >= openDay then
        return
    else
        if rolelv < openLv then
            return FactionSerWarModel.desTab.noOpenLV
        end
    end

    return  FactionSerWarModel.desTab.noOpenTime

end

function FactionSerWarModel:DealGuildsInfo(guilds)
    self.guildsInfo = {}
    for i, v in pairs(guilds) do
        --if not self.guildsInfo[v.id] then
        --    self.guildsInfo[v.id] = {}
        --end
        --self.guildsInfo[v.id] =  v
        table.insert(self.guildsInfo,v)
    end
    table.sort(self.guildsInfo, function(a,b)
            return a.score < b.score
    end)
end

--是否是参赛工会
function FactionSerWarModel:IsJoinCGW()
    if  table.isempty(self.guildsInfo) then
       return false
    end

    local myGuildId = RoleInfoModel.GetInstance():GetMainRoleData().guild
    for i = 1, #self.guildsInfo do
        if self.guildsInfo[i].id == myGuildId  then
            return true
        end
    end
    return false
end

function FactionSerWarModel:GetMyGuildRank()
    local myGuildId = RoleInfoModel.GetInstance():GetMainRoleData().guild
    for i = 1, #self.guildsInfo do
        if self.guildsInfo[i].id == myGuildId  then
            return self.guildsInfo[i].rank
        end
    end
    return 0
end

function FactionSerWarModel:GetGuildName(guidId)
    local myGuildId = RoleInfoModel.GetInstance():GetMainRoleData().guild
    if guidId == myGuildId then
        return RoleInfoModel.GetInstance():GetMainRoleData().gname
    end
    for i = 1, #self.guildsInfo do
        if self.guildsInfo[i].id == guidId  then
            return self.guildsInfo[i].name
        end
    end
    return 0
end


function FactionSerWarModel:SetGuildsIsBook(guild_id)
    --if not self.guildsInfo[guild_id] then
    --    logError("列表中没有ID",guild_id)
    --    return
    --end
    --self.guildsInfo[guild_id].book = 1
    for i = 1, #self.guildsInfo do
        if self.guildsInfo[i].id == guild_id then
            self.guildsInfo[i].book = RoleInfoModel.GetInstance():GetMainRoleData().guild
            self.guildsInfo[i].book_times = self.guildsInfo[i].book_times + 1
            self.guildsInfo[i].book_time = os.time()

        end
    end
end

function FactionSerWarModel:IsBook()
    local myGuildId = RoleInfoModel.GetInstance():GetMainRoleData().guild
    for i = 1, #self.guildsInfo do
        if self.guildsInfo[i].book1 == myGuildId then
            return true
        end
    end
    return false
end

--times 第几次被预约
function FactionSerWarModel:GetCostScore(times)
    --self.booktimes
    local cfg = Config.db_game["cgw_book_score"]
    local numTab = String2Table(cfg.val)[1]
    for i = 1, #numTab do
        if times == numTab[i][1] then
            return numTab[i][2]
        end
    end
    return 0
end

--可预约次数
function FactionSerWarModel:GetBookTimes()
    local cfg = Config.db_game["cgw_book_times1"]
    local numTab = String2Table(cfg.val)[1]
    return numTab
end

--可被预约次数
function FactionSerWarModel:GetBookTimes2()
    local cfg = Config.db_game["cgw_book_times2"]
    local numTab = String2Table(cfg.val)[1]
    return numTab
end


function FactionSerWarModel:GetCreepAddress(id)
    local cfg = Config.db_game["cgw_creeps"]
    local numTab = String2Table(cfg.val)[1]
    --self.touziNum = 0
    for i = 1, #numTab do
        if id == numTab[i][1] then
            return numTab[i][2],numTab[i][3]
        end
    end
    return 0
end

function FactionSerWarModel:GetJobTitleInfoById(id)
    local config = Config.db_jobtitle[id]
    if (config) then
        local r, g, b, a = HtmlColorStringToColor(config.color)
        local tab = {}
        tab.r = r
        tab.g = g
        tab.b = b
        tab.a = a
        tab.n = config.name
        return tab
    else
        return nil
    end
end

function FactionSerWarModel:GetRankInfo(guidId)
    for i = 1, #self.ranking do
        if self.ranking[i].id == guidId then
            return self.ranking[i]
        end
    end
    return nil
end


function FactionSerWarModel:GetRewardCfg(rank)
    --local cfg = Config.db_game["cgw_win_reward"]
    --local numTab = String2Table(cfg.val)[1]
    --return numTab
    if not table.isempty(self.winRewardTab[rank]) then
        return self.winRewardTab[rank]
    end

    if not self.winRewardTab[rank] then
        self.winRewardTab[rank] = {}
    end
    local lv = RoleInfoModel:GetInstance().world_level
    local cfg = Config.db_cgw_weekly_reward
    --self.winRewardTab
    for i = 1, #cfg do
        if (cfg[i].min_lv <= lv and cfg[i].max_lv >= lv)  then
            if  (rank >= cfg[i].min_rank and rank <= cfg[i].max_rank) then
                self.winRewardTab[rank] = cfg[i]
            end
            --table.insert(self.winRewardTab,cfg[i])
        end
    end
    return  self.winRewardTab[rank]

end

function FactionSerWarModel:GetRankReward(rank)
    --local cfg = Config.db_game["cgw_lose_reward"]
    --local numTab = String2Table(cfg.val)[1]
    --return numTab
    if not table.isempty(self.rankRewardTab[rank]) then
        return self.rankRewardTab[rank]
    end

    if not self.rankRewardTab[rank] then
        self.rankRewardTab[rank] = {}
    end
    local lv = RoleInfoModel:GetInstance().world_level
    local cfg = Config.db_cgw_monthly_reward
    --self.winRewardTab
    for i = 1, #cfg do
        if (cfg[i].min_lv <= lv and cfg[i].max_lv >= lv)  then
            if  (rank >= cfg[i].min_rank and rank <= cfg[i].max_rank) then
                self.rankRewardTab[rank] = cfg[i]
            end
            --table.insert(self.winRewardTab,cfg[i])
        end
    end
    return  self.rankRewardTab[rank]
end




function FactionSerWarModel:IsFactionSerMap(sceneId)
    sceneId = sceneId or SceneManager:GetInstance():GetSceneId()
    local config = Config.db_scene[sceneId]
    if not config then
        --   print2("不存在场景配置" .. tostring(sceneId));
        return false
    end
    if config.type == enum.SCENE_TYPE.SCENE_TYPE_ACT and config.stype == enum.SCENE_STYPE.SCENE_STYPE_CROSS_GUILDWAR then
        return true
    end

    return false
end

function FactionSerWarModel:CheckRedPoint()
    self.reds[1] = false  --活动开始红点
    self.reds[2] = false    --会长预约红点

    local myPost = FactionModel:GetInstance():SetSelfCadre()
    if myPost == enum.GUILD_POST.GUILD_POST_CHIEF  then
        local times = self:GetBookTimes() --预约次数
        if   self.booktimes < times  then
            self.reds[2] = true
        end
    end
    if  ActivityModel:GetInstance():GetActivity(12003) and self.my_rank ~= 0 then
        self.reds[1] = true
    end

    local isRed = false
    for i, v in pairs(self.reds) do
        if v == true then
            isRed = true
        end
    end
    logError(self.reds[2] )
    if self.reds[1]  then
        GlobalEvent:Brocast(MainEvent.ChangeRedDot, "crossGuildWar", true)
    end
    if self.reds[2]  then
        GlobalEvent:Brocast(MainEvent.ChangeRedDot, "crossResGuildWar", true)
    end
    GlobalEvent:Brocast(FactionSerWarEvent.FactionSerWarRed,isRed)
end

function FactionSerWarModel:GetSerWarRed()
    local isRed = false
    for i, v in pairs(self.reds) do
        if v == true then
            isRed = true
        end
    end
    return isRed
end

FactionSerWarModel.desTab =
{
    Name = "Cross Server Guild War",
    Tips = "Tip",
    ok = "Confirm",
    center = "Cancel",
    open = "Cross Server Guild War launches.Are you sure to enter the scene?",
    appDes = "The guild you chose has been reserved %s times by other guilds. Spend %s pts to date it?",
    noScore = "Insufficient Pts",
    addSuc = "%s<color=#3ab60e>%s</color> spent %s pts to reserve",
    noRank = "Not ranked",
    rank = "No.%s",
    noOpenLV = "Lvl not reached",
    noOpenTime = "Cross Server Guild War unlocks on date 15th of new server",
    seasonEnd = "%s later season ends",
    month = "Month",
    day = "Day",
    goText = "Attack",
    goText2 = "Defend",
    append = "The guild has been booked full",

}
