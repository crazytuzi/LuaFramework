
--—————————————————————————————————————————————————————————————————————————————————
-----------------------------------------------------------------------------------
----------------------------------随机活动-----------------------------------------

-- 随机活动-全民疯抢
SCRAServerPanicBuyInfo = SCRAServerPanicBuyInfo or BaseClass(BaseProtocolStruct)
function SCRAServerPanicBuyInfo:__init()
	self.msg_type = 2204
end

function SCRAServerPanicBuyInfo:Decode()
	self.user_buy_numlist = {}
	self.server_buy_numlist = {}
	for i = 1, GameEnum.RAND_ACTIVITY_SERVER_PANIC_BUY_ITEM_MAX_COUNT do
		table.insert(self.user_buy_numlist, MsgAdapter.ReadInt())
	end
	for i = 1, GameEnum.RAND_ACTIVITY_SERVER_PANIC_BUY_ITEM_MAX_COUNT do
		table.insert(self.server_buy_numlist, MsgAdapter.ReadInt())
	end
end

-- 随机活动-个人疯抢
SCRAPersonalPanicBuyInfo = SCRAPersonalPanicBuyInfo or BaseClass(BaseProtocolStruct)
function SCRAPersonalPanicBuyInfo:__init()
	self.msg_type = 2205
end

function SCRAPersonalPanicBuyInfo:Decode()
	self.buy_numlist = {}
	for i = 1, GameEnum.RAND_ACTIVITY_PERSONAL_PANIC_BUY_ITEM_MAX_COUNT do
		table.insert(self.buy_numlist, MsgAdapter.ReadInt())
	end
end

-- 随机活动-充值排行
SCRAChongzhiRankInfo = SCRAChongzhiRankInfo or BaseClass(BaseProtocolStruct)
function SCRAChongzhiRankInfo:__init()
	self.msg_type = 2206

	self.chongzhi_num = 0
end

function SCRAChongzhiRankInfo:Decode()
	self.chongzhi_num = MsgAdapter.ReadInt()
end

-- 随机活动-每日消费排行
SCRAConsumeGoldRankInfo = SCRAConsumeGoldRankInfo or BaseClass(BaseProtocolStruct)
function SCRAConsumeGoldRankInfo:__init()
	self.msg_type = 2207

	self.consume_gold_num = 0
end

function SCRAConsumeGoldRankInfo:Decode()
	self.consume_gold_num = MsgAdapter.ReadInt()
end

-- 随机活动-消费返利
SCRAConsumeGoldFanliInfo = SCRAConsumeGoldFanliInfo or BaseClass(BaseProtocolStruct)
function SCRAConsumeGoldFanliInfo:__init()
	self.msg_type = 2208

	self.consume_gold = 0
end

function SCRAConsumeGoldFanliInfo:Decode()
	self.consume_gold = MsgAdapter.ReadInt()
end

-- 随机活动-充值返利
SCRADayChongZhiFanLiInfo = SCRADayChongZhiFanLiInfo or BaseClass(BaseProtocolStruct)
function SCRADayChongZhiFanLiInfo:__init()
	self.msg_type = 2209

	self.chongzhi_gold = 0
	self.fetch_reward_flag = 0
end

function SCRADayChongZhiFanLiInfo:Decode()
	self.chongzhi_gold = MsgAdapter.ReadInt()
	self.fetch_reward_flag = MsgAdapter.ReadInt()
end

-- 随机活动-每日消费
SCRADayConsumeGoldInfo = SCRADayConsumeGoldInfo or BaseClass(BaseProtocolStruct)
function SCRADayConsumeGoldInfo:__init()
	self.msg_type = 2210

	self.consume_gold = 0
	self.fetch_reward_flag = 0
end

function SCRADayConsumeGoldInfo:Decode()
	self.consume_gold = MsgAdapter.ReadInt()
	self.fetch_reward_flag = MsgAdapter.ReadInt()
end

-- 随机活动-累计消费活动
SCRATotalConsumeGoldInfo = SCRATotalConsumeGoldInfo or BaseClass(BaseProtocolStruct)
function SCRATotalConsumeGoldInfo:__init()
	self.msg_type = 2211

	self.consume_gold = 0
	self.fetch_reward_flag = 0
end

function SCRATotalConsumeGoldInfo:Decode()
	self.consume_gold = MsgAdapter.ReadInt()
	self.fetch_reward_flag = MsgAdapter.ReadInt()
end

-- 随机活动-每日活跃度信息
SCRADayActiveDegreeInfo = SCRADayActiveDegreeInfo or BaseClass(BaseProtocolStruct)
function SCRADayActiveDegreeInfo:__init()
	self.msg_type = 2212

	self.active_degree = 0
	self.fetch_reward_flag = 0
end

function SCRADayActiveDegreeInfo:Decode()
	self.active_degree = MsgAdapter.ReadInt()
	self.fetch_reward_flag = MsgAdapter.ReadInt()
end

-- 随机活动-击杀boss
SCRAKillBossInfo = SCRAKillBossInfo or BaseClass(BaseProtocolStruct)
function SCRAKillBossInfo:__init()
	self.msg_type = 2213

	self.kill_count = 0
end

function SCRAKillBossInfo:Decode()
	self.kill_count = MsgAdapter.ReadInt()
end

-- 随机活动-奇珍异宝
SCRAChestshopInfo = SCRAChestshopInfo or BaseClass(BaseProtocolStruct)
function SCRAChestshopInfo:__init()
	self.msg_type = 2214

	self.chestshop_times = 0
	self.fetch_reward_flag = 0
end

function SCRAChestshopInfo:Decode()
	self.chestshop_times = MsgAdapter.ReadShort()
	self.fetch_reward_flag = MsgAdapter.ReadShort()
end

-- 随机活动-宝石升级
SCRAStoneUplevelInfo = SCRAStoneUplevelInfo or BaseClass(BaseProtocolStruct)
function SCRAStoneUplevelInfo:__init()
	self.msg_type = 2215

	self.total_level = 0
	self.can_fetch_reward_flag = 0
	self.fetch_reward_flag = 0
end

function SCRAStoneUplevelInfo:Decode()
	self.total_level = MsgAdapter.ReadInt()
	self.can_fetch_reward_flag = MsgAdapter.ReadLL()
	self.fetch_reward_flag = MsgAdapter.ReadLL()
end

-- 随机活动-仙女缠绵
SCRAXiannvChanmianUplevelInfo = SCRAXiannvChanmianUplevelInfo or BaseClass(BaseProtocolStruct)
function SCRAXiannvChanmianUplevelInfo:__init()
	self.msg_type = 2216

	self.chanmian_grade = 0
	self.can_fetch_reward_flag = 0
	self.fetch_reward_flag = 0
end

function SCRAXiannvChanmianUplevelInfo:Decode()
	self.chanmian_grade = MsgAdapter.ReadInt()
	self.can_fetch_reward_flag = MsgAdapter.ReadLL()
	self.fetch_reward_flag = MsgAdapter.ReadLL()
