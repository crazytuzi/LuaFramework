JinJieRewardData = JinJieRewardData or BaseClass()

JIN_JIE_REWARD_TARGET_TYPE = {
	BIG_TARGET = 0,
	SMALL_TARGET = 1,
}

function JinJieRewardData:__init()
	if JinJieRewardData.Instance then
		print_error("[JinJieRewardData] Attempt to create singleton twice!")
		return
	end
	JinJieRewardData.Instance = self

	self.big_active_image_flag_list = {}		-- 各系统有没有领取/购买激活道具的标识	大目标
	self.big_can_reward_flag = {}				-- 各系统能不能免费领取					大目标
	self.small_active_image_flag_list = {}		-- 各系统有没有领取/购买激活道具的标识	小目标
	self.small_can_reward_flag = {}				-- 各系统能不能免费领取					小目标
	self.timestamp_list = {}					-- 各系统免费活动截止时间列表
	self.open_view_system_type = -1				-- 打开面板的系统类型

	local cfg = ConfigManager.Instance:GetAutoConfig("jinjiesys_reward_auto")
	local jinjie_reward_cfg = cfg and cfg.item_cfg
	local jinjie_attr_cfg = cfg and cfg.attr_cfg

	self.jinjie_reward_cfg = jinjie_reward_cfg and ListToMap(jinjie_reward_cfg, "system_type", "reward_type") or {}
	self.jinjie_attr_cfg = jinjie_attr_cfg and ListToMap(jinjie_attr_cfg, "system_type") or {}
end

function JinJieRewardData:__delete()
	JinJieRewardData.Instance = nil
end

------------------------------配置-------------------------------
--奖励物品配置
function JinJieRewardData:GetAllRewardCfg()
	return self.jinjie_reward_cfg or {}
end

--属性配置
function JinJieRewardData:GetAllAttrCfg()
	return self.jinjie_attr_cfg or {}
end

-- 单个系统的奖励配置  target_type  大目标/小目标 0/1  不传默认大目标
function JinJieRewardData:GetSingleRewardCfg(system_type, target_type)
	local single_reward_cfg = {}
	local all_reward_cfg = self:GetAllRewardCfg()
	if nil == all_reward_cfg or nil == system_type or nil == all_reward_cfg[system_type] then
		return single_cfg
	end

	local reward_type = target_type or JIN_JIE_REWARD_TARGET_TYPE.BIG_TARGET
	single_cfg = all_reward_cfg[system_type][reward_type] or {}
	return single_cfg
end

-- 单个系统的属性配置
function JinJieRewardData:GetSingleAttrCfg(system_type)
	local single_cfg = {}
	local all_attr_cfg = self:GetAllAttrCfg()
	if nil == next(all_attr_cfg) or nil == system_type then
		return single_cfg
	end

	single_cfg = all_attr_cfg[system_type] or {}
	return single_cfg
end

--获取单个系统属性加成万分比
function JinJieRewardData:GetSingleAttrCfgAttrAddPer(system_type)
	local single_cfg = self:GetSingleAttrCfg(system_type)
	local add_per = single_cfg.add_per or 0
	return add_per
end

--获取单个系统显示奖励进阶开始天数 target_type  大目标/小目标 0/1   不传默认大目标
function JinJieRewardData:GetSingleRewardCfgOpenServerDay(system_type, target_type)
	local single_cfg = self:GetSingleRewardCfg(system_type, target_type)
	local openserver_day = single_cfg.openserver_day or -1
	return openserver_day
end

--获取单个系统免费活动持续时间 target_type  大目标/小目标 0/1   不传默认大目标
function JinJieRewardData:GetSingleRewardCfgContinueHour(system_type, target_type)
	local single_cfg = self:GetSingleRewardCfg(system_type, target_type)
	local duration_time = single_cfg.duration_time or 0
	return duration_time
end

--获取单个系统达到奖励阶数 target_type  大目标/小目标 0/1   不传默认大目标
function JinJieRewardData:GetSingleRewardCfgGetRewardGrade(system_type, target_type)
	local single_cfg = self:GetSingleRewardCfg(system_type, target_type)
	local grade = single_cfg.grade
	local reward_grade = grade and grade - 1 or 0
	return reward_grade
end

