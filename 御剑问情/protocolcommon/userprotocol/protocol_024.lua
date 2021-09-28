
-- 金银塔抽奖信息
SCRALevelLotteryInfo = SCRALevelLotteryInfo or BaseClass(BaseProtocolStruct)
function SCRALevelLotteryInfo:__init()
	self.msg_type = 2400
end

function SCRALevelLotteryInfo:Decode()
	self.lottery_cur_level = MsgAdapter.ReadInt()
	local history_count = MsgAdapter.ReadInt()
	self.history_list = {}
	for i = 1, history_count do
		local vo = {}
		vo.user_name = MsgAdapter.ReadStrN(32)
		vo.uid = MsgAdapter.ReadInt()
		vo.reward_index = MsgAdapter.ReadInt()
		self.history_list[i] = vo
	end
end

-- 金银塔奖励信息
SCRALevelLotteryRewardList = SCRALevelLotteryRewardList or BaseClass(BaseProtocolStruct)
function SCRALevelLotteryRewardList:__init()
	self.msg_type = 2401
end

function SCRALevelLotteryRewardList:Decode()
	self.lottery_reward_list = {}
	self.reward_count = MsgAdapter.ReadShort()
	MsgAdapter.ReadShort()
	for i = 1, self.reward_count do
		self.lottery_reward_list[i] = MsgAdapter.ReadChar()
	end
end


-- 充值扭蛋信息
SCRANiuEggInfo = SCRANiuEggInfo or BaseClass(BaseProtocolStruct)
function SCRANiuEggInfo:__init()
	self.msg_type = 2402
end

function SCRANiuEggInfo:Decode()
	self.history_list = {}												--所有玩家抽奖历史
	self.server_total_niu_egg_times = MsgAdapter.ReadInt()         		--活动期间全服总扭蛋次数
	self.cur_can_niu_egg_chongzhi_value = MsgAdapter.ReadInt()			--剩余可抽奖的充值额度
	self.server_reward_has_fetch_reward_flag = MsgAdapter.ReadInt()		--当前已领取的奖励标记
	self.history_count = MsgAdapter.ReadInt()							--所有玩家抽奖历史纪录个数
	for i=1, self.history_count do
		local vo = {}
		vo.user_name = MsgAdapter.ReadStrN(32)
		vo.uid = MsgAdapter.ReadInt()
		vo.reward_req = MsgAdapter.ReadInt()	--玩家抽取到的奖励下标
		self.history_list[i] = vo
	end
end

-- 充值扭蛋抽奖结果信息
SCRANiuEggChouResultInfo = SCRANiuEggChouResultInfo or BaseClass(BaseProtocolStruct)
function SCRANiuEggChouResultInfo:__init()
	self.msg_type = 2403
end

function SCRANiuEggChouResultInfo:Decode()
	self.reward_req_list = {}							--抽取的奖励列表
	self.reward_req_list_count = MsgAdapter.ReadInt()  	--抽取的奖励数量
	for i = 1, self.reward_req_list_count do
		self.reward_req_list[i] = MsgAdapter.ReadShort()
	end
end

-------------珍宝阁---------------------
SCRAZhenbaogeInfo = SCRAZhenbaogeInfo or BaseClass(BaseProtocolStruct)
function SCRAZhenbaogeInfo:__init()
	self.msg_type = 2404
	self.zhenbaoge_item_list = {}
	self.zhenbaoge_server_fetch_flag = 0
	self.cur_server_flush_times = 0
	self.zhenbaoge_next_flush_timestamp = 0
end

function SCRAZhenbaogeInfo:Decode()
	self.zhenbaoge_item_list = {}
	for i=0, GameEnum.RAND_ACTIVITY_ZHENBAOGE_ITEM_COUNT-1 do
		self.zhenbaoge_item_list[i] = MsgAdapter.ReadShort()
	end
	MsgAdapter.ReadShort()
	self.zhenbaoge_server_fetch_flag = MsgAdapter.ReadShort()
	self.cur_server_flush_times = MsgAdapter.ReadShort()
	self.zhenbaoge_next_flush_timestamp = MsgAdapter.ReadUInt()
end

-- 土豪金聊天
SCTuHaoJinInfo = SCTuHaoJinInfo or BaseClass(BaseProtocolStruct)
function SCTuHaoJinInfo:__init()
	self.msg_type = 2405
	self.tuhaojin_level = 0
	self.reserve_sh = 0
	self.cur_tuhaojin_color = 0
	self.max_tuhaojin_color = 0
end

function SCTuHaoJinInfo:Decode()
	self.tuhaojin_level = MsgAdapter.ReadShort()
	self.reserve_sh = MsgAdapter.ReadShort()
	self.cur_tuhaojin_color = MsgAdapter.ReadChar()
	self.max_tuhaojin_color = MsgAdapter.ReadChar()
end

-- 大表情 ---------------------------------------------------------

SCBigChatFaceAllInfo = SCBigChatFaceAllInfo or BaseClass(BaseProtocolStruct)
function SCBigChatFaceAllInfo:__init()
	self.msg_type = 2406
	self.big_face_level = 0
	self.reserve_sh = 0
end

function SCBigChatFaceAllInfo:Decode()
	self.big_face_level = MsgAdapter.ReadShort()
	self.reserve_sh = MsgAdapter.ReadShort()
end

--魂器
SCShenzhouWeapondAllInfo = SCShenzhouWeapondAllInfo or BaseClass(BaseProtocolStruct)

function SCShenzhouWeapondAllInfo:__init()
	self.msg_type = 2407
end

function SCShenzhouWeapondAllInfo:Decode()
    self.today_gather_times = MsgAdapter.ReadChar()								-- 今日采集总数
    self.today_buy_gather_times = MsgAdapter.ReadChar()							-- 今日购买采集总次数
	self.today_exchange_identify_exp_times = MsgAdapter.ReadShort()				-- 今日兑换鉴定经验次数
	self.identify_level = MsgAdapter.ReadShort()								-- 鉴定等级
	self.identify_star_level = MsgAdapter.ReadShort()							-- 鉴定星级
	self.identify_exp = MsgAdapter.ReadInt()									-- 鉴定经验
	self.hunqi_jinghua = MsgAdapter.ReadInt()									-- 魂器精华
	self.lingshu_exp = MsgAdapter.ReadInt()										-- 灵枢经验
	self.day_free_xilian_times = MsgAdapter.ReadInt()                           -- 今日已免费洗练次数
	self.all_weapon_level_list = {}
	for i = 1, HunQiData.SHENZHOU_WEAPON_COUNT do
		self.all_weapon_level_list[i] = {}
		self.all_weapon_level_list[i].weapon_level = MsgAdapter.ReadInt()
		self.all_weapon_level_list[i].hunyin_suit_level = MsgAdapter.ReadInt()
		self.all_weapon_level_list[i].perform_skill_last_time = MsgAdapter.ReadUInt()
		self.all_weapon_level_list[i].weapon_slot_level_list = {}
		for j = 1, HunQiData.SHENZHOU_WEAPON_SLOT_COUNT do
			self.all_weapon_level_list[i].weapon_slot_level_list[j] = MsgAdapter.ReadShort()
		end

		self.all_weapon_level_list[i].element_level_list = {}
		for j = 1, HunQiData.SHENZHOU_ELEMET_MAX_TYPE do
			self.all_weapon_level_list[i].element_level_list[j] = MsgAdapter.ReadShort()
		end

		self.all_weapon_level_list[i].hunyin_slot_list = {}

		for j = 1, HunQiData.SHENZHOU_HUNYIN_MAX_SLOT do
			self.all_weapon_level_list[i].hunyin_slot_list[j] = {}
			self.all_weapon_level_list[i].hunyin_slot_list[j].lingshu_level = MsgAdapter.ReadInt()
			self.all_weapon_level_list[i].hunyin_slot_list[j].hunyin_id = MsgAdapter.ReadUShort()
			self.all_weapon_level_list[i].hunyin_slot_list[j].is_bind = MsgAdapter.ReadChar()
			self.all_weapon_level_list[i].hunyin_slot_list[j].reserve1 = MsgAdapter.ReadChar()
		end
	end

	self.xilian_data = {}
	for i = 1, HunQiData.SHENZHOU_WEAPON_COUNT do
		self.xilian_data[i] = {}
		self.xilian_data[i].xilian_slot_open_falg = bit:d2b(MsgAdapter.ReadInt())
		self.xilian_data[i].xilian_shuxing_type = {}
		for j = 1, HunQiData.SHENZHOU_XIlIAN_MAX_SLOT do
			self.xilian_data[i].xilian_shuxing_type[j] = MsgAdapter.ReadChar()
		end

		self.xilian_data[i].xilian_shuxing_star = {}
		for j = 1, HunQiData.SHENZHOU_XIlIAN_MAX_SLOT do
			self.xilian_data[i].xilian_shuxing_star[j] = MsgAdapter.ReadChar()
		end

		self.xilian_data[i].xilian_shuxing_value = {}
		for j = 1, HunQiData.SHENZHOU_XIlIAN_MAX_SLOT do
			self.xilian_data[i].xilian_shuxing_value[j] = MsgAdapter.ReadInt()
		end
	end
