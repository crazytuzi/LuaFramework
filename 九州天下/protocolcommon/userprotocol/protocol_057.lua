-- 通知客户端进入隐藏服
SCCrossEnterServer = SCCrossEnterServer or BaseClass(BaseProtocolStruct)

function SCCrossEnterServer:__init()
	self.msg_type = 5700
end

function SCCrossEnterServer:Decode()
	self.cross_activity_type = MsgAdapter.ReadInt()
	self.login_server_ip = MsgAdapter.ReadStrN(64)
	self.login_server_port = MsgAdapter.ReadInt()
	self.pname = MsgAdapter.ReadStrN(64)
	self.login_time = MsgAdapter.ReadUInt()
	self.login_str = MsgAdapter.ReadStrN(32)
	self.anti_wallow = MsgAdapter.ReadChar()
	MsgAdapter.ReadChar()
	self.server = MsgAdapter.ReadShort()
end

-- 跨服修罗塔个人活动信息
SCCrossXiuluoTowerSelfActivityInfo = SCCrossXiuluoTowerSelfActivityInfo or BaseClass(BaseProtocolStruct)

function SCCrossXiuluoTowerSelfActivityInfo:__init()
	self.msg_type = 5701
end

function SCCrossXiuluoTowerSelfActivityInfo:Decode()
	self.cur_layer = MsgAdapter.ReadShort()
	self.max_layer = MsgAdapter.ReadShort()
	self.immediate_realive_count = MsgAdapter.ReadShort()
	self.boss_num = MsgAdapter.ReadShort()
	self.total_kill_count = MsgAdapter.ReadInt()
	self.kill_role_count = MsgAdapter.ReadInt()
	self.cur_layer_kill_count = MsgAdapter.ReadInt()
	self.reward_cross_honor = MsgAdapter.ReadInt()
	self.score = MsgAdapter.ReadInt()
	self.score_reward_flag = MsgAdapter.ReadInt()
	self.refresh_boss_time = MsgAdapter.ReadUInt()
end

--  跨服修罗塔排行榜信息
SCCrossXiuluoTowerRankInfo = SCCrossXiuluoTowerRankInfo or BaseClass(BaseProtocolStruct)

function SCCrossXiuluoTowerRankInfo:__init()
	self.msg_type = 5702
end

function SCCrossXiuluoTowerRankInfo:Decode()
	local count = MsgAdapter.ReadInt()
	self.rank = {}
	for i=1, count do
		local vo  = {}
		vo.user_name = MsgAdapter.ReadStrN(32)

		vo.finish_time = MsgAdapter.ReadUShort()
		vo.max_layer = (MsgAdapter.ReadShort() + 1)
		vo.prof = MsgAdapter.ReadChar()
		vo.camp = MsgAdapter.ReadChar()
		MsgAdapter.ReadShort()
		self.rank[i] = vo
	end
end

--  跨服修罗塔改变层提示
SCCrossXiuluoTowerChangeLayerNotice = SCCrossXiuluoTowerChangeLayerNotice or BaseClass(BaseProtocolStruct)

function SCCrossXiuluoTowerChangeLayerNotice:__init()
	self.msg_type = 5703
end

function SCCrossXiuluoTowerChangeLayerNotice:Decode()
	self.is_drop_layer = MsgAdapter.ReadInt()
end

-- 跨服修罗塔结果
SCCrossXiuluoTowerUserResult = SCCrossXiuluoTowerUserResult or BaseClass(BaseProtocolStruct)

function SCCrossXiuluoTowerUserResult:__init()
	self.msg_type = 5704
end

function SCCrossXiuluoTowerUserResult:Decode()
	self.result_info = {}
	self.result_info.max_layer = MsgAdapter.ReadChar()
	self.result_info.rank_pos = MsgAdapter.ReadChar()
	self.result_info.kill_role_count = MsgAdapter.ReadShort()
	self.result_info.reward_cross_honor = MsgAdapter.ReadInt()
end

-- 跨服修罗塔属性加成
SCCrossXiuluoTowerInfo = SCCrossXiuluoTowerInfo or BaseClass(BaseProtocolStruct)

function SCCrossXiuluoTowerInfo:__init()
	self.msg_type = 5705
end

function SCCrossXiuluoTowerInfo:Decode()
	self.buy_realive_count = MsgAdapter.ReadInt()
	self.add_gongji_per = MsgAdapter.ReadShort()
	self.add_hp_per = MsgAdapter.ReadShort()
end

-- 跨服荣誉值改变
SCCrossHonorChange = SCCrossHonorChange	or BaseClass(BaseProtocolStruct)

