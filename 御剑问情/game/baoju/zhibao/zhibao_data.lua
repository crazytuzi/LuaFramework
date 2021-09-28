ZhiBaoData = ZhiBaoData or BaseClass()

ZhiBaoData.ClassChs = {
	[0] = Language.Common.NumToChs[0],
	[1] = Language.Common.NumToChs[1],
	[2] = Language.Common.NumToChs[2],
	[3] = Language.Common.NumToChs[3],
	[4] = Language.Common.NumToChs[4],
	[5] = Language.Common.NumToChs[5],
	[6] = Language.Common.NumToChs[6],
	[7] = Language.Common.NumToChs[7],
	[8] = Language.Common.NumToChs[8],
	[9] = Language.Common.NumToChs[9],
	[10] = Language.Common.NumToChs[10],
}

FETCH_ACTIVE_REWARD_OPERATE_TYEP = {
	FETCH_ACTIVE_DEGREE_REWARD = 0,
	FETCHE_TOTAL_ACTIVE_DEGREE_REWARD = 1,
	FETCH_ACTIVE_REWARD_IN_LEIJI_DAILY_VIEW = 2,
}

function ZhiBaoData:GetChsNumber(num)
	if num >= 0 and num <= 10 then
		return self.ClassChs[num]..Language.Common.Jie
	elseif num > 10 then
		return self.ClassChs[10]..self.ClassChs[num - 10]..Language.Common.Jie
	end
end

function ZhiBaoData:__init()
	if ZhiBaoData.Instance then
		print_error("[ZhiBaoData] 尝试创建第二个单例模式")
		return
	end
	ZhiBaoData.Instance = self
	self.zhibao_level = 0

	local activedegree_cfg = ConfigManager.Instance:GetAutoConfig("activedegree_auto")
	self.max_active_type_max = 0
	for k,v in pairs(activedegree_cfg.degree) do
		self.max_active_type_max = self.max_active_type_max + 1
	end
	self.max_active_reward_max = 0
	for k,v in pairs(activedegree_cfg.reward) do
		self.max_active_reward_max = self.max_active_reward_max + 1
	end

	local zhibao_cfg = ConfigManager.Instance:GetAutoConfig("zhibaoconfig_auto")
	self.zhibao_level_cfg = zhibao_cfg.level_attr
	self.zhibao_skill_cfg = zhibao_cfg.skill
	self.active_degree_cfg = activedegree_cfg.degree
	self.active_reward_cfg = activedegree_cfg.reward
	self.active_degree_limit = activedegree_cfg.other[1].vitality_limit
	self.ratio_cfg = activedegree_cfg.ratio
	self.zhibao_huanhua = zhibao_cfg.huanhua
	self.zhibao_huanhua_list = ListToMapList(self.zhibao_huanhua,"huanhua_type","grade")
	self.activity_huanhua = zhibao_cfg.activity_huanhua
	self.active_reward_on_day = ListToMapList(activedegree_cfg.reward_on_day, "day")

	self.old_level = -1

	self.active_degree_info = {}
	self.degree_seq_list = {}
	self.huanhua_type_data = {}
	local count = 1
	local cu_type = -1
	for k,v in pairs(self.zhibao_huanhua) do
		if cu_type ~= v.huanhua_type then
			cu_type = v.huanhua_type
			local tmp_data = {}
			tmp_data.huanhua_type = v.huanhua_type
			self.huanhua_type_data[count] = tmp_data
			count = count + 1
		end
	end

	self.red_point_list = {
		["Active"] = false,
		["Upgrade"] = false,
		["HuanHua"] = false,
	}
	self.event_quest = GlobalEventSystem:Bind(OpenFunEventType.OPEN_TRIGGER, BindTool.Bind(self.ShowZhiBaoModel, self))
	RemindManager.Instance:Register(RemindName.ZhiBao_Active, BindTool.Bind(self.GetZhiBaoActiveRemind, self))
	RemindManager.Instance:Register(RemindName.ZhiBao_Upgrade, BindTool.Bind(self.GetZhiBaoUpgradeRemind, self))
	RemindManager.Instance:Register(RemindName.ZhiBao_HuanHua, BindTool.Bind(self.GetZhiBaoHuanHuaRemind, self))
end

function ZhiBaoData:__delete()
	RemindManager.Instance:UnRegister(RemindName.ZhiBao_Active)
	RemindManager.Instance:UnRegister(RemindName.ZhiBao_Upgrade)
	RemindManager.Instance:UnRegister(RemindName.ZhiBao_HuanHua)
	self.active_degree_info = nil
	if self.event_quest ~= nil then
		GlobalEventSystem:UnBind(self.event_quest)
		self.event_quest = nil
	end

	ZhiBaoData.Instance = nil
