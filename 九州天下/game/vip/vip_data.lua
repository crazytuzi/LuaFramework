VIPPOWER =
{
	SCENE_FLY 						= 0,			-- 传送
	KEY_DIALY_TASK 					= 1,			-- 一键日常
	HUSONG_BUY_TIMES 				= 2,			-- 购买护送次数
	VIP_LEVEL_REWARD				= 3,			-- VIP等级礼包
	QIANGHUA_SUC					= 4,			-- 强化成功率
	DAGUAI_EXP_PLUS					= 5,			-- 打怪经验加成
	GO_BOSS_HOME					= 6,			-- 进入BOSS之家
	BUY_LOCK_TOWER_COUNT			= 7,			-- 购买锁妖塔次数
	BUY_YAOSHOU_COUNT				= 8,			-- 购买妖兽广场次数
	VIP_REVIVE 						= 9, 			-- VIP免费复活
	BODY_WAREHOUSE					= 10,			-- 随身仓库
	BODY_DRUGSTORE					= 11,			-- 随身药店
	FOUR_OUTLINE_EXP				= 12,			-- 离线4倍经验领取
	EXP_FB_BUY_TIMES				= 13,			-- 经验本扫荡次数
	COIN_FB_BUY_TIMES				= 14,			-- 铜币本扫荡次数
	BUY_ARENA_CHALLENGE_COUNT		= 15,			-- 购买竞技场挑战次数
	JINGLING_CATCH					= 16, 			-- 精灵捕获
	DAOJU_FB_BUY_TIMES				= 17, 			-- 道具副本购买次数
	CLEAN_MERDIAN_CD 				= 18,			-- 清除经脉CD
	LINGYU_FB_BUY_TIMES 			= 19,			-- 灵玉挑战副本可购买次数
	GUILD_BOX_COUNT 				= 20,			-- 公会宝箱数量
	VAT_FB_STORY_COUNT 				= 21,			-- 剧情副本购买次数
	VAT_FB_PHASE_COUNT 				= 22,			-- 阶段副本购买次数
	HOTSPRING_EXTRA_EXP 			= 23,			-- 温泉活动额外经验万分比
	TEAM_EQUIP_COUNT 				= 24,			-- 组队装备副本购买掉落次数
	VAT_BUY_CAMP_TASK_CITAN_TIMES 	= 27,			-- 	购买国家营救任务次数
	VAT_BUY_CAMP_TASK_YINGJIU_TIMES = 28,			-- 	购买国家营救任务次数
	VAT_BUY_CAMP_TASK_BANZHUAN_TIMES= 29,			-- 	购买国家搬砖任务次数
	AUTO_SHENGWU_CHOU				= 34,			-- 圣物自动回收碎片
	AUTO_SHENGWU_TEN				= 35,			-- 圣物10次回收
	MINING_CHALLENGE 				= 36, 			-- 决斗场 挑衅
	MINING_MINE 					= 37, 			-- 决斗场 挖矿购买次数
	MINING_SEA 						= 38, 			-- 决斗场 航海购买次数
	TOWER_FB_MOP_TIMES				= 39,			-- 个人塔防扫荡次数
	WORLD_CHAT_FREE_TIMES 			= 40,			-- 世界频道免费聊天次数
	-- TOWER_FB_BUY_TIMES				= 40,			-- 个人塔防购买次数
}

OPEN_VIP_RECHARGE_TYPE =
{
	VIP = 0,
	RECHANRGE = 1,
	NONE = 2
}

VIP_BOX_SHOW_POS = {
	[1] = {x = 0,y = -50},
	[2] = {x = 0,y = -40},
	[3] = {x = 0,y = -35},
	[4] = {x = 0,y = 0},
	[5] = {x = 0,y = -50},
	[6] = {x = 0,y = -40},
	[7] = {x = -22,y = -50},
	[8] = {x = 0,y = -50},
	[9] = {x = -22,y = -69},
	[10] = {x = -3,y = -9},
	[11] = {x = 0,y = 0},
	[12] = {x = 9,y = -14},
	[13] = {x = 4,y = -3},
	[14] = {x = 0,y = -13},
	[15] = {x = 0,y = 0},
	[16] = {x = 0,y = 0},
	[17] = {x = 0,y = 0},
	[18] = {x = 0,y = 0},
	[19] = {x = 0,y = 0},
	[20] = {x = 0,y = 0},
	[21] = {x = 0,y = 0},
	[22] = {x = 0,y = 0},
	[23] = {x = 0,y = 0},
	[24] = {x = 0,y = 0},
	[25] = {x = 0,y = 0},
	[26] = {x = 0,y = 0},
	[27] = {x = 0,y = 0},
	[28] = {x = 0,y = 0},
	[29] = {x = 0,y = 0},
	[30] = {x = 0,y = 0},
}