end

--神州六器采集信息
SCShenzhouWeapondGatherInfo = SCShenzhouWeapondGatherInfo or BaseClass(BaseProtocolStruct)
function SCShenzhouWeapondGatherInfo:__init()
	self.msg_type = 2408
	self.today_gather_times = 0
	self.today_buy_gather_times = 0
	self.scene_leave_num = 0
	self.normal_item_num = 0
	self.rare_item_num = 0
	self.unique_item_num = 0
	self.next_refresh_time = 0
end

function SCShenzhouWeapondGatherInfo:Decode()
	self.today_gather_times = MsgAdapter.ReadChar()
	self.today_buy_gather_times = MsgAdapter.ReadChar()
	self.scene_leave_num = MsgAdapter.ReadShort()
	self.normal_item_num = MsgAdapter.ReadInt()
	self.rare_item_num = MsgAdapter.ReadInt()
	self.unique_item_num = MsgAdapter.ReadInt()
	self.next_refresh_time = MsgAdapter.ReadUInt()
end

--------------秘境淘宝----------------------
SCRAMiJingXunBaoInfo = SCRAMiJingXunBaoInfo or BaseClass(BaseProtocolStruct)
function SCRAMiJingXunBaoInfo:__init()
	self.msg_type = 2409

	self.ra_mijingxunbao_next_free_tao_timestamp = 0
end

function SCRAMiJingXunBaoInfo:Decode()
	self.ra_mijingxunbao_next_free_tao_timestamp = MsgAdapter.ReadUInt()
end

SCRAMiJingXunBaoTaoResultInfo = SCRAMiJingXunBaoTaoResultInfo or BaseClass(BaseProtocolStruct)
function SCRAMiJingXunBaoTaoResultInfo:__init()
	self.msg_type = 2410

	self.count = 0
	self.mijingxunbao_tao_seq = {}
end

function SCRAMiJingXunBaoTaoResultInfo:Decode()
	self.count = MsgAdapter.ReadInt()
	self.mijingxunbao_tao_seq = {}
	for i=1 ,self.count do
		self.mijingxunbao_tao_seq[i] = MsgAdapter.ReadShort()
	end
end


-- 摇钱树 -------------------------------------
SCRAMoneyTreeInfo = SCRAMoneyTreeInfo or BaseClass(BaseProtocolStruct)
function SCRAMoneyTreeInfo:__init()
	self.msg_type = 2411
	self.money_tree_total_times = 0
	self.money_tree_free_timestamp = 0
	self.server_total_pool_gold = 0
	self.server_reward_has_fetch_reward_flag = 0
end

function SCRAMoneyTreeInfo:Decode()
	self.money_tree_total_times = MsgAdapter.ReadInt()
	self.money_tree_free_timestamp = MsgAdapter.ReadUInt()
	self.server_total_pool_gold = MsgAdapter.ReadInt()
	self.server_reward_has_fetch_reward_flag = MsgAdapter.ReadInt()
end

-- 抽奖结果
SCRAMoneyTreeChouResultInfo = SCRAMoneyTreeChouResultInfo or BaseClass(BaseProtocolStruct)
function SCRAMoneyTreeChouResultInfo:__init()
	self.msg_type = 2412
	self.reward_req_list_count = 0
	self.reward_req_list = {}
end

function SCRAMoneyTreeChouResultInfo:Decode()
	self.reward_req_list_count = MsgAdapter.ReadInt()
	self.reward_req_list = {}
	for i = 1, self.reward_req_list_count do
		self.reward_req_list [i] = MsgAdapter.ReadChar()
	end
end


-------------------翻翻转------------------------
SCRAKingDrawInfo = SCRAKingDrawInfo or BaseClass(BaseProtocolStruct)
function SCRAKingDrawInfo:__init()
	self.msg_type = 2420
	self.card_list = {}
	self.draw_times = {}
	self.return_reward_flag = 0
end

function SCRAKingDrawInfo:Decode()
	self.draw_times = {}
	for i=0,GameEnum.RA_KING_DRAW_LEVEL_COUNT - 1 do
		self.draw_times[i] = MsgAdapter.ReadUShort()
	end
	MsgAdapter.ReadShort()
	self.return_reward_flag = MsgAdapter.ReadInt()
	self.card_list = {}
	for i = 0, GameEnum.RA_KING_DRAW_LEVEL_COUNT - 1 do
		local records_item = {}
		for j = 0, GameEnum.RA_KING_DRAW_MAX_SHOWED_COUNT - 1 do
			records_item[j] = MsgAdapter.ReadShort()
		end
		self.card_list[i] = records_item
		MsgAdapter.ReadShort()
	end
end

SCRAKingDrawMultiReward = SCRAKingDrawMultiReward or BaseClass(BaseProtocolStruct)
function SCRAKingDrawMultiReward:__init()
	self.msg_type = 2421
	self.reward_count = 0
	self.reward_seq_list = {}
end

function SCRAKingDrawMultiReward:Decode()
	self.reward_count = MsgAdapter.ReadShort()
	self.reward_seq_list = {}
	for i = 0, self.reward_count - 1 do
		self.reward_seq_list[i] = MsgAdapter.ReadShort()
	end

end


--宝宝-------------------------------------------
SCBabyInfo = SCBabyInfo or BaseClass(BaseProtocolStruct)
function SCBabyInfo:__init()
	self.msg_type = 2413
	self.baby_index = 0
	self.baby_id  = 0
	self.rename_times = 0
	self.grade = 0
	self.level = 0
	self.bless = 0
	self.baby_name = ""
	-- self.lover_uid = 0
	self.baby_info = {}
end

function SCBabyInfo:Decode()
	local data = {}
	data.baby_index = MsgAdapter.ReadShort()
	data.baby_id = MsgAdapter.ReadShort() or -1
	data.rename_times = MsgAdapter.ReadShort() or 0
	data.grade = MsgAdapter.ReadShort() or 0
	data.level = MsgAdapter.ReadShort() or 0
	data.bless = MsgAdapter.ReadShort() or 0
	-- data.lover_uid = MsgAdapter.ReadInt() or 0
	data.baby_name = MsgAdapter.ReadStrN(32) or ""
	data.lover_name = MsgAdapter.ReadStrN(32) or ""
	local baby_spirit_list = {}
	for i = 0, GameEnum.BABY_SPIRIT_COUNT - 1 do
		local sprite_data = {}
		sprite_data.spirit_level = MsgAdapter.ReadChar()
		sprite_data.reserve_ch = MsgAdapter.ReadChar()
		sprite_data.spirit_train = MsgAdapter.ReadShort()
		baby_spirit_list[i] = sprite_data
	end
	data.baby_spirit_list = baby_spirit_list
	self.baby_info = data
end


SCBabyBornRoute = SCBabyBornRoute or BaseClass(BaseProtocolStruct)
function SCBabyBornRoute:__init()
	self.msg_type = 2414
	self.type = 0
end

function SCBabyBornRoute:Decode()
	self.type = MsgAdapter.ReadInt()
end


SCBabyAllInfo = SCBabyAllInfo or BaseClass(BaseProtocolStruct)
function SCBabyAllInfo:__init()
	self.msg_type = 2415
	self.baby_list = {}
	baby_chaosheng_count = 0
end

