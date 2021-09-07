-- @author hze
-- @date #2019/05/28#


CampaignProtoModel = CampaignProtoModel or BaseClass(BaseModel)

function CampaignProtoModel:__init()
    self.mgr = CampaignProtoManager.Instance

    self.luckytreeData = {} -- 幸运树数据
    self.getItemMark = false
    
    self.warOrderData = {}
    self.warOrderHasGet = {}
    self.warOrderQuestData = {}
    self.highLevelWarStatus = false  --是否购买高级战令

    self.customGiftData = {}    --定制礼包数据  
    self.selectReward = {}  --定制礼包选择奖励
    self.customGiftAllRewards = {}  --定制礼包所有奖励

    self.prayTreasureSelectTab = {} --服务端选择奖池内容
    self.prayTreasureCliSelectTab = {} --玩家手动选择奖池内容
    self.praytreasure_shoplist = {} --祈愿宝阁兑换商店
end

function CampaignProtoModel:__delete()
end

-------------------幸运树摇一摇活动------------------
--幸运树摇一摇活动窗口
function CampaignProtoModel:OpenLuckyTreeWindow(args)
    if self.lucktreewin == nil then
        self.lucktreewin = LuckyTreeWindow.New(self)
    end
    self.lucktreewin:Open(args)
end

function CampaignProtoModel:CloseLuckyTreeWindow()
    WindowManager.Instance:CloseWindow(self.lucktreewin)
end

function CampaignProtoModel:SetLuckyTreeData(data)
    local luckytree_data = {}
    luckytree_data.cost_item = data.cost_item
    luckytree_data.times = data.times
    luckytree_data.num = data.num
    luckytree_data.exchang_val = data.exchang_val
    luckytree_data.list = {}                            --所有列表
    luckytree_data.unObtained_list = {}                 --未获得列表

    local index = 0
    for _,v in ipairs(data.reward_info) do
        local info = luckytree_data.list[v.site]
        if info == nil then 
            info = LuckyTreeDataVo.Create()
            luckytree_data.list[v.site] = info
        end
        info:SetData(v)

        if not info.isFlag then 
            index = index + 1
            luckytree_data.unObtained_list[index] = info
        end
    end

    luckytree_data.unObtainedLength = index

    --是否全部获得
    local finishFlag = true
    for _, dat in ipairs(luckytree_data.list) do
        if not dat.isFlag then 
            finishFlag = false
            break
        end
    end
    luckytree_data.finishFlag = finishFlag 

    self.luckytreeData = luckytree_data
end

-------------------战令活动------------------
--战令活动主窗口
function CampaignProtoModel:OpenWarOrderWindow(args)
    if self.warorderwin == nil then
        self.warorderwin = WarOrderWindow.New(self)
    end
    self.warorderwin:Open(args)
end

function CampaignProtoModel:CloseWarOrderWindow()
    WindowManager.Instance:CloseWindow(self.warorderwin)
end

--战令购买窗口
function CampaignProtoModel:OpenWarOrderBuyWindow(args)
    if self.warorderbuywin == nil then
        self.warorderbuywin = WarOrderBuyWindow.New(self)
    end
    self.warorderbuywin:Open(args)
end

function CampaignProtoModel:CloseWarOrderBuyWindow()
    WindowManager.Instance:CloseWindow(self.warorderbuywin)
end

--战令奖励预览面板
function CampaignProtoModel:OpenWarOrderPreviewPanel(args)
    if self.warorderpreviewpanel == nil then
        self.warorderpreviewpanel = WarOrderPreviewPanel.New(self)
    end
    self.warorderpreviewpanel:Show(args)
end

function CampaignProtoModel:CloseWarOrderPreviewPanel()
    if self.warorderpreviewpanel ~= nil then 
        self.warorderpreviewpanel:DeleteMe()
        self.warorderpreviewpanel = nil
    end
end