VipData = VipData or BaseClass()
function VipData:__init()
	if VipData.Instance ~= nil then
		print_error("[VipData] Attemp to create a singleton twice !")
	end
	VipData.Instance = self
	self.vip_info = {}
	self.is_show_temp_vip = false					--是否已经展示过限时vip
	self.is_in_temp_vip = false
	self.open_type = nil
	RemindManager.Instance:Register(RemindName.Vip, BindTool.Bind(self.GetVipRemind, self))
end

function VipData:__delete()
	RemindManager.Instance:UnRegister(RemindName.Vip)

	VipData.Instance = nil
end

function VipData:SetOpenType(open_type)
	self.open_type = open_type
end

function VipData:GetOpenType()
	return self.open_type
end

--vip等级信息变化
function VipData:OnVipInfo(protocol)
	self.fetch_level_reward_flag = protocol.fetch_level_reward_flag
	self.vip_info.vip_level = protocol.vip_level
	self.vip_info.last_free_buyyuanli_timestamp = protocol.last_free_buyyuanli_timestamp
	self.vip_info.fetch_qifu_buyxianhun_reward_flag = protocol.fetch_qifu_buyxianhun_reward_flag
	self.vip_info.fetch_qifu_buycoin_reward_flag = protocol.fetch_qifu_buycoin_reward_flag
	self.vip_info.gold_buyxianhun_times = gold_buyxianhun_times
	self.vip_info.fetch_qifu_buyyuanli_reward_flag = protocol.fetch_qifu_buyyuanli_reward_flag
	self.vip_info.vip_exp = protocol.vip_exp
	self.vip_info.last_free_buyxianhun_timestamp = protocol.last_free_buyxianhun_timestamp
	self.vip_info.last_free_buycoin_timestamp = protocol.last_free_buycoin_timestamp
	self.vip_info.gold_buycoin_times = protocol.gold_buycoin_times
	self.vip_info.free_buyyuanli_times = protocol.free_buyyuanli_times
	self.vip_info.gold_buyyuanli_times = protocol.gold_buyyuanli_times
	self.vip_info.obj_id = protocol.obj_id
	self.vip_info.reward_flag_list = bit:d2b(protocol.fetch_level_reward_flag)
	self.vip_info.free_buyxianhun_times = protocol.free_buyxianhun_times
	self.vip_info.free_buycoin_times = protocol.free_buycoin_times
	self.vip_info.vip_week_gift_resdiue_times = protocol.vip_week_gift_resdiue_times
	self.vip_info.time_temp_vip_time = protocol.time_temp_vip_time					--限时vip结束时间

	if self.vip_info.time_temp_vip_time > 0 then
		self.is_show_temp_vip = true
	end

	if self:IsInTempVip() then
		self.vip_info.vip_level = 0
		self.is_in_temp_vip = true
	else
		self.is_in_temp_vip = false
	end

	RemindManager.Instance:Fire(RemindName.Vip)
end

function VipData:GetTempVipEndTime()
	return self.vip_info.time_temp_vip_time or 0
end

function VipData:GetVipRemind()
	return self:GetVipRewardFetchFlag() and 1 or 0
end

--判斷是否有vip獎勵可以領取
function VipData:GetVipRewardFetchFlag()
	if nil ~= self.vip_info.vip_level and self.vip_info.vip_level > 0 then
		local total_gift_num = 0
		for i=0,self.vip_info.vip_level-1 do
			total_gift_num = total_gift_num + self:GetVipRewardCfg()[i].reward_item.num
		end
		local vip_week_num = total_gift_num - self.vip_info.vip_week_gift_resdiue_times
		for i=1,self.vip_info.vip_level do
			if self.vip_info.reward_flag_list[33-i] == 0 then
				return true
			end
		end
	end
	return false