end

-- 随机活动-坐骑进阶
SCRAMountUpgradeInfo = SCRAMountUpgradeInfo or BaseClass(BaseProtocolStruct)
function SCRAMountUpgradeInfo:__init()
	self.msg_type = 2217

	self.grade = 0
	self.can_fetch_reward_flag = 0
	self.fetch_reward_flag = 0
	self.rare_reward_fetch_flag = 0
end

function SCRAMountUpgradeInfo:Decode()
	self.grade = MsgAdapter.ReadInt()
	self.can_fetch_reward_flag = MsgAdapter.ReadShort()
	self.fetch_reward_flag = MsgAdapter.ReadShort()
	self.rare_reward_fetch_flag = MsgAdapter.ReadInt()
end

-- 随机活动 羽翼进化
SCRAWingUpgradeInfo = SCRAWingUpgradeInfo or BaseClass(BaseProtocolStruct)
function SCRAWingUpgradeInfo:__init()
	self.msg_type = 2220

	self.grade = 0
	self.can_fetch_reward_flag = 0
	self.fetch_reward_flag = 0
	self.rare_reward_fetch_flag = 0
end

function SCRAWingUpgradeInfo:Decode()
	self.grade = MsgAdapter.ReadInt()
	self.can_fetch_reward_flag = MsgAdapter.ReadLL()
	self.fetch_reward_flag = MsgAdapter.ReadLL()
	self.rare_reward_fetch_flag = MsgAdapter.ReadInt()
end

--随机活动 骑兵进阶
SCRAQibingUpgradeInfo = SCRAQibingUpgradeInfo or BaseClass(BaseProtocolStruct)
function SCRAQibingUpgradeInfo:__init()
	self.msg_type = 2218

	self.qibing_grade = 0
	self.can_fetch_reward_flag = 0
	self.fetch_reward_flag = 0
end

function SCRAQibingUpgradeInfo:Decode()
	self.qibing_grade = MsgAdapter.ReadInt()
	self.can_fetch_reward_flag = MsgAdapter.ReadShort()
	self.fetch_reward_flag = MsgAdapter.ReadShort()
end

-- 随机活动 根骨全身等级
SCRAMentalityUplevelInfo = SCRAMentalityUplevelInfo or BaseClass(BaseProtocolStruct)
function SCRAMentalityUplevelInfo:__init()
	self.msg_type = 2219

	self.total_mentality_level = 0
	self.can_fetch_reward_flag = 0
	self.fetch_reward_flag = 0
end

function SCRAMentalityUplevelInfo:Decode()
	self.total_mentality_level = MsgAdapter.ReadInt()
	self.can_fetch_reward_flag = MsgAdapter.ReadShort()
	self.fetch_reward_flag = MsgAdapter.ReadShort()
end

-- 随机活动 全民祈福
SCRAQuanminQifuInfo = SCRAQuanminQifuInfo or BaseClass(BaseProtocolStruct)
function SCRAQuanminQifuInfo:__init()
	self.msg_type = 2221

	self.qifu_times = 0
	self.fetch_reward_flag = 0
end

function SCRAQuanminQifuInfo:Decode()
	self.qifu_times = MsgAdapter.ReadShort()
	self.fetch_reward_flag = MsgAdapter.ReadShort()
end

-- 随机活动 手有余香
SCRAShouYouYuXiangInfo = SCRAShouYouYuXiangInfo or BaseClass(BaseProtocolStruct)
function SCRAShouYouYuXiangInfo:__init()
	self.msg_type = 2222

	self.shouyou_yuxiang_fetch_flag = 0
	self.shouyou_yuxiang_give_flower_flag = 0
	self.shouyou_yuxiang_flower_num = 0
end

function SCRAShouYouYuXiangInfo:Decode()
	self.shouyou_yuxiang_fetch_flag = MsgAdapter.ReadShort()
	self.shouyou_yuxiang_give_flower_flag = MsgAdapter.ReadShort()
	self.shouyou_yuxiang_flower_num = MsgAdapter.ReadInt()
end

-- 随机活动 登录送礼
SCRALoginGiftInfo = SCRALoginGiftInfo or BaseClass(BaseProtocolStruct)
function SCRALoginGiftInfo:__init()
	self.msg_type = 2223

	self.login_days = 0
	self.has_login = 0
	self.has_fetch_accumulate_reward = 0
	self.fetch_common_reward_flag = 0
	self.fetch_vip_reward_flag = 0
end

function SCRALoginGiftInfo:Decode()
	self.login_days =  MsgAdapter.ReadShort()
	self.has_login = MsgAdapter.ReadChar()
	self.has_fetch_accumulate_reward = MsgAdapter.ReadChar()
	self.fetch_common_reward_flag = MsgAdapter.ReadInt()
	self.fetch_vip_reward_flag = MsgAdapter.ReadInt()
end

-- 随机活动 仙盟比拼
SCRAXianMengBiPinInfo = SCRAXianMengBiPinInfo or BaseClass(BaseProtocolStruct)
function SCRAXianMengBiPinInfo:__init()
	self.msg_type = 2224

	self.kill_boss_count = 0
end

function SCRAXianMengBiPinInfo:Decode()
	self.kill_boss_count =  MsgAdapter.ReadInt()
end

-- 随机活动 仙盟崛起
SCRAXianMengJueQiInfo = SCRAXianMengJueQiInfo or BaseClass(BaseProtocolStruct)
function SCRAXianMengJueQiInfo:__init()
	self.msg_type = 2225

	self.increase_capability = 0
end

function SCRAXianMengJueQiInfo:Decode()
	self.increase_capability =  MsgAdapter.ReadInt()
end

-- 下一次怪物入侵刷新时间
SCMonsterInvadeTimeNotice = SCMonsterInvadeTimeNotice or BaseClass(BaseProtocolStruct)
function SCMonsterInvadeTimeNotice:__init()
	self.msg_type = 2226

	self.next_monster_invade_time = 0
end

function SCMonsterInvadeTimeNotice:Decode()
	self.next_monster_invade_time =  MsgAdapter.ReadUInt()
end

-- 一战到底
SCYiZhanDaoDiKickout = SCYiZhanDaoDiKickout or BaseClass(BaseProtocolStruct)
function SCYiZhanDaoDiKickout:__init()
	self.msg_type = 2227

	self.reason = 0
	self.jisha_count = 0
	self.dead_count = 0
	self.jisha_score = 0
	self.lucky_count = 0
	self.rank_pos = 0
end

function SCYiZhanDaoDiKickout:Decode()
	self.reason =  MsgAdapter.ReadInt()
	self.jisha_count = MsgAdapter.ReadInt()
	self.dead_count = MsgAdapter.ReadInt()
	self.jisha_score = MsgAdapter.ReadInt()
	self.lucky_count = MsgAdapter.ReadInt()
	self.rank_pos = MsgAdapter.ReadInt()
end