function CampaignProtoModel:UpdateWarOrderQuestData(data)
    self.warOrderQuestData = {}
    for _, v in ipairs(data.doing) do
        local vo = QuestManager.Instance:GetQuest(v.quest_id)
        if not vo then
            vo = QuestData.New()
            vo:SetBase(DataQuest.data_get[v.quest_id])
        end
        vo.cfg = WarOrderConfigHelper.GetQuest(v.quest_id)
        self.warOrderQuestData[v.quest_id] = vo
        if vo.finish == 1 then
            vo.sort = 2
        elseif vo.finish == 2 then
            vo.sort = 1
        else
            vo.sort = 3
        end
    end

    for _, v in ipairs(data.finish) do
        local vo = self.warOrderQuestData[v.quest_id]
        if not vo then
            vo = QuestData.New()
            vo:SetBase(DataQuest.data_get[v.quest_id])
            vo.cfg = WarOrderConfigHelper.GetQuest(v.quest_id)
            self.warOrderQuestData[v.quest_id] = vo
        end
        vo.finish = 3
        if vo.finish == 1 then
            vo.sort = 2
        elseif vo.finish == 2 then
            vo.sort = 1
        else
            vo.sort = 3
        end
    end
end


--是否购买高级战令
function CampaignProtoModel:GetHighLevelWarStatus()
    return self.highLevelWarStatus
end

--检查战令领取状态 0不可领取,1为可领取,2已领取
function CampaignProtoModel:GetWarOrderObtainedStatus(id, lev)
    local data = self.warOrderData.token_info or {}
    for i, v in ipairs(data) do
        if v.id == id then
            for j, vv in ipairs(v.can_draw) do
                if vv.lev_id == lev then 
                    return 1
                end
            end
        end
    end

    data = self.warOrderHasGet.token_info or {}
    for i, v in ipairs(data) do
        if v.id == id then
            for j, vv in ipairs(v.has_get) do
                if vv.lev_id == lev then
                    return 2
                end
            end
        end
    end
    
    return 0
end

--检查战令是否有可领取奖励(红点判断)
function CampaignProtoModel:GetWarOrderRedStatus()
    local data = self.warOrderData.token_info or {}
    for i, v in ipairs(data) do
        if #v.can_draw > 0 then 
            return true
        end
    end
    return false
end

--检查战令是否有可领取任务(红点判断)
function CampaignProtoModel:GetWarOrderQuestRedStatus()
    local idList = WarOrderConfigHelper.GetQuestIdList()
    for i, quest_id in ipairs(idList) do
        local vo = self.warOrderQuestData[quest_id]
        if vo and vo.finish == 2 then 
            return true
        end
    end
    return false
end


-------------------定制礼包------------------
-- 设置定制礼包活动数据
function CampaignProtoModel:UpdateCustomGiftData(data)
    local key = ""
    for i, v in pairs(data.gift) do
        local vo = self.customGiftData[v.gift_id] or {}
        if self.customGiftData[v.gift_id] == nil then 
            vo.cfg = DataCampGiftCustom.data_gifts[v.gift_id]
            vo.times = 0
            vo.limit_status = 0
            local date1 = vo.cfg.end_time[1][1]
            local date2 = vo.cfg.end_time[1][2]
            local end_time = os.time{year = date1[1], month = date1[2], day = date1[3], hour = date2[1], min = date2[2], sec = date1[2]}
            local timeGap = end_time - BaseUtils.BASE_TIME
            vo.day = math.ceil(timeGap / 86400)
            self.customGiftData[v.gift_id] = vo
        end
        key = BaseUtils.Key(key, v.gift_id)
    end
    
    for i, v in pairs(data.buy) do
        local vo = self.customGiftData[v.gift_id]
        if vo then 
            vo.times = v.times
            if vo.cfg.limit_times == v.times then
                vo.limit_status = 1
            end
        end
    end

    self.customgift_extra_reward = data.extra_reward

    self.customgift_key = key
    self:SetCustomGiftAllRewards(key)
end

