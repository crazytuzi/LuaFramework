--
-- @Author: chk
-- @Date:   2018-12-18 19:15:39
--
FactionLogView = FactionLogView or class("FactionLogView",BaseItem)
local FactionLogView = FactionLogView

function FactionLogView:ctor(parent_node,layer)
	self.abName = "faction"
	self.assetName = "FactionLogView"
	self.layer = layer
	self.events = {}
	self.itemSettors = {}
	self.model = FactionModel:GetInstance()
	FactionLogView.super.Load(self)
end

function FactionLogView:dctor()
	for i, v in pairs(self.events) do
		self.model:RemoveListener(v)
	end

	for i, v in pairs(self.itemSettors) do
		v:destroy()
	end
end

function FactionLogView:LoadCallBack()
	self.nodes = {
		"ScrollView/Viewport/Content",
	}
	self:GetChildren(self.nodes)
	self:AddEvent()

	self:CreateItems()
end

function FactionLogView:AddEvent()
	self.events[#self.events+1] = self.model:AddListener(FactionEvent.Logs, handler(self,self.CreateItems))

	self.model.logs = {}
	FactionController.Instance:RequestLog()
end

function FactionLogView:CreateItems()
	for i, v in pairs(self.model.logs) do
		self.itemSettors[#self.itemSettors+1] = FactionCareerApplyLogItemSettor(self.Content)
		self.itemSettors[#self.itemSettors]:SetData(v)
	end
end

function FactionLogView:SetData(data)
	self.data = data
end

