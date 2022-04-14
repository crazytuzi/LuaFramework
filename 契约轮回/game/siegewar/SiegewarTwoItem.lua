SiegewarTwoItem = SiegewarTwoItem or class("SiegewarTwoItem",BaseItem)
local SiegewarTwoItem = SiegewarTwoItem

function SiegewarTwoItem:ctor(parent_node,layer)
	self.abName = "siegewar"
	self.assetName = "SiegewarTwoItem"
	self.layer = layer

	self.cities = {}
	self.mcities = {}
	self.bcities = {}
	self.lines = {}
	self.city_list = {}
	self.events = {}
	self.model = SiegewarModel:GetInstance()
	SiegewarTwoItem.super.Load(self)
end

function SiegewarTwoItem:dctor()
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

function SiegewarTwoItem:LoadCallBack()
	self.nodes = {
		"group1/city1","group1/city2",
		"group2/mcity1","group2/mcity2","group3/bcity1",
		"lines/line1","lines/line2","lines/line5","lines/line6",
		"lines/line17","lines/line18",
	}
	self:GetChildren(self.nodes)
	self.cities[1] = self.city1
	self.cities[2] = self.city2
	self.mcities[1] = self.mcity1
	self.mcities[2] = self.mcity2
	self.bcities[1] = self.bcity1
	self.lines[1] = self.line1
	self.lines[2] = self.line2
	self.lines[3] = nil
	self.lines[4] = nil
	self.lines[5] = self.line5
	self.lines[6] = self.line6
	self.lines[7] = nil
	self.lines[8] = nil
	self.lines[9] = nil
	self.lines[10] = nil
	self.lines[11] = nil
	self.lines[12] = nil
	self.lines[13] = nil
	self.lines[14] = nil
	self.lines[15] = nil
	self.lines[16] = nil
	self.lines[17] = self.line17
	self.lines[18] = self.line18
	self:AddEvent()
	self:UpdateView()
end

function SiegewarTwoItem:AddEvent()
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
	end
	self.events[#self.events+1] = self.model:AddListener(SiegewarEvent.ClickCity, call_back)
end

function SiegewarTwoItem:SetData(data)

end

function SiegewarTwoItem:UpdateView()
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

function SiegewarTwoItem:UpdateLines()
	for i=1, 18 do
		if self.lines[i] then
			SetVisible(self.lines[i], false)
		end
	end
	local my_indexes = self.model:GetMyCityIndex(1)
	for _, my_index in pairs(my_indexes) do
		local lines_index = self.model:CityIndex2Lines(1, my_index)
		for i=1, #lines_index do
			if self.lines[lines_index[i]] then
				SetVisible(self.lines[lines_index[i]], true)
			end
		end
	end
	local my_indexes_m = self.model:GetMyCityIndex(2)
	if my_indexes_m then
		for _, my_index_m in pairs(my_indexes_m) do
			local lines_index_m = self.model:CityIndex2Lines(2, my_index_m)
			for i=1, #lines_index_m do
				if self.lines[lines_index_m[i]] then
					SetVisible(self.lines[lines_index_m[i]], true)
				end
			end
		end
	end
end