function SCCrossHonorChange:__init()
	self.msg_type = 5706
end

function SCCrossHonorChange:Decode()
	self.honor = MsgAdapter.ReadInt()
	self.delta_honor = MsgAdapter.ReadInt()
end

-- 跨服1v1活动信息
SCCrossActivity1V1SelfInfo = SCCrossActivity1V1SelfInfo	or BaseClass(BaseProtocolStruct)

function SCCrossActivity1V1SelfInfo:__init()
	self.msg_type = 5707
end

function SCCrossActivity1V1SelfInfo:Decode()
	self.info = {}
	self.info.cross_honor = MsgAdapter.ReadInt()
	self.info.cross_score_1v1 = MsgAdapter.ReadInt()
	self.info.cross_1v1_left_hp = MsgAdapter.ReadInt()
	self.info.cross_week_win_1v1_count = MsgAdapter.ReadShort()
	self.info.cross_week_lose_1v1_count = MsgAdapter.ReadShort()
	self.info.cross_day_win_1v1_count = MsgAdapter.ReadShort()
	self.info.cross_day_lose_1v1_count = MsgAdapter.ReadShort()
	self.info.cross_1v1_day_match_fail_count = MsgAdapter.ReadShort()
	self.info.cross_dur_win_1v1_max_count = MsgAdapter.ReadChar()
	self.info.cross_dur_win_1v1_count = MsgAdapter.ReadChar()
	self.info.cross_dur_lose_1v1_count = MsgAdapter.ReadChar()
	self.info.cross_1v1_xiazhu_seq = MsgAdapter.ReadChar()
	self.info.cross_1v1_xiazhu_gold = MsgAdapter.ReadShort()
	self.info.cross_1v1_curr_activity_add_honor = MsgAdapter.ReadInt()								--跨服1v1本场活动增加的荣誉
	self.info.cross_1v1_curr_activity_add_score = MsgAdapter.ReadInt()								--跨服1v1本场活动增加的威望
	self.info.cross_1v1_max_score = MsgAdapter.ReadInt()
	self.info.cross_1v1_score_reward_flag = MsgAdapter.ReadInt()
end

-- 跨服1V1战斗开始
SCCross1v1FightStart = SCCross1v1FightStart	or BaseClass(BaseProtocolStruct)

function SCCross1v1FightStart:__init()
	self.msg_type = 5708
end

function SCCross1v1FightStart:Decode()

end

-- 跨服3v3主角信息刷新
SCCrossMultiuserChallengeSelfInfoRefresh = SCCrossMultiuserChallengeSelfInfoRefresh	or BaseClass(BaseProtocolStruct)

function SCCrossMultiuserChallengeSelfInfoRefresh:__init()
	self.msg_type = 5709
end

function SCCrossMultiuserChallengeSelfInfoRefresh:Decode()
	self.self_side = MsgAdapter.ReadInt()
	self.kills = MsgAdapter.ReadInt()
	self.assist = MsgAdapter.ReadInt()
	self.dead = MsgAdapter.ReadInt()
end


-- 跨服3v3信息刷新
SCCrossMultiuserChallengeMatchInfoRefresh = SCCrossMultiuserChallengeMatchInfoRefresh or BaseClass(BaseProtocolStruct)

function SCCrossMultiuserChallengeMatchInfoRefresh:__init()
	self.msg_type = 5710
end

function SCCrossMultiuserChallengeMatchInfoRefresh:Decode()
	self.side_score_list = {}
	for i = 1, 2 do
		self.side_score_list[i] = MsgAdapter.ReadInt()
	end
	self.stronghold_list = {}
	for i = 1, GameEnum.CROSS_MULTIUSER_CHALLENGE_STRONGHOLD_NUM do
		local vo = {}
		vo.obj_id = MsgAdapter.ReadUShort()
		vo.owner_side = MsgAdapter.ReadShort()
		self.stronghold_list[i] = vo
	end
end

-- 跨服3v3匹配状态
SCCrossMultiuserChallengeMatchState = SCCrossMultiuserChallengeMatchState or BaseClass(BaseProtocolStruct)

function SCCrossMultiuserChallengeMatchState:__init()
	self.msg_type = 5711
end