end

-- 获取当前未领取奖励的Index
function VipData:GetCurRewardFlagIndex()
	local vip_level = VipData.Instance:GetVipInfo().vip_level
	for i=1,vip_level do
		if VipData.Instance:GetIsVipRewardByVipLevel(i) then
			vip_level = i
			break
		end
	end
	return vip_level
end

function VipData:IsInTempVip()
	local is_in = false
	local server_time = TimeCtrl.Instance:GetServerTime()
	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	if main_vo.vip_level > 0 and next(self.vip_info) and self.vip_info.time_temp_vip_time > server_time then
		is_in = true
	end
	return is_in
end

--获取是否处于限时vip中
function VipData:GetIsInTempVip()
	return self.is_in_temp_vip
end

--检查临时Vip是否结束
function VipData:CheckTempTimeIsEnd()
	local is_end = false
	local server_time = TimeCtrl.Instance:GetServerTime()
	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	if main_vo.vip_level <= 0 and next(self.vip_info) and self.vip_info.time_temp_vip_time <= server_time then
		is_end = true
	end
	return is_end
end

function VipData:GetIsVipRewardByVipLevel(level)
	if level > self.vip_info.vip_level then
		return false
	end
	if level > 0 then
		if self.vip_info.reward_flag_list[33-level] == 0 then
			return true
		else
			return false
		end
	end

	return false
end

--判断是否有VIP周礼包可领
function VipData:GetVipWeekRewardFetchFlag()
	if nil ~= self.vip_info.vip_level and self.vip_info.vip_level > 0 then
		local total_gift_num = 0
		for i=0,self.vip_info.vip_level-1 do
			total_gift_num = total_gift_num + self:GetVipRewardCfg()[i].reward_item.num
		end
		local vip_week_num = total_gift_num - self.vip_info.vip_week_gift_resdiue_times
		if vip_week_num > 0 then
			return true
		end
	end
	return false
end

-- 获取当前可领取的周礼包数量
function VipData:GetVipWeekRewardNum()
	if nil ~= self.vip_info.vip_level and self.vip_info.vip_level > 0 then
		local total_gift_num = 0
		for i=0,self.vip_info.vip_level-1 do
			total_gift_num = total_gift_num + self:GetVipRewardCfg()[i].reward_item.num
		end
		local vip_week_num = total_gift_num - self.vip_info.vip_week_gift_resdiue_times
		return vip_week_num
	end
	return 0
end

--获取列表中第一个可以领取奖励的vip等级
function VipData:GetFirstCanFetchGiftVip(exclude_vip)
	if nil ~= self.vip_info.vip_level and self.vip_info.vip_level > 0 then
		for i=1,self.vip_info.vip_level do
			if exclude_vip ~= i and self.vip_info.reward_flag_list[33-i] == 0 then
				return i
			end
		end
	end
end

function VipData:GetVipInfo()
	return self.vip_info
end

function VipData:GetVipBuffCfg(vip_level)
	return ConfigManager.Instance:GetAutoConfig("vip_auto").vipbuff[vip_level]
end

function VipData:GetVipLevelCfg()
	return ConfigManager.Instance:GetAutoConfig("vip_auto").level
end

function VipData:GetVipRewardCfg()
	return ConfigManager.Instance:GetAutoConfig("vip_auto").level_reward
end

function VipData:GetVipUpLevelCfg()
	return ConfigManager.Instance:GetAutoConfig("vip_auto").uplevel
end

function VipData:GetVipWeekGiftCfg()
	return ConfigManager.Instance:GetAutoConfig("vip_auto").other[1]
end

function VipData:GetTempVipTime()
	return ConfigManager.Instance:GetAutoConfig("vip_auto").other[1].time_limit_vip_time
end

function VipData:GetVipPowerList(vip_id)
	local vip_cfg = self:GetVipLevelCfg()
	local power_list = {}
	for k,v in pairs(VIPPOWER) do
		if vip_cfg[v] ~= nil then
			power_list[v] = vip_cfg[v]["param_"..vip_id]
		end
	end
	return power_list
