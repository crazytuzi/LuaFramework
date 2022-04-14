SiegewarThreeItem = SiegewarThreeItem or class("SiegewarThreeItem",BaseItem)
local SiegewarThreeItem = SiegewarThreeItem

function SiegewarThreeItem:ctor(parent_node,layer)
	self.abName = "siegewar"
	self.assetName = "SiegewarThreeItem"
	self.layer = layer

	self.model = SiegewarModel:GetInstance()
	SiegewarThreeItem.super.Load(self)
	self.cities = {}
	self.events = {}
	self.city_list = {}
end

function SiegewarThreeItem:dctor()
	self.cities = nil
	if self.city_list then
		destroyTab(self.city_list)
		self.city_list = nil
	end
	if self.events then
		self.model:RemoveTabListener(self.events)
		self.events = nil
	end
end

function SiegewarThreeItem:LoadCallBack()
	self.nodes = {
		"group2/mcity1", "group2/mcity2","group2/mcity3",
	}
	self:GetChildren(self.nodes)
	self.cities[1] = self.mcity1
	self.cities[2] = self.mcity2
	self.cities[3] = self.mcity3
	self:AddEvent()
	self:UpdateView()
end

function SiegewarThreeItem:AddEvent()
	local function call_back()
		self:UpdateView()
	end
	self.events[#self.events+1] = self.model:AddListener(SiegewarEvent.UpdateCity, call_back)

	local function call_back(scene)
		lua_panelMgr:GetPanelOrCreate(SiegewarBossPanel):Open(scene)
	end
	self.events[#self.events+1] = self.model:AddListener(SiegewarEvent.ClickCity, call_back)
end

function SiegewarThreeItem:SetData(data)

end

function SiegewarThreeItem:UpdateView()
	destroyTab(self.city_list)
	self.city_list = {}
	for i=1, #self.cities do
		local item = SiegewarCityItem(self.cities[i], 0, i)
		self.city_list[#self.city_list+1] = item
	end
end