---
--- Created by  Administrator
--- DateTime: 2019/11/18 15:37
---
CompeteModel = CompeteModel or class("CompeteModel", BaseModel)
local CompeteModel = CompeteModel

--CompeteModel.leftPos = {[101] = true,[102] = true,[105] = true,[106] = true,[201] = true,[203] = true,[301] = true}
--CompeteModel.rightPos = {[103] = true,[104] = true,[107] = true,[108] = true,[202] = true,[204] = true,[302] = true}
--CompeteModel.midPos = {[401] = true}


CompeteModel.Pos = {
    [101] = 1,[102] = 1,[105] = 1,[106] = 1,[201] = 1,[203] = 1,[301] = 1,
    [103] = 2,[104] = 2,[107] = 2,[108] = 2,[202] = 2,[204] = 2,[302] = 2,
    [401] = 3
}
CompeteModel.Round = {
    [201] = {101,102},[203] = {105,106},[301] = {201,203},
    [202] = {103,104},[204] = {107,108},[302] = {202,204},
    [401] = {301,302}
}
function CompeteModel:ctor()
    CompeteModel.Instance = self
    self:Reset()
end

--- 初始化或重置
function CompeteModel:Reset()
    self.curPeriod = 0 --当前阶段
    self.competeGroup = {}  --分组
    self.isCross = false -- 是否跨服
    self.isEnroll = false --是否报名
    self.powerRank = 0 --当前战力排行
    self.actId = 0
    self.isOpenCopetePanel = false
    self.isOpenBattlePanel = false
    self.isFirstOpenEroll = true
    self.redPoints = {}
    self.roleData = {}
end

function CompeteModel:GetInstance()
    if CompeteModel.Instance == nil then
        CompeteModel()
    end
    return CompeteModel.Instance
end

function CompeteModel:DealPanelInfo(data)
    self.curPeriod = data.cur_period
    self.isEnroll = data.is_enroll
    self.actId = data.act_id
    self.powerRank = data.power_rank
    local cfg = Config.db_activity[self.actId]
    if not cfg then
        logError("actId :"..self.actId)
        return
    end
    self.isCross = cfg.type == 2
    --if self.isOpenCopetePanel == false and self.curPeriod == enum.COMPETE_PERIOD.COMPETE_PERIOD_ENROLL then --报名阶段
    --    GlobalEvent:Brocast(CompeteEvent.OpenCompeteNoticePanel)
    --end


end

function CompeteModel:DealGruop(groups,type)
    if not self.competeGroup[type] then
        self.competeGroup[type] = {}
    end
    self.competeGroup[type] = groups
end

function CompeteModel:GetRoleGroupData(type,id)
    if  not self.competeGroup[type] then
        return nil
    end
    for i, v in pairs(self.competeGroup[type]) do
        if v.id == id  then
            return v
        end
    end
    return nil
end

function CompeteModel:SetGuessData(type,id,roleId)
    for i, v in pairs(self.competeGroup[type]) do
        if v.id == id  then
            v.guess = roleId
        end
    end
end
--报名消耗
function CompeteModel:GetEnterCost()
    local cross = 1
    if self.isCross then
        cross = 0
    end
    local cfg = Config.db_compete_misc["enroll_cost".."@"..cross]
    local tab = String2Table(cfg.val)
    if not table.isempty(tab) then
        return  tab[1][1]
    end
    return nil
   -- dump(tab)
end

function CompeteModel:GetBuffs()
    local cross = 1
    if self.isCross then
        cross = 0
    end
    local cfg = Config.db_compete_misc["battle_buffs".."@"..cross]
    local tab = String2Table(cfg.val)
    if not table.isempty(tab) then
        return  tab[1]
    end
    return nil
    -- dump(tab)
end

--初始命数
function CompeteModel:GetMingNum()
    local cross = 1
    if self.isCross then
        cross = 0
    end
    local cfg = Config.db_compete_misc["battle_life".."@"..cross]
    local tab = String2Table(cfg.val)
    if not table.isempty(tab) then
        return  tab[1]
    end
    return nil
    -- dump(tab)
end

--获取报名条件
function CompeteModel:GetEnrollCondition()
    local cross = 1
    if self.isCross then
        cross = 0
    end
    local cfg = Config.db_compete_misc["enroll_reqs".."@"..cross]
    local tab = String2Table(cfg.val)
    if not table.isempty(tab) then
        return  tab[1]
    end
    return nil
    -- dump(tab)
end



--1 天  2地
function CompeteModel:GetRewards(type)
    local tab = {}
    local cfg = Config.db_compete_rank_reward
    local index = 16
    if type == 2 then
        index = 32
    end
    for i = 1, #cfg do
        if type == 1 then
            if  cfg[i].max_rank <= 16 then
                table.insert(tab,cfg[i])
            end
        else
            if  cfg[i].max_rank > 16 and  cfg[i].max_rank< 32 then
                table.insert(tab,cfg[i])
            end
        end

    end
    return tab
end
--小组赛奖励
function CompeteModel:GetLittleRewards()
    local tab = {}
    local cross = 1
    if self.isCross then
        cross = 0
    end
    local miscCfg1 = Config.db_compete_misc["rank_reward1".."@"..cross]
    local miscCfg2 = Config.db_compete_misc["rank_reward2".."@"..cross]
    table.insert(tab,miscCfg1)
    table.insert(tab,miscCfg2)
    local cfg = Config.db_compete_battle_reward
    for i = 1, #cfg do
        if cfg[i].islocal == cross and cfg[i].type == 1  and cfg[i].round <= 2 then
            table.insert(tab,cfg[i])
        end
    end
    return tab
