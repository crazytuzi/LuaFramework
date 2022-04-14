STResultPanel = STResultPanel or class("STResultPanel", BaseRewardPanel)
local STResultPanel = STResultPanel

function STResultPanel:ctor()
    self.abName = "search_treasure"
    self.assetName = "STResultPanel"
    self.layer = "UI"

    self.use_background = true
    self.change_scene_close = true
    self.is_hide_other_panel = true

    self.item_list = {}

    self.btn_list = {
        { btn_res = "common:btn_yellow_2", btn_name = ConfigLanguage.Mix.Confirm, format = "Auto closing in %s sec", auto_time = 10, call_back = handler(self, self.OkFunc) },
        -- 说明
        { btn_res = "common:btn_blue_2", btn_name = ConfigLanguage.SearchT.SearchOne, call_back = handler(self, self.SearchOne) },
        { btn_res = "common:btn_blue_2", btn_name = ConfigLanguage.SearchT.SearchTen, call_back = handler(self, self.SearchTen) },
        { btn_res = "common:btn_blue_2", btn_name = ConfigLanguage.SearchT.SearchFifty, call_back = handler(self, self.SearchFifty) },
        -- {btn_res = "common:btn_blue_2",btn_name = "按钮2",format = "%s倒计时",auto_time = 5,call_back = handler(self,self.Close)},
        -- {btn_res = "common:btn_blue_2",btn_name = "按钮2",auto_time = 5,call_back = handler(self,self.Close)},
    }
    self.model = SearchTreasureModel:GetInstance()
end

function STResultPanel:dctor()
end

function STResultPanel:Open(type_id)
    STResultPanel.super.Open(self)
    self.type_id = type_id
end

function STResultPanel:LoadCallBack()
    self.nodes = {
        "ScrollView/Viewport/Content", "ScrollView/Viewport",
        "tips2/value1", "tips3/value2", "ScrollView", "tips2", "tips3", "tips1",
        "tips1/value0", "tips1/zuanshi", "tips2/zuanshi2", "tips3/zuanshi3",
        "jifen/img_jifen", "jifen/txt_jifenNum",
    }
    self:GetChildren(self.nodes)
    self:SetMask()
    self.value1 = GetText(self.value1)
    self.value2 = GetText(self.value2)
    self.value0 = GetText(self.value0)
    self.zuanshi = GetImage(self.zuanshi)
    self.zuanshi2 = GetImage(self.zuanshi2)
    self.zuanshi3 = GetImage(self.zuanshi3)
    self.img_jifen = GetImage(self.img_jifen)
    self.txt_jifenNum = GetText(self.txt_jifenNum)

    local function schedule_fun()
        self:Close()
    end

    self:AddEvent()
end

function STResultPanel:DoSearch(num, need_gold)
    local bo = RoleInfoModel:GetInstance():CheckGold(need_gold, Constant.GoldType.Gold)
    if not bo then
        return
    end
    SearchTreasureController:GetInstance():RequestSearch(self.type_id, num)
    --self:Close()
end

function STResultPanel:RequestSearch(num)

    local keyId
    local key
    if self.type_id == 1 then
        keyId = self.model.gold_key_id
        key = "Golden Key"
    elseif self.type_id == 2 then
        keyId = self.model.silver_key_id
        key = "Silver Key"
    elseif self.type_id == 3 then
        keyId = self.model.gundam_key_id
        key = "Memory Chip"
    elseif self.type_id == 4 then
        keyId = self.model.supermecy_key_id
        key = "Ultimate Key"
    end

    local had_num = BagController:GetInstance():GetItemListNum(keyId)
    if had_num >= num then
        self:DoSearch(num, 0)
    else
        local batch = Config.db_searchtreasure_batch[self.model.batch_id]
        local cost = String2Table(batch.cost)
        local need_num = 1
        for i = 1, #cost do
            if num == cost[i][1] then
                need_num = cost[i][3]
                break
            end
        end
        local gold_num = need_num - had_num

        local gold = Config.db_voucher[keyId].price * gold_num

        local message = ""
        if had_num > 0 then
            message = string.format(ConfigLanguage.SearchT.AlertMsg5, key, gold, key, gold_num)
        else
            message = string.format(ConfigLanguage.SearchT.AlertMsg4, key, gold, key, gold_num)
        end
        if self.model.is_check then
            self:DoSearch(num, gold)
        else
            local function ok_fun(is_check)
                self.model.is_check = is_check
                self:DoSearch(num, gold)
            end
            Dialog.ShowTwo(ConfigLanguage.SearchT.TipsTitle, message, nil, ok_fun, nil, nil, nil, nil, ConfigLanguage.SearchT.NoAlert, false)
        end
    end
end

function STResultPanel:OkFunc()
    self:FinishEffect()
    self:Close()
end

function STResultPanel:SearchOne()
    self:FinishEffect()
    self:RequestSearch(1)
end

function STResultPanel:SearchTen()
    self:FinishEffect()
    self:RequestSearch(10)
end

function STResultPanel:SearchFifty()
    self:FinishEffect()
    self:RequestSearch(50)
end

