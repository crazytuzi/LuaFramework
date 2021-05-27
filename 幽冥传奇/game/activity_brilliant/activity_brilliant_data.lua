ActivityBrilliantData = ActivityBrilliantData or BaseClass()

ActivityBrilliantData.First_Charge_Change = "first_charge_change"
ActivityBrilliantData.DRAGON_TREASURE_DATA = "dragon_treasure_data"

function ActivityBrilliantData:__init()
	if ActivityBrilliantData.Instance then
		ErrorLog("[ActivityBrilliantData]:Attempt to create singleton twice!")
	end
	ActivityBrilliantData.Instance = self
	GameObject.Extend(self):AddComponent(EventProtocol):ExportMethods()

	--配置表 活动id 活动时间 活动奖励
	self.act_cfg = {}
	self.last_yaoqian_time = 0
	self.yaoqian_time = 0
	self.can_list = {}

	self.res_id = {}

	-- 摇钱相关
	self.yaojiang_reward_list = {}
	self.yaojiang_list = {}

	--超级寻宝
	self.xunbao_list = {}

	self.denglu_reward_list = {}
	self.leichong_reward_list = {}
	self.qinggou_item_list = {}
	self.rank_list = {}
	self.mine_rank = {}
	self.xunbao_reward_list = {}
	self.baoshi_reward_list = {}
	self.xiaofei_reward_list = {}

	self.today_charge_gold_count = 0
	self.receive_count_list = {}
	
	self.item_list = {}

	-- 操作标志
	self.sign = {} 
	self.sign_2 = {} --超级豪礼
	self.is_lingqu = {}

	self.yaoqian_num = 0
	--转盘
	self.use_num = 0
	self.consum_gold = {}
	self.zp_record = ""

	self.tabbar_list = {}
	self.activity_name = {}
	self.act_priority = {}

	self.baozan_num = 0

	self.mine_num = {}

	--幸运有礼
	self.lucky_flush_time = 0
	self.item_index = 0
	self.draw_num = 0
	self.xf_draw_num = 0
	self.all_draw_num = 0

	--神秘商店
	self.shop_flush_time =  0
	self.shop_item_num = 0
	self.shop_item_list = {}

	--全民抢购
	self.qm_item_list = {}
	self.act_day = 0

	--金蛋
	self.num_list = {}
	self.num_2_list = {}

	--兑换
	self.duihuan_num_list = {}
	self.duihuan_num_2_list = {}

	self.spare_szxb_num = 0
	self.spare_xb_num = 0
	self.xunbao_num = 0
	self.all_charge = 0
	self.lingqu_num = 0
	self.buy_num = 0
	self.gold_draw_num = 0

	self.day_charge = {}
	self.lk_draw_num = 0

	self.ylq_num = 0
	self.cqq_num = 0

	-- 44 ACT_ID.THLB
	self.thlb_buy_times_list = {}

	--46
	self.fl_time_list = {}
	self.fl_qf_record = ""
	self.fl_gr_record = ""
	self.gold_46_num = 0
	self.draw_46_num = 0
	self.index_46 = 0

	--47
	self.daily_charge = 0
	self.lingqu_47_times = {}
	self.sign_47_times = {}

	--48
	self.buy_level = 0

	--50
	self.is_exchange = 0

	--52
	self.lingqu_num_52 = 0

	--54
	self.record_54 = ""
	self.cz_draw_num = 0

	--57
	self.red_rope_type = {}
	self.red_rope_level = 0
	self.red_rope_count = 0

	self.turntable_list = {}

	--61探索秘宝
	self.tsmb_list = {
		cound_time = 0,
		luck_time = 0,
		xunbao_time = 0,
		zj_sign = 0,
		record_list = {}
	}

	--62 藏宝阁
	self.canbaoge_data = {}

	--63
	self.cabinet_flush_time = 0
	self.cabinet_num = 0
	self.cabinet_list = {}
	self.flush_times = 0
	self.flush_sign = 0

	--64
	self.tower_level = 0
	self.draw_record = ""

	--65
	self.super_exc_list = {}

	self:SetBrandInfo({})

	self.cs_act_model_map = {}

	-- 67/83
	self.rechaege_data = {}
	--68
	self.grade_list = {}
	-- 69
	self.charge_total = 0
	self.cur_grade = 0
	-- 70
	self.charge_grade = 0
	self.charge_day = 0
	self.charge_count = 0

	-- 71
	self.act_71_info = {}
	-- 72
	self.charge_days = 0
	self.charge_sign_count = 0
	-- 73
	self.charge_grad_list = {}
	self.cur_day = 0

	-- 74 
	self.charge_money = 0
	-- 75
	self.red_packet_integral = 0
	self.red_packet_record = ""
	self.red_num = 0
	self.cur_red_num = 0
	self.time = 0
	-- 76
	self.cur_draw_grade = 0
	self.cur_charge_money = 0
	self.gold_draw_record = ""
	self.unlock_grade = 0
	-- 77
	self.gold_consume = 0
	-- 78
	self.charge_fanli = 0
	-- 79
	self.draw_integral = 0
	self.cz_draw_record = ""

	-- 80
	self.fanli_list = {}

	--81
	self.ranking_data = {}
	self.ranktoday_num = nil
	self.today_value = 0
	self.today_getvalue = 0
	self.get_tag = 0

	--82
	self.topupRank_count = 0
	self.topupRank_data = {}
	self.todayRank_num = 0
	self.Topup_value = 0
	self.Topup_getvalue = 0
	self.Topup_tag = 0 

	--83
	self.legendRank_count = 0
	self.legendRank_data = {}
	self.legendRank_num = 0
	self.Legend_value = 0
	self.Legend_getvalue = 0
	self.Legend_tag = 0

	--84
	self.All_open_count = 0
	self.Free_open_count = 0
	self.This_reopen_count = 0
	self.This_open_tag = 0
	self.Grif_get_tag = 0
	self.Online_time = 0
	self.Auth_record_str = "" 
	self.record_index = 0 
	self.autn_gift_index = 0
	self.re_online = {0, 0}
	self.shone_num = 0
	self.grift_index = {}

	--85
	self.firecrackes_open_count = 0
	self.firecrackes_gift_tag = 0
	self.small_firecrackes_count = 0
	self.big_firecrackes_rewardcount = 0
	self.small_gift_index = {}
	self.big_gift_index = {}
	self.lucky_draw_index = 0
	self.lucky_draw_count = 0
	self.lucky_big_index = {}

	--86
	self.zphl_data = {
		hl_sign = 0,
		hl_score = 0,
		day_com_sign = 0,
	}

	--87
	self.act_pay_num = 0
	self.act_pay_tag = 0

	--88
	self.boss_count = 0
	self.boss_kill_tag = {}
	self.boss_num = {}
	self.boss_awake_tag = 0

	--89
	self.now_bless_value = 0
	self.ident_record_str = ""
	
	--92
	self.treasure_score = 0
	self.treasure_reward = 0
	self.treasure_record = ""
	self.treasure_item_num = 0
	self.treasure_item_index = 0	
	self.treasure_item_list = {}

	-- 93
	self.dragon_treasure_data = {}
	self.dragon_treasure_times_award = {}
	self.dragon_treasure_all_log = {}
	self.dragon_treasure_results = {}

	-- 94
	self.dljs_data = {
		lq_sign = 0,
		dl_day = 0,
	}

	-- 95
	self.czlb_data = {
		act_days = 1,
		item_list = {},
	}
end

function ActivityBrilliantData:__delete()
end

function ActivityBrilliantData:SetTabbarList(protocol)
	local need_clear_act = {}
	if protocol.type == 1 then
		self.can_list = protocol.can_list
		for k, v in pairs(self.can_list) do
			table.insert(need_clear_act, v)
		end
	elseif protocol.type == 5 then
		for k,v in pairs(self.can_list) do
			if v.cmd_id == protocol.cmd_id and v.act_id == protocol.act_id then
				return
			end
		end
		local vo = {
			act_id = protocol.act_id,
			cmd_id = protocol.cmd_id,
		}
		table.insert(self.can_list, vo)
		table.insert(need_clear_act, vo)
	elseif protocol.type == 6 then
		if protocol.act_id == 0 then
			local temp_list = TableCopy(self.can_list)
			for k, v in pairs(temp_list) do
				if v.cmd_id == protocol.cmd_id then
					temp_list[k] = nil
				end
			end
			self.can_list = {}
			for k, v in pairs(temp_list) do
				table.insert(self.can_list, v)
			end
		else
			for k,v in pairs(self.can_list) do
				if v.cmd_id == protocol.cmd_id and v.act_id == protocol.act_id then
					table.remove(self.can_list, k)
					break
				end
			end
		end
	end
	
	for k, v in pairs(need_clear_act) do
		if v.act_id == ACT_ID.SCFL then
			GlobalEventSystem:Fire(ActivityBrilliantData.First_Charge_Change, true)
		end
		self.activity_name[v.act_id] = nil
		self.act_cfg[v.act_id] = nil
		self:DeleteCSActModel(v.act_id)
	end
end

function ActivityBrilliantData:GetCmdIdByActId(act_id)
	for i,v in pairs(self.can_list) do
		if v.act_id == act_id then 
			return v.cmd_id
		end
	end
end

function ActivityBrilliantData:CheckActOpen(act_id)
	for i,v in pairs(self.can_list) do
		if v.act_id == act_id then
			return true
		end
	end
	return false
end

function ActivityBrilliantData:SetActivityCfg(protocol)
	local act_id = protocol.act_id
	local act_cfg = protocol.act_cfg 
	local b = loadstring("return"..act_cfg)
	act_cfg = b()
	self.act_cfg[act_id] = act_cfg
	self:UpdateActViewInfo(act_cfg)

	if self.IsCrossServerAct(act_id) then
		self:CreateCSActModel(act_id)
	end
end

function ActivityBrilliantData:SetActivityData(protocol)
	local act_id = protocol.act_id
	if nil == self.act_cfg[act_id] then
		return
	end
	self.yaojiang_list = self:GetRewardList(protocol.jilv)
	self.xunbao_list = self:GetRewardList(protocol.zp_record)
	self.turntable_list = self:GetGoldRewardList(protocol.jc_record)

	self.activity_name[act_id] = self.act_cfg[act_id].act_name
	self.act_priority[act_id] = self.act_cfg[act_id].act_priority
	self.sign[act_id] = protocol.sign
	self.sign_2[act_id] = protocol.sign_2
	self.consum_gold[act_id]  = protocol.consum_gold
	self.mine_num[act_id] = protocol.mine_num
	self.rank_list[act_id] = protocol.rank_list
	self.receive_count_list[act_id] = protocol.receive_count_list
	self.mine_rank[act_id] = protocol.mine_rank
	if self.mine_rank[act_id] == 0 then
		self.mine_rank[act_id] = Language.RankingList.MyRanking
	end
	self.is_lingqu[act_id] = protocol.is_lingqu
	if act_id == 1 then
		self.yaoqian_num =  protocol.yaoqian_num
		self.yaoqian_time =  protocol.yaoqian_time
		self.last_yaoqian_time =  Status.NowTime - protocol.yaoqian_time
		self.jilv = protocol.jilv
	elseif act_id == 4 then
		self.flush_time = protocol.flush_time
		self.item_num = protocol.item_num
		self.item_list = protocol.item_list
	elseif act_id == 6 then
		self.xunbao_num = protocol.xunbao_num	
	elseif act_id == ACT_ID.SHIZ  then
		self.spare_szxb_num = protocol.spare_szxb_num
	elseif act_id == ACT_ID.ZP then
		self.use_num = protocol.use_num
		self.zp_record = protocol.zp_record
		self.ylq_num = protocol.ylq_num
		self.cqq_num = protocol.cqq_num
	elseif act_id == ACT_ID.CJXB then
		self.spare_xb_num = protocol.spare_xb_num
	elseif act_id == ACT_ID.LJ then
		self.all_charge = protocol.all_charge

	elseif act_id == ACT_ID.CFCZ then
		self.lingqu_num =  protocol.lingqu_num
	elseif act_id == ACT_ID.BZ then
		self.baozan_num =  protocol.baozan_num
	elseif act_id == 25 then
		self.lucky_flush_time = protocol.flush_time
		self.item_index = protocol.item_index
		self.draw_num = protocol.draw_num
		self.buy_num = protocol.buy_num
	elseif act_id == 27 then
		self.xf_draw_num = protocol.draw_num
		self.all_draw_num = protocol.all_num
	elseif act_id == 26 then
		self.shop_flush_time = protocol.flush_time
		self.shop_item_num = protocol.item_num
		self.shop_item_list = protocol.item_list
	elseif act_id == 33 then
		self.gold_draw_num = protocol.draw_num
		self.jackpot = protocol.jackpot
	elseif act_id == 34 then
		self.num_list = protocol.num_list
		self.num_2_list = protocol.num_2_list
	elseif act_id == 40 then
		self.duihuan_num_list = protocol.num_list
		self.duihuan_num_2_list = protocol.num_2_list
	elseif act_id == 37 then
		self.qm_item_list = protocol.item_list
		self.act_day = protocol.act_day
	elseif act_id == 32 or act_id == 42 then
		self.day_charge[act_id] = protocol.day_charge
	elseif act_id == 45 then
		self.lk_draw_num = protocol.lk_draw_num
	elseif act_id == 46 then
		self.fl_time_list = protocol.fl_time_list
		self.fl_qf_record = protocol.fl_qf_record
		self.fl_gr_record = protocol.fl_gr_record
		self.gold_46_num = protocol.gold_46_num
		self.draw_46_num = protocol.draw_46_num - 1 --防止上来能直接转一次
		self.index_46 = protocol.activity_index
	elseif act_id == 47 then
		self.daily_charge = protocol.daily_charge
		self.lingqu_47_times = protocol.lingqu_times
		self.sign_47_times = protocol.sign_times
	elseif act_id == 48 then
		self.buy_level = protocol.buy_level
	elseif act_id == 50 then
		self.is_exchange = protocol.is_exchange
	elseif act_id == 52 then
		self.lingqu_num_52 = protocol.lingqu_num_52 - 1
	elseif act_id == 54 then
		self.record_54= protocol.record_54
		self.cz_draw_num = protocol.cz_draw_num - 1
	elseif act_id == 57 then
		self.red_rope_type = protocol.red_rope_type
		self.red_rope_level = protocol.red_rope_level
		self.red_rope_count = protocol.red_rope_count
	elseif act_id == 61 then
		self.tsmb_list.cound_time = protocol.cound_time
		self.tsmb_list.luck_time = protocol.luck_time
		self.tsmb_list.xunbao_time = protocol.xunbao_time
		self.tsmb_list.zj_sign = protocol.zj_sign
		self.tsmb_list.record_list = protocol.record_list
	elseif act_id == 62 then
		self.canbaoge_data = protocol.canbaoge_data
	elseif act_id == 63 then 
		self.cabinet_flush_time = protocol.cabinet_flush_time
		self.cabinet_num = protocol.cabinet_num
		self.cabinet_list = protocol.cabinet_list
		self.flush_times = protocol.flush_times
		self.flush_sign = protocol.flush_sign
	elseif act_id == 64 then
		self.tower_level = protocol.tower_level
		self.draw_record = protocol.draw_record
	elseif act_id == 65 then
		self.super_exc_list = protocol.super_exc_list
	elseif act_id == ACT_ID.XYFP then
		self.can_flip_count = protocol.can_flip_count
		self:SetBrandInfo(protocol.cards)
	elseif act_id == ACT_ID.JBXG then
		self.grade_list = protocol.grade_list
	elseif act_id == ACT_ID.HHDL then
		self.charge_total = protocol.charge_total
		self.cur_grade = protocol.cur_grade
	elseif act_id == ACT_ID.LCFL then
		self.charge_grade = protocol.day_charge
		self.charge_day = protocol.mine_num
		self.charge_count = protocol.sign
	elseif act_id == ACT_ID.CZLC then
		self.act_71_info = {
			everyday_grade = protocol.everyday_grade,
			everyday_sign = protocol.everyday_sign,
			cumulative_grade = protocol.cumulative_grade,
			cumulative_sign = protocol.cumulative_sign,
			cur_day_charge = protocol.cur_day_charge,
			cumulative_charge = protocol.cumulative_charge,
		}
	elseif act_id == ACT_ID.LCFD then 
		self.charge_days = protocol.charge_days
		self.charge_sign_count = protocol.charge_sign_count
	elseif act_id == ACT_ID.CSFS then 
		self.charge_grad_list = protocol.charge_grad_list
		self.cur_day = protocol.cur_day
	elseif act_id == ACT_ID.XSCZ then 
		self.charge_money = protocol.charge_money
	elseif act_id == ACT_ID.FHB then 
		self.red_packet_integral = protocol.red_packet_integral
		self.red_packet_record = protocol.red_packet_record
	elseif act_id == ACT_ID.GZP then 
		self.cur_draw_grade = protocol.cur_draw_grade
		self.cur_charge_money = protocol.cur_charge_money
		self.gold_draw_record = protocol.gold_draw_record
		self.unlock_grade = protocol.unlock_grade
	elseif act_id == ACT_ID.YBFS then 
		self.gold_consume = protocol.gold_consume
	elseif act_id == ACT_ID.CZFL then 
		self.charge_fanli = protocol.charge_fanli
	elseif act_id == ACT_ID.SVZP then 
		self.draw_integral = protocol.draw_integral
		self.cz_draw_record = protocol.cz_draw_record
	elseif act_id == ACT_ID.LXFL then 
		self.fanli_list = protocol.fanli_list
	elseif act_id == ACT_ID.XFZF then
		self.ranking_data = protocol.ranking_data
		self.ranktoday_num = protocol.ranktoday_num
		self.today_value = protocol.today_value
		self.today_getvalue = protocol.today_getvalue
		self.get_tag = protocol.get_tag
	elseif act_id == ACT_ID.CZZF then
		self.topupRank_data = protocol.topupRank_data
		self.todayRank_num = protocol.todayRank_num
		self.Topup_value = protocol.Topup_value
		self.Topup_getvalue = protocol.Topup_getvalue
		self.Topup_tag = protocol.Topup_tag
	elseif act_id == ACT_ID.CQZF then
		self.legendRank_count = protocol.legendRank_count
		self.legendRank_data = protocol.legendRank_data
		self.legendRank_num = protocol.legendRank_num
		self.Legend_value = protocol.Legend_value
		self.Legend_getvalue = protocol.Legend_getvalue
		self.Legend_tag = protocol.Legend_tag
	elseif act_id == ACT_ID.YSJD then
		self.All_open_count = protocol.All_open_count
		self.Free_open_count = protocol.Free_open_count
		self.This_reopen_count = protocol.This_reopen_count
		self.This_open_tag = protocol.This_open_tag
		self.Grif_get_tag = protocol.Grif_get_tag
		self.Online_time = protocol.Online_time
		self.Auth_record_str = protocol.Auth_record_str
		self.record_index = protocol.record_index 
		self.autn_gift_index = protocol.autn_gift_index
		self.re_online = {protocol.re_online, Status.NowTime}
		self.shone_num = protocol.shone_num
		self.grift_index = protocol.grift_index
	elseif act_id == ACT_ID.HDBP then
		self.firecrackes_open_count = protocol.firecrackes_open_count
		self.firecrackes_gift_tag = protocol.firecrackes_gift_tag
		self.small_firecrackes_count = protocol.small_firecrackes_count
		self.big_firecrackes_rewardcount = protocol.big_firecrackes_rewardcount
		self.small_gift_index = protocol.small_gift_index
		self.big_gift_index = protocol.big_gift_index
		self.lucky_draw_index = protocol.lucky_draw_index
		self.lucky_draw_count = protocol.lucky_draw_count
		self.lucky_big_index = protocol.lucky_big_index
	elseif act_id == ACT_ID.ZPHL then
		self.zphl_data.hl_sign = protocol.hl_sign
		self.zphl_data.hl_score = protocol.hl_score
		self.zphl_data.day_com_sign = protocol.day_com_sign
	elseif act_id == ACT_ID.XFJL then
		self.act_pay_num = protocol.act_pay_num
		self.act_pay_tag = protocol.act_pay_tag
	elseif act_id == ACT_ID.JDBS then
		self.boss_count = protocol.boss_count
		self.boss_kill_tag = protocol.boss_kill_tag
		self.boss_num = protocol.boss_num
		self.boss_awake_tag = protocol.boss_awake_tag
	elseif act_id == ACT_ID.BSJD then
		self.now_bless_value = protocol.now_bless_value
		self.ident_record_str = protocol.ident_record_str
	elseif act_id == ACT_ID.SLLB then
		self.treasure_score = protocol.treasure_score
		self.treasure_reward = protocol.treasure_reward
		self.treasure_record = protocol.treasure_record
	elseif act_id == ACT_ID.DLJS then
		self.dljs_data.lq_sign = protocol.lq_sign
		self.dljs_data.dl_day = protocol.dl_day
	elseif act_id == ACT_ID.LZMB then
		self.dragon_treasure_data = protocol.dragon_treasure_data
	elseif act_id == ACT_ID.THLB then
		self.thlb_buy_times_list = protocol.thlb_buy_times_list
	elseif act_id == ACT_ID.DBFL or act_id == ACT_ID.XSZG then
		self.rechaege_data = protocol.rechaege_data
	elseif act_id == ACT_ID.CZLB then
		self.czlb_data.act_days = protocol.act_days
		self.czlb_data.item_list = protocol.item_list
	else
		local cs_act_model = self:GetCSActModel(act_id)
		if nil ~= cs_act_model then
			cs_act_model:ServerProtocol(protocol)
		else
		end
	end

	--75抢红包
	self.cooling_time = protocol.cooling_time or 0
	self.cooling_endtime = self.cooling_time + TimeCtrl.Instance:GetServerTime()
