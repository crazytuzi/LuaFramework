-- 完成并掉落
CSFbGuideFinish = CSFbGuideFinish or BaseClass(BaseProtocolStruct)
function CSFbGuideFinish:__init()
	self.msg_type = 8400
end

function CSFbGuideFinish:Encode()
	MsgAdapter.WriteBegin(self.msg_type)

	MsgAdapter.WriteInt(self.pos_x)
	MsgAdapter.WriteInt(self.pos_y)
	MsgAdapter.WriteInt(0)
end

-- 创建采集物
CSFbGuideCreateGather = CSFbGuideCreateGather or BaseClass(BaseProtocolStruct)
function CSFbGuideCreateGather:__init()
	self.msg_type = 8401
end

function CSFbGuideCreateGather:Encode()
	MsgAdapter.WriteBegin(self.msg_type)

	MsgAdapter.WriteInt(self.pos_x)
	MsgAdapter.WriteInt(self.pos_y)
	MsgAdapter.WriteInt(self.gather_id)
	MsgAdapter.WriteInt(self.gather_time)
end

-- 我们结婚吧
SCRAMarryMeAllInfo = SCRAMarryMeAllInfo or BaseClass(BaseProtocolStruct)

function SCRAMarryMeAllInfo:__init()
	self.msg_type = 8416
end

function SCRAMarryMeAllInfo:Decode()
	self.cur_couple_count = MsgAdapter.ReadInt()
	self.couple_list = {}
	local count = math.min(self.cur_couple_count, GameEnum.RA_MARRY_SHOW_COUPLE_COUNT_MAX)
	for i = 1, count do
		self.couple_list[i] = {}
		self.couple_list[i].propose_id = MsgAdapter.ReadInt()						-- 求婚者id
		self.couple_list[i].propose_name = MsgAdapter.ReadStrN(32)					-- 求婚者名字
		self.couple_list[i].accept_proposal_id = MsgAdapter.ReadInt()				-- 被求婚者id
		self.couple_list[i].accept_proposal_name = MsgAdapter.ReadStrN(32)			-- 被求婚者名字
		self.couple_list[i].proposer_sex = MsgAdapter.ReadChar()					-- 求婚者性别
		self.couple_list[i].accept_proposal_sex = MsgAdapter.ReadChar()				-- 被求婚者性别
		self.couple_list[i].reserve_sh = MsgAdapter.ReadShort()
	end
end

SCOpenServerInvestInfo = SCOpenServerInvestInfo or BaseClass(BaseProtocolStruct)

function SCOpenServerInvestInfo:__init()
	self.msg_type = 8417
end

function SCOpenServerInvestInfo:Decode()
	self.reward_flag = MsgAdapter.ReadInt()
	self.time_limit = {}
	self.finish_param = {}
	for i=1,3 do
		self.time_limit[i] = MsgAdapter.ReadUInt()
	end
	for i=1,3 do
		self.finish_param[i] = MsgAdapter.ReadChar()
	end
	self.reserve_ch = MsgAdapter.ReadChar()
end

-- 开服红包
SCRARedEnvelopeGiftInfo = SCRARedEnvelopeGiftInfo or BaseClass(BaseProtocolStruct)
function SCRARedEnvelopeGiftInfo:__init()
	self.msg_type = 8410

	self.consume_gold_num = 0
	self.reward_flag = 0
end

function SCRARedEnvelopeGiftInfo:Decode()
	self.consume_gold_num_list = {}
	for i = 1 , 7 do
		self.consume_gold_num_list[i] = MsgAdapter.ReadInt()
	end
	self.reward_flag = MsgAdapter.ReadInt()
end


-- 开服七天充值18元档次
CSChongZhi7DayFetchReward = CSChongZhi7DayFetchReward or BaseClass(BaseProtocolStruct)
function CSChongZhi7DayFetchReward:__init()
	self.msg_type = 8420
end

function CSChongZhi7DayFetchReward:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

-- 神格操作请求
CSShengeSystemReq = CSShengeSystemReq or BaseClass(BaseProtocolStruct)
function CSShengeSystemReq:__init()
	self.msg_type = 8421
	self.info_type = 0
	self.param1 = 0
	self.param2 = 0
	self.param3 = 0
	self.param4 = 0

	self.count = 0
	self.virtual_inde_list = {}
	self.select_slot_list = {}