end

function ZhiBaoData:GetActivityHuanHuaCfg()
	return self.activity_huanhua
end

function ZhiBaoData:ShowZhiBaoModel(name)
	if "BaoJu" == name then
		ZhiBaoCtrl.Instance:SendUseImage(self:GetJsByLevel(self.zhibao_level))
		if self.event_quest ~= nil then
			GlobalEventSystem:UnBind(self.event_quest)
			self.event_quest = nil
		end
	end
end

--同步玩家至宝信息
function ZhiBaoData:SyncZhiBaoInfo(protocol)
	self.zhibao_level = protocol.level
	self.use_image = protocol.use_image
	self.exp = protocol.exp
	self.huanhua_using_type = protocol.huanhua_using_type
	self.huanhua_level_list = protocol.huanhua_level_list
end

-- 通过等级获取阶数
function ZhiBaoData:GetJsByLevel(level)
	for k,v in pairs(self.zhibao_level_cfg) do
		if level == v.level then
			return v.image_id
		end
	end
end

-- 通过等级获取名字
function ZhiBaoData:GetNameByLevel()
	for k,v in pairs(self.zhibao_level_cfg) do
		if self.zhibao_level == v.level then
			return v.name
		end
	end
end

-- 判断是否进阶
function ZhiBaoData:GetZhiBaoIsJj(is_need_level)
	local cur_js = self:GetJsByLevel(self.zhibao_level)
	local old_js = self:GetJsByLevel(self.old_level)

	if is_need_level then
		return cur_js
	end

	if self.old_level > -1 and self.zhibao_level ~= self.old_level and cur_js ~= old_js then
		return true
	end

	return false
end

-- 判断是否是升级
function ZhiBaoData:GetIsUpGrade()
	if self.old_level > -1 and self.zhibao_level ~= self.old_level then
		return true
	end

	return false
end

-- 设置旧的等级
function ZhiBaoData:SetOldLevel(level)
	self.old_level = level
end

-- 根据等级获取属性
function ZhiBaoData:GetAttrByLevel(level)
	local data = CommonStruct.Attribute()
	local fight = 0
	for k,v in pairs(self.zhibao_level_cfg) do
		if level == v.level then
			data.gong_ji = v.gongji
			data.fang_yu = v.fangyu
			data.max_hp = v.maxhp
			data.ming_zhong = v.mingzhong
			data.shan_bi = v.shanbi
			data.bao_ji = v.baoji
			data.jian_ren = v.jianren
			fight = CommonDataManager.GetCapabilityCalculation(data)
			break
		end
	end

	return data,fight
end

--获取经验等级系数
function ZhiBaoData:GetExpRatio()
	local ratio = 1
	local level = GameVoManager.Instance:GetMainRoleVo().level
	for _, v in ipairs(self.ratio_cfg) do
		if level < v.min_level then
			break
		end
		ratio = v.exp_ratio
	end
	return ratio
end

-- 获取新旧属性值
function ZhiBaoData:GetAttrOldOrNew(is_old)
	if is_old then
		return self:GetAttrByLevel(self.old_level)
	else
		return self:GetAttrByLevel(self.zhibao_level)
	end
end


--至宝活跃变动后检测活跃红点
function ZhiBaoData:GetZhiBaoActiveRemind()
	self:ActiveDegreeRedPoint()
	if self:IsCanGetReward() then
		return 1
	end
	return self.red_point_list["Active"] and 1 or 0
end

function ZhiBaoData:IsCanGetReward()
	local main_level = GameVoManager.Instance:GetMainRoleVo().level
	for k,v in pairs(self.active_degree_cfg) do
		if v.is_show == 1 then
			local degree = self:GetActiveDegreeListByIndex(v.type) or 0
			local fetch_flag = self:GetRewardFetchFlag(v.type)
			if main_level >= v.open_level and degree >= v.max_times and fetch_flag == 0 then
				return true
			end
		end
	end
end

--至宝活跃变动后检测活跃红点
function ZhiBaoData:ActiveDegreeRedPoint()
	if not next(self.active_degree_info) then
		return
	end
	local flag = false
	--检测功能是否开启
	if not OpenFunData.Instance:CheckIsHide("baoju") then
		self.red_point_list["Active"] = flag
		return
	end
	local player_degree = self.active_degree_info.total_degree
	local reward_info = self:GetActiveRewardInfo()
	for k,v in pairs(reward_info) do
		if not v.flag then
			if v.cfg.degree_limit <= player_degree then
				flag = true
				break
			end
		end
	end
	self.red_point_list["Active"] = flag
