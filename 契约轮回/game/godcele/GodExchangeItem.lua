-- @Author: lwj
-- @Date:   2019-09-07 10:40:50 
-- @Last Modified time: 2019-09-10 23:06:07

GodExchangeItem = GodExchangeItem or class("GodExchangeItem", BaseCloneItem)
local GodExchangeItem = GodExchangeItem

function GodExchangeItem:ctor(parent_node, layer, act_id)
    self.act_id = act_id
    GodExchangeItem.super.Load(self)
end

function GodExchangeItem:dctor()
    if self.item then
        self.item:destroy()
        self.item = nil
    end
    if self.red_dot then
        self.red_dot:destroy()
        self.red_dot = nil
    end
    if self.over_event_id then
        self.model:RemoveListener(self.over_event_id)
        self.over_event_id = nil
    end
    if self.success_exchange_event_id then
        GlobalEvent:RemoveListener(self.success_exchange_event_id)
        self.success_exchange_event_id = nil
    end
end

function GodExchangeItem:LoadCallBack()
    self.model = GodCelebrationModel.GetInstance()
    self.nodes = {
        "btn_exchange", "btn_gray", "item_con", "score", "name", "score_icon", "remain", "btn_exchange/red_con",
        "btn_gray/gray_text", "recommend",
    }
    self:GetChildren(self.nodes)
    self.name = GetText(self.name)
    self.score = GetText(self.score)
    self.remain = GetText(self.remain)
    self.score_icon = GetImage(self.score_icon)
    self.gray_text = GetText(self.gray_text)

    self:AddEvent()
    self:SetRedDot(true)
end

function GodExchangeItem:AddEvent()
    local function callback()
        GlobalEvent:Brocast(OperateEvent.REQUEST_GET_REWARD, self.data.act_id, self.data.id, self.data.level)
    end
    AddButtonEvent(self.btn_exchange.gameObject, callback)

    local function callback(data)
        if data.act_id ~= self.act_id then
            return
        end
        if data.id == self.data.id then
            self.ser_data.count = self.ser_data.count + 1
        end
        self:UpdateRemain()
        self:UpdateBtnShow()
    end
    self.success_exchange_event_id = GlobalEvent:AddListener(OperateEvent.SUCCESS_GET_REWARD, callback)
    self.over_event_id = self.model:AddListener(GodCeleEvent.ExchangeOver, handler(self, self.HandleOver))
end

function GodExchangeItem:SetData(data, ser_data)
    self.data = data
    self.ser_data = ser_data
    if not self.ser_data then
        return
    end
    self:UpdateView()
end

function GodExchangeItem:UpdateView()
    self.rewa_cf = OperateModel.GetInstance():GetRewardConfig(self.act_id, self.data.id)
    self:UpdateRecommon()
    self:InitRewa()
    local item_cf = Config.db_item[self.reward_tbl[1]]
    self.name.text = item_cf.name
    self.cost_tbl = String2Table(self.data.cost)[1]
    local item_cf = Config.db_item[self.cost_tbl[1]]
    if item_cf then
        GoodIconUtil.GetInstance():CreateIcon(self, self.score_icon, tostring(item_cf.icon), true)
    end
    self:UpdateRemain()
    self:UpdateBtnShow()
end

function GodExchangeItem:InitRewa()
    self.reward_tbl = String2Table(self.data.reward)[1]
    if not self.item then
        self.item = GoodsIconSettorTwo(self.item_con)
    end
    local item_id = self.reward_tbl[1]
    local param = {}
    local operate_param = {}
    param["item_id"] = item_id
    param["model"] = self.model
    param["can_click"] = true
    param["operate_param"] = operate_param
    param["size"] = { x = 70, y = 70 }
    param["num"] = self.reward_tbl[2]
    param.bind = self.reward_tbl[3]
    self.item:SetIcon(param)
end

function GodExchangeItem:UpdateRemain()
    local max_num = String2Table(self.data.limit)[2]
    local exchange_num = self.ser_data.count
    --剩余兑换次数
    self.remain_num = max_num - exchange_num
    local num_color_str = "0db420"
    local score_color_str = "7c4d30"
    self.is_can_exchange = true
    local have_num = BagModel.GetInstance():GetItemNumByItemID(self.cost_tbl[1])
    if self.remain_num <= 0 or have_num < self.cost_tbl[2] then
        if self.remain_num <= 0 then
            num_color_str = "FF1C1C"
        end
        if have_num < self.cost_tbl[1] then
            score_color_str = "FF1C1C"
        end
        self.is_can_exchange = false
    end
    local str = string.format(ConfigLanguage.GodCele.ExchangeRemain, num_color_str, self.remain_num, max_num)
    self.remain.text = str
    self.score.text = string.format(ConfigLanguage.GodCele.CostShow, score_color_str, self.cost_tbl[2])
end

function GodExchangeItem:UpdateBtnShow()
    SetVisible(self.btn_exchange, self.is_can_exchange)
    SetVisible(self.btn_gray, not self.is_can_exchange)
    local str = ConfigLanguage.GodCele.Exchange
    if self.remain_num <= 0 then
        str = ConfigLanguage.GodCele.NoRest
    end
    self.gray_text.text = str
end

function GodExchangeItem:SetRedDot(isShow)
    if not self.red_dot then
        self.red_dot = RedDot(self.red_con, nil, RedDot.RedDotType.Nor)
    end
    self.red_dot:SetPosition(0, 0)
    self.red_dot:SetRedDotParam(isShow)
end

function GodExchangeItem:HandleOver()
    SetVisible(self.btn_exchange, false)
    SetVisible(self.btn_gray, true)
end

function GodExchangeItem:UpdateRecommon()
    local cf = String2Table(self.rewa_cf.sundries)
    local is_show_recommend = false
    if type(cf[1]) == "table" then
        for _, tbl in pairs(cf) do
            if tbl[1] == "recommend" then
                is_show_recommend = true
                break
            end
        end
    else
        if not table.isempty(cf) then
            is_show_recommend = true
        end
    end
    SetVisible(self.recommend, is_show_recommend)
end