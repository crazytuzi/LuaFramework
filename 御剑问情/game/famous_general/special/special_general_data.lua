SpecialGeneralData = SpecialGeneralData or BaseClass()

GENERAL_TARGET_TYPE = {
	BIG_TARGET = 0,
	SMALL_TARGET = 1,
}

function SpecialGeneralData:__init()
	SpecialGeneralData.Instance = self

	self.cur_used_special_img_id = 0 			-- 当前使用特殊形象id
	self.small_goal_can_fetch_flag = 0			-- 小目标是否可以免费领取标记 可免费/不可免费 0/1
	self.small_goal_fetch_flag = 0				-- 小目标领取标记 领取/未领取 0/1
	self.system_open_timestamp = 0				-- 系统开放时间
	self.special_img_active_flag = {}			-- 名将特殊形象激活标记
	self.special_img_can_fetch_flag = {}		-- 名将特殊形象可领取标记
	self.special_img_fetch_flag = {}			-- 名将特殊形象领取标记
	self.special_img_level_list = {}			-- 特殊形象等级列表

	local all_cfg = ConfigManager.Instance:GetAutoConfig("greate_soldier_config_auto")
	local special_img_cfg = all_cfg and all_cfg.special_img
	local special_image_upgrade_cfg = all_cfg and all_cfg.special_img_uplevel
	local other_cfg = all_cfg and all_cfg.other 

	self.other_cfg = other_cfg or {}
	self.special_img_cfg = special_img_cfg and ListToMap(special_img_cfg, "special_img_id") or {}
	self.special_image_upgrade_cfg = special_image_upgrade_cfg and ListToMap(special_image_upgrade_cfg, "special_img_id", "level") or {}
end

function SpecialGeneralData:__delete()
	SpecialGeneralData.Instance = nil
end

---------------------------------------------配置相关--------------------------------------------------
--获取所有的幻化配置
function SpecialGeneralData:GetSpecialImagesCfg()
	return self.special_img_cfg or {}
end

--小目标系统开启后有效时间
function SpecialGeneralData:GetSamllTargetContinueDay()
	local continue_day = self.other_cfg[1] and self.other_cfg[1].small_goal_valid_day
	return continue_day or 0
end

--小目标奖励物品卡
function SpecialGeneralData:GetSmallTargetRewardItemId()
	local list = self.other_cfg[1] and self.other_cfg[1].small_goal_reward_item
	local item_id = 0
	if list then
		item_id = list.item_id or 0
	end

	return item_id
end

--小目标展示称号资源id
function SpecialGeneralData:GetSmallTargetShowTitleId()
	local res_id = self.other_cfg[1] and self.other_cfg[1].title_show
	return res_id or 0
end

--小目标购买价格
function SpecialGeneralData:GetSmallTargetBuyPrice()
	local price = self.other_cfg[1] and self.other_cfg[1].small_goal_gold_price
	return price or 0
end

--获取单个幻化形象的配置
function SpecialGeneralData:GetSpecialImageCfgInfoByImageId(image_id)
	local cfg = {}
	if nil == image_id then
		return cfg
	end

	local all_cfg = self:GetSpecialImagesCfg()
	cfg = all_cfg[image_id] or {}
	return cfg
end

--获取单个幻化形象激活所需item_id
function SpecialGeneralData:GetActiveSpecialImageNeedItemId(image_id)
	local item_id = 0
	if nil == image_id then
		return item_id
	end

	local cfg = self:GetSpecialImageCfgInfoByImageId(image_id)
	item_id = cfg.item_id or 0
	return item_id
end

--获取单个幻化形象免费持续天数时间戳(系统开启天数)
function SpecialGeneralData:GetSpecialImageFreeSystemOpenDay(image_id)
	local system_open_day = 0
	if nil == image_id then
		return system_open_day
	end

	local cfg = self:GetSpecialImageCfgInfoByImageId(image_id)
	system_open_day = cfg.system_open_day or 0

	return system_open_day
end

--获取单个幻化形象增加其他天神属性的万分比
function SpecialGeneralData:GetSpecialImageAttrAddPer(image_id)
	local attr_add_per = 0
	if nil == image_id then
		return attr_add_per
	end

	local cfg = self:GetSpecialImageCfgInfoByImageId(image_id)
	attr_add_per = cfg.add_other_soldier_attr_per or 0

	return attr_add_per
