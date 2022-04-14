STGoodsItem = STGoodsItem or class("STGoodsItem",BaseItem)
local STGoodsItem = STGoodsItem

function STGoodsItem:ctor(parent_node,layer)
	self.abName = "search_treasure"
	self.assetName = "STGoodsItem"
	self.layer = layer

	if not parent_node then
		return
	end
	--self.model = 2222222222222end:GetInstance()
	STGoodsItem.super.Load(self)
end

function STGoodsItem:dctor()
	if self.goods then
		self.goods:destroy()
		self.goods = nil
	end
end

function STGoodsItem:LoadCallBack()
	self.nodes = {
		"",
	}
	self:GetChildren(self.nodes)
	self:AddEvent()
	self.goods = GoodsIconSettorTwo(self.transform)
	local param = {}
	param["item_id"] = self.item_id
	param["num"] = self.num
	param["bind"] = self.bind
	param["color_effect"] = 4
	param["effect_type"] = 2
	param["stencil_id"] = self.StencilId
	param["stencil_type"] = 3
	param["can_click"] = true
	self.goods:SetIcon(param)

	local scaleAction = cc.ScaleTo(0.001, 3, 3, 3)
	local scaleAction2 = cc.ScaleTo(0.08, 1, 1, 1)
	local action = cc.Sequence(scaleAction, scaleAction2)
	cc.ActionManager:GetInstance():addAction(action, self.transform)
end

function STGoodsItem:AddEvent()
end

function STGoodsItem:SetData(data, num, bind, StencilId)
	self.item_id = data
	self.num = num
	self.bind = bind
	self.StencilId = StencilId
end