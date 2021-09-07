-- region *.lua
-- Date jia 2017-5-16
-- 活动排行榜manager
-- endregion
WorldLevManager = WorldLevManager or BaseClass(BaseManager)
WorldLevManager.SYSTEM_ID = 342
function WorldLevManager:__init()
    if WorldLevManager.Instance ~= nil then
        Log.Error("不能重复实例化")
        return
    end
    WorldLevManager.Instance = self
    self.RankRewardTmps = { }
    self.PersonalTmps = { }
    self.RankList = { }
    self.MyRankData = { }
    self.RankRewardList = { }
    self.rankPanel = nil
    self.CurRankType = 0
    self.GiftRefreshIndex = 0
    self.sortFun = function(a, b)
        return a.rank < b.rank
    end
    self.isInitHandler = false

    self.model = WorldLevModel.New()
    self.redPointEvent = EventLib.New()

    self.redPointDic = { }
    self.menuId = {
        PlayerKill = 613-- 星辰擂台
        ,
        Weapon = 614-- 装备评分
        ,
        Constellation = 615-- 十二星座
        ,
        WorldChampion = 616-- 武道大会
        ,
        Pet = 617-- 宠物
        ,
        Wing = 618-- 翅膀排行
        ,
        Gift = 627-- 礼包
        ,
        Recharge = 626-- 充值返利
        ,
        TotalRecharge = 619-- 累计充值
        ,
        Gift2 = 636-- 礼包2
        ,
        Mount = 652-- 坐骑评分排行榜
        ,
        Home = 653-- 家园评分排行榜
        ,
        Arena = 654-- 竞技场评分排行榜
        ,
        Stone = 655-- 宝石评分排行榜
        ,
        Weapon2 = 656-- 装备评分
        ,
        Recharge2 = 664-- 充值返利第二档
        ,
        TotalRecharge2 = 658-- 累计充值第二档
        ,
        Gift3 = 665-- 累计消费第三档
        ,
        Gift4 = 674-- 累计消费第四档
    }
    self:ReSortMenu()
    self:InitHandler()
end

function WorldLevManager:ReSortMenu()
    for k, id in pairs(self.menuId) do
        if DataCampaign.data_list[id] ~= nil then
            CampaignEumn.WorldLevType[k] = DataCampaign.data_list[id].index
        end
    end
end

function WorldLevManager:__delete()
end


function WorldLevManager:InitHandler()
    self.tmp17858 = self:AddNetHandler(17858, self.On17858)
    self.tmp17859 = self:AddNetHandler(17859, self.On17859)
    self.tmp17860 = self:AddNetHandler(17860, self.On17860)
    self.tmp17861 = self:AddNetHandler(17861, self.On17861)
    self.tmp17868 = self:AddNetHandler(17868, self.On17868)

    self.redPointEvent:AddListener( function() self:CheckRedMainUI() end)

    EventMgr.Instance:AddListener(event_name.campaign_rank_my_data_update,
    function()
        self:CheckRed()
    end )
    EventMgr.Instance:AddListener(event_name.campaign_rank_reward_data_update,
    function()
        self:CheckRed()
    end )
    EventMgr.Instance:AddListener(event_name.campaign_change,
    function()
        self:CheckRed()
    end )

end

function WorldLevManager:OpenWindow(args)
    self.model:OpenWindow(args)
end


-- 请求初始化数据
function WorldLevManager:RequestInitData(rankType)
    self:Send17858(rankType)
    self:Send17859(rankType)
    self:Send17860(rankType)
end

-- 请求排行榜信息
function WorldLevManager:Send17858(rankType)
    local data = { type = rankType };
    self:Send(17858, data)
end

function WorldLevManager:On17858(data)
    local rankData = self.RankList[data.type]
    rankData = { }
    for _, rank in pairs(data.rank_list) do
        table.insert(rankData, rank)
    end
    table.sort(rankData, self.sortFun)
    self.RankList[data.type] = rankData
    EventMgr.Instance:Fire(event_name.campaign_rank_update, data.type)
end

-- 请求活动个人信息榜信息
function WorldLevManager:Send17859(rankType)
    local data = { type = rankType }
    self:Send(17859, data)
end

