SecretBossData = SecretBossData or BaseClass()

SecretBossData.UPDATA_SECRET_DATA = "updata_secret_data"

SecretBossData.BOSS_ENTER_LIMIT = {{min = 0, max = 2},{min = 3, max = 4},{min = 5, max = 6},{min = 7, max = 8},{min = 9, max = 10},{min = 11, max = 15},}

function SecretBossData:__init()
	if SecretBossData.Instance then
		ErrorLog("[SecretBossData]:Attempt to create singleton twice!")
	end
	SecretBossData.Instance = self
	self.secret_boss_list = nil
	self.attribution_list = nil
	
	self.secret_data = {consume = 3508, max_times = SecretRealmBossCfg.freeTms, can_buy = SecretRealmBossCfg.daysbuyTms, enter_times = 0, buy_times = 0}

	GameObject.Extend(self):AddComponent(EventProtocol):ExportMethods()
end

function SecretBossData:__delete()
	SecretBossData.Instance = nil
end

function SecretBossData:SetListenerEvent()
	EventProxy.New(RoleData.Instance, self):AddEventListener(RoleData.ROLE_ATTR_CHANGE, BindTool.Bind(self.RoleAttrChange, self))
	EventProxy.New(LunHuiData.Instance, self):AddEventListener(LunHuiData.LUNHUI_DATA_CHANGE, BindTool.Bind(self.BossStateChange, self))
	EventProxy.New(BossData.Instance, self):AddEventListener(BossData.UPDATE_BOSS_DATA, BindTool.Bind(self.SetSecretBossList, self))
	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.CanEnterSecretBossNum, self), RemindName.SecretBoss, true)
end

function SecretBossData:GetSecretInfo(protocol)
	self.secret_data.type = protocol.type
	self.secret_data.enter_times = protocol.enter_times
	self.secret_data.buy_times = protocol.buy_times
	self.attribution_list = protocol.attribution_list
	self:DispatchEvent(SecretBossData.UPDATA_SECRET_DATA)
end

function SecretBossData:GetSecretData()
	return self.secret_data
end

function SecretBossData:GetAttributionName(id)
	if self.attribution_list then 
		for k,v in pairs(self.attribution_list) do
			if v.boss_id == id then 
				return v.role_name
			end
		end
	end
	return nil
end

function SecretBossData:SetSecretBossList()
	local list = BossData.Instance:GetSceneBossListByType(BossData.BossTypeEnum.SECRET_BOSS)   
	local boss_list = SecretRealmBossCfg.conditions
	self.secret_boss_list = {}
	local lis_data = nil
	for k,v in pairs(list) do
		lis_data = boss_list[k]
		if lis_data and self:IsCircleEnough(lis_data) then 
			local data = {}
			data.index = k
			data.boss_id = lis_data.bossIds
			data.scene_id = lis_data.sceneId
			data.boss_name = lis_data.BossName
			data.boss_level = lis_data.level
			data.boss_circle = lis_data.circle
			data.vip_level = lis_data.viplevel or 0
			data.boss_lunhui = lis_data.lunhui
			data.boss_drop = lis_data.drops
			data.boss_type = v.boss_type
			data.refresh_time = v.refresh_time 
			data.now_time = v.now_time 
			data.boss_type = v.boss_type
			data.rindex = lis_data.index or 0
			data.monster_lv = v.monster_lv
			data.monster_circle = v.monster_circle
			data.monster_lunhui = v.monster_lunhui
			local is_enough = BossData.BossIsEnoughAndTip(data)
			data.boss_state = is_enough and (v.refresh_time > 0 and 1 or 0) or 2
			table.insert(self.secret_boss_list, data)
		end
	end

	table.sort(self.secret_boss_list, function (a, b)
		if a.boss_state ~= b.boss_state then
			return a.boss_state < b.boss_state
		end
	end)
	RemindManager.Instance:DoRemind(RemindName.WildBoss)
end

function SecretBossData:SetRemindBossDataList()
	self.secret_boss_remind_data = {}
	self.boss_remind_info = {}
	local boss_list = SecretRealmBossCfg.conditions
	for k,v in pairs(boss_list) do
		if self:IsRemindDataCircleEnough(v) then
			local data = {	monster_lv = 0,
							monster_circle = 0,
							monster_lunhui = 0,
						}
			local cfg = BossData.GetMosterCfg(v.bossIds)
			if cfg then
				data.monster_lv = cfg.level
				data.monster_circle = cfg.circle
				data.monster_lunhui = cfg.lunhui
			end
			data.boss_id = v.bossIds
			data.scene_id = v.sceneId
			data.boss_name = v.BossName
			data.boss_level = v.level
			data.boss_circle = v.circle
			data.vip_level = v.viplevel or 0
			data.boss_lunhui = v.lunhui
			data.boss_drop = v.drops
			data.boss_type = BossData.BossTypeEnum.SECRET_BOSS
			data.rindex = v.index or 0
			table.insert(self.secret_boss_remind_data, data)
			table.insert(self.boss_remind_info, data)
		end 		
	end
	table.sort(self.secret_boss_remind_data, function (a, b)
			return a.monster_circle < b.monster_circle
	end)
	table.sort(self.boss_remind_info, function (a, b)
			return a.boss_id < b.boss_id
	end)
end

function SecretBossData:GetSecretBossList()
	if nil == self.secret_boss_list then                                                                                                                                  
		self:SetSecretBossList()
	end
	return self.secret_boss_list
end

function SecretBossData:GetSecretBossRemindInfo()
	if nil == self.boss_remind_info then
		self:SetBossListInfo()
	end
	return self.boss_remind_info
end

function SecretBossData:GetSecretBossRemindList()
	if nil == self.secret_boss_remind_data then                                                                                                                                  
		self:SetSecretBossList()
	end
	return self.secret_boss_remind_data
end

function SecretBossData:IsCircleEnough(data)
	local circle = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)
	local index = 1 
	for k,v in pairs(SecretBossData.BOSS_ENTER_LIMIT) do
		if circle <= v.max and circle >= v.min then 
			index = k
			break
		end
	end
	local limit_list = SecretBossData.BOSS_ENTER_LIMIT[index]
	if limit_list and data.circle >= limit_list.min and data.circle <= limit_list.max then 
		return true
	end
	return false
end

function SecretBossData:IsRemindDataCircleEnough(data)
	local circle = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)
	local index = 1 
	for k,v in pairs(SecretBossData.BOSS_ENTER_LIMIT) do
		if circle <= v.max and circle >= v.min then 
			index = k
		end
	end
	local limit_list = SecretBossData.BOSS_ENTER_LIMIT[index]
	if limit_list and data.circle >= limit_list.min then 
		return true
	end
	return false
end

function SecretBossData:CanEnterSecretBossNum()
	local consume = BagData.Instance:GetItemNumInBagById(self.secret_data.consume)
	for k,v in pairs(self:GetSecretBossList()) do
		if v.boss_state == 0 then 
			if consume > 0 or self.secret_data.enter_times > 0 then 
				return 1
			end
		end
	end
	return 0
end

function SecretBossData:RoleAttrChange(vo)
	if vo.key == OBJ_ATTR.ACTOR_CIRCLE then 
		self:SetSecretBossList()
		self:SetRemindBossDataList()
	end
end

function SecretBossData:BossStateChange()
	self:SetSecretBossList()
end