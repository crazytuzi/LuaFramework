MarriageData = MarriageData or BaseClass()

MarriageData.QINGYUAN_COUPLE_HALO_MAX_TYPE = 16				--光环最大类型

QINGYUAN_COUPLE_HALO_REQ_TYPE = {
	QINGYUAN_COUPLE_REQ_TYPE_INFO = 0,						-- 请求信息
	QINGYUAN_COUPLE_REQ_TYPE_USE = 1,						-- 装备光环 param_1光环类型
	QINGYUAN_COUPLE_REQ_TYPE_UP_LEVEL = 2,					-- 光环升级 param_1光环类型 param_2是否自动购买
}

function MarriageData:__init()
	if MarriageData.Instance then
		print_error("[MarriageData] Attempt to create singleton twice!")
		return
	end
	self.red_point_list = {
		["honeymoon_group"] = {
			["Ring"] = false,
			["Bless"] = false,
			["love_content"] = false,
			["lover"] = true,
		},
		["interact_group"] = {
			["halo_content"] = false,
			["love_tree"] = false,
		},
		["shengdi_group"] = {
			["shengdi_reward"] = true,
		},
	}

	MarriageData.Instance = self
	self:SetCfg()
	self:GetMarriageConditions()
	self.get_invite_data = {}
	self.marryuser_list = {}
	self.wedding_by_info = {}
	self.wedding_target_info = {
		wedding_type = 0,
		target_id = 0,
	}
	self.role_msg_info = {
		marry_type = 0,
		marry_count = 0,
		marry_state = 0,
		param_ch4 = 0,
	}
	self.invite_guests_info = {
		role_id = 0,
		lover_role_id = 0,
		wedding_type = 0,
		has_num = 0,
		can_num = 0,
		wedding_yuyue_seq = 0,
		count = 0,
		data = {},
	}
	self.is_use_bind_diamond = 2
	self.wedding_pledge_info = 0
	self.lover_level = 0
	self.lover_star = 0
	self.lover_ring_item_id = 0
	self.ring_item_id = 0
	self.self_hunyan_state = 0				--自己的婚宴状态
	self.paohuoqiu_times = nil

	self.love_tree_state = 0
	self.love_tree_info = {}
	self.wedding_info = {}
	self.applicant_info = {}
	self.tuodan_list = {}
	self.good_time_list = {}				--记录示好冷却时间
	self.send_tuo_dan_time = 0				--记录发送脱单宣言的时间

	self.qy_equip_info_list = {}
	self.my_wedding_type = 0
	self.yuyue_list_info = {}
	self.equip_select_index = 0				--情缘装备选择的格子

	self.guaji_setting_param = 0			--自动挂机参数
	self.select_time_seq = nil

	self.love_contract_info = {				-- 爱情契约信息数据
		self_love_contract_reward_flag = {},
		can_receive_day_num = -1,
		lover_love_contract_timestamp = 1,	-- 设置1表示没结婚之类的也隐藏掉按钮吧。
		leaveword_list = {},
	}

	self.hunyan_renqi_value_info = 0		-- 婚宴人气值
	self.rank_list = {}
	self.wedding_role_info = {}				-- 婚礼个人信息
	self.cur_wedding_info = {}				-- 当前婚礼信息
	self.task_info_list = {}
	self.bless_record_list = {				-- 祝福(日志)
		count = 0,
		bless_record_list = {},
	}
	self.hunyan_user_info = {}				-- 婚宴答题
	self.question_list = {}
	self.topic_answer = {}

	RemindManager.Instance:Register(RemindName.MarryRing, BindTool.Bind(self.GetRingRemind, self))
	RemindManager.Instance:Register(RemindName.MarryBless, BindTool.Bind(self.GetBlessRemind, self))
	RemindManager.Instance:Register(RemindName.MarryLoveContent, BindTool.Bind(self.GetLoveContentRemind, self))
	RemindManager.Instance:Register(RemindName.MarryLoveTree, BindTool.Bind(self.GetLoveTreeRemind, self))
	RemindManager.Instance:Register(RemindName.MarryShengDi, BindTool.Bind(self.GetShengDiRemind, self))
	RemindManager.Instance:Register(RemindName.MarryFuBen, BindTool.Bind(self.GetFuBenRemind, self))
	RemindManager.Instance:Register(RemindName.MarryCoupHalo, BindTool.Bind(self.GetHaloRemind, self))
	RemindManager.Instance:Register(RemindName.MarryQingShi, BindTool.Bind(self.GetQinShiRemind, self))
end

function MarriageData:__delete()
	RemindManager.Instance:UnRegister(RemindName.MarryRing)
	RemindManager.Instance:UnRegister(RemindName.MarryBless)
	RemindManager.Instance:UnRegister(RemindName.MarryLoveContent)
	RemindManager.Instance:UnRegister(RemindName.MarryLoveTree)
	RemindManager.Instance:UnRegister(RemindName.MarryShengDi)
	RemindManager.Instance:UnRegister(RemindName.MarryFuBen)
	RemindManager.Instance:UnRegister(RemindName.MarryCoupHalo)
	RemindManager.Instance:UnRegister(RemindName.MarryQingShi)
	MarriageData.Instance = nil
end

function MarriageData:GetMarryNpcCfg()
	local data = {}
	data.marry_npc_id = self.marriage_condition.marry_npc_id
	data.marry_npc_scene_id = self.marriage_condition.marry_npc_scene_id
	return data
end

--是否已婚
function MarriageData:CheckIsMarry()
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	if main_role_vo.lover_uid ~= nil and main_role_vo.lover_uid ~= 0 then
		return true
	end
	return false
end

--处理戒指红点
function MarriageData:RingRedPoint()
	local flag = self:GetRingInfo()
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	if main_role_vo.lover_uid <= 0 then
		flag = 0
	end
	self:HandleRedPoint("Ring", flag == 1)
end

--处理祝福红点
function MarriageData:BlessRedPoint()
	local had_buy, flag = self:GetBlessInfo()
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	if main_role_vo.lover_uid <= 0 then
		flag = 0
	end
	self:HandleRedPoint("Bless", flag == 1)
end

--处理爱情契约红点
function MarriageData:ChangeLoveContentRedPoint()
	local flag = self:GetQingyuanLoveContractReward()
	self:HandleRedPoint("love_content", flag)
end

--处理副本红点
-- function MarriageData:FuBenRedPoint()
-- 	local data = self:GetQingYuanFBInfo()
-- 	local num = 0
-- 	local flag = false
-- 	if data == nil or next(data) == nil then
-- 		return
-- 	end
-- 	if data.join_fb_times <= 0 then
-- 		num = data.buy_fb_join_times + 1
-- 	else
-- 		local des = data.buy_fb_join_times - data.join_fb_times
-- 		num = des >= 0 and des + 1 or 0
-- 	end
-- 	flag = num > 0 
-- 	self:HandleRedPoint("fuben", flag)
-- end

--获得是否显示红点
function MarriageData:GetShowRedPoint()
	local flag = false
	for k1, v1 in pairs(self.red_point_list) do
		for k2, v2 in pairs(v1) do
			if v2 then
				flag = true
				break
			end
		end
	end
	return flag
end

--获得相关红点
function MarriageData:GetRedPointByKey(key)

	local flag = false
	local temp_list = self.red_point_list[key]
	if temp_list then
		for k, v in pairs(temp_list) do
			if v then
				flag = true
				break
			end
		end
	else
		for _, v in pairs(self.red_point_list) do
			local temp_flag = v[key]
			if temp_flag ~= nil then
				flag = temp_flag
				break
			end
		end
	end
	return flag
end

--处理红点
function MarriageData:HandleRedPoint(key, value)
	for _, v in pairs(self.red_point_list) do
		if v[key] ~= nil then
			v[key] = value
			break
		end
	end
	-- local flag = self:GetShowRedPoint()
	-- MainUICtrl.Instance:ChangeRedPoint(MainUIData.RemindingName.Marriage, flag)
end

