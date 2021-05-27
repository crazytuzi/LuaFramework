WildBossData = WildBossData or BaseClass()

WildBossData.UPDATE_ROLE_DATA = "update_role_data"

function WildBossData:__init()
	if WildBossData.Instance then
		ErrorLog("[WildBossData]:Attempt to create singleton twice!")
	end
	WildBossData.Instance = self
	self.challenge_info = {total_count = WildBossCfg.freeTms, consume_id = 3507, enter_times = 0, cd_time = 0}

	GameObject.Extend(self):AddComponent(EventProtocol):ExportMethods()
end

function WildBossData:__delete()
	WildBossData.Instance = nil
end

function WildBossData:SetListenerEvent()
	EventProxy.New(RoleData.Instance, self):AddEventListener(RoleData.ROLE_ATTR_CHANGE, BindTool.Bind(self.RoleAttrChange, self))
	EventProxy.New(LunHuiData.Instance, self):AddEventListener(LunHuiData.LUNHUI_DATA_CHANGE, BindTool.Bind(self.BossStateChange, self))
	EventProxy.New(BossData.Instance, self):AddEventListener(BossData.UPDATE_BOSS_DATA, BindTool.Bind(self.SetBossListInfo, self))
	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.CanEnterWildBossNum, self), RemindName.WildBoss, true)
end

function WildBossData:SortList(list)
	-- table.sort(list, function (a, b)
	-- 	if a.boss_state ~= b.boss_state then
	-- 		return a.boss_state < b.boss_state
	-- 	end
	-- 	if 0 == a.boss_state then 
	-- 		if a.boss_lunhui ~= b.boss_lunhui then
	-- 			return a.boss_lunhui > b.boss_lunhui
	-- 		elseif a.boss_circle ~= b.boss_circle then
	-- 			return a.boss_circle > b.boss_circle
	-- 		else
	-- 			return a.boss_level > b.boss_level
	-- 		end
	-- 	else
	-- 		if a.boss_circle ~= b.boss_circle then
	-- 			if a.boss_lunhui ~= b.boss_lunhui then 
	-- 				return a.boss_lunhui < b.boss_lunhui
	-- 			else 
	-- 				return a.boss_circle < b.boss_circle and a.boss_circle ~= 0 or b.boss_circle == 0
	-- 			end
	-- 		elseif a.boss_level ~= b.boss_level then
	-- 			return a.boss_level < b.boss_level
	-- 		elseif a.boss_lunhui ~= b.boss_lunhui then
	-- 			return a.boss_lunhui < b.boss_lunhui
	-- 		end
	-- 	end
	-- end)
	table.sort(list,function (a,b)
		if a.boss_state ~= b.boss_state then
			return a.boss_state < b.boss_state
		else
			-- if a.boss_lunhui~=b.boss_lunhui then
			-- 	return a.boss_lunhui < b.boss_lunhui
			-- else
				if a.boss_circle~=b.boss_circle then
					return a.boss_circle < b.boss_circle
				else
					if a.boss_level~= b.boss_level then
						return a.boss_level < b.boss_level
					else
						return false
					end
				end
			-- end
		end
	end)
end

function WildBossData:SetBossListInfo()
	self.boss_list_info = {}
	self.boss_remind_info = {}
	local list = WildBossCfg.conditions
	local boss_list = BossData.Instance:GetSceneBossListByType(BossData.BossTypeEnum.WILD_BOSS)
	local lis_data = nil
	for k,v in pairs(boss_list) do
		lis_data = list[k]
		if lis_data then 
			local data = {}
			data.boss_id = v.boss_id
			data.scene_id = lis_data.sceneId
			data.boss_name = lis_data.BossName
			data.boss_level = lis_data.level
			data.boss_circle = lis_data.circle
			data.vip_level = lis_data.viplevel or 0
			-- data.boss_lunhui = lis_data.lhGrade or lis_data.lunhui
			data.boss_drop = lis_data.drops
			data.boss_type = v.boss_type
			data.limit_time = lis_data.Time
			data.refresh_time = v.refresh_time 
			data.now_time = v.now_time
			data.rindex = lis_data.index or 0
			data.monster_lv = v.monster_lv
			data.monster_circle = v.monster_circle
			data.monster_lunhui = v.monster_lunhui 
			local is_enough = BossData.BossIsEnoughAndTip(data)
			data.boss_state = is_enough and (v.refresh_time > 0 and 1 or 0) or 2  --1表示击杀0表示可以击杀2未开启
			table.insert(self.boss_list_info, data)
			table.insert(self.boss_remind_info, data)
		end
	end
	self:SortList(self.boss_list_info)

	RemindManager.Instance:DoRemind(RemindName.WildBoss)
end

function WildBossData:GetBossListInfo()
	if nil == self.boss_list_info then
		self:SetBossListInfo()
	end
	return self.boss_list_info
end

function WildBossData:GetBossRemindInfo()
	if nil == self.boss_remind_info then
		self:SetBossListInfo()
	end
	return self.boss_remind_info
end


function WildBossData:GetChallengeInfo()
	local vip_lv = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_VIP_GRADE)

	--特权
	local get_tequan_num = function ()
		local num = 0
		for i = 1, 3 do
			if PrivilegeData.Instance:IsTeQuan(i) then
				num = num + PrivilegeCardCfg.Pros[i].dayAddWildBossTms or 0
			end
		end
		return num
	end

	if vip_lv > 0 then 
		self.challenge_info.total_count = VipConfig.VipAddWildBossTms[vip_lv] + WildBossCfg.freeTms + get_tequan_num()
	end
	return self.challenge_info
end

function WildBossData:RoleAttrChange(vo)
	if vo.key == OBJ_ATTR.CREATURE_LEVEL or 
		vo.key == OBJ_ATTR.ACTOR_CIRCLE then 
		self:BossStateChange()
	end
end

function WildBossData:BossStateChange()
	if nil == self.boss_list_info then 
		self:SetBossListInfo()
	else
		for k,v in pairs(self.boss_list_info) do
			local is_enough = BossData.BossIsEnoughAndTip(v)
			v.boss_state = is_enough and (v.refresh_time > 0 and 1 or 0) or 2
		end
		self:SortList(self.boss_list_info)
		RemindManager.Instance:DoRemind(RemindName.WildBoss)
	end
end

function WildBossData:CanEnterWildBossNum()
	-- local consume = BagData.Instance:GetItemNumInBagById(self.challenge_info.consume_id)
	-- for k,v in pairs(self:GetBossListInfo()) do
	-- 	if v.boss_state == 0 then 
	-- 		if consume > 0 or self.challenge_info.total_count > self.challenge_info.enter_times then 
	-- 			return 1
	-- 		end
	-- 	end
	-- end
	-- return 0
end

function WildBossData:SetWildBossOwnInfo(protocol)
	self.challenge_info.enter_times = protocol.times
	self.challenge_info.cd_time = protocol.cd_time
	self:DispatchEvent(WildBossData.UPDATE_ROLE_DATA)
end

function WildBossData:GetChallengeTimes()
	return 
end