function SCBabyAllInfo:Decode()
	self.baby_list = {}
	for i = 1, GameEnum.BABY_MAX_COUNT do
		local data = {}
		data.baby_index = MsgAdapter.ReadShort()
		data.baby_id = MsgAdapter.ReadShort() or -1
		data.rename_times = MsgAdapter.ReadShort() or 0
		data.grade = MsgAdapter.ReadShort() or 0
		data.level = MsgAdapter.ReadShort() or 0
		data.bless = MsgAdapter.ReadShort() or 0
		-- data.lover_uid = MsgAdapter.ReadInt() or 0
		data.baby_name = MsgAdapter.ReadStrN(32) or ""
		data.lover_name = MsgAdapter.ReadStrN(32) or ""
		local baby_spirit_list = {}
		for j = 0, GameEnum.BABY_SPIRIT_COUNT - 1 do
			local sprite_data = {}
			sprite_data.spirit_level = MsgAdapter.ReadChar()
			sprite_data.reserve_ch = MsgAdapter.ReadChar()
			sprite_data.spirit_train = MsgAdapter.ReadShort()
			baby_spirit_list[j] = sprite_data
		end
		data.baby_spirit_list = baby_spirit_list
		self.baby_list[i] = data
	end
	self.baby_chaosheng_count = MsgAdapter.ReadInt()

	self.super_baby_info = {}
	self.super_baby_info.grade = MsgAdapter.ReadShort()
	self.super_baby_info.baby_id = MsgAdapter.ReadShort()
	self.super_baby_info.fight_flag = MsgAdapter.ReadShort()
	MsgAdapter.ReadShort()
	self.super_baby_info.baby_name = MsgAdapter.ReadStrN(32)

	--功能开启的时间
	self.func_open_timestamp = MsgAdapter.ReadUInt()
end

SCBabySpiritInfo = SCBabySpiritInfo or BaseClass(BaseProtocolStruct)
function SCBabySpiritInfo:__init()
	self.msg_type = 2416
	self.baby_index = 0
	self.baby_spirit_list = {}
end

function SCBabySpiritInfo:Decode()
	self.baby_index = MsgAdapter.ReadInt()
	self.baby_spirit_list = {}
	for i = 0, GameEnum.BABY_SPIRIT_COUNT - 1 do
		local data = {}
		data.spirit_level = MsgAdapter.ReadChar()
		data.reserve_ch = MsgAdapter.ReadChar()
		data.spirit_train = MsgAdapter.ReadShort()
		self.baby_spirit_list[i] = data
	end
end


CSBabyOperaReq = CSBabyOperaReq or BaseClass(BaseProtocolStruct)
function CSBabyOperaReq:__init()
	self.msg_type = 2417
	self.opera_type = 0
	self.param_0 = 0
	self.param_1 = 0
	self.param_2 = 0
	self.param_3 = 0
end

function CSBabyOperaReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.opera_type)
	MsgAdapter.WriteShort(self.param_0)
	MsgAdapter.WriteInt(self.param_1)
	MsgAdapter.WriteInt(self.param_2)
	MsgAdapter.WriteInt(self.param_3)
end

CSBabyUpgradeReq = CSBabyUpgradeReq or BaseClass(BaseProtocolStruct)
function CSBabyUpgradeReq:__init()
	self.msg_type = 2418
	self.baby_index = 0
	self.repeat_times = 0
	self.auto_buy = 0
	self.is_auto_upgrade = 0
end

function  CSBabyUpgradeReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.baby_index)
	MsgAdapter.WriteShort(self.repeat_times)
	MsgAdapter.WriteShort(self.auto_buy)
	MsgAdapter.WriteShort(self.is_auto_upgrade)
end


CSBabyRenameReq = CSBabyRenameReq or BaseClass(BaseProtocolStruct)
function CSBabyRenameReq:__init()
	self.msg_type = 2419
	self.baby_index = 0
	self.newname = ""
end

function CSBabyRenameReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.baby_index)
	MsgAdapter.WriteShort(0)
	MsgAdapter.WriteStrN(self.newname, 32)
end
--宝宝-------------------------------------------


--三件套
SCRATotalCharge3Info = SCRATotalCharge3Info or BaseClass(BaseProtocolStruct)
function SCRATotalCharge3Info:__init()
	self.msg_type = 2422
	self.cur_total_charge = 0
	self.cur_total_has_fetch_flag = {}
end

function SCRATotalCharge3Info:Decode()
	self.cur_total_charge = MsgAdapter.ReadInt()
	local has_fetch_flag = bit:d2b(MsgAdapter.ReadInt())
	self.cur_total_has_fetch_flag = {}
	for i = 0, 2 do
		self.cur_total_has_fetch_flag[i] = has_fetch_flag[32 - i]
	end
end


CSRATotalCharge3Info = CSRATotalCharge3Info	 or BaseClass(BaseProtocolStruct)
function CSRATotalCharge3Info:__init()
	self.msg_type = 2423
end

function CSRATotalCharge3Info:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end


--请求下发新三件套信息
CSRATotalCharge4Info = CSRATotalCharge4Info	 or BaseClass(BaseProtocolStruct)
function CSRATotalCharge4Info:__init()
	self.msg_type = 2424
end

function CSRATotalCharge4Info:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

--随机活动 累计充值4(新三件套)
SCRATotalCharge4Info = SCRATotalCharge4Info or BaseClass(BaseProtocolStruct)
function SCRATotalCharge4Info:__init()
	self.msg_type = 2425
	self.cur_total_charge = 0
	self.cur_total_charge_has_fetch_flag = 0
end

function SCRATotalCharge4Info:Decode()
	self.cur_total_charge = MsgAdapter.ReadInt()
	self.cur_total_charge_has_fetch_flag = MsgAdapter.ReadInt()
end

--开心矿场信息下发协议
SCRAMineAllInfo = SCRAMineAllInfo or BaseClass(BaseProtocolStruct)
function SCRAMineAllInfo:__init()
	self.msg_type = 2426

	self.total_refresh_times = 0
	self.role_refresh_times = 0
	self.free_gather_times = 0
	self.next_refresh_time = 0
	self.cur_reward_fetch_flag = 0
	self.reward_begin_index = 0
	self.reward_end_index = 0
	self.gather_count_list = {}
	self.mine_cur_type_list = {}
end

function SCRAMineAllInfo:Decode()
	self.gather_count_list = {}
	self.mine_cur_type_list = {}
	self.total_refresh_times = MsgAdapter.ReadInt()
	self.role_refresh_times = MsgAdapter.ReadInt()
	self.free_gather_times = MsgAdapter.ReadInt()
	self.next_refresh_time = MsgAdapter.ReadInt()
	self.cur_reward_fetch_flag = MsgAdapter.ReadInt()

	for i = 0, GameEnum.RA_MINE_MAX_TYPE_COUNT - 1 do
		self.gather_count_list[i] = MsgAdapter.ReadInt()
	end

	for i = 1, GameEnum.RA_MINE_MAX_REFRESH_COUNT do
		self.mine_cur_type_list[i] = MsgAdapter.ReadChar()
	end

	self.reward_begin_index = MsgAdapter.ReadShort()
	self.reward_end_index = MsgAdapter.ReadShort()
end

SCOtherCapabilityInfo = SCOtherCapabilityInfo or BaseClass(BaseProtocolStruct)
function SCOtherCapabilityInfo:__init()
	self.msg_type = 2427
	self.active_flag = 0
end

function SCOtherCapabilityInfo:Decode()
	self.active_flag = MsgAdapter.ReadInt()
end

------------顶刮刮-------------------------------------------
SCRAGuaGuaInfo = SCRAGuaGuaInfo or BaseClass(BaseProtocolStruct)
function SCRAGuaGuaInfo:__init()
	self.msg_type = 2428
	self.guagua_acc_count = 0;										--累计抽奖次数
	self.guagua_acc_reward_has_fetch_flag = 0;						--已经领取标记
end

function SCRAGuaGuaInfo:Decode()
	self.guagua_acc_count = MsgAdapter.ReadUShort()
	self.guagua_acc_reward_has_fetch_flag = MsgAdapter.ReadUShort();
end

SCRAGuaGuaMultiReward = SCRAGuaGuaMultiReward or BaseClass(BaseProtocolStruct)
function SCRAGuaGuaMultiReward:__init()
	self.msg_type = 2429
	self.reward_count = 0
	self.is_bind = 0
	self.reward_seq_list = {}
end

function SCRAGuaGuaMultiReward:Decode()
	self.reward_count = MsgAdapter.ReadInt()
	self.is_bind = MsgAdapter.ReadInt()
	self.reward_seq_list = {}
	for i = 0, self.reward_count - 1 do
		self.reward_seq_list[i] = MsgAdapter.ReadShort()
	end
end