end

--至宝信息变动后检测升级红点
function ZhiBaoData:GetZhiBaoUpgradeRemind()
	self:ZhiBaoRedPoint()
	return self.red_point_list["Upgrade"] and 1 or 0
end

--至宝信息变动后检测升级红点
function ZhiBaoData:ZhiBaoRedPoint()
	local list = TaskData.Instance:GetTaskCompletedList()
	if list[OPEN_FUNCTION_TYPE_ID.ZHIBAO] ~= 1 then
		return
	end
	local flag = self:CheckZhiBaoCanUpgrade()
	self.red_point_list["Upgrade"] = flag
end

function ZhiBaoData:CheckZhiBaoCanUpgrade()
	local flag = false
	--检测功能是否开启
	if not OpenFunData.Instance:CheckIsHide("baoju") then
		return flag
	end
	local cfg = self:GetLevelCfgByLevel(self.zhibao_level)
	local next_cfg = self:GetLevelCfgByLevel(self.zhibao_level + 1)
	if next_cfg ~= nil and cfg ~= nil and self.exp then
		flag = (self.exp >= cfg.uplevel_exp)
	end
	return flag
end

--物品变动后检测幻化红点
function ZhiBaoData:GetZhiBaoHuanHuaRemind()
	self:HuanHuaRedPoint()
	return self.red_point_list["HuanHua"] and 1 or 0
end

--物品变动后检测幻化红点
function ZhiBaoData:HuanHuaRedPoint()
	if self.huanhua_level_list == nil then
		return
	end
	local flag = false
	--检测功能是否开启
	if not OpenFunData.Instance:CheckIsHide("baoju") then
		self.red_point_list["HuanHua"] = flag
		return
	end
	for k,v in pairs(self.huanhua_level_list) do
		local can_upgrade = self:CheckHuanHuaCanUpgradeByType(k)
		if can_upgrade then
			flag = true
			break
		end
	end
	self.red_point_list["HuanHua"] = flag
end

--根据类型检测是否能激活/升阶
function ZhiBaoData:CheckHuanHuaCanUpgradeByType(type)
	local flag = false
	local data = self:GetHuanHuaLevelCfg(type, true)
	if data ~= nil then
		local had_num = ItemData.Instance:GetItemNumInBagById(data.stuff_id)
		if had_num >= data.stuff_count then
			flag = true
		end
	end
	return flag
end

function ZhiBaoData:GetRedPoint()
	return self.red_point_list
end

--获取玩家使用中的至宝形象
function ZhiBaoData:GetZhiBaoImage()
	return self.use_image
end

-- 根据image_id获取至宝形象
function ZhiBaoData:GetZhiBaoXingX(image_id)
	for k,v in pairs(self.zhibao_level_cfg) do
		if v.image_id == image_id then
			return v.res_id
		end
	end
end

function ZhiBaoData:GetImageIsActive(image_index)
	local cfg = self:GetLevelCfgByLevel(self.zhibao_level)
	return (cfg.image_id >= image_index)
end

--获取玩家至宝等级
function ZhiBaoData:GetZhiBaoLevel()
	return self.zhibao_level
end

--获取玩家至宝经验
function ZhiBaoData:GetZhiBaoExp()
	return self.exp
end

--获取玩家至宝经验
function ZhiBaoData:GetZhiBaoCanUpgrade()
	local uplevel_exp = self:GetLevelCfgByLevel(self.zhibao_level).uplevel_exp
	return (self.exp >= uplevel_exp)
end

--获取宝等级最大形象数
function ZhiBaoData:GetMaxImageNum()
	local max_image = 0
	for k,v in pairs(self.zhibao_level_cfg) do
		if v.image_id > max_image then
			max_image = v.image_id
		end
	end
	return max_image
end

--获取所有幻化类型的配置
function ZhiBaoData:GetZhiBaoHuanHuaCfg()
	if self.temp_list then
		return self.temp_list
	end
	local list = {}
	local server_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local count = 0
	for k,v in pairs(self.activity_huanhua) do
		count = count + 1
	end
	for i=0,count - 1 do
		if server_day >= self.activity_huanhua[i].open_day then
			-- table.insert(list, self.activity_huanhua[i])
			list[self.activity_huanhua[i].id] = true
		end
	end
	self.temp_list = {}
	for i,v in ipairs(self.huanhua_type_data) do
		if list[v.huanhua_type] then
			table.insert(self.temp_list, v)
		end
	end
	self.huanhua_type_data = self.temp_list
	return self.huanhua_type_data
