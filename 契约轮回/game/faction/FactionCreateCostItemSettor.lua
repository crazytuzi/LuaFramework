--
-- @Author: chk
-- @Date:   2019-01-08 19:38:16
--
FactionCreateCostItemSettor = FactionCreateCostItemSettor or class("FactionCreateCostItemSettor",BaseItem)
local FactionCreateCostItemSettor = FactionCreateCostItemSettor

function FactionCreateCostItemSettor:ctor(parent_node,layer)
	self.abName = "faction"
	self.assetName = "FactionCreateCostItem"
	self.layer = layer

	--self.model = FactionMode:GetInstance()
	FactionCreateCostItemSettor.super.Load(self)
end

function FactionCreateCostItemSettor:dctor()
end

function FactionCreateCostItemSettor:LoadCallBack()
	self.nodes = {
		"name",
		"value",
	}
	self:GetChildren(self.nodes)
	self:AddEvent()

	local itemCfg = Config.db_item[self.cost_id]
	--GoodIconUtil.GetInstance():CreateIcon(self,GetImage(self.icon),itemCfg.icon,true)
	self.nameTxt = GetText(self.name)
	self.valueTxt = GetText(self.value)

	self.nameTxt.text = itemCfg.name
	self.valueTxt.text = tostring(self.cost_value)


	--local valueRectTra = self.value:GetComponent('RectTran')
	SetAnchoredPosition(self.value,self.nameTxt.preferredWidth + 6,0)
	SetAnchoredPosition(self.transform,0,(1 - self.index) * 30)
end

function FactionCreateCostItemSettor:AddEvent()
end

function FactionCreateCostItemSettor:SetData(cost_id,cost_value,index)
	self.cost_value = cost_value
	self.cost_id = cost_id
	self.index = index
end