end

function VipData:GetVipPowerListIsByIndex(is_get_num)
	local vip_cfg = self:GetVipLevelCfg()
	local power_list = {}
	local index = 1
	for k,v in pairs(vip_cfg) do
		power_list[index] = v
		index = index + 1
	end
	if is_get_num then
		return index - 1
	end
	return power_list
end

--返回所有当前vip的主要权限描述
function VipData:GetVipPowerDesc(vip_id)
	return "待定"
end

function VipData:GetVipRewardFlag(vip_id)
	local flag = self.vip_info.reward_flag_list[33 - vip_id]
	if flag == 0 then
		return false
	else
		return true
	end
end

function VipData:GetFBSaodangCount(auth_type, vip_level)
	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	if not auth_type  then return end
	local vip_level = vip_level or main_vo.vip_level
	for k, v in pairs(self:GetVipLevelCfg()) do
		if k == auth_type then
			return v["param_"..vip_level]
		end
	end
	return 0
end

function VipData:GetFBSaodangMaxCount(auth_type)
	if not auth_type  then return end

	local max_count = 0
	for k, v in pairs(self:GetVipLevelCfg()) do
		if k == auth_type then
			for m, n in pairs(v) do
				if string.find(m, "param_") and max_count < n then
					max_count = n
				end
			end
		end
	end
	return max_count
end

-- 计算下一个可购买vip等级
function VipData:GetNextVipLevel(auth_type, vip_level)
	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	if not auth_type  then return end
	vip_level = vip_level or main_vo.vip_level
	local cur_count = self:GetFBSaodangCount(auth_type, vip_level)
	for k,v in pairs(self:GetVipLevelCfg()) do
		if k == auth_type and "table" == type(v) then
			for level = 1, GameEnum.MAX_VIP_LEVEL do
				if v["param_" .. level] and v["param_" .. level] > cur_count then
					return level
				end
			end
		end
	end
	return 0
end

-- --返回指定类型的权限描述
-- function VipData:GetVipPowerDesc(auth_type)
-- 	return self:GetVipLevelCfg()[auth_type].power_desc
-- end

