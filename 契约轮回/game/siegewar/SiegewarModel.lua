SiegewarModel = SiegewarModel or class("SiegewarModel",BaseModel)
local SiegewarModel = SiegewarModel

function SiegewarModel:ctor()
	SiegewarModel.Instance = self
	self:Reset()
end

function SiegewarModel:Reset()
	self.medal = 0
	self.cities = {}
	self.city_array = {}
	self.bosses = {}
	self.select_boss = 0         --选中bossid
	self.fetch = {}
	self.enemies = {}
	self.rule = 0
	self.targetPos = nil
	self.cityindex2line = {
		[1] = {1, 5},
		[2] = {2, 6},
		[3] = {7, 9},
		[4] = {8, 10},
		[5] = {11, 13},
		[6] = {12, 14},
		[7] = {15, 3},
		[8] = {4, 16},
	}
	self.mcityindex2line = {
		[1] = {17},
		[2] = {18},
		[3] = {19},
		[4] = {20},
	}
	self.cityindex2mcity = {
		[1] = {
			[1] = {1, 2},
			[2] = {1, 2},
		},
		[2] = {
			[1] = {1, 2},
			[2] = {1, 2},
			[3] = {1, 2},
			[4] = {1, 2},
		},
		[3] = {
			[1] = {1, 2},
			[2] = {1, 2},
			[3] = {2, 3},
			[4] = {2, 3},
			[5] = {3, 4},
			[6] = {3, 4},
			[7] = {1, 4},
			[8] = {1, 4},
		},
	}
	self.cityindex2img = {
		[1] = 1,
		[2] = 1,
		[3] = 1,
		[4] = 1,
		[5] = 1,
		[6] = 1,
		[7] = 1,
		[8] = 1,
	}
end

function SiegewarModel.GetInstance()
	if SiegewarModel.Instance == nil then
		SiegewarModel()
	end
	return SiegewarModel.Instance
end

function SiegewarModel:SetCities(cities)
	local city_by_level = {}
	for i=1, #cities do
		local city = cities[i]
		self.cities[city.scene] = city
		city_by_level[city.level] = city_by_level[city.level] or {}
		city_by_level[city.level][city.scene] = city
	end
	self.city_array = {}
	for level, allcity in pairs(city_by_level) do
		for _, city in pairs(allcity) do
			self.city_array[level] = self.city_array[level] or {}
			table.insert(self.city_array[level], city)
		end
		local function sort_fun(a, b)
			return a.scene < b.scene
		end
		table.sort(self.city_array[level], sort_fun)
	end
end

function SiegewarModel:UpdateCityIndex(link)
	if self.rule > 0 then
		local index = self:GetMyCityIndex(1)[1]
		if not index then
			return
		end
		local mcity_index = self.cityindex2mcity[self.rule][index]
		local mcities = self.city_array[2]

		local old_index = {}
		for i=1, #link do 
			for m=1, #mcities do
				if mcities[m].scene == link[i] then
					table.insert(old_index, m)
				end
			end
		end

		for i=1, #old_index do
			local old_city = self.city_array[2][old_index[i]]
			local old_city2 = self.city_array[2][mcity_index[i]]
			self.city_array[2][mcity_index[i]] = old_city
			self.city_array[2][old_index[i]] = old_city2
		end
	end
end

function SiegewarModel:GetCityByIndex(level, index)
	return self.city_array[level][index]
end

function SiegewarModel:GetMyCityIndex(level)
	local mysuid = RoleInfoModel:GetInstance():GetRoleValue("suid")
	local arr_city = self.city_array[level]
	local result = {}
	for i=1, #arr_city do
		if arr_city[i].suid == mysuid then
			table.insert(result, i)
		end
	end
	return result
end

function SiegewarModel:GetCityIndex(level, scene)
	local arr_city = self.city_array[level]
	for i=1, #arr_city do
		if arr_city[i].scene == scene then
			return i
		end
	end
end

function SiegewarModel:SetRule(rule)
	self.rule = rule
end

function SiegewarModel:SetMedal(medal)
	self.medal = medal
end

function SiegewarModel:SetBosses(scene, bosses)
	self.bosses[scene] = self.bosses[scene] or {}
	self.bosses[scene] = bosses