--获取单个系统可显示目标阶数 target_type  大目标/小目标 0/1   不传默认大目标
function JinJieRewardData:GetSingleRewardCfgShowGrade(system_type, target_type)
	local single_cfg = self:GetSingleRewardCfg(system_type, target_type)
	local show_grade = single_cfg.show_grade or 0
	return show_grade
end

--获取单个系统 param_0 是大目标幻化形象id  是小目标的title_id target_type  大目标/小目标 0/1   不传默认大目标
function JinJieRewardData:GetSingleRewardCfgParam0(system_type, target_type)
	local single_cfg = self:GetSingleRewardCfg(system_type, target_type)
	local param_0 = single_cfg.param_0 or 0
	return param_0
end

--获取单个系统达到奖励的奖励物品id target_type  大目标/小目标 0/1   不传默认大目标
function JinJieRewardData:GetSingleRewardCfgRewardId(system_type, target_type)
	local single_cfg = self:GetSingleRewardCfg(system_type, target_type)
	local reward_item_list = single_cfg.reward_item
	local item_id = 0
	if reward_item_list and reward_item_list.item_id then
		item_id = reward_item_list.item_id
	end

	return item_id
end

--获取单个系统购买金额 target_type  大目标/小目标 0/1   不传默认大目标
function JinJieRewardData:GetSingleRewardCfgCost(system_type, target_type)
	local single_cfg = self:GetSingleRewardCfg(system_type, target_type)
	local cost = single_cfg.cost or 0
	return cost
end
----------------------------配置结束------------------------------

-----------------------------协议---------------------------------

--进阶奖励信息
function JinJieRewardData:SetRewardInfo(protocol)
	self.big_active_image_flag_list = bit:d2b(protocol.reward_flag)			-- 各系统有没有领取/购买激活道具的标识	大目标
	self.big_can_reward_flag = bit:d2b(protocol.can_reward_flag)			-- 各系统能不能免费领取					大目标

	self.small_active_image_flag_list = bit:d2b(protocol.reward_flag_1)		-- 各系统有没有领取/购买激活道具的标识	小目标
	self.small_can_reward_flag = bit:d2b(protocol.can_reward_flag_1)		-- 各系统能不能免费领取					小目标
end

--各系统免费激活形象结束时间戳
function JinJieRewardData:SetEndTimeInfo(protocol)
	local count = protocol.use_sys_count		--系统数量
	if count > 0 and protocol.timestamp_list then
		self.timestamp_list = protocol.timestamp_list
	end
end
----------------------------协议结束------------------------------

-----------------------面板显示相关数据---------------------------

--系统活动是否开启(当前天数大于配置中的开服天数) target_type  大目标/小目标 0/1   不传默认大目标
function JinJieRewardData:GetSystemFreeIsOpen(system_type, target_type)
	local is_open = false
	if nil == system_type then
		return is_open
	end

	local open_server_day = self:GetSingleRewardCfgOpenServerDay(system_type, target_type)
	local cur_open_server_day = TimeCtrl.Instance:GetCurOpenServerDay()
	if open_server_day ~= -1 and cur_open_server_day >= open_server_day then
		is_open = true
	end
	return is_open
end

--各系统活动结束时间  target_type  大目标/小目标   0/1  不传默认大目标
function JinJieRewardData:GetSystemFreeEndTime(system_type, target_type)
	local end_time = 0
	if nil == system_type or nil == self.timestamp_list or nil == next(self.timestamp_list) then
		return end_time
	end

	local reward_type = target_type or JIN_JIE_REWARD_TARGET_TYPE.BIG_TARGET
	for k,v in pairs(self.timestamp_list) do
		if v.sys_type == system_type and v.reward_type == reward_type then
			end_time = v.end_timestamp
			break
		end
	end

	return end_time or 0
end

--免费时间是否结束 target_type  大目标/小目标   0/1  不传默认大目标
function JinJieRewardData:FreeTimeIsEnd(system_type, target_type)
	local is_end = true
	if nil == system_type then
		return is_end
	end

	local end_time = self:GetSystemFreeEndTime(system_type, target_type)
	local cur_time = TimeCtrl.Instance:GetServerTime() 										--活动时间内返回false
	local is_open = self:GetSystemFreeIsOpen(system_type, target_type)
	if is_open and end_time ~= 0 and cur_time <= end_time then
		is_end = false
	end

	return is_end