end

--根据幻化类型获取幻化属性
function ZhiBaoData:GetHuanHuaLevelCfg(huanhua_type, is_next, level)
	if self.zhibao_huanhua == nil then
		return
	end

	level = level or self:GetHuanHuaLevelByType(huanhua_type)
	if is_next then
		level = level + 1
	end
	if level <= 0 then
		level = 1
	end
	-- for k,v in pairs(self.zhibao_huanhua) do
	-- 	if v.huanhua_type == huanhua_type and v.grade == level then
	-- 		return v
	-- 	end
	-- end
	if not self.zhibao_huanhua_list[huanhua_type] or not self.zhibao_huanhua_list[huanhua_type][level] then
		return nil
	end
	return self.zhibao_huanhua_list[huanhua_type][level][1]
end

--根据幻化类型获取幻化等级 0为未激活
function ZhiBaoData:GetHuanHuaLevelByType(huanhua_type)
	if self.huanhua_level_list == nil then
		return 0
	end
	return self.huanhua_level_list[huanhua_type] or 0
end

--下一坐骑羽翼加成
function ZhiBaoData:GetNextAdditionCfg(mount_addition,wing_addition)
	local month_cfg = nil
	local wing_cfg = nil
	for k,v in pairs(self.zhibao_level_cfg) do
		if month_cfg == nil and v.mount_attr_add > mount_addition then
			month_cfg = v
		end

		if wing_cfg == nil and v.wing_attr_add > wing_addition then
			wing_cfg = v
		end
	end
	return month_cfg, wing_cfg
end

--获取至宝形象编号获取Cfg
function ZhiBaoData:GetLevelImageCfg(image_index)
	for k,v in pairs(self.zhibao_level_cfg) do
		if v.image_id == image_index then
			return v
		end
	end
end

--根据至宝等级获取Cfg
function ZhiBaoData:GetLevelCfgByLevel(level)
	for k,v in pairs(self.zhibao_level_cfg) do
		if v.level == level then
			return v
		end
	end
end

--获取下一形象Cfg
function ZhiBaoData:GetNextImageCfg()
	local image_index = self:GetLevelCfgByLevel(self.zhibao_level).image_id
	for k,v in pairs(self.zhibao_level_cfg) do
		if v.image_id > image_index then
			return v
		end
	end
end

--根据编号和等级获取技能Cfg
function ZhiBaoData:GetSkillCfgBySkillLevel(idx, level)
	for k,v in pairs(self.zhibao_skill_cfg) do
		if v.skill_idx == idx and v.skill_level == level then
			return v
		end
	end
end

--根据编号获取技能Cfg
function ZhiBaoData:GetSkillCfgByIndex(idx)
	local match_data = nil
	for k,v in pairs(self.zhibao_skill_cfg) do
		if v.skill_idx == idx then
			if v.zhibao_level <= self.zhibao_level then
				match_data = v
			else
				return match_data
			end
		end
	end
	return match_data
end

function ZhiBaoData:SetActiveDegreeInfo(protocol)
	self.active_degree_info = protocol
	MainUICtrl.Instance.view:FlushChargeIcon()
end

function ZhiBaoData:GetActiveDegreeInfo()
	return self.active_degree_info
end

function ZhiBaoData:GetActiveDegreeValue()
	return self.active_degree_info.total_degree
end

function ZhiBaoData:GetIsChange()
	return self.active_degree_info.is_change
end

function ZhiBaoData:GetMaxNumInfo()
	return self.max_active_reward_max ,self.max_active_type_max
end

--活跃总Cfg
function ZhiBaoData:GetActiveDegreeCfg()
	return self.active_degree_cfg
end

function ZhiBaoData:GetActiveDegreeListByIndex(index)
	local degree = 0
	if self.active_degree_info and self.active_degree_info.degree_list then
		degree = self.active_degree_info.degree_list[index] or 0
	end
	return degree
end

function ZhiBaoData:GetRewardFetchFlag(index)
	if not self.active_degree_info or not self.active_degree_info.activedegree_fetch_flag_high then
		return 0
	end
	local bit_list = bit:ll2b(self.active_degree_info.activedegree_fetch_flag_high, self.active_degree_info.activedegree_fetch_flag_low)

	return bit_list[64 - index]
end