end

--获取对应等级幻化信息
function SpecialGeneralData:GetHuanHuaCfgInfo(image_id, grade)
	local list = {}
	grade = grade or self:GetHuanHuaGrade(image_id)
	grade = grade < 1 and 1 or grade

	if self.special_image_upgrade_cfg[image_id] then
		list = self.special_image_upgrade_cfg[image_id][grade] or {}
	end

	return list
end

---------------------------------------------配置结束--------------------------------------------------

---------------------------------------------协议相关--------------------------------------------------
function SpecialGeneralData:SetGeneralInfo(protocol)
	self.cur_used_special_img_id = protocol.cur_used_special_img_id						-- 当前使用特殊形象id
	self.small_goal_can_fetch_flag = protocol.small_goal_can_fetch_flag					-- 小目标是否可以免费领取标记 可免费/不可免费 0/1
	self.small_goal_fetch_flag = protocol.small_goal_fetch_flag							-- 小目标领取标记 领取/未领取 0/1
	self.system_open_timestamp = protocol.system_open_timestamp							-- 系统开放时间
	self.special_img_active_flag = bit:d2b(protocol.special_img_active_flag)			-- 名将特殊形象激活标记
	self.special_img_can_fetch_flag = bit:d2b(protocol.special_img_can_fetch_flag)		-- 名将特殊形象可领取标记
	self.special_img_fetch_flag = bit:d2b(protocol.special_img_fetch_flag)				-- 名将特殊形象领取/购买标记
	self.special_img_level_list = protocol.special_img_level_list 						-- 特殊形象等级列表
end
---------------------------------------------协议结束--------------------------------------------------

---------------------------------------------特殊名将相关--------------------------------------------------
--特殊天神对应的幻化id
function SpecialGeneralData:GetSpecialGeneraImgId()
	return 1
end

--获取当前是否使用特殊形象和特殊形象img_id
function SpecialGeneralData:GetCurIsUsedSpecialImgIdAndSpecialImgId()
	local is_use = false
	local cur_used_special_img_id = self.cur_used_special_img_id or 0
	if cur_used_special_img_id > 0 then
		is_use = true
		cur_used_special_img_id = cur_used_special_img_id + GameEnum.MOUNT_SPECIAL_IMA_ID
	end
	return is_use, cur_used_special_img_id
end

--获取对应幻化等级
function SpecialGeneralData:GetHuanHuaGrade(image_id)
	local grade = 0
	if nil == self.special_img_level_list or nil == image_id or nil == self.special_img_level_list[image_id] then
		return grade
	end

	grade = self.special_img_level_list[image_id]
	return grade
end

--小目标是否已经领取  来自协议
function SpecialGeneralData:SmallTargetIsAchieve()
	return self.small_goal_fetch_flag > 0
end

--小目标是否可以免费领取  来自协议
function SpecialGeneralData:SmallTargetIsCanFreeGet()
	return self.small_goal_can_fetch_flag > 0
end

--小目标战力显示
function SpecialGeneralData:SmallTargetFightPower()
	local id = self:GetSmallTargetShowTitleId()
	local cfg = TitleData.Instance:GetTitleCfg(id)
	local power = 0
	if cfg then
		power = CommonDataManager.GetCapabilityCalculation(cfg)
	end

	return power
end

--是否显示小目标
function SpecialGeneralData:IsShowSmallTarget()
	local image_id = self:GetSpecialGeneraImgId()
	local is_active = self:SpecialImageIsActive(image_id)														-- 激活的特殊形象  大目标
	if is_active then
		return false
	end

	local small_target_is_achieve = self:SmallTargetIsAchieve()													-- 小目标 已购买/已领取
	if small_target_is_achieve then
		return false
	end

	local small_target_is_bag_have = self:BagIsHaveActiveNeedItem(image_id, GENERAL_TARGET_TYPE.SMALL_TARGET) 	-- 背包中有小目标奖励
	if small_target_is_bag_have then
		return false
	end

	return true
end