-- 通过礼包id和槽口位置确认可获得奖励
function CampaignProtoModel:GetCustomGiftByIdPos(id, pos)
    local key = BaseUtils.Key(id, pos)
    local reward = DataCampGiftCustom.data_rewards[key]

    local list = {}
    local lev = RoleManager.Instance.RoleData.lev
    local sex = RoleManager.Instance.RoleData.sex
    local classes = RoleManager.Instance.RoleData.classes

    for i, v in ipairs(reward) do
        if (lev >= v.lev_min and lev <= v.lev_max) or (v.lev_min == 0 and v.lev_max == 0) then
            if classes == v.classes or v.classes == 0 then 
                if sex == v.sex or v.sex == 2 then
                    local dat = {}
                    dat.index = v.index
                    dat.item_id = v.item_id
                    dat.item_name = v.item_name
                    dat.item_num = v.item_num
                    dat.effect = v.effect
                    dat.pos = v.pos
                    table.insert(list, dat)
                end
            end
        end
    end
    return list
end

-- 获得槽的选中奖励位置和奖励序号
function CampaignProtoModel:GetSelectRewardById(gift_id, index)
    local data = (self.selectReward[gift_id] or {})[index]
    if data then 
        for i, v in pairs(data) do
            if v.select then
                return i, v.itemVo.index
            end
        end
    end
    return nil
end

-- 得到定制礼包所有奖励
function CampaignProtoModel:SetCustomGiftAllRewards(key)
    if self.customGiftAllRewards[key] then 
        return
    end

    local list = {}
    local lev = RoleManager.Instance.RoleData.lev
    local sex = RoleManager.Instance.RoleData.sex
    local classes = RoleManager.Instance.RoleData.classes

    for i, v in ipairs(DataCampGiftCustom.data_all_rewards) do
        if (lev >= v.lev_min and lev <= v.lev_max) or (v.lev_min == 0 and v.lev_max == 0) then
            if classes == v.classes or v.classes == 0 then
                if sex == v.sex or v.sex == 2 then
                    list[v.id] = list[v.id] or {}
                    table.insert(list[v.id], v)
                end
            end
        end
    end
    self.customGiftAllRewards[key] = list
end

function CampaignProtoModel:OpenCustomGiftRewardPanel(gift_id)
    if self.rewardPreviewPanel2 == nil then
        self.rewardPreviewPanel2 = RewardPreviewPanel2.New(self)
    end
    local data = (self.customGiftAllRewards[self.customgift_key] or {})[gift_id]
    local cfg = DataCampGiftCustom.data_gifts[gift_id]
    local title = string.format(TI18N("%s{assets_2,%s}可获得该礼包全部奖励"), cfg.all_loss[1][2], cfg.all_loss[1][1])
    self.rewardPreviewPanel2:Show({data, title})
end


-------------------祈愿宝阁------------------
--祈愿宝阁窗口
function CampaignProtoModel:OpenPrayTreasureWindow(args)
    if self.praytreasurewin == nil then
        self.praytreasurewin = PrayTreasureWindow.New(self)
    end
    self.praytreasurewin:Open(args)
end

function CampaignProtoModel:ClosePrayTreasureWindow()
    WindowManager.Instance:CloseWindow(self.praytreasurewin)
end

