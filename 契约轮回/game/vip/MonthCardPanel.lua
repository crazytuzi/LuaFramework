-- @Author: lwj
-- @Date:   2019-05-29 19:40:21
-- @Last Modified time: 2019-05-29 19:41:58

MonthCardPanel = MonthCardPanel or class("MonthCardPanel", BaseItem)
local MonthCardPanel = MonthCardPanel

function MonthCardPanel:ctor(parent_node, layer)
    self.abName = "vip"
    self.assetName = "MonthCardPanel"
    self.layer = layer

    self.model = VipModel.GetInstance()
    self.settle_list = { 11005, 11020143, 11020144 }
    self.settle_items = {}

    BaseItem.Load(self)
end

function MonthCardPanel:dctor()
    for i, v in pairs(self.item_list) do
        if v then
            v:destroy()
        end
    end
    self.item_list = {}

    for i = 1, #self.model_event do
        self.model:RemoveListener(self.model_event[i])
    end
    self.model_event = {}

    for i, v in pairs(self.settle_items) do
        if v then
            v:destroy()
        end
    end
    self.settle_items = {}
end

function MonthCardPanel:LoadCallBack()
    self.nodes = {
        "Right/RTop/btn_buy", "Right/RTop/btn_buy/buy_text", "Right/item_scroll/Viewport/item_con", "Right/item_scroll/Viewport/item_con/MCItem",
        "Right/RTop/example_con", "Right/RTop/btn_buy/Image",
    }
    self:GetChildren(self.nodes)
    self.item_obj = self.MCItem.gameObject
    self.btn_img = GetImage(self.btn_buy)
    self.btn_text = GetText(self.buy_text)
    self.btn_deco_img = GetImage(self.Image)

    self:AddEvent()
    self:LoadSettleIcons()
    self:InitPanel()
    self:IsHideSideRD()
end

function MonthCardPanel:LoadSettleIcons()
    for i, v in pairs(self.settle_items) do
        if v then
            v:destroy()
        end
    end
    self.settle_items = {}
    for i = 1, #self.settle_list do
        local param = {}
        local operate_param = {}
        param["item_id"] = self.settle_list[i]
        param["model"] = self.model
        param["can_click"] = true
        param["operate_param"] = operate_param
        param["size"] = { x = 76, y = 76 }
        local itemIcon = GoodsIconSettorTwo(self.example_con)
        itemIcon:SetIcon(param)
        self.settle_items[#self.settle_items + 1] = itemIcon
    end
end

function MonthCardPanel:AddEvent()
    local function callback()
        if self.model:IsBuyMC() then
            Notify.ShowText("Invested")
            return
        end
        local condi = String2Table(Config.db_game["vip_mcard"].val)[1]
        local balan = RoleInfoModel.GetInstance():GetRoleValue(condi[1])
        if balan >= condi[2] then
            self.model.is_buying = true
            self.model:Brocast(VipEvent.BuyMC)
        else
            local name = Config.db_item[condi[1]].name
            local tip = string.format(ConfigLanguage.Shop.BalanceNotEnough, name)
            local function callback()
                GlobalEvent:Brocast(VipEvent.CloseVipPanel)
                GlobalEvent:Brocast(VipEvent.OpenVipPanel, 2)
            end
            Dialog.ShowTwo("Tip", tip, "Confirm", callback, nil, "Cancel", nil, nil, nil, false, false);
        end
    end
    AddButtonEvent(self.btn_buy.gameObject, callback)

    self.model_event = {}
    self.model_event[#self.model_event + 1] = self.model:AddListener(VipEvent.UpdateMCPanel, handler(self, self.InitPanel))
end

function MonthCardPanel:InitPanel()
    self.is_buy = self.model:IsBuyMC()
    if self.is_buy then
        ShaderManager:GetInstance():SetImageGray(self.btn_img)
        ShaderManager:GetInstance():SetImageGray(self.btn_deco_img)
        self.btn_text.text = ConfigLanguage.Vip.AlreadyInsveted
    else
        ShaderManager:GetInstance():SetImageNormal(self.btn_img)
        ShaderManager:GetInstance():SetImageNormal(self.btn_deco_img)
        self.btn_text.text = ConfigLanguage.Vip.InvestedMC
    end

    local list = self.model:SortMCData()
    self.item_list = self.item_list or {}
    local len = #list
    for i = 1, len do
        local item = self.item_list[i]
        if not item then
            item = MCItem(self.item_obj, self.item_con)
            self.item_list[i] = item
        else
            item:SetVisible(true)
        end
        local serdata = self.model:GetMCStateByDay(list[i].day)
        item:SetData(list[i], serdata)
    end
    for i = len + 1, #self.item_list do
        local item = self.item_list[i]
        item:SetVisible(false)
    end
end

function MonthCardPanel:IsHideSideRD()
    if self.model.is_show_mc_once then
        self.model.is_show_mc_once = false
        self.model:RemoveSideRD(4)
        self.model:Brocast(VipEvent.UpdateVipSideRD)
        if self.model:IsCanHideMainIconRD() then
            GlobalEvent:Brocast(VipEvent.ShowMainVipRD, false)
        end
    end
end