-- 一战到底幸运玩家信息
SCYiZhanDaoDiLuckyInfo = SCYiZhanDaoDiLuckyInfo or BaseClass(BaseProtocolStruct)
function SCYiZhanDaoDiLuckyInfo:__init()
	self.msg_type = 2228

	self.next_lucky_timestamp = 0
	self.luck_user_count = 0
end

function SCYiZhanDaoDiLuckyInfo:Decode()
	self.next_lucky_timestamp =  MsgAdapter.ReadUInt()
	self.luck_user_count = MsgAdapter.ReadInt()
	self.luck_user_namelist = {}
	for i = 1, self.luck_user_count do
		self.luck_user_namelist[i] = MsgAdapter.ReadStrN(32)
	end
end

-- 一战到底称号改变
SCYiZhanDaoDiTitleChange = SCYiZhanDaoDiTitleChange or BaseClass(BaseProtocolStruct)
function SCYiZhanDaoDiTitleChange:__init()
	self.msg_type = 2229

	self.uid = 0
	self.obj_id = 0
	self.title_id = 0
	self.jisha_count = 0
end

function SCYiZhanDaoDiTitleChange:Decode()
	self.uid =  MsgAdapter.ReadInt()
	self.obj_id = MsgAdapter.ReadUShort()
	self.title_id = MsgAdapter.ReadShort()
	self.jisha_count = MsgAdapter.ReadInt()
end

-- 一战到底主角信息
SCYiZhanDaoDiUserInfo = SCYiZhanDaoDiUserInfo or BaseClass(BaseProtocolStruct)
function SCYiZhanDaoDiUserInfo:__init()
	self.msg_type = 2230

	self.jisha_count = 0
	self.jisha_title_id = 0
	self.dead_count = 0
	self.jisha_score = 0
	self.gongji_guwu_per = 0
	self.maxhp_guwu_per = 0
end

function SCYiZhanDaoDiUserInfo:Decode()
	self.jisha_count =  MsgAdapter.ReadInt()
	self.jisha_title_id = MsgAdapter.ReadInt()
	self.dead_count = MsgAdapter.ReadInt()
	self.jisha_score = MsgAdapter.ReadInt()
	self.gongji_guwu_per = MsgAdapter.ReadInt()
	self.maxhp_guwu_per = MsgAdapter.ReadInt()
end

-- 一战到底排行榜信息
SCYiZhanDaoDiRankInfo = SCYiZhanDaoDiRankInfo or BaseClass(BaseProtocolStruct)
function SCYiZhanDaoDiRankInfo:__init()
	self.msg_type = 2231

	self.count = 0
end

function SCYiZhanDaoDiRankInfo:Decode()
	self.count = MsgAdapter.ReadUInt()
	self.rank_list = {}
	for i = 1, self.count do
		local vo = {}
		vo.uid = MsgAdapter.ReadInt()
		vo.user_name = MsgAdapter.ReadStrN(32)
		vo.jisha_count = MsgAdapter.ReadShort()
		vo.dead_count = MsgAdapter.ReadShort()
		self.rank_list[i] = vo
	end
end


-- 挂机boss出生通知
SCGuajiBossBornNotice = SCGuajiBossBornNotice or BaseClass(BaseProtocolStruct)
function SCGuajiBossBornNotice:__init()
	self.msg_type = 2234
	self.boss_id = 0
	self.scene_id = 0
	self.pos_x = 0
	self.pos_y = 0
end

function SCGuajiBossBornNotice:Decode()
	self.boss_id = MsgAdapter.ReadInt()
	self.scene_id = MsgAdapter.ReadInt()
	self.pos_x = MsgAdapter.ReadInt()
	self.pos_y = MsgAdapter.ReadInt()
end

-- 随机活动比拼战力信息
SCRABipinCapabilityInfo = SCRABipinCapabilityInfo or BaseClass(BaseProtocolStruct)
function SCRABipinCapabilityInfo:__init()
	self.msg_type = 2235
	self.bipin_activity_type = 0
	self.capability = 0
	self.fetch_reward_flag = 0
	self.all_camp_top_user_info_list = {}
end

function SCRABipinCapabilityInfo:Decode()
	self.bipin_activity_type = MsgAdapter.ReadInt()
	self.capability = MsgAdapter.ReadInt()
	self.fetch_reward_flag = MsgAdapter.ReadInt()

	self.all_camp_top_user_info_list = {}		--三个阵营里排名第一的信息
	for i = 1, 3 do
		local vo = {}
		vo.uid = MsgAdapter.ReadInt()
		vo.name =  MsgAdapter.ReadStrN(32)
		vo.capability = MsgAdapter.ReadLL()
		vo.prof = MsgAdapter.ReadChar()
		MsgAdapter.ReadChar()
		MsgAdapter.ReadShort()
		vo.avatar_key_big = MsgAdapter.ReadInt()
		vo.avatar_key_small = MsgAdapter.ReadInt()
		self.all_camp_top_user_info_list[i] = vo
	end
end

-- 充值回馈
SCChargeRewardInfo = SCChargeRewardInfo or BaseClass(BaseProtocolStruct)
function SCChargeRewardInfo:__init()
	self.msg_type = 2236
	self.can_fetch_reward_flag = 0
	self.fetch_reward_flag = 0
	self.charge_value = 0
end

function SCChargeRewardInfo:Decode()
	self.can_fetch_reward_flag = MsgAdapter.ReadInt()
	self.fetch_reward_flag = MsgAdapter.ReadInt()
	self.charge_value = MsgAdapter.ReadInt()
end

-- 随机活动单笔充值
SCRADanbiChongzhiInfo = SCRADanbiChongzhiInfo or BaseClass(BaseProtocolStruct)
function SCRADanbiChongzhiInfo:__init()
	self.msg_type = 2241
	self.can_fetch_reward_flag = 0
	self.fetch_reward_flag = 0
end

function SCRADanbiChongzhiInfo:Decode()
	self.can_fetch_reward_flag = MsgAdapter.ReadInt()
	self.fetch_reward_flag = MsgAdapter.ReadInt()
end

-- 随机活动连续充值
SCRATotalChargeDayInfo = SCRATotalChargeDayInfo or BaseClass(BaseProtocolStruct)
function SCRATotalChargeDayInfo:__init()
	self.msg_type = 2242
	self.charge_day_count = 0
	self.fetch_reward_flag = 0
end

function SCRATotalChargeDayInfo:Decode()
	self.charge_day_count = MsgAdapter.ReadInt()
	self.fetch_reward_flag = MsgAdapter.ReadInt()
end

-- 随机活动-次日福利
SCRATomorrowRewardInfo = SCRATomorrowRewardInfo or BaseClass(BaseProtocolStruct)
function SCRATomorrowRewardInfo:__init()
	self.msg_type = 2243
	self.reword_count = 0
	self.reward_index = 0
end

function SCRATomorrowRewardInfo:Decode()
	self.reword_count = MsgAdapter.ReadInt()
	self.reward_index = MsgAdapter.ReadInt()
end

