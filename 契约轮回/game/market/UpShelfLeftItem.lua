UpShelfLeftItem = UpShelfLeftItem or class("UpShelfLeftItem",BaseCloneItem)
local UpShelfLeftItem = UpShelfLeftItem

function UpShelfLeftItem:ctor(obj,parent_node,layer)
    self.Events = {}
    self.model = MarketModel:GetInstance()
    UpShelfLeftItem.super.Load(self)
end

function UpShelfLeftItem:dctor()
    GlobalEvent:RemoveTabListener(self.Events)

    if self.itemicon ~= nil then
        self.itemicon:destroy()

    end

    self.itemicon = nil
    if self.buyPanel then
        self.buyPanel:destroy()
    end
end


function UpShelfLeftItem:LoadCallBack()
    self.nodes =
    {
        "name",
        "price",
        "icon",
        "bg",
        "click",
        "dia"

    }
    self:GetChildren(self.nodes)
    self.name = GetText(self.name)
    self.price = GetText(self.price)
    --self.btn = GetButton(self.bg)
    self.dia = GetImage(self.dia)
    self:AddEvent()

    local iconName = Config.db_item[enum.ITEM.ITEM_GREEN_DRILL].icon
    GoodIconUtil:CreateIcon(self, self.dia, iconName, true)
end

function UpShelfLeftItem:AddEvent()

    function call_back(target, x, y)
        self.model.selectGoodItem = self.data
        MarketController:GetInstance():RequeseGoodInfo(self.data.uid)

    end
    AddClickEvent(self.click.gameObject, call_back)
    self.Events[#self.Events + 1] = GlobalEvent:AddListener(MarketEvent.UpShelfMarketAlter, handler(self, self.UpShelfMarketRemove))
    self.Events[#self.Events + 1] = GlobalEvent:AddListener(MarketEvent.UpShelfMarketRemove, handler(self, self.UpShelfMarketRemove))
    self.Events[#self.Events + 1] = GlobalEvent:AddListener(MarketEvent.BuyMarketUpdateGoodData, handler(self, self.UpdateGood))
    self.Events[#self.Events + 1] = GlobalEvent:AddListener(MarketEvent.BuyMarketUpdateTwoGoodData, handler(self, self.UpdateTwoGood))
    self.Events[#self.Events + 1] = GlobalEvent:AddListener(MarketEvent.BuyMarketUpdateThreeGoodData, handler(self, self.UpdateThreeGood))
end

function UpShelfLeftItem:SetData(data)
    self.data = data
    self.uid = data.uid
    local allPrice = tonumber(self.data.num)* tonumber(self.data.price)
    self.price.text = allPrice

    local itemId = self.data.id
    local colorNum = Config.db_item[itemId].color
    local str = string.format("<color=#%s>%s</color>", ColorUtil.GetColor(colorNum), Config.db_item[itemId].name)
    self.name.text = str
    if self.itemicon == nil then
        self.itemicon = GoodsIconSettorTwo(self.icon)
    end

    local param = {}
    param["item_id"] = self.data.id
    param["num"] = self.data.num
    param["bind"] = 2
    self.itemicon:SetIcon(param)
    --self.itemicon:UpdateIconByItemId(self.data.id,self.data.num)
end

function UpShelfLeftItem:UpdateGood(data)
    if self.model.selectGoodItem == self.data then
        local operate_param = {}
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
        GoodsTipController.Instance:SetChangePriceSellCB(operate_param,call_back,{data.item})

        local param = {}
        param["item_id"] = data.item.id
        param["p_item"] = data.item
        param["model"] = self.model
        param["operate_param"] = operate_param
        param["mType"] = 1
        param["isUp"] = true
        param["is_compare"] = true
        self.buyPanel = BuyMarketBuyPanel(self.itemicon.transform)
        self.buyPanel:ShowTip(param)
    end
   --
end

function UpShelfLeftItem:UpdateTwoGood(data)
    if self.model.selectGoodItem == self.data then
        local bag = data.item.bag
        if bag == BagModel.Pet then
            local pos = self.transform.position
            local view = PetShowTipView()
            view:SetData(data.item,PetModel.TipType.DownMarket,pos,nil,nil)
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
        end


        local operate_param = {}
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
        GoodsTipController.Instance:SetChangePriceSellCB(operate_param,call_back,{data.item})

        local param = {}
        param["item_id"] = data.item.id
        param["p_item"] = data.item
        param["model"] = self.model
        param["operate_param"] = operate_param
        param["mType"] = 1
        param["isUp"] = true
        self.buyPanel = BuyMarketBuyTowPanel(self.itemicon.transform)
        self.buyPanel:ShowTip(param)

    end
end

function UpShelfLeftItem:UpdateThreeGood(data)
    if self.model.selectGoodItem == self.data then
        local operate_param = {}
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
        GoodsTipController.Instance:SetChangePriceSellCB(operate_param,call_back,{data.item})

        local param = {}
        param["item_id"] = data.item.id
        param["p_item"] = data.item
        param["model"] = self.model
        param["operate_param"] = operate_param
        param["mType"] = 1
        param["isUp"] = true
        param["is_compare"] = true
        self.buyPanel = BuyMarketBuyThreePanel(self.itemicon.transform)
        self.buyPanel:ShowTip(param)
    end
   --
end

function UpShelfLeftItem:UpShelfMarketRemove()
    if self.buyPanel then
        self.buyPanel:destroy()
    end
end