end

function CSShengeSystemReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.info_type)
	MsgAdapter.WriteShort(self.param1)
	MsgAdapter.WriteShort(self.param2)
	MsgAdapter.WriteShort(self.param3)
	MsgAdapter.WriteUInt(self.param4)

	MsgAdapter.WriteInt(self.count)
	for i = 1, self.count do
		MsgAdapter.WriteInt(self.virtual_inde_list[i])
	end
end

-- 神格信息
SCShengeSystemBagInfo = SCShengeSystemBagInfo or BaseClass(BaseProtocolStruct)
function SCShengeSystemBagInfo:__init()
	self.msg_type = 8422
end

function SCShengeSystemBagInfo:Decode()
	self.info_type = MsgAdapter.ReadChar()
	self.param1 = MsgAdapter.ReadChar()
	self.count = MsgAdapter.ReadShort()
	self.param3 = MsgAdapter.ReadUInt()

	self.bag_list = {}
	for i = 0, self.count - 1 do
		local vo = {}
		vo.quality = MsgAdapter.ReadChar()
		vo.type = MsgAdapter.ReadChar()
		vo.level = MsgAdapter.ReadUChar()
		vo.index = MsgAdapter.ReadUChar()
		self.bag_list[i] = vo
	end
end




--神格掌控
SCShengeZhangkongInfo = SCShengeZhangkongInfo or BaseClass(BaseProtocolStruct)
function SCShengeZhangkongInfo:__init()
	self.msg_type = 8423
end

function SCShengeZhangkongInfo:Decode()
	self.zhangkong_list = {}
	for i = 0, 3 do
		local zk = {}
		zk.level =  MsgAdapter.ReadInt()
		zk.exp = MsgAdapter.ReadInt()
		self.zhangkong_list[i] = zk
	end
end

SCZhangkongSingleChange = SCZhangkongSingleChange or BaseClass(BaseProtocolStruct)
function SCZhangkongSingleChange:__init()
	self.msg_type = 8424
end

function SCZhangkongSingleChange:Decode()
	self.grid = MsgAdapter.ReadInt()
	self.level = MsgAdapter.ReadInt()
	self.exp = MsgAdapter.ReadInt()
	self.add_exp = MsgAdapter.ReadInt()
end

--元宝转盘
CSYuanBaoZhuanpanInFo = CSYuanBaoZhuanpanInFo or BaseClass(BaseProtocolStruct)
function CSYuanBaoZhuanpanInFo:__init()
	self.msg_type = 8425
end

function CSYuanBaoZhuanpanInFo:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.operate_type)
end

--元宝转盘奖品信息
SCYuanBaoZhuanpanSenditem = SCYuanBaoZhuanpanSenditem or BaseClass(BaseProtocolStruct)
function SCYuanBaoZhuanpanSenditem:__init()
	self.msg_type = 8426
end

function SCYuanBaoZhuanpanSenditem:Decode()
	self.index = MsgAdapter.ReadInt() 			--奖励索引
end

--元宝奖池砖石数
SCYuanBaoZhuanPanInfo = SCYuanBaoZhuanPanInfo or BaseClass(BaseProtocolStruct)
function SCYuanBaoZhuanPanInfo:__init()
	self.msg_type = 8427
end

function SCYuanBaoZhuanPanInfo:Decode()
	self.zhuanshinum = MsgAdapter.ReadLL() 		--奖池砖石数刷新时CS发协议
	self.chou_jiang_times = MsgAdapter.ReadInt()
end

-- 金猪召唤请求协议
CSGoldenPigOperateReq = CSGoldenPigOperateReq or BaseClass(BaseProtocolStruct)
function CSGoldenPigOperateReq:__init()
	self.msg_type = 8428
	self.operate_type = 0
	self.param = 0
end

function CSGoldenPigOperateReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.operate_type)
	MsgAdapter.WriteShort(self.param)
end

--金猪召唤积分信息
SCGoldenPigOperateInfo = SCGoldenPigOperateInfo or BaseClass(BaseProtocolStruct)
function SCGoldenPigOperateInfo:__init()
	self.msg_type = 8429