end

function SiegewarModel:UpdateBoss(data)
	for _, arr_boss in pairs(self.bosses) do
		for i=1, #arr_boss do
			if arr_boss[i].id == data.id then
				arr_boss[i].born = data.born
			end
		end
	end
end

function SiegewarModel:GetBosses(scene)
	local bosses = {}
	local arr_boss = self.bosses[scene] or {}
	for i=1, #arr_boss do
		local boss = {}
		local bosscfg = Config.db_siegewar_boss[arr_boss[i].id]
		boss.info = arr_boss[i]
		boss.cfg = bosscfg
		bosses[#bosses+1] = boss
	end
	local function sort_func(a, b)
		return a.cfg.order < b.cfg.order
	end
	table.sort(bosses, sort_func)
	return bosses
end

function SiegewarModel:GetMedalRewards()
	local worldlevel = RoleInfoModel:GetInstance().world_level
	local rewards = {}
	for _, v in pairs(Config.db_siegewar_medal_reward) do
		if worldlevel>=v.worldlv_min and worldlevel <= v.worldlv_max then
			table.insert(rewards, v)
		end
	end
	local function sort_func(a, b)
		return a.id < b.id
	end
	table.sort(rewards, sort_func )
	return rewards, rewards[#rewards].id
end

function SiegewarModel:GetBossOrder()
	local worldlevel = RoleInfoModel:GetInstance().world_level
	for _, v in pairs(Config.db_siegewar_order_show) do
		if worldlevel>=v.worldlv_min and worldlevel<=v.worldlv_max then
			return v.show
		end
	end
	return 0
end

function SiegewarModel:GetTired()
	local main_role_data = RoleInfoModel:GetInstance():GetMainRoleData()
	local use_count = 0
	local max_count = 8
	if main_role_data then
		local buffer = main_role_data:GetBuffByID(enum.BUFF_ID.BUFF_ID_SIEGEBOSS_KILL_TIRED)
		use_count = (buffer and buffer.value or 0)
	end
	return max_count-use_count, max_count
end

function SiegewarModel:IsHaveRedDot()
	local left_count = self:GetTired()
	local flag = false
	if self.medal > 0 and not table.containValue(self.fetch, self.medal) then
		falg = true 
	end
	return left_count > 0 or flag
end

function SiegewarModel:SetFetch(fetch)
	self.fetch = fetch
end

function SiegewarModel:SetEnemies(enemies)
	self.enemies = enemies
end

function SiegewarModel:IsEnemy(suid)
	return self.enemies[suid]
end

function SiegewarModel:GetEnemies()
	local result = {}
	local mysuid = RoleInfoModel:GetInstance():GetRoleValue("suid")
	for suid, is_enemy in pairs(self.enemies) do
		if suid ~= mysuid then
			local item = {}
			item.suid = suid
			item.is_enemy = is_enemy
			table.insert(result, item)
		end
	end
	local function sort_func(a, b)
		return a.suid < b.suid
	end
	table.sort(result, sort_func)
	return result
end

function SiegewarModel:UpdateEnemy(data)
	if data.type == 1 then
		self.enemies[data.suid] = true
	else
		self.enemies[data.suid] = false
	end
end

function SiegewarModel:CityIndex2Lines(level, index)
	if level == 1 then
		return self.cityindex2line[index]
	elseif level == 2 then
		return self.mcityindex2line[index]
	end
end


--是否可以攻击中级城市
function SiegewarModel:IsCanAttackMCity(index)
	local myindexes = self:GetMyCityIndex(1)
	for _, myindex in pairs(myindexes) do
		local indexes = self.cityindex2mcity[self.rule][myindex]
		if table.containValue(indexes, index) then
			return true
		end
	end
	return false
end

function SiegewarModel:IsCanAttackBCity()
	local mysuid = RoleInfoModel:GetInstance():GetRoleValue("suid")
	local arr_city = self.city_array[2]
	for i=1, #arr_city do
		if arr_city[i].suid == mysuid then
			return true
		end
	end
	return false
end

function SiegewarModel:SetTargetPos(x, y)
	self.targetPos = {x=x, y=y}
end