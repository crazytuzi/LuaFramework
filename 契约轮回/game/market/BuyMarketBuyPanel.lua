BuyMarketBuyPanel = BuyMarketBuyPanel or class("BuyMarketBuyPanel",EquipTipView)
local BuyMarketBuyPanel = BuyMarketBuyPanel

function BuyMarketBuyPanel:ctor(parent_node, layer)
    --self.parent_node = parent_node
    --self.is_loaded = true
    --self.gameObject = newObject(obj)
    --self.transform = self.gameObject.transform
    --self.transform_find = self.transform.Find
    --self.gameObject:SetActive(true)
    --if self.parent_node then
    --    self.transform:SetParent(self.parent_node)
    --end
    --SetLocalScale(self.transform , 1, 1, 1)
    --SetLocalPosition(self.transform , 0 , 0 , 0)
    --SetLocalRotation(self.transform,0,0,0)
    --self:InitData()
    --self:LoadCallBack()
    --self.auto_order_count = 2
    --self:SetOrderByParentMax()
    self.abName = "system"
    self.assetName = "BuyMarketBuyPanel"
    self.layer = layer

    self.careerSettor = nil
    BaseGoodsTip.Load(self)
end

function BuyMarketBuyPanel:BeforeLoad()

end


function BuyMarketBuyPanel:dctor()
    if self.itemicon ~= nil then
        self.itemicon:destroy()
    end
    self.itemicon = nil
    BuyMarketBuyPanel.super.dctor(self)
end

function BuyMarketBuyPanel:LoadCallBack()
    self.nodes =
    {
        "buyPanel",
        "buyPanel/buyPanelBg",
        "buyPanel/name",
        "buyPanel/price",
        "buyPanel/buyBtn",
        "buyPanel/allPrice",
        "buyPanel/iconParent",
        "buyPanel/Count_Group/reduce_btn",
        "buyPanel/Count_Group/plus_btn",
        "buyPanel/Count_Group/max_btn",
        "buyPanel/Count_Group/num",
        "buyPanel/upShlefBuyBtn",
        "btnContain/modifyBtn",
        "btnContain/downShelfBtn",
        "btnContain/marketBuyBtn",
        "btnContain/refuseBtn",
        "buyPanel/static/stText1/priIcon2","buyPanel/static/stText/priIcon1",


    }
    self:GetChildren(self.nodes)
    self.num = GetText(self.num)
    self.num.text = "1"
    self.priIcon1 = GetImage(self.priIcon1)
    self.priIcon2 = GetImage(self.priIcon2)
    --EquipTipView.super.LoadCallBack(self)
    BuyMarketBuyPanel.super.LoadCallBack(self)
    self:AddEvent()
    self:InitUI()
    local iconName = Config.db_item[enum.ITEM.ITEM_GREEN_DRILL].icon
    GoodIconUtil:CreateIcon(self, self.priIcon1, iconName, true)
    GoodIconUtil:CreateIcon(self, self.priIcon2, iconName, true)
end

function BuyMarketBuyPanel:OnTouchenBengin(x, y, isCall)

    --if self.isDown == false then
    --    if self.buyType == 1 then
    --        LayerManager:UIRectangleContainsScreenPoint(self.buyPanel.transform, x, y)
    --    end
    --end
    --BuyMarketBuyPanel.super.OnTouchenBengin(self,x, y, isCall)
    if self.isDown then
        self:CheckClicK(x, y, isCall)
    else
        if self.buyType == 1 then
            local isInViewBG = false
            local isInOperateBtn = false
            isInViewBG = LayerManager:UIRectangleContainsScreenPoint(self.bgRectTra, x, y)

            if LayerManager:UIRectangleContainsScreenPoint(self.buyPanelBg.transform, x, y) then
                isInOperateBtn = true
            end
            if (isCall) then
                return isInViewBG or isInOperateBtn
            else
                if not isInViewBG and not isInOperateBtn then
                    self:destroy()
                end
            end
        else
            self:CheckClicK(x, y, isCall)
        end

    end
end

function BuyMarketBuyPanel:CheckClicK(x, y, isCall)
    local isInViewBG = false
    local isInOperateBtn = false

    isInViewBG = LayerManager:UIRectangleContainsScreenPoint(self.bgRectTra, x, y)

    if (self.btnSettors) then
        for _, v in ipairs(self.btnSettors) do
            if (LayerManager:UIRectangleContainsScreenPoint(v.transform, x, y)) then
                isInOperateBtn = true
                break
            end
        end
    end
    if (isCall) then
        return isInViewBG or isInOperateBtn
    else
        if not isInViewBG and not isInOperateBtn then
            self:destroy()
        end
    end
end