end

function SCGoldenPigOperateInfo:Decode()
	self.summon_credit = MsgAdapter.ReadInt()		--召唤积分
	self.current_chongzhi = MsgAdapter.ReadInt()	--当前充值
end

--金猪召唤boss状态
SCGoldenPigBossState = SCGoldenPigBossState or BaseClass(BaseProtocolStruct)
function SCGoldenPigBossState:__init()
	self.msg_type = 8435
end

function SCGoldenPigBossState:Decode()					--boss状态 0不存在,1存在
	self.boss_state = {}
	for i = 1, GameEnum.GOLDEN_PIG_SUMMON_TYPE_MAX do
		self.boss_state[i] = MsgAdapter.ReadChar()
	end
	self.reserve_ch = MsgAdapter.ReadChar()
end

-------------------------- 推图副本 --------------------------
--请求
CSTuituFbOperaReq = CSTuituFbOperaReq or BaseClass(BaseProtocolStruct)
function CSTuituFbOperaReq:__init()
	self.msg_type = 8430
	self.opera_type = 0
	self.param_1 = 0
	self.param_2 = 0
	self.param_3 = 0
end

function CSTuituFbOperaReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.opera_type)							--请求信息
	MsgAdapter.WriteInt(self.param_1)
	MsgAdapter.WriteInt(self.param_2)
	MsgAdapter.WriteInt(self.param_3)
end

--推图副本信息
SCTuituFbInfo = SCTuituFbInfo or BaseClass(BaseProtocolStruct)
function SCTuituFbInfo:__init()
	self.msg_type = 8431
end

function SCTuituFbInfo:Decode()
	self.fb_info_list = {}											--副本信息， 数组长度2
	for i = 1, 1 do
		local one_vo = {}
		one_vo.pass_chapter = MsgAdapter.ReadShort()				--已通过最大章节
		one_vo.pass_level = MsgAdapter.ReadShort()					--已通过最大关卡等级
		one_vo.today_join_times = MsgAdapter.ReadShort()			--今日进入次数
		one_vo.buy_join_times = MsgAdapter.ReadShort()				--购买次数
		one_vo.chapter_info_list = {}								--章节列表，数组长度50

		for j = 0, 49 do
			local chatper_info = {}

			chatper_info.is_pass_chapter = MsgAdapter.ReadChar()	--是否章节通关(一章里面所有关卡通关)
			MsgAdapter.ReadChar()
			MsgAdapter.ReadShort()
			chatper_info.total_star = MsgAdapter.ReadShort()		--章节总星数
			chatper_info.star_reward_flag = MsgAdapter.ReadShort()	--章节星数奖励拿取标记，按位与
			chatper_info.level_info_list = {}						--关卡列表，数组大小20
			for k = 0 , 19 do
				local level_info = {}
				level_info.pass_star = MsgAdapter.ReadChar()		--关卡通关星数
				level_info.reward_flag = MsgAdapter.ReadChar()		--关卡奖励拿取标记（0或1）
				MsgAdapter.ReadShort()
				chatper_info.level_info_list[k] = level_info
			end
			one_vo.chapter_info_list[j] = chatper_info
		end
		one_vo.card_add_times = MsgAdapter.ReadShort()
		self.fb_info_list[i] = one_vo
	end
	MsgAdapter.ReadShort()
	-- print_error(self.fb_info_list[1].pass_chapter, self.fb_info_list[1].pass_level, self.fb_info_list[1].chapter_info_list[3].level_info_list)
end

SCTuituFbResultInfo = SCTuituFbResultInfo or BaseClass(BaseProtocolStruct)
function SCTuituFbResultInfo:__init()
	self.msg_type = 8432
end

function SCTuituFbResultInfo:Decode()
	self.star = MsgAdapter.ReadChar()				-- 通关星级 star > 0则成功 否则失败
	MsgAdapter.ReadChar()
	self.item_count = MsgAdapter.ReadShort()
	self.reward_item_list = {}
	for i = 1, self.item_count do
		local vo = {}
		vo.item_id = MsgAdapter.ReadUShort()
		vo.num = MsgAdapter.ReadShort()
		vo.is_bind = MsgAdapter.ReadChar()
		MsgAdapter.ReadChar()
		MsgAdapter.ReadShort()
		self.reward_item_list[i] = vo
	end