end

--系统活动是否已结束(大目标) 未激活该形象+背包中没有所需的激活道具+没有购买或者领取激活所用道具+在活动时间内 (false/true 活动进行中/活动结束)
function JinJieRewardData:GetSystemFreeIsEnd(system_type)
	local is_end = true
	if nil == system_type then
		return is_end
	end

	local is_active = self:GetSystemIsActiveSpecialImage(system_type)						--激活的情况下返回true
	if is_active then
		return is_end
	end

	local is_get_active_item = self:BagIsHaveActiveNeedItem(system_type)					--背包中有激活用的道具返回true
	if is_get_active_item then
		return is_end
	end

	local get_flag_by_info = self:GetSystemIsGetActiveNeedItemFromInfo(system_type) 		--已购买或者已领取激活所用道具返回true
	if get_flag_by_info then
		return is_end
	end

	local free_time_is_end = self:FreeTimeIsEnd(system_type, JIN_JIE_REWARD_TARGET_TYPE.BIG_TARGET) --活动时间内返回false
	if not free_time_is_end then
		is_end = false
	end

	return is_end
end

--系统活动小目标免费活动是否已结束
function JinJieRewardData:GetSystemSmallTargetFreeIsEnd(system_type)
	local is_end = self:FreeTimeIsEnd(system_type, JIN_JIE_REWARD_TARGET_TYPE.SMALL_TARGET)
	return is_end
end

--当前系统进阶等级 大目标用
function JinJieRewardData:GetSystemCurLevel(system_type)
	local cur_level = 0
	if nil == system_type then
		return cur_level
	end

	local info_level = 0
	if system_type == JINJIE_TYPE.JINJIE_TYPE_MOUNT then 					-- 坐骑
		info_level = MountData.Instance:GetGrade()
	elseif system_type == JINJIE_TYPE.JINJIE_TYPE_WING then 				-- 羽翼
		info_level = WingData.Instance:GetGrade()
	elseif system_type == JINJIE_TYPE.JINJIE_TYPE_SHENGONG then				-- 伙伴光环
		info_level = ShengongData.Instance:GetGrade()
	elseif system_type == JINJIE_TYPE.JINJIE_TYPE_SHENYI then				-- 伙伴法阵
		info_level = ShenyiData.Instance:GetGrade()
	elseif system_type == JINJIE_TYPE.JINJIE_TYPE_HALO then					-- 角色光环
		info_level = HaloData.Instance:GetGrade()
	elseif system_type == JINJIE_TYPE.JINJIE_TYPE_FOOTPRINT then			-- 足迹
		info_level = FootData.Instance:GetGrade()
	elseif system_type == JINJIE_TYPE.JINJIE_TYPE_FIGHT_MOUNT then			-- 战骑
		info_level = FightMountData.Instance:GetGrade()
	end

	cur_level = info_level and info_level - 1 or 0 							-- 服务端阶数从1开始，客户端阶数从0开始
	return cur_level
end

--系统是否激活了这个幻化形象 大目标用
function JinJieRewardData:GetSystemIsActiveSpecialImage(system_type)
	local is_active = false
	if nil == system_type then
		return is_active
	end

	local img_id = self:GetSingleRewardCfgParam0(system_type, JIN_JIE_REWARD_TARGET_TYPE.BIG_TARGET)
	if nil == img_id then
		return is_active
	end

	if system_type == JINJIE_TYPE.JINJIE_TYPE_MOUNT then 					-- 坐骑
		is_active = MountData.Instance:GetSpecialImageIsActive(img_id)
	elseif system_type == JINJIE_TYPE.JINJIE_TYPE_WING then 				-- 羽翼
		is_active = WingData.Instance:GetSpecialImageIsActive(img_id)
	elseif system_type == JINJIE_TYPE.JINJIE_TYPE_SHENGONG then				-- 伙伴光环
		is_active = ShengongData.Instance:GetSpecialImageIsActive(img_id)
	elseif system_type == JINJIE_TYPE.JINJIE_TYPE_SHENYI then				-- 伙伴法阵
		is_active = ShenyiData.Instance:GetSpecialImageIsActive(img_id)
	elseif system_type == JINJIE_TYPE.JINJIE_TYPE_HALO then					-- 角色光环
		is_active = HaloData.Instance:GetSpecialImageIsActive(img_id)
	elseif system_type == JINJIE_TYPE.JINJIE_TYPE_FOOTPRINT then			-- 足迹
		is_active = FootData.Instance:GetSpecialImageIsActive(img_id)
	elseif system_type == JINJIE_TYPE.JINJIE_TYPE_FIGHT_MOUNT then			-- 战骑
		is_active = FightMountData.Instance:GetSpecialImageIsActive(img_id)
	end

	return is_active