function SCCrossMultiuserChallengeMatchState:Decode()
		self.match_state = MsgAdapter.ReadShort()
		self.win_side = MsgAdapter.ReadShort()
		self.next_state_time = MsgAdapter.ReadUInt()
		self.user_info_list = {}
		for i = 1, GameEnum.CROSS_MULTIUSER_CHALLENGE_SIDE_MEMBER_COUNT * 2 do
			local vo ={}
			vo.plat_type = MsgAdapter.ReadShort()
			vo.obj_id = MsgAdapter.ReadUShort()
			vo.role_id = MsgAdapter.ReadInt()
			vo.name = MsgAdapter.ReadStrN(32)
			vo.prof = MsgAdapter.ReadShort()
			vo.sex = MsgAdapter.ReadShort()
			vo.kills = MsgAdapter.ReadShort()
			vo.assist = MsgAdapter.ReadShort()
			vo.dead = MsgAdapter.ReadShort()
			vo.occupy = MsgAdapter.ReadShort()
			vo.origin_score = MsgAdapter.ReadInt()
			vo.add_score = MsgAdapter.ReadInt()
			vo.add_honor = MsgAdapter.ReadInt()
			vo.is_mvp = MsgAdapter.ReadInt()
			self.user_info_list[i] = vo
		end
end

-- 跨服3v3基本信息
SCCrossMultiuserChallengeBaseSelfSideInfo = SCCrossMultiuserChallengeBaseSelfSideInfo or BaseClass(BaseProtocolStruct)

function SCCrossMultiuserChallengeBaseSelfSideInfo:__init()
	self.msg_type = 5712
end

function SCCrossMultiuserChallengeBaseSelfSideInfo:Decode()
	local user_count = MsgAdapter.ReadInt()
	self.user_list = {}
	for i=1,user_count do
		local vo = {}
		vo.plat_type = MsgAdapter.ReadInt()
		vo.server_id = MsgAdapter.ReadInt()
		vo.uid = MsgAdapter.ReadInt()
		vo.user_name = MsgAdapter.ReadStrN(32)
		MsgAdapter.ReadChar()
		vo.sex = MsgAdapter.ReadChar()
		vo.prof = MsgAdapter.ReadChar()
		vo.camp = MsgAdapter.ReadChar()
		vo.level = MsgAdapter.ReadInt()
		vo.challenge_score = MsgAdapter.ReadInt()
		vo.win_percent = MsgAdapter.ReadInt()
		vo.capability = MsgAdapter.ReadInt()
		self.user_list[i] = vo
	end
end

-- 跨服3v3角色活动信息
SCCrossMultiuserChallengeSelfActicityInfo = SCCrossMultiuserChallengeSelfActicityInfo or BaseClass(BaseProtocolStruct)

function SCCrossMultiuserChallengeSelfActicityInfo:__init()
	self.msg_type = 5713
end

function SCCrossMultiuserChallengeSelfActicityInfo:Decode()
	self.info = {}
	self.info.challenge_mvp_count = MsgAdapter.ReadInt()
	self.info.challenge_score = MsgAdapter.ReadInt()
	self.info.challenge_total_match_count = MsgAdapter.ReadInt()
	self.info.challenge_win_match_count = MsgAdapter.ReadInt()
	self.info.win_percent = MsgAdapter.ReadShort()
	self.info.today_match_count = MsgAdapter.ReadShort()
	self.info.matching_state = MsgAdapter.ReadInt()
end

-- 跨服3v3获取队友位置信息
SCMultiuserChallengeTeamMemberPosList = SCMultiuserChallengeTeamMemberPosList or BaseClass(BaseProtocolStruct)

function SCMultiuserChallengeTeamMemberPosList:__init()
	self.msg_type = 5714
end

function SCMultiuserChallengeTeamMemberPosList:Decode()
	local member_count = MsgAdapter.ReadInt()
	self.team_member_list = {}
	for i = 1, member_count do
		local member_info = {}
		member_info.role_id = MsgAdapter.ReadInt()
		member_info.obj_id = MsgAdapter.ReadUShort()
		member_info.reserved = MsgAdapter.ReadChar()
		member_info.is_leave_scene = MsgAdapter.ReadChar()
		member_info.pos_x = MsgAdapter.ReadShort()
		member_info.pos_y = MsgAdapter.ReadShort()
		member_info.dir = MsgAdapter.ReadFloat()
		member_info.distance = MsgAdapter.ReadFloat()
		member_info.move_speed = MsgAdapter.ReadInt()
		self.team_member_list[i] = member_info
	end
end

-- 请求开始跨服
CSCrossStartReq = CSCrossStartReq or BaseClass(BaseProtocolStruct)
function CSCrossStartReq:__init()
	self.msg_type = 5750
	self.cross_activity_type = 0
	self.param = 0
end
function CSCrossStartReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.cross_activity_type)
	MsgAdapter.WriteShort(self.param)
end