-- --返回需要全部权限描述
-- function VipData:GetVipAllPowerDesc(vip_id)
-- 	local desc_list = {}
-- 	local power_list = self:GetVipPowerList(vip_id)
-- 	if vip_id == 1 then
-- 		for k,v in pairs(power_list) do
-- 			if v ~= 0 then
-- 				desc_list[#desc_list + 1] = self:GetDescPostfix(k, v)
-- 			end
-- 		end
-- 	else
-- 		local power_list_before = self:GetVipPowerList(vip_id - 1)
-- 		desc_list[1] = "享受VIP ".. (vip_id - 1).."全部特权并且:"
-- 		for k,v in pairs(power_list) do
-- 			if v ~= power_list_before[k] then
-- 				desc_list[#desc_list + 1] = self:GetDescPostfix(k, v)
-- 			end
-- 		end
-- 	end
-- 	return desc_list
-- end

-- --返回描述后缀
-- function VipData:GetDescPostfix(auth_type,value)
-- 	local show_type = self:GetVipLevelCfg()[auth_type].show_type
-- 	local text = self:GetVipPowerDesc(auth_type)
-- 	if show_type == 2 then
-- 		text = text ..":"..value
-- 	elseif show_type == 3 then
-- 		text =  text.."%" .. value
-- 	end
-- 	return text
-- end

--返回总描述集合
function VipData:GetVipPowerDescList(vip_id)
	local cfg = self:GetVipUpLevelCfg()
	for k,v in pairs(cfg) do
		if v.level == vip_id then
			return Split(v.desc, ",")
		end
	end
end

--获取当前VIP特权描述
function VipData:GetVipCurDescList(index)
	local cfg = self:GetVipUpLevelCfg()
	for k,v in pairs(cfg) do
		if v.level == index then
			return v
		end
	end
end

--获取当前VIP BUFF信息
function VipData:GetVipBuffData(vip_level)
	local cfg = self:GetVipUpLevelCfg()
	for k,v in pairs(cfg) do
		if v.level == vip_level then
			return Split(v.desc_buff, "\n")
		end
	end
end

-- 获取当前VIP BUFF的战力
function VipData:GetVipBuffFightPower(vip_level)
	local vip_buff_cfg = self:GetVipBuffCfg(vip_level)
	local role_vo = GameVoManager.Instance:GetMainRoleVo()
	local ratio = 0.0001
	local vip_buff_data = {}
	vip_buff_data.maxhp  = vip_buff_cfg.maxhp + vip_buff_cfg.maxhp_per * role_vo.max_hp * ratio
	vip_buff_data.gongji = vip_buff_cfg.gongji + vip_buff_cfg.gongji_per * role_vo.gong_ji * ratio
	vip_buff_data.fangyu = vip_buff_cfg.fangyu + vip_buff_cfg.fangyu_per * role_vo.fang_yu * ratio
	vip_buff_data.ice_master = vip_buff_cfg.ice_master
	vip_buff_data.fire_master = vip_buff_cfg.fire_master
	vip_buff_data.thunder_master = vip_buff_cfg.thunder_master
	vip_buff_data.poison_master = vip_buff_cfg.poison_master
	vip_buff_data.per_mianshang = vip_buff_cfg.mianshang_per
	
	return CommonDataManager.GetCapability(vip_buff_data)
end

--获取当前VIP信息
function VipData:GetVipInfoList(vip_level)
	local vip_info = self:GetVipRewardCfg()
	-- for k,v in pairs(vip_info) do
	-- 	if v.level == vip_level  then
	-- 		return v
	-- 	end
	-- end
	return vip_info[vip_level - 1]
end


--获取当前vip的奖励领取list
function VipData:GetRewardList(vip_id)
	if vip_id == 0 then
		vip_id = 1
	end

	local max_level = self:GetMaxVipLevel()
	if vip_id >= max_level then
		vip_id = max_level
	end
	
	local gift_cfg = ItemData.Instance:GetItemConfig(self:GetVipRewardCfg()[vip_id - 1].reward_item.item_id)
	local reward_list = {}
	for i=1, 8 do
		reward_list[i] = {}
		if i<= gift_cfg.item_num then
			reward_list[i].item_id = gift_cfg["item_" .. i .. "_id"]
			reward_list[i].item_num = gift_cfg["item_" .. i .. "_num"]
		else
			reward_list[i].item_id = 0
			reward_list[i].item_num = 0
		end
	end
	return reward_list
end

--返回当前vip的exp总值
function VipData:GetVipExp(vip_id)
	local total_gold = 0
	for i,v in ipairs(self:GetVipUpLevelCfg()) do
		total_gold = total_gold + v.need_gold
		if v.level == vip_id then
			return total_gold
		end
	end
	return 0
end

-- 是否可以传送
function VipData:GetIsCanFly(vip_level)
	vip_level = vip_level or 0
	local config = self:GetVipLevelCfg()
	if config then
		local auth_config = config[VIPPOWER.SCENE_FLY]
		if auth_config then
			if auth_config["param_" .. vip_level] == 1 then
				return true
			end
		end
	end
	return false
end

--是否可展示限时vip界面
function VipData:CanShowTempVipView()
	local flag = false
	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	local vip_level = main_vo.vip_level
	if next(self.vip_info) and vip_level <= 0 and not self.is_show_temp_vip then
		flag = true
	end
	return flag
end

--记录是否自己主动发送请求限时vip
function VipData:SetIsSendLimitVip()
	self.is_send_temp_vip = true
end

function VipData:GetIsSendTempVip()
	return self.is_send_temp_vip
end

function VipData:GetGiftEffectCfgById(vip_id)
	return self:GetVipRewardCfg()[vip_id - 1].item_effect
end

function VipData:GetMaxVipLevel()
	if self.vip_uplevel_cfg == nil then
		self.vip_uplevel_cfg = ListToMap(ConfigManager.Instance:GetAutoConfig("vip_auto").uplevel, "level")
	end
	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	local vip_level = main_vo.vip_level
	return self.vip_uplevel_cfg[vip_level].show_max_level or 0
end
