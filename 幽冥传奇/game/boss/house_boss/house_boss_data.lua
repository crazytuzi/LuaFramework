HouseBossData = HouseBossData or BaseClass()
function HouseBossData:__init()
	if HouseBossData.Instance then
		ErrorLog("[HouseBossData]:Attempt to create singleton twice!")
	end
	HouseBossData.Instance = self
	self.vip_tab_list = nil
	self.house_boss_list = nil
end

function HouseBossData:__delete()
	HouseBossData.Instance = nil
end

function HouseBossData:SetVipTabList()
	self.vip_tab_list = {}
	for i = 1, 4 do
		local data = {}
		data.index = i
		data.remind = true
		data.boss_list = {}
		self.vip_tab_list[i] = data
	end
end

function HouseBossData:SetListenerEvent()
	EventProxy.New(RoleData.Instance, self):AddEventListener(RoleData.ROLE_ATTR_CHANGE, BindTool.Bind(self.RoleAttrChange, self))
	EventProxy.New(BossData.Instance, self):AddEventListener(BossData.UPDATE_BOSS_DATA, BindTool.Bind(self.SetHouseBossList, self))
	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.CanEnterHouseBossNum, self), RemindName.HouseBoss, true)
end

function HouseBossData.IsVipCondMatch(vip_cond)
	return RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_VIP_GRADE) >= vip_cond
end

function HouseBossData:GetVipTabList()
	if nil == self.vip_tab_list then 
		self:SetVipTabList()
	end
	return self.vip_tab_list
end

function HouseBossData:SetHouseBossList()
	self.house_boss_list = {}
	self.house_boss_remind_list = {}
	local boss_list = BossData.Instance:GetSceneBossListByType(BossData.BossTypeEnum.HOUSE_BOSS)
	local list = BossZhiJiaCfg.conditions
	local lis_data = nil
	for k,v in pairs(boss_list) do
		lis_data = list[k]
		if lis_data then 
			local data = {}
			data.boss_id = lis_data.bossId
			data.scene_id = lis_data.sceneId
			data.boss_name = lis_data.BossName
			data.boss_level = lis_data.level
			data.boss_circle = lis_data.circle
			data.vip_level = lis_data.viplv or 0
			data.boss_lunhui = lis_data.lunhui
			data.boss_drop = lis_data.drops
			data.layer = lis_data.layer
			data.boss_type = v.boss_type
			data.refresh_time = v.refresh_time 
			data.limit_time = lis_data.Time
			data.now_time = v.now_time
			data.rindex = lis_data.index or 0
			data.monster_lv = v.monster_lv
			data.monster_circle = v.monster_circle
			data.monster_lunhui = v.monster_lunhui 
			local is_enough = BossData.BossIsEnoughAndTip(data)
			data.boss_state = is_enough and (v.refresh_time > 0 and 1 or 0) or 2
			if nil == self.house_boss_list[data.layer] then 
				self.house_boss_list[data.layer] = {}
			end
			table.insert(self.house_boss_list[data.layer], data)

			if nil == self.house_boss_remind_list[data.layer] then 
				self.house_boss_remind_list[data.layer] = {}
			end
			table.insert(self.house_boss_remind_list[data.layer], data)
		end
	end
	RemindManager.Instance:DoRemind(RemindName.WildBoss)
end

function HouseBossData:GetHouseBossList(index)
	if nil == self.house_boss_list or nil == self.house_boss_list[index] then 
		self:SetHouseBossList()
	end
	if self.house_boss_list[index] then
		table.sort(self.house_boss_list[index], function (a, b)
			if a.boss_state ~= b.boss_state then
				return a.boss_state < b.boss_state
			else
				return a.boss_id > b.boss_id
			end
		end)
		return self.house_boss_list[index]
	end
	return {}
end

function HouseBossData:GetHouseBossRemindList(index)

	if nil == self.house_boss_remind_list or nil == self.house_boss_remind_list[index] then 
		self:SetHouseBossList()
	end
	if self.house_boss_remind_list[index] then
		table.sort(self.house_boss_remind_list[index], function (a, b)
			return a.boss_id < b.boss_id
		end)
		return self.house_boss_remind_list[index]
	end
	return {}
end

function HouseBossData:CanEnterHouseBossNum()
	if nil == self.house_boss_list then 
		self:SetHouseBossList()
	end
	for k,v in pairs(self.house_boss_list) do
		for k_1,v_1 in pairs(v) do
			if v_1.boss_state == 0 then
				return 1
			end
		end
	end
	return 0
end

function HouseBossData:RoleAttrChange(vo)
	if vo.key == OBJ_ATTR.ACTOR_VIP_GRADE then 
		self:BossStateChange()
	end
end

function HouseBossData:BossStateChange()
	if nil == self.house_boss_list then 
		self:SetPersonalBossList()
	else
		for i,v in ipairs(self.house_boss_list) do
			for k,v_1 in pairs(v) do
				local is_enough = BossData.BossIsEnoughAndTip(v_1)
				v_1.boss_state = is_enough and (v_1.refresh_time > 0 and 1 or 0) or 2
			end
			table.sort(v, function(a, b)
				if a.boss_state ~= b.boss_state then
					return a.boss_state > b.boss_state
				else
					return a.boss_id < b.boss_id
				end
			end)
		end
		RemindManager.Instance:DoRemind(RemindName.WildBoss)
	end
end