end

--3 天  2地
function CompeteModel:GetTianWinReward(type)
    local tab = {}
    local cross = 1
    if self.isCross then
        cross = 0
    end
    local cfg = Config.db_compete_battle_reward
    for i = 1, #cfg do
        if cfg[i].islocal == cross and cfg[i].type == type then
            table.insert(tab,cfg[i])
        end
    end
    table.sort(tab, function (a,b)
        return a.round > b.round
    end)
    return tab
end

function CompeteModel:GetCrossReward(islocal)
    local tab = {}
    local cfg = Config.db_compete_rank_reward
    for i = 1, #cfg do
        if cfg[i].islocal == islocal then
            table.insert(tab,cfg[i])
        end
    end
    return tab
end

--商店
function CompeteModel:GetShopItems()
    local id = 100
    if self.isCross then
        id = 101
    end
    local cfg = Config.db_mall
    local items = {}
    local worldLv = RoleInfoModel:GetInstance().world_level
    for i, v in pairs(cfg) do
        local type = String2Table(v.mall_type)[1]
        if type == id and worldLv >= v.limit_level then
            table.insert(items, v)
        end
    end
    return items
end


function CompeteModel:GetMingBuff(buffs)
    for i, v in pairs(buffs) do
        if v.id == 304100004 then
            return v
        end
    end
    return nil
end

function CompeteModel:IsCompeteReady(sceneId)
    sceneId = sceneId or SceneManager:GetInstance():GetSceneId()
    local config = Config.db_scene[sceneId]
    if not config then
        --   print2("不存在场景配置" .. tostring(sceneId));
        return false
    end
    if config.type == enum.SCENE_TYPE.SCENE_TYPE_ACT and config.stype == enum.SCENE_STYPE.SCENE_STYPE_COMPETE_PREPARE then
        return true
    end

    return false
end

function CompeteModel:IsCompeteDungeon(sceneId)
    sceneId = sceneId or SceneManager:GetInstance():GetSceneId()
    local config = Config.db_scene[sceneId]
    if not config then
        --   print2("不存在场景配置" .. tostring(sceneId));
        return false
    end
    if config.type == enum.SCENE_TYPE.SCENE_TYPE_ACT and config.stype == enum.SCENE_STYPE.SCENE_STYPE_COMPETE_BATTLE then
        return true
    end

    return false
end

--报名图标的红点
function CompeteModel:CheckEnrollRedPoint()
    local actId = 11011
    if self.isCross then
        actId = 11014
    end
    GlobalEvent:Brocast(MainEvent.ChangeRedDot,"compete",not self.isEnroll,actId)
    --if not self.isFirstOpenEroll then
    --    GlobalEvent:Brocast(MainEvent.ChangeRedDot,"compete",false,actId)
    --else
    --    if not self.isEnroll then
    --        GlobalEvent:Brocast(MainEvent.ChangeRedDot,"compete",self.isEnroll,actId)
    --    end
    --end

    --self.isFirstOpenEroll
   --[[ logError("报名红点")
    if self.isEnroll then  --已经报名了
        GlobalEvent:Brocast(MainEvent.ChangeRedDot,"compete",false)
    else
        --判断是否达到报名条件
        local role = RoleInfoModel:GetInstance():GetMainRoleData()
        local conditions = {}
        local tab = self:GetEnrollCondition()
        local costTab = self:GetEnterCost()
        if costTab then
            conditions[1] = false
            local num =  BagModel:GetInstance():GetItemNumByItemID(costTab[1])
            if num >= costTab[2] then --满足
                conditions[1] = true
            end
        end
        for i = 1, #tab do
            conditions[i+1] = false
            if tab[i][1] == "wake" then --觉醒
                local wake = role.wake
                if wake >= tab[i][2] then
                    conditions[i+1] = true
                end
            elseif tab[i][1] == "level" then --等級
                local level = role.level
                if level >= tab[i][2] then
                    conditions[i+1] = true
                end
            elseif tab[i][1] == "rank" then --排名
                local rank = self.powerRank
                if rank ~= 0 then
                    if rank <= tab[i][2] then
                        conditions[i+1] = true
                    end
                end
            end
        end
        local isRed = true
        for i, v in pairs(conditions) do
            if v == false then
                isRed = false
            end
        end
        local actId = 11011
        if self.isCross then
            actId = 11014
        end
        GlobalEvent:Brocast(MainEvent.ChangeRedDot,"compete",isRed,11011)
    end
    --GlobalEvent:Brocast(MainEvent.ChangeRedDot,"compete",true)
    --OperateModel:GetInstance():UpdateIconReddot(id,isRed)]]--
end

function CompeteModel:CheckRedPoint()
    self.redPoints[1] = false
    self.redPoints[2] = false
    if self.curPeriod ~= enum.COMPETE_PERIOD.COMPETE_PERIOD_TRUCE and self.curPeriod ~= enum.COMPETE_PERIOD.COMPETE_PERIOD_ENROLL  then
        if self.isEnroll then --已经报名
            self.redPoints[1] = true
        end
    end
    if self.curPeriod == enum.COMPETE_PERIOD.COMPETE_PERIOD_RANK then
        self.redPoints[2] = true
    end
    local isRed = false
    for i, v in pairs(self.redPoints) do
        if v == true then
             isRed = true
            break
        end
    end
    GlobalEvent:Brocast(CompeteEvent.CheckRedPoint,isRed)
end

function CompeteModel:isRedPoint()
    for i, v in pairs(self.redPoints) do
        if v == true then
            return true
        end
    end
    return false
end