end
------------------------
--兑换豪礼
------------------------
-- function ActivityBrilliantData:GetExchangeawardList()
-- 	return self.exchange_re_list
-- end

-- function ActivityBrilliantData:GetTodayChargeTag()
-- 	return self.today_charge_tag
-- end

-- function ActivityBrilliantData:GetActGlodGiftTag()
-- 	local list = {}
-- 	list.login_award_num = self.login_award_num
-- 	list.first_charge_tag = self.first_charge_num
-- 	return list
-- end
------------------------
--BOSS鉴定
------------------------
function ActivityBrilliantData:GetBlessValue()
	return self.now_bless_value
end

function ActivityBrilliantData:GetIdentRecord()
	local list = {}
	local tag_t = Split(self.ident_record_str, ";")
	if nil == tag_t then return end
	for i= #tag_t, 1, -1 do
		local str =  Split(tag_t[i], "#")
		local vo = {}
		vo.name = str[1]
		vo.item_name = str[2]
		table.insert(list, vo)
	end
	return list
end

------------------------
--经典BOSS
------------------------
function ActivityBrilliantData:GetBossKillList()
	local boss_list = {}
	local boss_tag_list = {}
	for i = 1, self.boss_count do
		local vo = {}
		for k = 1, self.boss_num[i] do
			vo[k] = bit:_and(1,bit:_rshift(self.boss_kill_tag[i], k - 1))
		end
		table.insert(boss_tag_list,vo)
	end
	for i,v in ipairs(boss_tag_list) do
		boss_list[i] = v
		boss_list[i].boss_num = self.boss_num[i]
		boss_list[i].awake_sign = bit:_and(1,bit:_rshift(self.boss_awake_tag, i))
	end
	return boss_list
end



------------------------
--消费奖励
------------------------
function ActivityBrilliantData:GetGoldPayList()
	local pay_ward = {}
	local cfg = self:GetActCfgByIndex(ACT_ID.XFJL).config
	for k,v in ipairs(cfg) do
		pay_ward[k] = v
		pay_ward[k].sign =  bit:_and(1,bit:_rshift(self.act_pay_tag, k))
		pay_ward[k].index = k
	end
	table.sort(pay_ward, function (a, b)
		if a.sign == b.sign then
			return a.index < b.index
		end
		return a.sign < b.sign
	end)
	return pay_ward
end

function ActivityBrilliantData:GetActDaily()
	return self.act_pay_num
end
------------------------
--转盘好礼
------------------------

function ActivityBrilliantData:GetZPHLList()
	local zphl_data = {}
	local cfg = self:GetActCfgByIndex(ACT_ID.ZPHL).config
	local task_data_list = ShenDingData.Instance:GetTaskList()
	
	for k, v in pairs(cfg.tasks) do
		local times = self:GetTaskTime(v.task_id + 1)
		local vo = {
			index = v.task_id + 1,
			time = times >= v.max_tms and v.max_tms or times,
			max_tms = v.max_tms,
			score = v.add_score,
			can_receive = times >= v.max_tms and 1 or 0,
			item_icon = cfg.item_icon,
		}
		table.insert(zphl_data, vo)
	end

	table.sort(zphl_data, function(a, b)
		if a.can_receive ~= b.can_receive then
			return a.can_receive < b.can_receive
		else
			return a.index < b.index
		end
	end)

	return zphl_data
end