function ZhiBaoData:GetActiveDegreeListBySeq(seq)
	for k, v in pairs(self.active_degree_cfg) do
		local degree = self:GetActiveDegreeListByIndex(v.type) or 0
		self.degree_seq_list[v.show_seq] = degree
	end
	return self.degree_seq_list[seq] or 0
end

--活跃上方滚动条信息
function ZhiBaoData:GetActiveDegreeScrollerData()
	self.degree_seq_list = {}
	local final_data = {}
	-- local done_data = {}
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	local had_done_list = {}
	for k,v in pairs(self.active_degree_cfg) do
		if v.is_show == 1 then
			local data = v
			local degree = self:GetActiveDegreeListByIndex(v.type) or 0
			local fetch_flag = self:GetRewardFetchFlag(v.type)

			self.degree_seq_list[data.show_seq] = degree

			if degree > 0 or data.act_id == "" or ActivityData.Instance:GetActivityIsInToday(data.act_id) then
				if main_role_vo.level >= data.open_level then
					if degree >= data.max_times then
						if fetch_flag == 1 then
							had_done_list[v.show_seq] = 3
						else
							had_done_list[v.show_seq] = 1
						end
					else
						had_done_list[v.show_seq] = 2
					end
					table.insert(final_data, data)
				end
			end
		end
	end

	table.sort(final_data, function(a, b)
		if had_done_list[a.show_seq] == had_done_list[b.show_seq] then
			return a.show_seq < b.show_seq
		else
	 		return had_done_list[a.show_seq] < had_done_list[b.show_seq]
	 	end
	 end)

	return final_data
end

function ZhiBaoData:GetFirstTask()
	for k, v in pairs(self:GetActiveDegreeScrollerData()) do
		if v.is_show_in_task == 1 and self:GetRewardFetchFlag(v.type) ~= 1 then
			return v
		end
	end

	return nil
end

--活跃下方奖励信息
function ZhiBaoData:GetActiveRewardInfo()
	local final_data = {}
	--第一个是寻宝用的，不读
	for i=1,#self.active_reward_cfg do
		local data = {cfg = self.active_reward_cfg[i]}
		data.flag = (self.active_degree_info.reward_flags[i] == 1)
		table.insert(final_data, data)
	end
	return final_data
end

--活跃上限
function ZhiBaoData:GetActiveDegreeLimit()
	return self.active_degree_limit
end

-- 至宝特殊形象id
function ZhiBaoData:GetSpecialResId(index)
	if index == nil then return end
	for k,v in pairs(self.activity_huanhua) do
		if index == v.id then
			return v.image_id
		end
	end
end

function ZhiBaoData:GetSpecialResIdByItem(item_id)
	if item_id == nil then return end
	for k,v in pairs(self.activity_huanhua) do
		if item_id == v.active_item then
			return v.image_id
		end
	end
end

function ZhiBaoData:GetZhiBaoHuanHua()
	return self.zhibao_huanhua
end

--记录领取活跃奖励前的开始飞行obj（飞行特效使用）
function ZhiBaoData:SetStartFlyObj(obj)
	self.start_fly_obj = obj
end

function ZhiBaoData:GetStartFlyObj()
	return self.start_fly_obj
end

function ZhiBaoData:GetDailyActiveRewardInfo()
	local active_reward_info = {}

	if not self.active_degree_info or not next(self.active_degree_info) then
		return active_reward_info
	end

	local now_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local reward_on_day_flag_list = self.active_degree_info.reward_on_day_flag_list
	local common_reward_day = #self.active_reward_on_day

	local cur_reward_index = 0
    for i = 1, 5 do
        cur_reward_index = i
        if reward_on_day_flag_list[i] == 0 then
            break
        end
    end

    active_reward_info.cur_index = cur_reward_index
	active_reward_info.total_degree = self.active_degree_info.total_degree
	active_reward_info.reward_on_day_flag_list = reward_on_day_flag_list
	-- 开服前30天按日读取，30天后统一读第31天的奖励
	if now_day >= common_reward_day then
		active_reward_info.reward_list = self.active_reward_on_day[common_reward_day]
	else
		active_reward_info.reward_list = self.active_reward_on_day[now_day]
	end
	return active_reward_info
end

function ZhiBaoData:IsShowActiveRewardRedPoint()
	local active_reward_info = self:GetDailyActiveRewardInfo()
	if not next(active_reward_info) then
		return false
	end

    local total_degree = active_reward_info.total_degree
    local has_reach  = math.min(math.floor(total_degree / 20), 5)
    if has_reach >= 1 then
        if active_reward_info.reward_on_day_flag_list[has_reach] == 0 then
            return true
        else
            return false
        end
    end
    return false
end