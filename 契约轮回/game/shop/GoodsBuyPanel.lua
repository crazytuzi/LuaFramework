-- @Author: lwj
-- @Date:   2019-03-19 15:07:43
-- @Last Modified time: 2019-03-19 15:07:52

GoodsBuyPanel = GoodsBuyPanel or class("GoodsBuyPanel", BasePanel)
local GoodsBuyPanel = GoodsBuyPanel

function GoodsBuyPanel:ctor()
    self.abName = "shop"
    self.assetName = "GoodsBuyPanel"
    self.layer = "UI"

    self.use_background = true
    self.click_bg_close = true
    self.model = ShopModel.GetInstance()

    self.goods_item = nil
    self.is_use_gold = true
    self.cur_input = 1
end

function GoodsBuyPanel:dctor()
end

function GoodsBuyPanel:Open(mall_id)
    BasePanel.Open(self)

    self.mall_id = mall_id
    self.mall_cf = Config.db_mall[mall_id]
    self.item_cf = Config.db_item[String2Table(self.mall_cf.item)[1]]
    self.price_tbl = String2Table(self.mall_cf.price)
    self.price_type = self.price_tbl[1]
    self.sin_price = self.price_tbl[2]
    self.balance_type = ShopModel.GetInstance():GetTypeNameById(tonumber(self.price_type))
end

function GoodsBuyPanel:BindRoleBalanceUpdate()
    local function call_back()
        if self.cur_input == 0 then
            self.cur_input = 1
            self.input.text = 1
        end
        self:ClickCheckInput()
    end
    self.gold_event_id = RoleInfoModel:GetInstance():GetMainRoleData():BindData(Constant.GoldType.Gold, call_back, Constant.GoldType.Gold)
    self.diamond_event_id = RoleInfoModel:GetInstance():GetMainRoleData():BindData(Constant.GoldType.BGold, call_back, Constant.GoldType.BGold)
end

function GoodsBuyPanel:LoadCallBack()
    self.nodes = {
        "sum", "input_bg", "btn_reduce_gray", "btn_buy", "balanceicon", "Bg_3/price_icon", "Bg_3/name", "Bg_3/icon", "btn_max", "input_bg/input", "Bg_3/single_price", "btn_plus", "btn_recharge", "btn_reduce",
        "tips",
    }
    self:GetChildren(self.nodes)
    self.name = GetText(self.name)
    self.sum = GetText(self.sum)
    self.input = GetText(self.input)
    self.single_price = GetText(self.single_price)

    self.balace_icon = GetImage(self.balanceicon)
    self.price_icon = GetImage(self.price_icon)

    self:AddEvent()
    self:UpdateView()
end

function GoodsBuyPanel:AddEvent()
    --数量按钮
    local function callback()
        local text_num = tonumber(self.input.text)
        local after_cal_num = text_num - 1
        if after_cal_num > 0 then
            self.input.text = after_cal_num
            self.cur_input = after_cal_num
            self:CheckSumShow()
        end
    end
    AddButtonEvent(self.btn_reduce.gameObject, callback)

    local function callback()
        local text_num = tonumber(self.input.text)
        local after_cal_num = text_num + 1
        if after_cal_num > 999 then
            Notify.ShowText("You can't buy anymore")
        else
            local isEnough = self:CheckIsMoneyEnough(after_cal_num)
            if isEnough then
                self.cur_input = after_cal_num
                self.input.text = after_cal_num
                self:CheckSumShow()
            end
        end
    end
    AddButtonEvent(self.btn_plus.gameObject, callback)

    local function callback()
        --local text_num = tonumber(self.input.text)
        --local after_cal_num = text_num + 10
        --local need_price=self.sin_price*
        --
        --local roleBalance = RoleInfoModel:GetInstance():GetRoleValue(self.balance_type)
        --local rest = roleBalance % self.sin_price
        --local result = (roleBalance - rest) / self.sin_price
        --if result > 999 then
        --    result = 999
        --end
        --self.cur_input = result
        --if self.cur_input == 0 then
        --    self.cur_input = 1
        --    self:ShowNotEnoughTips()
        --end
        --self.input.text = self.cur_input
        --self:CheckSumShow()
    end
    AddButtonEvent(self.btn_max.gameObject, callback)

    local function callback()
        lua_panelMgr:GetPanelOrCreate(NumKeyPad, self.input, handler(self, self.ClickCheckInput), handler(self, self.ClickCheckInput), handler(self, self.ClickCheckInput), 3, -60, 0):Open()
    end
    AddButtonEvent(self.input_bg.gameObject, callback)

    local function callback()
        GlobalEvent:Brocast(VipEvent.OpenVipPanel, 2)
        self:Close()
    end
    AddButtonEvent(self.btn_recharge.gameObject, callback)

    local function callback()
        if self:CheckIsMoneyEnough(self.cur_input) then
            --self.model:Brocast(CandyEvent.RequestBuyGiftCount, tonumber(self.cur_input))
            GlobalEvent:Brocast(ShopEvent.BuyShopGoods, self.mall_id, tonumber(self.cur_input))
        end
    end
    AddButtonEvent(self.btn_buy.gameObject, callback)

    self.success_buy_shop_goods_event_id = GlobalEvent:AddListener(ShopEvent.SuccessToBuyGoodsInShop, handler(self, self.Close))