-------------------天命卜卦------------------------
SCRATianMingDivinationInfo = SCRATianMingDivinationInfo or BaseClass(BaseProtocolStruct)
function SCRATianMingDivinationInfo:__init()
	self.msg_type = 2430

	self.free_chou_times = 0
	self.add_lots_list = {}
	self.reward_history_item_count_list = {}
	self.reward_history_list_cur_index = 0
end

function SCRATianMingDivinationInfo:Decode()
	self.free_chou_times = MsgAdapter.ReadInt()
	self.add_lots_list = {}
	for i = 0, GameEnum.RA_TIANMING_LOT_COUNT - 1 do
		self.add_lots_list[i] = MsgAdapter.ReadChar()
	end

	self.reward_history_item_count_list = {}
	for i = 1, GameEnum.RA_TIANMING_REWARD_HISTORY_COUNT do
		local reward_history_item_count = {}
		reward_history_item_count.seq = MsgAdapter.ReadChar()
		reward_history_item_count.add_lot = MsgAdapter.ReadChar()
		self.reward_history_item_count_list[i] = reward_history_item_count
	end
	self.reward_history_list_cur_index = MsgAdapter.ReadUShort()
end

SCTianMingDivinationActivityStartChouResult = SCTianMingDivinationActivityStartChouResult or BaseClass(BaseProtocolStruct)
function SCTianMingDivinationActivityStartChouResult:__init()
	self.msg_type = 2431

	self.reward_index = 0
	self.item_info_list = {}
end

function SCTianMingDivinationActivityStartChouResult:Decode()
	self.reward_index = MsgAdapter.ReadShort()
	self.item_count = MsgAdapter.ReadShort()
	self.item_info_list = {}
	for i = 1, self.item_count do
		local vo = {}
		vo.item_id = MsgAdapter.ReadUShort()
		vo.num = MsgAdapter.ReadShort()
		vo.is_bind = MsgAdapter.ReadShort()
		MsgAdapter.ReadShort()
		self.item_info_list[i] = vo
	end
end

-------------------翻翻转活动------------------------
SCRAFanFanAllInfo = SCRAFanFanAllInfo or BaseClass(BaseProtocolStruct)
function SCRAFanFanAllInfo:__init()
	self.msg_type = 2432

	self.next_refresh_time = 0			-- 下一次重置时间
	self.card_type_list = {}			-- 卡牌类型列表，物品为seq值，隐藏卡和字组卡是枚举值
	self.word_active_info_list = {}		-- 字组激活信息列表
	self.hidden_word_info = {}			-- 隐藏字信息
	self.fanfan_cur_free_times = 0		-- 当前免费次数
	self.fanfan_cur_word_seq = 0		-- 当前刷到的字组索引
end

function SCRAFanFanAllInfo:Decode()
	self.next_refresh_time = MsgAdapter.ReadInt()
	self.card_type_list = {}

	for i = 0, GameEnum.RA_FANFAN_CARD_COUNT - 1  do
		self.card_type_list[i] = MsgAdapter.ReadUChar()
	end

	self.word_active_info_list = {}
	for i = 0, GameEnum.RA_FANFAN_MAX_WORD_COUNT - 1  do
		local table = {}
		table.active_flag = MsgAdapter.ReadChar()
		table.active_count = MsgAdapter.ReadUChar()
		self.word_active_info_list[i] = table
	end

	self.hidden_word_info = {}
	self.hidden_word_info.hidden_word_seq = MsgAdapter.ReadUChar()
	-- 占位
	MsgAdapter.ReadChar()
	MsgAdapter.ReadChar()
	MsgAdapter.ReadChar()
	self.hidden_word_info.hidden_letter_pos_list = {}
	for i = 0, GameEnum.RA_FANFAN_LETTER_COUNT_PER_WORD - 1 do
		self.hidden_word_info.hidden_letter_pos_list[i] = MsgAdapter.ReadUChar()
	end

	self.fanfan_cur_free_times = MsgAdapter.ReadChar()

	-- 占位
	MsgAdapter.ReadChar()
	MsgAdapter.ReadChar()
	MsgAdapter.ReadChar()
	self.ra_fanfan_leichou_times = MsgAdapter.ReadInt()
	self.is_fanfan_giveout = MsgAdapter.ReadInt()
end

SCRAFanFanWordExchangeResult = SCRAFanFanWordExchangeResult or BaseClass(BaseProtocolStruct)	-- 字组兑换返回的协议

function SCRAFanFanWordExchangeResult:__init()
	self.msg_type = 2433

	self.index = 0			-- 下一次重置时间
	self.active_count = 0		-- 当前免费次数
end

function SCRAFanFanWordExchangeResult:Decode()
	self.index = MsgAdapter.ReadShort()
	self.active_count = MsgAdapter.ReadShort()
end

-------------------连充特惠------------------------
SCRAContinueChongzhiInfo = SCRAContinueChongzhiInfo or BaseClass(BaseProtocolStruct)
function SCRAContinueChongzhiInfo:__init()
	self.msg_type = 2434

	self.today_chongzhi = 0
	self.can_fetch_reward_flag = 0
	self.has_fetch_reward_flag = 0
	self.continue_chongzhi_days = 0
	self.is_activity_over = 0
end

function SCRAContinueChongzhiInfo:Decode()
	self.today_chongzhi = MsgAdapter.ReadUInt()
	self.can_fetch_reward_flag = MsgAdapter.ReadShort()
	self.has_fetch_reward_flag = MsgAdapter.ReadShort()
	self.continue_chongzhi_days = MsgAdapter.ReadChar()
	self.is_activity_over = MsgAdapter.ReadChar()
	MsgAdapter.ReadShort()
end

-------------------连消特惠------------------------
SCRAContinueConsumeInfo = SCRAContinueConsumeInfo or BaseClass(BaseProtocolStruct)
function SCRAContinueConsumeInfo:__init()
	self.msg_type = 2435

	self.today_consume_gold_total = 0	-- 当天累计消费
	self.cur_consume_gold = 0		-- 上次领奖到现在的消费
	self.continue_days_total = 0		-- 总达标天数
	self.continue_days = 0		-- 连续达标天数
	self.current_day_index = 0		-- 当前活动处于第几天
	self.extra_reward_num = 0	-- 特殊奖励领取标记
end

function SCRAContinueConsumeInfo:Decode()
	self.today_consume_gold_total = MsgAdapter.ReadUInt()
	self.cur_consume_gold = MsgAdapter.ReadUInt()
	self.continue_days_total = MsgAdapter.ReadChar()
	self.continue_days = MsgAdapter.ReadChar()
	self.current_day_index = MsgAdapter.ReadChar()
	self.extra_reward_num = MsgAdapter.ReadChar()
end

-------------------------军歌嘹亮-------------------------
SCRAArmyDayInfo = SCRAArmyDayInfo or BaseClass(BaseProtocolStruct)
function SCRAArmyDayInfo:__init()
	self.msg_type = 2436
	self.reserve_sh = 0
	self.belong_army_side = 0
	self.exchange_flag = 0
	self.army_day_own_flags_list = {}
	self.army_day_own_score_list = {}
	self.army_day_all_flags_list = {}
end

function SCRAArmyDayInfo:Decode()
	self.belong_army_side = MsgAdapter.ReadChar()
	self.exchange_flag = MsgAdapter.ReadChar()
	self.reserve_sh = MsgAdapter.ReadShort()




	self.army_day_own_flags_list = {}
	for i = 0,RA_FLAG_TYPE.RA_ARMY_DAY_ARMY_SIDE_NUM - 1 do
	self.army_day_own_flags_list[i] = {}
	self.army_day_own_flags_list[i] = MsgAdapter.ReadInt()
	end

	self.army_day_own_score_list = {}
	for i = 0,RA_FLAG_TYPE.RA_ARMY_DAY_ARMY_SIDE_NUM - 1 do
	self.army_day_own_score_list[i] = {}
	self.army_day_own_score_list[i] = MsgAdapter.ReadInt()
	end

	self.army_day_all_flags_list = {}
	for i = 0,RA_FLAG_TYPE.RA_ARMY_DAY_ARMY_SIDE_NUM - 1 do
	self.army_day_all_flags_list[i] = {}
	self.army_day_all_flags_list[i] = MsgAdapter.ReadInt()
	end

end

------------------------循环充值----------------------------------------------------------
SCRACirculationChongzhiInfo = SCRACirculationChongzhiInfo or BaseClass(BaseProtocolStruct)
function SCRACirculationChongzhiInfo:__init()
	self.msg_type = 2437
	self.total_chongzhi = 0
	self.cur_chongzhi = 0
end