-- 转盘好礼奖励是否领取
function ActivityBrilliantData:GetZPHLRewardSign()
	local list = bit:d2b(self.zphl_data.hl_sign)
	local data = {}
	for i = 1, #list do
		data[i] = list[#list - i + 1]
	end
	return data
end

-- 获取当前抽取第几次
function ActivityBrilliantData:GetIndexCostScore()
	local cfg = self:GetActCfgByIndex(ACT_ID.ZPHL).config.award_pool
	local data = self:GetZPHLRewardSign()
	local index = 0
	for k, v in pairs(data) do
		if v == 0 then
			index = k
			break
		end
	end
	return cfg[index].cost_score
end

-- 获取活跃度任务的次数
function ActivityBrilliantData:GetTaskTime(index)
	local data = ShenDingData.Instance:GetTaskList()
	for k, v in pairs(data) do
		if v.index == index then
			return v.times
		end
	end
	return 0
end

function ActivityBrilliantData:GetZPHLScore()
	return self.zphl_data.hl_score
end


------------------------
--欢度大鞭炮
------------------------
function ActivityBrilliantData:GetWardList()
	local ward_list = {}
	for i, v in ipairs(self.small_gift_index) do
		ward_list[i] = v
	end
	ward_list.firecrackes_open_count = self.firecrackes_open_count
	ward_list.small_firecrackes_count = self.small_firecrackes_count
	return ward_list
end

function ActivityBrilliantData:GetBigWardList()
	local ward_list = {}
	for i, v in ipairs(self.big_gift_index) do
		ward_list[i] = v
	end
	ward_list.big_firecrackes_rewardcount = self.big_firecrackes_rewardcount
	return ward_list 
end


-------------------------
--原石鉴定
-------------------------

function ActivityBrilliantData:GetAuthList()
	local auth_list = {}
	auth_list.record_index = self.record_index
	auth_list.autn_gift_index = self.autn_gift_index
	return auth_list
end

function ActivityBrilliantData:GetOnlineTime()
	local re_online = self.re_online[1] - self.re_online[2] + Status.NowTime
	return re_online
end

function ActivityBrilliantData:GetCellList()
	local auth_list = {}
	for i, v in ipairs(self.grift_index) do
		auth_list[i] = v
	end
	auth_list.shone_num = self.shone_num
	return auth_list
end 


function ActivityBrilliantData:GetAuthawakeList()
	local cfg = self:GetActCfgByIndex(ACT_ID.YSJD)
	local authawak_list = {}
	for i, v in ipairs(cfg.config.giftBox) do
		authawak_list[i] = v
		authawak_list[i].grade = i 
		authawak_list[i].tag = bit:_and(1, bit:_rshift(self.Grif_get_tag, i))
	end
	return authawak_list
end

function ActivityBrilliantData:GetMationList()
	local mation_list = {}
	mation_list.All_open_count = self.All_open_count
	mation_list.Free_open_count = self.Free_open_count
	return mation_list
end

function ActivityBrilliantData:GetYSJDDrawRecord()
	local list = {}
	local tag_t = Split(self.Auth_record_str, ";")
	if nil == tag_t then return end

	local max_count = #tag_t
	for i= max_count, 1, -1 do
		local str =  Split(tag_t[i], "#")
		local vo = {}
		vo.name = str[1]
		vo.item_name = str[2]
		vo.max_count = max_count
		table.insert(list, vo)
	end
	return list
end

function ActivityBrilliantData:GetGiftTag()
	local gift_index = {}
	local cfg = self:GetActCfgByIndex(ACT_ID.YSJD)
	for i= 1, #cfg.config.giftBox do
		local sign = bit:_and(1,bit:_rshift(self.Grif_get_tag, i))
		gift_index[i] = sign
	end
	return gift_index
end

function ActivityBrilliantData:GetGiftList()
	local cfg = self:GetActCfgByIndex(ACT_ID.YSJD)
	local config = cfg.config
	local openCount = config.openCount
	local show_index = config.show_index or {}
	local gift_list = {}
	for i, v in ipairs(config.giftBox) do
		local item = {}
		item.gift_box = v 					 -- 开启宝箱的奖励 预览用
		item.times = openCount[i] 			 -- 开启宝箱的条件 单位:次
		item.show_index = show_index[i] or 1 -- 宝箱图片索引 显示用
		item.sign = bit:_and(1,bit:_rshift(self.Grif_get_tag, i)) -- 领取标记 1为已领取

		gift_list[i - 1] = item
	end

	return gift_list
end

-------------------------
--传奇争锋
-------------------------
function ActivityBrilliantData:GetLegendAttr()
	local cfg = self:GetActCfgByIndex(ACT_ID.CQZF)
	local topup_list = {}
	-- for i,v in ipairs(cfg.config.rankings) do
	-- 	while true do 
	-- 		if i == 1 then break end
	-- 		topup_list[i-1] = v
	-- 		topup_list[i-1].role_info = self.legendRank_data[i]
	-- 		topup_list[i-1].role_index = i 
	-- 		break
	-- 	end
	-- end
	return topup_list
end

function ActivityBrilliantData:GetFirstLegend()
	-- local cfg = self:GetActCfgByIndex(ACT_ID.CQZF)
	-- cfg.config.rankings[1].role_info = self.legendRank_data[1]

	-- return cfg.config.rankings[1]
end
function ActivityBrilliantData:LegendMation()
	local role_list = {}
	role_list.Legend_value = self.Legend_value
	role_list.Legend_getvalue = self.Legend_getvalue
	role_list.legendRank_num = self.legendRank_num
	return role_list
end
function ActivityBrilliantData:LegendAward()
	local cfg = self:GetActCfgByIndex(ACT_ID.CQZF)
	
	local award_list = {}
	for i, v in ipairs(cfg.config.join_award) do
		local sign = bit:_and(1,bit:_rshift(self.Legend_tag,i ))
		if sign == 0 then
			v.sign = sign
			v.grade = i 
			return v
		end
	end
	local list = cfg.config.join_award[#cfg.config.join_award]
	list.sign = 1
	list.grade = #cfg.config.join_award
	return list
end

-------------------------
--充值争锋
-------------------------
function ActivityBrilliantData:GetTopupAttr()
	local cfg = self:GetActCfgByIndex(ACT_ID.CZZF)
	local topup_list = {}
	for i,v in ipairs(cfg.config.rankings) do
		-- while true do 
		-- 	if i == 1 then break end
		-- 	topup_list[i-1] = v
		-- 	topup_list[i-1].role_info = self.topupRank_data[i]
		-- 	topup_list[i-1].role_index = i 
		-- 	break
		-- end
		topup_list[i] = v
		topup_list[i].role_info = self.topupRank_data[i]
		topup_list[i].role_index = i 
	end
	return topup_list
end

function ActivityBrilliantData:GetFirstArrtTop()
	local cfg = self:GetActCfgByIndex(ACT_ID.CZZF)
	if self.topupRank_data[1] and self.topupRank_data[1].rank_count >= cfg.config.rankings[1].count then
		cfg.config.rankings[1].role_info = self.topupRank_data[1]
	end
	return cfg.config.rankings[1]
end

function ActivityBrilliantData:ToproleMation()
	local role_list = {}
	role_list.Topup_value = self.Topup_value
	role_list.Topup_getvalue = self.Topup_getvalue
	role_list.todayRank_num = self.todayRank_num
	return role_list
end

function ActivityBrilliantData:Getawake()
	local cfg = self:GetActCfgByIndex(ACT_ID.CZZF)
	for i,v in ipairs(cfg.config.join_award) do
		local sign = bit:_and(1, bit:_rshift(self.Topup_tag, i))
		if sign == 0 then 
			v.sign = sign
			v.grade = i 
			return v
		end
	end
end

function ActivityBrilliantData:GetawakeList()
	
	local list = {}
	local cfg = self:GetActCfgByIndex(ACT_ID.CZZF)
	for i,v in ipairs(cfg.config.join_award) do
		local vo = v
		vo.sign = bit:_and(1, bit:_rshift(self.Topup_tag, i))
		vo.grade = i
		table.insert(list, vo)
	end

	table.sort(list, function (a, b)
		return a.sign < b.sign
	end)

	return list
end

-------------------------
--消费争锋
-------------------------
function ActivityBrilliantData:GetContendAttr()
	local cfg = self:GetActCfgByIndex(ACT_ID.XFZF)
	local award_list = {}
	for i , v in ipairs(cfg.config.rankings) do
		-- while true do
		-- 	if i == 1 then break end 
		-- award_list[i-1] = v
		-- award_list[i-1].role_info = self.ranking_data[i]
		-- award_list[i-1].role_index  = i
		-- break
		-- end
		award_list[i] = v
		award_list[i].role_info = self.ranking_data[i]
		award_list[i].role_index = i 
	end 
	return award_list
end

function ActivityBrilliantData:GetFirstAttr()
	local cfg = self:GetActCfgByIndex(ACT_ID.XFZF)
	if self.ranking_data[1] and self.ranking_data[1].rank_count >= cfg.config.rankings[1].count then
		cfg.config.rankings[1].role_info = self.ranking_data[1]
	end
	return cfg.config.rankings[1]
end

function ActivityBrilliantData:RoleInformation()
	local role_list = {}
	role_list.ranktoday_num = self.ranktoday_num
	role_list.today_getvalue = self.today_getvalue
	role_list.today_value = self.today_value
	return role_list
end

function ActivityBrilliantData:GetRewardCell()
	local cfg = self:GetActCfgByIndex(ACT_ID.XFZF)
	local cell_list = {}
	for i,v in ipairs(cfg.config.join_award) do
		local sign = bit:_and(1, bit:_rshift(self.get_tag, i))
		if sign == 0 then 
			v.sign = sign
			v.grade = i 
			return v
		end
	end
	local list = cfg.config.join_award[#cfg.config.join_award]
	list.sign = 1
	list.grade = #cfg.config.join_award
	return list
end

function ActivityBrilliantData:Get81Rewards()
	local list = {}
	local cfg = self:GetActCfgByIndex(ACT_ID.XFZF)
	for i,v in ipairs(cfg.config.join_award) do
		local vo = v
		vo.sign = bit:_and(1, bit:_rshift(self.get_tag, i))
		vo.grade = i
		table.insert(list, vo)
	end

	table.sort(list, function (a, b)
		return a.sign < b.sign
	end)

	return list
end

--==============================--
-- 连续返利
--==============================--
function ActivityBrilliantData:GetLianxuFanliList()
	local cfg = self:GetActCfgByIndex(ACT_ID.LXFL)
	local fanli_list = {}
	for i,v in ipairs(cfg.config) do
		if not self.fanli_list[i] then 
			return {}
		end
		fanli_list[i] = {}
		fanli_list[i].pay_money = v.paymoney
		fanli_list[i].grade_list = {}
		for i_1,v_1 in ipairs(v.award) do
			local list = {}
			list.item_index = i_1
			list.pay_money = v.paymoney
			list.awards = v_1
			list.charge_day = self.fanli_list[i].charge_day
			list.grade = i
			list.sign = bit:_and(1, bit:_rshift(self.fanli_list[i].sign, i_1))
			list.freeAwardDay = v.freeAwardDay
			table.insert(fanli_list[i].grade_list, list)
		end
		local list = {}
		list.awards = v.freeAward
		list.item_index = table.getn(v.award) + 1
		list.pay_money = v.paymoney
		list.charge_day = self.fanli_list[i].charge_day
		list.grade = i
		list.sign = bit:_and(1, bit:_rshift(self.fanli_list[i].sign, 0))
		list.freeAwardDay = v.freeAwardDay
		table.insert(fanli_list[i].grade_list, list)
	end
	if not fanli_list[0] and fanli_list[1] then
		fanli_list[0] = table.remove(fanli_list, 1)
	end
	return fanli_list
end
--==============================--
-- 超值转盘
--==============================--
function ActivityBrilliantData:GetDrawIntegral()
	return self.draw_integral
end

function ActivityBrilliantData:GetSVZPDrawRecord()
	local list = {}
	local tag_t = Split(self.cz_draw_record, ";")
	if nil == tag_t then return end
	for i= #tag_t, 1, -1 do
		local str =  Split(tag_t[i], "#")
		local vo = {}
		vo.name = str[1]
		vo.item_name = str[2]
		vo.flag = str[3]
		table.insert(list, vo)
	end
	return list
end
--==============================--
-- 充值返利
--==============================--
function ActivityBrilliantData:GetChargeFanli()
	return self.charge_fanli
end

function ActivityBrilliantData:GetChargeFanliGold(charge_num)
	local act_cfg = self.act_cfg[ACT_ID.CZFL]
	local fanli = 0
	if act_cfg and act_cfg.config then 
		for i,v in ipairs(act_cfg.config) do
			if v.maxPayMoney then 
				if charge_num >= v.minPayMoney and charge_num <= v.maxPayMoney then 
					return charge_num * v.rebateRate / 10000
				end
			else
				if charge_num >= v.minPayMoney then 
					return charge_num * v.rebateRate / 10000
				end
			end
		end
	end
	return fanli
end
--==============================--
-- 元宝放送
--==============================--
function ActivityBrilliantData:GetGoldConsume()
	return self.gold_consume
end
--==============================--
-- 元宝转盘
--==============================--
function ActivityBrilliantData:GetDrawRrecord()
	local list = {}
	local tag_t = Split(self.gold_draw_record, ";")
	if nil == tag_t then return end
	for i= #tag_t, 1, -1 do
		local str =  Split(tag_t[i], "#")
		local vo = {}
		vo.name = str[1]
		vo.mult = str[2]
		vo.gold = str[3]
		table.insert(list, vo)
	end
	return list
end

function ActivityBrilliantData:GetCurDrawGrade()
	return self.cur_draw_grade
end

function ActivityBrilliantData:GetCurChargeMoney()
	return self.cur_charge_money
end

function ActivityBrilliantData:GetUnlockGrade()
	return self.unlock_grade
end
--==============================--
-- 发红包
--==============================--
function ActivityBrilliantData:GetRedPacketIntegral()
	return self.red_packet_integral
end

function ActivityBrilliantData:GetRedPacketRrecord()
	local list = {}
	local tag_t = Split(self.red_packet_record, ";")
	if nil == tag_t then return end
	for i= #tag_t, 1, -1 do
		local str =  Split(tag_t[i], "#")
		local vo = {}
		vo.name = str[1]
		vo.gold = str[2]
		vo.flag = tonumber(str[3])
		table.insert(list, vo)
	end
	return list
end


--==============================--
-- 限时充值
--==============================--
function ActivityBrilliantData:GetLimitChargeList()
	local cfg = self:GetActCfgByIndex(ACT_ID.XSCZ)
	local charge_list = {}
	for i,v in ipairs(cfg.config) do
		local list = {}
		list.index = i
		list.paymoney = v.paymoney
		list.award = v.award
		list.charge_money = self.charge_money
		table.insert(charge_list, list)
	end
	charge_list = self:GetSignListByActId(charge_list, ACT_ID.XSCZ)
	return charge_list
end

--==============================--
-- 充三反四
--==============================--
function ActivityBrilliantData:GetChargeThreeList()
	local cfg = self:GetActCfgByIndex(ACT_ID.CSFS)
	local charge_list = {}
	for i,v in ipairs(cfg.config) do
		if not self.charge_grad_list[i] then 
			return {}
		end
		charge_list[i] = {}
		charge_list[i].pay_money = v.paymoney
		charge_list[i].grade_list = {}
		for i_1,v_1 in ipairs(v.award) do
			local list = {}
			list.item_index = i_1
			list.awards = v_1
			list.charge_day = self.charge_grad_list[i].charge_day
			list.grade = i
			list.cur_day = bit:_and(1, bit:_rshift(self.cur_day, i - 1))
			list.sign = bit:_and(1, bit:_rshift(self.charge_grad_list[i].sign, i_1))
			list.freeAwardDay = v.freeAwardDay
			table.insert(charge_list[i].grade_list, list)
		end
		local list = {}
		list.awards = v.freeAward
		list.item_index = table.getn(v.award) + 1
		list.charge_day = self.charge_grad_list[i].charge_day
		list.cur_day = bit:_and(1, bit:_rshift(self.cur_day, i - 1))
		list.grade = i
		list.sign = bit:_and(1, bit:_rshift(self.charge_grad_list[i].sign, 0))
		list.freeAwardDay = v.freeAwardDay
		table.insert(charge_list[i].grade_list, list)
	end
	if not charge_list[0] and charge_list[1] then
		charge_list[0] = table.remove(charge_list, 1)
	end 
	return charge_list
end

--==============================--
-- 连充福袋
--==============================--
function ActivityBrilliantData:GetChargeDays()
	return self.charge_days
end

function ActivityBrilliantData:GetFudaiList()
	local fudai_list = {}
	local cfg = self:GetActCfgByIndex(ACT_ID.LCFD)
	local cfg_list = cfg.config.ChargeLevels
	for i,v in ipairs(cfg_list) do
		local list = {}
		list.awards = v.award
		list.paymoney = v.paymoney
		list.payday = v.payday
		list.charge_days = self:GetChargeDays()
		list.role_model_effect = v.role_model_effect 
		list.effect_type  = v.effect_type
		list.effect_id = v.effect_id
		table.insert(fudai_list, list)
	end
	fudai_list = self:GetSignListByActId(fudai_list, ACT_ID.LCFD)
	return fudai_list
end

function ActivityBrilliantData:GetFDChargeCount()
	return self.charge_sign_count
end
--==============================--
-- 超值连充
--==============================--
function ActivityBrilliantData:GetChaozhiInfo()
	return self.act_71_info
end

--==============================--
-- 连充返利
--==============================--
function ActivityBrilliantData:GetChargeGrade()
	return self.charge_grade
end

function ActivityBrilliantData:GetChargeDay()
	return self.charge_day
end

function ActivityBrilliantData:GetChargeCount()
	return self.charge_count
end
--==============================--
-- 豪华大礼
--==============================--
function ActivityBrilliantData:GetTotalCharge()
	return self.charge_total
end

function ActivityBrilliantData:GetCurGrade()
	return self.cur_grade
end
--==============================--
-- 绝品限购
--==============================--
function ActivityBrilliantData:GetGradeList()
	return self.grade_list
end

--==============================--
-- 幸运翻牌 began
--==============================--

function ActivityBrilliantData:SetBrandInfo(cards)
	self.opened_num = 0
	self.turn_gold = 0
	self.brand_list = {}
	for k, v in pairs(cards) do
		local cfg_idx = v[1]
		self.brand_list[k] = {item_index = 0, is_open = false, item_data = nil }
		self.brand_list[k].item_index = cfg_idx
		self.brand_list[k].is_open = cfg_idx > 0
		if cfg_idx > 0 then
			self.opened_num = self.opened_num + 1
		end
		self.brand_list[k].item_data = ActivityBrilliantData.GetBrandItemData(v[2], cfg_idx) or CommonStruct.ItemDataWrapper()
	end
	local cfg = self:GetActCfgByIndex(ACT_ID.XYFP)
	if cfg then
		self.turn_gold = cfg.config.extraCostYb[self.opened_num + 1]
	end
end

function ActivityBrilliantData:GetBrandDataList()
	return self.brand_list
end

function ActivityBrilliantData:GetBrandData(index)
	return self.brand_list[index]
end

function ActivityBrilliantData.GetBrandItemData(num, item_index)
	local act_cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.XYFP)
	local items_cfg = act_cfg and act_cfg.config.allCards[num]
	if items_cfg and items_cfg[item_index] then
		return ItemData.FormatItemData(items_cfg[item_index].awards[1])
	end
end

function ActivityBrilliantData:HaveBrandNum()
	return self.opened_num or 0
end

function ActivityBrilliantData:GetCurTurnBrandNeedGold()
	return self.turn_gold
end

function ActivityBrilliantData:GetBrandTimes()
	return self.can_flip_count or 0
end

function ActivityBrilliantData:SetTurnRecordList(type, record_str)
	if record_str == nil then 
		return
	end

	self.brand_record_list = self.brand_record_list or {}
	local group_t = Split(record_str, ";")
	local record_list = {}
	for k, v in pairs(group_t) do
		local record = Split(v, "#")
		record_list[#record_list + 1] = {
			role_name = record[1] or "",
			role_id = tonumber(record[2]),
			item_data = self.GetBrandItemData(tonumber(record[3]), tonumber(record[4])) or CommonStruct.ItemDataWrapper(),
		}
	end
	if type == 1 then
		self.brand_record_list = record_list
	elseif type == 2 then
		ConcatTable(self.brand_record_list, record_list)
	end
end

function ActivityBrilliantData:GetTurnRecordList()
	return self.brand_record_list
end

--==============================--
-- 幸运翻牌 end
--==============================--

--==============================--
-- 神炉炼宝 begin
--==============================--
function ActivityBrilliantData:SetHuntTreasure(treasure_item_num,treasure_item_list)
	self.treasure_item_num = treasure_item_num
	self.treasure_item_list = treasure_item_list
end

function ActivityBrilliantData:GetTreasureScore()
	return self.treasure_score
end

function ActivityBrilliantData:GetTreasureReward()
	return self.treasure_reward
end

function ActivityBrilliantData:GetTreasureRecord()
	return self:GetRewardList(self.treasure_record)
end

function ActivityBrilliantData:GetItemIdByIndex(index)
	local cfg = self:GetActCfgByIndex(ACT_ID.SLLB)
	local id = cfg.config.awardPood[index].id
	return id
end

--==============================--
-- 神炉炼宝 end
--==============================--

--==============================--
-- 龙族秘宝 begin
--==============================--
-- 获取龙族秘宝Data
function ActivityBrilliantData:GetDragonTreasureData()
	return self.dragon_treasure_data
end

-- 获取宝箱奖励领取状态列表
function ActivityBrilliantData:GetDragonTreasureTimesAward()
	local list = self.dragon_treasure_times_award
	local award = self.dragon_treasure_data.times_award
	if list and list.data ~= award then
		list = bit:d2b(award)
		list.data = award
		self.dragon_treasure_times_award = list
	end
	return list
end

-- 获取全服记录
function ActivityBrilliantData:GetDragonTreasureAllLog()
	local log_list = self.dragon_treasure_all_log or {}
	local log = self.dragon_treasure_data.all_log
	local list = {}
	if log_list.data ~= log then
		local log_list = {}
		log_list = Split(log, "@")
		for k, v in pairs(log_list) do
			if v then
				local str_t = Split(v, "#")
				--名字#奖励索引#个数
				local vo = {
					name = str_t[1],
					item_index = str_t[2],
					item_count = str_t[3],
					index = str_t[4],
				}
				table.insert(list, vo)
			end
		end
		list.data = log
		self.dragon_treasure_all_log = list
	end

	return self.dragon_treasure_all_log
end

function ActivityBrilliantData:SetDragonTreasureResults(protocol)
	self.dragon_treasure_results = protocol.dragon_treasure_results
end

function ActivityBrilliantData:GetDragonTreasureResults()
	return self.dragon_treasure_results
end

-- 获取龙族秘宝提醒数量
function ActivityBrilliantData:GetDragonTreasureRemind()
	local data = self.dragon_treasure_data

	local list = ActivityBrilliantData.Instance:GetDragonTreasureTimesAward()
	local cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.LZMB).config
	-- if nil ~= list then
		for i,v in ipairs(list) do
			-- 其中一个未领取和购买次数大于等于配置的要求时,返回1
			if v == 0 then
				if data.buy_times >= cfg.timesAward[i].times then
					return 1
				else
					break
				end
			end
		end
	-- end
	for i = 1, #cfg.things do
		if data[i] > 0 then
			return 1
		end 
	end

	return 0
end

--==============================--
-- 龙族秘宝 end
--==============================--

-------------------------
--多倍返利
-------------------------
function ActivityBrilliantData:GetFanliData()
	local cfg = self.act_cfg[ACT_ID.DBFL]
	local data = {}
	for k, v in pairs(cfg.config) do
		local vo = {
			act_id = cfg.act_id,
			cmd_id = cfg.cmd_id,
			rmb_num = v.rmb,
			zs_num = v.zs_count,
			beishu = v.mult_count,
			remind_num = v.max_tms - self:GetGearTime(v.zs_count),
			is_falg = v.max_tms <= self:GetGearTime(v.zs_count),
		}
		table.insert(data, vo)
	end
	table.sort(data, function (a,b)
		if a.rmb_num < b.rmb_num then
			return true
		end
	end )

	return data
end

--  判断该档位是否还有充值次数
function ActivityBrilliantData:GetGearTime(num)
	for k, v in pairs(self.rechaege_data) do
		if num == v.zs_num then
			return v.change_time
		end
	end
	return 0
end
-------------------------
--多倍返利end
-------------------------

-------------------------
--限时直购
-------------------------
function ActivityBrilliantData:GetZhigouData()
	local cfg = self.act_cfg[ACT_ID.XSZG]
	local data = {}
	for k, v in pairs(cfg.config.paycfg) do
		local vo = {
			act_id = cfg.act_id,
			cmd_id = cfg.cmd_id,
			rmb_num = v.rmb,
			vip_exp = v.svip_exp,
			max_buy_time = v.max_tms,
			gift_name = v.giftName,
			buy_time = self:GetXsGearTime(k),
			is_double = v.mult_count,
			awards = v.awards,
			is_falg = v.max_tms <= self:GetXsGearTime(k),
			is_have_time = v.max_tms <= self:GetXsGearTime(k) and 0 or 1,
		}
		table.insert(data, vo)
	end

	table.sort(data, function (a,b)
		if a.is_have_time == b.is_have_time then
			return a.vip_exp < b.vip_exp
		else
			return a.is_have_time > b.is_have_time
		end
	end )

	return data
end

--  判断该档位是否还有充值次数
function ActivityBrilliantData:GetXsGearTime(num)
	for k, v in pairs(self.rechaege_data) do
		if num == v.zs_num then
			return v.change_time
		end
	end
	return 0
end
-------------------------
--限时直购end
-------------------------

-------------------------
--充值返利
-------------------------
function ActivityBrilliantData:GetFLIndex()
	return self.index_46 or 0
end

function ActivityBrilliantData:GetFanliNumList()
	local cfg = self.act_cfg[ACT_ID.DRAWFL] and self.act_cfg[ACT_ID.DRAWFL].config.rateconfig

	if nil == cfg or nil == next(self.fl_time_list) then return end
	 local data = cfg["non_iso"] --安卓
	 if PLATFORM == cc.PLATFORM_OS_IPHONE or PLATFORM == cc.PLATFORM_OS_IPAD or PLATFORM == cc.PLATFORM_OS_MAC then
	 	data = cfg["ios"] 		--苹果
	 end
	for k,v in pairs(self.fl_time_list) do
		v.reward = data[k].reward or 0
		v.giverate = data[k].giverate * 100 or 0
 	end
	return self.fl_time_list
end

function ActivityBrilliantData:GetFanliRewardList(str, is_person)
	local list = {}
	local tag_t = Split(str, ";")
	if nil == tag_t then return end
	for i= #tag_t, 1, -1 do
		local str2 =  Split(tag_t[i], "#")
		local vo = {}
		vo.name = str2[1]
		vo.gold = str2[2]
		vo.rate = str2[3]
		vo.is_per = is_person
		table.insert(list, vo)
	end
	return list
end

function ActivityBrilliantData:GetQFFanliRecord()
	return self:GetFanliRewardList(self.fl_qf_record)
end

function ActivityBrilliantData:GetGRFanliRecord()
	return self:GetFanliRewardList(self.fl_gr_record, true)
end

function ActivityBrilliantData:GetFanliNum()
	if nil == self.act_cfg[ACT_ID.DRAWFL] then return end
	local have_num = math.floor(self.gold_46_num / self.act_cfg[ACT_ID.DRAWFL].config.consumMoney) 
	if have_num >= self.act_cfg[ACT_ID.DRAWFL].config.maxTime then
		have_num = self.act_cfg[ACT_ID.DRAWFL].config.maxTime
	end
	return have_num - self.draw_46_num
end

function ActivityBrilliantData:GetFanliGold()
	if nil == self.act_cfg[ACT_ID.DRAWFL] then return end
	local num = self.act_cfg[ACT_ID.DRAWFL].config.consumMoney - self.gold_46_num % self.act_cfg[ACT_ID.DRAWFL].config.consumMoney
	if num == 0 then num = self.act_cfg[ACT_ID.DRAWFL].config.consumMoney end
	local have_num = math.floor(self.gold_46_num / self.act_cfg[ACT_ID.DRAWFL].config.consumMoney) 
	if have_num >= self.act_cfg[ACT_ID.DRAWFL].config.maxTime then
		num = 0
	end
	return num
end

-------------------------
--左侧列表
-------------------------
function ActivityBrilliantData:GetTabbarNameList(view_index)
	local name_list = {}
	local num = 1
	local act_name = nil
	for k,v in pairs(self.can_list) do
		-- 没有定义 sub_view_class 说明不出现在主活动界面
		if nil ~= OPER_ACT_CLIENT_CFG[v.act_id] and nil ~= OPER_ACT_CLIENT_CFG[v.act_id].sub_view_class then
			local index = ActivityBrilliantData.Instance:GetOperActViewIndex(v.act_id)
			if index == view_index then
				act_name = self.activity_name[v.act_id]
				if nil ~= act_name then
					local vo = {}
					vo.name = act_name
					vo.act_id = v.act_id
					vo.act_priority = self.act_priority[v.act_id] or 0
					if  vo.act_id ~= 64 and vo.act_id ~= 62 then
						name_list[num] = vo
						num = num + 1
					end
				end
			end
		end
	end
	if #name_list <= 0 then return {} end

	table.sort(name_list, function (a,b)
		if a.act_priority > b.act_priority then
			return true
		end
	end )

	return name_list
end

----------------------
-- 竞技活动奖励列表
----------------------

function ActivityBrilliantData:GetJingJiGearList(act_id, sort)
	local cfg = self.act_cfg[act_id] and self.act_cfg[act_id].config or {}
	local std_awards = cfg.std_awards or {}
	local receive_count_list = self.receive_count_list[act_id] or {}
	local condition_1, condition_2, condition  = self.GetJingJiGearConditions(act_id)
	local list = {}
	for i,v in ipairs(std_awards) do
		list[i] = {}
		list[i].cfg = v
		list[i].index = i
		list[i].act_id = act_id
		list[i].condition_1 = condition_1
		list[i].condition_2 = condition_2
		list[i].condition = condition
		list[i].receive_count = receive_count_list[i] or 0
	end
	list = self:GetSignListByActId(list, act_id)

	if sort then -- 用于红点提示判断时,不需要排序
		table.sort(list, function(a, b)
			if a.sign ~= b.sign then
				return a.sign < b.sign
			else
				return a.index < b.index
			end
		end)
	end

	return list
end

-- 获取活动档位 需要达标的对应值
function ActivityBrilliantData.GetJingJiGearConditions(act_id)
	-- condition 用于区分条件只有一个值的,显示要分割成两个值,的活动达标判断.不需要使用时,为nil值

	-- condition_1, condition_2, condition 对应接口 GetJingJiGearValue 所返回的 cfg_value1, cfg_value2, cfg_value
	
	local condition_1, condition_2, condition  = 0, 0
	if act_id == ACT_ID.DJJJ then
		condition_1 = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL) -- 级
		condition_2 = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)	 -- 转
	elseif act_id == ACT_ID.CBJJ then
		local wing_level = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SWING_LEVEL)
		-- 阶, 星
		condition_2, condition_1 = WingData.GetWingLevelAndGrade(wing_level)
		condition = wing_level
	elseif act_id == ACT_ID.ZCJJ then
		local zc_data = ZhanjiangCtrl.Instance:GetData(HERO_TYPE.ZC)
		condition_1 = zc_data:GetPart()-- 星
		condition_2 = zc_data:GetJie() -- 阶
		condition = zc_data:Getlevel()
	elseif act_id == ACT_ID.BSJJ then
		local slot_data = GodFurnaceData.Instance:GetSlotData(GodFurnaceData.Slot.GemStonePos)
		condition_1 = GodFurnaceData:GetStarNum(slot_data.level) -- 星
		condition_2 = GodFurnaceData:GetGradeNum(slot_data.level)-- 阶
		condition = slot_data.level
	elseif act_id == ACT_ID.HZJJ then
		local slot_data = GodFurnaceData.Instance:GetSlotData(GodFurnaceData.Slot.DragonSpiritPos)
		condition_1 = GodFurnaceData:GetStarNum(slot_data.level) -- 星
		condition_2 = GodFurnaceData:GetGradeNum(slot_data.level)-- 阶
		condition = slot_data.level
	elseif act_id == ACT_ID.RXJJ then
		condition_1 = ActivityBrilliantData.Instance:GetOtherPower(act_id) -- 热血总战力
	elseif act_id == ACT_ID.ZLJJ then
		condition_1 = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_BATTLE_POWER) -- 玩家总战力
	elseif act_id == ACT_ID.JBJJ then
		condition_1 = AuthenticateData.Instance:GetAllEquipStar() -- 锻造-鉴宝 全身总星级
	elseif act_id == ACT_ID.SHJJ then
		condition_1 = ActivityBrilliantData.Instance:GetOtherPower(act_id) -- 守护总战力
	end

	return condition_1, condition_2, condition
