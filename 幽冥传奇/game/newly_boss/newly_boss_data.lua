NewlyBossData = NewlyBossData or BaseClass()

NewlyBossData.NEWLY_BOSS_REMIND = "newboss_boss_remind"
NewlyBossData.TUMO_ADD_TIME = "tumo_add_time"

NewlyBossData.RX_BOSS_STATE_CHANGE = "rx_boss_state_change"
NewlyBossData.RX_BOSS_RANK_LIST_CHANGE = "rx_boss_rank_list_change"
NewlyBossData.RX_BOSS_SELF_RANK_CHANGE = "rx_boss_self_rank_change"

function NewlyBossData:__init()
	if NewlyBossData.Instance then
		ErrorLog("[NewlyBossData] attempt to create singleton twice!")
		return
	end
	NewlyBossData.Instance = self

	GameObject.Extend(self):AddComponent(EventProtocol):ExportMethods()

	self.add_time = 0

	-- 绑定红点提示触发条件
	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindIndex), RemindName.WildBossKill, true) 			-- 野外BOSS 		
	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindIndex), RemindName.CircleBossKill, true)  		-- 转生BOSS
	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindIndex), RemindName.VipBossKill, true) 			-- 会员BOSS 		
	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindIndex), RemindName.XinghunBossKill, true)  		-- 星魂BOSS
	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindIndex), RemindName.MjingBossKill, true)  		-- 秘境BOSS
	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindIndex), RemindName.ReXueBossKill, true)  		-- 热血BOSS
	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindIndex), RemindName.MoyuBossKill, true) 			-- 圣殿BOSS
	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindIndex), RemindName.ShenWeiKill, true) 			-- 神威BOSS
end

function NewlyBossData:__delete()
end

-- 获取提醒显示索引 0不显示红点, 1显示红点
function NewlyBossData.GetRemindIndex(remind_name)
	local lv = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
	if lv < GameCond.CondId78.RoleLevel then return end

	if remind_name == RemindName.WildBossKill then
		return NewlyBossData.Instance:GetBossRemid(1)
	elseif remind_name == RemindName.CircleBossKill then
		return NewlyBossData.Instance:GetBossRemid(4)
	elseif remind_name == RemindName.VipBossKill then
		return NewlyBossData.Instance:GetBossRemid(2)
	elseif remind_name == RemindName.XinghunBossKill then
		return NewlyBossData.Instance:GetBossRemid(3)
	elseif remind_name == RemindName.MjingBossKill then
		return ExploreData.Instance.GetRareplaceRemind()
	elseif remind_name == RemindName.ReXueBossKill then
		return NewlyBossData.Instance:ReXueBossIsFlush() and 1 or 0
	elseif remind_name == RemindName.MoyuBossKill then
		return NewlyBossData.Instance:GetBossRemid(9)
	elseif remind_name == RemindName.ReXueBossKill then
		return NewlyBossData.Instance:ShenWeiKill(8)
	end
end

-- 获取boss是够红点
function NewlyBossData:GetBossRemid(index)
	local is_vis = 0
	local data = NewBossData.Instance:SetRareBossInfo(index) or {}
	for k, v in pairs(data) do
		if v.boss_state == 0 then
			local is_rem = BossData.Instance:GetRemindFlag(v.boss_type, v.rindex) == 0
			if is_rem then
				is_vis = 1
				break
			end
		end
	end
	return is_vis
end

-- 点击改变状态
function NewlyBossData:ChangeState()
	self:DispatchEvent(NewlyBossData.NEWLY_BOSS_REMIND)
	RemindManager.Instance:DoRemindDelayTime(RemindName.WildBossKill)
	RemindManager.Instance:DoRemindDelayTime(RemindName.CircleBossKill)
	RemindManager.Instance:DoRemindDelayTime(RemindName.VipBossKill)
	RemindManager.Instance:DoRemindDelayTime(RemindName.XinghunBossKill)
	RemindManager.Instance:DoRemindDelayTime(RemindName.MjingBossKill)