end

--系统是否 已领取/已购买 激活形象所需道具 来自协议  大目标
function JinJieRewardData:GetSystemIsGetActiveNeedItemFromInfo(system_type)
	local is_have = false
	if nil == system_type then
		return is_have
	end

	local active_flag = self.big_active_image_flag_list[32 - system_type] or 0
	is_have = active_flag > 0
	return is_have
end

--系统是否 已领取/已购买 激活形象所需道具 来自协议  小目标
function JinJieRewardData:GetSystemSmallIsGetActiveNeedItemFromInfo(system_type)
	local is_have = false
	if nil == system_type then
		return is_have
	end

	local active_flag = self.small_active_image_flag_list[32 - system_type] or 0
	is_have = active_flag > 0
	return is_have
end

--各系统是否 能够免费领取 道具 来自协议 大目标
function JinJieRewardData:GetSystemIsCanFreeLingQuFromInfo(system_type)
	local is_can_free = false
	if nil == system_type then
		return is_can_free
	end

	local active_flag = self.big_can_reward_flag[32 - system_type] or 0
	is_can_free = active_flag > 0
	return is_can_free
end

--各系统是否能够免费领取道具 来自协议 小目标
function JinJieRewardData:GetSystemSmallIsCanFreeLingQuFromInfo(system_type)
	local is_can_free = false
	if nil == system_type then
		return is_can_free
	end

	local active_flag = self.small_can_reward_flag[32 - system_type] or 0
	is_can_free = active_flag > 0
	return is_can_free
end
 
-- 相关系统是否显示进阶奖励图标 target_type 大目标/小目标 0/1 不传默认大目标 激活当前幻化形象/达到配置要求的等级和时间  
function JinJieRewardData:IsShowJinJieRewardIcon(system_type, target_type)
	local is_show_icon = false
	if nil == system_type then
		return is_show_icon
	end

	local is_active = self:GetSystemIsActiveSpecialImage(system_type)		-- 如果激活就显示图标
	if is_active then
		return true
	end

	local is_open = self:GetSystemFreeIsOpen(system_type, target_type)
	local limit_level = self:GetSingleRewardCfgShowGrade(system_type, target_type)
	local cur_level = self:GetSystemCurLevel(system_type)
	if is_open and limit_level ~= -1 and cur_level >= limit_level then
		is_show_icon = true
	end

	return is_show_icon
end

--背包是否有激活所需的道具 target_type  大目标/小目标   0/1  不传默认大目标
function JinJieRewardData:BagIsHaveActiveNeedItem(system_type, target_type)
	local is_have = false
	local index = -1
	local sub_type = -1
	if nil == system_type then
		return is_have, index, sub_type
	end

	local active_item_id = self:GetSingleRewardCfgRewardId(system_type, target_type)
	if nil == active_item_id or active_item_id == 0 then
		return is_have, index, sub_type
	end

	local data_list = ItemData.Instance:GetBagItemDataList()
	if nil == data_list then
		return is_have, index, sub_type
	end

	for k, v in pairs(data_list) do
		if v.item_id == active_item_id then
			is_have = true
			index = v.index
			sub_type = v.sub_type
			break
		end
	end

	return is_have, index, sub_type
end