function WorldLevManager:On17859(data)
    local lastValue = 0
    local myData = self.MyRankData[data.type]
    if myData ~= nil then
        lastValue = myData.val1
    end
    local protoData = nil;
    protoData = data.rank_list[1]
    -- if protoData.val1 >= lastValue then
    local myData = { };
    local role = RoleManager.Instance.RoleData
    local myKey = BaseUtils.Key(role.id, role.platform, role.zone_id)
    local key2 = BaseUtils.Key(protoData.role_id2, protoData.platform2, protoData.zone_id2);
    local key1 = BaseUtils.Key(protoData.role_id, protoData.platform, protoData.zone_id);
    if myKey == key1 then
        myData = protoData
    else
        myData.role_id2 = protoData.role_id
        myData.platform2 = protoData.platform
        myData.zone_id2 = protoData.zone_id
        myData.name2 = protoData.name
        myData.sex2 = protoData.sex
        myData.classes2 = protoData.classes
        myData.lev2 = protoData.lev

        myData.role_id = role.id
        myData.platform = role.platform
        myData.zone_id = role.zone_id
        myData.name = role.name
        myData.sex = role.sex
        myData.classes = role.classes
        myData.lev = role.lev
        myData.val1 = protoData.val1
        myData.val4 = protoData.val4
    end
    self.MyRankData[data.type] = myData
    EventMgr.Instance:Fire(event_name.campaign_rank_my_data_update, data.type)
    -- end
end

-- 请求活动个人领奖信息
function WorldLevManager:Send17860(rankType)
    local data = { type = rankType };
    self:Send(17860, data)
end

function WorldLevManager:On17860(data)
    self.RankRewardList[data.type] = { }
    for _, reward in pairs(data.list) do
        table.insert(self.RankRewardList[data.type], reward)
    end
    EventMgr.Instance:Fire(event_name.campaign_rank_reward_data_update, data.type)
end
-- 领取个人奖励
function WorldLevManager:Send17861(rankType, num)
    local data = { type = rankType, val = num };
    self:Send(17861, data)
end

function WorldLevManager:On17861(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
    SummerGiftManager.Instance:CheckRedPoint()
end

function WorldLevManager:On17868(data)
    EventMgr.Instance:Fire(event_name.campaign_rank_time_update, data)
end

function WorldLevManager:Send17868(campID)
    local data = { id = campID };
    self:Send(17868, data)
end



-- 根据活动排行榜类型获取奖励模板数据
function WorldLevManager:GetRankTmpByType(rankType)
    local rankTmp = self.RankRewardTmps[rankType]
    if rankTmp ~= nil then
        return rankTmp
    end
    rankTmp = { }
    local rankData = DataCampaignRank.data_rank_reward_list;
    for _, data in pairs(rankData) do
        if data.sec_type == rankType then
            table.insert(rankTmp, data)
        end
    end
    local sortfun = function(a, b)
        return a.id < b.id
    end
    table.sort(rankTmp, sortfun)
    self.RankRewardTmps[rankType] = rankTmp
    return rankTmp
end

-- 根据活动排行榜类型获取个人奖励模板数据
function WorldLevManager:GetPersonalTmpByType(rankType)
    local rankTmp = self.PersonalTmps[rankType]
    if rankTmp ~= nil then
        return rankTmp
    end
    rankTmp = { }
    local rankData = DataCampaignRank.data_personal_reward_list;
    for _, data in pairs(rankData) do
        if data.sec_type == rankType then
            table.insert(rankTmp, data)
        end
    end
    local sortfun = function(a, b)
        return a.num < b.num
    end
    table.sort(rankTmp, sortfun)
    self.PersonalTmps[rankType] = rankTmp
    return rankTmp
end
-- 根据活动排行榜类型获取我的排名
function WorldLevManager:GetMyRankIndexByType(rankType)
    local rank = 0;
    local myData = self.MyRankData[rankType]
    local rankData = self.RankList[rankType]
    if rankData == nil or myData == nil then
        return 0
    end
    local role = RoleManager.Instance.RoleData
    local myKey = BaseUtils.Key(role.id, role.platform, role.zone_id)
    for index = 1, #rankData do
        local rankData = rankData[index];
        local key1 = BaseUtils.Key(rankData.role_id, rankData.platform, rankData.zone_id);
        local key2 = BaseUtils.Key(rankData.role_id2, rankData.platform2, rankData.zone_id2);
        if myKey == key1 or myKey == key2 then
            return rankData.rank
        end
    end
    return 0
end

--  根据活动排行榜类型获取前几排名数据 如 len = 3 则获取前三排名数据
function WorldLevManager:GetLenRankDataByType(rankType, len)
    local rankData = self.RankList[rankType]
    if rankData == nil then
        return nil
    end
    len = len or 1
    local retData = { };
    for index = 1, len do
        table.insert(retData, rankData[index])
    end
    return retData
end
-- 根据活动排行榜类型获取我的活动值
function WorldLevManager:GetMyValueByType(rankType)
    local myValue = 0;
    local myData = self.MyRankData[rankType]
    if myData ~= nil then
        myValue = myData.val1
    end
    return myValue
end
-- 星辰擂台排行榜获取当前星数
function WorldLevManager:GetMyPlayerStarts(rankType)
    local myValue = 0;
    if rankType == CampaignEumn.CampaignRankType.PlayerKill then
        local myData = self.MyRankData[rankType]
        if myData ~= nil then
            myValue = myData.val4
        end
    end
    return myValue
end

-- 根据奖励条件（配置值）判断奖励是否已经领取
function WorldLevManager:CheckIsGetRewardByType(rankType, num)
    local rewardList = self.RankRewardList[rankType];
    if rewardList == nil then
        return false
    end
    for _, item in pairs(rewardList) do
        if tonumber(item.val) == tonumber(num) then
            return true
        end
    end
    return false
end

function WorldLevManager:SetIcon()
    MainUIManager.Instance:DelAtiveIcon3(WorldLevManager.SYSTEM_ID)
    if CampaignManager.Instance.campaignTree[CampaignEumn.Type.WorldLev] == nil then
        return
    end
    self.activeIconData = AtiveIconData.New()
    local iconData = DataSystem.data_daily_icon[WorldLevManager.SYSTEM_ID]
    self.activeIconData.id = iconData.id
    self.activeIconData.iconPath = iconData.res_name
    self.activeIconData.sort = iconData.sort
    self.activeIconData.lev = iconData.lev
    self.activeIconData.clickCallBack = function()
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.world_lev_window)
    end
    MainUIManager.Instance:AddAtiveIcon3(self.activeIconData)
    self:CheckRed()
