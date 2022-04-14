BuyMarketRightItem = BuyMarketRightItem or class("BuyMarketRightItem",BaseCloneItem)
local BuyMarketRightItem = BuyMarketRightItem

function BuyMarketRightItem:ctor(obj,parent_node,layer)
    --self.abName = "market"
    --self.assetName = "BuyMarketRightItem"
    --self.layer = layer
    --self.parentPanel = parent_node;
    --self.model = MarketModel:GetInstance()

    BuyMarketRightItem.super.Load(self)
end
function BuyMarketRightItem:dctor()
    if self.itemicon then
        self.itemicon:destroy()
        self.itemicon = nil
    end
end

function BuyMarketRightItem:LoadCallBack()
    self.nodes =
    {
        "name",
        "icon",
        "bg",
        "SellNum",
        "click"

    }
    self:GetChildren(self.nodes)

    SetLocalPosition(self.transform, 0, 0, 0)

    self.name = GetText(self.name)
    self.mBtn = GetButton(self.bg)
    self.SellNum = GetText(self.SellNum)
    if self.isEnd then
        self:InitUI()
    end
    
    self:AddEvent()
end

function BuyMarketRightItem:SetData(data,index)
    self.data = data
    self.index = index
    self.type = data.type
    self.stype = data.stype
    if self.is_loaded then
        self:InitUI()
    else
        self.isEnd = true
    end
end
function BuyMarketRightItem:InitUI()
    self.name.text = self.data.desc
    --itemicon:UpdateIconByItemId(11020111)
    if self.itemicon == nil then
        self.itemicon = GoodsIconSettorTwo(self.icon)
    end
    local param = {}
    param["model"] = MarketModel.GetInstance()
    param["item_id"] = self.data.icon
    --param["num"] = 0
    param["no_show_order"] = true
    param["bind"] = 2
    --param["can_click"] = true
    self.itemicon:SetIcon(param)
    --self.itemicon:UpdateIconByItemId(self.data.icon,1)
end
function BuyMarketRightItem:AddEvent()
    local Click_call_back = function(target, x, y)
        if  self.number == nil or self.number == 0 then
            Notify.ShowText("Nothing of this type is on sale")
            return
        end
        GlobalEvent:Brocast(MarketEvent.BuyMarketRightItemClick, self.data)
    end
    AddClickEvent(self.click.gameObject, Click_call_back);
end

function BuyMarketRightItem:SetNum(number)
    --478dc1 e63232
    local color = ""
    self.number = number
    if number <= 5 then
        color = "e63232"
    else
        color = "478dc1"
    end
    self.SellNum.text = string.format("For sale：<color=#%s>%s</color>",color,number)

end