--系统是否显示小红点 未激活当前形象+背包有激活所需道具 或 未激活当前形象+背包中没有激活所需道具+未购买/未领取+可免费领取道具
function JinJieRewardData:SystemIsShowRedPoint(system_type)
	if nil == system_type then
		return false
	end

	local is_active = self:GetSystemIsActiveSpecialImage(system_type)				-- 激活后不显示红点
	if is_active then
		return false
	end

	local is_get_active_item = self:BagIsHaveActiveNeedItem(system_type)			-- 未激活+背包有激活所需道具
	if is_get_active_item then
		return true
	end

	local is_get_active_need_item = self:GetSystemIsGetActiveNeedItemFromInfo(system_type)
	local is_can_free_ling_qu = self:GetSystemIsCanFreeLingQuFromInfo(system_type)			
	if not is_get_active_need_item and is_can_free_ling_qu then 					-- 未激活+未得到激活所需道具+可以免费领取显示红点
		return true
	end

	-- local bag_is_have_small_target = self:BagIsHaveActiveNeedItem(system_type, JIN_JIE_REWARD_TARGET_TYPE.SMALL_TARGET)
	-- local is_get_small_tagert = self:GetSystemSmallIsGetActiveNeedItemFromInfo(system_type)
	-- local is_can_free_get_small_tagert = self:GetSystemSmallIsCanFreeLingQuFromInfo(system_type)
	-- if not is_get_active_need_item and not bag_is_have_small_target and not is_get_small_tagert and is_can_free_get_small_tagert then 				-- 小目标可以免费领取
	-- 	return true
	-- end

	return false
end

--各系统超级幻化形象对应等级
function JinJieRewardData:GetSystemSpecialImageGrade(system_type, img_id)
	local grade = 0
	if nil == system_type or nil == img_id then
		return grade
	end

	if system_type == JINJIE_TYPE.JINJIE_TYPE_MOUNT then 					-- 坐骑
		grade = MountData.Instance:GetSingleSpecialImageGrade(img_id)
	elseif system_type == JINJIE_TYPE.JINJIE_TYPE_WING then 				-- 羽翼
		grade = WingData.Instance:GetSingleSpecialImageGrade(img_id)
	elseif system_type == JINJIE_TYPE.JINJIE_TYPE_SHENGONG then				-- 伙伴光环
		grade = ShengongData.Instance:GetSingleSpecialImageGrade(img_id)
	elseif system_type == JINJIE_TYPE.JINJIE_TYPE_SHENYI then				-- 伙伴法阵
		grade = ShenyiData.Instance:GetSingleSpecialImageGrade(img_id)
	elseif system_type == JINJIE_TYPE.JINJIE_TYPE_HALO then					-- 角色光环
		grade = HaloData.Instance:GetSingleSpecialImageGrade(img_id)
	elseif system_type == JINJIE_TYPE.JINJIE_TYPE_FOOTPRINT then			-- 足迹
		grade = FootData.Instance:GetSingleSpecialImageGrade(img_id)
	elseif system_type == JINJIE_TYPE.JINJIE_TYPE_FIGHT_MOUNT then			-- 战骑
		grade = FightMountData.Instance:GetSingleSpecialImageGrade(img_id)
	end

	return grade or 0
end

--各系统超级幻化形象等级配置
function JinJieRewardData:GetSystemSpecialImageLevelCfg(system_type, img_id)
	local cfg = {}
	if nil == system_type or nil == img_id then 
		return cfg
	end

	local special_grade = self:GetSystemSpecialImageGrade(system_type, img_id)
	local grade = special_grade <= 0 and 1 or special_grade

	if system_type == JINJIE_TYPE.JINJIE_TYPE_MOUNT then 					-- 坐骑
		cfg = MountData.Instance:GetSpecialImageUpgradeInfo(img_id, grade)
	elseif system_type == JINJIE_TYPE.JINJIE_TYPE_WING then 				-- 羽翼
		cfg = WingData.Instance:GetSpecialImageUpgradeInfo(img_id, grade)
	elseif system_type == JINJIE_TYPE.JINJIE_TYPE_SHENGONG then				-- 伙伴光环
		cfg = ShengongData.Instance:GetSpecialImageUpgradeInfo(img_id, grade)
	elseif system_type == JINJIE_TYPE.JINJIE_TYPE_SHENYI then				-- 伙伴法阵
		cfg = ShenyiData.Instance:GetSpecialImageUpgradeInfo(img_id, grade)
	elseif system_type == JINJIE_TYPE.JINJIE_TYPE_HALO then					-- 角色光环
		cfg = HaloData.Instance:GetSpecialImageUpgradeInfo(img_id, grade)
	elseif system_type == JINJIE_TYPE.JINJIE_TYPE_FOOTPRINT then			-- 足迹
		cfg = FootData.Instance:GetSpecialImageUpgradeInfo(img_id, grade)
	elseif system_type == JINJIE_TYPE.JINJIE_TYPE_FIGHT_MOUNT then			-- 战骑
		cfg = FightMountData.Instance:GetSpecialImageUpgradeInfo(img_id, grade)
	end
	return cfg