function BuyMarketBuyPanel:InitUI()
   -- SetVisible(self.btnContain,false)
    self.price = GetText(self.price)
    self.name =  GetText(self.name)
    self.allPrice = GetText(self.allPrice)
    self.reduceImg = GetImage(self.reduce_btn)
    self.plusImg = GetImage(self.plus_btn)
    self.maxImg = GetImage(self.max_btn)
    self.upShlefBuyBtn = GetButton(self.upShlefBuyBtn)
    self.modifyBtn = GetButton(self.modifyBtn)
    self.downShelfBtn = GetButton(self.downShelfBtn)
    self.refuseBtn = GetButton(self.refuseBtn)
    self.marketBuyBtn = GetButton(self.marketBuyBtn)
    self.num = GetText(self.num)
    self.num.text = 1
    ShaderManager.GetInstance():SetImageGray(self.reduceImg)
    ShaderManager.GetInstance():SetImageGray(self.plusImg)
    ShaderManager.GetInstance():SetImageGray(self.maxImg)
end

function BuyMarketBuyPanel:ShowTip(param)
    BuyMarketBuyPanel.super.ShowTip(self,param)
    if self.is_compare  then
        self:AddClickCloseBtn()
        self:SetViewPosition()
    end
    self.buyType = param["mType"]
    self.isDown = param["isUp"]
    self:SetItemData(self.goods_item,self.buyType,self.isDown)
end

function BuyMarketBuyPanel:SetItemData(data,type,isDown)
    self.itemData = data
    self.buyType = type
    self.num.text = 1
    if isDown then  --下架
        if type == 1 then --非指定交易

        else

        end
        SetVisible(self.buyPanel,false)
        SetVisible(self.refuseBtn,false)
        SetVisible(self.marketBuyBtn,false)
       -- SetVisible(self.downShelfBtn,true)
    else
        if type == 1 then --非指定交易
            SetVisible(self.modifyBtn,false)
            SetVisible(self.downShelfBtn,false)
            SetVisible(self.refuseBtn,false)
            SetVisible(self.marketBuyBtn,false)
            local itemId = self.itemData.id
            local colorNum = Config.db_item[itemId].color
            local str = string.format("<color=#%s>%s</color>", ColorUtil.GetColor(colorNum), Config.db_item[itemId].name)
            self.name.text = str

            local item = MarketModel:GetInstance().selectGoodItem
            self.price.text = item.price
            self.allPrice.text = item.price
            --self.itemPrice,self.itemNum = MarketModel:GetInstance():GetPriceById(itemId)
            --self.price.text = itemPrice
            self:CreateIcon()
            self:SetBuyPanelPos()
            SetVisible(self.buyPanel,true)
        else
            SetVisible(self.buyPanel,false)
            SetVisible(self.downShelfBtn,false)
            SetVisible(self.modifyBtn,false)
        end

    end
end

function BuyMarketBuyPanel:SetBuyPanelPos()
    local cruHeight = GetSizeDeltaY(self.bg)
    local  max = self.maxViewHeight
    local hight = (max - cruHeight)/2

    SetAnchoredPosition(self.buyPanel,0,hight,0)
end

function BuyMarketBuyPanel:AddEvent()
    --SetVisible(self.btnContain,false)
    local function call_back()
        local item = MarketModel:GetInstance().selectGoodItem
        local type = self.buyType
        local uid = item.uid
        local num = item.num
        local price = item.price
        MarketController:GetInstance():RequeseBuyItem(type,uid,num,price)
    end
    AddButtonEvent(self.upShlefBuyBtn.gameObject,call_back)

    local function call_back()  --下架
        local item = MarketModel:GetInstance().selectGoodItem
        local type = self.buyType
        local uid = item.uid
        MarketController:GetInstance():RequeseRemove(type,uid)
    end
    AddButtonEvent(self.downShelfBtn.gameObject,call_back)

    local function call_back()  --修改
        MarketModel.GetInstance().selectItem = self.equipItem
        GlobalEvent:Brocast(MarketEvent.UpShelfMarketUpBtn,2)
    end
    AddButtonEvent(self.modifyBtn.gameObject,call_back)

    local function call_back()  --购买
        local item = MarketModel:GetInstance().selectGoodItem
        local type = 2
        local uid = item.uid
        local num = item.num
        local price = item.price
        MarketController:GetInstance():RequeseBuyItem(type,uid,num,price)
    end

    AddButtonEvent(self.marketBuyBtn.gameObject,call_back)

    local function call_back()  --拒绝
        local item = MarketModel:GetInstance().selectGoodItem
        MarketController:GetInstance():RequeseRefuse(item.uid)
    end

    AddButtonEvent(self.refuseBtn.gameObject,call_back)


    BuyMarketBuyPanel.super.AddEvent(self)
    SetVisible(self.upShelfBtn,false)
end

function BuyMarketBuyPanel:CreateIcon()
    if self.itemicon == nil then
        self.itemicon = GoodsIconSettorTwo(self.iconParent)
    end

    local param = {}
    param["model"] = MarketModel.GetInstance()
    param["item_id"] = self.itemData.id
    param["num"] = self.itemData.num
    self.itemicon:SetIcon(param)
    --self.itemicon:UpdateIconByItemId(self.itemData.id,self.itemData.num)
end