-- 随机活动-每日充值排行
SCRADayChongzhiRankInfo = SCRADayChongzhiRankInfo or BaseClass(BaseProtocolStruct)
function SCRADayChongzhiRankInfo:__init()
	self.msg_type = 2244
	self.gold_num = 0
end

function SCRADayChongzhiRankInfo:Decode()
	self.gold_num = MsgAdapter.ReadInt()
end

-- 随机活动-每日消费排行
SCRADayConsumeRankInfo = SCRADayConsumeRankInfo or BaseClass(BaseProtocolStruct)
function SCRADayConsumeRankInfo:__init()
	self.msg_type = 2245
	self.gold_num = 0
end

function SCRADayConsumeRankInfo:Decode()
	self.gold_num = MsgAdapter.ReadInt()
end

-- 随机活动-每日消费排行
SCRATotalChargeInfo = SCRATotalChargeInfo or BaseClass(BaseProtocolStruct)
function SCRATotalChargeInfo:__init()
	self.msg_type = 2246
	self.total_charge_value = 0								--累计充值数
	self.reward_has_fetch_flag = 0							--已领取过的奖励标记
end

function SCRATotalChargeInfo:Decode()
	self.total_charge_value = MsgAdapter.ReadInt()
	self.reward_has_fetch_flag = MsgAdapter.ReadInt()
end

-- 随机活动-装备兑换
SCRATimeLimitExchangeEquiInfo = SCRATimeLimitExchangeEquiInfo or BaseClass(BaseProtocolStruct)
function SCRATimeLimitExchangeEquiInfo:__init()
	self.msg_type = 2247
end

function SCRATimeLimitExchangeEquiInfo:Decode()
	self.time_list = {}
	for i = 0, GameEnum.TIME_LIMIT_EXCHANGE_ITEM_COUNT -1 do
		self.time_list[i] = MsgAdapter.ReadInt()
	end
end

-- 随机活动-精灵兑换
SCRATimeLimitExchangeJLInfo = SCRATimeLimitExchangeJLInfo or BaseClass(BaseProtocolStruct)
function SCRATimeLimitExchangeJLInfo:__init()
	self.msg_type = 2248
end

function SCRATimeLimitExchangeJLInfo:Decode()
	self.time_list = {}
	for i = 0, GameEnum.TIME_LIMIT_EXCHANGE_ITEM_COUNT -1 do
		self.time_list[i] = MsgAdapter.ReadInt()
	end
end

-- 大富豪箱子刷新时间
SCMillionaireTimeNotice = SCMillionaireTimeNotice or BaseClass(BaseProtocolStruct)
function SCMillionaireTimeNotice:__init()
	self.msg_type = 2249
end

function SCMillionaireTimeNotice:Decode()
	self.next_millionaire_box_refresh_time = MsgAdapter.ReadUInt()
	self.next_millionaire_boss_refresh_time = MsgAdapter.ReadUInt()
end

-- --趣味挖矿
-- CSRandActivityOperaReq = CSRandActivityOperaReq or BaseClass(BaseProtocolStruct)
-- function CSRandActivityOperaReq:__init()
-- 	self.msg_type = 2257
-- 	self.rand_activity_type = 0
-- 	self.opera_type = 0
-- 	self.param_1 = 0
-- 	self.param_2 = 0
-- end

-- function CSRandActivityOperaReq:Encode()
-- 	MsgAdapter.WriteBegin(self.msg_type)
-- 	MsgAdapter.WriteShort(self.rand_activity_type)
-- 	MsgAdapter.WriteShort(self.opera_type)
-- 	MsgAdapter.WriteInt(self.param_1)
-- 	MsgAdapter.WriteInt(self.param_2)
-- end

-- 一站到底购买属性加成
CSYiZhanDaoDiGuwu = CSYiZhanDaoDiGuwu or BaseClass(BaseProtocolStruct)
function CSYiZhanDaoDiGuwu:__init()
	self.msg_type = 2258
	self.guwu_type = 0
end

function CSYiZhanDaoDiGuwu:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.guwu_type)
end

----------------------------------随机活动-----------------------------------------
-----------------------------------------------------------------------------------
--—————————————————————————————————————————————————————————————————————————————————

--合服活动子活动状态
SCCSASubActivityState = SCCSASubActivityState or BaseClass(BaseProtocolStruct)
function SCCSASubActivityState:__init()
	self.msg_type = 2237
	self.sub_activity_state_list = {}
end

function SCCSASubActivityState:Decode()
	self.sub_activity_state_list = {}
	for i = 0, COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_MAX - 1 do
		self.sub_activity_state_list[i] = MsgAdapter.ReadChar()
	end
end

--合服活动信息
SCCSAActivityInfo = SCCSAActivityInfo or BaseClass(BaseProtocolStruct)
function SCCSAActivityInfo:__init()
	self.msg_type = 2238
	self.qianggou_buynum_list = {}
	self.rank_item_list = {}
	self.server_panic_buy_num_list = {}
end

function SCCSAActivityInfo:Decode()
	self.qianggou_buynum_list = {}
	for i = 1, GameEnum.COMBINE_SERVER_RANK_QIANGOU_ITEM_MAX_TYPE do
		self.qianggou_buynum_list[i] = MsgAdapter.ReadInt()
	end
	self.csa_xmz_winner_roleid = MsgAdapter.ReadInt()
	self.csa_gcz_winner_roleid = MsgAdapter.ReadInt()

	self.rank_item_list = {}
	for i = 0, GameEnum.CSA_RANK_TYPE_MAX - 1 do
		local rank_item = {}
		rank_item.is_finish = MsgAdapter.ReadChar()
		MsgAdapter.ReadChar()
		MsgAdapter.ReadShort()
		rank_item.user_list = {}
		for j = 1, GameEnum.COMBINE_SERVER_ACTIVITY_RANK_REWARD_ROLE_NUM do
			local user = {}
			user.role_id = MsgAdapter.ReadInt()
			user.rank_value = MsgAdapter.ReadLL()
			user.rank_reserved = MsgAdapter.ReadLL()
			user.user_name = MsgAdapter.ReadStrN(32)
			user.camp = MsgAdapter.ReadChar()
			user.prof = MsgAdapter.ReadChar()
			user.sex = MsgAdapter.ReadChar()
			user.reserve_ch = MsgAdapter.ReadChar()
--			user.reserve_sh = MsgAdapter.ReadChar()
			user.avatar = MsgAdapter.ReadLL()
			rank_item.user_list[j] = user
		end
		self.rank_item_list[i] = rank_item
	end

	self.server_panic_buy_num_list = {}
	for i = 1, GameEnum.COMBINE_SERVER_SERVER_PANIC_BUY_ITEM_MAX_COUNT do
		self.server_panic_buy_num_list[i] = MsgAdapter.ReadInt()
	end

end