end

SCTuituFbSingleInfo = SCTuituFbSingleInfo or BaseClass(BaseProtocolStruct)
function SCTuituFbSingleInfo:__init()
	self.msg_type = 8433
end

function SCTuituFbSingleInfo:Decode()
	self.fb_type = MsgAdapter.ReadShort()						-- 副本类型
	self.chatper = MsgAdapter.ReadChar()					    -- 副本章节
	self.level = MsgAdapter.ReadChar()				    		-- 副本关卡等级
	self.cur_chapter = MsgAdapter.ReadShort()					-- 当前进行章节
	self.cur_level = MsgAdapter.ReadShort()						-- 当前进行关卡等级
	self.today_join_times = MsgAdapter.ReadShort()				-- 今日进入副本次数
	self.buy_join_times = MsgAdapter.ReadShort()				-- 购买次数
	self.total_star = MsgAdapter.ReadShort()			        -- 章节总星数
	self.star_reward_flag = MsgAdapter.ReadShort()		        -- 章节星数奖励标记
	self.layer_info = {}										-- 关卡信息
	self.layer_info.pass_star = MsgAdapter.ReadChar()
	self.layer_info.reward_flag = MsgAdapter.ReadChar()
	MsgAdapter.ReadShort()

	-- print_error(self.total_star, self.buy_join_times, self.star_reward_flag)
end

SCTuituFbFetchResultInfo = SCTuituFbFetchResultInfo or BaseClass(BaseProtocolStruct)
function SCTuituFbFetchResultInfo:__init()
	self.msg_type = 8434
end

function SCTuituFbFetchResultInfo:Decode()
	self.is_success = MsgAdapter.ReadShort()
	self.fb_type = MsgAdapter.ReadShort()
	self.chapter = MsgAdapter.ReadShort()
	self.seq = MsgAdapter.ReadShort()
end

SCTuituFbTitleInfo = SCTuituFbTitleInfo or BaseClass(BaseProtocolStruct)
function SCTuituFbTitleInfo:__init()
	self.msg_type = 8436
end

function SCTuituFbTitleInfo:Decode()
	self.names = {}
	for i=0,49 do
		self.names[i] = MsgAdapter.ReadStrN(32)
	end
end

-- 神格神躯信息
SCShengeShenquAllInfo = SCShengeShenquAllInfo or BaseClass(BaseProtocolStruct)
function SCShengeShenquAllInfo:__init()
	self.msg_type = 8440
end

function SCShengeShenquAllInfo:Decode()
	self.shenqu_list = {}
	for i = 0, GameEnum.SHENGE_SYSTEM_SHENGESHENQU_MAX_NUM - 1 do
		local shenqu_attr = {}
		for j = 1, GameEnum.SHENGE_SYSTEM_SHENGESHENQU_ATTR_MAX_NUM do
			local attr_info = {}
			for p = 1, GameEnum.SHENGE_SYSTEM_SHENGESHENQU_XILIAN_SLOT_MAX_NUM do
				local vo = {}
				vo.qianghua_times = MsgAdapter.ReadShort()
				vo.attr_point = MsgAdapter.ReadShort()
				vo.attr_value = MsgAdapter.ReadInt()
				-- vo.is_select = MsgAdapter.ReadShort()
				attr_info[p] = vo
			end
			shenqu_attr[j] = attr_info
		end
		self.shenqu_list[i] = shenqu_attr
	end
	self.shenqu_history_max_cap = {}
	for i = 0, GameEnum.SHENGE_SYSTEM_SHENGESHENQU_MAX_NUM - 1 do
		self.shenqu_history_max_cap[i] = MsgAdapter.ReadInt()
	end
end

-- 单个神格神躯信息
SCShengeShenquInfo = SCShengeShenquInfo or BaseClass(BaseProtocolStruct)
function SCShengeShenquInfo:__init()
	self.msg_type = 8441
end