-- 跨服修罗塔报名
CSCrossXiuluoTowerJoinReq = CSCrossXiuluoTowerJoinReq or BaseClass(BaseProtocolStruct)
function CSCrossXiuluoTowerJoinReq:__init()
	self.msg_type = 5751
end
function CSCrossXiuluoTowerJoinReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

-- 跨服修罗塔购买buff
CSCrossXiuluoTowerBuyBuff = CSCrossXiuluoTowerBuyBuff or BaseClass(BaseProtocolStruct)
function CSCrossXiuluoTowerBuyBuff:__init()
	self.msg_type = 5752
	self.is_buy_realive_count = 0
	self.is_use_gold_bind = 0

end
function CSCrossXiuluoTowerBuyBuff:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.is_buy_realive_count)
	MsgAdapter.WriteShort(self.is_use_gold_bind)
end

-- 跨服1v1匹配请求
CSCrossMatch1V1Req = CSCrossMatch1V1Req or BaseClass(BaseProtocolStruct)
function CSCrossMatch1V1Req:__init()
	self.msg_type = 5753

end
function CSCrossMatch1V1Req:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

-- 跨服1v1战斗准备
CSCross1v1FightReady = CSCross1v1FightReady or BaseClass(BaseProtocolStruct)
function CSCross1v1FightReady:__init()
	self.msg_type = 5754

end
function CSCross1v1FightReady:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

-- 跨服1v1领取奖励
CSCross1v1FetchRewardReq = CSCross1v1FetchRewardReq or BaseClass(BaseProtocolStruct)
function CSCross1v1FetchRewardReq:__init()
	self.msg_type = 5755
	self.seq = 0
end
function CSCross1v1FetchRewardReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.seq)
end

--跨服3v3请求匹配（队长发起）
CSCrossMultiuserChallengeMatchgingReq = CSCrossMultiuserChallengeMatchgingReq or BaseClass(BaseProtocolStruct)
function CSCrossMultiuserChallengeMatchgingReq:__init()
	self.msg_type = 5756
end

function CSCrossMultiuserChallengeMatchgingReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

-- 跨服3v3请求同队基本信息
CSCrossMultiuserChallengeGetBaseSelfSideInfo = CSCrossMultiuserChallengeGetBaseSelfSideInfo or BaseClass(BaseProtocolStruct)
function CSCrossMultiuserChallengeGetBaseSelfSideInfo:__init()
	self.msg_type = 5757
end

function CSCrossMultiuserChallengeGetBaseSelfSideInfo:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

-- 跨服3v3获取每日奖励
CSCrossMultiuserChallengeFetchDaycountReward = CSCrossMultiuserChallengeFetchDaycountReward or BaseClass(BaseProtocolStruct)
function CSCrossMultiuserChallengeFetchDaycountReward:__init()
	self.msg_type = 5758
end

function CSCrossMultiuserChallengeFetchDaycountReward:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

-- 跨服3v3取消匹配
CSCrossMultiuerChallengeCancelMatching = CSCrossMultiuerChallengeCancelMatching or BaseClass(BaseProtocolStruct)
function CSCrossMultiuerChallengeCancelMatching:__init()
	self.msg_type = 5759
end

function CSCrossMultiuerChallengeCancelMatching:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

-- 跨服3v3，请求队友位置信息
CSMultiuserChallengeReqSideMemberPos = CSMultiuserChallengeReqSideMemberPos or BaseClass(BaseProtocolStruct)
function CSMultiuserChallengeReqSideMemberPos:__init()
	self.msg_type = 5760
end

function CSMultiuserChallengeReqSideMemberPos:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

-- 跨服1V1(巅峰竞技) 取消匹配
CSCrossCancelMatch1V1Req = CSCrossCancelMatch1V1Req or BaseClass(BaseProtocolStruct)
function CSCrossCancelMatch1V1Req:__init()
	self.msg_type = 5761
end

function CSCrossCancelMatch1V1Req:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

-- 比赛状态通知
SCCrossTuanzhanStateNotify = SCCrossTuanzhanStateNotify or BaseClass(BaseProtocolStruct)
function SCCrossTuanzhanStateNotify:__init()
	self.msg_type = 5715
end

function SCCrossTuanzhanStateNotify:Decode()
	self.fight_start_time = MsgAdapter.ReadUInt()					-- 战斗开始时间
	self.activity_end_time = MsgAdapter.ReadUInt()					-- 活动结束时间
end

-- 玩家信息
SCCrossTuanzhanPlayerInfo = SCCrossTuanzhanPlayerInfo or BaseClass(BaseProtocolStruct)
function SCCrossTuanzhanPlayerInfo:__init()
	self.msg_type = 5716