--合服活动角色信息
SCCSARoleInfo = SCCSARoleInfo or BaseClass(BaseProtocolStruct)
function SCCSARoleInfo:__init()
	self.msg_type = 2239

	self.rank_qianggou_buynum_list = {}
	self.roll_chongzhi_num = 0
	self.chongzhi_rank_chongzhi_num = 0
	self.consume_rank_consume_gold = 0
	self.kill_boss_kill_count = 0
	self.personal_panic_buy_numlist = {}
	self.server_panic_buy_numlist = {}
	self.login_days = 0
	self.has_fetch_accumulate_reward = 0
	self.fetch_common_reward_flag = 0
	self.fetch_vip_reward_flag = 0
	self.roll_total_chongzhi_num = 0
end

function SCCSARoleInfo:Decode()
	self.rank_qianggou_buynum_list = {}
	for i = 1, GameEnum.COMBINE_SERVER_RANK_QIANGOU_ITEM_MAX_TYPE do
		self.rank_qianggou_buynum_list[i] = MsgAdapter.ReadInt()
	end
	self.roll_chongzhi_num = MsgAdapter.ReadInt()
	self.chongzhi_rank_chongzhi_num = MsgAdapter.ReadInt()
	self.consume_rank_consume_gold = MsgAdapter.ReadInt()
	self.kill_boss_kill_count = MsgAdapter.ReadInt()

	self.personal_panic_buy_numlist = {}
	for i = 1, GameEnum.COMBINE_SERVER_PERSONAL_PANIC_BUY_ITEM_MAX_COUNT do
		self.personal_panic_buy_numlist[i] = MsgAdapter.ReadInt()
	end
	self.server_panic_buy_numlist = {}
	for i = 1, GameEnum.COMBINE_SERVER_SERVER_PANIC_BUY_ITEM_MAX_COUNT do
		self.server_panic_buy_numlist[i] = MsgAdapter.ReadInt()
	end

	self.login_days = MsgAdapter.ReadShort()
	MsgAdapter.ReadChar()
	self.has_fetch_accumulate_reward = MsgAdapter.ReadChar()
	self.fetch_common_reward_flag = MsgAdapter.ReadInt()
	self.fetch_vip_reward_flag = MsgAdapter.ReadInt()
	self.roll_total_chongzhi_num = MsgAdapter.ReadInt()
end

--合服活动转盘转动结果
SCCSARollResult = SCCSARollResult or BaseClass(BaseProtocolStruct)
function SCCSARollResult:__init()
	self.msg_type = 2240
	self.ret_seq = 0
end

function SCCSARollResult:Decode()
	self.ret_seq = MsgAdapter.ReadInt()
end

--合服活动角色操作请求
CSCSARoleOperaReq = CSCSARoleOperaReq or BaseClass(BaseProtocolStruct)
function CSCSARoleOperaReq:__init()
	self.msg_type = 2263
	self.sub_type = 0
	self.param_1 = 0
	self.param_2 = 0
	self.reserve_sh = 0
end

function CSCSARoleOperaReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.sub_type)
	MsgAdapter.WriteShort(self.param_1)
	MsgAdapter.WriteShort(self.param_2)
	MsgAdapter.WriteShort(self.reserve_sh)
end

--合服Boss信息
SCCSABossInfo = SCCSABossInfo or BaseClass(BaseProtocolStruct)
function SCCSABossInfo:__init()
	self.msg_type = 2276
	self.refresh_state = 0
	self.acquisitions_num = 0
end

function SCCSABossInfo:Decode()
	self.boss_info = {}
	for i = 1, GameEnum.COMBINE_SERVER_BOSS_MAX_COUNT do
		local data = {}
		data.boss_id = MsgAdapter.ReadUShort()
		data.boss_type = MsgAdapter.ReadShort()
		data.next_refresh_time = MsgAdapter.ReadUInt()
		self.boss_info[i] = data
	end
	self.refresh_state = MsgAdapter.ReadShort()
	self.acquisitions_num = MsgAdapter.ReadShort()

end

--合服Boss排行榜
SCCSABossRankInfo = SCCSABossRankInfo or BaseClass(BaseProtocolStruct)
function SCCSABossRankInfo:__init()
	self.msg_type = 2277
end

function SCCSABossRankInfo:Decode()
	self.personal_rank = {}
	self.guild_rank = {}
	for i = 1, GameEnum.COMBINE_SERVER_BOSS_RANK_NUM do
		local data = {}
		data.id = MsgAdapter.ReadInt()
		data.rank_value = MsgAdapter.ReadInt()
		data.name = MsgAdapter.ReadStrN(32)
		self.personal_rank[i] = data
	end
	for i = 1, GameEnum.COMBINE_SERVER_BOSS_RANK_NUM do
		local data = {}
		data.id = MsgAdapter.ReadInt()
		data.rank_value = MsgAdapter.ReadInt()
		data.name = MsgAdapter.ReadStrN(32)
		self.guild_rank[i] = data
	end
end

--合服Boss击杀数
SCCSABossRoleInfo = SCCSABossRoleInfo or BaseClass(BaseProtocolStruct)
function SCCSABossRoleInfo:__init()
	self.msg_type = 2278
	self.kill_boss_num = 0
	self.guild_killl_boss_num = 0
end

function SCCSABossRoleInfo:Decode()
	self.kill_boss_num = MsgAdapter.ReadShort()
	self.guild_killl_boss_num = MsgAdapter.ReadShort()
end
----------------------------------合服活动-----------------------------------------
-----------------------------------------------------------------------------------
--—————————————————————————————————————————————————————————————————————————————————

-- 随机活动请求
CSRandActivityOperaReq = CSRandActivityOperaReq or BaseClass(BaseProtocolStruct)
function CSRandActivityOperaReq:__init()
	self.msg_type = 2257

	self.rand_activity_type = 0
	self.opera_type = 0
	self.param_1 = 0
	self.param_2 = 0
end

function CSRandActivityOperaReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.rand_activity_type)
	MsgAdapter.WriteShort(self.opera_type)
	MsgAdapter.WriteInt(self.param_1)
	MsgAdapter.WriteInt(self.param_2)
end

----------------------------------女神协议-----------------------------------------
-----------------------------------------------------------------------------------
--—————————————————————————————————————————————————————————————————————————————————

local function LoadXiannvItem()
	local t = {}
	t.xn_level = MsgAdapter.ReadShort()
	t.xn_zizhi = MsgAdapter.ReadShort()
	return t
end

-- 指定仙女信息2200
SCXiannvInfo = SCXiannvInfo or BaseClass(BaseProtocolStruct)
function SCXiannvInfo:__init()
	self.msg_type = 2200
end

function SCXiannvInfo:Decode()
	self.notify_reaon = MsgAdapter.ReadShort()
	self.xiannv_id = MsgAdapter.ReadShort()
	self.xn_item = LoadXiannvItem()
end


--仙女所有信息2201
SCAllXiannvInfo = SCAllXiannvInfo or BaseClass(BaseProtocolStruct)
function SCAllXiannvInfo:__init()
	self.msg_type = 2201
	self.xn_item_list = {}
	self.pos_list = {}
	self.xiannv_huanhua_level = {}
	self.xiannv_name = {}
	self.shengwu_lingye = 0 			--圣物灵液
	self.shengwu_chou_id = -1  			--未领取的抽奖exp所属圣物id
	self.shengwu_chou_exp = {}  			--未领取的抽奖exp奖励
	self.shengwu_list = {}
	self.grid_level_list = {}
	self.miling_list = {}
	self.day_free_miling_times = 0
	self.day_fetch_ling_time = 0
	self.cur_gold_miling_times = 0