function MarriageData:SetCfg()
	local marriage_cfg = ConfigManager.Instance:GetAutoConfig("qingyuanconfig_auto")
	self.honeymoon_reward = marriage_cfg.honeymoon_reward
	self.marriage_condition = marriage_cfg.other[1]
	self.ring_upgrade_item = marriage_cfg.uplevel_stuff[1]
	self.wedding_type_cfg = marriage_cfg.marry_cfg
	self.hunli_cfg = marriage_cfg.hunli_type
	self.ring_cfg = marriage_cfg.uplevel
	self.honeymoon_reward = marriage_cfg.honeymoon_reward[1]
	self.bless_price = marriage_cfg.bless_price[1]
	self.divorce_cost = marriage_cfg.other[1].divorce_coin_cost						--强制离婚所需的花费的绑元
	self.divorce_intimacy_dec = marriage_cfg.other[1].divorce_intimacy_dec			--离婚会扣除的亲密度
	self.qingyuan_fb_buff = marriage_cfg.qingyuan_fb_buff[1]
	self.hunyan_activity = marriage_cfg.hunyan_activity[1]
	self.hunyan_cfg = marriage_cfg.hunyan_cfg[1]
	self.qingyuan_fb_reward = marriage_cfg.qingyuan_fb_reward
	self.tuodan_cfg = marriage_cfg.tuodan_list
	self.mode_show = marriage_cfg.mode_show
	self.marriage_blessing = marriage_cfg.wedding_blessing							-- 结婚祝福配置
	self.couple_halo_cfg = ListToMap(marriage_cfg.couplehalo_cfg, "halo_type", "level")
	self.question_npc_pos = ListToMap(marriage_cfg.question_npc_pos, "index")
	self.question_npc = ListToMap(marriage_cfg.npc, "question_idx")
	self.question = ListToMap(marriage_cfg.question, "question_id")

	local love_tree_cfg = ConfigManager.Instance:GetAutoConfig("lovetreeconfig_auto")
	self.love_tree_level_cfg = love_tree_cfg.love_tree_level_cfg
	self.love_tree_other_cfg = love_tree_cfg.other_cfg
	self.qy_quality_cfg = marriage_cfg.quality_cfg
	self.qy_level_cfg = marriage_cfg.level_cfg
	self.qy_cfg_equip = marriage_cfg.equip_cfg or {}

	self.wedding_liveness_cfg = marriage_cfg.wedding_liveness

	local sheng_di_cfg = ConfigManager.Instance:GetAutoConfig("qingyuanshengdiconfig_auto")
	self.sheng_di_other = sheng_di_cfg.other[1]
	self.sheng_di_layer = sheng_di_cfg.layer
	self.sheng_di_task2 = ListToMap(sheng_di_cfg.task, "task_id")
	self.sheng_di_task = sheng_di_cfg.task
	self.sheng_di_monster = ListToMap(sheng_di_cfg.monster, "layer", "pos_type", "monster_id")
	self.sheng_di_pos = ListToMapList(sheng_di_cfg.pos, "pos_type")
	self.sheng_di_gather = sheng_di_cfg.gather
end

------------------婚礼-------------------------------
-- 根据职业获取模型配置
function MarriageData:GetModelCfgById(prof)
	local model_data = {}
	for k,v in pairs(self.mode_show) do
		if v.id == prof then
			model_data = v
			break
		end
	end
	return model_data
end

function MarriageData:GetHunLiData()
	return self.hunli_cfg
end

function MarriageData:GetHunliInfoByType(hunli_type)
	local hunli_info = {}
	for k, v in ipairs(self.hunli_cfg) do
		if hunli_type == v.hunli_type then
			hunli_info = v
			break
		end
	end
	return hunli_info
end

function MarriageData:CostEnoughByHunliType(hunli_type)
	local cost_enough = false
	local is_bind_gold = false
	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	local day = TimeCtrl.Instance:GetCurOpenServerDay()
	for k, v in ipairs(self.hunli_cfg) do
		if v.hunli_type == hunli_type then
			if v.need_bind_gold > 0 then
				local bind_gold = main_vo.bind_gold
				local gold = main_vo.gold
				local cost_gold = day <= 7 and v.openserver_discount or v.need_bind_gold
				cost_enough = (bind_gold >= cost_gold) or (gold >= cost_gold)
				is_bind_gold = true
			else
				local gold = main_vo.gold
				local cost_gold = day <= 7 and v.openserver_discount or v.need_gold
				cost_enough = (gold >= cost_gold)
			end
			break
		end
	end

	local is_qixi_open = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_QIXI_MARRIAGE) -- 七夕活动
	if is_qixi_open then
		if QiXiMarriageData:GetHunLiOtherCfg() and hunli_type == 2 then 
			local gold = main_vo.gold
			local qixi_hunli_cfg = QiXiMarriageData:GetHunLiOtherCfg()[hunli_type + 1]
			cost_enough = (gold >= qixi_hunli_cfg.marry_gold)
		end
	end
	return cost_enough, is_bind_gold
end

function MarriageData:GetMarryLevelLimit()
	return self.marriage_condition.marry_limit_level
end

function MarriageData:GetMarryIntimacyLimit()
	return self.marriage_condition.marry_limit_intimacy
end

function MarriageData:GetHunliEquipReward()
	return self.marriage_condition.hunjie_item
end

--设置求婚者信息
function MarriageData:SetReqWeddingInfo(protocol)
	self.wedding_by_info = protocol
end

function MarriageData:GetReqWeddingInfo()
	return self.wedding_by_info
end

function MarriageData:SetWeddingTargetInfo(marry_type, uid)
	self.wedding_target_info.wedding_type = marry_type
	self.wedding_target_info.target_id = uid
end

function MarriageData:GetWeddingTargetInfo()
	return self.wedding_target_info
end

function MarriageData:SetWeddingPledgeInfo(pledge)
	self.wedding_pledge_info = pledge
end

function MarriageData:GetWeddingPledgeInfo()
	return self.wedding_pledge_info
end
-----------------结婚/离婚---------------------------
--获取结婚条件
function MarriageData:GetMarriageConditions()
	return self.marriage_condition
end

--获取强制离婚需要花费的钻石
function MarriageData:GetDivorceCost()
	return self.divorce_cost
end

--获取离婚会扣除的亲密度
function MarriageData:GetIntimacyCost()
	return self.divorce_intimacy_dec
end

--------------------蜜月祝福--------------------
--同步祝福信息
function MarriageData:SyncBlessInfo(protocol)
	self.had_get_bless_reward = protocol.is_fetch_bless_reward
	self.bless_days = protocol.bless_days
	self.lover_bless_days = protocol.lover_bless_days
	-- self:BlessRedPoint()
end

--获取祝福的Cfg
function MarriageData:GetBlessCfg()
	return self.bless_price
end

--获取祝福的每日奖励
function MarriageData:GetHoneymoonReward()
	return self.honeymoon_reward
end

--获取自己祝福有效时间
function MarriageData:GetSelfBlessDays()
	return self.bless_days
end

--获取伴侣祝福有效时间
function MarriageData:GetLoverBlessDays()
	return self.lover_bless_days
end

--是否已领取每日祝福奖励
function MarriageData:GetHadGetBlessReward()
	if self.had_get_bless_reward == 1 then
		return true
	else
		return false
	end
end

--获取剩余的祝福日子
function MarriageData:GetBlessDay()
	return self.bless_days
end

--获取祝福信息
function MarriageData:GetBlessInfo()
	local had_buy = false
	local flag = -1
	if self.bless_days > 0 then
		--购买了祝福奖励
		had_buy = true
		if self.had_get_bless_reward == 1 then
			--已领取奖励
			flag = 0
		else
			--未领取奖励-可领取
			flag = 1
		end
	else
		--未购买祝福奖励
		if self.lover_bless_days > 0 then
			--伴侣有买祝福
			flag = 2
		else
			--伴侣没有买祝福
			flag = 3
		end
	end
	return had_buy, flag
end

--------------------蜜月戒指--------------------
--同步戒指信息
function MarriageData:SyncRingInfo(protocol)
	self.sonsume_num = protocol.consume_num
	self.baoji_num = protocol.baoji_num
	self.ring_exp = protocol.exp
	self.ring_star = protocol.star
	self.lover_level = protocol.lover_level or 0
	self.lover_ring_item_id = protocol.lover_ring_item_id or 0
	self.ring_item_id = protocol.ring_item_id or 0
	self.lover_star = protocol.lover_star or 0
	self.lover_prof = protocol.lover_prof or 0
end

--同步伴侣信息
function MarriageData:OnQingyuanLoverInfo(protocol)
	self.lover_level = protocol.lover_level or 0
	self.lover_ring_item_id = protocol.lover_ring_item_id or 0
	self.lover_star = protocol.lover_star or 0
end

