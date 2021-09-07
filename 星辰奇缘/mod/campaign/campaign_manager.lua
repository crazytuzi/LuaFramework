-- ------------------------------
-- 活动管理
-- hosr
-- ------------------------------
CampaignManager = CampaignManager or BaseClass(BaseManager)

function CampaignManager:__init()
    if CampaignManager.Instance ~= nil then
        return
    end
    CampaignManager.Instance = self
    self.model = CampaignModel.New()

    self.campaignTab = {}

    self:InitHandler()

    -- 开服时间
    self.open_srv_time = 0

    self.hasFestival = false
    self.hasOnline = false
    self.currentFestival = nil
    -- 客户端在线奖励，倒计时
    self.countOnLine = 0

    self.firstRiceCake = true
    self.redPointDic = {}

    self.campaign_eggs = {} --神秘彩蛋数据
    self.rollPoint = 0 -- 摇到的点数
    self.campaign_bags = {} --福袋数据
    self.campaignWishTimes = 0 -- 许愿池许愿次数
    self.campaignSummerRed =false  --夏日必做任务红点
    --self.campaignHaoliLaixiRed =false
    self.campaignTree = {}


    self.initHalloween = false

    self.christmas_ride = true -- 圣诞坐骑展示界面
    self.christmas_ride_click = false

    self.DiscountShop_show = true -- 兑换商店展示界面红点

    -- ------------------------------------------
    -- 下面是活动优化
    -- ------------------------------------------
    -- 奖励面板里面的活动标签是否显示标志
    self.IsShowTabInBible = false
    self.ShowTab = {}

    self.labourModel = LabourCampaignModel.New()

    self.OnUpdate = EventLib.New()

    self.onUpdateRecharge = EventLib.New()

    EventMgr.Instance:AddListener(event_name.role_asset_change, function ()
        self:CheckTreasureHuntingRedPoint()
    end)

    self.summer_questQuestChange = EventLib.New()

    self.campaignData = {}
end

function CampaignManager:RequestInitData()
    self.isFirst = nil
    self.initHalloween = false
    self.initThanksgiving = false
    self.isInitOpenServer = false
    self.initChildBirth = false
    self.isInitSummer = false
    self.initSpringFestival = false
    self.isInitUniversal = false
    self.campaignSummerRed =false
    self:Send14000()
    -- self:Send14003()
    self:Send14004()
    self:Send14097()
    self:Send17875()
    NewLabourManager.Instance:Send17842()
    NewLabourManager.Instance:Send17899()
    for _,rankType in pairs(CampaignEumn.CampaignRankType) do
        WorldLevManager.Instance:RequestInitData(rankType)
    end
end

function CampaignManager:InitHandler()
    self:AddNetHandler(14000, self.On14000)
    self:AddNetHandler(14001, self.On14001)
    self:AddNetHandler(14002, self.On14002)
    self:AddNetHandler(14003, self.On14003)
    self:AddNetHandler(14004, self.On14004)

    self:AddNetHandler(14006, self.On14006)
    self:AddNetHandler(14007, self.On14007)
    self:AddNetHandler(14008, self.On14008)
    self:AddNetHandler(14009, self.On14009)
    self:AddNetHandler(14010, self.On14010)
    self:AddNetHandler(14011, self.On14011)
    self:AddNetHandler(14012, self.On14012)
    self:AddNetHandler(14013, self.On14013)
    self:AddNetHandler(14014, self.On14014)
    self:AddNetHandler(14096, self.On14096)
    self:AddNetHandler(14097, self.On14097)
    self:AddNetHandler(14099, self.On14099)

    self:AddNetHandler(17875, self.On17875)
    self:AddNetHandler(17876, self.On17876)
    self:AddNetHandler(17877, self.On17877)
    EventMgr.Instance:AddListener(event_name.mainui_btn_init, function() self:RequestInitData() end)
    EventMgr.Instance:AddListener(event_name.role_level_change, function() self:Send14000() end)
end

-- 请求奖励情况
function CampaignManager:Send14000()
    self:Send(14000, {})
end

function CampaignManager:ReSerRed()
    local tab = {}
    for id,v in pairs(self.redPointDic) do
        if v ~= nil then
            table.insert(tab, id)
        end
    end
    for _,id in ipairs(tab) do
        self.redPointDic[id] = nil
    end
end