end

function SCCrossTuanzhanPlayerInfo:Decode()
	self.side = MsgAdapter.ReadShort()						-- 所在阵营
	MsgAdapter.ReadShort()
	self.score = MsgAdapter.ReadUInt()						-- 积分
	self.kill_num = MsgAdapter.ReadUInt() 					-- 击杀次数
	self.assist_kill_num = MsgAdapter.ReadUInt() 			-- 助攻次数
	self.dur_kill_num = MsgAdapter.ReadUInt()				-- 连杀次数
end

-- 排名信息
SCCrossTuanzhanRankInfo = SCCrossTuanzhanRankInfo or BaseClass(BaseProtocolStruct)
function SCCrossTuanzhanRankInfo:__init()
	self.msg_type = 5717
end

function SCCrossTuanzhanRankInfo:Decode()
	local rank_list_count = MsgAdapter.ReadInt()
	self.rank_list = {}
	for i = 1, rank_list_count do
		local vo = {}
		vo.side = MsgAdapter.ReadShort()
		MsgAdapter.ReadShort()
		vo.score = MsgAdapter.ReadUInt()
		vo.name = MsgAdapter.ReadStrN(32)
		self.rank_list[i] = vo
	end
end

-- 阵营积分信息
SCCrossTuanzhanSideInfo = SCCrossTuanzhanSideInfo or BaseClass(BaseProtocolStruct)
function SCCrossTuanzhanSideInfo:__init()
	self.msg_type = 5718
end

function SCCrossTuanzhanSideInfo:Decode()
	self.side_score_list = {}
	for i = 1, CROSS_TUANZHAN_SIDE.CROSS_TUANZHAN_SIDE_MAX do
		self.side_score_list[i] = MsgAdapter.ReadUInt()
	end
end

-- 通天柱子信息
SCCrossTuanzhanPillaInfo = SCCrossTuanzhanPillaInfo or BaseClass(BaseProtocolStruct)
function SCCrossTuanzhanPillaInfo:__init()
	self.msg_type = 5719
end

function SCCrossTuanzhanPillaInfo:Decode()
	local pilla_list_count = MsgAdapter.ReadUShort()
	MsgAdapter.ReadShort()
	self.pilla_list = {}
	for i = 1, pilla_list_count do
		local vo= {}
		vo.monster_id = MsgAdapter.ReadUShort() 			-- 柱子怪物id
		vo.obj_id = MsgAdapter.ReadUShort()					-- 柱子的对象id
		vo.owner_side = MsgAdapter.ReadShort()				-- 占领柱子的阵营
		MsgAdapter.ReadShort()
		vo.owner_name = MsgAdapter.ReadStrN(32)				-- 占领柱子玩家名
		self.pilla_list[i] = vo
	end
end

-- 连杀信息变更
SCCrossTuanzhanPlayerDurKillInfo = SCCrossTuanzhanPlayerDurKillInfo or BaseClass(BaseProtocolStruct)
function SCCrossTuanzhanPlayerDurKillInfo:__init()
	self.msg_type = 5720
end

function SCCrossTuanzhanPlayerDurKillInfo:Decode()
	self.obj_id = MsgAdapter.ReadUShort()					-- 玩家对象id
	self.reserve_sh = MsgAdapter.ReadShort()
	self.dur_kill_num = MsgAdapter.ReadUInt()				-- 连杀次数
end

-- 比赛结果通知
SCCrossTuanzhanResultInfo = SCCrossTuanzhanResultInfo or BaseClass(BaseProtocolStruct)
function SCCrossTuanzhanResultInfo:__init()
	self.msg_type = 5721
end

function SCCrossTuanzhanResultInfo:Decode()
	self.personal_score = MsgAdapter.ReadUInt()								-- 个人积分
	self.side_score = MsgAdapter.ReadUInt()									-- 阵营积分
	self.result = MsgAdapter.ReadShort()									-- 比赛结果，0 失败，1 胜利
	self.reserve_sh = MsgAdapter.ReadShort()
end

-------跨服牧场，玩家信息通知
SCCrossPasturePlayerInfo = SCCrossPasturePlayerInfo or BaseClass(BaseProtocolStruct)
function SCCrossPasturePlayerInfo:__init()
	self.msg_type = 5722
	self.score = 0
	self.left_get_score_times = 0
	self.reserve = 0
end

function SCCrossPasturePlayerInfo:Decode()
	self.score = MsgAdapter.ReadInt()							-- 当前积分
	self.left_get_score_times = MsgAdapter.ReadShort()			-- 剩余获取积分次数
	self.reserve = MsgAdapter.ReadShort()
