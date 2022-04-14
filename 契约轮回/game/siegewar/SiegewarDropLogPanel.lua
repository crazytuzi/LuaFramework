SiegewarDropLogPanel = SiegewarDropLogPanel or class("SiegewarDropLogPanel",BaseItem)
local SiegewarDropLogPanel = SiegewarDropLogPanel

function SiegewarDropLogPanel:ctor(parent_node,layer)
	self.abName = "siegewar"
	self.assetName = "SiegewarDropLogPanel"
	self.layer = layer

	self.model = SiegewarModel:GetInstance()
	SiegewarDropLogPanel.super.Load(self)
	self.events = {}
	self.global_events = {}
	self.item_list = {}
end

function SiegewarDropLogPanel:dctor()
	if self.events then
		self.model:RemoveTabListener(self.events)
		self.events = nil
	end
	if self.item_list then
		destroyTab(self.item_list)
		self.item_list = nil
	end
	if self.global_events then
		GlobalEvent:RemoveTabListener(self.global_events)
		self.global_events = nil
	end
end

function SiegewarDropLogPanel:LoadCallBack()
	self.nodes = {
		"ScrollView/Viewport/Content/killlogItem","ScrollView/Viewport/Content",
	}
	self:GetChildren(self.nodes)
	self.killlogItem_go = self.killlogItem.gameObject
	SetVisible(self.killlogItem_go, false)
	self:AddEvent()
	SiegewarController.GetInstance():RequestDrop()
end

function SiegewarDropLogPanel:AddEvent()
	local function call_back(logs)
		local function sort_func(a, b)
			return a.time > b.time
		end
		table.sort( logs, sort_func)
		for i=1, #logs do
			local item = self.item_list[i] or SiegewarDropLogItem(self.killlogItem_go, self.Content)
			item:SetData(logs[i])
			if i % 2 == 0 then
				item:HideBg()
			end
			self.item_list[i] = item
		end
	end
	self.events[#self.events+1] = self.model:AddListener(SiegewarEvent.UpdateRank, call_back)

	self.global_events[#self.global_events + 1] = GlobalEvent:AddListener(GoodsEvent.QueryDroppedEvent, handler(self, self.OnQueryDropped))
end

function SiegewarDropLogPanel:SetData(data)

end

function SiegewarDropLogPanel:OnQueryDropped(pItem)
    BagModel:GetInstance():ShowPItemTip(pItem, self.transform)
end