--活动奖励情况
function CampaignManager:On14000(data)
    --oppo渠道社区图标按钮
    if ctx.PlatformChanleId == 12 then 
        self:ShowCommunityIcon()
    end

    if IS_DEBUG then
        -- NoticeManager.Instance:FloatTipsByString("收到活动协议14000")
        BaseUtils.dump(data,string.format("%s <color='#fff000'>收到14000</color>", os.date("%c", BaseUtils.BASE_TIME)))
    end

    local rewardReturnData = ShopManager.Instance.dataList
    for k,v1 in pairs(data.reward_list) do
        for i,v2 in ipairs(rewardReturnData) do
            if v1.id == v2.id then
                self.campaignData[v2.group_index] = v1
            end
        end
    end

    -- BaseUtils.dump(self.campaignData,"整合后的数据")

    self.onUpdateRecharge:Fire()
    -- FirstRechargeManager.Instance:on14000(data)
    self.hasOnline = false
    local isNeedRequestEggInfo = false
    local isNeedRequestBalloon = true
    local lev = RoleManager.Instance.RoleData.lev

    local idList = {}
    for id,v in pairs(self.campaignTab) do
        if v ~= nil then
            table.insert(idList, id)
        end
    end
    for _,id in ipairs(idList) do
        self.campaignTab[id] = nil
    end

    self.hasBuyThree = false
    for i,v in ipairs(data.reward_list) do
        local baseData = DataCampaign.data_list[v.id]
        if baseData ~= nil then
            if (baseData.lev_min == 0 and baseData.lev_max == 0)
             or (baseData.lev_min <= lev and lev <= baseData.lev_max) then
                local campaignData = CampaignData.New()
                campaignData:Update(v)
                self.campaignTab[v.id] = campaignData
                if baseData ~= nil and baseData.cond_type == CampaignEumn.ShowType.BuyThree then
                    self.hasBuyThree = true
                end
            end
        end
    end

    if isNeedRequestEggInfo == true then
        --请求彩蛋数据
        self:Send14006()
    end

    if isNeedRequestBalloon or isNeedRequestEggInfo then
        --请求福袋数据
        self:Send14009()
    end
    self.campaignTree = {}
    self:InitCampaignData()
    -- self:CalOnlineRewardTime(false)

    -- BibleManager.Instance:checkRedPoint()
    EventMgr.Instance:Fire(event_name.onlinereward_change)

    EventMgr.Instance:Fire(event_name.campaign_change)

end

-- 领取奖励
function CampaignManager:Send14001(id)
    self:Send(14001, {id = id})
end

function CampaignManager:On14001(data)
    FirstRechargeManager.Instance:on14001(data)
    if data.flag == 1 then
        EventMgr.Instance:Fire(event_name.get_campaign_reward_success)
    end
end

-- 奖励进度发生变化(存在则更新 不存在则为新增加的)
function CampaignManager:Send14002()
    self:Send(14002, {})
end
--奖励进度发生变化(存在则更新 不存在则为新增加的)
function CampaignManager:On14002(data)
    if IS_DEBUG then
        -- NoticeManager.Instance:FloatTipsByString("收到活动协议14002")
        --print(string.format("%s <color='#fff000'>收到14002</color>", os.date("%c", BaseUtils.BASE_TIME)))
    end

    self.hasOnline = false
    local lev = RoleManager.Instance.RoleData.lev
    for i,v in ipairs(data.reward_list) do
        print(v.id)
        local baseData = DataCampaign.data_list[v.id]

        if (baseData.lev_min == 0 and baseData.lev_max == 0)
            or (baseData.lev_min <= lev and lev <= baseData.lev_max)
            then
            local campaignData = self.campaignTab[v.id]
            if campaignData == nil then
                campaignData = CampaignData.New()
                self.campaignTab[v.id] = campaignData
            end
            campaignData:Update(v)
        end
    end

    self.campaignTree = self.campaignTree or {}
    self:InitCampaignData()
    -- self:CalOnlineRewardTime(true)
    EventMgr.Instance:Fire(event_name.campaign_change)

    EventMgr.Instance:Fire(event_name.onlinereward_change)
end

function CampaignManager:CalOnlineRewardTime(isFrom14002)
    if self.countOnLine > 0 then
        return
    end
    self.countOnLine = 0
    local dataItemList = CampaignManager.Instance:GetCampaignDataList(CampaignEumn.Type.OnLine)
    if dataItemList ~= nil then
        self.hasOnline = true
    else
        return
    end

    for i,v in ipairs(dataItemList) do
        local tplData = DataCampaign.data_list[v.id]
        if v.status == 0 then
            if isFrom14002 == false then
                local compareSec = 120 - (BaseUtils.BASE_TIME - v.ext_val)
                self.countOnLine = v.target_val - (BaseUtils.BASE_TIME - v.ext_val + v.value)
                self.countOnLine = math.max(compareSec,self.countOnLine)
            elseif isFrom14002 == true then
                self.countOnLine = v.target_val - v.value
            end
            -- Log.Error(self.countOnLine)
            break
        end
    end

    if self.countOnLine == 0 then
        local dataItemList = ((CampaignManager.Instance.campaignTree[CampaignEumn.Type.OpenServer] or {})[CampaignEumn.OpenServerType.Online] or {}).sub or {}
        if dataItemList ~= nil then
            self.hasOnline = true
        else
            return
        end

        for i,v in ipairs(dataItemList) do
            local tplData = DataCampaign.data_list[v.id]
            if v.status == 0 then
                if isFrom14002 == false then
                    local compareSec = 120 - (BaseUtils.BASE_TIME - v.ext_val)
                    self.countOnLine = v.target_val - (BaseUtils.BASE_TIME - (v.ext_val - v.value))
                    self.countOnLine = math.max(compareSec,self.countOnLine)
                elseif isFrom14002 == true then
                    self.countOnLine = v.target_val - v.value
                end
                -- Log.Error(self.countOnLine)
                break
            end
        end
    end

    if self.timerId ~= nil and self.timerId ~= 0 then
        LuaTimer.Delete(self.timerId)
    end
    if self.countOnLine > 0 then
        self.timerId = LuaTimer.Add(0, 1000, function()
            --print(self.clickInterval)
            if self.countOnLine > 0 then
                self.countOnLine = self.countOnLine - 1
            else
                self.countOnLine = 0
                LuaTimer.Delete(self.timerId)
                self.timerId = nil
            end
        end)
    end