end
--------------------------------------
-- 玛雅神殿数据
--------------------------------------
function NewlyBossData:MayaBossData()
	local data = {}
	for k, v in pairs(FieldNpcCfg[248].layer) do
		local vo = {
			layer = k,
			comsume = v.consumes,
			circle = v.circle,
			scene_id = v.sceneId,
			type = 6,
			boss_id = self:GetFirstBossid(v.sceneId, 6),
		}
		table.insert(data, vo)
	end

	if not data[0] and data[1] then
		data[0] = table.remove(data, 1)
	end

	return data
end

-- 获取该层的第一个bossid
function NewlyBossData:GetFirstBossid(scene_id, boss_type)
	local idx
	for k, v in pairs(NewBossData.Instance:SetRareBossInfo(boss_type)) do
		if scene_id == v.scene_id and v.refresh_time == 0 then
			idx = v.boss_id
			break
		end
	end
	return idx
end

-- 获取层boss数据
function NewlyBossData:GetSceneData(scene_id, boss_type)
	local boss_list = {}
	for k, v in pairs(ModBossConfig[boss_type]) do
		if v.SceneId == scene_id then
			local vo = {
				boss_type = v.type,
				boss_id = v.BossId,
				boss_lv = v.bosslv,
				scene_id = v.SceneId,
			}
			table.insert(boss_list, vo)
		end
	end
	return boss_list
end

-- 获得boss等级
function NewlyBossData:GetBossLv(data, boss_type)
	local lv = 0
	local lv_list = {}
	for k, v in pairs(data) do
		if lv ~= v.boss_lv then
			local vo = {
				boss_lv = v.boss_lv,
				scene_id = v.scene_id,
				id_cfg = self:GetBossIdNUm(v.scene_id, v.boss_lv, boss_type)
			}
			table.insert(lv_list, vo)
		end
		lv = v.boss_lv
	end
	return lv_list
end

-- 获得此场景的bossid
function NewlyBossData:GetBossIdNUm(scene_id, lv, boss_type)
	local id_data = {}
	for k, v in pairs(ModBossConfig[boss_type]) do
		if lv == v.bosslv and scene_id == v.SceneId then
			table.insert(id_data, v.BossId)
		end
	end

	return id_data
end

-- 获取该id存活个数
function NewlyBossData:GetBossNum(cfg, boss_type)
	local index = 0
	local boss_list = BossData.Instance:GetSceneBossListByType(boss_type)
	for k, v in pairs(boss_list) do
		for k1, v1 in pairs(cfg) do
			local left_time = v.refresh_time - Status.NowTime + v.now_time
			if k == v1 and left_time <= 0 then 
				index = index + 1
			end
		end
	end

	return index
end
--------------------------------------
-- 玛雅神殿数据
--------------------------------------

--------------------------------------
-- 地下宫殿数据
--------------------------------------
-- 获取地下宫殿层数
function NewlyBossData:GetPalaceData()
	local sce_id = 0
	local boss_list = {}
	local layer = 0
	for k, v in pairs(ModBossConfig[16]) do
		if sce_id ~= v.SceneId then
			layer = layer + 1
			local vo = {
				layer = layer,
				scene_id = v.SceneId,
				type = 16,
				boss_id = self:GetFirstBossid(v.SceneId, 16),
			}
			table.insert(boss_list, vo)
			sce_id = v.SceneId
		end
	end

	if not boss_list[0] and boss_list[1] then
		boss_list[0] = table.remove(boss_list, 1)
	end

	return boss_list
end

--------------------------------------
-- 地下宫殿数据
--------------------------------------