end

function GoodsBuyPanel:OpenCallBack()
    SetVisible(self.btn_max, false)
    self:CheckSumShow()
    self:BindRoleBalanceUpdate()
end

function GoodsBuyPanel:UpdateView()
    --lua_resMgr:SetImageTexture(self, self.price_icon, "iconasset/icon_goods_900", tostring(Config.db_item[price_tbl[1]].icon), true, nil, false)
    --GoodIconUtil:CreateIcon(self, self.price_icon, tostring(Config.db_item[self.price_type].icon), true)
    GoodIconUtil:CreateIcon(self, self.price_icon, tostring(self.price_type), true)
    GoodIconUtil:CreateIcon(self, self.balace_icon, tostring(self.price_type), true)
    if self.price_type ~= Constant.GoldType.BGold then
        SetVisible(self.tips, false)
    end
    self.single_price.text = self.sin_price

    local param = {}
    local operate_param = {}
    param["cfg"] = self.item_cf
    param["model"] = self.model
    param["can_click"] = true
    param["operate_param"] = operate_param
    param["size"] = { x = 60, y = 60 }
    self.goods_item = GoodsIconSettorTwo(self.icon)
    self.goods_item:SetIcon(param)

    local colorNum = self.item_cf.color
    self.name.text = string.format("<color=#%s>%s</color>", ColorUtil.GetColor(colorNum), self.item_cf.name)
end

function GoodsBuyPanel:CheckIsMoneyEnough(num)
    local isEnough = false
    local roleBalance = RoleInfoModel:GetInstance():GetRoleValue(self.balance_type)
    local after_cal_sum = self.sin_price * num
    if after_cal_sum > roleBalance then
        isEnough = false
        if num - 1 == 1 or num - 1 == 0 then
            self:ShowNotEnoughTips()
        else
            Notify.ShowText("You can't buy anymore")
        end
    else
        isEnough = true
    end
    return isEnough
end

function GoodsBuyPanel:CheckSumShow()
    local roleBalance = RoleInfoModel:GetInstance():GetRoleValue(self.balance_type)
    if self.cur_input > 999 then
        self.cur_input = 999
        self.input.text = 999
    end
    if self.cur_input > 1 then
        SetVisible(self.btn_reduce, true)
    else
        SetVisible(self.btn_reduce, false)
    end
    local sum = self.sin_price * self.cur_input
    if roleBalance < sum then
        SetColor(self.sum, 230, 50, 50, 255)
    else
        SetColor(self.sum, 71, 141, 193, 255)
    end
    self.sum.text = sum
end

function GoodsBuyPanel:ClickCheckInput()
    local roleBalance = RoleInfoModel:GetInstance():GetRoleValue(self.balance_type)
    local text_num = tonumber(self.input.text)
    local after_cal_sum = text_num * self.sin_price
    local finalText = nil
    if roleBalance < after_cal_sum then
        local rest = roleBalance % self.sin_price
        finalText = (roleBalance - rest) / self.sin_price
        if finalText == 0 then
            finalText = 1
        end
    else
        finalText = text_num
    end
    if finalText > 999 then
        self.input.text = 999
        Notify.ShowText("You can't buy anymore")
    else
        self.input.text = finalText
    end
    self.cur_input = tonumber(self.input.text)
    self:CheckSumShow()
end

function GoodsBuyPanel:ShowNotEnoughTips()
    local type = ""
    if self.is_use_gold then
        type = "Diamond"
    else
        type = "Bound Diamond"
    end
    local tips = string.format("Insufficient %s", type)
    Notify.ShowText(tips)
end

function GoodsBuyPanel:CloseCallBack()
    --if self.selectequipitemclick_event_id then
    --    GlobalEvent:RemoveListener(self.selectequipitemclick_event_id)
    --    self.selectequipitemclick_event_id = nil
    --end
    if self.success_buy_shop_goods_event_id then
        GlobalEvent:RemoveListener(self.success_buy_shop_goods_event_id)
        self.success_buy_shop_goods_event_id = nil
    end
    if self.goods_item then
        self.goods_item:destroy()
        self.goods_item = nil
    end

    if self.gold_event_id then
        RoleInfoModel:GetInstance():GetMainRoleData():RemoveListener(self.gold_event_id)
        self.gold_event_id = nil
    end
    if self.diamond_event_id then
        RoleInfoModel:GetInstance():GetMainRoleData():RemoveListener(self.diamond_event_id)
        self.diamond_event_id = nil
    end
end