end

-- 图标信息,现在好像已经没用了
function CampaignManager:Send14003()
    self:Send(14003, {})
end

function CampaignManager:On14003(data)
    BaseUtils.dump(data, "<color=#FF0000>14003</color>")
    FirstRechargeManager.Instance:on14003(data)
    self.bibleType = nil

    -- --------------------------------------------------------
    -- 优化,这个协议只做一件事，就是判断图标或标签是否显示
    -- 红点就交给14000 和 14002来处理
    -- -------------------------------------------------------
    self.IsShowTabInBible = false
    for i,v in ipairs(data.camp_list) do
        local icon = DataCampaign.data_camp_ico[v.id]
        if icon ~= nil then
            if icon.position_type == CampaignEumn.ShowPosition.BibleCampaign then
                self.IsShowTabInBible = true
                if self.bibleType == nil then self.bibleType = icon.id end
            else
                -- 在主界面显示的处理。从FirstRechargeManager.Instance:on14003(data)搬回来
            end
        end
    end
end

-- 时间信息
function CampaignManager:Send14004()
    self:Send(14004, {})
end

function CampaignManager:On14004(data)
    self.open_srv_time = data.open_srv_time
    self.merge_srv_time = data.merge_srv_time
    self.merge_num = data.merge_num
end

-- 获取神秘彩蛋数据
function CampaignManager:Send14006()
    self:Send(14006, {})
end
--获取神秘彩蛋数据
function CampaignManager:On14006(data)
    -- BaseUtils.dump(data,"CampaignManager:On14006(data)")
    self.campaign_eggs = data
    -- self.campaign_eggs.footIndexDic = {}
    -- for i,v in ipairs(self.campaign_eggs.footprints) do
    --     self.campaign_eggs.footIndexDic[v.fp] = fp
    -- end
    EventMgr.Instance:Fire(event_name.mystical_eggs_info_update)
    self:checkMysticalEggsRedPoint()
end
function CampaignManager:checkMysticalEggsRedPoint()
    local num = BackpackManager.Instance:GetItemCount(29183)
    if self.campaign_eggs.can_roll == 15 or num > 0 then
        self.redPointDic[77] = (self.campaignTab[77] ~= nil and true)
    else
        self.redPointDic[77] = (self.campaignTab[77] ~= nil and false)
    end
    -- BibleManager.Instance.redPointDic[4][77] = self.redPointDic[77]
    -- BibleManager.Instance.onUpdateRedPoint:Fire()

    self:CheckRedPoint()
end
-- 彩蛋投掷
function CampaignManager:Send14007()
    self:Send(14007, {})
end
--彩蛋投掷
function CampaignManager:On14007(data)
    -- BaseUtils.dump(data,"CampaignManager:On14007(data)")
    if data.flag == 1 then
        self.rollPoint = data
        EventMgr.Instance:Fire(event_name.mystical_eggs_roll_update)
    else
        NoticeManager.Instance:FloatTipsByString(data.msg)
    end
end
-- 领取次数奖励
function CampaignManager:Send14008(id)
    self:Send(14008, {id = id})
end
--领取次数奖励
function CampaignManager:On14008(data)
    -- BaseUtils.dump(data,"CampaignManager:On14008(data)")
end
-- 获取守护福袋数据
function CampaignManager:Send14009()
    self:Send(14009, {})
end
--获取守护福袋数据
function CampaignManager:On14009(data)
    self.campaign_bags = data

    self.campaign_bags.bagRewardsKeyValue = self.campaign_bags.bagRewardsKeyValue or {}
    for i,v in ipairs(self.campaign_bags.bag_rewards) do
        self.campaign_bags.bagRewardsKeyValue[v.c_id] = v
    end

    EventMgr.Instance:Fire(event_name.welfare_bags_info_update)

    NationalDayManager.Instance.model:CheckBalloonRed()
end

-- 填充福袋
function CampaignManager:Send14010(id)
    self:Send(14010, {id = id})
end
--填充福袋
function CampaignManager:On14010(data)
    -- BaseUtils.dump(data,"CampaignManager:On14010(data)")
    if data.flag == 1 then
        --
    else
        NoticeManager.Instance:FloatTipsByString(data.msg)
    end
end
-- 领取福袋奖励
function CampaignManager:Send14011(id)
    self:Send(14011, {id = id})