end

--各系统进阶等级基础战力和额外加成百分比 未达到可额外加成的等级,额外加成百分比未0
function JinJieRewardData:GetSystemJinJieLevelBasePowerAndExtraAddPer(system_type)
	local base_power = 0
	local extra_add_per = 0
	if nil == system_type then 
		return base_power, extra_add_per
	end

	if system_type == JINJIE_TYPE.JINJIE_TYPE_MOUNT then 													-- 坐骑
		base_power, extra_add_per = MountData.Instance:GetCurGradeBaseFightPowerAndAddPer()
	elseif system_type == JINJIE_TYPE.JINJIE_TYPE_WING then 												-- 羽翼
		base_power, extra_add_per = WingData.Instance:GetCurGradeBaseFightPowerAndAddPer()
	elseif system_type == JINJIE_TYPE.JINJIE_TYPE_SHENGONG then												-- 伙伴光环
		base_power, extra_add_per = ShengongData.Instance:GetCurGradeBaseFightPowerAndAddPer()
	elseif system_type == JINJIE_TYPE.JINJIE_TYPE_SHENYI then												-- 伙伴法阵
		base_power, extra_add_per = ShenyiData.Instance:GetCurGradeBaseFightPowerAndAddPer()
	elseif system_type == JINJIE_TYPE.JINJIE_TYPE_HALO then													-- 角色光环
		base_power, extra_add_per = HaloData.Instance:GetCurGradeBaseFightPowerAndAddPer()
	elseif system_type == JINJIE_TYPE.JINJIE_TYPE_FOOTPRINT then											-- 足迹
		base_power, extra_add_per = FootData.Instance:GetCurGradeBaseFightPowerAndAddPer()
	elseif system_type == JINJIE_TYPE.JINJIE_TYPE_FIGHT_MOUNT then											-- 战骑
		base_power, extra_add_per = FightMountData.Instance:GetCurGradeBaseFightPowerAndAddPer()
	end

	return base_power, extra_add_per
end

--系统激活超级幻化形象战力值
function JinJieRewardData:GetSystemSpecialImageFightPower(system_type, cfg)
	local all_power = 0
	if nil == system_type then 
		return all_power
	end

	local base_power, extra_add_per = self:GetSystemJinJieLevelBasePowerAndExtraAddPer(system_type)
	local huanhua_fight_power = 0
	if cfg then
		huanhua_fight_power = CommonDataManager.GetCapabilityCalculation(cfg)
	end

	local attr_cfg = self:GetSingleAttrCfg(system_type)
	local add_per = attr_cfg.add_per or 0 				--万分比

	-- 总战力 = 幻化战力 + 幻化战力 * 达到指定等级的额外加成(原有逻辑) + 当前进阶等级的基础战力*激活当前形象的属性加成
	all_power = huanhua_fight_power + (huanhua_fight_power * extra_add_per * 0.01) + (base_power * add_per * 0.0001)
	return all_power
end

--系统激活超级幻化形象配置
function JinJieRewardData:GetSystemSpecialImageCfg(system_type, img_id)
	local cfg = {}
	if nil == system_type or nil == img_id then 
		return cfg
	end

	if system_type == JINJIE_TYPE.JINJIE_TYPE_MOUNT then 					-- 坐骑
		cfg = MountData.Instance:GetSpecialImageCfg(img_id)
	elseif system_type == JINJIE_TYPE.JINJIE_TYPE_WING then 				-- 羽翼
		cfg = WingData.Instance:GetSpecialImageCfg(img_id)
	elseif system_type == JINJIE_TYPE.JINJIE_TYPE_HALO then					-- 角色光环
		cfg = HaloData.Instance:GetSpecialImageCfg(img_id)
	elseif system_type == JINJIE_TYPE.JINJIE_TYPE_FOOTPRINT then			-- 足迹
		cfg = FootData.Instance:GetSpecialImageCfg(img_id)
	elseif system_type == JINJIE_TYPE.JINJIE_TYPE_FIGHT_MOUNT then			-- 战骑
		cfg = FightMountData.Instance:GetSpecialImageCfg(img_id)
	elseif system_type == JINJIE_TYPE.JINJIE_TYPE_SHENGONG then				-- 伙伴光环
		for k, v in pairs(ShengongData.Instance:GetSpecialImagesCfg()) do
			if v.image_id == img_id then
				cfg = v
				break
			end
		end
	elseif system_type == JINJIE_TYPE.JINJIE_TYPE_SHENYI then				-- 伙伴法阵
		for k, v in pairs(ShenyiData.Instance:GetSpecialImagesCfg()) do
			if v.image_id == img_id then
				cfg = v
				break
			end
		end
	end

	return cfg or {}
