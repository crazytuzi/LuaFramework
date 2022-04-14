-- @Author: lwj
-- @Date:   2019-12-20 14:47:40
-- @Last Modified time: 2019-12-20 14:47:40

CloudLotItem = CloudLotItem or class("CloudLotItem", BaseCloneItem)
local CloudLotItem = CloudLotItem

function CloudLotItem:ctor(parent_node, layer)
    CloudLotItem.super.Load(self)
end

function CloudLotItem:dctor()
    if self.buy_result_event_id then
        GlobalEvent:RemoveListener(self.buy_result_event_id)
        self.buy_result_event_id = nil
    end
    destroySingle(self.good)
end

function CloudLotItem:LoadCallBack()
    self.model = NationModel.GetInstance()
    self.nodes = {
        "name", "icon_con", "max", "person", "slider/progress", "slider/pro_num", "btn_buy",
    }
    self:GetChildren(self.nodes)
    self.name = GetText(self.name)
    self.max = GetText(self.max)
    self.person = GetText(self.person)
    self.pro_num = GetText(self.pro_num)
    self.progress = GetImage(self.progress)
    self.btn_img = GetImage(self.btn_buy)

    self:AddEvent()
end

function CloudLotItem:AddEvent()
    local function callback()
        local cost = self.model.cur_cost
        local type = self.model.lot_shop_type == 1 and 90010003 or 90010004
        local etime = self.model.shop_info.reward_time

        if not self.model:IsShopInNoSideSale() then
            --不在无限制次数时间段
            if os.time() >= etime then
                --已过截止时间
                Notify.ShowText("Event unavailable for now, fail to buy")
                return
            elseif self.ser_data.buy_num + self.model.cur_buy_times > self.cf.limit then
                --即将购买的次数将超过个人上线
                Notify.ShowText("Purchase limit exceeded, please come another time, please come back when limit is removed")
                return
            end
        end
        if self.ser_data.progress + self.model.cur_buy_times > self.cf.max then
            --超过全服购买上限
            Notify.ShowText("Purchase limit exceeded, failed to buy")
            return
        elseif not RoleInfoModel.GetInstance():CheckGold(cost, type) then
            return
        end
        GlobalEvent:Brocast(OperateEvent.REQUEST_SHOP_BUY, self.act_id, self.ser_data.id, self.model.cur_buy_times)
    end
    AddButtonEvent(self.btn_buy.gameObject, callback)

    self.buy_result_event_id = GlobalEvent:AddListener(OperateEvent.DILIVER_BUY_RESULT, handler(self, self.HandleBuyResult))
end

function CloudLotItem:SetData(data, StencilId, act_id)
    self.act_id = act_id
    self.ser_data = data
    self.StencilId = StencilId
    if not data then
        return
    end
    self.rewa_id = self.ser_data.id
    self.cf = OperateModel.GetInstance():GetShopCfByRewaId(self.rewa_id)
    self.item_tbl = String2Table(self.cf.rewards)[1]
    self.item_id = self.item_tbl[1]
    self:UpdateView()
end

function CloudLotItem:UpdateView()
    self.item_cf = Config.db_item[self.item_id]
    local color_str = ColorUtil.GetColor(self.item_cf.color)
    self.name.text = "<color=#" .. color_str .. ">" .. self.item_cf.name .. "</color>"

    local param = {}
    local operate_param = {}
    param["item_id"] = self.item_id
    param["can_click"] = true
    param["operate_param"] = operate_param
    param["size"] = { x = 70, y = 70 }
    param["num"] = self.item_tbl[2]
    param.bind = self.item_tbl[3]
    local color = Config.db_item[self.item_id].color - 1
    param["color_effect"] = color
    param["effect_type"] = 2  --活动特效：2
    param["stencil_id"] = self.StencilId
    param["stencil_type"] = 3
    if not self.good then
        self.good = GoodsIconSettorTwo(self.icon_con)
    end
    self.good:SetIcon(param)

    self.max.text = string.format("Max quota：<color=#3ab60e>%d</color>", self.cf.total)
    self.person.text = "Personal purchase:" .. self.ser_data.buy_num
    local max_pro = self.cf.max
    local pro = self.ser_data.progress / max_pro
    self.progress.fillAmount = pro
    self.pro_num.text = self.ser_data.progress .. "/" .. max_pro

    if self.ser_data.progress >= self.cf.max then
        --已达全服上限
        ShaderManager:GetInstance():SetImageGray(self.btn_img, self.StencilId, 3)
    else
        ShaderManager:GetInstance():SetImageNormal(self.btn_img)
    end
end

function CloudLotItem:HandleBuyResult(act_id, p_shop)
    if act_id ~= self.act_id or p_shop.id ~= self.ser_data.id then
        return
    end
    self.model:UpdatePShop(p_shop)
    self.ser_data = p_shop
    self:UpdateView()
end