--获取强化后返回的信息
function MarriageData:GetRingUpgradeInfo()
	local info = {}
	local upgrade_item = self.ring_upgrade_item
	local item_cfg = ItemData.Instance:GetItemConfig(upgrade_item.stuff_id)
	info.name = item_cfg.name
	info.num = self.sonsume_num
	info.baoji_num = self.baoji_num
	return info
end

--获取戒指是否激活
function MarriageData:GetRingHadActive()
	return self.ring_item_id ~= 0
end

--获取戒指经验
function MarriageData:GetRingExp()
	return self.ring_exp
end

--获取戒指升级材料
function MarriageData:GetRingUpgradeItem()
	return self.ring_upgrade_item
end

--是否有足够的钱升级婚戒
function MarriageData:EnoughMoneyToUpRing()
	local can_up_level = false
	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	local item_id = self.ring_upgrade_item.stuff_id
	local shop_item_info = ShopData.Instance:GetShopItemCfg(item_id)
	if not shop_item_info then
		return can_up_level
	end
	if shop_item_info.gold > 0 and main_vo.gold > shop_item_info.gold then
		can_up_level = true
	elseif shop_item_info.bind_gold > 0 and main_vo.bind_gold > shop_item_info.bind_gold then
		can_up_level = true
	end
	return can_up_level
end

--获取1级戒指Cfg
function MarriageData:GetLevelOneRingCfg()
	return self.ring_cfg[1]
end

--获取伴侣职业
function MarriageData:GetLoverProf()
	return self.lover_prof
end

--获取戒指Cfg和戒指是否满级
function MarriageData:GetRingCfg()
	local is_max = true
	local match_cfg = nil
	for k,v in pairs(self.ring_cfg) do
		if match_cfg == nil then
			if self.ring_star == v.star and self.ring_item_id == v.equip_id then
				match_cfg = v
			end
		else
			is_max = false
			break
		end
	end
	return match_cfg, is_max
end

function MarriageData:GetNextRingCfg()
	local match_cfg = nil
	for k,v in pairs(self.ring_cfg) do
		if v.equip_id == self.ring_item_id then
			if v.star > self.ring_star then
				match_cfg = v
				break
			end
		elseif v.equip_id > self.ring_item_id then
			if v.star == 1 and self.ring_star == 10 then
				match_cfg = v
				break
			end
		end
	end
	return match_cfg
end

--获取戒指信息
function MarriageData:GetRingInfo()
	if self.ring_item_id ~= 0 then
		--戒指已激活
		local had_num = ItemData.Instance:GetItemNumInBagById(self.ring_upgrade_item.stuff_id)
		if had_num > 0 then
			--够材料
			local ring_cfg, is_max = self:GetRingCfg()
			if is_max then
				--满级
				return 0
			else
				--未满级-可升级
				return 1
			end
		else
			--不够材料
			return 2, self.ring_upgrade_item.stuff_id
		end
	else
		--戒指未激活
		return 3
	end
end

--获取伴侣等级
function MarriageData:GetLoverLevel()
	return self.lover_level or 0
end

--获取伴侣戒指等级
function MarriageData:GetLoverStar()
	local level = 0
	local lover_star = self.lover_star
	if lover_star < 0 then
		lover_star = 0
	end

	if self.lover_ring_item_id <= 0 then
		return 0
	end
	
	local _, big_lev = math.modf(self.lover_ring_item_id/100)
	big_lev = string.format("%.2f", big_lev or 0) * 1000
	level = big_lev + tonumber(lover_star)

	return level
end

