-- --------------------------------
-- 场景活动单位存活状态集中处理
-- hosr
-- --------------------------------
UnitStateManager = UnitStateManager or BaseClass(BaseManager)

function UnitStateManager:__init()
	if UnitStateManager.Instance then
		return
	end
	UnitStateManager.Instance = self

	self.model = UnitStateModel.New()

    self.OnDataUpdate = EventLib.New() -- 数据更新

	self.isShow = false
	self.hasStar = false
	self.hasBoss = false
	self.hasRobber = false
	self.hasFox = false

	self.starList = {}
	self.bossList = {}
	self.robberList = {}
	self.coldList = {}
	self.starTrialList = {}
	self.moonStarList = {}

	self.mapTab = {}
	self.foxmapTab = {}

	self.internalRefresh = 0

	self.listener = function() self:MainuiLoaded() end
	self.fightListener = function() self:UpdateFight() end
	self.levelUp = function() self:OnLevelUp() end
	EventMgr.Instance:AddListener(event_name.mainui_notice_init, self.listener)
end

function UnitStateManager:MainuiLoaded()
	EventMgr.Instance:AddListener(event_name.scene_load, self.levelUp)
	EventMgr.Instance:RemoveListener(event_name.mainui_notice_init, self.listener)
	EventMgr.Instance:AddListener(event_name.role_level_change, self.levelUp)
	self:ShowIcon()
end

function UnitStateManager:OnLevelUp()
	self:CheckShow()
	self:ShowIcon()
end

function UnitStateManager:Update(type, data)
	-- BaseUtils.dump(data, "======================== 场景活动单位存活状态集中处理 ======================== ")

	if type == UnitStateEumn.Type.Star then
		self.mapTab = {}
		local all = 0
		for i,v in ipairs(data.map_num) do
			-- all = all + v.num
			self.mapTab[v.map_id] = {num = v.num}
		end

		local temp = {}
		for i,v in ipairs(data.constellation_unit) do
			local map = self.mapTab[v.map_id]
			if temp[v.map_id] == nil then
				temp[v.map_id] = {}
			end
			table.insert(temp[v.map_id], v)
			all = all + 1
		end

		for mapid,v in pairs(temp) do
			if self.mapTab[mapid] ~= nil then
				self.mapTab[mapid].stars = BaseUtils.copytab(v)
			end
		end
		temp = nil

		if all > 0 then
			self.hasStar = true
		else
			self.hasStar = false
		end
	elseif type == UnitStateEumn.Type.Boss then
		self.bossList = {}
		self.hasBoss = false
		if WorldBossManager.Instance.model.world_boss_data ~= nil then
			for i,v in ipairs(WorldBossManager.Instance.model.world_boss_data.boss_list) do
				local cfg_data = DataBoss.data_base[v.id]
				if cfg_data ~= nil then
					local fresh_left_time = (v.last_killed + cfg_data.refresh_time) - BaseUtils.BASE_TIME
					local dat = {}
					dat.id = v.id
					dat.last_killed = v.last_killed
					dat.map_id = v.map_id
					dat.x = v.x
					dat.y = v.y
					dat.lev = cfg_data.lev
					dat.type = UnitStateEumn.Type.Boss
					table.insert(self.bossList, dat)
					if fresh_left_time <= 0 then
						self.hasBoss = true
					end
				end
			end
			table.sort(self.bossList, function(a, b) return a.lev < b.lev end)
			local temp = {}
			local match = nil
			for i,v in ipairs(self.bossList) do
				if match == nil then
					match = v
				else
					if v.lev <= RoleManager.Instance.RoleData.lev and (v.lev < 95 or RoleManager.Instance.RoleData.lev_break_times > 0) then
						match = v
					end
				end
			end
			self.bossList = {match}
			if match ~= nil then
				local matchboss_status = WorldBossManager.Instance.myBossData[match.id]
				if matchboss_status ~= nil then
					self.hasBoss = matchboss_status.is_kill ~= 1 and matchboss_status.is_live ~= 0
					if matchboss_status.is_kill ~= 1 and matchboss_status.is_live ~= 0 then
						self.hasBoss = true
					else
						self.bossList = {}
						self.hasBoss = false
					end
				else
					self.hasBoss = false
				end
			else
				self.hasBoss = false
			end
		end
	elseif type == UnitStateEumn.Type.Robber then
		if data.left_num > 0 then
			data.type = UnitStateEumn.Type.Robber
			self.robberList = {data}
			self.hasRobber = true
		else
			self.robberList = {}
			self.hasRobber = false
		end
	elseif type == UnitStateEumn.Type.Fox then
		self.foxmapTab = {}
		local all = 0
		for i,v in ipairs(data.map_num) do
			-- all = all + v.num
			self.foxmapTab[v.map_id] = {num = v.num}
		end

		local temp = {}
		for i,v in ipairs(data.camp_unit) do
			local map = self.foxmapTab[v.map_id]
			if temp[v.map_id] == nil then
				temp[v.map_id] = {}
			end
			table.insert(temp[v.map_id], v)
			all = all + 1
		end

		for mapid,v in pairs(temp) do
			if self.foxmapTab[mapid] ~= nil then
				self.foxmapTab[mapid].camp_unit = BaseUtils.copytab(v)
			end
		end
		temp = nil
		if all > 0 then
			self.hasFox = true
		else
			self.hasFox = false
		end
	elseif type == UnitStateEumn.Type.Cold then
		self.coldList = data
		self.showCold = #data > 0
	elseif type == UnitStateEumn.Type.StarTrial then
		self.starTrialList = data
		self.showStarTrial = #data > 0
	elseif type == UnitStateEumn.Type.MoonStar then
		self.moonStarList = data
		self.showMoonStar = #data > 0
	end

	self:CheckShow()

	self:ShowIcon()

	self.OnDataUpdate:Fire()
