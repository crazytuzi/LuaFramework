---
--- Author: R2D2
--- Date: 2019-02-18 09:57:18
---
FactionBattleModel = FactionBattleModel or class("FactionBattleModel", BaseModel)
local FactionBattleModel = FactionBattleModel

function FactionBattleModel:ctor()
    FactionBattleModel.Instance = self
    self:Init()
    --self:InitTestData()
end

--- 初始化或重置
function FactionBattleModel:Reset()

    if (self.CountdownTip) then
        self.CountdownTip:destroy()
        self.CountdownTip = nil
    end
end

--function FactionBattleModel:InitTestData()
----    self.WinnerInfo = {}
----    self.WinnerInfo.guild = "8800000200000000001"
----    self.WinnerInfo.victory = 5
----    self.WinnerInfo.fetch = true
----    self.WinnerInfo.v_allot = false
----
--    self.RankList = {}
--
--    for i = 1, 20 do
--        local t = {}
--        t.rank = i
--        t.role_id = i*100
--        t.role_name = "name" .. i
--        t.gname = "g_name" .. i
--        t.kill = math.random(20)
--        t.occupy =math.random(100)
--        t.contrib = math.random(200)
--
--        table.insert(self.RankList, t)
--    end
----
--end
function FactionBattleModel:GetInstance()
    if FactionBattleModel.Instance == nil then
        FactionBattleModel()
    end
    return FactionBattleModel.Instance
end

function FactionBattleModel:Init()
    self.Activity = {}

    for _, v in pairs(Config.db_activity) do
        if (v.group == 102) then
            table.insert(self.Activity, v)
            --self.Activity[i] = v
        end
    end

    table.sort(self.Activity, function(a, b)
        return a.id < b.id
    end)
end

function FactionBattleModel:GetJobTitleInfoById(id)
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