function SCShengeShenquInfo:Decode()
	self.shenqu_id = MsgAdapter.ReadInt()
	self.shenqu_attr = {}
	for j = 1, GameEnum.SHENGE_SYSTEM_SHENGESHENQU_ATTR_MAX_NUM do
		local attr_info = {}
		for p = 1, GameEnum.SHENGE_SYSTEM_SHENGESHENQU_XILIAN_SLOT_MAX_NUM do
			local vo = {}
			vo.qianghua_times = MsgAdapter.ReadShort()
			vo.attr_point = MsgAdapter.ReadShort()
			vo.attr_value = MsgAdapter.ReadInt()
			-- vo.is_select = MsgAdapter.ReadShort()
			attr_info[p] = vo
		end
		self.shenqu_attr[j] = attr_info
	end
	self.shenqu_history_max_cap = MsgAdapter.ReadInt()
end

SCRuneSystemZhulingNotifyInfo = SCRuneSystemZhulingNotifyInfo or BaseClass(BaseProtocolStruct)
function SCRuneSystemZhulingNotifyInfo:__init()
	self.msg_type = 8442
end

function SCRuneSystemZhulingNotifyInfo:Decode()
	self.index = MsgAdapter.ReadInt()
	self.zhuling_slot_bless = MsgAdapter.ReadInt()
end

SCRuneSystemZhulingAllInfo = SCRuneSystemZhulingAllInfo or BaseClass(BaseProtocolStruct)
function SCRuneSystemZhulingAllInfo:__init()
	self.msg_type = 8443
end

function SCRuneSystemZhulingAllInfo:Decode()
	self.zhuling_slot_bless = MsgAdapter.ReadInt()
	self.run_zhuling_list = {}
	for i=1, GameEnum.RUNE_SYSTEM_SLOT_MAX_NUM do
		self.run_zhuling_list[i] = {}
		self.run_zhuling_list[i].grade = MsgAdapter.ReadInt()
		self.run_zhuling_list[i].zhuling_bless = MsgAdapter.ReadInt()
	end
end

SCRuneSystemXunBaoResult = SCRuneSystemXunBaoResult or BaseClass(BaseProtocolStruct)
function SCRuneSystemXunBaoResult:__init()
	self.msg_type = 8444
end

function SCRuneSystemXunBaoResult:Decode()
	self.jinghua_box_magic_crystal = MsgAdapter.ReadInt()
	local item_count = MsgAdapter.ReadInt()
	self.item_list = {}
	for i = 1, item_count do
		local item_info = {}
		item_info.item_id = MsgAdapter.ReadShort()
		item_info.num = MsgAdapter.ReadShort()
		item_info.is_bind = 1
		table.insert(self.item_list, item_info)
	end
end

SCXuantuCuiLianInfo = SCXuantuCuiLianInfo or BaseClass(BaseProtocolStruct)
function SCXuantuCuiLianInfo:__init()
	self.msg_type = 8445
end

function SCXuantuCuiLianInfo:Decode()
	self.grid_id = MsgAdapter.ReadInt()
	self.level = MsgAdapter.ReadInt()
	self.attr_list = {}
	for i=1,3 do
		self.attr_list[i] = MsgAdapter.ReadInt()
	end
end

SCXuantuCuiLianAllInfo = SCXuantuCuiLianAllInfo or BaseClass(BaseProtocolStruct)
function SCXuantuCuiLianAllInfo:__init()
	self.msg_type = 8446
	self.cell_info_list = {}
end

function SCXuantuCuiLianAllInfo:Decode()
	for i=0,19 do
		local cell = {}
		cell.grid_id = MsgAdapter.ReadInt()
		cell.level = MsgAdapter.ReadInt()
		cell.attr_list = {}
		for i=1,3 do
			cell.attr_list[i] = MsgAdapter.ReadInt()
		end
		self.cell_info_list[i] = cell
	end
end

--------------------------升星助力-----------------------------
CSGetShengxingzhuliInfoReq = CSGetShengxingzhuliInfoReq or BaseClass(BaseProtocolStruct)
function CSGetShengxingzhuliInfoReq:__init()
	self.msg_type = 8450
end

function CSGetShengxingzhuliInfoReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