-- 获取需要打开tips的场景
function NewlyBossData:GetTipScene()
	local scene_cfg = {}
	local idx_1 = 0
	local boss_scene = BossFlagConfig or {}

	for k, v in pairs(boss_scene) do
		if v.show and v.type then
			for k1, v1 in pairs(ModBossConfig[v.type]) do
				if idx_1 ~= v1.SceneId then
					table.insert(scene_cfg, v1.SceneId)
				end
				idx_1 = v1.SceneId
			end
		end
	end
	
	return scene_cfg
end

-- 获取屠魔令加点时间
function NewlyBossData:SetTumoAddTime(protocol)
	if protocol.start_time ~= 0 then
		self.add_time = protocol.start_time + GlobalConfig.nIntervalDevilTokenTimes
	end
	
	self:DispatchEvent(NewlyBossData.TUMO_ADD_TIME)
end

function NewlyBossData:GetAddTime()
	return self.add_time
end

--------------------------------------
-- 野外boss数据
--------------------------------------
-- 合并名字一样的boss
function NewlyBossData:MergeBoss(index)
	local data = {}
	local name
	local open_server_days = OtherData.Instance:GetOpenServerDays()
	for k, v in ipairs(ModBossConfig[index]) do
		v.order_index = k
		if open_server_days >= v.opensvrday then
			if name ~= v.BossName then
				table.insert(data, v)
			end
		end

		name = v.BossName
	end

	return data
end

-- 获取野外boss数据
function NewlyBossData:GetFieldBossData(index)
	local boss_cfg = {}

	local list = self:MergeBoss(index)
	local boss_list = BossData.Instance:GetSceneBossListByType(index)
	for k1, v1 in pairs(list) do
		local cur_boss_data = boss_list[v1.BossId]
		if cur_boss_data then
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
			data.rindex = v1.order_index or 0 --顺序索引 对应提醒标记中的位数
			data.monster_lv = cur_boss_data.monster_lv
			data.monster_circle = cur_boss_data.monster_circle
			data.monster_lunhui = cur_boss_data.monster_lunhui 
			local is_enough = BossData.BossIsEnoughAndTip(data)
			local item = self:GetSameBossItem(v1.BossName, is_enough)
			local is_kill = #item > 1 and self:GetIsCanKill(item) or (cur_boss_data.refresh_time - Status.NowTime + cur_boss_data.now_time)
			local is_rem = BossData.Instance:GetRemindFlag(cur_boss_data.boss_type, v1.order_index or 0) == 0
			local state = is_rem and (is_enough and (is_kill > 0 and 3 or 0) or 2) or 1
			data.boss_state = state  --0表示可以击杀1表示击杀2未开启
			data.item = item
			table.insert(boss_cfg, data)
		end
	end

	self:SortList(boss_cfg)

	return boss_cfg
end

-- 获取boss是否有刷新
function NewlyBossData:GetIsCanKill(item)
	local time = 1
	for k, v in pairs(item) do
		if v.state == 1 then
			time = 0
			break
		end
	end
	return time
end

-- 获取野外boss同名字的场景
function NewlyBossData:GetSameBossItem(name, state)
	local item = {}
	for k, v in pairs(ModBossConfig[1]) do
		if name == v.BossName then
			local refresh_time, now_time = self:GetBossFlushTiem(v.BossId)
			local vo = {
				scene = v.SceneName,
				cs_id = v.chuansongId,
				boss_type = v.type,
				boss_id = v.BossId, 
				refresh_time = refresh_time,
				now_time = now_time,
				state = (refresh_time - (Status.NowTime - now_time)) <= 0 and 1 or 0,
				is_kill = state,
			}	
			table.insert(item, vo)
		end
	end

	return item
end

-- 根据bossid获取刷新时间
function NewlyBossData:GetBossFlushTiem(id)
	local refresh_time, now_time = 0, 0
	local boss_list = BossData.Instance:GetSceneBossListByType(1)

	local cur_boss_data = boss_list[id]
	if cur_boss_data then
		refresh_time = cur_boss_data.refresh_time
		now_time = cur_boss_data.now_time
	end

	return refresh_time, now_time
end

function NewlyBossData:SortList(list)
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