function SCRACirculationChongzhiInfo:Decode()
	self.total_chongzhi = MsgAdapter.ReadUInt()			        	-- 累计充值
	self.cur_chongzhi = MsgAdapter.ReadUInt() 						-- 上次领奖到现在的充值
end



---------------------至尊幸运星--------------------------------------------------------------
--至尊幸运星刷新协议
SCRAExtremeLuckyAllInfo = SCRAExtremeLuckyAllInfo or BaseClass(BaseProtocolStruct)
function SCRAExtremeLuckyAllInfo:__init()
	self.msg_type = 2438
	self.next_flush_timestamp = 0                                   -- 下次刷新时间
	self.free_draw_times = 0                                        -- 剩余免费次数
	self.lottery_times = 0     										-- 刷新次数
	self.lottery_times_gold = 0                                     -- 用元宝抽奖次数
	self.cur_item_info_list = {}
end

function SCRAExtremeLuckyAllInfo:Decode()
	self.next_flush_timestamp = MsgAdapter.ReadUInt()
	self.free_draw_times = MsgAdapter.ReadShort()
	self.lottery_times = MsgAdapter.ReadShort()
	self.lottery_times_gold = MsgAdapter.ReadInt()
	self.total_times = MsgAdapter.ReadShort()
	self.return_reward_flag = MsgAdapter.ReadShort()

	self.cur_item_info_list = {}
	for i = 1, GameEnum.RA_EXTREME_LUCKY_REWARD_COUNT do
		self.cur_item_info_list[i] = {}
		self.cur_item_info_list[i].seq = MsgAdapter.ReadShort()
		self.cur_item_info_list[i].invalid = MsgAdapter.ReadChar()
		self.cur_item_info_list[i].has_fetch = MsgAdapter.ReadChar()  --领取标记
		self.cur_item_info_list[i].weight = MsgAdapter.ReadInt()
	end
end

--至尊幸运星抽奖协议
SCRAExtremeLuckySingleInfo = SCRAExtremeLuckySingleInfo or BaseClass(BaseProtocolStruct)
function SCRAExtremeLuckySingleInfo:__init()
	self.msg_type = 2439
	self.single_lottery_times = 0
	self.single_lottery_times_gold = 0
	self.single_free_draw_times = 0
	self.single_item_info = {}

end

function SCRAExtremeLuckySingleInfo:Decode()
	self.single_lottery_times = MsgAdapter.ReadShort()
	self.single_lottery_times_gold = MsgAdapter.ReadShort()
	self.total_times = MsgAdapter.ReadShort()
	self.return_reward_flag = MsgAdapter.ReadShort()
	self.single_free_draw_times = MsgAdapter.ReadInt()

	self.single_item_info = {}
	self.single_item_info.seq = MsgAdapter.ReadShort()
	self.single_item_info.invalid = MsgAdapter.ReadChar()
	self.single_item_info.has_fetch = MsgAdapter.ReadChar()
	self.single_item_info.weight = MsgAdapter.ReadInt()
end


--------------灵虚宝藏----------------------
SCRAMiJingXunBao2Info = SCRAMiJingXunBao2Info or BaseClass(BaseProtocolStruct)
function SCRAMiJingXunBao2Info:__init()
	self.msg_type = 2440

	self.ra_mijingxunbao_next_free_tao_timestamp = 0
end

function SCRAMiJingXunBao2Info:Decode()
	self.ra_mijingxunbao_next_free_tao_timestamp = MsgAdapter.ReadUInt()
end

SCRAMiJingXunBao2TaoResultInfo = SCRAMiJingXunBao2TaoResultInfo or BaseClass(BaseProtocolStruct)
function SCRAMiJingXunBao2TaoResultInfo:__init()
	self.msg_type = 2441

	self.count = 0
	self.mijingxunbao_tao_seq = {}
end

function SCRAMiJingXunBao2TaoResultInfo:Decode()
	self.count = MsgAdapter.ReadInt()
	self.mijingxunbao_tao_seq = {}
	for i=1 ,self.count do
		self.mijingxunbao_tao_seq[i] = MsgAdapter.ReadShort()
	end
end


-- 天泉祈福 -------------------------------------
SCRAMoneyTree2Info = SCRAMoneyTree2Info or BaseClass(BaseProtocolStruct)
function SCRAMoneyTree2Info:__init()
	self.msg_type = 2442

	self.server_total_money_tree_times = 0
	self.server_total_pool_gold = 0
	self.server_reward_has_fetch_reward_flag = 0
end

function SCRAMoneyTree2Info:Decode()
	self.server_total_money_tree_times = MsgAdapter.ReadInt()
	self.server_total_pool_gold = MsgAdapter.ReadInt()
	self.server_reward_has_fetch_reward_flag = MsgAdapter.ReadInt()
end

-- 抽奖结果
SCRAMoneyTree2ChouResultInfo = SCRAMoneyTree2ChouResultInfo or BaseClass(BaseProtocolStruct)
function SCRAMoneyTree2ChouResultInfo:__init()
	self.msg_type = 2443

	self.reward_req_list = {}
end

function SCRAMoneyTree2ChouResultInfo:Decode()
	local reward_req_list_count = MsgAdapter.ReadInt()
	self.reward_req_list = {}
	for i = 1, reward_req_list_count do
		self.reward_req_list [i] = MsgAdapter.ReadChar()
	end
end

-------------珍宝阁---------------------
SCRAZhenbaoge2Info = SCRAZhenbaoge2Info or BaseClass(BaseProtocolStruct)
function SCRAZhenbaoge2Info:__init()
	self.msg_type = 2444
	self.zhenbaoge_item_list = {}
	self.zhenbaoge_server_fetch_flag = 0
	self.cur_server_flush_times = 0
	self.zhenbaoge_next_flush_timestamp = 0
end

function SCRAZhenbaoge2Info:Decode()
	self.zhenbaoge_item_list = {}
	for i=0, GameEnum.RAND_ACTIVITY_ZHENBAOGE_ITEM_COUNT-1 do
		self.zhenbaoge_item_list[i] = MsgAdapter.ReadShort()
	end
	MsgAdapter.ReadShort()
	self.zhenbaoge_server_fetch_flag = MsgAdapter.ReadShort()
	self.cur_server_flush_times = MsgAdapter.ReadShort()
	self.zhenbaoge_next_flush_timestamp = MsgAdapter.ReadUInt()
end

------------------步步高升------------------------------
SCPromotingPositionAllInfo = SCPromotingPositionAllInfo or BaseClass(BaseProtocolStruct)
function SCPromotingPositionAllInfo:__init()
	self.msg_type = 2445
	self.next_free_timestamp = 0
	self.extra_times = 0
	self.start_pos = {}
	self.records_count = 0
	self.record_list = {}
	self.reward_flag = 0
	self.records_count = 0
end

function SCPromotingPositionAllInfo:Decode()
	self.record_list = {}
	self.next_free_timestamp = MsgAdapter.ReadUInt()
	self.extra_times = MsgAdapter.ReadUShort()
	MsgAdapter.ReadShort()
	self.start_pos["circle_type"] = MsgAdapter.ReadChar()
	MsgAdapter.ReadChar()
	self.start_pos["position"] = MsgAdapter.ReadShort()
	self.reward_flag = MsgAdapter.ReadInt()
	local records_count = MsgAdapter.ReadInt()
	for i=1, records_count do
		self.record_list[i] = {}
		self.record_list[i]["user_name"] = MsgAdapter.ReadStrN(32)
		self.record_list[i]["uid"] = MsgAdapter.ReadInt()
		self.record_list[i]["circle_type"] = MsgAdapter.ReadChar()
		MsgAdapter.ReadChar()
		self.record_list[i]["seq"] = MsgAdapter.ReadShort()
	end
end

-- 双开协议
SCPromotingPositionRewardInfo = SCPromotingPositionRewardInfo or BaseClass(BaseProtocolStruct)
function SCPromotingPositionRewardInfo:__init()
	self.msg_type = 2446
	self.split_position = 0
	self.reward_count = 0
	self.reward_info_list = {}
end

function SCPromotingPositionRewardInfo:Decode()
	self.reward_info_list = {}
	self.split_position = MsgAdapter.ReadInt()
	self.reward_count = MsgAdapter.ReadInt()
	for i=1 ,self.reward_count do
		self.reward_info_list[i] = {}
		self.reward_info_list[i]["circle_type"] = MsgAdapter.ReadChar()
		MsgAdapter.ReadChar()
		self.reward_info_list[i]["seq"] = MsgAdapter.ReadShort()
	end
