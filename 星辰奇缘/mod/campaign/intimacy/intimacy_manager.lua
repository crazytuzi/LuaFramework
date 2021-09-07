-- region *.lua
-- Date jia 2017-5-16
-- 此文件由[BabeLua]插件自动生成RankRewardTmps
-- 亲密度排行榜manager
-- endregion
IntimacyManager = IntimacyManager or BaseClass(BaseManager)
function IntimacyManager:__init()
    if IntimacyManager.Instance ~= nil then
        Log.Error("不能重复实例化")
        return
    end
    IntimacyManager.Instance = self
    self.RankID = CampaignEumn.CampaignRankType.Intimacy
    self.RankRewardTmps = nil
    self.PersonalTmps = nil
    self.RankList = nil
    self.MyRankData = nil
    self.RankRewardList = nil
    self.rankPanel = nil
    self.sortFun = function(a, b)
        return a.rank < b.rank
    end
    self:InitHandler()
    self.onUpdateIntimacy = EventLib.New()
end

function IntimacyManager:ClearData()
    self.RankList = nil
    self.MyRankData = nil
    self.RankRewardList = nil
end

function IntimacyManager:__delete(args)
    --IntimacyManager.Instance = nil
    if self.model ~= nil then
        self.model:DeleteMe()
    end
    self.model = nil
    self:RemoveNetHandler(17858, self.tmp17858)
    self:RemoveNetHandler(17859, self.tmp17859)
    self:RemoveNetHandler(17860, self.tmp17860)
    self:RemoveNetHandler(17861, self.tmp17861)
end

function IntimacyManager:InitHandler()
    self.tmp17858 = self:AddNetHandler(17858, self.On17858)
    self.tmp17859 = self:AddNetHandler(17859, self.On17859)
    self.tmp17860 = self:AddNetHandler(17860, self.On17860)
    self.tmp17861 = self:AddNetHandler(17861, self.On17861)
end
-- 请求排行榜信息
function IntimacyManager:Send17858()
    -- print(debug.traceback().."UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU")
    local data = { type = self.RankID };
    self:Send(17858, data)
end

function IntimacyManager:On17858(data)
    if data.type == self.RankID then
        self.RankList = { }
        for _, rank in pairs(data.rank_list) do
            table.insert(self.RankList, rank)
        end
        table.sort(self.RankList, self.sortFun)
    end
    EventMgr.Instance:Fire(event_name.intimacy_update)
end

-- 请求亲密度个人信息榜信息
function IntimacyManager:Send17859()
    local data = { type = self.RankID };
    self:Send(17859, data)
end

function IntimacyManager:On17859(data)
    local lastIntimacy = 0

    if self.MyRankData ~= nil then
        lastIntimacy = self.MyRankData.val1
    end
    local protoData = nil;
    if data.type == self.RankID then
        protoData = data.rank_list[1]
        if protoData.val1 >= lastIntimacy then
            local data = { };
            local role = RoleManager.Instance.RoleData
            local myKey = BaseUtils.Key(role.id, role.platform, role.zone_id)
            local key2 = BaseUtils.Key(protoData.role_id2, protoData.platform2, protoData.zone_id2);
            local key1 = BaseUtils.Key(protoData.role_id, protoData.platform, protoData.zone_id);
            if myKey == key1 then
                data = protoData
            else
                data.role_id2 = protoData.role_id
                data.platform2 = protoData.platform
                data.zone_id2 = protoData.zone_id
                data.name2 = protoData.name
                data.sex2 = protoData.sex
                data.classes2 = protoData.classes
                data.lev2 = protoData.lev

                data.role_id = role.id
                data.platform = role.platform
                data.zone_id = role.zone_id
                data.name = role.name
                data.sex = role.sex
                data.classes = role.classes
                data.lev = role.lev
                data.val1 = protoData.val1
            end
            self.MyRankData = data
            EventMgr.Instance:Fire(event_name.intimacy_my_data_update)
        end
    end
end


-- 请求亲密度个人领奖信息
function IntimacyManager:Send17860()
    local data = { type = self.RankID };
    self:Send(17860, data)
end

function IntimacyManager:On17860(data)
    if data.type == self.RankID then
        self.RankRewardList = { }
        for _, reward in pairs(data.list) do
            table.insert(self.RankRewardList, reward)
        end
    end
    EventMgr.Instance:Fire(event_name.intimacy_reward_data_update)
end
-- 领取个人亲密度奖励
function IntimacyManager:Send17861(num)
    local data = { type = self.RankID, val = num };
    self:Send(17861, data)
end

function IntimacyManager:On17861(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end


-- 获取亲密度排行榜奖励模板数据
function IntimacyManager:GetIntimacyRankData()
    if self.RankRewardTmps ~= nil then
        return self.RankRewardTmps
    end
    self.RankRewardTmps = { }
    local rankData = DataCampaignRank.data_rank_reward_list;
    for _, data in pairs(rankData) do
        if data.sec_type == self.RankID then
            table.insert(self.RankRewardTmps, data)
        end
    end
    local sortfun = function(a, b)
        return a.id < b.id
    end
    table.sort(self.RankRewardTmps, sortfun)
    return self.RankRewardTmps
end

-- 获取亲密度个人奖励模板数据
function IntimacyManager:GetIntimacyPersonalData()
    if self.PersonalTmps ~= nil then
        return self.PersonalTmps
    end
    self.PersonalTmps = { }
    local rankData = DataCampaignRank.data_personal_reward_list;
    for _, data in pairs(rankData) do
        if data.sec_type == self.RankID then
            table.insert(self.PersonalTmps, data)
        end
    end
    local sortfun = function(a, b)
        return a.num < b.num
    end
    table.sort(self.PersonalTmps, sortfun)
    return self.PersonalTmps
end
-- 获取我的亲密度排名
function IntimacyManager:GetMyRankIndex()
    local rank = 0;
    if self.MyRankData == nil or self.RankList == nil then
        return 0
    end
    local role = RoleManager.Instance.RoleData
    local myKey = BaseUtils.Key(role.id, role.platform, role.zone_id)
    for index = 1, #self.RankList do
        local rankData = self.RankList[index];
        local key1 = BaseUtils.Key(rankData.role_id, rankData.platform, rankData.zone_id);
        local key2 = BaseUtils.Key(rankData.role_id2, rankData.platform2, rankData.zone_id2);
        if myKey == key1 or myKey == key2 then
            return rankData.rank
        end
    end
    return 0
end

-- 获取前几排名数据 如 len = 3 则获取前三排名数据
function IntimacyManager:GetRankData(len)
    if self.RankList == nil then
        return nil
    end
    len = len or 1
    local retData = { };
    for index = 1, len do
        table.insert(retData, self.RankList[index])
    end
    return retData
end
-- 获取我的亲密度值
function IntimacyManager:GetMyIntimacy()
    local myIntimacy = 0;
    if self.MyRankData ~= nil then
        myIntimacy = self.MyRankData.val1
    end
    return myIntimacy
end
-- 根据奖励条件（配置值）判断奖励是否已经领取
function IntimacyManager:CheckIsGetReward(num)
    if self.RankRewardList == nil then
        return false
    end
    for _, item in pairs(self.RankRewardList) do
        if tonumber(item.val) == tonumber(num) then
            return true
        end
    end
    return false
end