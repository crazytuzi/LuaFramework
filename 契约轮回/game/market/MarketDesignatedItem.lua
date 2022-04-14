MarketDesignatedItem = MarketDesignatedItem or class("MarketDesignatedItem",BaseCloneItem)
local MarketDesignatedItem = MarketDesignatedItem

function MarketDesignatedItem:ctor(obj,parent_node,layer)
    --self.abName = "market"
    --self.assetName = "BuyMarketLeftItem"
    --self.layer = layer
    --self.parentPanel = parent_node;
    self.Events = {}
    self.model = MarketModel:GetInstance()
    MarketDesignatedItem.super.Load(self)



end
function MarketDesignatedItem:dctor()
    self.model.seletAppointInfo = nil
    GlobalEvent:RemoveTabListener(self.Events)
    if self.itemicon ~= nil then
        self.itemicon:destroy()
    end

    self.itemicon = nil
    if self.buyPanel then
        self.buyPanel:destroy()
    end
end

function MarketDesignatedItem:LoadCallBack()
    self.nodes =
    {
        "icon",
        "name",
        "powerParent/power",
        "powerParent/downArraw",
        "powerParent/upArraw",
        "price",
        "allPrice",
        "titleText",
        "click",
        "staticText/price/pri1","staticText/price1/pri2",
    }
    self:GetChildren(self.nodes)
    SetLocalPosition(self.transform, 0, 0, 0)
    self.name = GetText(self.name)
    self.power = GetText(self.power)
    self.price = GetText(self.price)
    self.allPrice =GetText(self.allPrice)
    self.titleText = GetText(self.titleText)
    self.pri1 = GetImage(self.pri1)
    self.pri2 = GetImage(self.pri2)
    local iconName = Config.db_item[enum.ITEM.ITEM_GREEN_DRILL].icon
    GoodIconUtil:CreateIcon(self, self.pri1, iconName, true)
    GoodIconUtil:CreateIcon(self, self.pri2, iconName, true)
    self:InitUI()
    self:AddEvent()

end



function MarketDesignatedItem:InitUI()

end