--------------------------------------
-- 野外boss数据
--------------------------------------

-- 热血霸者

function NewlyBossData:GetReXueBossRankList()
	return self.rank_list or {}
end

function NewlyBossData:SetReXueBossRankList(list)
	self.rank_list = list
	self:DispatchEvent(NewlyBossData.RX_BOSS_RANK_LIST_CHANGE, self.rank_list)
end

function NewlyBossData:GetReXueBossInfo()
	return self.rank_info or {}
end

function NewlyBossData:SetReXueBossInfo(info)
	self.rank_info = info
	self:DispatchEvent(NewlyBossData.RX_BOSS_SELF_RANK_CHANGE, self.rank_info)
end

function NewlyBossData:ReXueBossIsFlush()
	return self.rexue_boss_state and self.rexue_boss_state == 1
end

function NewlyBossData:GetReXueBossState()
	-- 1 为刷新  2为死亡
	return self.rexue_boss_state or 2
end

function NewlyBossData:OnReXueBossStateChange(state)
	self.rexue_boss_state = state
	self:DispatchEvent(NewlyBossData.NEWLY_BOSS_REMIND)
	self:DispatchEvent(NewlyBossData.RX_BOSS_STATE_CHANGE, {is_flush = state == 1})
end

function NewlyBossData:GetReXueBossResumeTime()

--获取离下个星期几剩余时间（星期天为第一天）
	-- local cur_time =TimeCtrl.Instance:GetServerTime()
	-- local tab = os.date("*t", cur_time)
	-- tab.hour = 0
	-- tab.min = 0
	-- tab.sec = 0
	-- --剩余天数
 --    local rest_day = (wday - tab.wday + 7)%7 
	-- --下个星期某一天的时间戳
	-- if rest_day == 0 then
	-- 	rest_day = 7
	-- end
	-- local time=   tonumber(os.time(tab)) + rest_day*86400
	-- return time - cur_time

	local weeks = ReXueBaZheBossCfg.actTime.weeks
	local starttm = ReXueBaZheBossCfg.actTime.starttm
	local endtm = ReXueBaZheBossCfg.actTime.endtm

	local curr_time = os.time()
	local date_t = os.date("*t", curr_time)
	
	-- test
	-- local curr_time2 = os.time({day = date_t.day - 3, month = date_t.month, year = date_t.year, hour = date_t.hour, min = date_t.min, sec = date_t.sec})
	-- local date2_t = os.date("*t", curr_time2)

	local date = date_t
	--匹配配置中的星期
	local t_week = date.wday - 1
	if t_week == 0 then
		t_week = 7
	end
	local day = 7 - t_week + 1
	for i,v in ipairs(weeks) do
		if v >= t_week then
			day = v - t_week 
			break
		end
	end

	local end_time = os.time({day = date.day + day, month = date.month, year = date.year, hour = starttm[1], min = starttm[2], sec = 0})
	
	return end_time - curr_time
end

-- 龙魂秘境数据
function NewlyBossData:GetLonghunData()
	local data_list = DmkjConfig.LoongDmCfg.LoongKingTreasureTroveCfg.LoongSceneCfg or {}
	local data = {}
	for k, v in pairs(data_list) do
		local own_all_num = ExploreData.Instance:GetXunBaoData().own_all_num or 0
		local boor = own_all_num >= (v.openDmTms or 0)
		local boss_list = BossData.Instance:GetSceneBossListByType(5)
		local cur_boss = boss_list[v.boss_id] or {}
		local left_time = (cur_boss.now_time or 0) + (cur_boss.refresh_time or 0) - Status.NowTime
		local is_show = left_time <= 0
		v.time = is_show
		v.state = boor and (is_show and 2 or 0) or 1
		table.insert(data, v)
	end

	table.sort(data, function(a, b)
		if a.state == b.state then
			return a.layer < b.layer
		else
			return a.state > b.state
		end
	end)

	return data
end