end

--抢购钱是否足够
function JinJieRewardData:GoldIsEnough(need_gold)
	local is_enough = false
	if nil == need_gold then
		return is_enough
	end

	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	local have_gold = main_vo.gold
	if have_gold >= need_gold then
		is_enough = true
	end
	return is_enough
end

function JinJieRewardData:SetCurSystemType(system_type)
	self.open_view_system_type = system_type or -1
end

function JinJieRewardData:GetCurSystemType()
	return self.open_view_system_type
end

-- 各系统百分比加成和超级幻化形象展示
function JinJieRewardData:GetSystemShowPercentAndName(system_type)
	local percent = 0
	local name = ""
	if nil == system_type then
		return percent, name
	end

	local attr_cfg = self:GetSingleAttrCfg(system_type)
	local per = attr_cfg.add_per or 0
	percent = per and per/100 or 0

	local img_id = self:GetSingleRewardCfgParam0(system_type, JIN_JIE_REWARD_TARGET_TYPE.BIG_TARGET)
	local huan_hua_cfg = self:GetSystemSpecialImageCfg(system_type, img_id)
	local image_name = huan_hua_cfg and huan_hua_cfg.image_name
	name = image_name or ""
	return percent, name
end

--是否使用了当前进阶奖励的幻化形象
function JinJieRewardData:GetSystemIsUseCurSpecialImage(system_type)
	local is_use = false
	if nil == system_type then 
		return is_use
	end

	local is_active = self:GetSystemIsActiveSpecialImage(system_type)
	if not is_active then
		return is_use
	end

	local img_id = self:GetSingleRewardCfgParam0(system_type, JIN_JIE_REWARD_TARGET_TYPE.BIG_TARGET)
	if nil == img_id then
		return is_use
	end

	local use_img_id = 0
	if system_type == JINJIE_TYPE.JINJIE_TYPE_MOUNT then 					-- 坐骑
		local multi_mount_flag = MultiMountData.Instance:GetCurUseMountId()
		if multi_mount_flag == 0 then
			use_img_id = MountData.Instance:GetUsedImageId() or 0
		end
	elseif system_type == JINJIE_TYPE.JINJIE_TYPE_WING then 				-- 羽翼
		use_img_id = WingData.Instance:GetUsedImageId()		
	elseif system_type == JINJIE_TYPE.JINJIE_TYPE_SHENGONG then				-- 伙伴光环
		use_img_id = ShengongData.Instance:GetUsedImageId()
	elseif system_type == JINJIE_TYPE.JINJIE_TYPE_SHENYI then				-- 伙伴法阵
		use_img_id = ShenyiData.Instance:GetUsedImageId()
	elseif system_type == JINJIE_TYPE.JINJIE_TYPE_HALO then					-- 角色光环
		use_img_id = HaloData.Instance:GetUsedImageId()
	elseif system_type == JINJIE_TYPE.JINJIE_TYPE_FOOTPRINT then			-- 足迹
		use_img_id = FootData.Instance:GetUsedImageId()
	elseif system_type == JINJIE_TYPE.JINJIE_TYPE_FIGHT_MOUNT then			-- 战骑
		use_img_id = FightMountData.Instance:GetUsedImageId()
	end

	if use_img_id and use_img_id >= GameEnum.MOUNT_SPECIAL_IMA_ID then
		is_use = use_img_id == img_id + GameEnum.MOUNT_SPECIAL_IMA_ID
	end

	return is_use
end

