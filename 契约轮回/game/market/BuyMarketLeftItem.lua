

BuyMarketLeftItem = BuyMarketLeftItem or class("BuyMarketLeftItem",BaseCloneItem)
local BuyMarketLeftItem = BuyMarketLeftItem

function BuyMarketLeftItem:ctor(obj,parent_node,layer)
	--self.abName = "market"
	--self.assetName = "BuyMarketLeftItem"
	--self.layer = layer
	--self.parentPanel = parent_node;
	BuyMarketLeftItem.super.Load(self)
	self.model = MarketModel:GetInstance()

	self.mType = 0
	self.isEquip = -1   --1 是装备 0不是
	--BuyMarketLeftItem.super.Load(self)
end
function BuyMarketLeftItem:dctor()
    
end

function BuyMarketLeftItem:LoadCallBack()
    self.nodes = 
    {
        "Text",
		"select"
    }
    self:GetChildren(self.nodes)
    SetLocalPosition(self.transform, 0, 0, 0)
	--if self.isloadEnding then
	--	self:InitUI()
	--end
	self:InitUI()
    self:AddEvent()
    --self:SetTileTextImage("combine_image", "Combine_title")

end

function BuyMarketLeftItem:SetData(data,index)
	self.data = data
	self.isEquip = self.data.is_equip
	self.mType = self.data.type
	self.index = index
	self.Text.text = self.data.desc

end
function BuyMarketLeftItem:InitUI()
	self.Text = GetText(self.Text)
	self.mBtn = GetButton(self)
end

function BuyMarketLeftItem:AddEvent()
	-- body
    local call_back = function(target, x, y)
    	--Notify.ShowText("没有装备")
		GlobalEvent:Brocast(MarketEvent.BuyMarketLeftItemClick, self.data)
    end
    AddClickEvent(self.mBtn.gameObject, call_back);
end

function BuyMarketLeftItem:Select(show)
	SetVisible(self.select,show)
end



