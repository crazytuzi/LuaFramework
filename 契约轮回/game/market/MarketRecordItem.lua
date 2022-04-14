MarketRecordItem = MarketRecordItem or class("MarketRecordItem",BaseCloneItem)
local MarketRecordItem = MarketRecordItem

function MarketRecordItem:ctor(obj,parent_node,layer)
    --self.abName = "market"
    --self.assetName = "BuyMarketLeftItem"
    --self.layer = layer
    --self.parentPanel = parent_node;
    MarketRecordItem.super.Load(self)
    self.model = MarketModel:GetInstance()
    --BuyMarketLeftItem.super.Load(self)
end
function MarketRecordItem:dctor()
    if self.itemicon ~= nil then
        self.itemicon:destroy()
    end
end

function MarketRecordItem:LoadCallBack()
    self.nodes =
    {
        "icon",
        "name",
        "powerParent/power",
        "powerParent/upArraw",
        "powerParent/downArraw",
        "des",
        "time",
        "taxPrice",
        "incomePrice",
        "taxPrice/pri1","incomePrice/pri2",
    }
    self:GetChildren(self.nodes)
    SetLocalPosition(self.transform, 0, 0, 0)
    self.name = GetText(self.name)
    self.power = GetText(self.power)
    self.des = GetText(self.des)
    self.time = GetText(self.time)
    self.taxPrice = GetText(self.taxPrice)
    self.incomePrice = GetText(self.incomePrice)
    self.pri1 = GetImage(self.pri1)
    self.pri2 = GetImage(self.pri2)
    self:InitUI()
    self:AddEvent()
    local iconName = Config.db_item[enum.ITEM.ITEM_GREEN_DRILL].icon
    GoodIconUtil:CreateIcon(self, self.pri1, iconName, true)
    GoodIconUtil:CreateIcon(self, self.pri2, iconName, true)
end

function MarketRecordItem:SetData(data)
    self.data = data
    self.type = data.type
    local itemCfd = Config.db_item[self.data.item.id]
    local marketItem = self.data.item
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
        SetLocalPosition(self.name.transform,-358.7,0,0)

    end

    self:CreateIcon()
    if self.type == 1 then
        if self.data.inout > 0 then
            self.des.text = "Sell at the market"
        else
            self.des.text = "Buy at the market"
        end
    else
        if self.data.inout > 0 then
            self.des.text = "Designated sale"
        else
            self.des.text = "Designated purchase"
        end
    end
    self.taxPrice.text = self.data.tax
    local timeTab = TimeManager:GetTimeDate(self.data.time)
    local timestr = "";
    if timeTab.year then
        timestr = timestr .. string.format("%02d", timeTab.year) .. "-";
    end
    if timeTab.month then
        timestr = timestr .. string.format("%02d", timeTab.month) .. "-";
    end
    if timeTab.yday then
        timestr = timestr .. string.format("%d", timeTab.day) .. " ";
    end
    if timeTab.hour then
        timestr = timestr .. string.format("%02d", timeTab.hour) .. ":";
    end
    if timeTab.min then
        timestr = timestr .. string.format("%02d", timeTab.min) .. ":";
    end
    if timeTab.sec then
        timestr = timestr .. string.format("%02d", timeTab.sec);
    end


    dump(timeTab)
    self.time.text =  timestr
   -- self.incomePrice.text = self.data.inout
    local color = ""
    if self.data.inout > 0 then
        color = "478dc1"
    else
        color = "e63232"
    end
    self.incomePrice.text = string.format("<color=#%s>%s</color>",color,self.data.inout)



end
function MarketRecordItem:InitUI()


end

function MarketRecordItem:AddEvent()

end

function MarketRecordItem:CreateIcon()
    if self.itemicon == nil then
        self.itemicon = GoodsIconSettorTwo(self.icon)
    end

    local param = {}
    param["model"] = self.model
    param["item_id"] = self.data.item.id
    param["num"] = self.data.item.num
    param["can_click"] = true
    param["bind"] = 2
    --param["size"] = {x=70,y=70}
    self.itemicon:SetIcon(param)
    --self.itemicon:UpdateIconByItemIdClick(self.data.item.id,self.data.item.num)
end

function MarketRecordItem:SetScore(isUp)
    if isUp then
        SetVisible(self.upArraw,true)
        SetVisible(self.downArraw,false)
    else
        SetVisible(self.downArraw,true)
        SetVisible(self.upArraw,false)
    end
    SetLocalPositionX(self.upArraw,self.power.preferredWidth - 45)
    SetLocalPositionX(self.downArraw,self.power.preferredWidth-45)
end