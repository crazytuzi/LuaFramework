-- @Author: lwj
-- @Date:   2019-01-15 17:01:38
-- @Last Modified time: 2019-01-15 17:01:40

DailyRewardItem = DailyRewardItem or class("DailyRewardItem", BaseCloneItem)
local DailyRewardItem = DailyRewardItem

function DailyRewardItem:ctor(parent_node, layer)
    DailyRewardItem.super.Load(self)
    self.model = DailyModel.GetInstance()
end

function DailyRewardItem:dctor()
    if self.item then
        self.item:destroy(0)
    end
    self.item = nil
    if self.red_dot then
        self.red_dot:destroy()
        self.red_dot = nil
    end
end

function DailyRewardItem:LoadCallBack()
    self.nodes = {
        "act_text", "click/icon",
        "click",
        "tick",
        "red_con"
    }
    self:GetChildren(self.nodes)
    self.act_text = GetText(self.act_text)

    self:AddEvent()
end

function DailyRewardItem:AddEvent()
end

function DailyRewardItem:SetData(data)
    self.data = data
    if self.is_loaded then
        self:UpdateView()
    end
end

function DailyRewardItem:UpdateView()
    self.act_text.text = self.data.act_value
    local total = nil
    if self.data.isInDailyPanel then
        total = self.model:GetActTotal()
    else
        total = self.model:GetWeekTotalAct()
    end
    if not self.item then
        self.item = GoodsIconSettorTwo(self.icon)
    end
    local param = {}
    local operate_param = {}
    local id = self.data.reward_tbl[1][1]
    param["item_id"] = id
    param["model"] = self.model
    param["can_click"] = true
    param["operate_param"] = operate_param
    param["size"] = { x = 60, y = 60 }
    param["num"] = self.data.reward_tbl[1][2]
    if total >= self.data.act_value and not self.data.isGot then
        --设置可领取特效
        AddClickEvent(self.click.gameObject, handler(self, self.RewardItemClick))
        self.item:UpdateRayTarget(false)
        local color = Config.db_item[id].color - 1
        param["color_effect"] = color
        param["effect_type"] = 2
        self:SetRedDot(true)
    else
        --取消可领取特效
        RemoveClickEvent(self.click.gameObject)
        self.item:UpdateRayTarget(true)
        self:SetRedDot(false)
    end
    self.item:SetIcon(param)
    if self.data.isGot then
        --已经获得
        self.item:SetIconGray()
        SetVisible(self.tick, true)
    else
        self.item:SetIconNormal()
        SetVisible(self.tick, false)
    end
end

function DailyRewardItem:RewardItemClick()
    if not self.data.isGot then
        if self.data.isInDailyPanel then
            self.model:Brocast(DailyEvent.RequestGetReward, self.data.id)
        else
            GlobalEvent:Brocast(DailyEvent.RequestGetWeeklyReward, self.data.id)
        end
    end
end

function DailyRewardItem:SetRedDot(isShow)
    if not self.red_dot then
        self.red_dot = RedDot(self.red_con, nil, RedDot.RedDotType.Nor)
    end
    self.red_dot:SetPosition(0, 0)
    self.red_dot:SetRedDotParam(isShow)
end

