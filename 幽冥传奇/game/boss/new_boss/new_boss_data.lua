NewBossData = NewBossData or BaseClass()

NewBossData.UPDATA_KILL_INFO = "updata_kill_info"
NewBossData.FLUSH_TYPE_BOSS = "flush_type_boss"

function NewBossData:__init()
	if NewBossData.Instance then
		ErrorLog("[NewBossData]:Attempt to create singleton twice!")
	end
	NewBossData.Instance = self
	self.map_info_list = nil

	self.boss_record = {}

	--keytest
	-- GlobalEventSystem:Bind(LayerEventType.KEYBOARD_RELEASED, function (key_code, event)
	-- 	if cc.KeyCode.KEY_T == key_code and event == cc.Handler.EVENT_KEYBOARD_PRESSED then
	-- 		GlobalEventSystem:Fire(OtherEventType.PASS_DAY)
	-- 	end
	-- end)

	self.boss_list = {}
	self.boss_type_list = {}

	GameObject.Extend(self):AddComponent(EventProtocol):ExportMethods()

end

function NewBossData:__delete()
	NewBossData.Instance = nil
end

local is_tequan_id = {
	[50] = 1,
	[51] = 2,
	[52] = 3,
}

function NewBossData:SetListenerEvent()
	EventProxy.New(RoleData.Instance, self):AddEventListener(RoleData.ROLE_ATTR_CHANGE, BindTool.Bind(self.RoleAttrChange, self))
	EventProxy.New(LunHuiData.Instance, self):AddEventListener(LunHuiData.LUNHUI_DATA_CHANGE, BindTool.Bind(self.BossStateChange, self))
	EventProxy.New(FubenData.Instance, self):AddEventListener(FubenData.BOSS_ENTER_TIMES, BindTool.Bind(self.BossStateChange, self))
	EventProxy.New(PrivilegeData.Instance, self):AddEventListener(PrivilegeData.TEQUAN_CHANGE, BindTool.Bind(self.TeQuanChange, self))
	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.CanEnterBossFuben, self), RemindName.PerBoss, true)
	GlobalEventSystem:Bind(OtherEventType.PASS_DAY, BindTool.Bind1(self.PassDayCallBack, self))
end

function NewBossData:PassDayCallBack()
	self:SetMapInfoList()
	self:BossStateChange()
end

function NewBossData:GetMapInfoList()
	if nil == self.map_info_list then 
		self:SetMapInfoList()
	end
	return self.map_info_list
end

function NewBossData:SetMapInfoList()
	self.map_info_list = {}
	local fuben_list = FubenData.Instance:GetFubenEnterInfo()

	local sort_idx = 1
	local function format_boss_data(v)
		v.index = sort_idx
		local enter_time = fuben_list[v.fubenId] and fuben_list[v.fubenId].enter_time or 0
		v.times = enter_time
		v.boss_level = v.needLevel
		v.boss_circle = v.circle
		v.vip_level = v.viplevel or 0
		-- v.boss_lunhui = v.lhlevel
		-- v.boss_lunhui = v.lhGrade or v.lhlevel
		v.is_tequan = nil ~= is_tequan_id[v.fubenId]
		local is_enough = BossData.BossIsEnoughAndTip(v)
		v.state = is_enough and (enter_time > 0 and 2 or 0) or 1

		sort_idx = sort_idx + 1
		return v
	end

	--加入特权boss
	for fubenId = 50, 52 do
		if PrivilegeData.Instance:IsTeQuan(is_tequan_id[fubenId]) then
			table.insert(self.map_info_list, format_boss_data(GameFubenCfg.fubenList[fubenId]))
		end
	end

	for i,v in ipairs(GameFubenCfg.fubenList) do
		if not is_tequan_id[v.fubenId] then
            if IS_AUDIT_VERSION and i > 19 then
                break
            else
			    table.insert(self.map_info_list, format_boss_data(v))
            end
		end
	end

	table.sort(self.map_info_list, function(a, b)
		if a.state ~= b.state then
			return a.state > b.state
		else
			return a.index < b.index
		end
	end)

	RemindManager.Instance:DoRemind(RemindName.PerBoss)
end

function NewBossData:CanEnterBossFuben()
	for k,v in pairs(self:GetMapInfoList()) do
		if v.state == 2 then
			return 1
		end
	end
	return 0
end

function NewBossData:TeQuanChange()
	self:SetMapInfoList()
end

function NewBossData:RoleAttrChange(vo)
	if vo.key == OBJ_ATTR.CREATURE_LEVEL or 
		vo.key == OBJ_ATTR.ACTOR_CIRCLE or
		vo.key == OBJ_ATTR.ACTOR_VIP_GRADE then 
		self:BossStateChange()
	end
end

function NewBossData:BossStateChange()
	if nil == self.map_info_list then 
		self:SetMapInfoList()
	else
		local fuben_list = FubenData.Instance:GetFubenEnterInfo()
		for k,v in pairs(self.map_info_list) do
			local is_enough = BossData.BossIsEnoughAndTip(v)
			local enter_time = fuben_list[v.fubenId] and fuben_list[v.fubenId].enter_time or 0
			v.state = is_enough and (enter_time > 0 and 2 or 0) or 1
		end
		table.sort(self.map_info_list, function(a, b)
			if a.state ~= b.state then
				return a.state > b.state
			else
				return a.index < b.index
			end
		end)
		RemindManager.Instance:DoRemind(RemindName.PerBoss)
	end
end

--  击杀记录
function NewBossData:GetBossInfo(protocol)
	self.boss_record = protocol
	self.boss_recast_list = nil
	self:DispatchEvent(NewBossData.UPDATA_KILL_INFO)
end

