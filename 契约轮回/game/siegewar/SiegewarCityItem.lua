SiegewarCityItem = SiegewarCityItem or class("SiegewarCityItem",Node)
local SiegewarCityItem = SiegewarCityItem

function SiegewarCityItem:ctor(obj, level, index)
	if not obj then
        return
    end
    self.transform = obj.transform
    self.gameObject = self.transform.gameObject
    self.transform_find = self.transform.Find
    self.level = level
    self.index = index

    self.model = SiegewarModel.GetInstance()
    self:Init()
end

function SiegewarCityItem:dctor()
	self.transform = nil
    self.gameObject = nil
end

function SiegewarCityItem:Init()
	self.is_loaded = true
	self.nodes = {
		"city_img", "name", "bosscount", "state", "box"
	}
	self:GetChildren(self.nodes)
	self.city_img = GetImage(self.city_img)
	self.state = GetImage(self.state)
	self.name = GetText(self.name)
	self.bosscount = GetText(self.bosscount)
	SetVisible(self.box, false)
	self:AddEvent()

	self:UpdateView()
end

function SiegewarCityItem:AddEvent()
	local function call_back(target,x,y)
		if not self.city then
			return
		end
		self.model:Brocast(SiegewarEvent.ClickCity, self.city.scene)
	end
	AddClickEvent(self.gameObject,call_back)
end

function SiegewarCityItem:UpdateView()
	local city = self.model:GetCityByIndex(self.level, self.index)
	self.city = city
	if city and city.level == 0 then
		self.name.text = city.name
		if city.score > 0 then
			lua_resMgr:SetImageTexture(self,self.state, 'siegewar_image', 'join', true)
		else
			SetVisible(self.state, false)
		end
		if self.bosscount then
			self.bosscount.text = string.format("Boss Left %s", city.boss)
		end
		return
	end
	local my_suid = RoleInfoModel:GetInstance():GetRoleValue("suid")
	if city and city.suid > 0 then
		if city.temp and self.level == 2 then
			self.name.text = string.format("S%s (temporary)", RoleInfoModel:GetInstance():GetServerName(city.suid))
		else
			self.name.text = string.format("S%s", RoleInfoModel:GetInstance():GetServerName(city.suid))
		end
		if my_suid == city.suid then
			SetGray(self.city_img, false)
			local city_name = self:GetCityName(true)
			lua_resMgr:SetImageTexture(self,self.city_img, 'siegewar_image', city_name,true)
			if self.level == 2 then
				SetVisible(self.box, true)
			end
		else
			SetGray(self.city_img, true)
		end
	else
		self.name.text = "No exclusive"
		if self.level == 2 and self.model:IsCanAttackMCity(self.index) then
			local city_name = self:GetCityName()
			lua_resMgr:SetImageTexture(self,self.city_img, 'siegewar_image', city_name,true)
		elseif self.level == 3 and self.model:IsCanAttackBCity() then
			local city_name = self:GetCityName()
			lua_resMgr:SetImageTexture(self,self.city_img, 'siegewar_image', city_name,true)
		else
			SetGray(self.city_img, true)
		end
	end
	if city then
		if self.bosscount then
			self.bosscount.text = string.format("Boss Left %s", city.boss)
		end
		if self.state then
			SetVisible(self.state, true)
			if city.suid == my_suid then
				lua_resMgr:SetImageTexture(self,self.state, 'siegewar_image', 'occupy', true)
			else
				if city.score > 0 and (self.model:IsCanAttackMCity(self.index) or self.model:IsCanAttackBCity() )then
					lua_resMgr:SetImageTexture(self,self.state, 'siegewar_image', 'join', true)
				else
					SetVisible(self.state, false)
				end
			end
		end
	end
end

function SiegewarCityItem:GetCityName(is_occupy)
	local city_name = ""
	if is_occupy then
		if self.level == 1 then
			city_name = string.format("city%s", self.model.cityindex2img[self.index])
		elseif self.level == 2 then
			city_name = string.format("mcity%s", self.index)
		else
			city_name = string.format("bcity%s", self.index)
		end
	else
		if self.level == 1 then
			city_name = string.format("city%s_2", self.model.self.cityindex2img[self.index])
		elseif self.level == 2 then
			city_name = string.format("mcity%s_2", self.index)
		else
			city_name = string.format("bcity%s_2", self.index)
		end
	end
	return city_name
end