SCGetShengxingzhuliInfoAck = SCGetShengxingzhuliInfoAck or BaseClass(BaseProtocolStruct)
function SCGetShengxingzhuliInfoAck:__init()
	self.msg_type = 8451
end

function SCGetShengxingzhuliInfoAck:Decode()
	self.is_get_reward_today = MsgAdapter.ReadInt()
	self.chognzhi_today = MsgAdapter.ReadInt()
	self.func_level = MsgAdapter.ReadInt()
	self.func_type = MsgAdapter.ReadInt()
	self.is_max_level = MsgAdapter.ReadInt()
	self.stall = MsgAdapter.ReadInt()
end

CSGetShengxingzhuliRewardReq = CSGetShengxingzhuliRewardReq or BaseClass(BaseProtocolStruct)
function CSGetShengxingzhuliRewardReq:__init()
	self.msg_type = 8452
end

function CSGetShengxingzhuliRewardReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

SCGetShengxingzhuliRewardAck = SCGetShengxingzhuliRewardAck or BaseClass(BaseProtocolStruct)
function SCGetShengxingzhuliRewardAck:__init()
	self.msg_type = 8453
end

function SCGetShengxingzhuliRewardAck:Decode()
	self.is_succ = MsgAdapter.ReadInt()
end

--------------------------------------
--组队塔防
--------------------------------------

-- 组队塔防信息
SCTeamTowerInfo = SCTeamTowerInfo or BaseClass(BaseProtocolStruct)

function SCTeamTowerInfo:__init()
	self.msg_type = 8460
	self.reason = 0
	self.life_tower_left_hp = 0
	self.life_tower_left_maxhp = 0
	self.gongji_uid = 0
	self.fangyu_uid = 0
	self.assist_uid = 0
	self.curr_wave = 0
	self.next_wave_refresh_time = 0
	self.score = 0
	self.exp = 0
	self.clear_wave = 0
	self.skill_list = {}
end

function SCTeamTowerInfo:Decode()
	local MAX_SKILL_COUNT = 4
	self.reason = MsgAdapter.ReadInt()
	self.life_tower_left_hp = MsgAdapter.ReadInt()
	self.life_tower_left_maxhp = MsgAdapter.ReadInt()
	self.gongji_uid = MsgAdapter.ReadInt()
	self.fangyu_uid = MsgAdapter.ReadInt()
	self.assist_uid = MsgAdapter.ReadInt()
	self.curr_wave = MsgAdapter.ReadInt()
	self.next_wave_refresh_time = MsgAdapter.ReadInt()
	self.score = MsgAdapter.ReadInt()
	self.exp = MsgAdapter.ReadInt()
	self.clear_wave = MsgAdapter.ReadInt()
	self.skill_list = {}
	for i = 1, MAX_SKILL_COUNT do
		self.skill_list[i] = {}
		self.skill_list[i].skill_id = MsgAdapter.ReadUShort()
		self.skill_list[i].skill_level = MsgAdapter.ReadShort()
		self.skill_list[i].last_perform_time = MsgAdapter.ReadUInt()
	end
end

-- 加成属性
SCTeamTowerDefendAttrType = SCTeamTowerDefendAttrType or BaseClass(BaseProtocolStruct)
function SCTeamTowerDefendAttrType:__init()
	self.msg_type = 8461
	self.uid = 0
	self.attr_type = 0
end

function SCTeamTowerDefendAttrType:Decode()
	self.uid = MsgAdapter.ReadInt()
	self.attr_type = MsgAdapter.ReadInt()
end

-- 塔防技能CD
SCTeamTowerDefendSkill = SCTeamTowerDefendSkill or BaseClass(BaseProtocolStruct)
function SCTeamTowerDefendSkill:__init()
	self.msg_type = 8462
	self.skill_index = 0
	self.skill_level = 0
	self.perform_time = 0
end

function SCTeamTowerDefendSkill:Decode()
	self.skill_index = MsgAdapter.ReadUShort()
	self.skill_level = MsgAdapter.ReadShort()
	self.perform_time = MsgAdapter.ReadUInt()
end

-- 跨服充值
CSCrossRandActivityRequest  = CSCrossRandActivityRequest or BaseClass(BaseProtocolStruct)
function CSCrossRandActivityRequest:__init()
	self.msg_type = 8467