end
--领取福袋奖励
function CampaignManager:On14011(data)
    -- BaseUtils.dump(data,"CampaignManager:On14011(data)")
end
-- 好友求助
function CampaignManager:Send14012(rid,platform,zone_id,id)
    self:Send(14012, {rid = rid,platform = platform,zone_id = zone_id,id = id})
end
--好友求助
function CampaignManager:On14012(data)
    -- BaseUtils.dump(data,"CampaignManager:On14012(data)")
    if data.msg ~= "" then
        NoticeManager.Instance:FloatTipsByString(data.msg)
    end
end
-- 公会求助
function CampaignManager:Send14013(id)
    self:Send(14013, {id = id})
end
--公会求助
function CampaignManager:On14013(data)
    -- BaseUtils.dump(data,"CampaignManager:On14013(data)")
    if data.msg ~= "" then
        NoticeManager.Instance:FloatTipsByString(data.msg)
    end
end
-- 领取福袋大奖
function CampaignManager:Send14014()
    self:Send(14014, {})
end

function CampaignManager:Send14099()
    self:Send(14099, {})
end

--领取福袋大奖
function CampaignManager:On14014(data)
    -- BaseUtils.dump(data,"CampaignManager:On14014(data)")
    if data.flag == 1 then
        --
    else
        NoticeManager.Instance:FloatTipsByString(data.msg)
    end
end
--许愿池许愿
function CampaignManager:Send14096()
    -- print("CampaignManager:Send14096()")
    self:Send(14096, {})
end
--许愿池许愿
function CampaignManager:On14096(data)
    -- BaseUtils.dump(data,"CampaignManager:On14096(data)")
    NoticeManager.Instance:FloatTipsByString(data.msg)
    if data.err_code == 1 then
        self.OnUpdate:Fire("OpenServerTreviFountainPanel:ShowRewardPanel", data.gold)
    end
end
-- 许愿池次数
function CampaignManager:Send14097()
    self:Send(14097, {})
end
--许愿池次数
function CampaignManager:On14097(data)
    self.campaignWishTimes = data.times
    self.OnUpdate:Fire()
end

function CampaignManager:On14099(data)
    self.luckeyChestOwnList = {}
    for _, v in pairs(data.list) do
        self.luckeyChestOwnList[v.id] = 1
    end
    EventMgr.Instance:Fire(event_name.luckey_chest_own_id_change)
end

--请求开服翻牌数据
function CampaignManager:Send17875()
    Connection.Instance:send(17875, {})
end

function CampaignManager:On17875(data)
    -- BaseUtils.dump(data, "<color='#00ff00'>On17875</color>")
    local model = self.model

    model.receiveNum = 0
    model.baseIdList = {}
    model.allOpen = true
    model.notOpen = true
    model.card_act_cost = {}
    model.last_group = data.last_group
    model.start_time = data.start_time
    model.end_time = data.end_time

    local tab = {}

    for i,v in ipairs(data.card_list) do
        if #v.item_id > 0 then -- 调整数据结构，保持和原来的协议一致(17814)
            v.base_id = v.item_id[1].id
            v.num = v.item_id[1].num
        end

        if v.flag ~= 0 then
            model.receiveNum = model.receiveNum + 1
            tab[v.flag] = v
        end
        model.allOpen = model.allOpen and (v.flag ~= 0)
        model.notOpen = model.notOpen and (v.flag == 0)
        table.insert(model.baseIdList, v)
    end

    model.card_act_cost = data.act_cost
    model.card_act_cost_max = 0
    for i=1, #data.act_cost do
        if data.act_cost[i].acticity > model.card_act_cost_max then
            model.card_act_cost_max = data.act_cost[i].acticity
        end
    end

    if model.cardData == nil then       -- 登录请求
        model.cardData = model.cardData or {}
        if model.notOpen == true then
            model.cardData.card_list = model.baseIdList
        else
            model.cardData.card_list = tab
        end
        model.cardData.temp_list = data.card_list
        model.cardData.times = data.times
        OpenServerManager.Instance.onUpdateCard:Fire(false)
    else
        if #model.baseIdList == 0 then -- 没派牌
            model.cardData.card_list = model.baseIdList
            model.cardData.temp_list = data.card_list
            model.cardData.times = data.times
            OpenServerManager.Instance.onUpdateCard:Fire(false)
        elseif #model.cardData.temp_list == 0 and model.notOpen == true then      -- 执行了派牌
            model.cardData.card_list = model.baseIdList
            model.cardData.temp_list = data.card_list
            model.cardData.times = data.times
            OpenServerManager.Instance.onUpdateCard:Fire(true)
        elseif #data.card_list == 0 then                                    -- 可认为是0点更新
            model.cardData.card_list = tab
            model.cardData.temp_list = data.card_list
            model.cardData.times = data.times
            OpenServerManager.Instance.onUpdateCard:Fire(data.times == 4)
        else
            if model.notOpen == true then
                model.cardData.card_list = model.baseIdList
            else
                model.cardData.card_list = tab
            end
            model.cardData.temp_list = data.card_list
            model.cardData.times = data.times
            if #model.cardData.card_list == 0 and data.times == 4 then
                OpenServerManager.Instance.onUpdateCard:Fire(true)
            else
                OpenServerManager.Instance.onUpdateCard:Fire(false)
            end
        end
    end

    self:CheckTreasureHuntingRedPoint()
