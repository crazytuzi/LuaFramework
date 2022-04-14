CrossBossRewardItem = CrossBossRewardItem or class("CrossBossRewardItem",BaseCloneItem)
local CrossBossRewardItem = CrossBossRewardItem

function CrossBossRewardItem:ctor(obj,parent_node,layer)
	CrossBossRewardItem.super.Load(self)
end

function CrossBossRewardItem:dctor()
	if self.items then
		destroyTab(self.items)
		self.items = nil
	end
end

function CrossBossRewardItem:LoadCallBack()
	self.nodes = {
		"content",
	}
	self:GetChildren(self.nodes)
	self.items = {}
	self:AddEvent()
end

function CrossBossRewardItem:AddEvent()
end

function CrossBossRewardItem:SetData(data)
	self.data = data
	self:UpdateView()
end

function CrossBossRewardItem:UpdateView()
	destroyTab(self.items)
	self.items = {}
	for i=1, #self.data do
		local item_id = self.data[i]
		local param = {}
		param["item_id"] = item_id
		param["bind"] = 2
		param["size"] = {x=70, y=70}
		param["can_click"] = true

		local item = GoodsIconSettorTwo(self.content)
		item:SetIcon(param)
		self.items[i] = item
	end
end