end

function SCAllXiannvInfo:Decode()
	self.active_xiannv_flag = MsgAdapter.ReadShort()
	self.huanhua_id = MsgAdapter.ReadShort()
	self.active_huanhua_flag = MsgAdapter.ReadLL()
	for i = 0, 6 do
		self.xiannv_name[i] = MsgAdapter.ReadStrN(32)
	end
	for i = 0, 63 do
		self.xiannv_huanhua_level[i] = MsgAdapter.ReadInt()
	end
	for i = 0, 6 do
		self.xn_item_list[i] = LoadXiannvItem()
	end
	for i = 1, 4 do
		self.pos_list[i] = MsgAdapter.ReadChar()
	end

	self.shengwu_lingye = MsgAdapter.ReadInt()
	self.cur_gold_miling_times = MsgAdapter.ReadShort()

	self.shengwu_chou_id = MsgAdapter.ReadShort()
	self.shengwu_chou_exp = {}
	for i = 0, XIANNV_SHENGWU_CHOU_EXP_COUNT - 1 do
		self.shengwu_chou_exp[i] = MsgAdapter.ReadShort()
	end

	self.shengwu_list = {}
	local sw_cfg = {}
	for i = 0, XIANNV_SHENGWU_MAX_ID do
		sw_cfg = {}
		sw_cfg.level = MsgAdapter.ReadShort()
		MsgAdapter.ReadShort()
		sw_cfg.exp = MsgAdapter.ReadInt()
		self.shengwu_list[i] = sw_cfg
	end

	self.grid_level_list = {}
	for i = 0, XIANNV_SHENGWU_GONGMING_MAX_GRID_ID do
		self.grid_level_list[i] = MsgAdapter.ReadShort()
	end

	self.day_free_miling_times = MsgAdapter.ReadChar()
    self.day_fetch_ling_time = MsgAdapter.ReadChar()

    self.miling_list = {}
	for i = 0, XIANNV_SHENGWU_MILING_TYPE_COUNT - 1 do
		self.miling_list[i] = MsgAdapter.ReadChar()
	end
	self.active_special_xiannv_flag = MsgAdapter.ReadShort()		              --激活特殊伙伴
	self.active_special_xiannv_time_stamp = MsgAdapter.ReadUInt() 	              --时间戳	
	self.special_xiannv_level = MsgAdapter.ReadShort()                            --等级
	self.is_new_player_active_special_xiannv = MsgAdapter.ReadChar()              --是否是新玩家
	self.can_get_special_xiannv_active_card = MsgAdapter.ReadChar()               --能否领取特殊伙伴
	self.has_got_speical_xiannv_active_card = MsgAdapter.ReadChar()               --是否已领取特殊伙伴
	self.active_xiannv_small_target_flag = MsgAdapter.ReadChar()                  --伙伴小目标激活
	self.can_get_xiannv_small_target_litle_card = MsgAdapter.ReadChar()           --能否领取伙伴小目标称号卡
	self.has_got_xiannv_small_target_title_card = MsgAdapter.ReadChar()           --是否领取伙伴小目标称号卡
end

--仙女形象改变广播2203
SCXiannvViewChange = SCXiannvViewChange or BaseClass(BaseProtocolStruct)
function SCXiannvViewChange:__init()
	self.msg_type = 2203
	self.obj_id = 0
	self.use_xiannv_id = 0
	self.huanhua_id = 0
	self.reserved = 0
	self.xiannv_name = ""
end

function SCXiannvViewChange:Decode()
	self.obj_id = MsgAdapter.ReadUShort()
	self.use_xiannv_id = MsgAdapter.ReadShort()
	self.huanhua_id = MsgAdapter.ReadShort()
	self.reserved = MsgAdapter.ReadShort()
	self.xiannv_name = MsgAdapter.ReadStrN(32)
end

--请求仙女出战2250
CSXiannvCall = CSXiannvCall or BaseClass(BaseProtocolStruct)
function CSXiannvCall:__init()
	self.msg_type = 2250
end

function CSXiannvCall:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	for i, v in ipairs(self.pos_list) do
		MsgAdapter.WriteChar(v)
	end
end

--请求重命名2251
CSXiannvRename = CSXiannvRename or BaseClass(BaseProtocolStruct)
function CSXiannvRename:__init()
	self.msg_type = 2251
	self.xiannv_id = 0
	self.new_name = {}
end

function CSXiannvRename:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.xiannv_id)
	MsgAdapter.WriteStrN(self.new_name,32)
end

--请求激活2252
CSXiannvActiveReq = CSXiannvActiveReq or BaseClass(BaseProtocolStruct)
function CSXiannvActiveReq:__init()
	self.msg_type = 2252
	self.xiannv_id = 0
	self.item_index = 0
end

function CSXiannvActiveReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.xiannv_id)
	MsgAdapter.WriteShort(self.item_index)
end

--请求加资质2253
CSXiannvAddZizhiReq = CSXiannvAddZizhiReq or BaseClass(BaseProtocolStruct)
function CSXiannvAddZizhiReq:__init()
	self.msg_type = 2253
	self.xiannv_id = 0
	self.auto_buy = 0
end

function CSXiannvAddZizhiReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.xiannv_id)
	MsgAdapter.WriteShort(self.auto_buy)
end

--请求加升级2254
CSXiannvUpLevelReq = CSXiannvUpLevelReq or BaseClass(BaseProtocolStruct)
function CSXiannvUpLevelReq:__init()
	self.msg_type = 2254
	self.xiannv_id = 0
	self.auto_buy = 0
end

function CSXiannvUpLevelReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.xiannv_id)
	MsgAdapter.WriteShort(self.auto_buy)
end

--请求激活幻化
CSXiannvActiveHuanhua = CSXiannvActiveHuanhua or BaseClass(BaseProtocolStruct)
function CSXiannvActiveHuanhua:__init()
	self.msg_type = 2265
	self.xiannv_id = 0
end

function CSXiannvActiveHuanhua:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.xiannv_id)
	MsgAdapter.WriteShort(self.item_index)
end

--请求形象
CSXiannvImageReq = CSXiannvImageReq or BaseClass(BaseProtocolStruct)
function CSXiannvImageReq:__init()
	self.msg_type = 2266
	self.huanhua_id = 0
end

function CSXiannvImageReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.huanhua_id)
end

--请求幻化升级
CSXiannvHuanHuaUpLevelReq = CSXiannvHuanHuaUpLevelReq or BaseClass(BaseProtocolStruct)
function CSXiannvHuanHuaUpLevelReq:__init()
	self.msg_type = 2267
	self.huanhua_id = 0
	self.auto_buy = 0
end

function CSXiannvHuanHuaUpLevelReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.huanhua_id)
	MsgAdapter.WriteShort(self.auto_buy)
end

-- 大富豪使用冰冻技能
CSMillionaireUseFrozenSkill = CSMillionaireUseFrozenSkill or BaseClass(BaseProtocolStruct)
function CSMillionaireUseFrozenSkill:__init()
	self.msg_type = 2269
	self.target_obj_id = 0
	self.reserver = 0
end

function CSMillionaireUseFrozenSkill:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteUShort(self.target_obj_id)
	MsgAdapter.WriteShort(self.reserver)
end

-- 2270 女神圣器请求协议
CSXiannvShengwuReq = CSXiannvShengwuReq or BaseClass(BaseProtocolStruct)
function CSXiannvShengwuReq:__init()
	self.msg_type = 2270
	self.req_type = 0
	self.param1 = 0
	self.param2 = 0
	self.param3 = 0
	-- enum ReqType
	-- 	{
	-- 		CHOU_EXP = 0,								// 抽取经验，param1 类型（0普通抽取，1完美抽取），param2 是否自动选择碎片， param3 是否10连抽
	-- 		FETCH_EXP,									// 领取经验
	-- 		UPGRADE_GRID,								// 提升共鸣格子，param1 格子ID
	-- 		CHOU_LING,									// 灵液抽取
	-- 		FETCH_LING,									// 灵液领取，param1 是否双倍领取（0 否，1 是）
	-- 	};
end

function CSXiannvShengwuReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)

	MsgAdapter.WriteShort(self.req_type)
	MsgAdapter.WriteShort(self.param1)
	MsgAdapter.WriteShort(self.param2)
	MsgAdapter.WriteShort(self.param3)
end

--女神圣物变化增量信息
SCXiannvShengwuChangeInfo = SCXiannvShengwuChangeInfo or BaseClass(BaseProtocolStruct)
function SCXiannvShengwuChangeInfo:__init()
	self.msg_type = 2271
	self.notify_type = 0
	self.param1 = 0
	self.param2 = 0
	self.param3 = 0
	self.param4 = 0

	-- enum NotifyType
	-- 	{
	-- 		UNFETCH_EXP = 0,							// param1 今日已使用免费引灵次数, param2 今日已使用元宝引灵次数，param3 今日已领取灵液次数，param4 剩余灵液
	-- 		SHENGWU_INFO,								// 圣物信息，param1 圣物ID，param2 圣物等级，param3 NULL，param4 圣物经验值
	-- 		GRID_INFO,									// 格子信息，param1 格子ID，param2 格子等级
	-- 	};
end

function SCXiannvShengwuChangeInfo:Decode()
	self.notify_type = MsgAdapter.ReadShort()
	self.param1 = MsgAdapter.ReadShort()
	self.param2 = MsgAdapter.ReadShort()
	self.param3 = MsgAdapter.ReadShort()
	self.param4 = MsgAdapter.ReadInt()
end

-- 女神圣物觅灵列表
SCXiannvShengwuMilingList = SCXiannvShengwuMilingList or BaseClass(BaseProtocolStruct)
function SCXiannvShengwuMilingList:__init()
	self.msg_type = 2272
	self.miling_list = {}
end

function SCXiannvShengwuMilingList:Decode()
	self.miling_list = {}
	for i = 0, XIANNV_SHENGWU_MILING_TYPE_COUNT - 1 do
		self.miling_list[i] = MsgAdapter.ReadChar()
	end
	self.reserve_sh = MsgAdapter.ReadShort()
end

-- 女神圣物回忆获取的经验列表
SCXiannvShengwuChouExpList = SCXiannvShengwuChouExpList or BaseClass(BaseProtocolStruct)
function SCXiannvShengwuChouExpList:__init()
	self.msg_type = 2273
	self.shengwu_chou_type = 0
	self.shengwu_chou_id = 0
	self.chou_list = {}
end

function SCXiannvShengwuChouExpList:Decode()
	self.chou_list = {}
	self.shengwu_chou_type = MsgAdapter.ReadChar()
	MsgAdapter.ReadChar()
	self.shengwu_chou_id = MsgAdapter.ReadShort()
	for i = 0, XIANNV_SHENGWU_CHOU_EXP_COUNT - 1 do
		self.chou_list[i] = MsgAdapter.ReadShort()
	end
end

-- 女神圣物抽经验结果
SCXiannvShengwuChouExpResult = SCXiannvShengwuChouExpResult or BaseClass(BaseProtocolStruct)
function SCXiannvShengwuChouExpResult:__init()
	self.msg_type = 2274
	self.is_auto_fetch = 0
	self.cur_type = 0
	self.add_exp_count = 0
	self.add_exp_list = {}
end

function SCXiannvShengwuChouExpResult:Decode()
	self.is_auto_fetch = MsgAdapter.ReadShort()
	self.add_exp_count = MsgAdapter.ReadShort()
	self.add_exp_list = {}
	local one_add_exp = {}
	for i = 0, self.add_exp_count - 1 do
		one_add_exp = {}
		one_add_exp.shengwu_id = MsgAdapter.ReadShort()
		one_add_exp.add_exp = MsgAdapter.ReadShort()
		self.add_exp_list[i] = one_add_exp
	end
end

--请求购买激活特殊伙伴形象
CSSpecialXiannvOperaReq = CSSpecialXiannvOperaReq or BaseClass(BaseProtocolStruct)
function CSSpecialXiannvOperaReq:__init()
	self.msg_type = 2289
	self.opera_type = 0
	self.special_xiannv_id = 0
	self.param = 0
end

function CSSpecialXiannvOperaReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.opera_type)
	MsgAdapter.WriteShort(self.special_xiannv_id)
	MsgAdapter.WriteInt(self.param)
end

--请求购买称号
CSXiannvSmallTargetOperaReq = CSXiannvSmallTargetOperaReq or BaseClass(BaseProtocolStruct)
function CSXiannvSmallTargetOperaReq:__init()
	self.msg_type = 2290
	self.opera_type = 0
end

function CSXiannvSmallTargetOperaReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.opera_type)
end


SCYiZhanDaoDiLastFirstInfo = SCYiZhanDaoDiLastFirstInfo or BaseClass(BaseProtocolStruct)
function SCYiZhanDaoDiLastFirstInfo:__init()
	self.msg_type = 2275
end

function SCYiZhanDaoDiLastFirstInfo:Decode()
	self.uid = MsgAdapter.ReadInt()
	self.game_name = MsgAdapter.ReadStrN(32)
end

SCRANewTotalChargeInfo = SCRANewTotalChargeInfo or BaseClass(BaseProtocolStruct)
function SCRANewTotalChargeInfo:__init()
	self.msg_type = 2262
end

function SCRANewTotalChargeInfo:Decode()
	self.total_charge_value = MsgAdapter.ReadInt()
	self.reward_has_fetch_flag = MsgAdapter.ReadInt()
end

