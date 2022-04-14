FlopGiftModel = FlopGiftModel or class('FlopGiftModel',BaseModel)

function FlopGiftModel:ctor()
    FlopGiftModel.Instance = self

    self:Reset()

    self.all_card_count = 8  --全部卡牌数量

    self.flop_gift_cfg = {}
    for k,v in pairs(Config.db_yunying_flop_gift) do
        self.flop_gift_cfg[v.round] = v
    end

    self.reward_cfg = {} --各轮奖励配置 {轮数-{奖励配置,奖励配置,...}} --奖励配置={min_lv最小等级,max_lv最大等级, big_reward_id大奖id,show_reward{展示奖励id,展示奖励id,...}}
    for i=1,#self.flop_gift_cfg do
        local v = self.flop_gift_cfg[i]
        local reward = String2Table(v.reward)
        local reward_show = String2Table(v.reward_show)
        for j=1,#reward do
            local vv = reward[j]

            --等级
            local min_lv = vv[1][1]
            local max_lv = vv[1][2]

            --大奖
            local big_reward_id = vv[2][1][2]

            --展示奖励
            local vvv = reward_show[j]
            local show_reward = vvv[3]
            local tab = {}

            tab.min_lv = min_lv
            tab.max_lv = max_lv
            tab.big_reward_id = big_reward_id
            tab.show_reward = show_reward

            self.reward_cfg[i] = self.reward_cfg[i] or {}
            table.insert( self.reward_cfg[i], tab )
        end
    end

    self.cost = {}  --刷新消耗表{轮数-{{id,数量},...}}
end

function FlopGiftModel:Reset()

    self.cur_act_lv = 1 --当前翻牌活动处理的等级

    self.cur_round = 1 --当前轮次

    self.round_get_data = {}  --所有轮次已获得奖励 {轮数-{{物品id,物品数量num},...}}
    
    self.card_data = {} --卡牌数据{卡牌pos-{物品id,数量},...}

    self.is_get_big_reward = false --当前轮是否已抽中大奖

end

function FlopGiftModel.GetInstance()
    if FlopGiftModel.Instance == nil then
        FlopGiftModel.new()
    end
    return FlopGiftModel.Instance
end


--设置轮次数据
function FlopGiftModel:SetRoundData(data)

    self.round_get_data = {}
    self.card_data = {}

    for i=1,#data do

        local v = data[i]

        self.round_get_data[v.round] =  self.round_get_data[v.round] or {}

        for j=1,#v.fetch do
            local vv = v.fetch[j]

            self:UpdateRoundGetData(v.round,vv)

            if v.round == self.cur_round then
                --处理下当前轮卡牌数据
                self:UpdateCardData(vv)


            end
        end



    end
end

--更新轮次已抽取奖励数据
function FlopGiftModel:UpdateRoundGetData( round,data )
    self.round_get_data[round] = self.round_get_data[round] or {}

    local tab = {data.item_id,data.item_count}

    table.insert( self.round_get_data[round],tab)
end

--更新卡牌数据
function FlopGiftModel:UpdateCardData(data )
    self.card_data[data.pos] = {data.item_id,data.item_count}
end

--获取指定轮次和当前活动处理等级的奖励配置
function FlopGiftModel:GetRewardCfg(round)
    for i=1,#self.reward_cfg[round] do
        local v = self.reward_cfg[round][i]
        if self.cur_act_lv >= v.min_lv and self.cur_act_lv <= v.max_lv then
            return v
        end
    end
end

--获取当前活动处理等级的所有轮次的展示奖励
function FlopGiftModel:GetShowReward(  )
    local result = {}
    for i=1,#self.reward_cfg do
        local cfg = self:GetRewardCfg(i)
        result[i] = cfg.show_reward
    end

    return result
end

--当前轮是否已抽中大奖
function FlopGiftModel:IsGetBigReward(item_id)

    local big_reward_id = self:GetRewardCfg(self.cur_round).big_reward_id
    if item_id then
        --有可对比物品id时直接进行对比
        return item_id == big_reward_id
    end

    if not self.round_get_data[self.cur_round] then
        return  false
    end

    --否则遍历当前轮抽到的物品
    for i,v in pairs(self.round_get_data[self.cur_round]) do
        if v[1] == big_reward_id then
            return true
        end
    end
    return false
end

--指定物品id是否已抽中
function FlopGiftModel:IsGet(round,item_id,num)



    if not self.round_get_data[round] then
        return false
    end

    for k,v in pairs(self.round_get_data[round]) do
        if item_id == v[1] and num == v[2] then
            return true
        end
    end

    return false
end

--获取指定卡牌翻开后的物品id和数量
--如果没翻开就返回nil
function FlopGiftModel:GetCardItem( pos )
    return self.card_data[pos]
end

--获取翻牌消耗物品id和数量
function  FlopGiftModel:GetCost(  )
    if not self.cost[self.cur_round] then
        self.cost[self.cur_round] = String2Table(self.flop_gift_cfg[self.cur_round].cost)
    end

    local count = table.nums(self.card_data) + 1
    return self.cost[self.cur_round][count]
end

--是否为最后一轮
function FlopGiftModel:IsLastRound(  )
    return self.cur_round == #self.flop_gift_cfg
end

--是否已翻完当前轮所有卡牌
function FlopGiftModel:IsAllTurnCard(  )
    local num = table.nums(self.card_data)
    return num == self.all_card_count
end

--红点检查
--是否有牌没翻完 或者可以刷新
function FlopGiftModel:CheckReddot(  )
    if self:IsAllTurnCard() then
        if self:IsLastRound() then
            --牌翻完 最后一轮
            return  false
        else
            --牌翻完 可刷新到下一轮
            return  true
        end
    end

    --牌没翻完
    return  true
end