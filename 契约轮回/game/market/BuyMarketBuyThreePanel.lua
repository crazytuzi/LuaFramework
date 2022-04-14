BuyMarketBuyThreePanel = BuyMarketBuyThreePanel or class("BuyMarketBuyThreePanel",PetEquipTipView)


--宠物装备用的市场tips
function BuyMarketBuyThreePanel:ctor(parent_node, layer)

    self.abName = "system"
    self.assetName = "BuyMarketBuyPanel"
    self.layer = layer


    BaseGoodsTip.Load(self)
end

function BuyMarketBuyThreePanel:BeforeLoad()
    
end


function BuyMarketBuyThreePanel:dctor()
    if self.itemicon ~= nil then
        self.itemicon:destroy()
    end
    self.itemicon = nil

    BuyMarketBuyThreePanel.super.dctor(self)
end

function BuyMarketBuyThreePanel:LoadCallBack()

  

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
        "buyPanel/upShlefBuyBtn",
        "btnContain/modifyBtn",
        "btnContain/downShelfBtn",
        "btnContain/marketBuyBtn",
        "btnContain/refuseBtn",


    }
    self:GetChildren(self.nodes)
    self:AddEvent()
    self:InitUI()

    
    BuyMarketBuyThreePanel.super.LoadCallBack(self)



end

function BuyMarketBuyThreePanel:OnTouchenBengin(x, y, isCall)

    --if self.isDown == false then
    --    if self.buyType == 1 then
    --        LayerManager:UIRectangleContainsScreenPoint(self.buyPanel.transform, x, y)
    --    end
    --end
    --BuyMarketBuyThreePanel.super.OnTouchenBengin(self,x, y, isCall)
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

function BuyMarketBuyThreePanel:CheckClicK(x, y, isCall)
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


function BuyMarketBuyThreePanel:InitUI()

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
    ShaderManager.GetInstance():SetImageGray(self.reduceImg)
    ShaderManager.GetInstance():SetImageGray(self.plusImg)
    ShaderManager.GetInstance():SetImageGray(self.maxImg)
end

function BuyMarketBuyThreePanel:ShowTip(param)

    BuyMarketBuyThreePanel.super.ShowTip(self,param)
    if self.is_compare  then
        self:AddClickCloseBtn()
        self:SetViewPosition()
    end
    self.buyType = param["mType"]
    self.isDown = param["isUp"]
    self:SetItemData(self.goods_item,self.buyType,self.isDown)
end

function BuyMarketBuyThreePanel:SetItemData(data,type,isDown)
    self.itemData = data
    self.buyType = type
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

function BuyMarketBuyThreePanel:SetBuyPanelPos()
    local cruHeight = GetSizeDeltaY(self.bg)
    local  max = self.maxViewHeight
    local hight = (max - cruHeight)/2

    SetAnchoredPosition(self.buyPanel,0,hight,0)
end

function BuyMarketBuyThreePanel:AddEvent()

    BuyMarketBuyThreePanel.super.AddEvent(self)

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


    SetVisible(self.upShelfBtn,false)
end

function BuyMarketBuyThreePanel:CreateIcon()
    if self.itemicon == nil then
        self.itemicon = GoodsIconSettorTwo(self.iconParent)
    end

    local param = {}
    param["model"] = MarketModel.GetInstance()
    param["item_id"] = self.itemData.id
    param["num"] = self.itemData.num
    --宠物装备的配置表特殊处理
	if not self.goods_item then
		param["cfg"] = self.cfg
	else
		param["cfg"] = self.pet_equip_model.pet_equip_cfg[self.itemData.id][self.goods_item.equip.stren_phase]
	end
    self.itemicon:SetIcon(param)
    --self.itemicon:UpdateIconByItemId(self.itemData.id,self.itemData.num)
end