--进阶返利-腰饰
SCRAYaoShiUpgradeInfo = SCRAYaoShiUpgradeInfo or BaseClass(BaseProtocolStruct)
function SCRAYaoShiUpgradeInfo:__init()
	self.msg_type = 2279

	self.grade = 0
	self.can_fetch_reward_flag = 0
	self.fetch_reward_flag = 0
	self.rare_reward_fetch_flag = 0
end

function SCRAYaoShiUpgradeInfo:Decode()
	self.grade = MsgAdapter.ReadInt()
	self.can_fetch_reward_flag = MsgAdapter.ReadShort()
	self.fetch_reward_flag = MsgAdapter.ReadShort()
	self.rare_reward_fetch_flag = MsgAdapter.ReadInt()
end

--进阶返利-头饰
SCRATouShiUpgradeInfo = SCRATouShiUpgradeInfo or BaseClass(BaseProtocolStruct)
function SCRATouShiUpgradeInfo:__init()
	self.msg_type = 2280

	self.grade = 0
	self.can_fetch_reward_flag = 0
	self.fetch_reward_flag = 0
	self.rare_reward_fetch_flag = 0
end

function SCRATouShiUpgradeInfo:Decode()
	self.grade = MsgAdapter.ReadInt()
	self.can_fetch_reward_flag = MsgAdapter.ReadShort()
	self.fetch_reward_flag = MsgAdapter.ReadShort()
	self.rare_reward_fetch_flag = MsgAdapter.ReadInt()
end

--进阶返利-麒麟臂
SCRAQiLinBiUpgradeInfo = SCRAQiLinBiUpgradeInfo or BaseClass(BaseProtocolStruct)
function SCRAQiLinBiUpgradeInfo:__init()
	self.msg_type = 2281

	self.grade = 0
	self.can_fetch_reward_flag = 0
	self.fetch_reward_flag = 0
	self.rare_reward_fetch_flag = 0
end

function SCRAQiLinBiUpgradeInfo:Decode()
	self.grade = MsgAdapter.ReadInt()
	self.can_fetch_reward_flag = MsgAdapter.ReadShort()
	self.fetch_reward_flag = MsgAdapter.ReadShort()
	self.rare_reward_fetch_flag = MsgAdapter.ReadInt()
end

--进阶返利-面具
SCRAMaskUpgradeInfo = SCRAMaskUpgradeInfo or BaseClass(BaseProtocolStruct)
function SCRAMaskUpgradeInfo:__init()
	self.msg_type = 2282

	self.grade = 0
	self.can_fetch_reward_flag = 0
	self.fetch_reward_flag = 0
	self.rare_reward_fetch_flag = 0
end

function SCRAMaskUpgradeInfo:Decode()
	self.grade = MsgAdapter.ReadInt()
	self.can_fetch_reward_flag = MsgAdapter.ReadShort()
	self.fetch_reward_flag = MsgAdapter.ReadShort()
	self.rare_reward_fetch_flag = MsgAdapter.ReadInt()
end

--进阶返利-仙宝
SCRAXianBaoUpgradeInfo = SCRAXianBaoUpgradeInfo or BaseClass(BaseProtocolStruct)
function SCRAXianBaoUpgradeInfo:__init()
	self.msg_type = 2283

	self.grade = 0
	self.can_fetch_reward_flag = 0
	self.fetch_reward_flag = 0
	self.rare_reward_fetch_flag = 0
end

function SCRAXianBaoUpgradeInfo:Decode()
	self.grade = MsgAdapter.ReadInt()
	self.can_fetch_reward_flag = MsgAdapter.ReadShort()
	self.fetch_reward_flag = MsgAdapter.ReadShort()
	self.rare_reward_fetch_flag = MsgAdapter.ReadInt()
end

--进阶返利-灵珠
SCRALingZhuUpgradeInfo = SCRALingZhuUpgradeInfo or BaseClass(BaseProtocolStruct)
function SCRALingZhuUpgradeInfo:__init()
	self.msg_type = 2284

	self.grade = 0
	self.can_fetch_reward_flag = 0
	self.fetch_reward_flag = 0
	self.rare_reward_fetch_flag = 0
end

function SCRALingZhuUpgradeInfo:Decode()
	self.grade = MsgAdapter.ReadInt()
	self.can_fetch_reward_flag = MsgAdapter.ReadShort()
	self.fetch_reward_flag = MsgAdapter.ReadShort()
	self.rare_reward_fetch_flag = MsgAdapter.ReadInt()
end

-- 登录有礼
SCRALoginGiftInfo = SCRALoginGiftInfo or BaseClass(BaseProtocolStruct)
function SCRALoginGiftInfo:__init()
	self.msg_type = 2285

	self.login_days = 0
	self.has_login = 0
	self.has_fetch_accumulate_reward = 0
	self.fetch_common_reward_flag = 0
	self.fetch_vip_reward_flag = 0
end

function SCRALoginGiftInfo:Decode()
	self.login_days = MsgAdapter.ReadShort() 					-- 连续登陆天数
	self.has_login = MsgAdapter.ReadChar() 						-- 最后登录的dayid
	self.has_fetch_accumulate_reward = MsgAdapter.ReadChar() 	-- 是否领取累计充值
	self.fetch_common_reward_flag = MsgAdapter.ReadInt() 		-- 普通奖励领取标识
	self.fetch_vip_reward_flag = MsgAdapter.ReadInt() 			-- vip奖励领取标识
end

-- 登录有礼
SCRALoginGiftInfo_1 = SCRALoginGiftInfo_1 or BaseClass(BaseProtocolStruct)
function SCRALoginGiftInfo_1:__init()
	self.msg_type = 2286

	self.login_days = 0
	self.has_login = 0
	self.has_fetch_accumulate_reward = 0
	self.fetch_common_reward_flag = 0
	self.fetch_vip_reward_flag = 0
end

function SCRALoginGiftInfo_1:Decode()
	self.login_days = MsgAdapter.ReadShort()
	self.has_login = MsgAdapter.ReadChar()
	self.has_fetch_accumulate_reward = MsgAdapter.ReadChar()
	self.fetch_common_reward_flag = MsgAdapter.ReadInt()
	self.fetch_vip_reward_flag = MsgAdapter.ReadInt()
end

-- 登录有礼
SCRALoginGiftInfo_2 = SCRALoginGiftInfo_2 or BaseClass(BaseProtocolStruct)
function SCRALoginGiftInfo_2:__init()
	self.msg_type = 2287

	self.login_days = 0
	self.has_login = 0
	self.has_fetch_accumulate_reward = 0
	self.fetch_common_reward_flag = 0
	self.fetch_vip_reward_flag = 0
end

function SCRALoginGiftInfo_2:Decode()
	self.login_days = MsgAdapter.ReadShort()
	self.has_login = MsgAdapter.ReadChar()
	self.has_fetch_accumulate_reward = MsgAdapter.ReadChar()
	self.fetch_common_reward_flag = MsgAdapter.ReadInt()
	self.fetch_vip_reward_flag = MsgAdapter.ReadInt()
end