end

function ActivityBrilliantData.GetJingJiGearValue(act_id, cfg)
	-- cfg_value 用于区分条件只有一个值的,显示要分割成两个值,的活动达标判断.不需要使用时,为nil值

	-- cfg_value1, cfg_value2, cfg_value 对应接口 GetJingJiGearConditions 所返回的 condition_1, condition_2, condition

	local cfg_value1, cfg_value2, cfg_value = 0, 0
	if act_id == ACT_ID.DJJJ then
		cfg_value1 = cfg.value1 or 0 -- 级
		cfg_value2 = cfg.value2 or 0 -- 转
	elseif act_id == ACT_ID.CBJJ then
		-- 星, 阶
		cfg_value2, cfg_value1 = WingData.GetWingLevelAndGrade(cfg.value or 0)
		cfg_value = cfg.value
	elseif act_id == ACT_ID.ZCJJ then
		local level = cfg.value
		local zc_data = ZhanjiangCtrl.Instance:GetData(HERO_TYPE.ZC)
		cfg_value1 = zc_data:GetPart(level)-- 星
		cfg_value2 = zc_data:GetJie(level) -- 阶
		cfg_value = cfg.value
	elseif act_id == ACT_ID.BSJJ then
		local level = cfg.value
		cfg_value1 = GodFurnaceData:GetStarNum(level) -- 星
		cfg_value2 = GodFurnaceData:GetGradeNum(level)-- 阶
		cfg_value = cfg.value
	elseif act_id == ACT_ID.HZJJ then
		local level = cfg.value
		cfg_value1 = GodFurnaceData:GetStarNum(level) -- 星
		cfg_value2 = GodFurnaceData:GetGradeNum(level)-- 阶
		cfg_value = cfg.value
	elseif act_id == ACT_ID.RXJJ then
		cfg_value1 = cfg.value -- 热血战力
	elseif act_id == ACT_ID.ZLJJ then
		cfg_value1 = cfg.value -- 战力
	elseif act_id == ACT_ID.JBJJ then
		cfg_value1 = cfg.value -- 星
	elseif act_id == ACT_ID.SHJJ then
		cfg_value1 = cfg.value -- 守护战力
	end

	return cfg_value1, cfg_value2, cfg_value
end

function ActivityBrilliantData:SetOtherPower(protocol)
	if self.rexue_power ~= protocol.rexue_power then
		RemindManager.Instance:DoRemindDelayTime(REMIND_ACT_LIST[ACT_ID.RXJJ])
	end

	if self.guard_equip_power ~= protocol.guard_equip_power then
		RemindManager.Instance:DoRemindDelayTime(REMIND_ACT_LIST[ACT_ID.SHJJ])
	end

	self.rexue_power = protocol.rexue_power 			 -- 热血总战力 用于运营活动 22 ACT_ID.RXJJ
	self.guard_equip_power = protocol.guard_equip_power	 -- 守护总战力 用于运营活动 30 ACT_ID.SHJJ
end

function ActivityBrilliantData:GetOtherPower(act_id)
	local power = 0
	if act_id == ACT_ID.RXJJ then
		power = self.rexue_power or 0
	elseif act_id == ACT_ID.SHJJ then
		power = self.guard_equip_power or 0
	end

	return power
end

function ActivityBrilliantData:GetJingJiRankingList(act_id)
	--排行榜数据格式{[1] = {[1]=排名 [2]=玩家名 [3]=值 [4]=玩家角色ID [5]=玩家职业 [6]=玩家性别} ... }
	return self.rank_list[act_id] or {}
end

----------------------
--奖励记录
----------------------
function ActivityBrilliantData:GetRewardList(str)
	local list = {}
	if nil == str then return {} end
	local tag_t = Split(str, ";")
	for i= #tag_t, 1, -1 do
		local str2 =  Split(tag_t[i], "#")
		local vo = {}
		vo.name = str2[1]
		vo.index = tonumber(str2[2])
		vo.num = tonumber(str2[3])
		table.insert(list, vo)
	end
	return list
end

function ActivityBrilliantData:GetGoldRewardList(str)
	local list = {}
	if nil == str then return {} end
	local tag_t = Split(str, ";")
	for i= #tag_t, 1, -1 do
		local str2 =  Split(tag_t[i], "#")
		local vo = {}
		vo.name = str2[1]
		vo.grid_index = tonumber(str2[2])
		vo.award_index = tonumber(str2[3])
		vo.num = tonumber(str2[4])
		table.insert(list, vo)
	end
	return list
end

function ActivityBrilliantData:GetYaoqianList()
	return self.yaojiang_list
end

function ActivityBrilliantData:GetXunbaoList()
	return self.xunbao_list
end

function ActivityBrilliantData:GetTurntableList()
	return self.turntable_list
end

-------------------------
--砸蛋活动
-------------------------
function ActivityBrilliantData:GetDestorList()
	local sign_list = {}
	for i=1, 12 do
		local vo = {
			sign = 0,
			idx = 0,
		}
		for k,v in pairs(self.num_2_list) do
			if v.value == i then
				if self.num_list[k] then
					vo.idx = self.num_list[k].value
					vo.award_idx = self.num_list[k].idx
				end
				break
			end
		end
		sign_list[i] = vo
	end
	sign_list = self:GetSignListByActId(sign_list,ACT_ID.EGG)

	return sign_list
end

function ActivityBrilliantData:GetEggGold()
	local cfg = self.act_cfg[34]
	if nil == cfg then return end

	local num = 0
	local draw_num = self.mine_num[34] or 0
	local gold = 0
	local list = self:GetDestorList()
	for k,v in pairs(list) do
		if v.sign == 1 then
			num = num + 1
		end
	end
	num = num + draw_num 	-- 已获取数量 + 可抽取数量
	if num == 0 then 
		gold = cfg.config.egg_award[1].money
	elseif cfg.config.egg_award[num + 1] then
		gold = cfg.config.egg_award[num + 1].money - cfg.config.egg_award[num].money
	else
		gold = 0
	end
	return gold
end

-------------------------
--获取排行列表
-------------------------
function ActivityBrilliantData:GetRankList(act_id)
	local rank_list = {}
	if nil == self.act_cfg[act_id] then return end
	for i = 1, #self.act_cfg[act_id].config.rankings  do
		local cfg = self.act_cfg[act_id].config or {}
		local count = cfg.rankings and cfg.rankings[i] and cfg.rankings[i].count
		rank_list[i] = self.rank_list[act_id][i] or {i, Language.Common.XuWenYiDai, count}
		rank_list[i].act_id = act_id
	end
	if self.act_cfg[act_id].config.join_award then 
		local pos = #rank_list + 1
		rank_list[pos] =  {pos,Language.Common.XuWenYiDai,self.is_lingqu[act_id], is_jion = true}
		rank_list[pos].act_id = act_id
	end
	return rank_list
end

---------------------
--其他活动
---------------------
--抢购
function ActivityBrilliantData:GetQianggouItemList()
	local qinggou_item_list = {}
	local cfg = self.act_cfg[ACT_ID.QG] 
	if nil == cfg  then return end
	for i = 1, #self.item_list do
		if nil == self.item_list[i] then return end
		local item = cfg.config.items[self.item_list[i]]
		item.index = i
		table.insert(qinggou_item_list, item)
	end
	qinggou_item_list = self:GetSignListByActId(qinggou_item_list,ACT_ID.QG)
	return qinggou_item_list
end

--连续充值
function ActivityBrilliantData:GetLXchargeItemList(act_id)
	local lx_charge_item_list = {}
	local cfg = self.act_cfg[act_id] 
	if nil == cfg  then return end
	for i = 1, #cfg.config.listTbl do
		if nil == cfg.config.listTbl[i] then return end
		local item = cfg.config.listTbl[i].award
		item.keepday = cfg.config.listTbl[i].keepday
		item.payday = self.mine_num[act_id]
		item.index = i
		item.act_id = act_id
		table.insert(lx_charge_item_list,item)
	end
	lx_charge_item_list = self:GetSignListByActId(lx_charge_item_list, act_id)

	table.sort( lx_charge_item_list, function (a,b)
		if a.sign ~= b.sign then
			return a.sign < b.sign
		else
			return a.index < b.index
		end
	end)

	return lx_charge_item_list
end

--单笔充值
function ActivityBrilliantData:GetSinglechargeItemList()
	self.sign_num = 0
	local single_charge_item_list = {}
	local cfg = self.act_cfg[ACT_ID.DBCZ] 
	if nil == cfg  then return end
	for i=1,#cfg.config do
		local cur_cfg = cfg.config and cfg.config[i]
		if type(cur_cfg) ~= "table" then return end
		local item = {}
		item.award = cur_cfg.award
		item.times = cur_cfg.times
		item.money_start = cur_cfg.money[1]
		item.money_end = cur_cfg.money[2]
		item.show_money = cur_cfg.show_money
		item.lingqu_times = self.lingqu_47_times[i].index
		item.sign_times = self.sign_47_times[i].times
		item.sign = item.lingqu_times > item.sign_times and 1 or 0
		item.is_lingqu = item.times == item.sign_times and 1 or 0
		item.index = i
		table.insert(single_charge_item_list,item)
	end
	table.sort( single_charge_item_list, function (a,b)
		if a.is_lingqu ~= b.is_lingqu then
			return a.is_lingqu < b.is_lingqu
		elseif a.sign ~= b.sign then
			return a.sign > b.sign
		else
			return a.index < b.index
		end
	end)
	return single_charge_item_list