-- 获取全服记录
function NewBossData:GetBossRecastList()
	return self.boss_record
end

function NewBossData:GetBossTypeData(protocol)
	self.boss_type_list = protocol.boss_list

	-- self.boss_list = {}
	-- for k, v in pairs(self.boss_type_list) do
	-- 	local t = BossTypeCfg[v.boss_type].BossMapList[k]
	-- 	local vo = {
	-- 		name = t.name,
	-- 		npc_id = t.chuansong_id,
	-- 		limit_lv = self:LimitText(t.level),
	-- 		remind_num = v.boss_num
	-- 	}
	-- 	table.insert(self.boss_list, vo)
	-- end

	self:DispatchEvent(NewBossData.FLUSH_TYPE_BOSS)
end

--获取boss类型
function NewBossData:GetBossTabble()
	local data = {}
	for k, v in pairs(BossTypeCfg) do
		table.insert(data, v.name)
	end

	return data
end

-- boss类型数据
function NewBossData:BossTypeData(index)
	local data = {}
	for k, v in pairs(BossTypeCfg[index].BossMapList) do
		local vo = {
			map_name = v.name,
			npc_id = v.chuansong_id,
			limit_lv = self:LimitText(v.level),
			remind_num = self:GetBossInfoCfg(v.sceneId),
			is_allow = self:GetIsLevel(v),
		}
		table.insert(data, vo)
	end
	return data
end

-- 地图boss信息数据
function NewBossData:BossInfoData(index)
	local data = {}
	for k, v in pairs(CleintBossMapInfoCfg[index].InfoList) do
		local vo = {
			map_name = v.name,
			desc = v.desc,
			npc_id = v.chuansong_id,
			award = v.awards,
			is_allow = self:GetIsLevel(v),
		}
		table.insert(data, vo)
	end
	return data
end

-- 判断是否登记足够进入地图
function NewBossData:GetIsLevel(data)
	local remind = false
	local level = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
	local circle = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)
	local wing_level = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SWING_LEVEL)
	local fs_level = DeifyData.Instance:GetLevel()
	local xh_lv = HoroscopeData.Instance:GetSuitId()
	if data.xinhunlv > 0 then
		remind = xh_lv >= data.xinhunlv
	elseif data.fengshenglv > 0 then
		remind = fs_level >= data.fengshenglv
	elseif data.chibanglv > 0 then
		remind = wing_level >= data.chibanglv
	elseif data.level[1] then
		if circle >= data.level[1] and level >= data.level[2] then
			remind = true
		end
	end
	return remind
end

-- 显示等级显示
function NewBossData:LimitText(data)
	local txt = ""
	if data[1] == nil then
		txt = data
	else
		if data[1] == 0 then
			txt = string.format(Language.Tip.ZhuanDengJi3, data[2])
		else
			txt = string.format(Language.Tip.ZhuanDengJi2, data[1], data[2])
		end
	end
	return txt
end

-- 获取boss存活个数
function NewBossData:GetBossInfoCfg(scene_id)
	local boss_num = 0
	for k, v in pairs(self.boss_type_list) do
		if v.scene_id == scene_id then
			boss_num = v.boss_num	
		end
	end
	return boss_num
end

-- 稀有boss
function NewBossData:SetRareBossInfo(index)
	local boss_cfg = {}

	local list = ModBossConfig[index]
	local boss_list = BossData.Instance:GetSceneBossListByType(index)
	for k1, v1 in pairs(list) do
		local cur_boss_data = boss_list[v1.BossId]
		local open_server_days = OtherData.Instance:GetOpenServerDays()
		if open_server_days >= v1.opensvrday and cur_boss_data then
			local data = {}
			data.boss_id = cur_boss_data.boss_id
			data.scene_id = v1.SceneId
			data.boss_name = v1.BossName
			data.scene_name = v1.SceneName
			data.chuansongId = v1.chuansongId
			data.consumes = v1.consumes
			data.boss_level = v1.level
			data.bosslv = v1.bosslv
			data.boss_circle = v1.circle
			data.vip_level = v1.viplevel or 0
			data.boss_drop = v1.drops or {}
			data.boss_type = cur_boss_data.boss_type
			data.limit_time = v1.Time
			data.boss_zslv = v1.zslv
			data.refresh_time = cur_boss_data.refresh_time 
			data.now_time = cur_boss_data.now_time
			data.rindex = cur_boss_data.boss_id or 0
			data.monster_lv = cur_boss_data.monster_lv
			data.monster_circle = cur_boss_data.monster_circle
			data.monster_lunhui = cur_boss_data.monster_lunhui 
			local is_enough = BossData.BossIsEnoughAndTip(data)
			local is_rem = BossData.Instance:GetRemindFlag(cur_boss_data.boss_type, data.rindex or 0) == 0
			local state = is_rem and (is_enough and ((cur_boss_data.refresh_time - Status.NowTime + cur_boss_data.now_time) > 0 and 3 or 0) or 2) or 1
			data.boss_state = state  --0表示可以击杀1表示击杀2未开启
			table.insert(boss_cfg, data)
		end
	end

	self:SortList(boss_cfg)

	return boss_cfg
end
function NewBossData:SortList(list)
	table.sort(list,function (a,b)
		if a.boss_state ~= b.boss_state then
			return a.boss_state < b.boss_state
		else
			if a.bosslv ~= b.bosslv then
				return a.bosslv < b.bosslv
			else
				return a.boss_circle < b.boss_circle
			end
		end
	end)
end

-- 获取稀有boss是否有击杀
function NewBossData:GetRareBossKill()
	local data = self:GetBossListInfo()
	local index = 0
	for k, v in pairs(data) do
		if v.boss_state == 0 then
			index = index + 1
		end
	end
	return index
end