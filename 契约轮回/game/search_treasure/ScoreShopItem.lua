

ScoreShopItem = ScoreShopItem or class("ScoreShopItem", BaseItem)
local ScoreShopItem = ScoreShopItem

function ScoreShopItem:ctor(parent_node, layer)
    self.abName = "search_treasure"
    self.assetName = "ScoreShopItem"
    self.layer = layer

    self.data = nil --Item数据
    self.price = nil --商品价格
    self.canBuy = nil --是否可以购买
    self.IconItem = nil --Icon

    self.model = ScoreShopModel:GetInstance()
    self.stModel = SearchTreasureModel:GetInstance()

    BaseItem.Load(self)
  
end

function ScoreShopItem:dctor()
    if self.IconItem then
        self.IconItem:destroy()
        self.IconItem = nil
    end
end

function ScoreShopItem:LoadCallBack()
    self.nodes = {
        "Bg",
        "Icon",
        "Select",
        "txt_Name",
        "btn_Exchange",
        "txt_Price",
        "img_Money",
    }
    self:GetChildren(self.nodes)
    
    self.Bg = GetRectTransform(self.Bg)
    self.Icon = GetRectTransform(self.Icon)
    self.Select = GetRectTransform(self.Select)

    self.txt_Name = GetText(self.txt_Name)
    self.txt_Price = GetText(self.txt_Price)
    self.btn_Exchange = GetButton(self.btn_Exchange)
    self.img_Money = GetImage(self.img_Money)

    self:AddEvent()
    self:InitUI()
    self:UpdatePriceColor()
end



function ScoreShopItem:AddEvent()

    --选中物品高亮
    local function call_back(target, x, y)
        self:OnClick()
    end
    AddClickEvent(self.Bg.gameObject, call_back)

    local function call_back2(target, x, y)
        self:OnClick()

        if self.canBuy then
            --可以购买
            ShopController:GetInstance():RequestBuyGoods(self.data.id,1)
        else
            --无法购买 飘字提示
           Notify.ShowText(ConfigLanguage.SearchT.AlertMsg7)
        end
    end
    AddClickEvent(self.btn_Exchange.gameObject, call_back2)



    
end

function ScoreShopItem:SetData(data)
    self.data = data
end

function ScoreShopItem:InitUI()

    local param = {}
    local item = String2Table(self.data.item)
    local itemId = item[1]
    local cfg = Config.db_item[itemId]
    param["cfg"] = cfg
    param["bind"] = cfg.isbind
    param["can_click"] = true

    local function call_back(target, x, y)
        self:OnClick()
    end
    param["out_call_back"] = call_back

    self.IconItem = GoodsIconSettorTwo(self.Icon)
    self.IconItem:SetIcon(param)

    self.txt_Name.text = cfg.name;

    local price = String2Table(self.data.price)
    self.price = price[2]
    self.txt_Price.text = tostring(price[2])

    local icon = Config.db_item[self.stModel.score_key_id].icon
    GoodIconUtil.GetInstance():CreateIcon(self,self.img_Money, icon,true)
end

--刷新价格颜色
function ScoreShopItem:UpdatePriceColor(  )
    local scoreNum = RoleInfoModel:GetInstance():GetRoleValue(Constant.GoldType.STScore)
    if self.price <= scoreNum then
        --绿色
        self.canBuy = true
        SetColor(self.txt_Price,9,176,5,255)
        
    else
       --红色
       self.canBuy = false
       SetColor(self.txt_Price,255,0,0,255)
    end
end

function ScoreShopItem:OnClick()

    if self.model.curSelectItem then

        if self.model.curSelectItem == self then
            return
        end

        SetVisible(self.model.curSelectItem.Select,false)
    end

    self.model.curSelectItem = self
    SetVisible(self.Select,true)


end



