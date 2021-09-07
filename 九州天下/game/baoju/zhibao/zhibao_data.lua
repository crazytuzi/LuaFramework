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
	self.one_key_complete_need_gold = activedegree_cfg.other[1].one_key_complete_need_gold
	self.zhibao_huanhua = zhibao_cfg.huanhua
	self.activity_huanhua = zhibao_cfg.activity_huanhua

	self.old_level = -1

	self.active_degree_info = {}

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

	-- if not OpenFunData.Instance:CheckIsHide("baoJu") then
		self.event_quest = GlobalEventSystem:Bind(OpenFunEventType.OPEN_TRIGGER, BindTool.Bind(self.ShowZhiBaoModel, self))
	-- end
	RemindManager.Instance:Register(RemindName.ZhiBao_Active, BindTool.Bind(self.GetZhiBaoActiveRemind, self))
	RemindManager.Instance:Register(RemindName.ZhiBao_Upgrade, BindTool.Bind(self.GetZhiBaoUpgradeRemind, self))
	--RemindManager.Instance:Register(RemindName.ZhiBao_HuanHua, BindTool.Bind(self.GetZhiBaoHuanHuaRemind, self))
	RemindManager.Instance:Register(RemindName.ZhiBao, BindTool.Bind(self.GetZhiBaoRemind, self))
	self.cur_select = 1


	self.zhibao_info = {
		task_id = 999989,
		task_type = TASK_TYPE.ZHIBAO,
		task_phase = 0,										-- 任务阶段
		task_seq = 0,										-- 当前任务序号
		task_aim_camp = 0,									-- 目标阵营
		yesterday_unaccept_times = 0,						-- 昨日未参加任务的次数
		param1 = 0,											-- 特殊参数1
		param2 = 0,											-- 特殊参数2
	}

end

function ZhiBaoData:__delete()
	RemindManager.Instance:UnRegister(RemindName.ZhiBao_Active)
	RemindManager.Instance:UnRegister(RemindName.ZhiBao_Upgrade)
	RemindManager.Instance:UnRegister(RemindName.ZhiBao)
	
	if self.event_quest ~= nil then
		GlobalEventSystem:UnBind(self.event_quest)
		self.event_quest = nil
	end

	ZhiBaoData.Instance = nil
end

function ZhiBaoData:SetCurSelect(index)
	self.cur_select = index
end

function ZhiBaoData:GetCurSelect()
	return self.cur_select
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
	return self:ActiveDegreeRedPoint() and 1 or 0
end

--至宝活跃变动后检测活跃红点
function ZhiBaoData:ActiveDegreeRedPoint()
	if ClickOnceRemindList[RemindName.ZhiBao_Active] and ClickOnceRemindList[RemindName.ZhiBao_Active] == 0 then
		return false
	end
	for k,v in pairs(self:GetActiveDegreeScrollerData()) do
		local degree = self:GetActiveDegreeListBySeq(v.show_seq) or 0
		if degree < v.max_times then
			return true 
		end
	end
	return false
end

--至宝信息变动后检测升级红点
function ZhiBaoData:GetZhiBaoUpgradeRemind()
	return self:CheckZhiBaoCanUpgrade() and 1 or 0
end

function ZhiBaoData:CheckZhiBaoCanUpgrade()
	if not OpenFunData.Instance:CheckIsHide("baoju_zhibao") then
		return false
	end
	local flag = false
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
	if ClickOnceRemindList[RemindName.MarryFuBen] and ClickOnceRemindList[RemindName.MarryFuBen] == 0 then
		return 0
	end
	return self.red_point_list["HuanHua"] and 1 or 0
end

function ZhiBaoData:GetZhiBaoRemind()
	if self:CheckZhiBaoCanUpgrade() or self:ActiveDegreeRedPoint() then
		return 1
	end
	return 0
end
--物品变动后检测幻化红点
function ZhiBaoData:HuanHuaRedPoint()
	if self.huanhua_level_list == nil then
		return
	end
	local flag = false
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
	return self.huanhua_type_data
end

--根据幻化类型获取幻化属性
function ZhiBaoData:GetHuanHuaLevelCfg(huanhua_type, is_next, level)
	if self.zhibao_huanhua == nil then
		return
	end

	local level = level or self:GetHuanHuaLevelByType(huanhua_type)
	if is_next then
		level = level + 1
	end
	if level <= 0 then
		level = 1
	end
	for k,v in pairs(self.zhibao_huanhua) do
		if v.huanhua_type == huanhua_type and v.grade == level then
			return v
		end
	end
end

--根据幻化类型获取幻化等级 0为未激活
function ZhiBaoData:GetHuanHuaLevelByType(huanhua_type)
	if self.huanhua_level_list == nil then
		return 0
	end
	return self.huanhua_level_list[huanhua_type]
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
end

function ZhiBaoData:GetActiveDegreeInfo()
	return self.active_degree_info
end

function ZhiBaoData:GetActiveDegreeValue()
	return self.active_degree_info.total_degree
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
	if not self.active_degree_info or not self.active_degree_info.activedegree_fetch_flag then
		return 0
	end
	local bit_list = bit:d2b(self.active_degree_info.activedegree_fetch_flag)

	return bit_list[32 - index]
end

--活跃上方滚动条信息
function ZhiBaoData:GetActiveDegreeScrollerData()
	self.degree_seq_list = {}
	local final_data = {}
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	local had_done_list = {}
	for k,v in pairs(self.active_degree_cfg) do
		local data = TableCopy(v)
		local degree = self:GetActiveDegreeListByIndex(k - 1) or 0
		self.degree_seq_list[data.show_seq] = degree
		if (data.name == "open" or OpenFunData.Instance:CheckIsHide(data.name)) and data.open_level <= main_role_vo.level then
			if degree >= data.max_times then
				data.sort = 2
			else
				data.sort = 1
			end
			table.insert(final_data, data)
		end
	end
	SortTools.SortAsc(final_data, "sort", "show_seq")
	return final_data
end

function ZhiBaoData:GetActiveDegreeListBySeq(seq)
	for k, v in pairs(self.active_degree_cfg) do
		local degree = self:GetActiveDegreeListByIndex(v.type) or 0
		self.degree_seq_list[v.show_seq] = degree
	end

	return self.degree_seq_list[seq] or 0
end

--活跃下方奖励信息
function ZhiBaoData:GetActiveRewardInfo()
	local final_data = {}
	--第一个是寻宝用的，不读
	for i=2,#self.active_reward_cfg do
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

function ZhiBaoData:GetZhiBaoHuanHua()
	return self.zhibao_huanhua
end

function ZhiBaoData:GetZhiBaoTaskCfg()
	return self.zhibao_info
end


function ZhiBaoData:GetQuickTotalPrice()
	return self.one_key_complete_need_gold or 0
end