end

function UnitStateManager:CheckShow()
	local roleLev = RoleManager.Instance.RoleData.lev
	local canBoss = (DataAgenda.data_list[1007].engaged ~= nil and DataAgenda.data_list[1007].engaged < 2) and roleLev >= 40
	local canStar = (DataAgenda.data_list[2013].engaged ~= nil and DataAgenda.data_list[2013].engaged < 3) and roleLev >= 40
	local canFox = (DataAgenda.data_list[2051].engaged ~= nil and DataAgenda.data_list[2051].engaged < 3) and roleLev >= 40
	local canStarTrial = RoleManager.Instance.world_lev >= 60 and roleLev >= 60
	local canMoonStar = RoleManager.Instance.world_lev >= 80 and roleLev >= 80
	self.isShow = (canStar and self.hasStar) or (canBoss and self.hasBoss) or (self.hasRobber and roleLev >= 30) or (self.hasFox and canFox) or (self.showCold == true) or (canStarTrial and self.showStarTrial) or (canMoonStar and self.showMoonStar) 
	GuildfightManager.Instance.model:CheckTeamVisible()
end

function UnitStateManager:ShowIcon()
	if MainUIManager.Instance.noticeView == nil then
		return
	end

	if RoleManager.Instance.RoleData.lev < 30 then
		MainUIManager.Instance.noticeView:ShowActiceNoticeIcon(false)
		return
	end

	if self.isShow then
		EventMgr.Instance:RemoveListener(event_name.begin_fight, self.fightListener)
		EventMgr.Instance:RemoveListener(event_name.end_fight, self.fightListener)
		EventMgr.Instance:AddListener(event_name.begin_fight, self.fightListener)
		EventMgr.Instance:AddListener(event_name.end_fight, self.fightListener)
	else
		EventMgr.Instance:RemoveListener(event_name.begin_fight, self.fightListener)
		EventMgr.Instance:RemoveListener(event_name.end_fight, self.fightListener)
	end
	MainUIManager.Instance.noticeView:ShowActiceNoticeIcon(self.isShow)
end

function UnitStateManager:Layout(hasHead)
	self.model:Layout(hasHead)
end

function UnitStateManager:GetStarList()
	local list = {}
	for k,v in pairs(self.mapTab) do
		v.mapid = k
		v.type = UnitStateEumn.Type.Star
		if v.stars ~= nil and #v.stars > 0 then
			table.insert(list, v)
		end
	end
	table.sort(list, function(a,b) return a.mapid < b.mapid end)
	return list
end

function UnitStateManager:GetBossList()
	local list = {}
	local role_lev = RoleManager.Instance.RoleData.lev
	for i,v in ipairs(self.bossList) do
		if role_lev >= v.lev then
			table.insert(list, v)
		end
	end
	table.sort(list, function(a,b) return a.id > b.id end)
	return list
end

function UnitStateManager:GetRobberList()
	return self.robberList
end

function UnitStateManager:GetColdList()
	return self.coldList
end

function UnitStateManager:GetStarTrialList()
	return self.starTrialList
end

function UnitStateManager:GetMoonStarList()
	return self.moonStarList
end

function UnitStateManager:GetFoxList()
	local list = {}
	for k,v in pairs(self.foxmapTab) do
		v.mapid = k
		v.type = UnitStateEumn.Type.Fox
		if v.camp_unit ~= nil and #v.camp_unit > 0 then
			table.insert(list, v)
		end
	end
	table.sort(list, function(a,b) return a.mapid < b.mapid end)
	return list
end

function UnitStateManager:UpdateFight()
	if CombatManager.Instance.isFighting then
		MainUIManager.Instance.noticeView:ShowActiceNoticeIcon(false)
	else
		MainUIManager.Instance.noticeView:ShowActiceNoticeIcon(self.isShow)
	end
end

function UnitStateManager:CheckBossCanFight(id)
	return true
end

