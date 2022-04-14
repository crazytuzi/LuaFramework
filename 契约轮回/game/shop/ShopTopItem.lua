-- @Author: lwj
-- @Date:   2018-11-14 20:25:05
-- @Last Modified time: 2018-11-14 20:25:07


ShopTopItem = ShopTopItem or class("ShopTopItem", BaseItem)
local ShopTopItem = ShopTopItem

function ShopTopItem:ctor(parent_node, layer)
    self.abName = "shop"
    self.assetName = "ShopTopItem"
    self.layer = layer

    self.model = ShopModel:GetInstance()
    self.isNeedSel = false
    self.globalEvents = self.globalEvents or {}
    BaseItem.Load(self)
end

function ShopTopItem:dctor()
    if self.globalEvents then
        for i, v in pairs(self.globalEvents) do
            GlobalEvent:RemoveListener(v)
        end
        self.globalEvents = {}
    end
end

function ShopTopItem:LoadCallBack()
    self.nodes = {
        "sel_img",
        "Image",
        "Text",
    }
    self:GetChildren(self.nodes)
    self.name_Text = self.Text:GetComponent('Text')
    self.bg_Img = self.Image:GetComponent('Image')
    self.sel_Img = self.sel_img:GetComponent("Image")
    self:AddEvent()

    self:UpdateView()
end

function ShopTopItem:AddEvent()
    local function call_back(target, x, y)
        local goodsType = self.data.goods_type
        self.model.curMallType = goodsType
        GlobalEvent:Brocast(ShopEvent.TopMenuClick, goodsType)
    end
    AddClickEvent(self.bg_Img.gameObject, call_back)

    self.globalEvents[#self.globalEvents + 1] = GlobalEvent:AddListener(ShopEvent.TopMenuClick, handler(self, self.Select))
end

function ShopTopItem:SetData(data)
    self.data = data
    if self.model.default_toggle then
        if self.data.index == self.model.default_toggle then
            self:SetDefault()
            self.model.default_toggle = nil
        end
    else
        if self.data.goods_type == self.data.shop_id .. ',1' or self.model:GetFlashSaleListNums() < 1 and self.data.shop_id == 1 then
            self:SetDefault()
        end
    end
end

function ShopTopItem:SetDefault()
    self.isNeedSel = true
    GlobalEvent:Brocast(ShopEvent.TopMenuClick, self.data.goods_type)
    self.model.curMallType = self.data.goods_type
end

function ShopTopItem:UpdateView()
    self.name_Text.text = self.data.type_name
    if self.isNeedSel then
        self:Select(self.data.goods_type)
    end
end

function ShopTopItem:Select(id)
    SetVisible(self.sel_Img, id == self.data.goods_type)
end