--各系统当前进阶等级的img_id
function JinJieRewardData:GetSystemCurJinJieGradeImageId(system_type)
	local image_id = 0
	if nil == system_type then 
		return image_id
	end

	local cur_garde = self:GetSystemCurLevel(system_type)
	if system_type == JINJIE_TYPE.JINJIE_TYPE_MOUNT then 					-- 坐骑
		image_id = MountData.Instance:GetCurGradeImageId()
	elseif system_type == JINJIE_TYPE.JINJIE_TYPE_WING then 				-- 羽翼
		image_id = WingData.Instance:GetCurGradeImageId()		
	elseif system_type == JINJIE_TYPE.JINJIE_TYPE_SHENGONG then				-- 伙伴光环
		image_id = ShengongData.Instance:GetCurGradeImageId()
	elseif system_type == JINJIE_TYPE.JINJIE_TYPE_SHENYI then				-- 伙伴法阵
		image_id = ShenyiData.Instance:GetCurGradeImageId()
	elseif system_type == JINJIE_TYPE.JINJIE_TYPE_HALO then					-- 角色光环
		image_id = HaloData.Instance:GetCurGradeImageId()
	elseif system_type == JINJIE_TYPE.JINJIE_TYPE_FOOTPRINT then			-- 足迹
		image_id = FootData.Instance:GetCurGradeImageId()
	elseif system_type == JINJIE_TYPE.JINJIE_TYPE_FIGHT_MOUNT then			-- 战骑
		image_id = FightMountData.Instance:GetCurGradeImageId()
	end

	return image_id
end

--是否显示小目标 不显示条件1.激活大目标形象 2.已领取/已购买 小目标 3.背包有小目标激活卡 3.符合显示条件
function JinJieRewardData:IsShowSmallTarget(system_type)
	-- if nil == system_type then
	-- 	return true
	-- end

	-- local is_active = self:GetSystemIsActiveSpecialImage(system_type)						
	-- if is_active then
	-- 	return false
	-- end

	-- local small_target_is_has_get_by_info = self:GetSystemSmallIsGetActiveNeedItemFromInfo(system_type)
	-- if small_target_is_has_get_by_info then
	-- 	return false
	-- end

	-- local small_target_bag_is_have = self:BagIsHaveActiveNeedItem(system_type, JIN_JIE_REWARD_TARGET_TYPE.SMALL_TARGET)
	-- if small_target_bag_is_have then
	-- 	return false
	-- end

	-- local is_show = self:IsShowJinJieRewardIcon(system_type, JIN_JIE_REWARD_TARGET_TYPE.SMALL_TARGET)
	-- if not is_show then
	-- 	return false
	-- end

	return false
end

--计算小目标称号战力值
function JinJieRewardData:GetSmallTargetTitlePower(system_type)
	local res_id = self:GetSingleRewardCfgParam0(system_type, JIN_JIE_REWARD_TARGET_TYPE.SMALL_TARGET)
	local power = 0
	if res_id then
		local cfg = TitleData.Instance:GetTitleCfg(res_id)
		if cfg then
			power = CommonDataManager.GetCapabilityCalculation(cfg)
		end
	end

	return power
end

-- 设置小目标面板的显示
function JinJieRewardData:GetSmallTargetShowData(system_type, callback)
	local data_list = CommonStruct.TimeLimitTitleInfo()
	if nil == system_type then
		return data_list
	end

	local end_time = self:GetSystemFreeEndTime(system_type, JIN_JIE_REWARD_TARGET_TYPE.SMALL_TARGET)
	local cur_time = TimeCtrl.Instance:GetServerTime()
	local left_time = end_time - cur_time

	data_list.item_id = self:GetSingleRewardCfgRewardId(system_type, JIN_JIE_REWARD_TARGET_TYPE.SMALL_TARGET)		-- 称号激活卡item_id
	data_list.cost = self:GetSingleRewardCfgCost(system_type, JIN_JIE_REWARD_TARGET_TYPE.SMALL_TARGET)				-- 直接购买花费
	data_list.left_time = left_time																					-- 免费时间
	data_list.can_fetch = self:GetSystemSmallIsCanFreeLingQuFromInfo(system_type)									-- 是否可领取
	data_list.from_panel = Language.JinJieReward.FlushSystemType[system_type]										-- 来自面板
	data_list.call_back = callback																					-- 回调函数
	return data_list
end
---------------------------------------------特殊名将结束----------
-----------------------面板显示相关数据阶数---------------------------