function FactionBattleModel:SetActivityInfo(isOpen, activityId, startTime, endTime)
    self.ActivityOpen = isOpen
    self.ActivityId = activityId
    self.StartTime = startTime
    self.endTime = endTime

    ---是否在等下一场战斗
    ---如果刚刚结速的ID不是最后一场的ID，则认为true
    self.isWaitNextActivity = false
	
	if not self.ActivityOpen then
		local lastActivity = self.Activity[#self.Activity]
		if self.ActivityId ~= lastActivity.id then
			self.isWaitNextActivity = true
		end
    end
    
    self:CheckAnyPoint()
end

---终结称霸次数
function FactionBattleModel:GetTerminatorTimes()
    if (self.WinnerInfo) then
        if (self.WinnerInfo.breakup < 2) then
            return self.WinnerInfo.victory > 1 and self.WinnerInfo.victory or 2
        else
            return self.WinnerInfo.breakup
        end
    else
        return 2
    end
end

---终结称霸奖励
function FactionBattleModel:GetTerminatorReward(times)
    for _, v in pairs(Config.db_guildwar_victory_reward) do
        if (v.times == times) then
            return v
        end
    end
    return nil
end

-----连胜奖励
function FactionBattleModel:GetWinningStreakReward()
    local t = {}
    for _, v in pairs(Config.db_guildwar_victory_reward) do
        table.insert(t, v)
    end

    table.sort(t, function(a, b)
        return a.times < b.times
    end)

    return t
end

---公会战开放时间TIP
function FactionBattleModel:GetOpenInfo()
    if (self.Activity) then
        local w = 0
        local t = {}
        for _, v in ipairs(self.Activity) do
            w = v.days
            table.insert(t, v.start_time)
        end
        return w, t
    else
        return nil
    end
end

---在对战信息中查找公会名字
function FactionBattleModel:GetGuildNameInField(guildId)
    for _, v in pairs(self.FieldInfo) do
        for _, w in pairs(v) do
            for _, u in pairs(w.guilds) do
                if (u.id == guildId) then
                    return u.name
                end
            end
        end    
    end

    return ""
end

function FactionBattleModel:SetRankData(tab)
    self.IsWin = tab.is_win
    self.RankList = tab.ranklist
    self.MyRank = tab.my_rank
end

function FactionBattleModel:GetRank(roleId)
    local rank = 0
    if (self.RankList) then
        for _, v in ipairs(self.RankList) do
            if v.role_id == roleId then
                return v.rank
            end
        end
    end
    return rank
end

---分配了终结奖励
function FactionBattleModel:AssignedTerminatorAward()
    if (self.WinnerInfo) then
        self.WinnerInfo.b_allot = true
    end
    self:CheckAnyPoint()
end

---分配了连胜奖励
function FactionBattleModel:AssignedWinAward()
    if (self.WinnerInfo) then
        self.WinnerInfo.v_allot = true
    end
    self:CheckAnyPoint()
end

---领取了会员奖励
function FactionBattleModel:MemberAwardReceived()
    if (self.WinnerInfo) then
        self.WinnerInfo.fetch = true
    end
    self:CheckAnyPoint()
end

---赛区信息
function FactionBattleModel:SetFieldInfo(tab)

    if (tab.role and tab.role ~= "0") then
        self.Dominator = tab.role
    else
        self.Dominator = nil
    end

    self.FieldInfo = {}
    local t = tab.fields

    for _, v in pairs(t) do
        self.FieldInfo[v.id] = v.vs
    end
end

---胜利方（主宰公会）信息
function FactionBattleModel:SetWinnerInfo(tab)
    self.WinnerInfo = tab

    self:CheckAnyPoint()
end

---战场信息（服务端推送）
function FactionBattleModel:SetBattleInfo(tab)
    self.BattleInfo = tab.battle
    if (self.CrystalInfo) then
        self:UpdateCrystal()
    end
end

---获取出生点信息
function FactionBattleModel:GetSpawnList()

    if (self.SpawnList and #self.SpawnList > 0) then
        return self.SpawnList
    end

    if (self.BattleInfo) then
        self.SpawnList = {}
        for i, v in pairs(self.BattleInfo) do
            local t = {}
            t.uid = enum.ACTOR_TYPE.ACTOR_TYPE_BORN * 100 + i
            t.type = enum.ACTOR_TYPE.ACTOR_TYPE_BORN
            t.state = i
            t.coord = {}
            t.coord.x = v.coord.x
            t.coord.y = v.coord.y

            table.insert(self.SpawnList, t)
        end

        return self.SpawnList
    else
        return nil
    end
end

---水晶是否是当前角色所在方
function FactionBattleModel:IsSelfSideCrystal(crystalId)
    return self:MainRoleSide() == self:GetCrystalSide(crystalId)
end

---自已所在方
function FactionBattleModel:MainRoleSide()
    local mainRole = RoleInfoModel:GetInstance():GetMainRoleData()
    return mainRole.group
end

---水晶归属方（0未占,1=蓝,2=红）
function FactionBattleModel:GetCrystalSide(crystalId)

    for k, v in pairs(self.CrystalInfo) do
        if (k == crystalId) then
            return v
        end
    end

    return -1
end

function FactionBattleModel:UpdateCrystal()

    for i, _ in pairs(self.CrystalInfo) do
        self.CrystalInfo[i] = 0
    end

    for i = 1, 2 do
        local tab = self.BattleInfo[i].crysts
        for _, v in pairs(tab) do
			local index = self.CrystalList[v]
            self.CrystalInfo[index] = i
        end
    end
end

function FactionBattleModel:GetCrystalState(uid)
	
	local index = self.CrystalList[uid]
	return  self.CrystalInfo[index] or 0
end

function FactionBattleModel:GetBattleNum()
    if (self.BattleInfo) then
        return self.BattleInfo[1].role, self.BattleInfo[1].score, self.BattleInfo[2].role, self.BattleInfo[2].score
    else
        return 0, 0, 0, 0
    end
end

function FactionBattleModel:GetFieldGuildName(typeId)
    if (self.FieldInfo and self.FieldInfo[typeId]) then
        local tab = self.FieldInfo[typeId]
        local t = {}

        for i = 1, 2 do
            if (tab[i]) then
                local tab2 = tab[i].guilds
                for j = 1, 2 do
                    if (tab2[j]) then
                        table.insert(t, tab2[j].name)
                    else
                        table.insert(t, "No guild yet")
                    end
                end
            else
                table.insert(t, "No guild yet")
                table.insert(t, "No guild yet")
            end
        end
        return unpack(t)
    else
        return "No guild yet", "No guild yet", "No guild yet", "No guild yet"
    end
end

function FactionBattleModel:GetFieldWinSign(typeId)
    if (self.FieldInfo and self.FieldInfo[typeId]) then
        local tab = self.FieldInfo[typeId]
        local t = {}

        for i = 1, 2 do
            t[i] = 0
            if (tab[i] and tab[i].winner ~= "0") then
                local tab2 = tab[i].guilds
                for j = 1, 2 do
                    if (tab2[j] and tab2[j].id == tab[i].winner) then
                        t[i] = j
                    end
                end
            end
        end
        return unpack(t)
    else
        return 0, 0
    end
end

--function FactionBattleModel:GetFieldWinSign(typeId)
--    if(self.FieldInfo and self.FieldInfo[typeId]) then
--        local tab = self.FieldInfo[typeId]
--        local t ={ShowWin = false}
--        for i, v in ipairs(tab) do
--            for m, n in ipairs(v.guilds) do
--                if(v.winner == n.id) then
--                    t["ShowWin"] = true
--                    t[i] = m
--                end
--            end
--        end
--        return t
--    else
--        return nil
--    end
--end
function FactionBattleModel:GetFieldData(typeId)
    if (self.FieldInfo and self.FieldInfo[typeId]) then
        return self.FieldInfo[typeId]
    end
end

function FactionBattleModel:SetCrystalInfo(scene_id)
    self.CrystalInfo = {}
	self.CrystalList = {};	
	
    local monster_list = SceneConfigManager:GetInstance():GetMonsterList(scene_id)
    local function sort(a, b)
        return a.id < b.id
    end
    table.sort(monster_list, sort)

    for k, v in pairs(monster_list) do
        --local t = {}
        --t["id"] = v.id
        --t["owner"] = 0
		local id = v.id
		self.CrystalList[id] = k
		self.CrystalList[id + 10] = k
		self.CrystalList[id + 20] = k
        self.CrystalInfo[k] = 0
    end
end

---是否获胜公会成员
function FactionBattleModel:IsWinGuild()
    local guild = RoleInfoModel:GetInstance():GetRoleValue("guild")
    local winGuild = self.WinnerInfo.guild
    return guild == winGuild
end

---是否有任意红点
function FactionBattleModel:CheckAnyPoint()
    local hadAnyPoint = self.ActivityOpen or self:HadWinningStreakAward() or self:HadTerminatorAward() or self:HadGuildPrize()
    --GlobalEvent:Brocast(MainEvent.ChangeRedDot,"guildTemple",self:HadWinningStreakAward() or self:HadTerminatorAward() or self:HadGuildPrize())
    GlobalEvent:Brocast( FactionEvent.Faction_GuildWarRedPointEvent, hadAnyPoint)
end

-- ---是否有可分配的奖品
-- function FactionBattleModel:HadGuildAwardAssign()
--     local isPresident =  FactionModel:GetInstance():GetIsPresidentSelf()
--     if isPresident then
--         return  (not self.WinnerInfo.b_allot) or  (not self.WinnerInfo.)
--     else
--         return flase
--     end
-- end

---是否有连胜奖励
function FactionBattleModel:HadWinningStreakAward()
    local isPresident =  FactionModel:GetInstance():GetIsPresidentSelf()
    if not self.WinnerInfo then
        return  false
    end
	if  self.WinnerInfo.guild == "0" then
		return  false
	end
	
    if isPresident then
        local gId = RoleInfoModel.GetInstance():GetMainRoleData().guild
        if (gId == self.WinnerInfo.guild) then
            if not self.WinnerInfo.v_allot and self.WinnerInfo.victory > 1  then
                return true
            end
        end
    end
    return false
end

---是否有终结奖励
function FactionBattleModel:HadTerminatorAward()
    local isPresident =  FactionModel:GetInstance():GetIsPresidentSelf()
    if not self.WinnerInfo then
        return  false
    end
	if  self.WinnerInfo.guild == "0" then
		return  false
	end
	
    if isPresident and self:IsWinGuild() and self.WinnerInfo.breakup > 1 and not self.WinnerInfo.b_allot then
        return  true
    else
        return false
    end
end

---是否有公会每日奖励
function FactionBattleModel:HadGuildPrize()
    if not self.WinnerInfo then
        return  false
    end
	if  self.WinnerInfo.guild == "0" then
		return  false
	end
	
    if(self:IsWinGuild()) then
        return (not self.WinnerInfo.fetch)
    end

    return false
end