end

--特惠礼包
function ActivityBrilliantData:GetTHlibaoItemList()
	local th_giftbag_item_list = {}
	local cfg = self.act_cfg[ACT_ID.THLB] or {}
	local act_cfg = cfg.config or {}
	for i = 1, #act_cfg do
		local item = {}
		item.cfg = act_cfg[i] or {}
		item.is_buy = self.thlb_buy_times_list[i] or 0
		item.index = i
		table.insert(th_giftbag_item_list,item)
	end
	th_giftbag_item_list[0] = table.remove(th_giftbag_item_list, 1)

	return th_giftbag_item_list
end

--全民抢购
function ActivityBrilliantData:GetQmQianggouItemList()
	local qm_qinggou_item_list = {}
	local cfg = self.act_cfg[ACT_ID.QMQG] 
	if nil == cfg  then return end
	for i=1,#self.qm_item_list do
		if nil == self.qm_item_list[i] then return end
		local item = cfg.config.items[self.act_day][self.qm_item_list[i].idx]
		item.index = i
		item.act_day = self.act_day
		item.buy_num = self.qm_item_list[i].spare_times
		table.insert(qm_qinggou_item_list, item)
	end
	qm_qinggou_item_list = self:GetSignListByActId(qm_qinggou_item_list,ACT_ID.QMQG)
	table.sort(qm_qinggou_item_list, function(a, b)
		if a.sign ~= b.sign then
			return a.sign < b.sign
		else
			return a.index < b.index
		end
	end)

	return qm_qinggou_item_list
end

--节日狂欢
function ActivityBrilliantData:GetJieriItemList()
	local jieri_item_list = {}
	local cfg = self.act_cfg[ACT_ID.JR] 
	if nil == cfg  then return end
	for i=1,#cfg.config.exchanges do
		local item = cfg.config.exchanges[i]
		item.index = i
		local num = 0
		-- 避免出现重复的物品
		local consume_list = {}
		for k,v in pairs(item.consume) do
			local item_id = v.id or 0
			local count = consume_list[v.id] or 0
			local cfg_count = v.count or 0
			consume_list[v.id] = count + v.count
		end

		item.can_lingqu = true
		for k,v in pairs(consume_list) do
			local have_num =  BagData.Instance:GetItemNumInBagById(k)
			item.can_lingqu = item.can_lingqu and have_num >= v
		end
		
		table.insert(jieri_item_list, item)
	end
	jieri_item_list = self:GetSignListByActId(jieri_item_list,ACT_ID.QMQG)
	return jieri_item_list
end

--兑换列表
function ActivityBrilliantData:GetDuihuanItemList()
	local duihuan_item_list = {}
	local cfg = self.act_cfg[ACT_ID.DH]
	if nil == cfg  then return end
	for i=1,#cfg.config do
		local item = cfg.config[i]
		item.index = i
		item.my_num = self.duihuan_num_list[i] or 0
		item.all_num = self.duihuan_num_2_list[i] or 0
		if self.mine_num[cfg.act_id] and self.mine_num[cfg.act_id] >= item.cost then 
			item.can_duihuan = true
		else
			item.can_duihuan = false
		end
		table.insert(duihuan_item_list, item)
	end
	duihuan_item_list = self:GetSignListByActId(duihuan_item_list,ACT_ID.DH)
	return duihuan_item_list
end

--商店列表
function ActivityBrilliantData:GetShopItemList()
	local shop_item_list = {}
	local cfg = self.act_cfg[ACT_ID.SHOP] 
	if nil == cfg  then return end
	for i=1,#self.shop_item_list do
		if nil == self.shop_item_list[i] then return end
		local item = cfg.config.items[self.shop_item_list[i]].award
		item.index = i
		item.money = cfg.config.items[self.shop_item_list[i]].money
		item.old_money = cfg.config.items[self.shop_item_list[i]].money_old
		item.money_type = cfg.config.items[self.shop_item_list[i]].money_type
		table.insert(shop_item_list, item)
	end
	shop_item_list = self:GetSignListByActId(shop_item_list, ACT_ID.SHOP)
	return shop_item_list
end

--寻宝奖励
function ActivityBrilliantData:GetXunbaoRewardList()
	local xunbao_reward_list = {}
	local cfg = self.act_cfg[ACT_ID.XB] 
	if nil == cfg then return end
	for i=1,#cfg.config do
		table.insert(xunbao_reward_list,cfg.config[i])
		xunbao_reward_list[i].index = i
	end
	xunbao_reward_list = self:GetSignListByActId(xunbao_reward_list,ACT_ID.XB)
	table.sort(xunbao_reward_list, function(a, b)
		if a.sign ~= b.sign then
			return a.sign < b.sign
		else
			return a.index < b.index
		end
	end)
	return xunbao_reward_list
end

--元宝装备，右侧奖励列表
function ActivityBrilliantData:GetTurntableRewardList()
	local turntable_reward_list = {}
	local cfg = self.act_cfg[ACT_ID.GOLDZP] 
	if nil == cfg then return end
	for i=1,#cfg.config.add_tms_award do
		table.insert(turntable_reward_list,cfg.config.add_tms_award[i])
		turntable_reward_list[i].index = i
		turntable_reward_list[i].sign = 0
		turntable_reward_list[i].act_id = ACT_ID.GOLDZP
		turntable_reward_list[i].draw_num = self.gold_draw_num
	end
	turntable_reward_list = self:GetSignListByActId(turntable_reward_list,ACT_ID.GOLDZP)
	table.sort(turntable_reward_list, function(a, b)
		if a.sign ~= b.sign then
			return a.sign < b.sign
		else
			return a.index < b.index
		end
	end)
	return turntable_reward_list
end

---------------------
--获取数据
---------------------
function ActivityBrilliantData:SetTodayRecharge(count)
	self.today_charge_gold_count =  count
end

function ActivityBrilliantData:GetTodayRecharge()
	-- return self.today_charge_gold_count or 0
	return OtherData.Instance:GetDayChargeGoldNum()
end

function ActivityBrilliantData:GetMineNumByActId(act_id)
	return self.mine_num[act_id] or 0
end

function ActivityBrilliantData:GetJackpotNum()
	return self.jackpot
end

function ActivityBrilliantData:GetXFZPDrawNum()
	return self.xf_draw_num 
end

function ActivityBrilliantData:GetXFZPAllDrawNum()
	return self.all_draw_num 
end

function ActivityBrilliantData:GetGoldTurnbleDrawNum()
	return self.gold_draw_num 
end

-------------------------
--获得提醒数
------------------------
function ActivityBrilliantData:GetRemindNumByType(remind_name)
	local remind_num = 0
	local act_id = self:GetActIdByRemindName(remind_name)
	local cfg = self.act_cfg[act_id]
	if nil == cfg then return 0 end

	if remind_name == RemindName.ActivityBrilliantYaoqian then
		if self.yaoqian_num == cfg.config.params[2] then
			return 0 
		end
		local yq_time_jg = cfg.config.params[1] * 60
		if self.yaoqian_time and self.yaoqian_time - self.yaoqian_num * yq_time_jg > yq_time_jg then 
			remind_num = 1
		end
	elseif remind_name == RemindName.ActivityBrilliantDenglu then
		local activity_day = math.floor((TimeCtrl.Instance:GetServerTime() - cfg.beg_time) / (24 * 60 * 60)) + 1
		local list = self:GetSignListByActId(cfg.config.award,ACT_ID.DL)
		for i,v in ipairs(list) do
			if  i == activity_day and v.sign == 0 then
				return 1
			end
		end
	elseif remind_name == RemindName.ActivityBrilliantLeichong then
		local num = 0
		local list = self:GetSignListByActId(cfg.config,ACT_ID.LC)
		for i,v in ipairs(list) do
			if v.sign == 0 and self:GetTodayRecharge() >= v.money then
				num = num + 1
			end
		end
		remind_num = num
	elseif remind_name == RemindName.ActivityBrilliantBaoshi then
		local num = 0
		local list = self:GetSignListByActId(cfg.config, act_id)
		if nil == list then return 0 end
		for i,v in ipairs(list) do
			if v.sign == 0 and self.jiejing_num[act_id] >= v.count then
				num = num + 1
			end
		end
		remind_num = num
	elseif false
	or remind_name == RemindName.ActivityBrilliantDJJJ
	or remind_name == RemindName.ActivityBrilliantCBJJ
	or remind_name == RemindName.ActivityBrilliantZCJJ
	or remind_name == RemindName.ActivityBrilliantBSJJ
	or remind_name == RemindName.ActivityBrilliantHZJJ
	or remind_name == RemindName.ActivityBrilliantRXJJ
	or remind_name == RemindName.ActivityBrilliantZLJJ
	or remind_name == RemindName.ActivityBrilliantJBJJ
	or remind_name == RemindName.ActivityBrilliantSHJJ
	then
		local num = 0
		local list = self:GetJingJiGearList(act_id, false) -- false 表示不排序
		for i,v in ipairs(list) do
			local cur_cfg = v.cfg or {}
			local cur_count = cur_cfg.count or 0
			if cur_count > v.receive_count then -- 还有剩余名额
				if v.sign == 0 then -- 未领取
					local value1, value2, value = self.GetJingJiGearValue(act_id, cur_cfg)
					if value and v.condition then
						if v.condition >= value then
							num = num + 1
						end
					elseif v.condition_1 >= value1 and v.condition_2 >= value2 then -- 满足档位条件
						num = num + 1
					end
				end
			end
		end
		remind_num = num
	elseif remind_name == RemindName.ActivityBrilliantXunbao then
		local num = 0
		local list = self:GetSignListByActId(cfg.config,ACT_ID.XB)
		for i,v in ipairs(list) do
			if v.sign == 0 and self.xunbao_num >= v.count then
				num = num + 1
			end
		end
		remind_num = num
	elseif remind_name == RemindName.ActivityBrilliantZhuanpan then
		if self:IsZPLingqu() then return 1 end
	elseif remind_name == RemindName.ActivityBrilliantShizhuang then
		local lq_limit =  cfg and cfg.config.params[1] or 0
		local reward_count = math.floor(self.spare_szxb_num / lq_limit)
		if reward_count > 0 then return 1 end
	elseif remind_name == RemindName.ActivityBrilliantCJXunbao then
		local lq_limit =  cfg and cfg.config.params[1] or 0
		local reward_count = math.floor(self.spare_xb_num / lq_limit)
		if reward_count > 0 then return 1 end
	elseif remind_name == RemindName.ActivityBrilliantLeiji then
		local num = 0
		local list = self:GetSignListByActId(cfg.config,ACT_ID.LJ)
		for i,v in ipairs(list) do
			if v.sign == 0 and self.all_charge >= v.money then
				num = num + 1
			end
		end
		remind_num = num
	elseif remind_name == RemindName.ActivityBrilliantCfcharge then
		local is_lingqu = self:GetTodayRecharge() - cfg.config.params[1] *  self.lingqu_num >= cfg.config.params[1] and true or false
		if  self.lingqu_num < cfg.config.params[2] and is_lingqu then 
			remind_num = 1
		else 
			return 0
		end 
	elseif remind_name == RemindName.ActivityBrilliantBaozan then
		local num = 0
		local list = self:GetSignListByActId(cfg.config,ACT_ID.BZ)
		for i,v in ipairs(list) do
			if v.sign == 0 and self.baozan_num >= v.times  then
				num = num + 1
			end
		end
		remind_num = num
	elseif remind_name == RemindName.ActivityBrilliantChargeGF or
		   remind_name == RemindName.ActivityBrilliantXiaofeiGF or
		   remind_name == RemindName.ActivityBrilliantCZrank or 
		   remind_name == RemindName.ActivityBrilliantXFgift then 
		if self.is_lingqu[cfg.act_id] == 0 and cfg.config.join_award and self.mine_num[cfg.act_id] >= cfg.config.join_award.count then
			remind_num = 1
		end
	elseif remind_name == RemindName.ActivityBrilliantshengzhuHK then
		local num = 0
		local list = self:GetSignListByActId(cfg.config,cfg.act_id)
		for i,v in ipairs(list) do
			if v.sign == 0 and self.jiejing_num[cfg.act_id] >= v.count then
				num = num + 1
			end
		end
		remind_num = num
	elseif  remind_name == RemindName.ActivityBrilliantKHHD then 
		local num = 0
		local config = cfg.config or {}
		local commitaward = config.commitaward or {}
		local max_happiness = commitaward.needhappiness or 0
		local happiness = self.sign[act_id] or 0 -- 幸福度
		local receive_times = self.mine_num[act_id] or 0 -- 已领取特殊奖励次数
		local daytimes = commitaward.daytimes or 0
		if receive_times < daytimes and happiness >= max_happiness then
			num = num + 1
		end

		remind_num = num
	elseif remind_name == RemindName.ActivityBrilliantLCgift then
		if self.draw_num > 0 then 
			remind_num = 1
		end
	elseif remind_name == RemindName.ActivityBrilliantXFZhuanpan then 
		local act_cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.XFZP)
		local can_draw = ActivityBrilliantData.Instance:GetXFZPDrawNum() > 0 and ActivityBrilliantData.Instance:GetXFZPAllDrawNum() - ActivityBrilliantData.Instance:GetXFZPDrawNum() < act_cfg.config.params[2]
		if can_draw then
			remind_num = 1
		end
	elseif remind_name == RemindName.ActivityBrilliantQmXiaofei
		or remind_name == RemindName.ActivityBrilliantXiaofeiHK then
		self:GetXiaofeiSignList(cfg.act_id) -- 设置领取标记
		for i,v in ipairs(cfg.config or {}) do
			if v.sign == 0 and self.consum_gold[cfg.act_id] >= v.numbers then
				remind_num = 1
			end
		end
	elseif remind_name == RemindName.Goldturntable then
		local num = 0
		local list = self:GetSignListByActId(cfg.config.backs,cfg.act_id)
		for i,v in ipairs(list) do
			if v.sign == 0 and self.gold_draw_num >= v.count then
				num = num + 1
			end
		end
		remind_num = num
	elseif remind_name == RemindName.ActivityBrilliantDegree or
		   remind_name == RemindName.ActivityBrilliantBoss then
		local num = 0
		local list = self:GetSignListByActId(cfg.config,cfg.act_id)
		for i,v in ipairs(list) do
			if v.sign == 0 and self.mine_num[cfg.act_id] >= v.numbers then
				num = num + 1
			end
		end
		remind_num = num
	elseif remind_name == RemindName.ActivityBrilliantEgg then
		local num = 0
		local list = self:GetSignListByActId(cfg.config,cfg.act_id)
		if self.mine_num[cfg.act_id] and self.mine_num[cfg.act_id] > 0 then
			remind_num = 1
		end
		local list = self:GetSignListByActId(cfg.config,cfg.act_id)
		for i,v in ipairs(list) do
			if v.sign == 1  then
				num = num + 1
			end
		end
		if num == 9 and list[10] == 0 then 
			remind_num = 1
		end
	elseif remind_name == RemindName.ActivityBrilliantQMQG then
		local num = 0
		local beg_time = os.date("*t",cfg.beg_time)
		local now_time =  os.date("*t",TimeCtrl.Instance:GetServerTime())
		local activity_day = now_time.day - beg_time.day + 1
		if nil == cfg.config.items[activity_day] then return 0 end
		local list = self:GetSignListByActId(cfg.config.items[activity_day],cfg.act_id)
		for i,v in ipairs(list) do
			if v.sign == 0  then
				num = num + 1
			end
		end
		remind_num = num
	elseif remind_name == RemindName.ActivityBrilliantJieri then
		local num = 0
		local list = self:GetJieriItemList()
		for k,v in pairs(list) do
			if v.can_lingqu then
				remind_num = remind_num + 1
			end
		end
	elseif remind_name == RemindName.ActivityBrilliantDuihuan then
		for k,v in pairs(cfg.config) do
			if self.mine_num[cfg.act_id] and self.mine_num[cfg.act_id] >= v.cost then
				remind_num = 1
				break
			end
		end
	elseif remind_name == RemindName.ActivityBrilliantLXcharge or 
		remind_name == RemindName.ActivityBrilliantLXCZ2 then
		local num = 0
		local list = self:GetSignListByActId(cfg.config.listTbl, act_id)
		for i,v in ipairs(list) do
			if v.sign == 0 and self.mine_num[act_id] >= v.keepday then
				num = num + 1
			end
		end

		remind_num = num
	elseif remind_name == RemindName.ActivityBrilliantGGAward then
		remind_num = self:GetNoticeActRemindNum()
	elseif remind_name == RemindName.ActivityBrilliantCZfudai then
		local num = 0
		local list = self:GetSignListByActId(cfg.config.awardList,ACT_ID.FD)
		for i,v in ipairs(list) do
			if v.sign == 0 and self.mine_num[ACT_ID.FD] >= v.buytime then
				num = num + 1
			end
		end
		remind_num = num
	elseif remind_name == RemindName.ActivityBrilliantLKDraw then
		remind_num = self.lk_draw_num
	elseif remind_name == RemindName.ActivityBrilliantTHlibao then
		-- 未添加至提示组
		local act_cfg = cfg.config or {}
		for i = 1, #act_cfg do
			local num = self.thlb_buy_times_list[i] or 0
			local cur_cfg = act_cfg[i] or {}
			local can_buy_times = cur_cfg.buyCount or 0
			if num < can_buy_times then
				remind_num = remind_num + 1
			end
		end
	elseif remind_name == RemindName.ActivityBrilliantDrawFL then
		remind_num = self:GetFanliNum()
	elseif remind_name == RemindName.ActivityBrilliantSingleCharge then
		local num = 0
		local list = self:GetSignListByActId(cfg.config, ACT_ID.DBCZ)
		for i,v in ipairs(list) do
			if  self.sign_47_times[i] and self.lingqu_47_times[i] and v.times > self.sign_47_times[i].times 
			and self.lingqu_47_times[i].index > self.sign_47_times[i].times then -- 已领取数量小于总数量并显示数量大于已领取数量
				num = num + 1   --即可领取数量
			end
		end 
		remind_num = num
	elseif remind_name == RemindName.ActivityBrilliantXFGIFTFT then
		local have_time = math.floor(self.mine_num[ACT_ID.XFGIFTFT] / cfg.config.money) - self.lingqu_num_52
		if have_time > 0 then
			remind_num = 1
		end
	elseif remind_name == RemindName.ActivityBrilliantCZZP then
		if self:GetCZZPData().draw_num > 0 then
			remind_num = 1
		end
	elseif remind_name == RemindName.ActivityBrilliantJQPD then
		if self.mine_num[ACT_ID.JQPD] >= cfg.config.join_award.count and self.is_lingqu[ACT_ID.JQPD] == 0 then
			remind_num = 0
		end
		for k,v in pairs(self:GetJQPDLeftItemList()) do
			if v.sign == 0 and self.mine_num[ACT_ID.JQPD] >= v.score then
				remind_num = 1
				break
			end
		end
	elseif remind_name == RemindName.ActCanbaoge then
		if self:CheckAndGetStepCanLingquIdx() or self:CheckAndGetFloorCanLingquIdx() then
			remind_num = 1
		end
	elseif remind_name == RemindName.ActivityBrilliantZBG then
		local vip_level = VipData.Instance:GetVipLevel()
		for i = 1, #cfg.config.refreshtimes do
			local sign = bit:_and(1, bit:_rshift(self.flush_sign, i - 1))
			local times = cfg.config.refreshtimes[i].times
			local viplv = cfg.config.refreshtimes[i].viplv
			if sign == 0 and self.flush_times >= times and vip_level >= viplv then
				remind_num = 1
				break
			end
		end
	elseif remind_name == RemindName.ActivityBrilliantJPDH then
		local list = self:GetSuperExchangeList()
		local is_can_exc = true
		for k,v in ipairs(list) do
			if v.personLimit > 0 and v.personLimit <= v.gr_num then
				is_can_exc = false
			else
				for k2,v2 in pairs(v.consume) do
					if BagData.Instance:GetItemNumInBagById(v2.id) < v2.count then
						is_can_exc = false
						break
					end
				end
			end
			if is_can_exc then 
				remind_num = 1
				break
			end
		end
	elseif remind_name == RemindName.ActivityBrilliantJDBS then
		local list = self:GetBossKillList()
		for i, k in ipairs(list) do
			local temp = 0
			for i = 1, k.boss_num do
				if k[i] == 1 then
					temp = temp + 1
				end
			end
			if temp == k.boss_num and k.awake_sign == 0 then
				remind_num = 1
			end
		end
	elseif remind_name == RemindName.ActivityBrilliantLXFL then
		local list = self:GetLianxuFanliList()
		for i, v in ipairs(list) do
			for j, k in ipairs(v.grade_list) do
				if k.item_index <= k.charge_day  and k.sign == 0 then
					remind_num = 1
				end
			end
		end
	elseif remind_name == RemindName.ActivityBrilliantXFZF then
		local list = self:GetRewardCell()
		local value = self:RoleInformation().today_value 
		if list and list.sign == 0 and list.count <= value then
			 remind_num = 1
		end
	elseif	remind_name == RemindName.ActivityBrilliantCZZF then
		local list = self:Getawake()
		local value = self:ToproleMation().Topup_value
		if list and list.sign == 0 and list.count <= value then
			remind_num = 1
		end
	-- elseif remind_name == RemindName.ActivityBrilliantXSZG then
		-- local list = self:LegendAward()
		-- local value = self:LegendMation().Legend_getvalue
		-- if list.sign == 0 and list.count <= value then
		-- 	remind_num = 1 
		-- end
	elseif	remind_name == RemindName.ActivityBrilliantYSJD then
		local list = self:GetActCfgByIndex(ACT_ID.YSJD).config.openCount
		local count = self:GetMationList().All_open_count
		local list_tag = self:GetGiftTag()
		for i,v in ipairs(list) do
			if count >= v and list_tag[i] == 0 then
				remind_num = 1
			end
		end
	elseif remind_name == RemindName.ActivityBrilliantZPHL then
		local have_score = ActivityBrilliantData.Instance:GetZPHLScore()
   		local cost_score = ActivityBrilliantData.Instance:GetIndexCostScore()

   		remind_num = have_score > cost_score and 1 or 0
	elseif remind_name == RemindName.ActivityBrilliantXFJL then
		local list = self:GetGoldPayList()
		local daily_pay_num = self:GetActDaily()
		for i, v in ipairs(list) do
			if daily_pay_num >= v.numbers and v.sign == 0 then
				remind_num = 1
			end
		end
	elseif remind_name == RemindName.ActivityBrilliantSLLB then
		local cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.SLLB)
		local num = 0
		for i = 1, #cfg.config.integralAward do
			local list = bit:d2b(self:GetTreasureReward())
			local is_finished = list[33- i]
			if is_finished == 0 and self:GetTreasureScore() >= cfg.config.integralAward[i].needIntegral then
				num = num + 1
			end
		end
		remind_num = num
	elseif remind_name == RemindName.ActivityBrilliantLZMB then
		remind_num = self:GetDragonTreasureRemind()
	elseif remind_name == RemindName.ActivityBrilliantFHB then
		remind_num = self:GetRemindRedNum()
	elseif remind_name == RemindName.ActivityBrilliantGZP then
		remind_num = self:GetZhuanPanRemindNum()
	elseif remind_name == RemindName.ActivityBrillianXYFP then
		remind_num = self:GetBrandTimes()
	elseif remind_name == RemindName.ActivityBrillianHHDL then
		remind_num = self:GetHHDLREMIND()
	elseif remind_name == RemindName.ActivityBrillianLCFL then
		remind_num = self:GetLCFLREMIND()
	elseif remind_name == RemindName.ActivityBrillianCZLC then
		remind_num = self:GetCZLCREMIND()
	elseif remind_name == RemindName.ActivityBrillianLCFD then
		remind_num = self:GetLCFDREMIND()
	elseif remind_name == RemindName.ActivityBrilliantCSFS then
		remind_num = self:GetCSFSREMINd()
	elseif remind_name == RemindName.ActivityBrillianSVZP then
		remind_num = self:GetSVZPREMINd()
	elseif remind_name == RemindName.ActivityBrilliantMsGift then
		remind_num = self:GetMSGIFTLevel() > 0 and 1 or 0
	elseif remind_name == RemindName.ActivityBrilliantXSCZ then
		local num = 0
		for i,v in ipairs(self:GetLimitChargeList()) do
			if v.sign == 0 and self:GetTodayRecharge() >= v.paymoney then
				num = num + 1
			end
		end
		remind_num = num

	elseif remind_name == RemindName.ActivityBrilliantPTTQ then
		local task_data_list = self:GetTaskDataList()
		for i, v in ipairs(task_data_list) do
			if v.sign == 0 and v.can_receive then
				remind_num = 1
				break
			end
		end
	elseif remind_name == RemindName.ActivityBrilliantTSMB then
		remind_num = self:GetTSMBData().draw_num == 0 and 1 or 0
	elseif remind_name == RemindName.ActivityBrillianDLJS then
		local data = ActivityBrilliantData.Instance:GetDLJSData()
		for k, v in pairs(data) do
			if k <= v.dl_day then
				if v.is_lq == 0 then
					remind_num = 1
					break
				end
			end
		end
	end
	return remind_num