end

function CSCrossRandActivityRequest:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.activity_type)
	MsgAdapter.WriteShort(self.opera_type)
	MsgAdapter.WriteInt(self.param_1)
	MsgAdapter.WriteInt(self.param_2)
	MsgAdapter.WriteInt(self.param_3)
end

SCCrossRandActivityStatus  = SCCrossRandActivityStatus or BaseClass(BaseProtocolStruct)
function SCCrossRandActivityStatus:__init()
	self.msg_type = 8468
end

function SCCrossRandActivityStatus:Decode()
	self.activity_type = MsgAdapter.ReadShort()
	self.status = MsgAdapter.ReadShort()
	self.begin_time = MsgAdapter.ReadUInt()
	self.end_time = MsgAdapter.ReadUInt()
end

SCCrossRAChongzhiRankChongzhiInfo   = SCCrossRAChongzhiRankChongzhiInfo  or BaseClass(BaseProtocolStruct)
function SCCrossRAChongzhiRankChongzhiInfo:__init()
	self.msg_type = 8469
end

function SCCrossRAChongzhiRankChongzhiInfo:Decode()
	self.total_chongzhi = MsgAdapter.ReadUInt()

end

CSLeaveHchz = CSLeaveHchz or BaseClass(BaseProtocolStruct)
function CSLeaveHchz:__init()
	self.msg_type = 8512
end

function CSLeaveHchz:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

-- 设置防御塔加成属性
CSTeamTowerDefendSetAttrType = CSTeamTowerDefendSetAttrType or BaseClass(BaseProtocolStruct)

function CSTeamTowerDefendSetAttrType:__init()
	self.msg_type = 8470
	self.uid = 0
	self.attr_type = 0
end

function CSTeamTowerDefendSetAttrType:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.uid)
	MsgAdapter.WriteInt(self.attr_type)
end

----------------------装备副本-----------------------
SCEquipFBResult = SCEquipFBResult or BaseClass(BaseProtocolStruct)
function SCEquipFBResult:__init()
	self.msg_type = 8480
end

function SCEquipFBResult:Decode()
	self.is_over = MsgAdapter.ReadInt()
	self.is_passed = MsgAdapter.ReadInt()
	self.can_jump = MsgAdapter.ReadInt()
end

SCEquipFBInfo = SCEquipFBInfo or BaseClass(BaseProtocolStruct)
function SCEquipFBInfo:__init()
	self.msg_type = 8481
end

function SCEquipFBInfo:Decode()
	self.is_personal = MsgAdapter.ReadInt()
	self.max_layer_today_entered = MsgAdapter.ReadShort()
	self.flag = MsgAdapter.ReadShort()
	self.mysterylayer_list = {}
	for i = 1, GameEnum.FB_EQUIP_MAX_GOODS_SEQ do
		self.mysterylayer_list[i] = MsgAdapter.ReadChar()
	end

end

SCEquipFBTotalPassExp = SCEquipFBTotalPassExp or BaseClass(BaseProtocolStruct)
function SCEquipFBTotalPassExp:__init()
	self.msg_type = 8482
end

function SCEquipFBTotalPassExp:Decode()
	self.total_pass_exp = MsgAdapter.ReadInt()
end

CSEquipFBBuy = CSEquipFBBuy or BaseClass(BaseProtocolStruct)
function CSEquipFBBuy:__init()
	self.msg_type = 8490
	self.shop_item_seq = 0
	self.is_personal = 0
end

function CSEquipFBBuy:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.shop_item_seq)
	MsgAdapter.WriteInt(self.is_personal)
end

CSEquipFBGetInfo = CSEquipFBGetInfo or BaseClass(BaseProtocolStruct)
function CSEquipFBGetInfo:__init()
	self.msg_type = 8491
	self.is_personal = 0
end

function CSEquipFBGetInfo:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.is_personal)
end

CSEquipFBJumpReq = CSEquipFBJumpReq or BaseClass(BaseProtocolStruct)
function CSEquipFBJumpReq:__init()
	self.msg_type = 8492
end

function CSEquipFBJumpReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end
------------------------------------------------