function MarketDesignatedItem:AddEvent()
    function call_back()
        self.model.selectGoodItem = self.data.item
        self.model.seletAppointInfo = self.data
        GlobalEvent:Brocast(MarketEvent.MarketDesignatedClickItem,self.type)
       -- MarketController:GetInstance():RequeseGoodInfo(self.data.item.uid)
    end
    AddClickEvent(self.click.gameObject,call_back)

    local function call_back()
        if self.buyPanel then
            self.buyPanel:destroy()
        end
    end
    self.Events[#self.Events + 1] = GlobalEvent:AddListener(MarketEvent.MarketDesignatedBuy, call_back)
    self.Events[#self.Events + 1] = GlobalEvent:AddListener(MarketEvent.MarketDesignatedRefuse, call_back)
    self.Events[#self.Events + 1] = GlobalEvent:AddListener(MarketEvent.UpShelfMarketAlter, call_back)
    self.Events[#self.Events + 1] = GlobalEvent:AddListener(MarketEvent.UpShelfMarketRemove, call_back)

    self.Events[#self.Events + 1] = GlobalEvent:AddListener(MarketEvent.BuyMarketUpdateGoodData, handler(self, self.UpdateGood))
    self.Events[#self.Events + 1] = GlobalEvent:AddListener(MarketEvent.BuyMarketUpdateTwoGoodData, handler(self, self.UpdateTwoGood))
    self.Events[#self.Events + 1] = GlobalEvent:AddListener(MarketEvent.BuyMarketUpdateThreeGoodData, handler(self, self.UpdateThreeGood))
end

function MarketDesignatedItem:SetData(data,type)
    self.data = data
    self.type = type  -- 1 左边  我发起的  2右边 我收到的
    if not self.data then
        return
    end
    if type == 1 then
        local des = string.format("Trade to <color=#%s>[%s]</color>","f0603c",self.data.to_name)
        self.titleText.text = des
    else
        local des = string.format("Trade from <color=#%s>[%s]</color>","f0603c",self.data.from_name)
        self.titleText.text = des
    end

    local itemCfd = Config.db_item[self.data.item.id]

    self.price.text = self.data.item.price
    self.allPrice.text = tonumber(self.data.item.price ) * tonumber(self.data.item.num)
    --local itemId = self.data.item.id
    local colorNum = itemCfd.color
    local str = string.format("<color=#%s>%s</color>", ColorUtil.GetColor(colorNum), itemCfd.name)
    self.name.text = str

    if itemCfd.type ==  enum.ITEM_TYPE.ITEM_TYPE_EQUIP then  --装备

        self.power.text = "Gear Ratings:"..self.data.item.score

        local putOnEquip = EquipModel.Instance:GetPutonEquipMap(self.data.item.id)
        if putOnEquip ~= nil then
            if putOnEquip.score > self.data.item.score then
                self:SetScore(false)
            else
                self:SetScore(true)
            end
        else
            self:SetScore(true)
        end
    else
        SetVisible(self.power,false)
        SetLocalPosition(self.name.transform,-97.5,-18,0)
       -- Config.db_vip_rights
    end

    self:CreateIcon()
end


function MarketDesignatedItem:CreateIcon()
    if self.itemicon == nil then
        self.itemicon = GoodsIconSettorTwo(self.icon)
    end

    local param = {}
    param["model"] = self.model
    param["item_id"] = self.data.item.id
    param["num"] = self.data.item.num
    param["bind"] = 2
    self.itemicon:SetIcon(param)
    --self.itemicon:UpdateIconByItemId(self.data.item.id,self.data.item.num)
end


function MarketDesignatedItem:SetScore(isUp)
    if isUp then
        SetVisible(self.upArraw,true)
        SetVisible(self.downArraw,false)
    else
        SetVisible(self.downArraw,true)
        SetVisible(self.upArraw,false)
    end
    SetLocalPositionX(self.upArraw,self.power.preferredWidth)
    SetLocalPositionX(self.downArraw,self.power.preferredWidth)
end

function MarketDesignatedItem:UpdateGood(data)
    if self.model.selectGoodItem == self.data.item then
        local operate_param = {}
        local isDown
        if self.type == 1 then
            isDown = true
            local function call_back()
                local item = MarketModel:GetInstance().selectGoodItem
                local type = 1
                local uid = item.uid
                MarketController:GetInstance():RequeseRemove(type,uid)
            end
            GoodsTipController.Instance:SetPutDownSellCB(operate_param,call_back,{data.item}) --下架

            local function call_back(item)
                self.model.selectItem = item[1]
                GlobalEvent:Brocast(MarketEvent.UpShelfMarketUpBtn,2)
            end
            GoodsTipController.Instance:SetChangePriceSellCB(operate_param,call_back,{data.item}) --修改
        else
            isDown = false
            local function call_back()
                local item = MarketModel:GetInstance().selectGoodItem
                local type = 2
                local uid = item.uid
                local num = item.num
                local price = item.price
                MarketController:GetInstance():RequeseBuyItem(type,uid,num,price)
            end
            GoodsTipController.Instance:SetBuyCB(operate_param,call_back,{data.item}) --购买

            local function call_back(item)
                local item = MarketModel:GetInstance().selectGoodItem
                MarketController:GetInstance():RequeseRefuse(item.uid)
            end
            GoodsTipController.Instance:SetRefuseCB(operate_param,call_back,{data.item}) --拒绝
        end

        local param = {}
        param["item_id"] = data.item.id
        param["p_item"] = data.item
        param["model"] = self.model
        param["mType"] = 2
        param["isUp"] = isDown
        param["operate_param"] = operate_param
        param["is_compare"] = true
        self.buyPanel = BuyMarketBuyPanel(self.itemicon.transform)
        self.buyPanel:ShowTip(param)
    end
end

function MarketDesignatedItem:UpdateTwoGood(data)
    if self.model.selectGoodItem == self.data.item then

        local bag = data.item.bag
        if bag == BagModel.Pet then --宠物
            if self.type == 1 then
                local pos = self.transform.position
                local view = PetShowTipView()
                view:SetData(data.item,PetModel.TipType.DownMarket,pos,nil,nil)
                --  view:SetBuyInfo(data.item.id,data.item)
                local function call_back()
                    local item = MarketModel:GetInstance().selectGoodItem
                    local type = 1
                    local uid = item.uid
                    MarketController:GetInstance():RequeseRemove(type,uid)
                end
                view:SetDownShelfCB(call_back,{data.item})

                local function call_back(item)
                    self.model.selectItem = item[1]
                    GlobalEvent:Brocast(MarketEvent.UpShelfMarketUpBtn,2)
                end
                view:SetModifyCB(call_back,{data.item})
                return
            else
                local pos = self.transform.position
                local view = PetShowTipView()
                view:SetData(data.item,PetModel.TipType.DesBuyMarket,pos,nil,nil)
                --  view:SetBuyInfo(data.item.id,data.item)
                local function call_back()
                    local item = MarketModel:GetInstance().selectGoodItem
                    local type = 2
                    local uid = item.uid
                    local num = item.num
                    local price = item.price
                    MarketController:GetInstance():RequeseBuyItem(type,uid,num,price)
                end
                view:SetBuyCB(call_back,{data.item})

                local function call_back()
                    local item = MarketModel:GetInstance().selectGoodItem
                    MarketController:GetInstance():RequeseRefuse(item.uid)
                end
                view:SetRefuseCB(call_back,{data.item})
                return
            end

        end

        local operate_param = {}
        local isDown
        if self.type == 1 then
            isDown = true
            local function call_back()
                local item = MarketModel:GetInstance().selectGoodItem
                local type = 1
                local uid = item.uid
                MarketController:GetInstance():RequeseRemove(type,uid)
            end
            GoodsTipController.Instance:SetPutDownSellCB(operate_param,call_back,{data.item}) --下架

            local function call_back(item)
                self.model.selectItem = item[1]
                GlobalEvent:Brocast(MarketEvent.UpShelfMarketUpBtn,2)
            end
            GoodsTipController.Instance:SetChangePriceSellCB(operate_param,call_back,{data.item}) --修改
        else
            isDown = false
            local function call_back()
                local item = MarketModel:GetInstance().selectGoodItem
                local type = 2
                local uid = item.uid
                local num = item.num
                local price = item.price
                MarketController:GetInstance():RequeseBuyItem(type,uid,num,price)
            end
            GoodsTipController.Instance:SetBuyCB(operate_param,call_back,{data.item}) --购买

            local function call_back(item)
                local item = MarketModel:GetInstance().selectGoodItem
                MarketController:GetInstance():RequeseRefuse(item.uid)
            end
            GoodsTipController.Instance:SetRefuseCB(operate_param,call_back,{data.item}) --拒绝
        end
        local param = {}
        param["item_id"] = data.item.id
        param["p_item"] = data.item
        param["model"] = self.model
        param["mType"] = 2
        param["isUp"] = isDown
        param["operate_param"] = operate_param
        self.buyPanel = BuyMarketBuyTowPanel(self.itemicon.transform)
        self.buyPanel:ShowTip(param)
    end
end

function MarketDesignatedItem:UpdateThreeGood(data)
    if self.model.selectGoodItem == self.data.item then
        local operate_param = {}
        local isDown
        if self.type == 1 then
            isDown = true
            local function call_back()
                local item = MarketModel:GetInstance().selectGoodItem
                local type = 1
                local uid = item.uid
                MarketController:GetInstance():RequeseRemove(type,uid)
            end
            GoodsTipController.Instance:SetPutDownSellCB(operate_param,call_back,{data.item}) --下架

            local function call_back(item)
                self.model.selectItem = item[1]
                GlobalEvent:Brocast(MarketEvent.UpShelfMarketUpBtn,2)
            end
            GoodsTipController.Instance:SetChangePriceSellCB(operate_param,call_back,{data.item}) --修改
        else
            isDown = false
            local function call_back()
                local item = MarketModel:GetInstance().selectGoodItem
                local type = 2
                local uid = item.uid
                local num = item.num
                local price = item.price
                MarketController:GetInstance():RequeseBuyItem(type,uid,num,price)
            end
            GoodsTipController.Instance:SetBuyCB(operate_param,call_back,{data.item}) --购买

            local function call_back(item)
                local item = MarketModel:GetInstance().selectGoodItem
                MarketController:GetInstance():RequeseRefuse(item.uid)
            end
            GoodsTipController.Instance:SetRefuseCB(operate_param,call_back,{data.item}) --拒绝
        end

        local param = {}
        param["item_id"] = data.item.id
        param["p_item"] = data.item
        param["model"] = self.model
        param["mType"] = 2
        param["isUp"] = isDown
        param["operate_param"] = operate_param
        param["is_compare"] = true
        self.buyPanel = BuyMarketBuyThreePanel(self.itemicon.transform)
        self.buyPanel:ShowTip(param)
    end
end