------------------------预约时间-----------------------
-- 获取预约时间配置信息
function MarriageData:GetMarryYuYueCfg()
	local yuyue_cfg = {}

	local wedding_yuyue_time = ConfigManager.Instance:GetAutoConfig("qingyuanconfig_auto").wedding_yuyue_time

	for k,v in ipairs(wedding_yuyue_time) do
		local time_table = os.date("*t", TimeCtrl.Instance:GetServerTime())
		local data = TableCopy(v)
		local time = os.time({year=time_table.year, month=time_table.month, day=time_table.day, hour=math.floor(v.apply_time / 100), min=v.apply_time % 100, sec=0})
		-- data.is_yuyue = self:GetYuYueListInfo(v.seq)
		if self:GetYuYueListInfo(v.seq) > 0 then
			data.is_yuyue = TimeCtrl.Instance:GetServerTime() > time and 0 or 1
		else
			data.is_yuyue = 0
		end
		data.yuyue_time = TimeCtrl.Instance:GetServerTime() > time and 1 or 0
		yuyue_cfg[#yuyue_cfg + 1] = data
	end
	table.sort(yuyue_cfg, self:MarryYuYueListSorters("yuyue_time", "is_yuyue", "seq"))
	return yuyue_cfg
end

function MarriageData:GetMarryYuYueTime()
	return ConfigManager.Instance:GetAutoConfig("qingyuanconfig_auto").wedding_yuyue_time
end

function MarriageData:MarryYuYueListSorters(sort_key_name1, sort_key_name2, sort_key_name3)
	return function(a, b)
		local order_a = 100000
		local order_b = 100000
		if a[sort_key_name1] > b[sort_key_name1] then
			order_a = order_a + 10000
		elseif a[sort_key_name1] < b[sort_key_name1] then
			order_b = order_b + 10000
		end

		if nil == sort_key_name2 then  return order_a < order_b end

		if a[sort_key_name2] < b[sort_key_name2] then
			order_a = order_a + 1000
		elseif a[sort_key_name2] > b[sort_key_name2] then
			order_b = order_b + 1000
		end

		if nil == sort_key_name3 then  return order_a < order_b end

		if a[sort_key_name3] > b[sort_key_name3] then
			order_a = order_a + 100
		elseif a[sort_key_name3] < b[sort_key_name3] then
			order_b = order_b + 100
		end

		return order_a < order_b
	end
end

function MarriageData:InviteListData(friend_list, data)
	local vo = GameVoManager.Instance:GetMainRoleVo()
	local friend_data = {}
	for k,v in pairs(friend_list) do
		if v.is_online == 1 and vo.lover_uid ~= v.user_id  then
			v.list_type = 1
			table.insert(friend_data, v)
		end
	end

	if data and next(data) then
		for k = #friend_data, 1, -1 do
			for k2,v2 in pairs(data) do
				if friend_data[k] then
					if friend_data[k].user_id == v2.user_id then
						table.remove(friend_data, k)
					end
				end
			end
		end
	end

	return friend_data
end

function MarriageData:SetYuYueRoleInfo(protocol)
	self.role_msg_info.marry_type = protocol.param_ch1
	self.role_msg_info.marry_count = protocol.param_ch2
	self.role_msg_info.marry_state = protocol.param_ch3
	self.role_msg_info.param_ch4 = protocol.param_ch4
end

function MarriageData:GetYuYueRoleInfo()
	return self.role_msg_info
end

--主人获取宾客信息
function MarriageData:SetInviteGuests(protocol)
	self.invite_guests_info.role_id = protocol.role_id
	self.invite_guests_info.lover_role_id = protocol.lover_role_id
	self.invite_guests_info.wedding_type = protocol.wedding_type
	self.invite_guests_info.has_num = protocol.has_invite_guests_num
	self.invite_guests_info.can_num = protocol.can_invite_guest_num
	self.invite_guests_info.wedding_yuyue_seq = protocol.wedding_yuyue_seq
	self.invite_guests_info.count = protocol.count
	self.invite_guests_info.data = protocol.guests_list
end

function MarriageData:GetInviteGuests()
	return self.invite_guests_info
end

function MarriageData:SetYuYueListInfo(protocol)
	self.my_wedding_type = protocol.param_ch1
	self.yuyue_list_info = bit:d2b(protocol.param2)
end

function MarriageData:GetMyWeddingType()
	return self.my_wedding_type
end

function MarriageData:SetHaveApplicantInfo(protocol)
	self.applicant_info = protocol.guests_list
end

function MarriageData:GetHaveApplicantInfo()
	return self.applicant_info
end

function MarriageData:GetYuYueListInfo(seq)
	return self.yuyue_list_info[32 - seq] or -1
end

function MarriageData:SetYanHuiType(type)
	self.is_use_bind_diamond = type
end

function MarriageData:GetSelectYanHuiType()
	return self.is_use_bind_diamond
end

--------------------婚宴--------------------
--同步婚宴信息
function MarriageData:OnWeddingInfo(protocol)
	self.is_first = protocol.is_first_diamond
	self.guest_list = protocol.guest_list
	self.hunyan_state = protocol.hunyan_state
	self.next_state_timestmp = protocol.next_state_timestmp
	self.fb_key = protocol.fb_key
	self.yanhui_type = protocol.yanhui_type
	self.is_self_hunyan = protocol.is_self_hunyan
	self.paohuoqiu_times = protocol.paohuoqiu_times
	self.marryuser_list = protocol.marryuser_list
	self.wedding_info = protocol
	self:ChangeHunYanState()
end

function MarriageData:GetPaohuoqiu_times()
	return self.paohuoqiu_times
end

function MarriageData:GetHunYanCfg()
	return self.hunyan_cfg
end

function MarriageData:GetMarryUserList()
	return self.cur_wedding_info.marryuser_list
end

function MarriageData:GetWeddingInfo()
	return self.wedding_info
end

-- 婚礼信息
function MarriageData:SetCurWeddingInfo(protocol)
	self.cur_wedding_info.marryuser_list = protocol.marryuser_list
	self.cur_wedding_info.seq = protocol.cur_wedding_seq
	self.cur_wedding_info.wedding_index = protocol.wedding_index
	self.cur_wedding_info.count = protocol.count
	self.cur_wedding_info.data = protocol.guests_uid
end

function MarriageData:GetCurWeddingInfo()
	return self.cur_wedding_info
end

------------------获取婚礼礼包数据---------------------
function MarriageData:GetRewardItemData(seq)
	local reward_item_list = {}
	local marry_cfg = ListToMap(ConfigManager.Instance:GetAutoConfig("qingyuanconfig_auto").marry_cfg, "marry_type")
	return marry_cfg[seq].reward_id_1
end

function MarriageData:GetYuYueTime(seq)
	local wedding_cfg = {}
	for k,v in pairs(ConfigManager.Instance:GetAutoConfig("qingyuanconfig_auto").wedding_yuyue_time) do
		if seq == v.seq then
			wedding_cfg = v
		end
	end
	return wedding_cfg
end

--判断是否免费抛花球
function MarriageData:IsFreePaoHuaQiu()
	local free_count = 0
	if self.yanhui_type == 1 then  --绑定
		free_count = self.hunyan_activity.paohuaqiu_free_times_1
	else
		free_count = self.hunyan_activity.paohuaqiu_free_times_2
	end
	return (self.paohuoqiu_times >= free_count)
end
--获取抛喜糖元宝
function MarriageData:GetHuaQiuGold()
	return self.hunyan_activity.paohuaqiu_need_gold
end

function MarriageData:ChangeHunYanState()
	if self.is_self_hunyan == 1 then
		self.self_hunyan_state = self.hunyan_state
	end
end

function MarriageData:GetIsFirstDiamond()
	return (self.is_first == 1)
end

--是否婚宴主人
function MarriageData:IsMarryUser()
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	for k, v in ipairs(self.marryuser_list) do
		if main_role_vo.role_id == v.marry_uid then
			return true
		end
	end
	return false
end

function MarriageData:GetFbKey()
	return self.fb_key
end

function MarriageData:GetYanHuiType()
	return self.yanhui_type
end

--获取婚宴持续时间
function MarriageData:GetWeedingTime()
	if self.next_state_timestmp == nil then
		return 0
	end
	
	return self.next_state_timestmp - TimeCtrl.Instance:GetServerTime()
end

function MarriageData:GetWeddingCfgByType(marry_type)
	for k,v in pairs(self.wedding_type_cfg) do
		if v.marry_type == marry_type then
			return v
		end
	end
end

local function Sort_InviteList(a, b)
	if a.garden_num < b.garden_num then
		return true
	end
end

--设置被邀请数据
function MarriageData:SetGetInviteData(protocol)
	self.get_invite_data = protocol.invite_list
	table.sort(self.get_invite_data, Sort_InviteList)
end

--获取被邀请数据
function MarriageData:GetGetInviteData()
	return self.get_invite_data
end

--获取婚宴行为数据
function MarriageData:GetActivityCfg()
	return self.hunyan_activity
end

--是否正在举办婚宴
function MarriageData:GetIsHoldingWeeding()
	return self.self_hunyan_state == 2
end

--获取所有参与婚宴客人的ID
function MarriageData:GetAllGuests()
	return self.guest_list
end

--获取已开启的婚宴副本编号
function MarriageData:GetFuBenKey()
	return self.fb_key
end

function MarriageData:GetHunYanReward(is_bind)
	local reward_data = {}
	if is_bind then
		reward_data = self.marriage_condition.bind_gold_hy_reward_item
	else
		reward_data = self.marriage_condition.gold_hy_reward_item
	end
	return reward_data
end

--------------------情缘副本--------------------
--接受情缘副本信息
function MarriageData:SetQingYuanFBInfo(data)
	self.qingyaun_fb_info = data
	self.yanhui_fb_key = data.yanhui_fb_key
	-- self:FuBenRedPoint()
end

--获取情缘副本信息
function MarriageData:GetQingYuanFBInfo()
	return self.qingyaun_fb_info
end

--获取情缘副本Buff信息
function MarriageData:GetQingYuanFBBuffInfo()
	return self.qingyuan_fb_buff
end

--获取情缘副本奖励
function MarriageData:GetQingYuanFBReward()
	local list = {}
	for k,v in pairs(self.qingyuan_fb_reward) do
		if list[v.stuff_id] == nil then
			list[v.stuff_id] = v
		end
	end
	return list
end

--副本获得奖励
function MarriageData:GetQingYuanFBPassReward()
	return self.qingyuan_fb_reward[1].stuff_id
end

--------------------光环--------------------

function MarriageData:GetHaloScrollerData()
	local marriage_cfg = ConfigManager.Instance:GetAutoConfig("qingyuanconfig_auto")
	local data = {}
	for k,v in pairs(marriage_cfg.couplehalo_cfg) do
		if data[v.halo_type] == nil then
			local tmp = TableCopy(v)
			tmp.is_active = self:GetHaloIsAvtive(v.halo_type)
			tmp.level = 99--ToDo目前不用等级
			tmp.is_wearing = (self.halo_info.equiped_couple_halo_type == v.halo_type)
			data[tmp.halo_type] = tmp
		end
	end
	return data
end

function MarriageData:GetHaloSpiritData(halo_type)
	local marriage_cfg = ConfigManager.Instance:GetAutoConfig("qingyuanconfig_auto")
	local data = {}
	for k,v in pairs(marriage_cfg.couplehalo_cfg) do
		if v.halo_type == halo_type then
			local tmp = TableCopy(v)
			local halo_tbl = self.halo_info.couple_halo_activate_status_list[halo_type] or {}
			local spirit_activite_value = halo_tbl[v.icon_index + 1] or 0
			tmp.is_active = spirit_activite_value == 1
			tmp.can_upgrade = (ItemData.Instance:GetItemNumInBagById(v.stuff_id) > 0)
			table.insert(data, tmp)
		end
	end
	return data
end

function MarriageData:OnHaloInfo(protocol)
	self.halo_info = protocol
end

function MarriageData:GetHaloIsAvtive(halo_type)
	local halo_tbl = self.halo_info.couple_halo_activate_status_list[halo_type] or {}
	for k,v in pairs(halo_tbl) do
		if v == 0 then
			return false
		end
	end
	return true
end

function MarriageData:GetHaloIsWearing(halo_type)
	return (self.halo_info.equiped_couple_halo_type == halo_type)
end

function MarriageData:GetSpiritIsAvtive(halo_type, spirit_index)
	local halo_tbl = self.halo_info.couple_halo_activate_status_list[halo_type] or {}
	local spirit_activite_value = halo_tbl[spirit_index] or 0
	return spirit_activite_value == 1
end

function MarriageData:GetSpiritActiveUseNum(halo_type, spirit_index)
	for k,v in pairs(self.halo_info.use_item_num_list) do
		if v.halo_id == halo_type and v.spirit_id == spirit_index then
			return v.active_num
		end
	end
end

function MarriageData:GetSpiritPower(halo_type, spirit_index)
	local marriage_cfg = ConfigManager.Instance:GetAutoConfig("qingyuanconfig_auto")
	for k,v in pairs(marriage_cfg.couplehalo_cfg) do
		if v.halo_type == halo_type then
			if (v.icon_index + 1) == spirit_index then
				local power = CommonDataManager.GetCapabilityCalculation(v)
				return power
			end
		end
	end
end

function MarriageData:GetHaloTotalAttr()
	local marriage_cfg = ConfigManager.Instance:GetAutoConfig("qingyuanconfig_auto")
	local total_attr = CommonStruct.Attribute()
	for k,v in pairs(self.halo_info.couple_halo_activate_status_list) do
		for k2,v2 in pairs(v) do
			if v2 == 1 then
				for k3,v3 in pairs(marriage_cfg.couplehalo_cfg) do
					if v3.halo_type == k and (v3.icon_index + 1) == k2 then
						local attr = CommonDataManager.GetAttributteByClass(v3)
						total_attr = CommonDataManager.AddAttributeAttr(total_attr, attr)
					end
				end
			end
		end
	end
	for k in pairs(total_attr) do
		if k == "bao_ji" or k == "jian_ren" then
			total_attr[k] = -1
		end
	end
	return total_attr
end

--处理光环红点
function MarriageData:ChangeHaloRedPoint()
	
end

------------------------相思树----------------------------------
function MarriageData:GetTreeInfo(level)
	local tree_info = {}
	for k, v in ipairs(self.love_tree_level_cfg) do
		if level == v.tree_star then
			tree_info = v
			break
		end
	end
	return tree_info
end

function MarriageData:GetLoverTreeLevelFristInfo()
	return self.love_tree_level_cfg[1]
end

function MarriageData:GetTreeCfg()
	return self.love_tree_other_cfg[1]
end

--获取树的归属
function MarriageData:GetTreeState()
	return self.love_tree_state
end

--设置相思树的信息
function MarriageData:SetLoveTreeInfo(protocol)
	self.love_tree_info = protocol
	self.love_tree_state = protocol.is_self 				--设置树的归属
end

function MarriageData:GetLoveTreeInfo()
	return self.love_tree_info
end

--处理相思树红点
function MarriageData:SetLoveTreeRedPoint()
	local state = false
	--检测功能是否开启
	-- local is_open = OpenFunData.Instance:CheckIsHide("marriage_love_tree")
	-- if not is_open then
	-- 	self:HandleRedPoint("love_tree", false)
	-- 	return
	-- end

	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	local self_free_water_time = self.love_tree_other_cfg[1].self_free_water_time
	local assist_free_water_time = self.love_tree_other_cfg[1].assist_free_water_time

	local free_water_self = self.love_tree_info.free_water_self
	local free_water_other = self.love_tree_info.free_water_other

	local self_item_data = {}
	local self_item_id = 0
	local self_num = 0

	local other_item_data = {}
	local other_item_id = 0
	local other_num = 0

	local self_level = self.love_tree_info.love_tree_star_level
	local other_level = self.love_tree_info.other_love_tree_star_level


	if self.love_tree_state == 1 then
		self_item_data = self:GetTreeInfo(self_level)
		other_item_data = self:GetTreeInfo(other_level)
	else
		self_item_data = self:GetTreeInfo(other_level)
		other_item_data = self:GetTreeInfo(self_level)
	end 

	local self_up_star_item_data = self_item_data.female_up_star_item or {}
	local other_up_star_item_data = other_item_data.male_up_star_item or {}

	self_item_id = self_up_star_item_data.item_id or 0
	self_num = self_up_star_item_data.num or 0

	other_item_id = other_up_star_item_data.item_id or 0
	other_num = other_up_star_item_data.num or 0

	if main_vo.sex == 1 then
		self_up_star_item_data = self_item_data.male_up_star_item or {}
		other_up_star_item_data = other_item_data.female_up_star_item or {}

		self_item_id = self_up_star_item_data.item_id or 0
		self_num = self_up_star_item_data.num or 0

		other_item_id = other_up_star_item_data.item_id or 0
		other_num = other_up_star_item_data.num or 0
	end
	
	local self_item_num = ItemData.Instance:GetItemNumInBagById(self_item_id)
	local other_item_num = ItemData.Instance:GetItemNumInBagById(other_item_id)

	-- if free_water_self and free_water_self < self_free_water_time or self_item_num >= self_num self_level ~= 100 then	--先判断自己是否有免费次数
	-- 	state = true																									--再判断自己所需物品是否足够
	-- elseif main_vo.lover_uid <= 0 then											--没结婚不考虑伴侣
	-- 	state = false
	-- elseif free_water_other and free_water_other < assist_free_water_time then	--先判断是否可以帮伴侣免费浇水
	-- 	state = true
	-- elseif other_item_num >= other_num then										--再判断伴侣所需的物品是否足够
	-- 	state = true
	-- end

	if free_water_self and self_level < 100 then
		if free_water_self < self_free_water_time or self_item_num >= self_num then
			state = true
		end
	end
	
	if free_water_other and main_vo.lover_uid > 0 and other_level < 100 then
		if free_water_other < assist_free_water_time or other_item_num >= other_num then
			state = true
		end
	end

	self:HandleRedPoint("love_tree", state)
end

--是否相思树所需要消耗的物品
function MarriageData:IsLoverTreeItemById(item_id)
	if item_id == self.love_tree_level_cfg[1].male_up_star_item.item_id or item_id == self.love_tree_level_cfg[1].female_up_star_item.item_id then
		return true
	end
end

-------------------我要脱单-----------------------------
function MarriageData:SetAllTuoDanList(protocol)
	self.tuodan_list = protocol.tuodan_list
end

function MarriageData:ChangeTuoDanList(protocol)
	local tuodan_info = protocol.tuodan_info
	if not next(tuodan_info) then
		return
	end
	if protocol.operate_type == TUODAN_OPERA_TYPE.TUODAN_INSERT then
		local up_date = false
		for k, v in ipairs(self.tuodan_list) do
			if v.uid == tuodan_info.uid then
				self.tuodan_list[k] = tuodan_info
				up_date = true
				break
			end
		end
		if not up_date then
			table.insert(self.tuodan_list, tuodan_info)
		end
	else
		local uid = tuodan_info.uid
		for k, v in ipairs(self.tuodan_list) do
			if uid == v.uid then
				table.remove(self.tuodan_list, k)
			end
		end
	end
end

function MarriageData:RemoveTuoDanInfoMySelf()
	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	for k, v in ipairs(self.tuodan_list) do
		if main_vo.role_id == v.uid then
			table.remove(self.tuodan_list, k)
		end
	end
end

function MarriageData:GetAllTuoDanList(is_other_sex)
	local temp_tuodan_list = {}
	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	for k, v in ipairs(self.tuodan_list) do
		if is_other_sex then
			if main_vo.sex ~= v.sex then
				table.insert(temp_tuodan_list, v)
			end
		else
			table.insert(temp_tuodan_list, v)
		end
	end
	return temp_tuodan_list
end

function MarriageData:IsInTuoDanList()
	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	for k, v in ipairs(self.tuodan_list) do
		if main_vo.role_id == v.uid then
			return true
		end
	end
	return false
end

--获取随机示好消息
function MarriageData:GetTuoDanDes()
	local count = #self.tuodan_cfg
	local index = math.random(1, count)
	return self.tuodan_cfg[index].des
end

--设置示好冷却时间
function MarriageData:AddSendGoodTimeList(role_id)
	local server_time = TimeCtrl.Instance:GetServerTime()
	self.good_time_list[role_id] = server_time
end

function MarriageData:GetSendGoodTime(role_id)
	return self.good_time_list[role_id]
end

function MarriageData:SetSendTuoDanTime()
	self.send_tuo_dan_time = TimeCtrl.Instance:GetServerTime()
end

function MarriageData:GetSendTuoDanTime()
	return self.send_tuo_dan_time
end

---------------------------情缘装备-----------------------
-- 设置缘装备位置信息
function MarriageData:SetQingYuanEquipInfo(info_list)
	self.qy_equip_info_list = info_list
end

-- 获取缘装备位置信息
function MarriageData:GetQyEquipInfoList()
	return self.qy_equip_info_list
end

-- 获取某情缘装备位置信息
function MarriageData:GetQyEquipInfoBySlot(index)
	if nil ~= index and self.qy_equip_info_list then
		return self.qy_equip_info_list[index]
	end
	return nil
end

-- 获取某位置是否有情缘装备
function MarriageData:CheckHasEquipBySlot(index)
	if nil == index then return false end
	local equip_info = self.qy_equip_info_list[index]
	if equip_info and equip_info.item_id > 0 then
		return true
	end
	return false
end

local function SortEquipList(a, b)
	local item_a_data = MarriageData.Instance:GetEquipCfgById(a.item_id) or {}
	local item_b_data = MarriageData.Instance:GetEquipCfgById(b.item_id) or {}

	if not next(item_a_data) or not next(item_b_data) then
		return false
	end

	if item_a_data.quality > item_b_data.quality then
		return true
	end
end

--获取某位置可融合的装备列表
function MarriageData:GetQualityListByIndex(index)
	local quality_list = {}
	local select_equip_info = self:GetQyEquipInfoBySlot(index)
	if not select_equip_info then
		return quality_list
	end

	local qingyuan_equip_list = self:GetAllQingYuanEquipList()
	for k, v in ipairs(qingyuan_equip_list) do
		local equip_data = self:GetEquipCfgById(v.item_id)
		if index - 1 == equip_data.slot_idx and select_equip_info.quality < equip_data.quality then
			table.insert(quality_list, v)
		end
	end
	table.sort(quality_list, SortEquipList)
	return quality_list
end

--获取一个装备是否可用于当前部位升级
function MarriageData:CanUpLevelByItemId(index, item_id)
	local can_up_level = true
	local have_equip = self:CheckHasEquipBySlot(index)
	if have_equip then
		--满级不显示
		local equip_data = self:GetQyEquipInfoBySlot(index)
		if equip_data.level >= 100 then
			return false
		end
		
		for i = 1, 4 do
			if not can_up_level then
				break
			end
			if i ~= index then
				local quality_list = self:GetQualityListByIndex(i)
				for k, v in ipairs(quality_list) do
					if item_id == v.item_id then
						can_up_level = false
						break
					end
				end
			end
		end
	else
		if not self:IsEquipByIndex(item_id, index) then
			can_up_level = false
		end
	end
	return can_up_level
end

--获取可用于升级当前装备的装备列表
function MarriageData:GetCanUpLevelEquipList(index)
	local temp_equip_list = {}
	local have_equip = self:CheckHasEquipBySlot(index)
	if have_equip then
		--满级不显示
		local equip_data = self:GetQyEquipInfoBySlot(index)
		if equip_data.level >= 100 then
			return temp_equip_list
		end
	end

	local all_equip_list = self:GetAllQingYuanEquipList()
	for k, v in ipairs(all_equip_list) do
		local is_remove = false
		for i = 1, 4 do
			if is_remove then
				break
			end
			if i ~= index then
				local quality_list = self:GetQualityListByIndex(i)
				for k1, v1 in ipairs(quality_list) do
					if v1.item_id == v.item_id then
						is_remove = true
						break
					end
				end
			end
		end

		--没装备统一把不属于自己的装备去掉
		if not have_equip and not self:IsEquipByIndex(v.item_id, index) then
			is_remove = true
		end

		if not is_remove then
			table.insert(temp_equip_list, v)
		end
	end
	return temp_equip_list
end

--判断是否该位置所属装备
function MarriageData:IsEquipByIndex(item_id, index)
	local equip_data = self:GetEquipCfgById(item_id) or {}
	if equip_data.slot_idx == index - 1 then
		return true
	end
	return false
end

--从背包获取情缘装备列表
function MarriageData:GetAllQingYuanEquipList()
	local equip_list = {}
	local bag_list = ItemData.Instance:GetBagItemDataList()
	for k, v in pairs(bag_list) do
		if self:GetEquipCfgById(v.item_id) then
			table.insert(equip_list, v)
		end
	end
	table.sort(equip_list, SortEquipList)
	return equip_list
end

-- 根据id获取情缘装备配置
function MarriageData:GetEquipCfgById(id)
	if nil == id then return end
	for _,v in pairs(self.qy_cfg_equip) do
		if v and v.item_id == id then
			return v
		end
	end
end

--获取装备的等级属性
function MarriageData:GetLevelInfo(index, level)
	local level_info = {}
	for k, v in ipairs(self.qy_level_cfg) do
		if index == v.slot + 1 then
			if level == v.level then
				level_info = v
				break
			end
		end
	end
	return level_info
end

--获取装备的总属性(品质属性+等级属性*(1+品质系数))
function MarriageData:GetAttrList(item_id, level)
	local attr_list = CommonStruct.Attribute()
	local equip_data = self:GetEquipCfgById(item_id)
	if not equip_data then
		return attr_list
	end

	local temp_attr_list = CommonDataManager.GetAttributteByClass(equip_data)
	attr_list = CommonDataManager.AddAttributeAttr(attr_list, temp_attr_list)

	local level_info = self:GetLevelInfo(equip_data.slot_idx + 1, level)
	temp_attr_list = CommonDataManager.GetAttributteByClass(level_info)

	local add_percent = self:GetQualityAddPercent(equip_data.quality)
	for k, v in pairs(temp_attr_list) do
		if v > 0 then
			temp_attr_list[k] = math.floor(temp_attr_list[k] * (1+(add_percent/10000)))
		end
	end

	attr_list = CommonDataManager.AddAttributeAttr(attr_list, temp_attr_list)

	return attr_list
end

--获取装备增加的品质系数
function MarriageData:GetQualityAddPercent(quality)
	local temp_add_percent = 0
	for k, v in ipairs(self.qy_quality_cfg) do
		if quality == v.quality then
			temp_add_percent = v.attr_add_percent
			break
		end
	end
	return temp_add_percent
end

--根据id获取可增加的经验值
function MarriageData:GetAddExpByItemId(item_id)
	local add_exp = 0
	local item_data = self:GetEquipCfgById(item_id) or {}
	local quality = item_data.quality
	if quality then
		for k, v in ipairs(self.qy_quality_cfg) do
			if quality == v.quality then
				add_exp = v.add_exp
				break
			end
		end
	end
	return add_exp
end

--设置挂机自动吸收参数
function MarriageData:SetGuaJiSettingParam(param)
	if param then
		self.guaji_setting_param = param
	end
end

function MarriageData:GetGuaJiSettingParam()
	local guaji_setting_param = self.guaji_setting_param
	if guaji_setting_param == 0 then
		local set_data = SettingData.Instance:GetSettingDataListByKey(HOT_KEY.MARRY_EQUIP)
		guaji_setting_param = set_data.item_id or 0
	end
	return guaji_setting_param
end

function MarriageData:SetSelectEquipIndex(index)
	self.equip_select_index = index
end

function MarriageData:GetSelectEquipIndex()
	return self.equip_select_index
end

---------------------爱情契约------------------------------------
function MarriageData:SetQingyuanLoveContractInfo(protocol)
	self.love_contract_info.self_love_contract_reward_flag = protocol.self_love_contract_reward_flag
	self.love_contract_info.can_receive_day_num = protocol.can_receive_day_num
	self.love_contract_info.lover_love_contract_timestamp = protocol.lover_love_contract_timestamp

	self.love_contract_info.leaveword_list = {}
	local leaveword_list = {}
	-- 自己
	local my_name = GameVoManager.Instance:GetMainRoleVo().name or ""
	for k,v in pairs(protocol.self_notice_list) do
		v.user_name = my_name
		-- local time = server_time - v.time
		local time_tab = TimeUtil.Format2TableDHM(v.time)
		-- v.day_num = self.love_contract_info.day_num - time_tab.day
		v.day_num = time_tab.day
		table.insert(leaveword_list, v)
	end

	-- 情侣
	local love_name = GameVoManager.Instance:GetMainRoleVo().lover_name or ""
	for k,v in pairs(protocol.lover_notice_list) do
		v.user_name = love_name
		-- local time = server_time - v.time
		local time_tab = TimeUtil.Format2TableDHM(v.time)
		-- v.day_num = self.love_contract_info.day_num - time_tab.day
		v.day_num = time_tab.day
		table.insert(leaveword_list, v)
	end
	SortTools.SortAsc(leaveword_list, "time")
	self.love_contract_info.leaveword_list = leaveword_list


	MainUICtrl.Instance.view:Flush(MainUIViewChat.IconList.LOVE_CONTENT, {true})
end

function MarriageData:GetQingyuanLoveContractInfo()
	return self.love_contract_info
end

function MarriageData:GetQingyuanLoveContractRewardFlag(index)
	local temp_flag_t = self.love_contract_info.self_love_contract_reward_flag
	return temp_flag_t[32 - index] or 0
end

function MarriageData:SetLoveContractSelectIndex(index)
	if index then
		self.love_contract_select_index = index
	end
end

function MarriageData:GetLoveContractSelectIndex()
	return self.love_contract_select_index or 1
end

function MarriageData:GetQingyuanLoveContractCfg()
	return ConfigManager.Instance:GetAutoConfig("qingyuanconfig_auto").love_contract or {}
end

function MarriageData:GetQingyuanLoveContractCfgByDay(day)
	local love_contract_cfg = self:GetQingyuanLoveContractCfg()
	for k, v in pairs(love_contract_cfg) do
		if day == v.day then
			return v
		end
	end
end

-- 爱情契约价格
function MarriageData:GetQingyuanLoveContractPrice()
	return self.marriage_condition.lovecontract_price or 0
end

-- 获取爱情契约是否有奖励可以领取
function MarriageData:GetQingyuanLoveContractReward()
	-- 爱情契约功能是否开启
	local love_contract_visible = OpenFunData.Instance:CheckIsHide("marriage_love_contract")
	local can_receive_day_num = self:GetQingyuanLoveContractInfo().can_receive_day_num
	for k,v in pairs(self:GetQingyuanLoveContractCfg()) do
		local reward_flag = self:GetQingyuanLoveContractRewardFlag(v.day)
		if v.day <= can_receive_day_num and reward_flag == 0 and love_contract_visible and self:CheckIsMarry() then
			return true
		end
	end
	return false
end

function MarriageData:GetRingRemind()
	return self:GetRedPointByKey("Ring") and 1 or 0
end

function MarriageData:GetBlessRemind()
	return self:GetRedPointByKey("Bless") and 1 or 0
end

function MarriageData:GetLoveContentRemind()
	if not OpenFunData.Instance:CheckIsHide("marriage_love_contract") then
		return 0
	end
	return self:GetRedPointByKey("love_content") and 1 or 0
end

function MarriageData:GetLoveTreeRemind()
	if not OpenFunData.Instance:CheckIsHide("marriage_halo") then
		return 0
	end

	return self:GetRedPointByKey("love_tree") and 1 or 0
end

function MarriageData:GetHaloRemind()
	local halo_type = 1
	local halo_level = MarriageData.Instance:GetHaloLevelByType(halo_type)
	local halo_info = MarriageData.Instance:GetHaloInfo(halo_type, halo_level)
	if halo_info == nil then
		return 0
	end
	local sex = GameVoManager.Instance:GetMainRoleVo().sex
	local item_id = sex == 1 and halo_info.stuff_id or halo_info.stuff_id_woman
	local have_num = ItemData.Instance:GetItemNumInBagById(item_id)
	return have_num > 0 and 1 or 0 
end

function MarriageData:GetFuBenRemind()
	if ClickOnceRemindList[RemindName.MarryFuBen] and ClickOnceRemindList[RemindName.MarryFuBen] == 0 then
		return 0
	end

	local data = self:GetQingYuanFBInfo()
	if data == nil or next(data) == nil then
		return 0
	end

	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	if main_role_vo.lover_name == nil or main_role_vo.lover_name == "" then
		return 0
	end

	local des = data.buy_fb_join_times - data.join_fb_times
	if data.join_fb_times <= 0 or des >= 0 then
		return 1
	end
	return 0 
end

function MarriageData:GetQinShiRemind()
	if not OpenFunData.Instance:CheckIsHide("marriage_equip") then
		return 0
	end

	local equip = MarryEquipData.Instance:GetMarryEquipRemind()
	local suit = MarryEquipData.Instance:GetMarrySuitRemind()
	local recyle = MarryEquipData.Instance:GetMarryEquipRecyleRemind()
	if equip == 1 or suit == 1 or recyle == 1 then
		return 1
	end
	return 0
end

-- 设置婚宴人气值
function MarriageData:SetHunyanRenQiValueInfo(protocol)
	self.hunyan_renqi_value_info = protocol.renqi_values
end

-- 获取婚宴人气值
function MarriageData:GetHunyanRenQiValueInfo()
	return self.hunyan_renqi_value_info or 0
end

---------------------获取婚礼玩家个人信息-------------------------
function MarriageData:SetWeddingRoleInfo(protocol)
	self.wedding_role_info.wedding_liveness = protocol.wedding_liveness
	self.wedding_role_info.is_baitang = protocol.is_baitang
	self.wedding_role_info.is_in_red_bag_fulsh_time = protocol.is_in_red_bag_fulsh_time
	self.wedding_role_info.banquet_has_gather_num = protocol.banquet_has_gather_num
	self.wedding_role_info.cur_turn_has_gather_red_bag = protocol.cur_turn_has_gather_red_bag
	self.wedding_role_info.total_exp = protocol.total_exp
end

function MarriageData:GetWeddingRoleInfo()
	return self.wedding_role_info
end

function MarriageData:GetHunYanCfgByReDu(liveness)
	local cfg = self.wedding_liveness_cfg

	for k,v in pairs(cfg) do
		if liveness < v.liveness_var then
			return v
		end
	end
	return cfg[#cfg]
end

---------------------设置祝福语信息-------------------------
function MarriageData:SetWeddingBlessingRecordInfo(protocol)
	self.bless_record_list.bless_record_list = protocol.bless_record_list
	self.bless_record_list.count = protocol.count
end

-- 获取祝福语
function MarriageData:GetWeddingBlessingRecordInfo()
	return self.bless_record_list
end

function MarriageData:GetBlessingListCfg(param)
	for k,v in pairs(self.marriage_blessing) do
		if v.param == param then
			return v
		end
	end
end

-- 获取婚礼祝福配置信息
function MarriageData:GetMarryFlowerItemIdBySeq(type, seq)
	for i,v in ipairs(self.marriage_blessing) do
		if v.blessing_type == type and v.seq == seq then
			return v.param
		end
	end
end

-- 设置结婚时间段索引
function MarriageData:SetMarryTimeSeq(seq)
	self.select_time_seq = seq
end

-- 获取结婚时间段
function MarriageData:GetMarryTimeSeq()
	return self.select_time_seq
end

-- 夫妻光环
function MarriageData:GetCoupleHaloRemind()
	local flag = 0
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	local item_id_key = main_role_vo.sex == 1 and "stuff_id" or "stuff_id_woman"
	for k, v in ipairs(self.couple_halo_level_list) do
		local halo_type = k - 1
		local halo_info = self:GetHaloInfo(halo_type, v)
		--先判断前置光环是否达到条件
		local above_level_enough = true
		if nil ~= halo_info then
			local pre_halo_level = halo_info.pre_halo_level
			if pre_halo_level > 0 then
				local above_halo_type = halo_type - 1
				local above_halo_level = self:GetHaloLevelByType(above_halo_type)
				if above_halo_level < pre_halo_level then
					above_level_enough = false
				end
			end
		end

		--如果存在前置光环等级没达到的话直接退出循环
		if not above_level_enough then
			break
		end

		--判断光环是否满级
		local next_halo_info = self:GetHaloInfo(halo_type, v + 1)
		if nil ~= next_halo_info then				--判断是否存在下一级光环属性
			--检查物品是否足够
			local item_id = halo_info[item_id_key]
			local num = ItemData.Instance:GetItemNumInBagById(item_id)
			if num > 0 then
				flag = 1
				break
			end
		end
	end

	return flag
end

--记录使用中的夫妻光环
function MarriageData:SetEquipCoupleHaloType(halo_type)
	self.equiped_couple_halo_type = halo_type
end

function MarriageData:GetEquipCoupleHaloType()
	return self.equiped_couple_halo_type
end

function MarriageData:SetCoupleHaloLevelList(list)
	self.couple_halo_level_list = list
end

function MarriageData:GetCoupleHaloLevelList()
	return self.couple_halo_level_list
end

function MarriageData:SetCoupleHaloExpList(list)
	self.couple_halo_exp_list = list
end

function MarriageData:GetHaloExpByType(halo_type)
	if nil == self.couple_halo_exp_list then
		return 0
	end

	return self.couple_halo_exp_list[halo_type + 1] or 0
end

function MarriageData:GetHaloLevelByType(halo_type)
	if nil == self.couple_halo_level_list then
		return 0
	end

	return self.couple_halo_level_list[halo_type + 1] or 0
end

function MarriageData:GetHaloInfo(halo_type, level)
	if nil == self.couple_halo_cfg or nil == self.couple_halo_cfg[halo_type] or nil == self.couple_halo_cfg[halo_type][level] then
		return nil
	end

	return self.couple_halo_cfg[halo_type][level]
end

--获取光环的激活等级
function MarriageData:GetActiveHaloLevel(halo_type)
	local level = 0
	if nil == self.couple_halo_cfg or nil == self.couple_halo_cfg[halo_type] then
		return level
	end

	local cfg = self.couple_halo_cfg[halo_type]
	while cfg[level] do
		local is_active = cfg[level].is_active_image
		if is_active == 1 then
			break
		end
		level = level + 1
	end
	return level
end


---------------------------情缘圣地------------------------------
function MarriageData:GetShengDiOtherCfg()
	return self.sheng_di_other
end
function MarriageData:GetShengDiLayerCfg()
	return self.sheng_di_layer
end
function MarriageData:GetShengDiTaskCfg()
	return self.sheng_di_task
end

function MarriageData:SetQingYuanShengDiTaskInfo(protocol)
	self.is_fetched_task_other_reward = protocol.is_fetched_task_other_reward
	self.lover_is_all_task_complete = protocol.lover_is_all_task_complete
	self.task_info_list = protocol.task_info_list
end

function MarriageData:GetIsOtherBtnShow()
	local is_fetched_reward_num = 0
	for k,v in pairs(self.task_info_list) do
		if v.is_fetched_reward == 1 then
			is_fetched_reward_num = is_fetched_reward_num + 1
		end
	end
	if self.is_fetched_task_other_reward == 1 then
		return 1
	elseif is_fetched_reward_num > 0 and is_fetched_reward_num == #self.task_info_list and self.lover_is_all_task_complete == 1 then
		return 2
	elseif is_fetched_reward_num <= 0 then
		return 4
	else
		return 3
	end
end

function MarriageData:GetTaskList()
	shengdi_task_list = TableCopy(self.task_info_list)
	for k,v in ipairs(shengdi_task_list) do
		local cfg = self:GetOneShengDiTaskById(v.task_id)
		if v.param >= cfg.param1 then
			v.flag = 0
		else
			v.flag = 1
		end
 	end
 	table.sort(shengdi_task_list, self:CommonSorters("is_fetched_reward", "flag", "index"))
    return shengdi_task_list
end

--未完成任务数量
function MarriageData:GetTaskNum()
	local num = 0
	for k,v in ipairs(self:GetTaskList()) do
		if v.flag == 1 then
			num = num  + 1
		end
	end
	return num
end

function MarriageData:CommonSorters(sort_key_name1, sort_key_name4, sort_key_name5)
    return function(a, b)
        local order_a = 10000
        local order_b = 10000
        if a[sort_key_name1] > b[sort_key_name1] then
            order_a = order_a + 10000
        elseif a[sort_key_name1] < b[sort_key_name1] then
            order_b = order_b + 10000
        end

        if nil == sort_key_name4 then return order_a < order_b end

        if a[sort_key_name4] > b[sort_key_name4] then
            order_a = order_a + 100
        elseif a[sort_key_name4] < b[sort_key_name4] then
            order_b = order_b + 100
        end

        if nil == sort_key_name5 then return order_a < order_b end

        if a[sort_key_name5] > b[sort_key_name5] then
            order_a = order_a + 10
        elseif a[sort_key_name5] < b[sort_key_name5] then
            order_b = order_b + 10
        end
        return order_a < order_b
    end
end


function MarriageData:GetOneShengDiTaskById(task_id)
	for k,v in pairs(self.sheng_di_task) do
		if task_id == v.task_id then
			return v
		end
	end
	return nil
end

function MarriageData:SetQingYuanShengDiBossInfo(protocol)
	self.boss_count = protocol.boss_count
	self.boss_list = protocol.boss_list
end

function MarriageData:GetTaskInfoList()
	return self.task_info_data
end

function MarriageData:GetBossInfoList()
	return self.boss_list
end

function MarriageData:SetSceneId(layer)
	for k,v in pairs(self.sheng_di_layer) do
		if layer == v.layer then
			self.boss_scene_id = v.scene_id
		end
	end
end

function MarriageData:SetNowShendiLayer(layer)
	self.shendi_layer = layer
end

function MarriageData:GetNowShendiLayer()
	return self.shendi_layer
end

function MarriageData:GetLayerCfgByLayer(layer)
	for k,v in pairs(self.sheng_di_layer) do
		if layer == v.layer then
			return v
		end
	end
end

function MarriageData:GetLayerCfgByLevel(level)
	local  data = {}
	for k,v in pairs(self.sheng_di_layer) do
		if level >= v.enter_level and (data.enter_level == nil or data.enter_level < v.enter_level) then
			data = v
		end
	end
	return data
end

function MarriageData:GetSceneId()
	return self.boss_scene_id
end

--获取对应位置类型的怪物列表
function MarriageData:GetShengDiMosterList(layer, pos_type)
	if self.sheng_di_monster[layer] == nil or self.sheng_di_monster[layer][pos_type] == nil then
		return nil
	end

	return self.sheng_di_monster[layer][pos_type]
end

function MarriageData:GetShengDiPosByPosType(pos_type)
	if self.sheng_di_pos[pos_type] == nil or self.sheng_di_pos[pos_type][1] == nil then
		return 0, 0
	end

	local pos_info = self.sheng_di_pos[pos_type][1]

	return pos_info.pos_x, pos_info.pos_y
end

function MarriageData:IsShengDIScene()
	local scene_id = Scene.Instance:GetSceneId()
	for k,v in pairs(self.sheng_di_layer) do
		if v.scene_id == scene_id then
			return true
		end
	end
	return false
end

function  MarriageData:SetTaskId(task_id)
	self.task_id = task_id
end

function MarriageData:IsGatherTimesLimit()
	local  task_cfg = {}
	local data = {}
	for k,v in pairs(self:GetTaskList()) do
		if self.sheng_di_task2[v.task_id] ~= nil and self.sheng_di_task2[v.task_id].task_type == 5 then
			task_cfg = self.sheng_di_task2[v.task_id]
			data = v
			break
		end
	end
	if task_cfg ~= nil and next(task_cfg) ~= nil and task_cfg.param1 <= data.param then
		return true
	end
	return false
end

function MarriageData:IsShowShengDiFuBen()
	if self:IsShengDIScene() and not self:IsGatherTimesLimit() then
		return true
	end
	return false
end

function MarriageData:GetGatherCfg()
	return self.sheng_di_gather
end


function MarriageData:GetShengDiRemind()
	if not OpenFunData.Instance:CheckIsHide("marriage_shnegdi") then
		return 0
	end

	if ClickOnceRemindList[RemindName.MarryShengDi] and ClickOnceRemindList[RemindName.MarryShengDi] == 0 then
		return 0
	end

	local flag = 0
	local task_list = self:GetTaskList()
	for k,v in pairs(task_list) do
		if v.flag == 0 and v.is_fetched_reward == 0 then
			flag = 1
			return flag
		end

		local task_cfg = self:GetOneShengDiTaskById(v.task_id)
		if v.param < task_cfg.param1 then
			flag = 1
		end
	end

	if self:GetIsOtherBtnShow() == 2 or self:GetIsOtherBtnShow() == 4 then
		flag = 1
	end

	return flag
end

function MarriageData:SetHunyanQuestionUserInfo(protocol)
	self.hunyan_user_info = protocol.user_info
	self.question_list = protocol.question_list
end

-- 婚宴答题个人信息
function MarriageData:GetHunyanQuestionUserInfo()
	return self.hunyan_user_info, self.question_list
end

function MarriageData:SetHunyanQuestionRankInfo(protocol)
	self.rank_list = protocol.rank_list
end

function MarriageData:SetHunyanAnswerResult(protocol)
	self.topic_answer.npc_seq = protocol.npc_seq
	self.topic_answer.is_righ = protocol.is_righ
end

--答题对错信息
function MarriageData:GetTopicAnswer()

	return self.topic_answer
end

-- 获取婚宴答题排行
function MarriageData:GetHunyanQuestionRankInfo()
	return self.rank_list
end

--获取NPC坐标
function MarriageData:GetQuestionNpcPos(index)
	return self.question_npc_pos[index]
end

-- npcID
function MarriageData:GetQuestionNpc(index)
	return self.question_npc[index].npc_id
end

--获取当前答题index
function MarriageData:GetCurQuestionIdx()
	return self.hunyan_user_info.cur_question_idx or 1
end

-- 根据id获取婚宴题目
function MarriageData:GetCurQuestionThe(index)
	return self.question[index]
end