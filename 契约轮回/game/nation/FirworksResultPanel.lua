-- @Author: lwj
-- @Date:   2019-11-30 17:21:51 
-- @Last Modified time: 2019-11-30 17:21:54

FirworksResultPanel = FirworksResultPanel or class("FirworksResultPanel", BaseRewardPanel)
local FirworksResultPanel = FirworksResultPanel

function FirworksResultPanel:ctor()
    self.abName = "nation"
    self.assetName = "FirworksResultPanel"
    self.layer = "UI"

    self.use_background = true
    self.change_scene_close = true
    self.is_hide_other_panel = true

    self.item_list = {}

    self.btn_list = {
        { btn_res = "common:btn_yellow_2", btn_name = ConfigLanguage.Mix.Confirm, format = "Auto closing in %s sec", auto_time = 10, call_back = handler(self, self.OkFunc) },
        -- 说明
        { btn_res = "common:btn_blue_2", btn_name = "Fire off once", call_back = handler(self, self.SearchOne) },
        { btn_res = "common:btn_blue_2", btn_name = "Fire off 10 times", call_back = handler(self, self.SearchTen) },
    }
    self.model = NationModel:GetInstance()
end

function FirworksResultPanel:dctor()
end

function FirworksResultPanel:Open(rewards)
    self:UpdateRewardList(rewards)
    FirworksResultPanel.super.Open(self)
end

function FirworksResultPanel:UpdateRewardList(rewards)
    if table.isempty(rewards) then
        return
    end
    local list = {}
    for i = 1, #rewards do
        local id = rewards[i]
        local lottery = Config.db_yunying_lottery_rewards[id]
        local tbl = String2Table(lottery.rewards)[1]
        list[#list + 1] = tbl
    end
    self.rewards = list
end

function FirworksResultPanel:LoadCallBack()
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

    SetLocalPositionX(self.tips1, 26.5)
    SetLocalPositionX(self.tips2, 300)
    SetVisible(self.tips3, false)
    local function schedule_fun()
        self:Close()
    end

    self:AddEvent()
end

function FirworksResultPanel:RequestSearch(times)
    local cost_id = self.model.cur_hanabi_cost_tbl[1]
    local cost_num = self.model.cur_hanabi_cost_tbl[2] * times
    if (not cost_num) or (not cost_id) then
        logError("ChristmasHanabiView: 没有消耗id")
        return
    end
    local is_can, _, have_num = self:IsEnoughFire(times)
    if is_can then
        self:FireTheHole(times)
    else
        --弹窗消费钻石提示
        local item_name = Config.db_item[cost_id].name
        local lack_num = cost_num - have_num
        local price = Config.db_voucher[cost_id].price * lack_num
        if not RoleInfoModel.GetInstance():CheckGold(price, Config.db_voucher[cost_id].type) then
            return
        end
        local message = string.format(ConfigLanguage.Nation.HammerNotEnough, item_name, price, item_name, lack_num)
        if self.model.is_hanabi_check then
            self:FireTheHole(times)
        else
            local function ok_fun(is_hanabi_check)
                self.model.is_hanabi_check = is_hanabi_check
                self:FireTheHole(times)
            end
            Dialog.ShowTwo(ConfigLanguage.SearchT.TipsTitle, message, nil, ok_fun, nil, nil, nil, nil, ConfigLanguage.SearchT.NoAlert, false)
        end
    end

end

function FirworksResultPanel:IsEnoughFire(times)
    local cost_id = self.model.cur_hanabi_cost_tbl[1]
    local cost_num = self.model.cur_hanabi_cost_tbl[2] * times
    local is_can_crack = false
    local have_num = BagModel.GetInstance():GetItemNumByItemID(cost_id)
    local is_have_enough_hammer = have_num >= cost_num
    if is_have_enough_hammer then
        is_can_crack = true
    end
    return is_can_crack, is_have_enough_hammer, have_num
end

function FirworksResultPanel:FireTheHole(times)
    local id = OperateModel.GetInstance():GetActIdByType(730)
    if id == 0 then
        logError("没有该id  ", id)
        return
    end
    GlobalEvent:Brocast(OperateEvent.REQUEST_FIRE, id, times)
end

function FirworksResultPanel:OkFunc()
    self:FinishEffect()
    self:Close()
end

function FirworksResultPanel:SearchOne()
    self:FinishEffect()
    self:StartDelay(1)
end

function FirworksResultPanel:SearchTen()
    self:FinishEffect()
    self:StartDelay(10)
end
function FirworksResultPanel:StartDelay(time)
    self:RequestSearch(time)
end

--页面上fire刷新
function FirworksResultPanel:AddEvent()
    local function call_back(id, data)
        local self_id = OperateModel.GetInstance():GetActIdByType(730)
        if self_id == 0 then
            return
        end
        if id ~= self_id then
            return
        end
        self:UpdateRewardList(data)
        self:UpdateView()
    end
    self.event_id = GlobalEvent:AddListener(OperateEvent.SUCCESS_FIRE, call_back)
end

function FirworksResultPanel:OpenCallBack()
    self:UpdateView()
end

--添加寻宝结果物品（创建UI）
function FirworksResultPanel:AddGoodsItem()
    local reward_ids = self.rewards
    local i = self.cur_index --当前物品索引
    local rewards = reward_ids[i]
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
            local rewards = reward_ids[i]
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
function FirworksResultPanel:ShowLeftRewards()
    local reward_ids = self.rewards
    if self.cur_index < #reward_ids then
        for i = self.cur_index, #reward_ids do
            local rewarditem = reward_ids[i]
            local item_id = rewarditem[1]
            local num = rewarditem[2]
            local bind = rewarditem[3] or 1
            local goods = self.item_list[i] or STGoodsItem(self.Content)
            goods:SetData(item_id, num, bind, self.StencilId)
            self.item_list[#self.item_list + 1] = goods
        end
    end
end

--结束特效展示
function FirworksResultPanel:FinishEffect()
    if self.schedule_id then
        self.schedule:Stop(self.schedule_id)
        self.schedule_id = nil
        self:ShowLeftRewards()
    end
    self.back_ground.item_list[1]:StopTime()
end

function FirworksResultPanel:UpdateView()
    for i = 1, #self.item_list do
        self.item_list[i]:destroy()
    end
    self.item_list = {}
    self.cur_index = 1
    local reward_ids = self.rewards
    local count = #reward_ids
    local y_pos = -60
    if count == 50 then
        y_pos = 33
    end
    SetLocalPositionY(self.ScrollView.transform, y_pos)
    self.schedule = Schedule()
    self.schedule_id = self.schedule:Start(handler(self, self.AddGoodsItem), 0.08, count)
end

function FirworksResultPanel:CloseCallBack()
    if self.event_id then
        GlobalEvent:RemoveListener(self.event_id)
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

function FirworksResultPanel:SetMask()
    self.StencilId = GetFreeStencilId()
    self.StencilMask = AddRectMask3D(self.Viewport.gameObject)
    self.StencilMask.id = self.StencilId
end
