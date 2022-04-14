-- @Author: lwj
-- @Date:   2018-11-19 11:43:22
-- @Last Modified time: 2018-11-19 11:43:26

ShopItem = ShopItem or class("ShopItem", BaseCloneItem)
local ShopItem = ShopItem

function ShopItem:ctor(parent_node, layer)
    self.isCanBuy = true

    ShopItem.super.Load(self)
end

function ShopItem:dctor()
    if self.handelselectevent_id then
        GlobalEvent:RemoveListener(self.handelselectevent_id)
        self.handelselectevent_id = nil
    end
    self:CleanItemSettor()
end

function ShopItem:LoadCallBack()
    self.model = ShopModel.GetInstance()
    self.nodes = {
        "name",
        "Count",
        "discount_Bg/discount",
        "discount_Bg",
        "icon",
        "VipLimit",
        "sel_img",
        "bg", "can_buy", "can_buy/diam_img", "can_buy/diam_img/price",
    }
    self:GetChildren(self.nodes)
    self.nameT = self.name:GetComponent('Text')
    self.timeT = self.Count:GetComponent('Text')
    self.discountT = self.discount:GetComponent('Text')
    self.priceT = self.price:GetComponent('Text')
    self.costI = self.diam_img:GetComponent('Image')
    self.vip_limit = GetText(self.VipLimit)
    self:AddEvent()
end

function ShopItem:AddEvent()
    local function call_back(target, x, y)
        self:ClickCallBack()
    end
    AddClickEvent(self.bg.gameObject, call_back)

    self.handelselectevent_id = GlobalEvent:AddListener(ShopEvent.GoodItemClick, handler(self, self.Select))
end

function ShopItem:SetData(data)
    self.data = data
    local limitNum = self.data.mallData.limit_num
    if limitNum ~= 0 and self.data.boughtRecord == nil then
        self.data.boughtRecord = 0
    end
    self:UpdateView()
end

function ShopItem:UpdateView()
    local tbl = String2Table(self.data.mallData.item)
    local itemId = RoleInfoModel:GetInstance():GetItemId(tbl[1])
    self:CleanItemSettor()
    local param = {}
    local operate_param = {}
    local cfg = Config.db_item[tonumber(itemId)]
    param["cfg"] = cfg
    param["model"] = self.model
    --param["can_click"] = true
    param["operate_param"] = operate_param
    param["size"] = { x = 80, y = 80 }
    param["out_call_back"] = handler(self, self.ClickCallBack)
    param['bind'] = tbl[3] or 1
    self.itemIcon = GoodsIconSettorTwo(self.icon)
    self.itemIcon:SetIcon(param)
    self.itemIcon:UpdateRayTarget(false)

    local limitNum = self.data.mallData.limit_num
    if limitNum == 0 then
        SetVisible(self.Count, false)
    else
        SetVisible(self.Count, true)
        if self.data.boughtRecord == nil then
            self.data.boughtRecord = 0
        end
        self.timeT.text = limitNum - self.data.boughtRecord .. "/" .. limitNum
        if limitNum - self.data.boughtRecord == 0 then
            SetColor(self.timeT, 255, 0, 0, 255)
        end
    end
    local colorNum = Config.db_item[itemId].color
    local str = string.format("<color=#%s>%s</color>", ColorUtil.GetColor(colorNum), Config.db_item[itemId].name)
    self.nameT.text = str

    local tbl = self.model.default_shop_id
    if tbl then
        local is_self = false
        if type(tbl) == "number" then
            if self.data.mallData.id == tbl then
                is_self = true
            end
        else
            for i = 1, #tbl do
                if self.data.mallData.id == tbl[i] then
                    is_self = true
                    break
                end
            end
        end
        if is_self then
            self.model.default_shop_id = nil
            self.model:Brocast(ShopEvent.MoveContentWhenSelect, self.data.index)
            self:ClickCallBack()
            self.model:Brocast(ShopEvent.UpdateLeftContenetPos, self.data.mallData.id)
        end
    else
        if self.data.mallData.order == self.model.min_order then
            self:ClickCallBack()
        end
    end

    local vip_lv = RoleInfoModel.GetInstance():GetMainRoleVipLevel()
    local vip_limit_cf = self.data.mallData.limit_vip
    if vip_lv < vip_limit_cf then
        self.vip_limit.text = string.format(ConfigLanguage.Shop.VipLimit, vip_limit_cf)
        SetVisible(self.VipLimit, true)
        SetVisible(self.can_buy, false)
        SetVisible(self.discount_Bg, false)
        self.isCanBuy = false
    else
        SetVisible(self.VipLimit, false)
        SetVisible(self.can_buy, true)
        SetVisible(self.discount_Bg, true)
        self.isCanBuy = true
    end
    local payType = tonumber(String2Table(self.data.mallData.price)[1])
    local iconName = nil
    if self.model.curMallType == "2,2" then
        iconName = "90010004"
    else
        iconName = Config.db_item[payType].icon
    end
    GoodIconUtil:CreateIcon(self, self.costI, iconName, true)

    --折扣
    if self.data.mallData.discount >= 10 then
        SetVisible(self.discount_Bg, false)
    elseif self.isCanBuy then
        SetVisible(self.discount_Bg, true)
        self.discountT.text = 100 - (self.data.mallData.discount * 10) .. "%"
    end
    --价格
    self.priceT.text = String2Table(self.data.mallData.price)[2]
end

function ShopItem:UpdateLimitText(num)
    local limitNum = self.data.mallData.limit_num
    local canBuyNum = limitNum - num
    self.timeT.text = canBuyNum .. "/" .. limitNum
    if canBuyNum == 0 then
        SetColor(self.timeT, 255, 0, 0, 255)
    end
    self.data.boughtRecord = num
    if ShopModel:GetInstance().curId == self.data.mallData.id then
        ShopModel:GetInstance().curLimit = self.data.boughtRecord
        GlobalEvent:Brocast(ShopEvent.UpdatePanelReaminText, canBuyNum)
    end
end

function ShopItem:ClickCallBack()
    ShopModel:GetInstance().curId = self.data.mallData.id
    local transferData = {}
    transferData.id = self.data.mallData.id
    if self.data.mallData.limit_num ~= "0" and self.data.boughtRecord then
        transferData.remain = self.data.mallData.limit_num - self.data.boughtRecord
    end
    ShopModel:GetInstance().curLimit = self.data.boughtRecord
    GlobalEvent:Brocast(ShopEvent.GoodItemClick, transferData, self.isCanBuy)
end

function ShopItem:Select(data)
    SetVisible(self.sel_img, data.id == self.data.mallData.id)
end

function ShopItem:CleanItemSettor()
    if self.itemIcon then
        self.itemIcon:destroy()
        self.itemIcon = nil
    end
end