--特殊天神是否激活
function SpecialGeneralData:SpecialImageIsActive(image_id)
	local is_active = false
	if nil == image_id then
		return is_active
	end
	
	if self.special_img_active_flag[32 - image_id] then
		is_active = self.special_img_active_flag[32 - image_id] > 0
	end

	return is_active
end

--特殊天神是否可以免费领取激活用道具
function SpecialGeneralData:SpecialImageIsCanFreeLingQu(image_id)
	local is_can_free_ling_qu = false
	if nil == image_id then
		return is_can_free_ling_qu
	end
	
	if self.special_img_can_fetch_flag[32 - image_id] then
		is_can_free_ling_qu = self.special_img_can_fetch_flag[32 - image_id] > 0
	end

	return is_can_free_ling_qu
end

--特殊天神是否已经领取激活用道具
function SpecialGeneralData:SpecialImageIsHasLingqu(image_id)
	local is_has_ling_qu = false
	if nil == image_id then
		return is_has_ling_qu
	end
	
	if self.special_img_fetch_flag[32 - image_id] then
		is_has_ling_qu = self.special_img_fetch_flag[32 - image_id] > 0
	end

	return is_has_ling_qu
end

--获取免费激活结束时间戳 target_type 目标类型  不传默认大目标
function SpecialGeneralData:GetActiveFreeEndTimestamp(image_id, target_type)
	local free_end_timestamp = 0
	if nil == image_id then
		return free_end_timestamp
	end

	local system_open_timestamp = self.system_open_timestamp or 0
	local free_continue_day = 0
	if target_type and target_type == GENERAL_TARGET_TYPE.SMALL_TARGET then
		free_continue_day = self:GetSamllTargetContinueDay()					--小目标
	else
		free_continue_day = self:GetSpecialImageFreeSystemOpenDay(image_id)		--大目标
	end

	if system_open_timestamp > 0 and free_continue_day ~= 0 then
		free_end_timestamp = system_open_timestamp + free_continue_day * 60 * 60 * 24
	end
	return free_end_timestamp
end

--免费活动时间是否结束 target_type 目标类型  不传默认大目标
function SpecialGeneralData:FreeActiveTimeIsEnd(target_type)
	local is_end = true
	local image_id = self:GetSpecialGeneraImgId()
	local end_time = self:GetActiveFreeEndTimestamp(image_id, target_type)
	local cur_time = TimeCtrl.Instance:GetServerTime() 									-- 活动时间内返回false
	if end_time ~= 0 and cur_time <= end_time then
		is_end = false
	end 

	return is_end
end

--背包是否有激活特殊形象所需的道具 target_type 目标类型  不传默认大目标
function SpecialGeneralData:BagIsHaveActiveNeedItem(image_id, target_type)
	local is_have = false
	local index = -1
	local sub_type = -1
	if nil == image_id then
		return is_have, index, sub_type
	end

	local active_item_id = 0
	if target_type and target_type == GENERAL_TARGET_TYPE.SMALL_TARGET then
		active_item_id = self:GetSmallTargetRewardItemId(image_id)			--小目标
	else
		active_item_id = self:GetActiveSpecialImageNeedItemId(image_id)		--大目标
	end

	if nil == active_item_id then
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

--是否显示小红点 已激活+可升级 或 未激活+背包有激活所需道具 或 未激活+背包中没有激活所需道具+未购买/未领取+可免费领取
function SpecialGeneralData:SpecialImageIsShowRedPoint(image_id)
	if nil == image_id then
		return false
	end

	local is_active = self:SpecialImageIsActive(image_id)								-- 激活+可升级
	local is_bag_have = self:BagIsHaveActiveNeedItem(image_id)
	if is_bag_have then
		return true
	end

	if is_active then
		return false
	end

	local is_has_ling_qu = self:SpecialImageIsHasLingqu(image_id)
	local is_can_free_ling_qu = self:SpecialImageIsCanFreeLingQu(image_id)
	if not is_has_ling_qu and is_can_free_ling_qu then 				-- 未激活+未得到激活所需道具+可以免费领取显示红点
		return true
	end

	if is_has_ling_qu then
		return false
	end

	local big_is_have_small_target = self:BagIsHaveActiveNeedItem(image_id, GENERAL_TARGET_TYPE.SMALL_TARGET)
	local is_can_free_get_small_tagert = self:SmallTargetIsCanFreeGet()
	local small_target_is_achieve = self:SmallTargetIsAchieve()
	if not big_is_have_small_target and not small_target_is_achieve and is_can_free_get_small_tagert then 				-- 小目标可以免费领取
		return true
	end

	return false