end


function ActivityBrilliantData:IsFDLingqu(tag)
	local cfg = self.act_cfg[ACT_ID.FD]
	local list = self:GetSignListByActId(cfg.config.awardList, ACT_ID.FD)
	for i,v in ipairs(list) do
		if i == tag and v.sign == 0 and self.mine_num[ACT_ID.FD] >= v.buytime  then
			return true
		end
	end
	return false
end

function ActivityBrilliantData:IsBzLingqu(tag)
	local cfg = self.act_cfg[ACT_ID.BZ]
	local list = self:GetSignListByActId(cfg.config,ACT_ID.BZ)
	for i,v in ipairs(list) do
		if i == tag and v.sign == 0 and self.baozan_num >= v.times  then
			return true
		end
	end
	return false
end

function ActivityBrilliantData:IsZPLingqu()
	local act_cfg = self.act_cfg[ACT_ID.ZP]
	if nil == act_cfg  then return end
	local use_num = self.use_num
	local maxYlBook = act_cfg.config.params[2]
	local maxCqBook = act_cfg.config.params[3]

	local  ylq_gold= act_cfg.config.tickets[1].yb
	local  cqq_gold= act_cfg.config.tickets[2].yb
	local today_recharge = ActivityBrilliantData.Instance:GetTodayRecharge()
	local consum_gold = self.consum_gold[act_cfg.act_id] or 0
	local ylq_count = math.floor(today_recharge / ylq_gold - use_num * maxYlBook)
	local cqq_count = math.floor(consum_gold / cqq_gold - use_num * maxCqBook)
	if ylq_count < maxYlBook  or cqq_count < maxCqBook  then 
		return false
	else
		return true
	end
end

function ActivityBrilliantData:GetActIdByRemindName(remind_name)
	return ACT_LIST_BY_REMIND[remind_name] or 0
end

function ActivityBrilliantData.GetMoneyTypeIcon(price_type)
	if price_type == MoneyType.BindCoin then
		return ResPath.GetCommon("bind_coin")
	elseif price_type == MoneyType.Coin then
		return ResPath.GetCommon("bind_gold")
	elseif price_type == MoneyType.BindYuanbao then
		return ResPath.GetCommon("bind_gold")
	elseif price_type == MoneyType.Yuanbao then
		return ResPath.GetCommon("gold")
	end
end

--主界面是否显示精彩活动icon图标
function ActivityBrilliantData:IsMainuiActivityIconShow(view_index)
	if type(view_index) == "number" then
		local list = self:GetTabbarNameList(view_index)
		if #list > 0 and not ActivityBrilliantCtrl.Instance:IsReqActCfg() then
			return true
		end
	end

	return false
end

--是否显示元宝转盘
-- function ActivityBrilliantData:IsMainuiTurntableIconShow()
-- 	if nil == self.act_cfg[ACT_ID.GOLDZP] or nil == self.activity_name[ACT_ID.GOLDZP] then return false end
-- 	for k,v in pairs(self.can_list) do
-- 		if v.act_id == ACT_ID.GOLDZP then
-- 			return true
-- 		end
-- 	end
-- 	return false
-- end

--是否显示首冲返利
function ActivityBrilliantData:IsFirstChargeIconShow()
	if nil == self.act_cfg[ACT_ID.SCFL] or nil == self.activity_name[ACT_ID.SCFL] then return false end
	for k,v in pairs(self.can_list) do
		if v.act_id == ACT_ID.SCFL then
			return true
		end
	end
	return false
end

--更新主界面运营活动资源信息
function ActivityBrilliantData:UpdateActViewInfo(cfg)
	if nil == cfg then
		return
	end

	if nil ~= cfg.pkg_bg and "" ~= cfg.pkg_bg then
		local res_id = tonumber(cfg.pkg_bg)
		local view_index = ActivityBrilliantData.Instance:GetOperActViewIndex(cfg.act_id)
		if self.res_id[view_index] then
			if self.res_id[view_index][2] and self.res_id[view_index][2] < cfg.act_priority then
				self.res_id[view_index] = {res_id, cfg.act_priority}
			end
		else
			self.res_id[view_index] = {res_id, cfg.act_priority}
		end
	end

	if not ActivityBrilliantCtrl.Instance:IsReqActCfg() then
		GlobalEventSystem:Fire(MainUIEventType.UPDATE_BRILLIANT_ICON)
	end
	-- Language.ViewName.ActivityBrilliant = Language.ActivityBrilliant["title_"..self.res_id]
end

--运营活动资源id
function ActivityBrilliantData:GetActViewResId(view_index)
	return self.res_id[view_index] and self.res_id[view_index][1] or 0
end

-- 获取活动经过了多少秒
function ActivityBrilliantData:GetActPassTime(act_id)
	local act_cfg = self.act_cfg[act_id]
	if nil == act_cfg then
		return 0
	end
	local beg_time = act_cfg.beg_time
	local now_time = TimeCtrl.Instance:GetServerTime()
	local pass_time = now_time - beg_time
	return pass_time
end

-- 获取活动经过了多少天
function ActivityBrilliantData:GetActPassDay(act_id)
	return math.floor(self:GetActPassTime(act_id) / 86400)
end

-- 公告活动奖励是否已领取
function ActivityBrilliantData:GetNoticeActRecSign(day)
	local l_shift = 0
	local sign = self.sign[ACT_ID.GG]
	if nil ~= sign and nil ~= day and 0 < day and 31 > day then
		l_shift = day - 1
	else
		return true
	end

	return 1 == bit:_and(1, bit:_rshift(sign, l_shift))
end

-- 公告活动提醒数
function ActivityBrilliantData:GetNoticeActRemindNum()
	local num = 0
	local act_id = ACT_ID.GG
	if self:CheckActOpen(act_id) then
		if not self:GetNoticeActRecSign(self:GetActPassDay(act_id) + 1) then
			num = 1
		end
	end

	return num
end

function ActivityBrilliantData:GetOperActCfg(act_id)
	return self.act_cfg[act_id]
end

function ActivityBrilliantData:GetOperActViewIndex(act_id)
	local view_index = 1
	local act_cfg = self:GetOperActCfg(act_id)
	if act_cfg then
		if type(act_cfg.pkg_type) == "number" then
			local view_def = ViewDef["ActivityBrilliant" .. act_cfg.pkg_type]
			if view_def then
				view_index = act_cfg.pkg_type
			end
		end
	end

	return view_index
end

function ActivityBrilliantData:GetRemindNum(act_id)
	local remind_num = 0
	local remind_type = REMIND_ACT_LIST[act_id]
	if remind_type then
		remind_num = self:GetRemindNumByType(remind_type)
	end

	return remind_num
end

function ActivityBrilliantData:GetXiaofeiRewardList()
	self.xiaofei_reward_list = {}
	local cfg = self.act_cfg[ACT_ID.XF] 
	if nil == cfg then return end
	for i=1,#cfg.config do
		table.insert(self.xiaofei_reward_list,cfg.config[i].award)
		cfg.config[i].act_id = ACT_ID.XF
	end
	return self.xiaofei_reward_list
end

function ActivityBrilliantData:GetActCfgByIndex(act_id)
	return self.act_cfg[act_id]
end

function ActivityBrilliantData:GetDengluRewardList()
	local denglu_reward_list = {}
	local cfg = self.act_cfg[ACT_ID.DL] 
	if nil == cfg then return end
	local activity_day = math.floor((TimeCtrl.Instance:GetServerTime() - cfg.beg_time) / (24 * 60 * 60)) + 1
	for i=1,#cfg.config.award do
		table.insert(denglu_reward_list,cfg.config.award[i])
		denglu_reward_list[i].index = i
		denglu_reward_list[i].is_day = activity_day == i and 1 or 0
		if i < activity_day and cfg.config.award[i].sign == 0 then
			denglu_reward_list[i].re_sign = 2
		else
			denglu_reward_list[i].re_sign = cfg.config.award[i].sign
		end
	end
	denglu_reward_list = self:GetSignListByActId(denglu_reward_list,ACT_ID.DL)
	table.sort(denglu_reward_list, function(a, b)
		--  if a.re_sign ~= b.re_sign  then
		-- 	return a.re_sign < b.re_sign
		-- else
			return a.index < b.index
		-- end
	end)
	return denglu_reward_list
