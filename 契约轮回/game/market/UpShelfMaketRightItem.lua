UpShelfMaketRightItem = UpShelfMaketRightItem or class("UpShelfMaketRightItem",BaseItem)
local UpShelfMaketRightItem = UpShelfMaketRightItem

function UpShelfMaketRightItem:ctor(parent_node,layer)
    self.abName = "market"
    self.assetName = "UpShelfMaketRightItem"
    self.layer = layer
    self.parentPanel = parent_node;
    self.model = MarketModel:GetInstance()

    UpShelfMaketRightItem.super.Load(self)
end
function UpShelfMaketRightItem:dctor()
    if self.itemicon ~= nil then
        self.itemicon:destroy()
    end
end

function UpShelfMaketRightItem:LoadCallBack()
    self.nodes =
    {
        "ItemParent",
        "bg"
    }
    self:GetChildren(self.nodes)
    SetLocalPosition(self.transform, 0, 0, 0)
    if self.isloadEnding then
        self:InitUI()
    end

    self:AddEvent()

end

function UpShelfMaketRightItem:SetData(data)
    self.data = data
    if self.is_loaded then
        self:InitUI()
    else
        self.isloadEnding = true
    end


end
function UpShelfMaketRightItem:InitUI()
   self:CreateIcon()
end
function UpShelfMaketRightItem:AddEvent()

end




function UpShelfMaketRightItem:CreateIcon()
    if self.itemicon == nil then
        self.itemicon = GoodsIconSettorTwo(self.ItemParent)
    end

    local param = {}
    param["model"] = self.model
    param["item_id"] = self.data.id
    param["num"] = self.data.num
    param["can_click"] = true
    self.itemicon:SetIcon(param)

    --self.itemicon:UpdateIconByItemIdClick(self.data.id,self.data.num)
end