end

--免费激活活动是否结束 未激活+背包中没有所需的激活道具+没有购买或者领取激活所用道具+在活动时间内 (false/true 活动进行中/活动结束)
function SpecialGeneralData:GetFreeActiveIsEnd(image_id)
	local is_end = true
	if nil == image_id then
		return is_end
	end  

	local is_active = self:SpecialImageIsActive(image_id)								-- 激活的情况下返回true
	if is_active then
		return is_end
	end
	
	local is_bag_have = self:BagIsHaveActiveNeedItem(image_id)							-- 背包中有激活用的道具返回true
	if is_bag_have then
		return is_end
	end

	local is_has_ling_qu = self:SpecialImageIsHasLingqu(image_id) 						-- 已购买或者已领取激活所用道具返回true
	if is_has_ling_qu then
		return is_end
	end

	is_end = self:FreeActiveTimeIsEnd()													-- 活动时间内返回false
	return is_end
end

--是否使用了特殊的幻化形象
function SpecialGeneralData:GetIsUseCurSpecialImage(image_id)
	local is_use = false
	if nil == image_id then 
		return is_use
	end

	local is_active = self:SpecialImageIsActive(image_id)
	if not is_active then
		return is_use
	end

	if self.cur_used_special_img_id then
		is_use = image_id == self.cur_used_special_img_id
	end

	return is_use
end

--抢购钱是否足够
function SpecialGeneralData:GoldIsEnough(need_gold)
	local is_enough = false
	if nil == need_gold then
		return is_enough
	end

	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	local have_gold = main_vo.gold
	is_enough = have_gold >= need_gold
	return is_enough
end

--战力 = 特殊形象对应等级战力+所有激活天神基础属性*战力加成   image_id 特殊形象的形象id  cfg 特殊形象的对应等级配置
function SpecialGeneralData:GetSpecialImagesPower(image_id, cfg)
	local power = 0
	local add_per = 0
	if image_id then
		add_per = self:GetSpecialImageAttrAddPer(image_id) or 0
	end

	local num = FamousGeneralData.Instance:GetListNum()
	local add_power = 0
	if num > 0 then
		for i=1, num do
			local is_active = FamousGeneralData.Instance:IsActiveGeneral(i)
			if is_active then
				local base_cfg = FamousGeneralData.Instance:GetImageCfg(i)
				local active_tianshen_power = CommonDataManager.GetCapabilityCalculation(base_cfg) or 0
				--激活天神的基础属性*战力加成
				add_power = add_power + active_tianshen_power * add_per * 0.0001
			end
		end
	end

	--特殊天神对应等级战力
	local base_power = 0
	if cfg and next(cfg) then
		base_power = CommonDataManager.GetCapabilityCalculation(cfg) or 0
	end

	--战力 = 特殊形象对应等级战力+所有激活天神基础属性*战力加成
	power = power + base_power + add_power
	return power
end

-- 设置小目标面板的显示
function SpecialGeneralData:GetSmallTargetShowData(callback)
	local data_list = CommonStruct.TimeLimitTitleInfo()
	local speical_img_id = self:GetSpecialGeneraImgId()
	local end_time = self:GetActiveFreeEndTimestamp(speical_img_id, GENERAL_TARGET_TYPE.SMALL_TARGET)
	local cur_time = TimeCtrl.Instance:GetServerTime()
	local left_time = end_time - cur_time

	data_list.item_id = self:GetSmallTargetRewardItemId()															-- 称号激活卡
	data_list.cost = self:GetSmallTargetBuyPrice()																	-- 直接购买花费
	data_list.left_time = left_time																					-- 免费时间
	data_list.can_fetch = self:SmallTargetIsCanFreeGet()															-- 是否可领取
	data_list.from_panel = TIME_LIMIT_TITLE_PANEL.GENERAL															-- 来自面板
	data_list.call_back = callback																					-- 回调函数
	return data_list
end
---------------------------------------------特殊名将结束--------------------------------------------------	