end

function ActivityBrilliantData:GetSuperExchangeList()
	local list = {}
	local cfg = self.act_cfg[ACT_ID.JPDH] 
	if nil == cfg then return end
	for i, v in ipairs(cfg.config) do
		local vo = v
		if self.super_exc_list[i] then
			vo.gr_num = self.super_exc_list[i].gr_num
			vo.qf_num = self.super_exc_list[i].qf_num
		end
		list[i] = vo
	end
	return list
end

function ActivityBrilliantData:GetLeichongRewardList()
	local leichong_reward_list = {}
	local cfg = self.act_cfg[ACT_ID.LC] 

	if nil == cfg then return end
	for i=1,#cfg.config do
		table.insert(leichong_reward_list,cfg.config[i])
		leichong_reward_list[i].index = i
	end
	leichong_reward_list = self:GetSignListByActId(leichong_reward_list,ACT_ID.LC)
	local  gold = VipData.Instance.charge_total_yuanbao
	table.sort(leichong_reward_list, function(a, b)
		if a.sign ~= b.sign then
			return a.sign < b.sign
		else
			return a.index < b.index
		end
	end)
	return leichong_reward_list
end

function ActivityBrilliantData:GetLeijiRewardList()
	local leiji_reward_list = {}
	local cfg = self.act_cfg[ACT_ID.LJ]
	if nil == cfg then return end
	for i=1,#cfg.config do
		table.insert(leiji_reward_list,cfg.config[i])
		leiji_reward_list[i].index = i
		leiji_reward_list[i].all_charge = self.all_charge or 0
	end
	leiji_reward_list = self:GetSignListByActId(leiji_reward_list,ACT_ID.LJ)
	local  gold = VipData.Instance.charge_total_yuanbao
	table.sort(leiji_reward_list, function(a, b)
		if a.sign ~= b.sign then
			return a.sign < b.sign
		else
			return a.index < b.index
		end
	end)
	return leiji_reward_list
end

-- 设置领取标志
function ActivityBrilliantData:GetXiaofeiSignList(act_id)
	local xiaofei_sign_list = {}
	local cfg = self.act_cfg[act_id]
	if nil == cfg then return end
	for i,v in ipairs(cfg.config or {}) do
		v.index = i
		if i == 1 then
			v.sign = self.sign_2[cfg.act_id]
		else
			local index = #xiaofei_sign_list + 1
			xiaofei_sign_list[index] = v
		end		
	end

	xiaofei_sign_list = self:GetSignListByActId(xiaofei_sign_list,act_id)
	return xiaofei_sign_list
end

function ActivityBrilliantData:GetDegreeBossSignList(act_id)
	local sign_list = {}
	local cfg = self.act_cfg[act_id] or {}
	local config = cfg.config or {}
	for i = 1,#cfg.config do
		table.insert(sign_list, cfg.config[i])
		sign_list[i].index = i
	end
	sign_list = self:GetSignListByActId(sign_list,act_id)
	return sign_list
end

function ActivityBrilliantData:GetAutoLingquList(list)
	local _list = {}
	for k,v in pairs(list) do
		if v.sign == 0 then
			table.insert(_list, v)
		end 
	end
	return _list
end

function ActivityBrilliantData:GetBaozanSignList()
	local baozan_sign_list = {}
	local cfg = self.act_cfg[15]
	if nil == cfg then return end
	for i = 1,#cfg.config do
		table.insert(baozan_sign_list,cfg.config[i])
		baozan_sign_list[i].index = i
	end
	baozan_sign_list = self:GetSignListByActId(baozan_sign_list,ACT_ID.BZ)
	return baozan_sign_list
end

function ActivityBrilliantData:GetFudaiSignList()
	local fudai_sign_list = {}
	local cfg = self.act_cfg[ACT_ID.FD]
	if nil == cfg then return end
	for i = 1,#cfg.config.awardList do
		table.insert(fudai_sign_list,cfg.config.awardList[i])
		fudai_sign_list[i].index = i
	end
	fudai_sign_list = self:GetSignListByActId(fudai_sign_list,ACT_ID.FD)
	fudai_sign_list[0] = table.remove(fudai_sign_list, 1)
	return fudai_sign_list
end

function ActivityBrilliantData:GetSignListByActId(reward_list,act_id) 
	if nil == reward_list then return {} end
	local sign = self.sign[act_id]
	for i=1,#reward_list do
		if nil ~= sign then
			local m_i = 0
			if act_id == 28 or act_id == 29 then
				m_i = i
			else
				m_i = i - 1
			end
			local is_lingqu = bit:_and(1, bit:_rshift(sign,m_i))
			reward_list[i].sign = is_lingqu
		end
	end
	return reward_list
end

function ActivityBrilliantData:IsNonuse(act_id)
	for k,v in pairs(ACT_ID) do
		if v == act_id then
			return false
		end
	end
	return true
end

-- 获取展示物品列表
function ActivityBrilliantData:GetShowItemList(act_id, show_type)
	local cfg = self.act_cfg[act_id]
	if not self:CheckActOpen(act_id) then return end
	if nil == cfg or nil == cfg.config then return end
	local item_list = cfg.config.ShowList
	if nil == item_list or nil == item_list.list then return end
	local count = cfg.config.showType <= 3 and cfg.config.showType or 1
	local star_index = 1 + (12 + count) * (show_type - 1)
	local end_index = (12 + count) * show_type
	local show_list = {}
	for i = star_index, end_index do
		local vo = {}
		vo.bind = 0
		vo.id = item_list.list[i]
		vo.count = 1
		table.insert(show_list, vo)
	end
	return show_list
end

-- 获取展示物品列表类型
function ActivityBrilliantData:GetShowItemListType(act_id)
	local cfg = self.act_cfg[act_id]
	if not self:CheckActOpen(act_id) then return end
	if nil == cfg or nil == cfg.config then return end
	return cfg.config.showType
end