function STResultPanel:AddEvent()
    local function call_back()
        self:UpdateView()
        self.back_ground.item_list[1]:StartTime()
    end
    self.event_id = self.model:AddListener(SearchTreasureEvent.SearchResult, call_back)
end

function STResultPanel:OpenCallBack()
    self:UpdateView()
end

--添加寻宝结果物品（创建UI）
function STResultPanel:AddGoodsItem()
    local reward_ids = self.model:GetSearchResult()
    local i = self.cur_index --当前物品索引
    local rewarditem = Config.db_searchtreasure_rewards[reward_ids[i]]
    if not rewarditem then
        return
    end
    local rewards = String2Table(rewarditem.rewards)
    local item_id = rewards[1]
    local num = rewards[2]
    local bind = rewards[3] or 1
    local goods = self.item_list[i] or STGoodsItem(self.Content)
    goods:SetData(item_id, num, bind, self.StencilId)
    self.item_list[i] = goods
    self.cur_index = i + 1

    if i >= 30 then
        self.schedule:Stop(self.schedule_id)
        for j = i, #reward_ids do
            local rewarditem = Config.db_searchtreasure_rewards[reward_ids[j]]
            local rewards = String2Table(rewarditem.rewards)
            item_id = rewards[1]
            num = rewards[2]
            bind = rewards[3] or 1
            local goods = self.item_list[j] or STGoodsItem(self.Content)
            goods:SetData(item_id, num, bind, self.StencilId)
            self.item_list[j] = goods
        end
    end
    if i == #reward_ids or i >= 30 then
        if #self.item_list > #reward_ids then
            for i = #self.item_list, #reward_ids + 1, -1 do
                self.item_list[i]:destroy()
                self.item_list[i] = nil
            end
        end
    end
end

--显示剩下的奖励
function STResultPanel:ShowLeftRewards()
    local reward_ids = self.model:GetSearchResult()
    if self.cur_index < #reward_ids then
        for i = self.cur_index, #reward_ids do
            local rewarditem = Config.db_searchtreasure_rewards[reward_ids[i]]
            local rewards = String2Table(rewarditem.rewards)
            item_id = rewards[1]
            num = rewards[2]
            bind = rewards[3] or 1
            local goods = self.item_list[i] or STGoodsItem(self.Content)
            goods:SetData(item_id, num, bind, self.StencilId)
            self.item_list[#self.item_list + 1] = goods
        end
    end
end

--结束特效展示
function STResultPanel:FinishEffect()
    if self.schedule_id then
        self:ShowLeftRewards()
        self.schedule:Stop(self.schedule_id)
        self.schedule_id = nil
    end
    self.back_ground.item_list[1]:StopTime()
end

function STResultPanel:UpdateView()
    for i = 1, #self.item_list do
        self.item_list[i]:destroy()
    end
    self.item_list = {}
    self.cur_index = 1
    local reward_ids = self.model:GetSearchResult()
    local count = #reward_ids
    if count == 1 then
        SetLocalPositionY(self.ScrollView.transform, -60)
    elseif count == 10 then
        SetLocalPositionY(self.ScrollView.transform, -60)
    else
        SetLocalPositionY(self.ScrollView.transform, 33)
    end
    self.schedule = Schedule()
    self.schedule_id = self.schedule:Start(handler(self, self.AddGoodsItem), 0.08, count)

    local batch_id = self.model.batch_id
    local batch = Config.db_searchtreasure_batch[batch_id]
    local cost = String2Table(batch.cost)
    self.value0.text = cost[1][3]
    self.value1.text = cost[2][3]
    self.value2.text = cost[3][3]

    local icon

    if self.type_id == 1 then
        icon = Config.db_item[self.model.gold_key_id].icon
    elseif self.type_id == 2 then
        icon = Config.db_item[self.model.silver_key_id].icon
    elseif self.type_id == 3 then
        icon = Config.db_item[self.model.gundam_key_id].icon
    elseif self.type_id == 4 then
        icon = Config.db_item[self.model.supermecy_key_id].icon
    end

    GoodIconUtil.GetInstance():CreateIcon(self, self.zuanshi, icon, true)
    GoodIconUtil.GetInstance():CreateIcon(self, self.zuanshi2, icon, true)
    GoodIconUtil.GetInstance():CreateIcon(self, self.zuanshi3, icon, true)

    --积分
    local batch = Config.db_searchtreasure_batch[self.model.batch_id]
    local gain = String2Table(batch.gain)
    local jifenIcon = gain[1][1]
    GoodIconUtil.GetInstance():CreateIcon(self, self.img_jifen, jifenIcon, true)

    local jifenNum = gain[1][2] * count
    self.txt_jifenNum.text = jifenNum
end

function STResultPanel:CloseCallBack()
    if self.event_id then
        self.model:RemoveListener(self.event_id)
    end
    for i = 1, #self.item_list do
        self.item_list[i]:destroy()
    end
    self.item_list = {}
    if self.StencilMask then
        destroy(self.StencilMask)
        self.StencilMask = nil
    end
end

function STResultPanel:SetMask()
    self.StencilId = GetFreeStencilId()
    self.StencilMask = AddRectMask3D(self.Viewport.gameObject)
    self.StencilMask.id = self.StencilId
end