end
--------------------------------------------------------

--------------------黑市竞拍--------------------
SCRABlackMarketAllInfo = SCRABlackMarketAllInfo or BaseClass(BaseProtocolStruct)
function SCRABlackMarketAllInfo:__init()
	self.msg_type = 2447
end

function SCRABlackMarketAllInfo:Decode()
	self.item_info_list = {}
	for i = 1, GameEnum.BLACK_MARKET_MAX_ITEM_COUNT do
		local data = {}
		data.seq = MsgAdapter.ReadInt()  			-- 物品的配置seq
		data.cur_price = MsgAdapter.ReadInt() 		-- 当前拍卖价格
		data.buyer_uid = MsgAdapter.ReadInt()
		data.buyer_name = MsgAdapter.ReadStrN(32)
		self.item_info_list[i] = data
	end
end
------------------------------------------------

SCWorldBossWearyInfo = SCWorldBossWearyInfo or BaseClass(BaseProtocolStruct)
function SCWorldBossWearyInfo:__init()
	self.msg_type = 2452
	self.worldboss_weary = 0
	self.worldboss_weary_last_die_time = 0
end

function SCWorldBossWearyInfo:Decode()
	self.worldboss_weary = MsgAdapter.ReadInt()
	self.worldboss_weary_last_die_time = MsgAdapter.ReadUInt()
end


--------------------------------------------------
-- 金银塔运营活动累计奖励与免费次数
SCRALevelLotteryActivityInfo = SCRALevelLotteryActivityInfo or BaseClass(BaseProtocolStruct)
function SCRALevelLotteryActivityInfo:__init()
	self.msg_type                        = 2453
	self.ra_level_lottery_free_buy_times = 0			-- 每日免费购买次数
	self.ra_lottery_next_free_timestamp  = 0			-- 下次免费购买时间
	self.ra_lottery_buy_total_times      = 0			-- 累计购买次数
	self.ra_lottery_fetch_reward_flag   = 0			-- 最后领取奖励的次数
end

function SCRALevelLotteryActivityInfo:Decode()
	self.ra_level_lottery_free_buy_times = MsgAdapter.ReadInt()
	self.ra_lottery_next_free_timestamp  = MsgAdapter.ReadUInt()
	self.ra_lottery_buy_total_times      = MsgAdapter.ReadInt()
	self.ra_lottery_fetch_reward_flag   = MsgAdapter.ReadUInt()
end

----------------------------------------------------
-- 连充特惠初
SCRAContinueChongzhiInfoChu = SCRAContinueChongzhiInfoChu or BaseClass(BaseProtocolStruct)
function SCRAContinueChongzhiInfoChu:__init()
	self.msg_type = 2454
end

function SCRAContinueChongzhiInfoChu:Decode()
	self.today_chongzhi = MsgAdapter.ReadUInt()								-- 今日充值数
	self.can_fetch_reward_flag = MsgAdapter.ReadUShort()					-- 奖励激活标记 位0标记特殊奖励,其他位标记达标奖励，值0未激活，值1已激活
	self.has_fetch_reward_falg = MsgAdapter.ReadUShort()					-- 奖励领取标记 位0标记特殊奖励,其他位标记达标奖励，值0未领取，值1已领取
	self.continue_chongzhi_days = MsgAdapter.ReadChar()						-- 连续充值天数
	self.reserve1 = MsgAdapter.ReadChar()
	self.reserve2 = MsgAdapter.ReadShort()
end

----------------------------------------------------
-- 连充特惠高
SCRAContinueChongzhiInfoGao = SCRAContinueChongzhiInfoGao or BaseClass(BaseProtocolStruct)
function SCRAContinueChongzhiInfoGao:__init()
	self.msg_type = 2455
end

function SCRAContinueChongzhiInfoGao:Decode()
	self.today_chongzhi = MsgAdapter.ReadUInt()								-- 今日充值数
	self.can_fetch_reward_flag = MsgAdapter.ReadShort()					-- 奖励激活标记 位0标记特殊奖励,其他位标记达标奖励，值0未激活，值1已激活
	self.has_fetch_reward_falg = MsgAdapter.ReadShort()					-- 奖励领取标记 位0标记特殊奖励,其他位标记达标奖励，值0未领取，值1已领取
	self.continue_chongzhi_days = MsgAdapter.ReadChar()						-- 连续充值天数
	self.reserve1 = MsgAdapter.ReadChar()
	self.reserve2 = MsgAdapter.ReadShort()
end

----------------------------------------------------
-- 聚划算
SCRAXianyuanTreasInfo = SCRAXianyuanTreasInfo or BaseClass(BaseProtocolStruct)
function SCRAXianyuanTreasInfo:__init()
	self.msg_type = 2457
	self.all_buy_gift_fetch_flag = 0
	self.xianyuan_list = {}
end

function SCRAXianyuanTreasInfo:Decode()
	self.all_buy_gift_fetch_flag = MsgAdapter.ReadInt()
	self.xianyuan_list = {}
	for i = 0, 9 do
		local vo = {}
		vo.num = MsgAdapter.ReadShort()
		vo.buy_day_index = MsgAdapter.ReadShort()
		self.xianyuan_list[i] = vo
	end
end

----------------------------------------------------
-- 限时拍卖
SCRARushBuyingAllInfo = SCRARushBuyingAllInfo or BaseClass(BaseProtocolStruct)
function SCRARushBuyingAllInfo:__init()
	self.msg_type = 2458
end

function SCRARushBuyingAllInfo:Decode()
	self.buy_end_timestamp = MsgAdapter.ReadInt()
	MsgAdapter.ReadShort()
	self.buy_phase = MsgAdapter.ReadChar()
	local item_count = MsgAdapter.ReadChar()

	self.item_buy_times_list = nil
	for i = 1, item_count do
		if nil == self.item_buy_times_list then
			self.item_buy_times_list = {}
		end
		self.item_buy_times_list[i] = {}
		self.item_buy_times_list[i].server_buy_times = MsgAdapter.ReadShort()
		self.item_buy_times_list[i].role_buy_times = MsgAdapter.ReadShort()
	end
end

--单笔充值2（单返豪礼）
SCRASingleChongZhiInfo = SCRASingleChongZhiInfo or BaseClass(BaseProtocolStruct)
function SCRASingleChongZhiInfo:__init()
	self.msg_type = 2456
	self.fetch_reward_flag = 0
	self.is_fetch_reward_flag = 0
end

function SCRASingleChongZhiInfo:Decode()
	self.fetch_reward_flag = MsgAdapter.ReadInt()
	self.is_fetch_reward_flag = MsgAdapter.ReadInt()
end

SCRAMapHuntAllInfo = SCRAMapHuntAllInfo or BaseClass(BaseProtocolStruct)
function SCRAMapHuntAllInfo:__init()
	self.msg_type = 2459
end

function SCRAMapHuntAllInfo:Decode()
	self.route_info ={}
	self.route_info.route_index = MsgAdapter.ReadChar()
	self.route_info.route_active_flag = MsgAdapter.ReadChar()
	self.route_info.reserve_sh = MsgAdapter.ReadShort()
	self.route_info.city_list = {}
	for i=1,3 do
		self.route_info.city_list[i] = MsgAdapter.ReadChar()
	end
	self.route_info.city_fetch_flag = MsgAdapter.ReadChar()
	self.flush_times = MsgAdapter.ReadInt()
	self.next_flush_timestamp = MsgAdapter.ReadUInt()
	self.return_reward_fetch_flag = MsgAdapter.ReadShort()
	self.free_count = MsgAdapter.ReadShort()
	self.can_extern_reward = MsgAdapter.ReadInt()
end

--查询合服信息
CSCSAQueryActivityInfo = CSCSAQueryActivityInfo or BaseClass(BaseProtocolStruct)
function CSCSAQueryActivityInfo:__init()
	self.msg_type = 2462
end

function CSCSAQueryActivityInfo:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

-- 换装商城
SCRAMagicShopAllInfo = SCRAMagicShopAllInfo or BaseClass(BaseProtocolStruct)
function SCRAMagicShopAllInfo:__init()
	self.msg_type = 2463

	self.magic_shop_fetch_reward_flag = 0
	self.magic_shop_buy_flag = 0
	self.activity_day = 0
    self.magic_shop_chongzhi_value = 0
end