end
function WorldLevManager:CheckRed()
    local redList = { }
    for id, _ in pairs(self.redPointDic) do
        table.insert(redList, id)
    end
    for _, id in pairs(redList) do
        self.redPointDic[id] = nil
    end
    local campaignData = CampaignManager.Instance.campaignTree[CampaignEumn.Type.WorldLev]
    if campaignData ~= nil then

        local rankRed =
        function(rank, campaign)
            local red = false;
            if rank ~= nil and campaign ~= nil then
                local red = false;
                for i, sub in pairs(campaignData[campaign].sub) do
                    local myIntimacy = self:GetMyValueByType(rank)
                    if myIntimacy > 0 then
                        local tmpList = self:GetPersonalTmpByType(rank)
                        if tmpList ~= nil then
                            for _, tmp in ipairs(tmpList) do
                                if myIntimacy >= tmp.num then
                                    local isGet = self:CheckIsGetRewardByType(rank, tmp.num);
                                    if not isGet then
                                        red = true
                                        break
                                    end
                                end
                            end
                        end
                    end
                    self.redPointDic[sub.id] = red
                end
            end
        end

        local rankType = nil;
        local campaignType = nil;
        if campaignData[CampaignEumn.WorldLevType.Constellation] ~= nil then
            rankType = CampaignEumn.CampaignRankType.Constellation
            campaignType = CampaignEumn.WorldLevType.Constellation
            rankRed(rankType, campaignType)
        end
        if campaignData[CampaignEumn.WorldLevType.Pet] ~= nil then
            rankType = CampaignEumn.CampaignRankType.Pet
            campaignType = CampaignEumn.WorldLevType.Pet
            rankRed(rankType, campaignType)
        end
        if campaignData[CampaignEumn.WorldLevType.PlayerKill] ~= nil then
            rankType = CampaignEumn.CampaignRankType.PlayerKill
            campaignType = CampaignEumn.WorldLevType.PlayerKill
            rankRed(rankType, campaignType)
        end
        if campaignData[CampaignEumn.WorldLevType.Weapon] ~= nil then
            rankType = CampaignEumn.CampaignRankType.Weapon
            campaignType = CampaignEumn.WorldLevType.Weapon
            rankRed(rankType, campaignType)
        end
        if campaignData[CampaignEumn.WorldLevType.Weapon2] ~= nil then
            rankType = CampaignEumn.CampaignRankType.Weapon2
            campaignType = CampaignEumn.WorldLevType.Weapon2
            rankRed(rankType, campaignType)
        end
        if campaignData[CampaignEumn.WorldLevType.Wing] ~= nil then
            rankType = CampaignEumn.CampaignRankType.Wing
            campaignType = CampaignEumn.WorldLevType.Wing
            rankRed(rankType, campaignType)
        end
        if campaignData[CampaignEumn.WorldLevType.WorldChampion] ~= nil then
            rankType = CampaignEumn.CampaignRankType.WorldChampion
            campaignType = CampaignEumn.WorldLevType.WorldChampion
            rankRed(rankType, campaignType)
        end
        if campaignData[CampaignEumn.WorldLevType.Mount] ~= nil then
            rankType = CampaignEumn.CampaignRankType.Mount
            campaignType = CampaignEumn.WorldLevType.Mount
            rankRed(rankType, campaignType)
        end
        if campaignData[CampaignEumn.WorldLevType.Home] ~= nil then
            rankType = CampaignEumn.CampaignRankType.Home
            campaignType = CampaignEumn.WorldLevType.Home
            rankRed(rankType, campaignType)
        end
        if campaignData[CampaignEumn.WorldLevType.Arena] ~= nil then
            rankType = CampaignEumn.CampaignRankType.Arena
            campaignType = CampaignEumn.WorldLevType.Arena
            rankRed(rankType, campaignType)
        end
        if campaignData[CampaignEumn.WorldLevType.Stone] ~= nil then
            rankType = CampaignEumn.CampaignRankType.Stone
            campaignType = CampaignEumn.WorldLevType.Stone
            rankRed(rankType, campaignType)
        end
        if campaignData[CampaignEumn.WorldLevType.Weapon2] ~= nil then
            rankType = CampaignEumn.CampaignRankType.Weapon2
            campaignType = CampaignEumn.WorldLevType.Weapon2
            rankRed(rankType, campaignType)
        end
            if campaignData[CampaignEumn.WorldLevType.Fairyland] ~= nil then
            rankType = CampaignEumn.CampaignRankType.Fairyland
            campaignType = CampaignEumn.WorldLevType.Fairyland
            rankRed(rankType, campaignType)
        end

        if campaignData[CampaignEumn.WorldLevType.Gift] ~= nil then
            campaignType = CampaignEumn.WorldLevType.Gift
            for i, sub in pairs(campaignData[campaignType].sub) do
                self.redPointDic[sub.id] = false
            end
        end
        if campaignData[CampaignEumn.WorldLevType.Gift2] ~= nil then
            campaignType = CampaignEumn.WorldLevType.Gift2
            for i, sub in pairs(campaignData[campaignType].sub) do
                self.redPointDic[sub.id] = false
            end
        end
        if campaignData[CampaignEumn.WorldLevType.Gift3] ~= nil then
            campaignType = CampaignEumn.WorldLevType.Gift3
            for i, sub in pairs(campaignData[campaignType].sub) do
                self.redPointDic[sub.id] = false
            end
        end
        if campaignData[CampaignEumn.WorldLevType.Gift4] ~= nil then
            campaignType = CampaignEumn.WorldLevType.Gift4
            for i, sub in pairs(campaignData[campaignType].sub) do
                self.redPointDic[sub.id] = false
            end
        end
        if campaignData[CampaignEumn.WorldLevType.TotalRecharge] ~= nil then
            for i, sub in pairs(campaignData[CampaignEumn.WorldLevType.TotalRecharge].sub) do
                if sub.status == CampaignEumn.Status.Finish then
                    self.redPointDic[sub.id] = true
                end
            end
        end
        if campaignData[CampaignEumn.WorldLevType.TotalRecharge2] ~= nil then
            for i, sub in pairs(campaignData[CampaignEumn.WorldLevType.TotalRecharge2].sub) do
                if sub.status == CampaignEumn.Status.Finish then
                    self.redPointDic[sub.id] = true
                end
            end
        end
    end
    self.redPointEvent:Fire()
end

function WorldLevManager:CheckRedMainUI()
    local red = false
    if CampaignManager.Instance.campaignTree ~= nil and CampaignManager.Instance.campaignTree[CampaignEumn.Type.WorldLev] ~= nil then
        for _, v in pairs(self.redPointDic) do
            red = red or(v == true)
        end
    end
    if MainUIManager.Instance.MainUIIconView ~= nil and self.activeIconData ~= nil then
        MainUIManager.Instance.MainUIIconView:set_icon_Redpoint_by_id(self.activeIconData.id, red)
    end
end