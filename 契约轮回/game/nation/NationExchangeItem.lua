-- @Author: lwj
-- @Date:   2019-09-18 17:42:28
-- @Last Modified time: 2019-09-18 17:42:30

NationExchangeItem = NationExchangeItem or class("NationExchangeItem", BaseCloneItem)
local NationExchangeItem = NationExchangeItem

function NationExchangeItem:ctor(parent_node, layer)
    self.color_red = "FF1F00"
    --    self.color_blue = "29679C"
    self.color_blue = "3efef7"
    self.color_green = "5CE53D"

    self.count_color = ""
    self.cost_color = ""
    self.is_sold_out = false

    NationExchangeItem.super.Load(self)
end

function NationExchangeItem:dctor()
    if self.item_change_event_id then
        self.model:RemoveListener(self.item_change_event_id)
        self.item_change_event_id = nil
    end
    if self.success_exchange_event_id then
        GlobalEvent:RemoveListener(self.success_exchange_event_id)
        self.success_exchange_event_id = nil
    end
    if self.icon then
        self.icon:destroy()
        self.icon = nil
    end
    if self.red_dot then
        self.red_dot:destroy()
        self.red_dot = nil
    end
end

function NationExchangeItem:LoadCallBack()
    self.model = NationModel.GetInstance()
    self.nodes = {
        "item_con", "name", "sold_out", "btn_exchange", "Price/cost_icon", "Price/cost",
        "count", "btn_gray", "btn_exchange/red_con",
    }
    self:GetChildren(self.nodes)
    self.name = GetText(self.name)
    self.cost_ol = GetOutLine(self.cost)
    self.cost = GetText(self.cost)
    self.cost_icon = GetImage(self.cost_icon)
    self.count = GetText(self.count)

    self:AddEvent()
    self:SetRedDot(true)
end

function NationExchangeItem:AddEvent()
    local function callback()
        GlobalEvent:Brocast(OperateEvent.REQUEST_GET_REWARD, self.data.act_id, self.data.id, self.data.level)
    end
    AddButtonEvent(self.btn_exchange.gameObject, callback)

    self.success_exchange_event_id = GlobalEvent:AddListener(OperateEvent.SUCCESS_GET_REWARD, handler(self, self.HandleSuccessExchange))
    self.item_change_event_id = self.model:AddListener(NationEvent.CheckExchangeItemRest, handler(self, self.HandleSuccessExchange))
end

function NationExchangeItem:SetData(data)
    self.data = data
    self.ser_data = self.model:GetSingleTaskInfo(self.data.act_id, self.data.id)
    local cost_tbl = String2Table(self.data.cost)[1]
    GoodIconUtil.GetInstance():CreateIcon(self, self.cost_icon, tostring(cost_tbl[1]), true)
    if not self.ser_data then
        logError("NationExchangeItem,没有tasks数据")
    end
    self:UpdateView()
end

function NationExchangeItem:UpdateView()
    local reward_tbl = String2Table(self.data.reward)[1]
    local param = {}
    local operate_param = {}
    param["item_id"] = reward_tbl[1]
    param["model"] = self.model
    param["can_click"] = true
    param["operate_param"] = operate_param
    param["size"] = { x = 76, y = 76 }
    param.bind = reward_tbl[3]
    if not self.icon then
        self.icon = GoodsIconSettorTwo(self.item_con)
    end
    self.icon:SetIcon(param)
    self.item_cf = Config.db_item[reward_tbl[1]]
    self.name.text = self.item_cf.name
    self:UpdateCount()
    self:UpdateCostShow()
end

function NationExchangeItem:UpdateCount()
    local limit_tbl = String2Table(self.data.limit)
    local max_count = limit_tbl[2]
    local rest_ex_num = max_count - self.ser_data.count
    local count_color = self.color_green
    local is_sold_out = rest_ex_num <= 0
    if is_sold_out then
        --售罄
        self:ShowGray()
        count_color = self.color_red
    else
        self:ShowNormal()
    end
    SetVisible(self.sold_out, is_sold_out)
    if self.icon then
        if self.is_sold_out then
            self.icon:SetIconGray()
        else
            self.icon:SetIconNormal()
        end
    end
    self.is_sold_out = is_sold_out
    --local count_r, count_g, count_b, count_a = HtmlColorStringToColor(count_color)
    --SetOutLineColor(self.count, count_r, count_g, count_b, count_a)
    local a = tostring(rest_ex_num)
    local b = tostring(max_count)
    self.count.text = "<color=#" .. count_color .. ">" .. a .. "/" .. b .. "</color>"
end

function NationExchangeItem:UpdateCostShow()
    local cost_tbl = String2Table(self.data.cost)[1]
    local is_enough_ex = BagModel.GetInstance():IsSomethingEnough(cost_tbl[1], cost_tbl[2])
    local color_str = is_enough_ex and self.color_blue or self.color_red
    self.cost.text = string.format("<color=#%s>%d</color>", color_str, cost_tbl[2])
    local is_show_normal = is_enough_ex
    --货币足够，不够兑换次数
    if is_enough_ex and self.is_sold_out then
        is_show_normal = false
    end
    local cb = is_show_normal and handler(self, self.ShowNormal) or handler(self, self.ShowGray)
    cb()
end

function NationExchangeItem:ShowNormal()
    SetVisible(self.btn_gray, false)
    SetVisible(self.btn_exchange, true)
end

function NationExchangeItem:ShowGray()
    SetVisible(self.btn_gray, true)
    SetVisible(self.btn_exchange, false)
end

function NationExchangeItem:SetRedDot(isShow)
    if not self.red_dot then
        self.red_dot = RedDot(self.red_con, nil, RedDot.RedDotType.Nor)
    end
    self.red_dot:SetPosition(0, 0)
    self.red_dot:SetRedDotParam(isShow)
end

function NationExchangeItem:HandleSuccessExchange(data)
    if not self.model:IsSelfAct(data.act_id) then
        return
    end
    if data and data.id == self.data.id then
        self.ser_data.count = self.ser_data.count + 1
    end
    self:UpdateCount()
    self:UpdateCostShow()
end