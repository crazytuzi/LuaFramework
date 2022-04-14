-- @Author: lwj
-- @Date:   2018-11-19 14:14:01
-- @Last Modified time: 2018-11-19 14:14:03

FlashSaleItem = FlashSaleItem or class("FlashSaleItem", BaseItem)
local FlashSaleItem = FlashSaleItem

function FlashSaleItem:ctor(parent_node, layer)
    self.abName = "shop"
    self.assetName = "FlashSaleItem"
    self.layer = layer

    BaseItem.Load(self)
end

function FlashSaleItem:dctor()
    if self.itemIcon ~= nil then
        self.itemIcon:destroy()
    end

    if self.countdowntext then
        self.countdowntext:destroy()
    end
    self.countdowntext = nil
end

function FlashSaleItem:LoadCallBack()
    self.nodes = {
        "content/icon",
        "content/name",
        "content/originalPrice",
        "content/curPrice",
        "content/btn_buy",
        "content/discount_Bg",
        "content/discount_Bg/FlashdiscountTex",
        "content/allBg/timeText",
        "content/allBg/originalIcon", "content/allBg/currentIcon",
        "content/preview",
        "content",
        "nothing", "content/num",
    }
    self:GetChildren(self.nodes)
    self.preview_text = GetText(self.preview)
    self.num = GetText(self.num)

    self.model = ShopModel.GetInstance()
    if self.data ~= nil and self.data.buy_num then
        self.countdowntext = CountDownText(self.timeText, { isShowMin = true, isShowHour = true });
        local function call_back()
            self.model:RemoveFlashSaleById(self.data.id)
            self.data = nil
            self:UpdateView()
            GlobalEvent:Brocast(MainEvent.ChangeMidTipIcon, "shop", false, handler(self, self.OpenShop), nil, os.time(), nil)
        end
        self.itemServData = self.data
        self.countdowntext:StartSechudle(self.itemServData.end_time, call_back)
        self.itemMallData = Config.db_mall[self.data.id]
    else
        self.itemMallData = self.data
    end

    self:AddEvent()
    self:UpdateView()
end

function FlashSaleItem:AddEvent()
    local function call_back(target, x, y)
        local paymentTypeId = String2Table(self.itemMallData.price)[1]
        local typeName = ShopModel:GetInstance():GetTypeNameById(paymentTypeId)
        local roleBalance = RoleInfoModel:GetInstance():GetRoleValue(typeName)
        --足够购买
        if roleBalance >= String2Table(self.itemMallData.price)[2] then
            GlobalEvent:Brocast(ShopEvent.BuyShopGoods, self.itemMallData.id, 1)
        else
            local typeName = Config.db_item[String2Table(self.itemMallData.price)[1]].name
            local tips = string.format(ConfigLanguage.Shop.BalanceNotEnough, typeName)
            local function callback()
                GlobalEvent:Brocast(VipEvent.OpenVipPanel, 2)
            end
            Dialog.ShowTwo("Tip", tips, "Confirm", callback, nil, "Cancel", nil, nil);

            --充值跳转

        end
    end
    AddButtonEvent(self.btn_buy.gameObject, call_back)
end

function FlashSaleItem:SetData(data)
    self.data = data
end

function FlashSaleItem:UpdateView()
    if not self.data then
        SetVisible(self.nothing, true)
        SetVisible(self.content, false)
    else
        SetVisible(self.nothing, false)
        SetVisible(self.content, true)

        self:CleanItemSettor()
        if not self.itemMallData then
            self.itemMallData = self.data
        end
        --self.itemIcon = AwardItem(self.icon)
        --self.itemIcon:SetConfig(self.itemMallData.item)
        --self.itemIcon:AddClickTips(self.icon)

        local itemId = String2Table(self.itemMallData.item)[1]
        if type(itemId) == "table" then
            local gender = RoleInfoModel.GetInstance():GetSex()
            itemId = itemId[gender]
        end
        local param = {}
        local operate_param = {}
        param["item_id"] = itemId
        param["model"] = self.model
        param["can_click"] = true
        --param["num"] = String2Table(self.itemMallData.item)[2]
        param["operate_param"] = operate_param
        param["size"] = { x = 80, y = 80 }
        self.itemIcon = GoodsIconSettorTwo(self.icon)
        self.itemIcon:SetIcon(param)
        local colorNum = Config.db_item[itemId].color
        local str = string.format("<color=#%s>%s</color>", ColorUtil.GetColor(colorNum), Config.db_item[itemId].name)
        self.name:GetComponent('Text').text = str
        self.num.text = String2Table(self.itemMallData.item)[2]
        local oriImg = self.originalIcon:GetComponent('Image')
        local curImg = self.currentIcon:GetComponent('Image')
        local payType = tonumber(String2Table(self.itemMallData.original_price)[1])
        local moneyIcon = Config.db_item[payType].icon
        --lua_resMgr:SetImageTexture(self,oriImg,"iconasset/icon_goods_900",tostring(moneyIcon),true,nil,false)
        --lua_resMgr:SetImageTexture(self,curImg,"iconasset/icon_goods_900",tostring(moneyIcon),true,nil,false)
        GoodIconUtil:CreateIcon(self, oriImg, moneyIcon, true)
        GoodIconUtil:CreateIcon(self, curImg, moneyIcon, true)
        local ori_price_component = self.originalPrice:GetComponent('UILineText')
        local tbl = String2Table(self.itemMallData.original_price)
        ori_price_component.text = "Orig:         " .. tbl[2]
        self.curPrice:GetComponent('Text').text = String2Table(self.itemMallData.price)[2]
        if self.itemMallData.discount == 10 then
            SetVisible(self.discount_Bg, false)
        else
            self.FlashdiscountTex:GetComponent('Text').text = tostring(100-(self.itemMallData.discount * 10)) .. "%"
        end
        if self.data.buy_num then
            SetVisible(self.timeText, true)
            SetVisible(self.btn_buy, true)
            SetVisible(self.preview, false)
        else
            SetVisible(self.timeText, false)
            SetVisible(self.btn_buy, false)
            SetVisible(self.preview, true)
            local temp_lv = GetLevelShow(self.itemMallData.limit_level)
            self.preview_text.text = string.format("Available for purchase at Lv.%s\nthis super-value item", temp_lv)
        end
    end
end

function FlashSaleItem:CleanItemSettor()
    if self.itemIcon then
        self.itemIcon:destroy()
        self.itemIcon = nil
    end
end