function CampaignProtoModel:OpenPrayTreasureRewardPanel()
    -- if self.rewardPreviewPanel2 == nil then
    --     self.rewardPreviewPanel2 = RewardPreviewPanel2.New(self)
    -- end
    -- local list = {}
    -- for id, _ in pairs(self.prayTreasureCliSelectTab) do
    --     local reward = DataCampPray.data_reward[id]
    --     table.insert(list, {item_id = reward.item_id, item_num = reward.count, effect = (reward.is_eff == 1 and 20138 or 0), pool_id = reward.pool_id})
    -- end
    -- table.sort( list, function(a, b)  return a.pool_id < b.pool_id end)
    -- -- local title = string.format(TI18N("%s{assets_2,%s}可获得该礼包全部奖励"), cfg.all_loss[1][2], cfg.all_loss[1][1])
    -- local title = TI18N("可随机获得以下道具中的一个")
    -- self.rewardPreviewPanel2:Show({list, title})

    local list = {}
    for id, _ in pairs(self.prayTreasureCliSelectTab) do
        local reward = DataCampPray.data_reward[id]
        table.insert(list, {item_id = reward.item_id, num = reward.count, is_effet = reward.is_eff, pool_id = reward.pool_id})
    end
    table.sort( list, function(a, b)  return a.pool_id < b.pool_id end)

    local callBack = function(myself)
        myself.gameObject.transform.localPosition = Vector3(myself.gameObject.transform.localPosition.x, myself.gameObject.transform.localPosition.y, 200)
    end

    if self.possibleReward == nil then
        self.possibleReward = SevenLoginTipsPanel.New(self, callBack)
    end

    self.possibleReward:Show({list, 4, {140, 140, 120, 120}, TI18N("可随机获得以下道具之一")})
end

function CampaignProtoModel:CampPrayInfo(data)
    self.pray_reset_times = data.reset_times
    self.prayTreasureSelectTab = data.choose_ids or {}
    for _, v in pairs(self.prayTreasureSelectTab) do
        self.prayTreasureCliSelectTab[v.id] = true
    end
end

function CampaignProtoModel:SelectRewardPool()
    local choose_items = {}
    for id, _ in pairs(self.prayTreasureCliSelectTab) do
        table.insert(choose_items, {id = id})
    end
    self.mgr:Send21201(choose_items)
end

function CampaignProtoModel:GetPrayTreasureSelectStatus()
    if #self.prayTreasureSelectTab > 0 then
        return true
    end
    return false
end

function CampaignProtoModel:CleanPrayTreasureCliSelectTab()
    self.prayTreasureCliSelectTab = {}
end

function CampaignProtoModel:GetSelectListByPoolId(poolId)
    local list = {}
    for id, _ in pairs(self.prayTreasureCliSelectTab) do
        local cfg = DataCampPray.data_reward[id]
        if poolId == cfg.pool_id then
            table.insert(list, id)
        end
    end
    return list
end

function CampaignProtoModel:GetFullSelectList()
    local count = 0
    for id, _ in pairs(self.prayTreasureCliSelectTab) do
        count = count + 1
    end

    local total_count = 0
    for i, v in ipairs(DataCampPray.data_pool) do
        total_count = total_count + v.count
    end
    return ((count == total_count) and total_count ~= 0 )
end

--祈愿宝阁主红点
function CampaignProtoModel:GetPrayTreasureMainRedStatus()
    self.lossItemId = DataCampPray.data_other[2].value1[1]
    return BackpackManager.Instance:GetItemCount(self.lossItemId) > 0
end

--祈愿宝阁兑换商店红点
function CampaignProtoModel:GetPrayTreasureShopRedStatus()
    local assets_type = ((self.praytreasure_shoplist or {})[1] or {}).assets_type or "camp_pray_sc"
    for i, v in ipairs(self.praytreasure_shoplist) do
        if RoleManager.Instance.RoleData[assets_type] >= v.price then
            return true
        end
    end
    return false
end

-------------------公用函数------------------
--获取活动时间格式文本
function CampaignProtoModel:GetCampaignTimeStr(campaignId, style)
    local dataFormatStr = TI18N("活动时间:%s月%s日-%s月%s日")
    if style == 1 then 
        dataFormatStr = TI18N("活动时间:<color='#248813'>%s月%s日-%s月%s日</color>")
    elseif style == 2 then 
        dataFormatStr = TI18N("%s月%s日-%s月%s日")
    end
    print(campaignId)
    local baseData = DataCampaign.data_list[campaignId]
    local startTime = baseData.cli_start_time[1]
    local endTime = baseData.cli_end_time[1]
    return string.format(dataFormatStr, tostring(startTime[2]), tostring(startTime[3]), tostring(endTime[2]), tostring(endTime[3]))
end