function SCRAMagicShopAllInfo:Decode()
    self.magic_shop_fetch_reward_flag = MsgAdapter.ReadChar()
	self.magic_shop_buy_flag = MsgAdapter.ReadChar()
	self.activity_day = MsgAdapter.ReadShort()
    self.magic_shop_chongzhi_value = MsgAdapter.ReadUInt()
end

--限时反馈活动
SCRALimitTimeRebateInfo = SCRALimitTimeRebateInfo or BaseClass(BaseProtocolStruct)
function SCRALimitTimeRebateInfo:__init()
	self.msg_type = 2464
	self.cur_day_chongzhi = 0
	self.chongzhi_days = 0
	self.reward_flag = 0
	self.chongzhi_day_list = {}
end

function SCRALimitTimeRebateInfo:Decode()
	self.cur_day_chongzhi = MsgAdapter.ReadInt()
	self.chongzhi_days = MsgAdapter.ReadInt()
	self.reward_flag = MsgAdapter.ReadInt()
	for i=1,9 do
		self.chongzhi_day_list[i] = MsgAdapter.ReadInt()
	end
end

--限时礼包活动---------------------------------------------------------------
SCRATimeLimitGiftInfo = SCRATimeLimitGiftInfo or BaseClass(BaseProtocolStruct)
function SCRATimeLimitGiftInfo:__init()
	self.msg_type = 2465
	self.reward_can_fetch_flag = 0
	self.reward_fetch_flag = 0
	self.open_flag = 0
	self.join_vip_level = 0
	self.begin_timestamp = 0
end

function SCRATimeLimitGiftInfo:Decode()
	self.reward_can_fetch_flag = MsgAdapter.ReadInt()
	self.reward_fetch_flag = MsgAdapter.ReadInt()
	self.join_vip_level = MsgAdapter.ReadShort()
	self.open_flag = MsgAdapter.ReadShort()
	self.begin_timestamp = MsgAdapter.ReadInt()

end

------------------------循环充值----------------------------------------------------------
SCCirculationChongzhiInfo = SCCirculationChongzhiInfo or BaseClass(BaseProtocolStruct)
function SCCirculationChongzhiInfo:__init()
	self.msg_type = 2466
	self.total_chongzhi = 0
	self.cur_chongzhi = 0
end

function SCCirculationChongzhiInfo:Decode()
	self.total_chongzhi = MsgAdapter.ReadUInt()			        	-- 累计充值
	self.cur_chongzhi = MsgAdapter.ReadUInt() 						-- 上次领奖到现在的充值
end

CSCirculationChongzhiOperate = CSCirculationChongzhiOperate or BaseClass(BaseProtocolStruct)

function CSCirculationChongzhiOperate:__init()
	self.msg_type = 2467
	self.operate_type = 0
	self.reserve_sh = 0
end

function CSCirculationChongzhiOperate:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.operate_type)
	MsgAdapter.WriteShort(self.reserve_sh)
end

---------------------------------------秘境寻宝-------------------------------------------
SCRAMiJingXunBaoInfo3 = SCRAMiJingXunBaoInfo3 or BaseClass(BaseProtocolStruct)
function SCRAMiJingXunBaoInfo3:__init()
	self.msg_type = 2480  
	self.ra_mijingxunbao3_next_free_tao_timestamp = 0
	self.chou_times = 0
	self.reward_flag = 0
end

function SCRAMiJingXunBaoInfo3:Decode()
	self.ra_mijingxunbao3_next_free_tao_timestamp = MsgAdapter.ReadInt()
	self.chou_times = MsgAdapter.ReadInt()
	self.reward_flag = MsgAdapter.ReadInt()
end


SCRAMiJingXunBaoTaoResultInfo3 = SCRAMiJingXunBaoTaoResultInfo3 or BaseClass(BaseProtocolStruct)
function SCRAMiJingXunBaoTaoResultInfo3:__init()
	self.msg_type = 2481 
	self.count = 0
	self.mijingxunbao3_tao_seq = {}
end
	
function SCRAMiJingXunBaoTaoResultInfo3:Decode()
	self.count = MsgAdapter.ReadInt()
	self.mijingxunbao3_tao_seq = {}

	for i=1,self.count do
		self.mijingxunbao3_tao_seq[i] = MsgAdapter.ReadShort()
	end
end

-----------------进阶返利------------------------------------------------------------------

-- 随机活动 光环进化
SCRAHaloUpgradeInfo = SCRAHaloUpgradeInfo or BaseClass(BaseProtocolStruct)
function SCRAHaloUpgradeInfo:__init()
	self.msg_type = 2468

	self.grade = 0
	self.can_fetch_reward_flag = 0
	self.fetch_reward_flag = 0
	self.rare_reward_fetch_flag = 0
end

function SCRAHaloUpgradeInfo:Decode()
	self.grade = MsgAdapter.ReadInt()
	self.can_fetch_reward_flag = MsgAdapter.ReadLL()
	self.fetch_reward_flag = MsgAdapter.ReadLL()
	self.rare_reward_fetch_flag = MsgAdapter.ReadLL()
end

--随机活动 足迹进化
SCRAFootPrintUpgradeInfo = SCRAFootPrintUpgradeInfo or BaseClass(BaseProtocolStruct)
function SCRAFootPrintUpgradeInfo:__init()
	self.msg_type = 2469

	self.grade = 0
	self.can_fetch_reward_flag = 0
	self.fetch_reward_flag = 0
	self.rare_reward_fetch_flag = 0
end

function SCRAFootPrintUpgradeInfo:Decode()
	self.grade = MsgAdapter.ReadInt()
	self.can_fetch_reward_flag = MsgAdapter.ReadLL()
	self.fetch_reward_flag = MsgAdapter.ReadLL()
	self.rare_reward_fetch_flag = MsgAdapter.ReadLL()
end

--随机活动 战骑进化
SCRAFightMountUpgradeInfo = SCRAFightMountUpgradeInfo or BaseClass(BaseProtocolStruct)
function SCRAFightMountUpgradeInfo:__init()
	self.msg_type = 2470

	self.grade = 0
	self.can_fetch_reward_flag = 0
	self.fetch_reward_flag = 0
	self.rare_reward_fetch_flag = 0
end

function SCRAFightMountUpgradeInfo:Decode()
	self.grade = MsgAdapter.ReadInt()
	self.can_fetch_reward_flag = MsgAdapter.ReadLL()
	self.fetch_reward_flag = MsgAdapter.ReadLL()
	self.rare_reward_fetch_flag = MsgAdapter.ReadLL()
end

--随机活动 伙伴光环-神弓进化
SCRAShengongUpgradeInfo = SCRAShengongUpgradeInfo or BaseClass(BaseProtocolStruct)
function SCRAShengongUpgradeInfo:__init()
	self.msg_type = 2471

	self.grade = 0
	self.can_fetch_reward_flag = 0
	self.fetch_reward_flag = 0
	self.rare_reward_fetch_flag = 0
end

function SCRAShengongUpgradeInfo:Decode()
	self.grade = MsgAdapter.ReadInt()
	self.can_fetch_reward_flag = MsgAdapter.ReadLL()
	self.fetch_reward_flag = MsgAdapter.ReadLL()
	self.rare_reward_fetch_flag = MsgAdapter.ReadLL()
end

--随机活动 伙伴法阵-神翼进化
SCRAShenyiUpgradeInfo = SCRAShenyiUpgradeInfo or BaseClass(BaseProtocolStruct)
function SCRAShenyiUpgradeInfo:__init()
	self.msg_type = 2472

	self.grade = 0
	self.can_fetch_reward_flag = 0
	self.fetch_reward_flag = 0
	self.rare_reward_fetch_flag = 0
end

function SCRAShenyiUpgradeInfo:Decode()
	self.grade = MsgAdapter.ReadInt()
	self.can_fetch_reward_flag = MsgAdapter.ReadLL()
	self.fetch_reward_flag = MsgAdapter.ReadLL()
	self.rare_reward_fetch_flag = MsgAdapter.ReadLL()
end

--随机活动 伙伴法阵-灵宠进化
SCRALingChongUpgradeInfo = SCRALingChongUpgradeInfo or BaseClass(BaseProtocolStruct)
function SCRALingChongUpgradeInfo:__init()
	self.msg_type = 2490

	self.grade = 0
	self.can_fetch_reward_flag = 0
	self.fetch_reward_flag = 0
	self.rare_reward_fetch_flag = 0
end

