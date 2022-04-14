SearchTreasureModel = SearchTreasureModel or class("SearchTreasureModel", BaseBagModel)
local SearchTreasureModel = SearchTreasureModel
local tableInsert = table.insert

function SearchTreasureModel:ctor()
    SearchTreasureModel.Instance = self
    self:Reset()

    self.rewards = {}      --存放普通奖励
    self.rare_rewards = {} --存放珍惜奖励
    self:InitRewards()  --从配置表里读取奖励

    self.gold_key_id = 11006  --寻宝钥匙
    self.silver_key_id = 11046 --巅峰钥匙
    self.score_key_id = 90010021  --积分icon
    self.gundam_key_id = 11012--机甲钥匙
    self.supermecy_key_id = 11013--至尊钥匙
end

function SearchTreasureModel:Reset()
    self.info = {}

    self.storage_opened = 0
    self.act_id = 0
    self.storage_items = {}
    self.messages = {}
    self.first_login = true
end

function SearchTreasureModel.GetInstance()
    if SearchTreasureModel.Instance == nil then
        SearchTreasureModel()
    end
    return SearchTreasureModel.Instance
end

--从配置表里读取奖励
function SearchTreasureModel:InitRewards()
    for reward_id, item in pairs(Config.db_searchtreasure_rewards) do
        local type_id = item.type_id
        local batch_id = item.batch_id
        if item.is_notice == 1 then
            local is_rare = item.is_rare
            self.rewards[type_id] = self.rewards[type_id] or {}
            self.rewards[type_id][batch_id] = self.rewards[type_id][batch_id] or {}
            self.rare_rewards[type_id] = self.rare_rewards[type_id] or {}
            self.rare_rewards[type_id][batch_id] = self.rare_rewards[type_id][batch_id] or {}

            --同一类型 同一批次的奖励id放进一张表里
            if is_rare == 0 then
                table.insert(self.rewards[type_id][batch_id], reward_id)
            else
                table.insert(self.rare_rewards[type_id][batch_id], reward_id)
            end
        end
    end

    --排序这些奖励id
    for type_id, item in pairs(self.rewards) do
        for batch_id, rewards in pairs(item) do
            table.sort(rewards)
        end
    end
    for type_id, item in pairs(self.rare_rewards) do
        for batch_id, rewards in pairs(item) do
            table.sort(rewards)
        end
    end
end

--更新寻宝信息
function SearchTreasureModel:UpdateInfo(data)
    local type_id = data.type_id
    self.info[type_id] = self.info[type_id] or {}
    self.info[type_id].batch_id = data.batch_id
    self.info[type_id].bless_value = data.bless_value
    self.info[type_id].turn = data.turn
    if data.show_add ~= "undefined" then
        self.info[type_id].show_add = data.show_add
    else
        self.info[type_id].show_add = 0
    end
end

--获取寻宝信息
function SearchTreasureModel:GetInfo(type_id)
    return self.info[type_id] or {}
end

--清空寻宝信息
function SearchTreasureModel:ClearInfo()
    self.info = {}
end

--根据type_id,batch_id获取奖励
function SearchTreasureModel:GetRewardIds(type_id, batch_id)
    return self.rewards[type_id][batch_id]
end

function SearchTreasureModel:GetRareRewardIds(type_id, batch_id)
    return self.rare_rewards[type_id][batch_id]
end

--更新仓库
function SearchTreasureModel:UpdateStorage(data)
    if data.bag_id ~= BagModel.stHouseId then
        return
    end
    self.storage_opened = data.opened
    self.storage_items = data.items
end

--更新寻宝记录
function SearchTreasureModel:UpdateMessages(type_id, is_global, messages, is_add_new)
    self.messages[type_id] = self.messages[type_id] or {}
    self.messages[type_id][is_global] = self.messages[type_id][is_global] or {}
    if is_add_new == 1 then
        for i = 1, #messages do
            table.insert(self.messages[type_id][is_global], messages[i])
        end
    else
        self.messages[type_id][is_global] = messages
    end
end

--获取寻宝记录
function SearchTreasureModel:GetMessages(type_id, is_global)
    return self.messages[type_id] and self.messages[type_id][is_global] or nil
end

--设置寻宝结果
function SearchTreasureModel:SetSearchResult(reward_ids)
    self.reward_ids = reward_ids
end

--获取寻宝结果
function SearchTreasureModel:GetSearchResult()
    return self.reward_ids
end

function SearchTreasureModel:GetYYLotteryRewards(act_id)
    local results = {}
    local rare
    for k, v in pairs(Config.db_yunying_lottery_rewards) do
        if v.yunying_id == act_id and v.is_self == 1 then
            if v.is_rare == 0 then
                tableInsert(results, v)
            else
                rare = v
            end
        end
    end
    return results, rare
end

function SearchTreasureModel:GetYYLotteryRewardsByKey(id)
    return Config.db_yunying_lottery_rewards[id]
end

--检查限时寻宝红点
function SearchTreasureModel:CheckTimelimitedTreasureHuntReddot(  )
    if OpenTipModel.GetInstance():IsOpenSystem(191, 1) then

        -- local act_id
        -- local key  = "191@1"
        -- for k,v in pairs(OperateModel.GetInstance().act_list) do
        --     local cfg = Config.db_yunying[v.id]
        --     if cfg and cfg.panel == key then
        --         act_id = v.id
        --         break
        --     end
        -- end

        local item_id = 11014
        -- local cfg = Config.db_yunying[act_id]
        -- local reqs = String2Table(cfg.reqs)
        
        -- for k,v in pairs(reqs) do
        --     if v[1] == "cost" then
        --         item_id = v[2][1][2]
        --         break
        --     end
        -- end

        local num = BagModel:GetInstance():GetItemNumByItemID(item_id)
        if num > 0 then
            --logError("限时寻宝红点检查-true")
            return  true
        end
    end
    --logError("限时寻宝红点检查-false")
    return false
end
