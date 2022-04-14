-- @Author: lwj
-- @Date:   2019-08-10 10:37:50 
-- @Last Modified time: 2019-08-10 10:37:54

ColeItem = ColeItem or class("ColeItem", BaseCloneItem)
local ColeItem = ColeItem

function ColeItem:ctor(parent_node, layer)
    self.act_id = 120301
    ColeItem.super.Load(self)
end

function ColeItem:dctor()
    if self.red_dot then
        self.red_dot:destroy()
        self.red_dot = nil
    end
    if self.success_exchange_event_id then
        self.model:RemoveListener(self.success_exchange_event_id)
        self.success_exchange_event_id = nil
    end
    if self.update_items_event_id then
        GlobalEvent:RemoveListener(self.update_items_event_id)
        self.update_items_event_id = nil
    end
    for i, v in pairs(self.goods_item_list) do
        if v then
            v:destroy()
        end
    end
    self.goods_item_list = {}
    for i, v in pairs(self.symbol_item_list) do
        if v then
            v:destroy()
        end
    end
    self.symbol_item_list = {}
    for i, v in pairs(self.rewa_item_list) do
        if v then
            v:destroy()
        end
    end
    self.rewa_item_list = {}
end

function ColeItem:LoadCallBack()
    self.model = OpenHighModel.GetInstance()
    self.nodes = {
        "btn_gray", "btn_gray/gray_text", "tips", "cost_con/ColeConnectItem", "cost_con/ColeGoodsItem", "cost_con", "btn_exchange",
        "btn_exchange/red_con",
    }
    self:GetChildren(self.nodes)
    self.symbol_obj = self.ColeConnectItem.gameObject
    self.goods_obj = self.ColeGoodsItem.gameObject
    self.tips = GetText(self.tips)

    self:AddEvent()
    self:SetRedDot(true)
end

function ColeItem:AddEvent()
    self.update_items_event_id = GlobalEvent:AddListener(BagEvent.UpdateGoods, handler(self, self.HandleGoodsUpdate))
    self.success_exchange_event_id = self.model:AddListener(OpenHighEvent.SuccessFetchRewa, handler(self, self.HandleSuccessExchange))

    local function callback()
        --logError("act_id:", self.act_id, "   id:", self.data.id, "   level:", self.data.level)
        GlobalEvent:Brocast(OperateEvent.REQUEST_GET_REWARD, self.act_id, self.data.id, self.data.level)
    end
    AddButtonEvent(self.btn_exchange.gameObject, callback)
    local function callback()
        if self.is_no_exchange_count then
            Notify.ShowText(ConfigLanguage.OpenHigh.NotExchangeCount)
        end
    end
    AddButtonEvent(self.btn_gray.gameObject, callback)
end

function ColeItem:SetData(data)
    self.data = data
    self.ser_data = self.model:GetSingleTaskInfo(self.data.act_id, self.data.id)
    self:UpdateView()
end

function ColeItem:UpdateView()
    self:LoadItemShow()
    self:UpdateStateShow()
end

function ColeItem:LoadItemShow()
    local list = String2Table(self.data.cost)
    self.goods_item_list = self.goods_item_list or {}
    self.symbol_item_list = self.symbol_item_list or {}
    local len = #list
    for i = 1, len do
        local item = self.goods_item_list[i]
        if not item then
            item = ColeGoodsItem(self.goods_obj, self.cost_con)
            self.goods_item_list[i] = item
        else
            item:SetVisible(true)
        end
        local data = list[i]
        item:SetData(data)

        --符号
        local symbol = self.symbol_item_list[i]
        if not symbol then
            symbol = ColeConnectItem(self.symbol_obj, self.cost_con)
            self.symbol_item_list[i] = symbol
        else
            symbol:SetVisible(true)
        end
        local data = 1
        if i == len then
            data = 2
        end
        symbol:SetData(data)
    end
    for i = len + 1, #self.goods_item_list do
        local item = self.goods_item_list[i]
        item:SetVisible(false)
    end
    for i = len + 1, #self.symbol_item_list do
        local item = self.symbol_item_list[i]
        item:SetVisible(false)
    end

    --获得
    local list = String2Table(self.data.reward)
    self.rewa_item_list = self.rewa_item_list or {}
    local len = #list
    for i = 1, len do
        local item = self.rewa_item_list[i]
        if not item then
            item = GoodsIconSettorTwo(self.cost_con)
            self.rewa_item_list[i] = item
        else
            item:SetVisible(true)
        end
        local param = {}
        local operate_param = {}
        param["item_id"] = list[i][1]
        param["model"] = self.model
        param["can_click"] = true
        param["operate_param"] = operate_param
        param["size"] = { x = 60, y = 60 }
        param["is_dont_set_pos"] = true
        param.bind = 2
        param.num = list[i][2]
        --local color = Config.db_item[id].color - 1
        --param["color_effect"] = color
        --param["effect_type"] = 2  --活动特效：2
        item:SetIcon(param)
    end
    for i = len + 1, #self.rewa_item_list do
        local item = self.rewa_item_list[i]
        item:SetVisible(false)
    end
end

function ColeItem:UpdateStateShow()
    if self:UpdateRemainNum() == 0 then
        SetVisible(self.btn_gray, true)
        SetVisible(self.btn_exchange, false)
        return
    end
    self:CheckIsCanExchange()
end

function ColeItem:HandleGoodsUpdate()
    local sum = String2Table(self.data.limit)[2]
    local cur = sum - self.ser_data.count
    self:LoadItemShow()
    if cur <= 0 then
        return
    end
    self:CheckIsCanExchange()
end

function ColeItem:CheckIsCanExchange()
    local is_lack = false
    local cost_tbl = String2Table(self.data.cost)
    for i, v in pairs(cost_tbl) do
        local item_id = v[1]
        if BagModel.GetInstance():GetItemNumByItemID(item_id) == 0 then
            is_lack = true
            break
        end
    end
    SetVisible(self.btn_gray, is_lack)
    SetVisible(self.btn_exchange, not is_lack)
end

function ColeItem:UpdateRemainNum()
    local sum = String2Table(self.data.limit)[2]
    local cur = sum - self.ser_data.count
    local color_str = "FFF3DD"
    self.is_no_exchange_count = false
    if cur <= 0 then
        cur = 0
        color_str = "fd2c2c"
        self.is_no_exchange_count = true
    end
    self.tips.text = string.format(ConfigLanguage.OpenHigh.ColeRemainShow, color_str, cur)
    return cur
end

function ColeItem:HandleSuccessExchange(data)
    if data.act_id ~= self.act_id or self.data.id ~= data.id then
        return
    end
    self.ser_data.count = self.ser_data.count + 1
    self:UpdateStateShow()
end

function ColeItem:SetRedDot(isShow)
    if not self.red_dot then
        self.red_dot = RedDot(self.red_con, nil, RedDot.RedDotType.Nor)
    end
    self.red_dot:SetPosition(0, 0)
    self.red_dot:SetRedDotParam(isShow)
end