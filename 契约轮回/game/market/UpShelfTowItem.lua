
UpShelfTowItem = UpShelfTowItem or class("UpShelfTowItem",BaseItem)
local UpShelfTowItem = UpShelfTowItem

function UpShelfTowItem:ctor(parent_node,layer)
    self.abName = "market"
    self.assetName = "UpShelfTowItem"
    self.layer = layer
    self.parentPanel = parent_node;
    self.model = MarketModel:GetInstance()
    self.events = {}

    self.type = -1
    UpShelfTowItem.super.Load(self)
end
function UpShelfTowItem:dctor()
    GlobalEvent.RemoveTabEventListener(self.events)
    if self.itemicon  then
        self.itemicon:destroy()
    end
   -- self.itemicon:destroy()
end

function UpShelfTowItem:LoadCallBack()
    self.nodes =
    {
        "icon",
        "nameText",
        "sellText",
        "Diamond/diamondNum",
        "Diamond"

    }
    self:GetChildren(self.nodes)
    SetLocalPosition(self.transform, 0, 0, 0)
    self.Diamond = GetImage(self.Diamond)
    if self.isloadEnding then
        self:InitUI()
    end

    self:AddEvent()
    local iconName = Config.db_item[enum.ITEM.ITEM_GREEN_DRILL].icon
    GoodIconUtil:CreateIcon(self, self.Diamond, iconName, true)
    --self:SetTileTextImage("combine_image", "Combine_title")

end
--type = 1 右边单独 = 2 左边列表
function UpShelfTowItem:SetData(data,type)
    self.data = data
    self.type = type
    if self.is_loaded then
        self:InitUI()
    else
        self.isloadEnding = true
    end
    if self.type == 2 then
        MarketController:GetInstance():RequeseGoodInfo(data.uid)
    else
        self.pItem = data
    end

end

function UpShelfTowItem:InitUI()
    self.nameText = GetText(self.nameText)
    self.sellText = GetText(self.sellText)
    self.diamondNum = GetText(self.diamondNum)

    local itemCfg = Config.db_item[self.data.id]
    if itemCfg then
        local colorNum = itemCfg.color
        local str = string.format("<color=#%s>%s</color>", ColorUtil.GetColor(colorNum), itemCfg.name)
        self.nameText.text = str
        if self.type  == 1 then
            local min , max  = self.model:GetCanUpShelfItemMaxPrice(self.data.id)
            self.sellText.text = "Unit Price:"
            self.diamondNum.text = string.format("%s~%s",min,max)

        else
            self.sellText.text = "Price"
            self.diamondNum.text = self.data.price
        end
    end
    --if self.type == 1 then
        self:CreateIcon()
    --end

end

function UpShelfTowItem:AddEvent()
    local function call_back(data)
        self.pItem = data.item
        --dump(data)
        self:CreateIcon()
    end
    self.events[#self.events+1] = GlobalEvent.AddEventListener(MarketEvent.ReturnPitem,call_back)
    --self.events[#self.events+1] = GlobalEvent.AddEventListener(MarketEvent.BuyMarketUpdateTwoGoodData,call_back)
end

function UpShelfTowItem:CreateIcon()
    if self.itemicon == nil then
        self.itemicon = GoodsIconSettorTwo(self.icon)
    end
    local param = {}
    param["model"] = self.model
    param["item_id"] = self.data.id
    --if Config.db_item[self.data.id].stype ~= enum.ITEM_STYPE.ITEM_STYPE_PET then
        param["p_item"]  = self.pItem
    --end
    param["num"] = self.data.num
    param["can_click"] = true
    self.itemicon:SetIcon(param)

    --self.itemicon:UpdateIconByItemIdClick(self.data.id,self.data.num)
end

