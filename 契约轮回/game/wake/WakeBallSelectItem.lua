WakeBallSelectItem = WakeBallSelectItem or class("WakeBallSelectItem",BaseItem)
local WakeBallSelectItem = WakeBallSelectItem

function WakeBallSelectItem:ctor(parent_node,layer)
	self.abName = "wake"
	self.assetName = "WakeBallSelectItem"
	self.layer = layer

	--self.model = 2222222222222end:GetInstance()
	WakeBallSelectItem.super.Load(self)
end

function WakeBallSelectItem:dctor()
	if self.effect then
		self.effect:destroy()
	end
end

function WakeBallSelectItem:LoadCallBack()
	self.nodes = {
		"",
	}
	self:GetChildren(self.nodes)
	self:AddEvent()

	self.effect = UIEffect(self.transform, 10120)
	SetLocalPosition(self.transform, 0, -7.4)
end

function WakeBallSelectItem:AddEvent()
end

function WakeBallSelectItem:SetData(data)

end