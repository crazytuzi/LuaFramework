SiegewarEightItem = SiegewarEightItem or class("SiegewarEightItem",BaseItem)
local SiegewarEightItem = SiegewarEightItem

function SiegewarEightItem:ctor(parent_node,layer)
	self.abName = "siegewar"
	self.assetName = "SiegewarEightItem"
	self.layer = layer

	self.cities = {}
	self.mcities = {}
	self.bcities = {}
	self.lines = {}
	self.city_list = {}
	self.events = {}
	self.model = SiegewarModel:GetInstance()
	SiegewarEightItem.super.Load(self)
end

function SiegewarEightItem:dctor()
	self.cities = nil
	self.mcities = nil
	self.bcities = nil
	self.lines = nil
	if self.city_list then
		destroyTab(self.city_list)
		self.city_list = nil
	end
	if self.events then
		self.model:RemoveTabListener(self.events)
		self.events = nil
	end
end

function SiegewarEightItem:LoadCallBack()
	self.nodes = {
		"group1/city1","group1/city2","group1/city3","group1/city4","group1/city5","group1/city6","group1/city7","group1/city8",
		"group2/mcity1","group2/mcity2","group2/mcity3","group2/mcity4","group3/bcity1",
		"lines/line1","lines/line2","lines/line3","lines/line4","lines/line5","lines/line6","lines/line7","lines/line8",
		"lines/line9","lines/line10","lines/line11","lines/line12","lines/line13","lines/line14","lines/line15","lines/line16",
		"lines/line17","lines/line18","lines/line19","lines/line20",
	}
	self:GetChildren(self.nodes)
	self.cities[1] = self.city1
	self.cities[2] = self.city2
	self.cities[3] = self.city3
	self.cities[4] = self.city4
	self.cities[5] = self.city5
	self.cities[6] = self.city6
	self.cities[7] = self.city7
	self.cities[8] = self.city8
	self.mcities[1] = self.mcity1
	self.mcities[2] = self.mcity2
	self.mcities[3] = self.mcity3
	self.mcities[4] = self.mcity4
	self.bcities[1] = self.bcity1
	self.lines[1] = self.line1
	self.lines[2] = self.line2
	self.lines[3] = self.line3
	self.lines[4] = self.line4
	self.lines[5] = self.line5
	self.lines[6] = self.line6
	self.lines[7] = self.line7
	self.lines[8] = self.line8
	self.lines[9] = self.line9
	self.lines[10] = self.line10
	self.lines[11] = self.line11
	self.lines[12] = self.line12
	self.lines[13] = self.line13
	self.lines[14] = self.line14
	self.lines[15] = self.line15
	self.lines[16] = self.line16
	self.lines[17] = self.line17
	self.lines[18] = self.line18
	self.lines[19] = self.line19
	self.lines[20] = self.line20
	self:AddEvent()
	self:UpdateView()
end

function SiegewarEightItem:AddEvent()
	local function call_back()
		self:UpdateView()
	end
	self.events[#self.events+1] = self.model:AddListener(SiegewarEvent.UpdateCity, call_back)

	local function call_back(scene)
		local city = self.model.cities[scene]
		local mysuid = RoleInfoModel:GetInstance():GetRoleValue("suid")
		if city.level == 1 and mysuid ~= city.suid then
			return Notify.ShowText("Unable to attack this city")
		end
		if city.level == 2 then
			local index = self.model:GetCityIndex(2, scene)
			if not self.model:IsCanAttackMCity(index) then
				return Notify.ShowText("You can only attack cities on the same server and middle cities nearby")
			end
		end
		lua_panelMgr:GetPanelOrCreate(SiegewarBossPanel):Open(scene)
		--[[if not self.bosspanel then
			self.bosspanel = SiegewarBossPanel(self.parent_node)
		end
		self.bosspanel:SetData(scene)--]]
	end
	self.events[#self.events+1] = self.model:AddListener(SiegewarEvent.ClickCity, call_back)
end

function SiegewarEightItem:SetData(data)

end

function SiegewarEightItem:UpdateView()
	destroyTab(self.city_list)
	self.city_list = {}
	for i=1, #self.cities do
		local item = SiegewarCityItem(self.cities[i], 1, i)
		self.city_list[#self.city_list+1] = item
	end
	for i=1, #self.mcities do
		local item = SiegewarCityItem(self.mcities[i], 2, i)
		self.city_list[#self.city_list+1] = item
	end
	for i=1, #self.bcities do
		local item = SiegewarCityItem(self.bcities[i], 3, i)
		self.city_list[#self.city_list+1] = item
	end
	self:UpdateLines()
end

function SiegewarEightItem:UpdateLines()
	for i=1, #self.lines do
		SetVisible(self.lines[i], false)
	end
	local my_indexes = self.model:GetMyCityIndex(1)
	for _, my_index in pairs(my_indexes) do
		local lines_index = self.model:CityIndex2Lines(1, my_index)
		for i=1, #lines_index do
			SetVisible(self.lines[lines_index[i]], true)
		end
	end
	local my_indexes_m = self.model:GetMyCityIndex(2)
	if my_indexes_m then
		for _, my_index_m in pairs(my_indexes_m) do
			local lines_index_m = self.model:CityIndex2Lines(2, my_index_m)
			for i=1, #lines_index_m do
				SetVisible(self.lines[lines_index_m[i]], true)
			end
		end
	end
end