--------------------------------------
-- 超级礼包
--------------------------------------
function ActivityBrilliantData:GetGiftMsgByIndex(index)
	local cfg = self.act_cfg[ACT_ID.THGIFT].config
	if index <= 0 or index > #cfg then return end
	local msg = {}
	local count = 0
	for i = (index - 1) * 4, index *4 - 1 do
		local sign = bit:_and(1, bit:_rshift(self.buy_level, i))
		if sign == 1 then
			count = count + 1
		end
	end

	local cur_cfg = cfg[index] or {}
	local gift_levels = cur_cfg.GiftLevels or {}
	msg.level = count
	msg.can_buy = true
	msg.level_max = #gift_levels
	msg.id = cur_cfg.id
	msg.giftName = cur_cfg.giftName
	msg.need_yuanbao = 0
	msg.img_effect = cur_cfg.imgEffect
	msg.effect_cfg = cur_cfg.effect_cfg or {img_effect = 1, img_pos_shift = {0, 0}}

	local show_level = msg.level + 1
	if msg.level == msg.level_max then
		show_level = msg.level_max
		msg.can_buy = false
	end

	local reward_data = {}
	local cur_gift_levels = gift_levels[show_level]
	if nil ~= cur_gift_levels then
		msg.need_yuanbao = cur_gift_levels.money.count
		msg.item_id = cur_gift_levels.item or 0
		msg.zslv = cur_gift_levels.zslv

		local data = cur_gift_levels.award
		if data ~= nil then
			for k,v in pairs(data) do
				reward_data[#reward_data + 1] = ItemData.InitItemDataByCfg(v)
			end
		end
	end

	return msg, reward_data
end

function ActivityBrilliantData:GetGiftGridMaxCount()
	local cfg = self.act_cfg[ACT_ID.THGIFT].config
	if nil == cfg or #cfg == nil or #cfg <= 0 then return 0 end
	return #cfg
end

function ActivityBrilliantData:GetGiftGridData()
	local gird_max_count = self:GetGiftGridMaxCount()
	local data = {}
	for i=1,gird_max_count do
		local msg, data_list = ActivityBrilliantData.Instance:GetGiftMsgByIndex(i)
		if nil ~= msg then
			data[#data + 1] = {}
			data[#data].msg = msg
			data[#data].index = i
			data[#data].sign = msg.level >= msg.level_max and 1 or 0
		end
	end
	table.sort(data, function (a,b)
		if a.sign ~= b.sign then
			return a.sign < b.sign
		else
			return a.index < b.index
		end
	end)

	if #data == 0 then return end
	return data
end

function ActivityBrilliantData:GetGiftGridCanSelect(index)
	local data = self:GetGiftGridData()
	if data == nil then return false end

	for k,v in pairs(data) do
		if v.index == index then return v.sign == 1 end
	end
	
	return false
end

function ActivityBrilliantData.GetGiftEffectCfg(index)
	if nil == index then
		return
	end

	local cfg = PreferentialGift and PreferentialGift.SpecialOffer or {}
	for k, v in pairs(cfg) do
		if v.id == index and nil ~= v.effect_cfg then
			return v.effect_cfg
		end
	end

	return {img_effect = 1, img_pos_shift = {0, 0}}
end

function ActivityBrilliantData:GetIsExchange()
	return self.is_exchange 
end

--充值有礼 52
function ActivityBrilliantData:GetChongZhiLQNum()
	return self.lingqu_num_52
end

--充值转盘54数据
function ActivityBrilliantData:GetCZZPData()
	local cfg = self.act_cfg[ACT_ID.CZZP] and self.act_cfg[ACT_ID.CZZP].config
	local _per =  self.mine_num[ACT_ID.CZZP]  / cfg.money >= 1 and 100 or self.mine_num[ACT_ID.CZZP]  / cfg.money * 100
	local _str = self.mine_num[ACT_ID.CZZP]  .. "/" .. cfg.money
	local t_have_num = self.mine_num[ACT_ID.CZZP] / cfg.money >= cfg.maxTime and cfg.maxTime or self.mine_num[ACT_ID.CZZP] / cfg.money
	local _draw_num = math.floor(t_have_num - self.cz_draw_num)
	
	return {per = _per or 0, str = _str or 0, draw_num = _draw_num or 0}
end

--探索秘宝61数据
function ActivityBrilliantData:GetTSMBData()
	local cfg = self.act_cfg[ACT_ID.TSMB] and self.act_cfg[ACT_ID.TSMB].config.award_pool
	local cond = self.tsmb_list.cound_time
	-- local luck_time = self.tsmb_list.luck_time == 0 and self.tsmb_list.luck_time + 1 or self.tsmb_list.luck_time
	local need_xb_time = self:GetNeedXunbaoTime(cond, self.tsmb_list.luck_time) - self.tsmb_list.xunbao_time
	local _draw_num = need_xb_time < 0 and 0 or need_xb_time
	
	return {cond = cond or 0, need_xb_time = need_xb_time or 0, draw_num = _draw_num or 0}
end

-- 获取下一次的次数
function ActivityBrilliantData:GetNeedXunbaoTime(cond, luck_time)
	local cfg = self.act_cfg[ACT_ID.TSMB] and self.act_cfg[ACT_ID.TSMB].config.award_pool
	local index = 0 
	if cfg[cond] then
		for i = 1, luck_time+1 do
			index = cfg[cond][i] and cfg[cond][i].cost_dmkj_tms or 0
		end
	end
	
	return index
end

-- 探索秘宝奖励是否领取
function ActivityBrilliantData:GetRewardSign()
	local list = bit:d2b(self.tsmb_list.zj_sign)
	local data = {}
	for i = 1, #list do
		data[i] = list[#list - i + 1]
	end
	return data
end


function ActivityBrilliantData:GetTSMBRecordList()
	local list = {}
	local tag_t = Split(self.tsmb_list.record_list, ";")
	for i= #tag_t, 1, -1 do
		local str2 =  Split(tag_t[i], "#")
		local vo = {}
		vo.name = str2[1]
		vo.cound = str2[2]
		vo.index = str2[3]
		table.insert(list, vo)
	end
	return list
end

function ActivityBrilliantData:GetCZZPRecordList()
	return self.ParseRewardRecord(self.record_54)
end

function ActivityBrilliantData.ParseRewardRecord(str)
	local list = {}
	local tag_t = Split(str, ";")
	for i= #tag_t, 1, -1 do
		local str2 =  Split(tag_t[i], "#")
		local vo = {}
		vo.name = str2[1]
		vo.index = str2[2]
		table.insert(list, vo)
	end
	return list
end

--激情派对
function ActivityBrilliantData:GetJQPDLeftItemList()
	self.sign_num = 0
	local item_list = {}
	local cfg = self.act_cfg[ACT_ID.JQPD] 
	if nil == cfg  then return end
	for i=1,#cfg.config.exchange do
		if nil == cfg.config.exchange[i] then return end
		local item = cfg.config.exchange[i].award
		item.score = cfg.config.exchange[i].score
		item.index = i
		table.insert(item_list,item)
	end
	item_list = self:GetSignListByActId(item_list,ACT_ID.JQPD)

	table.sort(item_list, function (a,b)
		if a.sign ~= b.sign then
			return a.sign < b.sign
		else
			return a.index < b.index
		end
	end)

	return item_list
end

-- function ActivityBrilliantData:GetRankList(act_id)
-- 	local rank_list = {}
-- 	if nil == self.act_cfg[act_id] then return end
-- 	for i = 1, #self.act_cfg[act_id].config.rankings  do
-- 		rank_list[i] = self.rank_list[act_id][i] or {i, Language.Common.ZanWu}
-- 	end
-- 	if self.act_cfg[act_id].config.join_award then 
-- 		local pos = #rank_list + 1
-- 		rank_list[pos] =  {pos,Language.Common.ZanWu,self.is_lingqu[act_id], is_jion = true}
-- 	end
-- 	return rank_list
-- end

--秒杀礼包
function ActivityBrilliantData:GetMSGIFTLevel()
	if nil == self.sign[ACT_ID.MSGIFT] then return 1 end
	local cfg = self.act_cfg[ACT_ID.MSGIFT]
	for i = 0, #cfg.config.GiftLevels - 1 do
		local is_buy = bit:_and(1, bit:_rshift(self.sign[ACT_ID.MSGIFT], i)) 
		if is_buy == 0 then --档次未购买时
			return i + 1
		end
	end
	return 0
end

--是否显示秒杀礼包
function ActivityBrilliantData:IsMainuiMSGIFTIconShow()
	-- if nil == self.act_cfg[ACT_ID.MSGIFT] or nil == self.activity_name[ACT_ID.MSGIFT] then return false end
	-- if self:GetMSGIFTLevel() == 0 then return false end
	-- for k,v in pairs(self.can_list) do
	-- 	if v.act_id == ACT_ID.MSGIFT then
	-- 		return true
	-- 	end
	-- end
	return false
end

--是否显示通天塔
function ActivityBrilliantData:IsMainuiBabelTowerIconShow()
	if nil == self.act_cfg[ACT_ID.TTT] or nil == self.activity_name[ACT_ID.TTT] then return false end
	for k,v in pairs(self.can_list) do
		if v.act_id == ACT_ID.TTT then
			return true
		end
	end
	return false
end

--是否显示藏宝阁
function ActivityBrilliantData:IsMainuiCanbaogeIconShow()
	if nil == self.act_cfg[ACT_ID.CBG] or nil == self.activity_name[ACT_ID.CBG] then return false end
	for k,v in pairs(self.can_list) do
		if v.act_id == ACT_ID.CBG then
			return true
		end
	end
	return false
end

--是否显示限时充值
 function ActivityBrilliantData:IsMainuiLimitChargeIconShow()
 	if nil == self.act_cfg[ACT_ID.XSCZ] or nil == self.activity_name[ACT_ID.XSCZ] then return false end
 	for k,v in pairs(self.can_list) do
 		if v.act_id == ACT_ID.XSCZ then
 			return true
 		end
 	end
 	return false
 end

--根据act_id判断是否显示功能图标
function ActivityBrilliantData:IsMainuiActIconShowByActId(act_id)
	if nil == self.act_cfg[act_id] or nil == self.activity_name[act_id] then return false end
	for k,v in pairs(self.can_list) do
		if v.act_id == act_id then
			return true
		end
	end
	return false
end
--许愿池
function ActivityBrilliantData:GetActivityGridLevel()
	if nil == self.red_rope_level then return 1 end
	for i = 0, #self.act_cfg[ACT_ID.XYC].config.pool - 1 do
		local is_buy = bit:_and(1, bit:_rshift(self.red_rope_level, i)) 
		if is_buy == 0 then --档次未购买时	
			return i + 1
		end
	end
	return #self.act_cfg[ACT_ID.XYC].config.pool
end

function ActivityBrilliantData:GetRedHopeNum()
	return self.red_rope_count
end

function ActivityBrilliantData:GetSignByIndexXYC(index)
	local sign = self.sign[ACT_ID.XYC]
	if nil == sign then return 0 end
	local is_lingqu = bit:_and(1, bit:_rshift(sign, index - 1))
	return is_lingqu
end

function ActivityBrilliantData:GetActivityGridData()
	local cfg = self.act_cfg[ACT_ID.XYC] and self.act_cfg[ACT_ID.XYC].config.livenessTask
	if nil == cfg then return end

	local num_list = self.red_rope_type

	local data = {}
	local legth = 0
	for i,v in pairs(cfg) do
		legth = legth + 1
	end 

	for i = 1, legth do
		local vo = cfg[i - 1] or {}
		local index = vo.id
		data[i] = vo
		data[i].tag = i
		data[i].title = Language.ActiveDegree.ActivityTitleList[index]
		data[i].finish_num = num_list and num_list[index] and num_list[index].finish_target_time or 0
	end

	-- --排序(把已完成放在后面)
	-- local function sort_func()	
	-- 	return function(a, b)
	-- 		local order_a = 1000
	-- 		local order_b = 1000
	-- 		if a.finish_num < a.limitTimes and b.finish_num >= b.limitTimes then
	-- 			order_b = order_b + 100
	-- 		end
	-- 		if a.finish_num >= a.limitTimes and b.finish_num < b.limitTimes then
	-- 			order_a = order_a + 100
	-- 		end

	-- 		if order_a == order_b then
	-- 			return a.tag < b.tag
	-- 		else
	-- 			return order_a < order_b
	-- 		end
	-- 	end
	-- end
	-- table.sort(data, sort_func())
	return data
end

--65藏宝阁
function ActivityBrilliantData:GetCanbaogeData()
	return self.canbaoge_data
end

function ActivityBrilliantData:GetCanbaogeLingquRecord()
	return self:GetRewardList(self.canbaoge_data.awrad_record)
end

local get_idx_sign = function (sign, idx)
	if nil == sign or nil == idx then
		return false
	end
	return bit:_and(1, bit:_rshift(sign, idx)) == 0
end

function ActivityBrilliantData:CheckAndGetStepCanLingquIdx()
	if nil == self.act_cfg[ACT_ID.CBG] then return end
	local show_idx = 1
	for k,v in ipairs(self.act_cfg[ACT_ID.CBG].config.speicalpoint) do
		if self.canbaoge_data.step_num >= v.point  and get_idx_sign(self.canbaoge_data.step_lingqu_sign, k - 1)  then
			return true, k
		elseif self.canbaoge_data.step_num >= v.point  then
			show_idx = k == #self.act_cfg[ACT_ID.CBG].config.speicalpoint and k or k + 1
		end
	end
	return false, show_idx
end

function ActivityBrilliantData:CheckAndGetFloorCanLingquIdx()
	if nil == self.act_cfg[ACT_ID.CBG] then return end
	local show_idx = 1
	for k,v in ipairs(self.act_cfg[ACT_ID.CBG].config.totalpiles) do
		if self.canbaoge_data.floor_num >= v.piles and get_idx_sign(self.canbaoge_data.floor_lingqu_sign, k - 1)  then
			return true, k
		elseif self.canbaoge_data.floor_num >= v.piles then
			show_idx = k == #self.act_cfg[ACT_ID.CBG].config.totalpiles and k or k + 1
		end
	end
	return false, show_idx
end

function ActivityBrilliantData:GetExchangeRecordList()
	return self:GetRewardList(self.canbaoge_data.duihuan_record)
end

function ActivityBrilliantData:IsActCanbaogeOpen()
	return self.act_cfg[ACT_ID.CBG] ~= nil
end

---------------------
-- 珍宝阁
---------------------
function ActivityBrilliantData:GetCabinetItemList()
	local treasure_cabinet_list = {}
	local cfg = self.act_cfg[ACT_ID.ZBG] 
	if nil == cfg  then return end
	for i = 1, #self.cabinet_list do
		if self.cabinet_list[i] and self.cabinet_list[i] > 0 then
			local item = cfg.config.items[self.cabinet_list[i]].award[1]
			item.index = i
			item.money = cfg.config.items[self.cabinet_list[i]].money
			item.money_type = cfg.config.items[self.cabinet_list[i]].money_type
			table.insert(treasure_cabinet_list, item)
		end
	end
	treasure_cabinet_list = self:GetSignListByActId(treasure_cabinet_list, ACT_ID.ZBG)
	return treasure_cabinet_list
end

-- 刷新次数奖励
function ActivityBrilliantData:GetCabinetRefreshList(is_vip)
	local cabinet_refreshtimes_list = {}
	local cfg = self.act_cfg[ACT_ID.ZBG] 
	if nil == cfg  then return end
	for i = 1, #cfg.config.refreshtimes do
		local viplv = cfg.config.refreshtimes[i].viplv > 0
		if not is_vip then
			viplv = not viplv
		end
		if viplv then
			local item = cfg.config.refreshtimes[i].award
			item.index = i
			item.sign = bit:_and(1, bit:_rshift(self.flush_sign, i - 1)) 
			item.times = cfg.config.refreshtimes[i].times
			item.viplv = cfg.config.refreshtimes[i].viplv
			table.insert(cabinet_refreshtimes_list, item)
		end
	end
	table.sort(cabinet_refreshtimes_list, function(a, b)
		if a.sign ~= b.sign then
			return a.sign < b.sign
		elseif a.viplv ~= b.viplv then
			return a.viplv < b.viplv
		else 
			return a.index < b.index
		end
	end)
	return cabinet_refreshtimes_list
end

-- 珍宝展示列表
function ActivityBrilliantData:GetShowCabinetList()
	local cabinet_list = self:GetCabinetItemList()
	local show_list = {}
	for k,v in pairs(cabinet_list) do
		if v.isspecial and v.isspecial > 0 then
			table.insert(show_list, v)
		end
	end
	return show_list
end

-- 刷新次数VIP奖励
function ActivityBrilliantData:GetCabinetVipList()
	return self:GetCabinetRefreshList(true)
end

-- 刷新次数Common奖励
function ActivityBrilliantData:GetCabinetCommonList()
	return self:GetCabinetRefreshList(false)
end

function ActivityBrilliantData:GetZBGFlushTimes()
	return self.flush_times
end

function ActivityBrilliantData:GetZBGFlushCost()
	local cfg = self.act_cfg[ACT_ID.ZBG]
	if nil == cfg or nil == cfg.config or nil == cfg.config.params then return 0 end
	return cfg.config.params[3] or 0
end

--通天塔
function ActivityBrilliantData:GetTowerLevel()
	return self.tower_level > 0 and self.tower_level or 1
end

function ActivityBrilliantData:GetDrawRecordList()
	return self:GetRewardList(self.draw_record)
end

function ActivityBrilliantData:GetTowerDrawCost()
	local cfg = self.act_cfg[ACT_ID.TTT]
	if nil == cfg or nil == cfg.config then return 0 end
	return cfg.config.money or 0
end

function ActivityBrilliantData:IsActBabelTowerOpen()
	return self.act_cfg[ACT_ID.TTT] ~= nil
end

----------------------------------------------
-- 跨服运营活动 begin
----------------------------------------------
function ActivityBrilliantData.IsCrossServerAct(act_id)
	return act_id > 199
end

function ActivityBrilliantData:DeleteCSActModel(act_id)
	if self.cs_act_model_map[act_id] then
		self.cs_act_model_map[act_id]:Delete()
		self.cs_act_model_map[act_id] = nil
	end
end

function ActivityBrilliantData:CreateCSActModel(act_id)
	local act_cfg = self:GetActCfgByIndex(act_id)
	if nil ~= act_cfg then
		local model = require(OPER_ACT_CLIENT_CFG[act_id].data_class_path)
		model:Init({act_cfg = act_cfg})
		self.cs_act_model_map[act_id] = model

		-- 注册提醒
		if nil ~= OPER_ACT_CLIENT_CFG[act_id].remind_param then
			for k, v in pairs(OPER_ACT_CLIENT_CFG[act_id].remind_param) do
				RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(model.GetRemindNum, model), v.name, v.auto_do, v.time)
			end
		end
	end
end

function ActivityBrilliantData:GetCSActModel(act_id)
	return self.cs_act_model_map[act_id]
end

function ActivityBrilliantData:GetCSActModelList()
	local list = {}
	for k, v in pairs(self.cs_act_model_map) do
		table.insert(list, v)
	end
	return list
end

--主界面是否显示跨服运营活动icon图标
function ActivityBrilliantData:IsShowCSActIcon()
	if nil ~= next(self.cs_act_model_map) and not ActivityBrilliantCtrl.Instance:IsReqActCfg() then
		return true
	else
		return false
	end
end


--新增搶紅包
function ActivityBrilliantData:SetCanRobNum(num)
	self.red_num = num
end

function ActivityBrilliantData:GetRobNum()
	return self.red_num
end

function ActivityBrilliantData:GetRemindRedNum()
	return self.red_num > 0 and 1 or 0
end

function ActivityBrilliantData:GetZhuanPanRemindNum()
	local num = self.unlock_grade - self.cur_draw_grade > 0 and self.unlock_grade - self.cur_draw_grade or 0
	return num > 0 and 1 or 0
end

--豪华大礼红点提醒
function ActivityBrilliantData:GetHHDLREMIND()
	local data = self:GetActCfgByIndex(ACT_ID.HHDL)
	if data and data.config then

		local cfg = data.config

		local charge_money = self:GetTotalCharge()
		local cur_grade = self:GetCurGrade()
		local index = table.getn(cfg.ChargeLevels) >= cur_grade and cur_grade or table.getn(cfg.ChargeLevels)
		if cfg.ChargeLevels[index] then 
			local awards = cfg.ChargeLevels[index].award
			local money = cfg.ChargeLevels[index].paymoney
			if charge_money < money then 
				return 0
			else
				if index < cur_grade then 
					return 0
				else
					return 1
				end
			end
		end
	end
	return 0
end

--累充返利
function ActivityBrilliantData:GetLCFLREMIND()
	local data = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.LCFL)
	if data and data.config then
		local cfg = data.config
		local cur_grade = ActivityBrilliantData.Instance:GetChargeGrade()
		local charge_day = ActivityBrilliantData.Instance:GetChargeDay()
		local charge_count = ActivityBrilliantData.Instance:GetChargeCount()
		local sign = ActivityBrilliantData.Instance:GetChargeCount()
		local list = bit:d2b(sign)
		local data_1 = {}
		for i = 1, #list do
			data_1[i] = list[#list - i + 1]
		end

		local index = 1
		for i, v in ipairs(data_1) do
			if v == 1 then
				index = i + 1
			end
		end
		if cfg.listTbl[index] then 
			local charge_days = cfg.listTbl[index].keepday
			
			if charge_day >= charge_days then 
				if cfg.pay < cur_grade then 
					return 1
				end
			end
		end
	end
	return 0
end

--超值累
function ActivityBrilliantData:GetCZLCREMIND()
	local num = 0
	local data = self:GetActCfgByIndex(ACT_ID.CZLC)
	if data and data.config then 
		local cfg = data.config
		local info_data73 = self:GetChaozhiInfo()

		local list =  bit:d2b(info_data73.everyday_sign)
		local data_sign = {}
		for i = 1, #list do
			data_sign[i] = list[#list - i + 1]
		end
		for k, v in ipairs(cfg.everyday) do
			
			if info_data73.cur_day_charge >= v.paymoney then --未达标
				if data_sign[k] == 0  then
					return 1
				end
	
			end
		end
		--累积充值
		local list2 =  bit:d2b(info_data73.cumulative_sign)
		local leiji_data = {}
		for i = 1, #list2 do
			leiji_data[i] = list2[#list2 - i + 1]
		end

		for k, v in ipairs(cfg.manyday) do
			if info_data73.cumulative_charge >= v.paymoney then --已达标
				if leiji_data[k] == 0  then --未领取
					return 1
				end
			end
		end

	end
	return 0
end

--连充福袋
function ActivityBrilliantData:GetLCFDREMIND()
	local fudai_list = self:GetFudaiList()
	for k, v in pairs(fudai_list) do
		if v.charge_days >= v.payday and v.sign == 0 then
			return 1
		end
	end
	return 0
end
--
function ActivityBrilliantData:GetCSFSREMINd()
	local charge_list = ActivityBrilliantData.Instance:GetChargeThreeList()
	for k, v in pairs(charge_list) do
		for k1, v1 in pairs(v.grade_list) do
			if v1.item_index <= v1.charge_day or (v1.item_index == 4 and v1.charge_day == 3) then
				if v1.sign == 0 then
					return 1
				end
			end
		end
	end
	return 0
end

function ActivityBrilliantData:GetSVZPREMINd()
	local act_cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.SVZP)
	local draw_integral = ActivityBrilliantData.Instance:GetDrawIntegral()
	
	if act_cfg and act_cfg.config then
		local cfg = act_cfg.config
		local num = math.floor(draw_integral/cfg.lotteryIntegral)
		return num
	end
	return 0
end

function ActivityBrilliantData:SetTime(time, num)
	self.time = time
	self.cur_red_num = num
end

function ActivityBrilliantData:GetTime( ... )
	return self.time
end

function ActivityBrilliantData:GetCanRedNum( ... )
	return self.cur_red_num
end

function ActivityBrilliantData:SetTimeCD(time)
	self.time = time
end
----------------------------------------------
-- 跨服运营活动 end
----------------------------------------------

-- 根据npc_id获取速传id
function ActivityBrilliantData:GetNpcQuicklyTransportId(npc_id)
	local cfg = ChuansongPoint
	if nil == cfg then return end
	for k,v in pairs(cfg) do
		if v.ncpid == npc_id then return v.id end
	end
end

----------------------------------------------
-- 49 普天同庆
----------------------------------------------

function ActivityBrilliantData:GetTaskDataList()
	local act_cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.PTTQ)
	local cfg_list = ActivityBrilliantData.Instance:GetSignListByActId(act_cfg.config, ACT_ID.PTTQ)
	local task_data_list = ShenDingData.Instance:GetTaskList()
	local task_cfg_list = ActivityAllConfig and ActivityAllConfig.tasklist or {}
	for i,v in ipairs(task_data_list) do
		v.cfg = cfg_list[v.index]
		v.sign = cfg_list[v.index].sign
		v.times2 = cfg_list[v.index].daylimit or 1 -- 需完成的次数
		v.can_receive = v.times >= v.times2
	end

	table.sort(task_data_list, function(a, b)
		if a.sign ~= b.sign then
			return a.sign < b.sign
		else
			if a.can_receive ~= b.can_receive then
				return a.can_receive
			else
				return a.index < b.index
			end
		end
	end)

	return task_data_list
end

----------------------------------------------
-- 49 普天同庆 end
----------------------------------------------

----------------------------------------------
-- 94 登录就送
----------------------------------------------
function ActivityBrilliantData:GetDLJSData()
	local act_cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.DLJS)
	local data = {}
	for k, v in pairs(act_cfg.config.award) do
		local vo = {
			dl_day = self.dljs_data.dl_day,
			is_lq = self:GetDLJSRewardSign(k),
			award = v,
		}
		table.insert(data, vo)
	end

	return data
end

-- 登录就送奖励是否领取
function ActivityBrilliantData:GetDLJSRewardSign(index)
	local list = bit:d2b(self.dljs_data.lq_sign)
	local data = {}
	for i = 1, #list do
		data[i] = list[#list - i + 1]
	end
	return data[index]
end

-- 可以领取哪一个
function ActivityBrilliantData:GetDLJSRewardIndex()
	local list = bit:d2b(self.dljs_data.lq_sign)
	local data = {}
	for i = 1, #list do
		data[i] = list[#list - i + 1]
	end
	local index = 1
	for k, v in pairs(data) do
		if v == 0 then
			index = k
			break
		end
	end
	return index
end
----------------------------------------------
-- 94 登录就送 end
----------------------------------------------

----------------------------------------------
-- 95 超值礼包
----------------------------------------------
function ActivityBrilliantData:GetCZLBData()
	local act_cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.CZLB)
	local data = {}
	local cfg = act_cfg.config[self.czlb_data.act_days]
	for k, v in pairs(cfg) do
		local vo = {
			index = k,
			src_price = v.src_price, --原价
			curr_price = v.consumes[1].count, --现价
			money_type = v.consumes[1].type,--货币类型
			discount = v.discount, 	--折扣
			max_buy_tms = v.buy_tms, 	--最大购买次数
			award = v.awards[1],
			buy_tms = self.czlb_data.item_list[k].spare_times,
		}
		table.insert(data, vo)
	end

	return data
end

----------------------------------------------
-- 95 超值礼包 end
----------------------------------------------