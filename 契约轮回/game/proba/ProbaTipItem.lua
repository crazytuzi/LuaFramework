ProbaTipItem = ProbaTipItem or class("ProbaTipItem",BaseCloneItem)
local ProbaTipItem = ProbaTipItem

function ProbaTipItem:ctor(obj,parent_node,layer)
	ProbaTipItem.super.Load(self)
end

function ProbaTipItem:dctor()
end

function ProbaTipItem:LoadCallBack()
	self.nodes = {
		"id", "name", "prob", 
	}
	self:GetChildren(self.nodes)
	self.id = GetText(self.id)
	self.name = GetText(self.name)
	self.prob = GetText(self.prob)
	self:AddEvent()
end

function ProbaTipItem:AddEvent()
end

function ProbaTipItem:SetData(data,idx)
	self.data = data
	self.idx=idx
	if self.is_loaded then
		self:UpdateView()
	end
end

function ProbaTipItem:UpdateView()
	self.id.text = self.idx
	self.name.text = self.data.item
	self.prob.text = self.data.prob
end