end


-- 跨服BOSS购买复活次数
CSCrossBossBuyReliveTimes = CSCrossBossBuyReliveTimes or BaseClass(BaseProtocolStruct)
function CSCrossBossBuyReliveTimes:__init()
	self.msg_type = 5723
	self.buy_times = 0
	self.reserved_sh = 0
end

function CSCrossBossBuyReliveTimes:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.buy_times)
	MsgAdapter.WriteShort(self.reserved_sh)
end

-- 跨服BOSS玩家信息
SCCrossBossPlayerInfo = SCCrossBossPlayerInfo or BaseClass(BaseProtocolStruct)
function SCCrossBossPlayerInfo:__init()
	self.msg_type = 5724

	self.cur_score = 0
	self.left_relive_times = 0
	self.notify_reason = 0
	self.cur_honor = 0
	self.cur_elite_honor = 0
end

function SCCrossBossPlayerInfo:Decode()
	self.cur_score = MsgAdapter.ReadInt()							--剩余积分
	self.left_relive_times = MsgAdapter.ReadShort()					--剩余复活次数
	self.notify_reason = MsgAdapter.ReadShort()						--通知原因
	self.cur_honor = MsgAdapter.ReadInt()							-- 荣耀
	self.cur_elite_honor = MsgAdapter.ReadInt()						-- 精英荣耀
end

-- 跨服boss场景里boss信息
SCCrossBossSceneBossInfo = SCCrossBossSceneBossInfo or BaseClass(BaseProtocolStruct)
function SCCrossBossSceneBossInfo:__init()
	self.msg_type = 5725
	self.boss_list = {}
end

function SCCrossBossSceneBossInfo:Decode()
	self.boss_list = {}
	for i = 1, GameEnum.MAX_CROSS_BOSS_PER_SCENE do
		local boss_info = {}
		boss_info.boss_id = MsgAdapter.ReadInt()
		boss_info.is_alive = MsgAdapter.ReadInt()
		boss_info.pos_x = MsgAdapter.ReadInt()
		boss_info.pos_y = MsgAdapter.ReadInt()
		boss_info.next_flush_time = MsgAdapter.ReadUInt()
		table.insert(self.boss_list, boss_info)
	end
end

-- 服务器即将关闭通知
SCServerShutdownNotify = SCServerShutdownNotify or BaseClass(BaseProtocolStruct)
function SCServerShutdownNotify:__init()
	self.msg_type = 5726

	self.remain_second = 0
end

function SCServerShutdownNotify:Decode()
	self.remain_second = MsgAdapter.ReadInt()							-- 离关闭服务器剩余秒数
end

-- 跨服修罗塔BUFF信息
SCCrossXiuluoTowerBuffInfo = SCCrossXiuluoTowerBuffInfo or BaseClass(BaseProtocolStruct)
function SCCrossXiuluoTowerBuffInfo:__init()
	self.msg_type = 5727

	self.id = 0
	self.buff_num = 0
	self.next_send_reward_time = 0
end

function SCCrossXiuluoTowerBuffInfo:Decode()
	self.id = MsgAdapter.ReadUShort()
	self.buff_num = MsgAdapter.ReadShort()
	self.next_send_reward_time = MsgAdapter.ReadUInt()
end

-- 请求积分奖励
CSCrossXiuluoTowerScoreRewardReq = CSCrossXiuluoTowerScoreRewardReq or BaseClass(BaseProtocolStruct)
function CSCrossXiuluoTowerScoreRewardReq:__init()
	self.msg_type = 5728
	self.index = 0
end

function CSCrossXiuluoTowerScoreRewardReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.index)
end

-- 跨服修罗塔采集物信息
SCCrossXiuluoTowerGatherInfo = SCCrossXiuluoTowerGatherInfo or BaseClass(BaseProtocolStruct)
function SCCrossXiuluoTowerGatherInfo:__init()
	self.msg_type = 5729
	self.count = 0
	self.info_list = {}
end

function SCCrossXiuluoTowerGatherInfo:Decode()
	self.count = MsgAdapter.ReadInt()
	self.info_list = {}
	for i = 1, self.count do
		self.info_list[i] = {}
		self.info_list[i].gather_id = MsgAdapter.ReadInt()
		self.info_list[i].gather_count = MsgAdapter.ReadInt()
	end
end

-- 请求跨服boss信息
CSCrossBossBossInfoReq = CSCrossBossBossInfoReq or BaseClass(BaseProtocolStruct)
function CSCrossBossBossInfoReq:__init()
	self.msg_type = 5730
end

function CSCrossBossBossInfoReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

-- 跨服boss信息
SCCrossBossBossInfoAck = SCCrossBossBossInfoAck or BaseClass(BaseProtocolStruct)
function SCCrossBossBossInfoAck:__init()
	self.msg_type = 5731
	self.boss_list = {}
end

function SCCrossBossBossInfoAck:Decode()
	local boss_count = MsgAdapter.ReadInt()
	for i = 1, boss_count do
		self.boss_list[i] = {}
		self.boss_list[i].layer = MsgAdapter.ReadInt()
		self.boss_list[i].boss_id = MsgAdapter.ReadInt()
		self.boss_list[i].next_flush_time = MsgAdapter.ReadUInt()
	end
end

--5370跨服帮派战，操作请求
CSCrossGuildBattleOperate = CSCrossGuildBattleOperate or BaseClass(BaseProtocolStruct)
function CSCrossGuildBattleOperate:__init()
	self.msg_type = 5370
	self.req_type = 0
	self.param1 = 0
	self.param2 = 0
end

function CSCrossGuildBattleOperate:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.req_type)
	MsgAdapter.WriteInt(self.param1)
	MsgAdapter.WriteInt(self.param2)
end

CSCrossGuildBattleGetRankInfoReq = CSCrossGuildBattleGetRankInfoReq or BaseClass(BaseProtocolStruct)
function CSCrossGuildBattleGetRankInfoReq:__init()
	self.msg_type = 5371
end

function CSCrossGuildBattleGetRankInfoReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

--跨服排行信息
SCCrossGuildBattleGetRankInfoResp = SCCrossGuildBattleGetRankInfoResp or BaseClass(BaseProtocolStruct)
function SCCrossGuildBattleGetRankInfoResp:__init()
	self.msg_type = 5372
end

function SCCrossGuildBattleGetRankInfoResp:Decode()
	self.info_type = MsgAdapter.ReadInt()
	self.scene_list = {}
	for i = 1, 6 do
		self.rank_list = {}
		for j = 1 ,10 do
			local guild_info = {}
			guild_info.guild_name = MsgAdapter.ReadStrN(32)
			guild_info.server_id  = MsgAdapter.ReadInt()
			guild_info.get_score  = MsgAdapter.ReadInt()
			guild_info.rank = j

			if guild_info.server_id > 0 then
				table.insert(self.rank_list, guild_info)
			end
		end
		self.scene_list[i] = self.rank_list
	end
end

SCCrossGuildBattleSceneInfo = SCCrossGuildBattleSceneInfo or BaseClass(BaseProtocolStruct)
function SCCrossGuildBattleSceneInfo:__init()
	self.msg_type = 5373

	self.flag_list = {}
	self.guild_join_num_list = {}
	self.rank_list_count = 0
	self.rank_list = {}
end

function SCCrossGuildBattleSceneInfo:Decode()
	self.flag_list = {}
	for i=1,CROSS_GUILDBATTLE.CROSS_GUILDBATTLE_MAX_FLAG_IN_SCENE do 		--CROSS_GUILDBATTLE_MAX_FLAG_IN_SCENE = 3;// 最大旗子数在场景中
		local flag_vo = {}
		flag_vo.monster_id = MsgAdapter.ReadInt()
		flag_vo.plat_type = MsgAdapter.ReadInt()
		flag_vo.server_id = MsgAdapter.ReadInt()
		flag_vo.camp_id = MsgAdapter.ReadInt()
		flag_vo.guild_name = MsgAdapter.ReadStrN(32)
		flag_vo.cur_hp = MsgAdapter.ReadInt()
		flag_vo.max_hp = MsgAdapter.ReadInt()
		self.flag_list[i] = flag_vo
	end
	
	self.guild_join_num_list = {}
	for i=1, CROSS_GUILDBATTLE.CROSS_GUILDBATTLE_MAX_SCENE_NUM do
		self.guild_join_num_list[i] = MsgAdapter.ReadInt()
	end

	self.rank_list_count = MsgAdapter.ReadInt()
	self.first_place_list = {}
	for i = 1, CROSS_GUILDBATTLE.CROSS_GUILDBATTLE_MAX_SCENE_NUM do 			-- 6个场景的第一
		local rank_vo = {}
		rank_vo.plat_type = MsgAdapter.ReadInt()
		rank_vo.server_id = MsgAdapter.ReadInt()
		rank_vo.guild_name = MsgAdapter.ReadStrN(32)
		rank_vo.score = MsgAdapter.ReadInt()
		rank_vo.own_num = MsgAdapter.ReadInt()
		self.first_place_list[i] = rank_vo
	end

	self.rank_list = {}
	for i=1, self.rank_list_count do 		--CROSS_GUILDBATTLE_MAX_GUILD_RANK_NUM = 5;	// 跨服帮派战前5
		local rank_vo = {}
		rank_vo.plat_type = MsgAdapter.ReadInt()
		rank_vo.server_id = MsgAdapter.ReadInt()
		rank_vo.guild_name = MsgAdapter.ReadStrN(32)
		rank_vo.score = MsgAdapter.ReadInt()
		rank_vo.own_num = MsgAdapter.ReadInt()
		self.rank_list[i] = rank_vo
	end