function SCRALingChongUpgradeInfo:Decode()
	self.grade = MsgAdapter.ReadInt()
	self.can_fetch_reward_flag = MsgAdapter.ReadLL()
	self.fetch_reward_flag = MsgAdapter.ReadLL()
	self.rare_reward_fetch_flag = MsgAdapter.ReadLL()
end

--随机活动 伙伴法阵-灵弓进化
SCRALingGongUpgradeInfo = SCRALingGongUpgradeInfo or BaseClass(BaseProtocolStruct)
function SCRALingGongUpgradeInfo:__init()
	self.msg_type = 2491

	self.grade = 0
	self.can_fetch_reward_flag = 0
	self.fetch_reward_flag = 0
	self.rare_reward_fetch_flag = 0
end

function SCRALingGongUpgradeInfo:Decode()
	self.grade = MsgAdapter.ReadInt()
	self.can_fetch_reward_flag = MsgAdapter.ReadLL()
	self.fetch_reward_flag = MsgAdapter.ReadLL()
	self.rare_reward_fetch_flag = MsgAdapter.ReadLL()
end

--随机活动 伙伴法阵-灵骑进化
SCRALingQiUpgradeInfo = SCRALingQiUpgradeInfo or BaseClass(BaseProtocolStruct)
function SCRALingQiUpgradeInfo:__init()
	self.msg_type = 2492

	self.grade = 0
	self.can_fetch_reward_flag = 0
	self.fetch_reward_flag = 0
	self.rare_reward_fetch_flag = 0
end

function SCRALingQiUpgradeInfo:Decode()
	self.grade = MsgAdapter.ReadInt()
	self.can_fetch_reward_flag = MsgAdapter.ReadLL()
	self.fetch_reward_flag = MsgAdapter.ReadLL()
	self.rare_reward_fetch_flag = MsgAdapter.ReadLL()
end

---------------------------------------欢乐摇奖-------------------------------------------
-- 欢乐摇奖信息
SCRAHuanLeYaoJiangInfo = SCRAHuanLeYaoJiangInfo or BaseClass(BaseProtocolStruct)
function SCRAHuanLeYaoJiangInfo:__init()
	self.msg_type = 2484  
    self.happy_ernie_next_free_tao_timestamp = 0
    self.chou_times = 0
    self.reward_flag = 0
end

function SCRAHuanLeYaoJiangInfo:Decode()
	self.happy_ernie_next_free_tao_timestamp = MsgAdapter.ReadUInt()
    self.chou_times = MsgAdapter.ReadInt()
    self.reward_flag = MsgAdapter.ReadInt()
end

-- 欢乐摇奖结果信息
SCRAHuanLeYaoJiangTaoResultInfo = SCRAHuanLeYaoJiangTaoResultInfo or BaseClass(BaseProtocolStruct)
function SCRAHuanLeYaoJiangTaoResultInfo:__init()
	self.msg_type = 2486
    self.count = 0
    self.happy_ernie_tao_seq = {}
end
	
function SCRAHuanLeYaoJiangTaoResultInfo:Decode()
	self.count = MsgAdapter.ReadInt()
    self.happy_ernie_tao_seq = {}

    for i = 1, self.count do
		self.happy_ernie_tao_seq[i] = MsgAdapter.ReadShort()
    end
end

--------臻品城-----
SCRARmbBugChestShopInfo = SCRARmbBugChestShopInfo or BaseClass(BaseProtocolStruct)
function SCRARmbBugChestShopInfo:__init()
	self.msg_type = 2474
	self.buy_count_list = {}
end

function SCRARmbBugChestShopInfo:Decode()
	self.buy_count_list = {}
	for i = 1, 64 do
		self.buy_count_list[i] = MsgAdapter.ReadChar()
	end
end

---------------------------------------欢乐砸蛋-------------------------------------------
SCRAHuanLeZaDanInfo = SCRAHuanLeZaDanInfo or BaseClass(BaseProtocolStruct)
function SCRAHuanLeZaDanInfo:__init()
	self.msg_type = 2482  
    self.ra_mijingxunbao_next_free_tao_timestamp = 0
    self.chou_times = 0
    self.reward_flag = 0
end

function SCRAHuanLeZaDanInfo:Decode()
	self.ra_mijingxunbao_next_free_tao_timestamp = MsgAdapter.ReadInt()
    self.chou_times = MsgAdapter.ReadInt()
    self.reward_flag = MsgAdapter.ReadInt()
end


SCRAHuanLeZaDanResultInfo = SCRAHuanLeZaDanResultInfo or BaseClass(BaseProtocolStruct)
function SCRAHuanLeZaDanResultInfo:__init()
	self.msg_type = 2483  
    self.count = 0
    self.mijingxunbao_tao_seq = {}
end

function SCRAHuanLeZaDanResultInfo:Decode()
	self.count = MsgAdapter.ReadInt()
    self.mijingxunbao_tao_seq = {}

    for i=1,self.count do
    	 self.mijingxunbao_tao_seq[i] = MsgAdapter.ReadShort()
    end
end


--随机活动 普天同庆
SCRAResetDoubleChongzhi = SCRAResetDoubleChongzhi or BaseClass(BaseProtocolStruct)
function SCRAResetDoubleChongzhi:__init()
	self.msg_type = 2485

	self.chongzhi_reward_flag = 0
end

function SCRAResetDoubleChongzhi:Decode()
	self.chongzhi_reward_flag = MsgAdapter.ReadInt()
end



--消费返利
SCRAConsumeGoldRewardInfo = SCRAConsumeGoldRewardInfo or BaseClass(BaseProtocolStruct)
function SCRAConsumeGoldRewardInfo:__init()
	self.msg_type = 2473

    self.consume_gold = 0
    self.fetch_reward_flag =0
    self.vip_level = 0
    self.activity_day = 0
end

function SCRAConsumeGoldRewardInfo:Decode()
    self.consume_gold = MsgAdapter.ReadInt()
    self.fetch_reward_flag = MsgAdapter.ReadChar()
    self.vip_level = MsgAdapter.ReadChar()
    self.activity_day = MsgAdapter.ReadShort()
end

-- 买一送一活动
SCBuyOneGetOneFreeInfo = SCBuyOneGetOneFreeInfo or BaseClass(BaseProtocolStruct)
function SCBuyOneGetOneFreeInfo:__init()
	self.msg_type = 2476
	self.buy_flag = 0
	self.free_reward_flag = 0
end

function SCBuyOneGetOneFreeInfo:Decode()
	self.buy_flag = MsgAdapter.ReadLL()
	self.free_reward_flag = MsgAdapter.ReadLL()
end

--消费有礼
SCRAConsumeForGiftAllInfo = SCRAConsumeForGiftAllInfo or BaseClass(BaseProtocolStruct)
function SCRAConsumeForGiftAllInfo:__init()
	self.msg_type = 2477
	self.total_consume_gold = 0
	self.cur_points = 0
	self.item_count = 0
	self.item_exchange_times = {}
end

function SCRAConsumeForGiftAllInfo:Decode()
	self.total_consume_gold = MsgAdapter.ReadInt()             --累计消费
	self.cur_points =  MsgAdapter.ReadInt()                    --上次领奖到现在的消费	
	self.item_count =  MsgAdapter.ReadInt()
	self.item_exchange_times = {}

	for i = 1, self.item_count do
		self.item_exchange_times[i] = MsgAdapter.ReadUChar()
	end	
end

--- 狂返元宝 ------
SCRaCrazyRebateChongInfo = SCRaCrazyRebateChongInfo or BaseClass(BaseProtocolStruct)
function SCRaCrazyRebateChongInfo:__init()
	self.msg_type = 2475
	self.chongzhi_count = 0
end

function SCRaCrazyRebateChongInfo:Decode()
	self.chongzhi_count = MsgAdapter.ReadInt()
end

-- 限时豪礼
SCRATimeLimitLuxuryGiftBagInfo = SCRATimeLimitLuxuryGiftBagInfo or BaseClass(BaseProtocolStruct)
function SCRATimeLimitLuxuryGiftBagInfo:__init()
	self.msg_type = 2487

	self.is_already_buy = 0
	self.join_vip_level = 0
	self.begin_timestamp = 0
	self.time_limit_luxury_gift_open_flag = 0
end

function SCRATimeLimitLuxuryGiftBagInfo:Decode()
	self.is_already_buy = MsgAdapter.ReadShort()
	self.join_vip_level = MsgAdapter.ReadShort()
	self.begin_timestamp = MsgAdapter.ReadInt()
    self.time_limit_luxury_gift_open_flag = MsgAdapter.ReadInt()
end