end

function CampaignManager:Send17876()
    Connection.Instance:send(17876, {})
end

function CampaignManager:On17876(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function CampaignManager:Send17877(order)
    Connection.Instance:send(17877, { order = order })
end

function CampaignManager:On17877(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

-- 外部数据读取
function CampaignManager:GetCampaignData(id)
    return self.campaignTab[id]
end

-- 外部取某一类活动数据   53
function CampaignManager:GetCampaignDataList(iconId)
    local target = {}
    for k,v in pairs(self.campaignTab) do
        local baseData = DataCampaign.data_list[v.id]
        if baseData ~= nil and tonumber(baseData.iconid) == iconId then
            table.insert(target,v)
        end
    end
    return target
end

-- self.campaignTree =
--                      tonumber(iconid)
--                      ->
--                      index ->
--                          mainui      是否在mainui上
--                          , sub =
--                          group_index -> data
function CampaignManager:InitCampaignData()
    self:ReSerRed()
    -- self.campaignTab[339] = CampaignData.New()
    -- self.campaignTab[339].id = 339
    --BaseUtils.dump(CampaignManager.Instance.campaignTab,"xxxxxxxxxxxxxxxxxx")
    for k,v in pairs(self.campaignTab) do
        local baseData = DataCampaign.data_list[v.id]
        if baseData ~= nil then
            local main = self.campaignTree[tonumber(baseData.iconid)]
            if main == nil then
                self.campaignTree[tonumber(baseData.iconid)] = {}
            end
            main = self.campaignTree[tonumber(baseData.iconid)]
            if main[baseData.index] == nil then
                if DataCampaign.data_camp_ico[tonumber(baseData.iconid)] ~= nil then
                    main[baseData.index] = {index = baseData.index, sub = {}, mainui = DataCampaign.data_camp_ico[tonumber(baseData.iconid)].is_show}
                else
                    main[baseData.index] = {index = baseData.index, sub = {}, mainui = 0}
                end
            end
             -- table.insert(main[baseData.index].sub, v)
            main[baseData.index].tempSub = main[baseData.index].tempSub or {}
            main[baseData.index].tempSub[baseData.id] = v
            v.group_index = baseData.group_index
        end
    end

    for _,v in pairs(self.campaignTree) do
        for k,v1 in pairs(v) do
            if k ~= "count" then
                local tab = {}
                for _,dat in pairs(v1.tempSub) do
                    table.insert(tab, dat)
                end
                v1.tempSub = nil
                table.sort(tab, function(a, b) return a.group_index < b.group_index end)
                v1.sub = tab
            end
        end
    end

    local tree = {}
    for k,campaign in pairs(self.campaignTree) do
        local campaignList = {}
        local count = 0
        -- BaseUtils.dump(campaign)
        for key,main in pairs(campaign) do
            if key ~= "count" then
                count = count + 1
                table.sort(main.sub, function(a, b) return a.group_index < b.group_index end)
                campaignList[main.index] = main
            end
        end
        campaignList["count"] = count
        tree[k] = campaignList
    end
    self.campaignTree = tree

    if self:CheckIntimacy() then
        if IntimacyManager.Instance == nil then
            IntimacyManager.New()
        end
        IntimacyManager.Instance:ClearData()
        IntimacyManager.Instance:Send17858()
        IntimacyManager.Instance:Send17859()
        IntimacyManager.Instance:Send17860()
    else
        -- if IntimacyManager.Instance ~= nil then
        --     IntimacyManager.Instance:DeleteMe()
        --     IntimacyManager.Instance = nil
        -- end
    end
    -- 暑假活动
    if self.isInitSummer ~= true then
        SummerManager.Instance:RequestData()
        self.isInitSummer = true
    end

    SummerManager.Instance:SetIcon()
    BigSummerManager.Instance:SetIcon()
    SummerCarnivalManager.Instance:SetIcon()

    -- 公测活动
    OpenBetaManager.Instance:SetIcon()

    -- 国庆活动

    MarchEventManager.Instance:SetIcon() -- 扭蛋抽奖活动

    RebateRewardManager.Instance:SetIcon() -- 小额双倍活动

    CampBoxManager.Instance:SetIcon() --夏日活动

    SummerGiftManager.Instance:SetIcon() -- 七月夏日活动

    BeginAutumnManager.Instance:SetIcon()

    -- 中秋活动
    if self.hasFestival == true and self.currentFestival == CampaignEumn.Type.MidAutumn then
        if MidAutumnFestivalManager.Instance == nil then
            MidAutumnFestivalManager.New()
        end
        MidAutumnFestivalManager.Instance:SetIcon()
        MidAutumnFestivalManager.Instance:RequestInitData()
    end
    -- BaseUtils.dump(self.campaignTree[CampaignEumn.Type.NewMoon], "<color='#00ff00'>self.campaignTree[CampaignEumn.Type.NewMoon]</color>")
    if self.campaignTree[CampaignEumn.Type.NewMoon] ~= nil then
        NewMoonManager.Instance:RequestInitData()
        if self.campaignTree[CampaignEumn.Type.NewMoon].count == 1 and self.campaignTree[CampaignEumn.Type.Halloween] ~= nil then
            if self.campaignTree[CampaignEumn.Type.NewMoon][CampaignEumn.NewMoonType.Dice] ~= nil then
                self.campaignTree[CampaignEumn.Type.Halloween][CampaignEumn.HalloweenType.NewMoon_Dice] = self.campaignTree[CampaignEumn.Type.NewMoon][CampaignEumn.NewMoonType.Dice]
                self.campaignTree[CampaignEumn.Type.Halloween][CampaignEumn.HalloweenType.NewMoon_Dice].index = CampaignEumn.HalloweenType.NewMoon_Dice
            elseif self.campaignTree[CampaignEumn.Type.NewMoon][CampaignEumn.NewMoonType.Recharge] ~= nil then
                self.campaignTree[CampaignEumn.Type.Halloween][CampaignEumn.HalloweenType.NewMoon_Recharge] = self.campaignTree[CampaignEumn.Type.NewMoon][CampaignEumn.NewMoonType.Recharge]
                self.campaignTree[CampaignEumn.Type.Halloween][CampaignEumn.HalloweenType.NewMoon_Recharge].index = CampaignEumn.HalloweenType.NewMoon_Recharge
            end
            self.campaignTree[CampaignEumn.Type.NewMoon] = nil
        elseif self.campaignTree[CampaignEumn.Type.NewMoon].count == 0 then
            self.campaignTree[CampaignEumn.Type.NewMoon] = nil
        end
        -- NewMoonManager.Instance:SetIcon()
    else
        if NewMoonManager.Instance == nil then
            NewMoonManager.New()
        end
        -- NewMoonManager.Instance:SetIcon()
    end

    -- 万圣节
    if self.initHalloween == false then
        HalloweenManager.Instance:RequestInitData()
        self.initHalloween = true
    end
    HalloweenManager.Instance:SetIcon()

    -- 合服活动
    MergeServerManager.Instance:SetIcon()

    -- 检查四季试炼
    if self.isFirst == nil then
        self.labourModel:CheckTrialOpen()
        NationalDayManager.Instance.model:CheckFiveOpen()
        self.isFirst = 1
    end

    -- 双十一活动
    NationalDayManager.Instance:SetIcon()

    -- 元旦活动 2017年四月累冲
    NewYearManager.Instance:SetIcon()

    -- 感恩节活动
    DoubleElevenManager.Instance:SetIcon1()


    -- 开服活动图标
    OpenServerManager.Instance:SetIcon()
    if self.isInitOpenServer ~= true then
        OpenServerManager.Instance:RequestInitData()
        self.isInitOpenServer = true
    end

    -- 首充活动
    FirstRechargeManager.Instance:SetIcon()

    -- 春节活动
    if self.initSpringFestival ~= true then
        SpringFestivalManager.Instance:RequestInitData()
        self.initSpringFestival = true
    end
    SpringFestivalManager.Instance:SetIcon()

    ValentineManager.Instance:CheckCakeExchange()
    -- 元宵, 白色情人节
    if self.initValentine ~= true then
        ValentineManager.Instance:ReqOnConnect()
        self.initValentine = true
    end
    ValentineManager.Instance:SetIcon()


    -- 子女系统资料片
    if self.initChildBirth ~= true then
        ChildBirthManager.Instance:RequestInitData()
        self.initChildBirth = true
    end
    ChildBirthManager.Instance:SetIcon()
    -- 愚人节活动（笑
    FoolManager.Instance:SetIcon()

    -- 520情人节
    MayIOUManager.Instance:SetIcon()
    -- 世界等级活动
    WorldLevManager.Instance:SetIcon();
    -- 端午节
    DragonBoatFestivalManager.Instance:SetIcon()

    WarmHeartManager.Instance:SetIcon()

    if self.initThanksgiving ~= true then
        ThanksgivingManager.Instance:RequestInitData()
        self.initThanksgiving = true
    end
    ThanksgivingManager.Instance:SetIcon()
    if CampaignManager.Instance:IsNeedHideRechargeByPlatformChanleId() == true then
        return
    end

    self.model:SetIcon(self.campaignTree)

   -- 2017年五一活动
  --  NewLabourManager.Instance:SetIcon()

    -- self:CheckChildRedPoint()
end

-- red = {
--      [campaign_id] = true/false
-- }
function CampaignManager:CheckRedPoint()

    -- BibleManager.Instance.redPointDic[4][1] = bibleRed

    -- self:CheckMainUIIconRedPoint() --活动入口红点检查
    BibleManager.Instance.onUpdateRedPoint:Fire()
end

function CampaignManager:isNeedShowRedPoint()
    local  isNeedShowPoint = false

    --消费返利
    local dataList = {}
    local dataItemList = CampaignManager.Instance:GetCampaignDataList(CampaignEumn.Type.OpenServer) --开服活动
    for i,v in ipairs(dataItemList) do
        local baseData = DataCampaign.data_list[v.id]
        if baseData ~= nil and baseData.index == CampaignEumn.OpenServerType.ConsumeReturn then --消费返利
            if v.status == CampaignEumn.Status.Finish then
                --完成未领取
                isNeedShowPoint = true
                break
            end
        end
    end
    self.redPointDic[81] = (self.campaignTab[81] ~= nil and isNeedShowPoint == true)
    if MainUIManager.Instance.MainUIIconView ~= nil then
        MainUIManager.Instance.MainUIIconView:set_icon_Redpoint_by_id(301, self.redPointDic[81] or self.redPointDic[374])
    end
    --其他活动情况
    if isNeedShowPoint == false then
    end
    return isNeedShowPoint
end

function CampaignManager:IsNeedHideRechargeByPlatformChanleId()
    --不屏蔽充值
    -- if ctx.PlatformChanleId == 13 then
    --     return true
    -- end
    return false
end

function CampaignManager:CheckChildRedPoint()
    -- 累计登录
    self.redPointDic[99] = (self.campaignTab[99] ~= nil and self.campaignTab[99].status == CampaignEumn.Status.Finish)
    self.redPointDic[100] = (self.campaignTab[100] ~= nil and self.campaignTab[100].status == CampaignEumn.Status.Finish)
    self.redPointDic[101] = (self.campaignTab[101] ~= nil and self.campaignTab[101].status == CampaignEumn.Status.Finish)

    -- 礼包
    self.redPointDic[104] = (self.campaignTab[104] ~= nil and self.campaignTab[104].status == CampaignEumn.Status.Finish)

    -- 食盒制作
    if self.campaignTree ~= nil and self.campaignTree[CampaignEumn.Type.Children] ~= nil and self.campaignTree[CampaignEumn.Type.Children][CampaignEumn.ChildType.Cake] ~= nil then
        for _,sub in ipairs(self.campaignTree[CampaignEumn.Type.Children][CampaignEumn.ChildType.Cake].sub) do
            local campaignData = DataCampaign.data_list[sub.id]
            local full = (sub.status ~= CampaignEumn.Status.Accepted)
            for _,item in ipairs(campaignData.loss_items) do
                if item[2] > BackpackManager.Instance:GetItemCount(item[1]) then
                    full = full and false
                end
            end
            self.redPointDic[sub.id] = full
        end
    end

    -- 累计充值
    self.redPointDic[113] = (self.campaignTab[113] ~= nil and self.campaignTab[113].status == CampaignEumn.Status.Finish)
    self.redPointDic[114] = (self.campaignTab[114] ~= nil and self.campaignTab[114].status == CampaignEumn.Status.Finish)

    self:CheckRedPoint()
    BaseUtils.dump(self.redPointDic,"redPointDich")
end

-- 根据自身等级性别职业筛选礼包数据
function CampaignManager.ItemFilter(reward)
    local list = {}
    local lev = RoleManager.Instance.RoleData.lev
    local classes = RoleManager.Instance.RoleData.classes
    local sex = RoleManager.Instance.RoleData.sex
    for _,item in ipairs(reward) do
        if #item == 2 then
            table.insert(list, {item[1], item[2]})
        elseif #item == 3 then
            table.insert(list, {item[1], item[3]})
        elseif #item == 4 then
            if (item[1] == 0 or item[1] == classes) and (item[2] == 2 or item[2] == sex) then
                table.insert(list, {item[3], item[4]})
            elseif item[2] >= 10000 then
                table.insert(list, {item[2], item[3]})
            end
        elseif #item == 6 then
            if (lev >= item[1] and lev <= item[2]) and (item[3] == 0 or item[3] == classes) and (item[4] == 2 or item[4] == sex) then
                table.insert(list, {item[5], item[6]})
            end
        elseif #item == 7 then
            if (lev >= item[1] and lev <= item[2]) and (item[3] == 0 or item[3] == classes) and (item[4] == 2 or item[4] == sex) then
                table.insert(list, {item[5], item[6],item[7]})
            end
        end
    end
    return list
end

-- 根据自身等级性别职业筛选礼包(data_item_gift)格式数据,is_effet(SevenLoginTipsPanel需要)
function CampaignManager.ItemFilterForItemGift(giftdata)
    if giftdata == nil then return end
    local list = {}
    local lev = RoleManager.Instance.RoleData.lev
    local classes = RoleManager.Instance.RoleData.classes
    local sex = RoleManager.Instance.RoleData.sex
    for _,dat in ipairs(giftdata) do
        if dat.sex == 2 or dat.sex == sex then 
            if dat.classes == 0 or dat.classes == classes then 
                if dat.lev_low == 0 or dat.lev_high == 0 or (dat.lev_low <= lev and dat.lev_high >= lev) then 
                    table.insert(list, {item_id = dat.item_id, num = dat.num, is_effet = dat.is_effect or 0})
                end
            end
        end
    end
    return list
end


--判断亲密度排行榜活动是否开启
function CampaignManager:CheckIntimacy()
    local isOpen = false
    -- local valentDatat = CampaignManager.Instance.campaignTree[CampaignEumn.Type.QiXi]
    -- if valentDatat == nil then
    --     return false
    -- end
    -- local campaignDatat = valentDatat[CampaignEumn.QiXi.Intimacy];
    -- if campaignDatat == nil then
    --     return false
    -- end
    -- for _, item in pairs(campaignDatat.sub) do
    --     if item.id == MayIOUManager.Instance.menuId.Intimacy then
    --         isOpen = true
    --         break
    --     end
    -- end

    local beginTime = DataCampaign.data_list[1195].cli_start_time[1]
    local endTime = DataCampaign.data_list[1195].cli_end_time[1]

    local BeginTime = tonumber(os.time { year = beginTime[1], month = beginTime[2], day = beginTime[3], hour = beginTime[4], min = beginTime[5], sec = beginTime[6] })
    local EndTime = tonumber(os.time { year = endTime[1], month = endTime[2], day = endTime[3], hour = endTime[4], min = endTime[5], sec = endTime[6] })

    local baseTime = BaseUtils.BASE_TIME

    if BeginTime < baseTime and baseTime < EndTime then
        isOpen = true
    else
        isOpen = false
    end
    return isOpen
end
-- 判断活动排行榜是否开启
function CampaignManager:CheckCampaignRank(rankType)
    local isOpen = false
     local treeData = CampaignManager.Instance.campaignTree[CampaignEumn.Type.QiXi]
    if treeData == nil then
        return false
    end
    local campaignDatat = treeData[CampaignEumn.QiXiType.Intimacy];
    if campaignDatat == nil then
        return false
    end
    local base_id = WorldLevType
    for _, item in pairs(campaignDatat.sub) do
        if item.id == MayIOUManager.Instance.menuId.Intimacy then
            isOpen = true
            break
        end
    end
    return isOpen
end

function CampaignManager:CheckTreasureHuntingRedPoint()
    if self.model.cardData == nil then
        return
    end

    local red = false
    local times = self.model.cardData.times+1
    local activity = RoleManager.Instance.RoleData.naughty
    if self.model.card_act_cost[times] ~= nil then
        local limit = self.model.card_act_cost[times]
        if limit.acticity > 0 then
            if limit.acticity <= activity then
                red = true
            end
        end
    end
    self.model.redPointList[735] = red
    self.model:ReloadIconById(735)
    EventMgr.Instance:Fire(event_name.campaign_change)
end

--oppo渠道社区图标按钮
function CampaignManager:ShowCommunityIcon()
    local activeIconData = AtiveIconData.New()
    activeIconData.id = 99
    activeIconData.iconPath = "I18NCommunityButton"
    activeIconData.sort = 1
    activeIconData.lev = 30
    if BaseUtils.CSVersionToNum() < 10706 then
        activeIconData.clickCallBack = function() SdkManager.Instance:OpenOnlineGmWindow("oppo") end
    else
        activeIconData.clickCallBack = function() SdkManager.Instance:OpenOnlineGmWindow("callOppoForum") end
    end
    
    MainUIManager.Instance:AddAtiveIcon(activeIconData)
end

function CampaignManager.CheckCampaignStatus(campaignId)
    --0:不存在此活动 1:开启中 2:活动尚未开启 3:活动已经结束
    if CampaignManager.Instance.campaignTab[campaignId] ~= nil then
        return 1
    else
        if DataCampaign.data_list[campaignId] == nil then
            Log.Error("活动Id不存在:"..campaignId)
            return 0
        end
        local NowTime = BaseUtils.BASE_TIME
        local startTime = DataCampaign.data_list[campaignId].cli_start_time[1]
        local endTime = DataCampaign.data_list[campaignId].cli_end_time[1]
        local startTimeStamp = os.time({year = startTime[1], month = startTime[2], day = startTime[3], hour = startTime[4], min = startTime[5], sec = startTime[6]})
        local endTimeStamp = os.time({year = endTime[1], month = endTime[2], day = endTime[3], hour = endTime[4], min = endTime[5], sec = endTime[6]})
        if NowTime < startTimeStamp then
            return 2
        elseif NowTime > endTimeStamp then
            return 3
        else
            Log.Error("服务端未开启该活动Id:"..campaignId)
            return 0
        end
    end
end


--通过活动id得到活动标题
function CampaignManager.GetTitleNameByCampaignId(campaignId)
    if DataCampaign.data_list[campaignId] == nil then 
        Log.Error("活动id不存在，id:%s",campaignId)
    end
    local campaignIconType = DataCampaign.data_list[campaignId].iconid
    local dataCampIco = DataCampaign.data_camp_ico[tonumber(campaignIconType)] 
    if dataCampIco ~= nil then 
        if dataCampIco.title_name ~= "" then 
            return dataCampIco.title_name
        end
    end

    return "I18NQdkh"
end