end

SCCrossGuildBattleNotifyInfo = SCCrossGuildBattleNotifyInfo or BaseClass(BaseProtocolStruct)
function SCCrossGuildBattleNotifyInfo:__init()
	self.msg_type = 5374
	self.notify_type = 0
	self.param_1 = 0	
	self.param_2 = 0			
end

function SCCrossGuildBattleNotifyInfo:Decode()
	self.notify_type = MsgAdapter.ReadInt()	
	self.param_1 = MsgAdapter.ReadInt()				--个人积分
	self.param_2 = MsgAdapter.ReadInt()					
end

SCCrossGuildBattleInfo = SCCrossGuildBattleInfo or BaseClass(BaseProtocolStruct)
function SCCrossGuildBattleInfo:__init()
	self.msg_type = 5375		
end

function SCCrossGuildBattleInfo:Decode()
	self.kf_reward_flag = MsgAdapter.ReadInt()	
	self.guild_reward_flag = MsgAdapter.ReadInt()	
	self.is_can_reward = MsgAdapter.ReadInt()	
	self.kf_battle_list = {}					
	for i = 1, CROSS_GUILDBATTLE.CROSS_GUILDBATTLE_MAX_SCENE_NUM do 				--CROSS_GUILDBATTLE_MAX_SCENE_NUM = 6帮派场景个数	
		local vo = {}
		vo.sort = i
		vo.index = i
		vo.plat_type = MsgAdapter.ReadInt()
		vo.server_id = MsgAdapter.ReadInt()
		vo.guild_id = MsgAdapter.ReadInt()
		vo.is_our_guild = MsgAdapter.ReadInt()
		vo.guild_name = MsgAdapter.ReadStrN(32)
		vo.guild_tuanzhang_name = MsgAdapter.ReadStrN(32)
		vo.prof = MsgAdapter.ReadChar()
		vo.sex = MsgAdapter.ReadChar()

		local info = {}
		info.prof = vo.prof
		info.sex = vo.sex
		local appearance = {}
		appearance.fashion_wuqi = MsgAdapter.ReadChar()
		appearance.fashion_body = MsgAdapter.ReadChar()
		appearance.halo_img_id = MsgAdapter.ReadShort()
		MsgAdapter.ReadShort()
		
		info.appearance = appearance
		vo.info = info

		self.kf_battle_list[i] = vo
	end
end

SCCrossGuildBattleTaskInfo = SCCrossGuildBattleTaskInfo or BaseClass(BaseProtocolStruct)
function SCCrossGuildBattleTaskInfo:__init()
	self.msg_type = 5376
end

function SCCrossGuildBattleTaskInfo:Decode()
	self.task_finish_flag = {}
	for i=1,CROSS_GUILDBATTLE.CROSS_GUILDBATTLE_MAX_SCENE_NUM do
		self.task_finish_flag[i] = MsgAdapter.ReadInt()
	end
	self.task_record = {}
	for i=1,CROSS_GUILDBATTLE.CROSS_GUILDBATTLE_MAX_SCENE_NUM do
		self.task_record[i] = {}
		for x=1,CROSS_GUILDBATTLE.CROSS_GUILDBATTLE_MAX_TASK_NUM do
			self.task_record[i][x] = MsgAdapter.ReadInt()
		end
	end
end

SCCrossGuildBattleBossInfo = SCCrossGuildBattleBossInfo or BaseClass(BaseProtocolStruct)
function SCCrossGuildBattleBossInfo:__init()
	self.msg_type = 5377
end

function SCCrossGuildBattleBossInfo:Decode()
	self.scene_id = MsgAdapter.ReadInt()
	self.count = MsgAdapter.ReadInt()
	self.boss_list = {}
	for i=1,self.count do
		local v = {}
		v.boss_id = MsgAdapter.ReadInt()
		v.status = MsgAdapter.ReadInt()
		v.next_refresh_time = MsgAdapter.ReadUInt()
		self.boss_list[i] = v
	end
end