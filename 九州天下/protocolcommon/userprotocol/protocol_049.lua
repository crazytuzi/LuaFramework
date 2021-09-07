--答题 玩家信息 4900
SCQuestionInfo = SCQuestionInfo or BaseClass(BaseProtocolStruct)

function SCQuestionInfo:__init()
	self.msg_type = 4900
end

function SCQuestionInfo:Decode()
	self.notify_reason = MsgAdapter.ReadShort()					-- 通知原因
	self.reserve_sh = MsgAdapter.ReadShort()					-- 保留
	self.curr_question_id = MsgAdapter.ReadShort()				-- 当前题目ID，0表示当前没有题目
	self.today_question_right_count = MsgAdapter.ReadChar()		-- 今日正确数量
	self.today_question_wrong_count = MsgAdapter.ReadChar()		-- 今日错误数量
	self.curr_question_begin_time = MsgAdapter.ReadUInt()		-- 本题开始时间
	self.question_exp = MsgAdapter.ReadInt()					-- 今日获得经验
	self.question_xianhun = MsgAdapter.ReadInt()				-- 今日获得仙魂
	self.question_jinyuan = MsgAdapter.ReadInt()				-- 今日获得铜钱
	self.curr_question_str = MsgAdapter.ReadStrN(128)			-- 当前题目字符串
	self.curr_answer0_desc_str = MsgAdapter.ReadStrN(128)		-- 当前答案0字符串
	self.curr_answer1_desc_str = MsgAdapter.ReadStrN(128)		-- 当前答案1字符串
end

-- 答题 结果 4901
SCQuestionResult = SCQuestionResult or BaseClass(BaseProtocolStruct)

function SCQuestionResult:__init()
	self.msg_type = 4901
	self.result = 0			-- 1 正确，0 错误
end

function SCQuestionResult:Decode()
	self.result = MsgAdapter.ReadInt()
end

--战场荣誉改变
SCBattleFieldHonorChange =  SCBattleFieldHonorChange or BaseClass(BaseProtocolStruct)
function SCBattleFieldHonorChange:__init()
	self.msg_type = 4902
	self.honor = 0
	self.delta_honor = 0
end

function SCBattleFieldHonorChange:Decode()
	self.honor = MsgAdapter.ReadInt()
	self.delta_honor = MsgAdapter.ReadInt()
end


--=================元素战场=================--

--元素战场 用户信息
SCQunXianLuanDouUserInfo =  SCQunXianLuanDouUserInfo or BaseClass(BaseProtocolStruct)
function SCQunXianLuanDouUserInfo:__init()
	self.msg_type = 4903

	self.data = {}
	self.data.notify_reason = 0													-- 通知原因
	self.data.side = 0															-- 角色在战场中的阵营	QUNXIANLUANDOU_SIDE
	self.data.kills = 0															-- 杀人次数
	self.data.lianzhan = 0														-- 连杀次数
	self.data.assists = 0														-- 助攻次数
	self.data.rob_shenshi = 0													-- 夺石次数
	self.data.realive_guard_monsterid = 0										-- 复活点守卫怪物id

	self.data.kill_honor = 0													-- 击杀荣誉
	self.data.assist_honor = 0													-- 助攻荣誉
	self.data.rob_shenshi_honor = 0												-- 运石荣誉
	self.data.free_reward_honor = 0												-- 免费赠送荣
	self.data.last_realive_here_timestamp = 0									-- 最后一次原地复活时间
	self.data.extra_honor = 0												    -- 额外奖励
end

function SCQunXianLuanDouUserInfo:Decode()
	self.data.notify_reason = MsgAdapter.ReadInt()
	self.data.side = MsgAdapter.ReadShort()
	self.data.kills = MsgAdapter.ReadShort()
	self.data.lianzhan = MsgAdapter.ReadShort()
	self.data.assists = MsgAdapter.ReadShort()
	self.data.rob_shenshi = MsgAdapter.ReadShort()
	self.data.realive_guard_monsterid = MsgAdapter.ReadUShort()

	self.data.kill_honor = MsgAdapter.ReadInt()
	self.data.assist_honor = MsgAdapter.ReadInt()
	self.data.rob_shenshi_honor = MsgAdapter.ReadInt()
	self.data.free_reward_honor = MsgAdapter.ReadInt()
	self.data.last_realive_here_timestamp = MsgAdapter.ReadUInt()
	self.data.extra_honor = MsgAdapter.ReadInt()
end

--元素战场 排行榜信息
SCQunXianLuanDouRankInfo =  SCQunXianLuanDouRankInfo or BaseClass(BaseProtocolStruct)
function SCQunXianLuanDouRankInfo:__init()
	self.msg_type = 4904

	self.data = {}
	self.data.count = 0															-- 元素战场 排行榜信息数量
	self.data.rank_list = {}													-- 元素战场 排行榜信息列表 QUNXIANLUANDOU_RANK_NUM
end

function SCQunXianLuanDouRankInfo:Decode()
	self.data.count = MsgAdapter.ReadInt()
	self.data.rank_list = {}
	for i = 0, self.data.count - 1 do
		local user_data = {}
		user_data.index = i
		user_data.uid = MsgAdapter.ReadInt()
		user_data.name  = MsgAdapter.ReadStrN(32)
		user_data.score = MsgAdapter.ReadShort()
		user_data.side = MsgAdapter.ReadShort()
		user_data.appearance = ProtocolStruct.ReadRoleAppearance()				-- 模型外观
		user_data.prof = MsgAdapter.ReadInt()
		user_data.sex = MsgAdapter.ReadInt()
		self.data.rank_list[i + 1] = user_data
	end
end

--元素战场 阵营信息
SCQunXianLuanDouSideInfo =  SCQunXianLuanDouSideInfo or BaseClass(BaseProtocolStruct)
function SCQunXianLuanDouSideInfo:__init()
	self.msg_type = 4905

	self.data = {}
	self.data.scores = {}														-- 元素战场 阵营积分 QUNXIANLUANDOU_SIDE
	self.data.shenshi_next_refresh_time = 0										-- 神石下次刷新时间，0：已经出
end

function SCQunXianLuanDouSideInfo:Decode()
	for i = 0, 3 - 1 do
		local vo = ElementBattleData.CreateSideVo()
		vo.side = i
		vo.score = MsgAdapter.ReadInt()
		self.data.scores[i + 1] = vo
	end
	self.data.shenshi_next_refresh_time = MsgAdapter.ReadUInt()
end

--连斩数改变
SCQunxianluandouLianzhanChange =  SCQunxianluandouLianzhanChange or BaseClass(BaseProtocolStruct)
function SCQunxianluandouLianzhanChange:__init()
	self.msg_type = 4928

	self.obj_id = 0 	--对象id
	self.lianzhan = 0 	--连斩数
end

function SCQunxianluandouLianzhanChange:Decode()
	self.obj_id = MsgAdapter.ReadUShort()
	self.lianzhan = MsgAdapter.ReadShort()
end

-- 群仙乱斗 请求元素排行榜信息
CSGetRankInfo = CSGetRankInfo or BaseClass(BaseProtocolStruct)
function CSGetRankInfo:__init()
	self.msg_type = 4940
end

function CSGetRankInfo:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end


SCQunXianLuanDouRewardResult =  SCQunXianLuanDouRewardResult or BaseClass(BaseProtocolStruct)
function SCQunXianLuanDouRewardResult:__init()
	self.msg_type = 4942

	self.daily_chestshop_score = 0
	self.item_count = 0
	self.item_list = {}
end

function SCQunXianLuanDouRewardResult:Decode()
	self.daily_chestshop_score = MsgAdapter.ReadInt()	-- 日常积分
	self.item_count = MsgAdapter.ReadInt()
	for i = 1, self.item_count do
		local vo = {}
		vo.item_id = MsgAdapter.ReadUShort()
		vo.num = MsgAdapter.ReadChar()
		vo.is_bind = MsgAdapter.ReadChar()
		self.item_list[i] = vo
	end
end
--=================仙盟战=================--

-- 仙盟战用户信息
SCXianMengZhanUserInfo =  SCXianMengZhanUserInfo or BaseClass(BaseProtocolStruct)
function SCXianMengZhanUserInfo:__init()
	self.msg_type = 4907
	self.notify_reason = 0					-- 通知原因
	self.call_count = 0						-- 已召唤次数
	self.call_allow = 0						-- 是否可召唤
	self.score = 0							-- 积分
	self.kill_count = 0						-- 击杀数
	self.last_realive_here_timestamp = 0	-- 上次原地复活时间
	self.lianzhan = 0						-- 连杀次数
end

function SCXianMengZhanUserInfo:Decode()
	self.notify_reason = MsgAdapter.ReadChar()
	self.call_count = MsgAdapter.ReadChar()
	self.call_allow = MsgAdapter.ReadChar()
	MsgAdapter.ReadChar()
	self.score = MsgAdapter.ReadShort()
	self.kill_count = MsgAdapter.ReadShort()
	self.last_realive_here_timestamp = MsgAdapter.ReadUInt()
	self.lianzhan = MsgAdapter.ReadShort()
	MsgAdapter.ReadShort()
	self.assist_count = MsgAdapter.ReadInt()
end

-- 仙盟战仙盟信息
SCXianMengZhanGuildInfo =  SCXianMengZhanGuildInfo or BaseClass(BaseProtocolStruct)
function SCXianMengZhanGuildInfo:__init()
	self.msg_type = 4908
	self.score = 0							-- 积分
	self.area_index = 0						-- 据点索引
	self.last_call_time = 0					-- 上一次召唤时间
end

function SCXianMengZhanGuildInfo:Decode()
	self.score = MsgAdapter.ReadInt()
	self.area_index = MsgAdapter.ReadInt()
	self.last_call_time = MsgAdapter.ReadUInt()
end


-- 仙盟战据点信息
SCXianMengZhanDefendAreaInfo =  SCXianMengZhanDefendAreaInfo or BaseClass(BaseProtocolStruct)
function SCXianMengZhanDefendAreaInfo:__init()
	self.msg_type = 4909
	self.center_area_guild_id = 0			-- 中央据点仙盟ID
	self.center_area_guild_name = ""		-- 中央据点仙盟名
	self.center_area_guild_score = 0		--  中央据点仙盟积分
	self.center_area_guild_camp = 0		--  中央据点仙盟所属阵营
	self.defend_area_list = {}				-- 据点列表
end

function SCXianMengZhanDefendAreaInfo:Decode()
	self.center_area_guild_id = MsgAdapter.ReadInt()
	self.center_area_guild_name = MsgAdapter.ReadStrN(32)
	self.center_area_guild_score = MsgAdapter.ReadInt()
	self.center_area_guild_camp = MsgAdapter.ReadChar()
	MsgAdapter.ReadChar()
	MsgAdapter.ReadShort()
	local area_count = MsgAdapter.ReadInt()
	self.defend_area_list = {}
	for i=1,area_count do
		local data = {}
		data.guild_name = MsgAdapter.ReadStrN(32)
		data.guild_score = MsgAdapter.ReadShort()
		data.area_index = MsgAdapter.ReadChar()
		MsgAdapter.ReadChar()
		data.guild_id = MsgAdapter.ReadInt()
		data.guild_camp = MsgAdapter.ReadChar()
		MsgAdapter.ReadChar()
		MsgAdapter.ReadShort()
		self.defend_area_list[i] = data
	end
end

-- 仙盟战仙盟排行信息
SCXianMengZhanGuildRankInfo =  SCXianMengZhanGuildRankInfo or BaseClass(BaseProtocolStruct)
function SCXianMengZhanGuildRankInfo:__init()
	self.msg_type = 4939
	self.rank_list = {}				-- 排行榜列表
end

function SCXianMengZhanGuildRankInfo:Decode()
	local rank_count = MsgAdapter.ReadInt()
	self.rank_list = {}
	for i=1,rank_count do
		local data = {}
		data.guild_name = MsgAdapter.ReadStrN(32)
		data.guild_id = MsgAdapter.ReadInt()
		data.guild_score = MsgAdapter.ReadInt()
		data.guild_camp = MsgAdapter.ReadChar()
		MsgAdapter.ReadChar()
		MsgAdapter.ReadShort()
		self.rank_list[i] = data
	end
end

-- 仙盟战盟主召唤
SCXianMengZhanGuildCallNotice =  SCXianMengZhanGuildCallNotice or BaseClass(BaseProtocolStruct)
function SCXianMengZhanGuildCallNotice:__init()
	self.msg_type = 4910
	self.caller_name = 0						-- 盟主名字
end

function SCXianMengZhanGuildCallNotice:Decode()
	self.caller_name = MsgAdapter.ReadStrN(32)
end

-- 仙盟战结果通知
SCXianMengZhanResult =  SCXianMengZhanResult or BaseClass(BaseProtocolStruct)
function SCXianMengZhanResult:__init()
	self.msg_type = 4911

	self.guild_rank = 0
	self.guild_score = 0
	self.kill_score = 0
	self.total_score = 0
	self.assist_count = 0
end

function SCXianMengZhanResult:Decode()
	self.guild_rank = MsgAdapter.ReadInt()
	self.guild_score = MsgAdapter.ReadInt()
	self.kill_score = MsgAdapter.ReadInt()
	self.total_score = MsgAdapter.ReadInt()
	self.assist_count = MsgAdapter.ReadInt()
end

-- 仙盟战据点被攻击
SCXianMengZhanDefendAreaBeAttackNotice =  SCXianMengZhanDefendAreaBeAttackNotice or BaseClass(BaseProtocolStruct)
function SCXianMengZhanDefendAreaBeAttackNotice:__init()
	self.msg_type = 4913
end

function SCXianMengZhanDefendAreaBeAttackNotice:Decode()
end

-- 仙盟战 连斩次数改变
SCXianmengzhanLianzhanChange =  SCXianmengzhanLianzhanChange or BaseClass(BaseProtocolStruct)
function SCXianmengzhanLianzhanChange:__init()
	self.msg_type = 4930
	self.obj_id = 0			--角色id
	self.lianzhan = 0		--连杀数
end

function SCXianmengzhanLianzhanChange:Decode()
	self.obj_id = MsgAdapter.ReadUShort()
	self.lianzhan = MsgAdapter.ReadShort()
end

-- 幸运转盘活动信息
SCLuckyRollActivityInfo = SCLuckyRollActivityInfo or BaseClass(BaseProtocolStruct)
function SCLuckyRollActivityInfo:__init()
	self.msg_type = 4934
	self.roll_times = 0
	self.gold_poll = 0
	self.reward_count = 0
	self.winner_list = {}
end

function SCLuckyRollActivityInfo:Decode()
	self.roll_times = MsgAdapter.ReadInt()
	self.gold_poll = MsgAdapter.ReadInt()
	self.reward_count = MsgAdapter.ReadInt()
	self.winner_list = {}
	for i = 1, self.reward_count do
		local vo = {}
		vo.user_id = MsgAdapter.ReadInt()
		vo.user_name = MsgAdapter.ReadStrN(32)
		vo.reward_type = MsgAdapter.ReadChar()
		vo.num = MsgAdapter.ReadChar()
		vo.item_id = MsgAdapter.ReadUShort()
		vo.gold = MsgAdapter.ReadInt()
		vo.time_stamp = MsgAdapter.ReadUInt()
		self.winner_list[i] = vo
	end

end

-- 幸运转盘奖励结果
SCLuckyRollActivityRollResult = SCLuckyRollActivityRollResult or BaseClass(BaseProtocolStruct)
function SCLuckyRollActivityRollResult:__init()
	self.msg_type = 4935
	self.reward_index = 0
end

function SCLuckyRollActivityRollResult:Decode()
	self.reward_index = MsgAdapter.ReadShort()
	MsgAdapter.ReadShort()
end

-- 仙盟战 盟主请求召唤
CSXianMengZhanGuildCall =  CSXianMengZhanGuildCall or BaseClass(BaseProtocolStruct)
function CSXianMengZhanGuildCall:__init()
	self.msg_type = 4953
	self.use_gold = 0

end

function CSXianMengZhanGuildCall:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.use_gold)
end

-- 仙盟战 成员响应召唤
CSXianMengZhanGuildFollow =  CSXianMengZhanGuildFollow or BaseClass(BaseProtocolStruct)
function CSXianMengZhanGuildFollow:__init()
	self.msg_type = 4954

end

function CSXianMengZhanGuildFollow:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

--充值信息
SCChongZhiInfo =  SCChongZhiInfo or BaseClass(BaseProtocolStruct)
function SCChongZhiInfo:__init()
	self.msg_type = 4914

	self.history_recharge = 0
	self.history_recharge_count = 0
	self.today_recharge = 0
	self.reward_flag = 0

	self.special_first_chongzhi_timestamp = 0
	self.is_daily_first_chongzhi_open = 0
	self.is_daily_first_chongzhi_fetch_reward = 0
	self.daily_total_chongzhi_fetch_reward_flag = 0
	self.daily_total_chongzhi_stage = 0
	self.daily_first_chongzhi_times = 0
	self.special_first_chongzhi_fetch_reward_flag = 0
	self.daily_total_chongzhi_stage_chongzhi = 0
	self.chongzhi_7day_reward_timestamp = 0
	self.chongzhi_7day_reward_fetch_day = 0
	self.daily_chongzhi_fetch_reward2_flag = 0
end

function SCChongZhiInfo:Decode()
	self.history_recharge = MsgAdapter.ReadLL()
	self.history_recharge_count = MsgAdapter.ReadInt()
	self.today_recharge = MsgAdapter.ReadInt()
	self.reward_flag = MsgAdapter.ReadInt()

	self.special_first_chongzhi_timestamp = MsgAdapter.ReadUInt()				--特殊首冲开始时间戳
	self.is_daily_first_chongzhi_open = MsgAdapter.ReadChar()					--每日首冲是否开启
	self.is_daily_first_chongzhi_fetch_reward = MsgAdapter.ReadChar()			--每日充值奖励是否已经领取
	self.daily_total_chongzhi_fetch_reward_flag = MsgAdapter.ReadShort()		--每日累计充值奖励领取标记
	self.daily_total_chongzhi_stage = MsgAdapter.ReadChar()						--累计充值当前阶段
	self.daily_first_chongzhi_times = MsgAdapter.ReadChar()        				--每日首冲累计次数（满7次有额外奖励）
	self.special_first_chongzhi_fetch_reward_flag = MsgAdapter.ReadChar()   	--特殊首冲领取标志
	self.zai_chongzhi_fetch_reward_flag = MsgAdapter.ReadChar()					--0未充值.1可领取.2已领取
	self.daily_total_chongzhi_stage_chongzhi = MsgAdapter.ReadInt()

	self.third_chongzhi_reward_flag = MsgAdapter.ReadChar()						--第三次充值状态（0 未充值，1 可领取，2 已领取）
	self.diff_weekday_chongzhi_is_open = MsgAdapter.ReadChar() 					--每日累充是否开启(星期几相关)
	self.diff_weekday_chongzhi_stage_fetch_flag = MsgAdapter.ReadShort()		--每日累充阶级奖励领取标记(星期几相关)
	self.diff_wd_chongzhi_value = MsgAdapter.ReadInt()							--每日累充额度(星期几相关)

	self.first_chongzhi_active_reward_flag = MsgAdapter.ReadUInt()			--首充奖励领取标记
	self.first_chongzhi_fetch_reward_flag = MsgAdapter.ReadShort()				--首充奖励领取标记
	self.daily_chongzhi_fetch_reward_flag = MsgAdapter.ReadShort()				--每日首充奖励领取标记
	self.daily_chongzhi_complete_days = MsgAdapter.ReadShort()					--每日首充完成天数
	self.daily_chongzhi_times_fetch_reward_flag = MsgAdapter.ReadShort()		--每日首充累计天数奖励标记

	self.chongzhi_7day_reward_timestamp =  MsgAdapter.ReadUInt()				-- 充值18元档次--七天返利达成时间
	self.chongzhi_7day_reward_fetch_day =  MsgAdapter.ReadShort()				-- 充值18元档次--七天返利领取天数
	self.chongzhi_7day_reward_is_fetch  =  MsgAdapter.ReadShort()               -- 充值18元档次--七天返利今天是否领取 0未领取 1已领取
	self.daily_chongzhi_fetch_reward2_flag = MsgAdapter.ReadShort()			    -- 每日首累计充值奖励2领取标记
	self.reserve_sh = MsgAdapter.ReadShort()
	self.daily_chongzhi_value =  MsgAdapter.ReadInt()							-- 每日首充金额					                -- 保留
end

-----------------------------1v1战场-----------------------------

--场景用户信息
SCChallengeFieldStatus =  SCChallengeFieldStatus or BaseClass(BaseProtocolStruct)
function SCChallengeFieldStatus:__init()
	self.msg_type = 4917
	self.scene_user_list = {}
	self.status = 0
	self.next_time = 0
end

function SCChallengeFieldStatus:Decode()
	self.scene_user_list = {}
	self.status = MsgAdapter.ReadInt()
	self.next_time = MsgAdapter.ReadUInt()
	for i=1,2 do
		local obj = {}
		obj.role_id = MsgAdapter.ReadInt()
		obj.obj_id = MsgAdapter.ReadUShort()
		obj.level = MsgAdapter.ReadShort()
		obj.name = MsgAdapter.ReadStrN(32)

		obj.camp = MsgAdapter.ReadChar()
		obj.prof = MsgAdapter.ReadChar()
		obj.avatar = MsgAdapter.ReadChar()
		obj.sex = MsgAdapter.ReadChar()

		obj.hp = MsgAdapter.ReadInt()
		obj.max_hp = MsgAdapter.ReadInt()
		obj.mp = MsgAdapter.ReadInt()
		obj.max_mp = MsgAdapter.ReadInt()
		obj.speed = MsgAdapter.ReadInt()

		obj.pos_x = MsgAdapter.ReadShort()
		obj.pos_y = MsgAdapter.ReadShort()

		obj.dir = MsgAdapter.ReadFloat()
		obj.distance = MsgAdapter.ReadFloat()

		obj.capability = MsgAdapter.ReadInt()

		obj.guild_id = MsgAdapter.ReadInt()
		obj.guild_name = MsgAdapter.ReadStrN(32)
		obj.guild_post = MsgAdapter.ReadChar()
		MsgAdapter.ReadChar()
		MsgAdapter.ReadShort()
		table.insert(self.scene_user_list, obj)
	end
end

--挑战列表信息和个人信息
SCChallengeFieldUserInfo =  SCChallengeFieldUserInfo or BaseClass(BaseProtocolStruct)
function SCChallengeFieldUserInfo:__init()
	self.msg_type = 4918
	self.user_info = {}
end

function SCChallengeFieldUserInfo:Decode()
	self.user_info = {}

	self.user_info.rank_pos = MsgAdapter.ReadInt()
	self.user_info.rank = self.user_info.rank_pos + 1
	self.user_info.curr_opponent_idx = MsgAdapter.ReadInt()
	self.user_info.join_times = MsgAdapter.ReadInt()
	self.user_info.buy_join_times = MsgAdapter.ReadInt()
	self.user_info.jifen = MsgAdapter.ReadInt()
	local flag = MsgAdapter.ReadInt()

	self.user_info.jifen_reward_flag = {}
	for i=0,31 do
		self.user_info.jifen_reward_flag[i] = (bit:_and(flag, bit:_lshift(1, i))) == 0
	end

	self.user_info.shengwang = MsgAdapter.ReadInt()
	self.user_info.reward_bind_gold = MsgAdapter.ReadInt()
	self.user_info.liansheng = MsgAdapter.ReadInt()

	local best_rank_pos = MsgAdapter.ReadInt()
	self.user_info.best_rank_pos = best_rank_pos + 1
	self.user_info.rank_list = {}

	for i=1,3 do
		local data = {}
		data.user_id = MsgAdapter.ReadInt()
		data.rank_pos = MsgAdapter.ReadInt()
		data.index = i - 1 						-- 真实索引与服务端对应
		data.rank = data.rank_pos + 1 			-- 界面显示排名用这个
		table.insert(self.user_info.rank_list, 1,data)
	end
	for k,v in pairs(self.user_info.rank_list) do
		if v.user_id ==  GameVoManager.Instance:GetMainRoleVo().role_id then
			self.user_info.rank_list[k] = nil
		end
	end
end

--排位变化通知
SCChallengeFieldOpponentRankPosChange =  SCChallengeFieldOpponentRankPosChange or BaseClass(BaseProtocolStruct)
function SCChallengeFieldOpponentRankPosChange:__init()
	self.msg_type = 4919
	self.user_id = 0
	self.rank_pos = 0
end

function SCChallengeFieldOpponentRankPosChange:Decode()
	self.user_id = MsgAdapter.ReadInt()
	self.rank_pos = MsgAdapter.ReadInt()
end

--战报
SCChallengeFieldReportInfo =  SCChallengeFieldReportInfo or BaseClass(BaseProtocolStruct)
function SCChallengeFieldReportInfo:__init()
	self.msg_type = 4920
	self.report_info = {}
end

function SCChallengeFieldReportInfo:Decode()
	self.report_info = {}
	local report_count = MsgAdapter.ReadInt()
	for i=1,report_count do
		local data = {}
		data.challenge_time = MsgAdapter.ReadUInt()
		data.target_uid = MsgAdapter.ReadInt()
		data.target_name = MsgAdapter.ReadStrN(32)
		data.is_sponsor = MsgAdapter.ReadChar()
		data.is_win = MsgAdapter.ReadChar()
		MsgAdapter.ReadShort()
		data.old_rankpos = MsgAdapter.ReadUShort()
		data.new_rankpos = MsgAdapter.ReadUShort()
		table.insert(self.report_info, data)
	end
	function SortFun(a, b)
		return a.challenge_time > b.challenge_time
	end
	if #self.report_info ~= 0 then
		table.sort(self.report_info, SortFun)
	end
end

--英雄榜
SCChallengeFieldRankInfo =  SCChallengeFieldRankInfo or BaseClass(BaseProtocolStruct)
function SCChallengeFieldRankInfo:__init()
	self.msg_type = 4921
	self.rank_info = {}
end

function SCChallengeFieldRankInfo:Decode()
	self.rank_info = {}
	for i=1,20 do
		local user_id = MsgAdapter.ReadUInt()
		local data = {}
		data.user_id = user_id
		data.capability = MsgAdapter.ReadInt()
		data.target_name = MsgAdapter.ReadStrN(32)
		data.sex = MsgAdapter.ReadChar()
		data.is_robot = MsgAdapter.ReadChar()
		MsgAdapter.ReadShort()
		data.rank = i
		if user_id ~= 0 then
			table.insert(self.rank_info, data)
		end
	end
end

--幸运排名
SCChallengeFieldLuckyPosInfo =  SCChallengeFieldLuckyPosInfo or BaseClass(BaseProtocolStruct)
function SCChallengeFieldLuckyPosInfo:__init()
	self.msg_type = 4922
	self.lucky_info = {}
end

function SCChallengeFieldLuckyPosInfo:Decode()
	self.lucky_info = {}
	self.last_lucky_info = {}

	local data
	for i=1,10 do
		data = {}
		data.rank_pos = MsgAdapter.ReadUInt()
		data.reward = Field1v1Data.Instance:GetXingYunRankRewardBySeq(i-1)
		data.is_last = false
		table.insert(self.lucky_info, data)
	end
	for i=1,10 do
		data = {}
		data.rank_pos = MsgAdapter.ReadUInt()
		data.user_id = MsgAdapter.ReadInt()
		data.user_name = MsgAdapter.ReadStrN(32)
		data.reward = Field1v1Data.Instance:GetXingYunRankRewardBySeq(i-1)
		data.is_last = true
		table.insert(self.last_lucky_info, data)
	end
end

-- 攻城战里购买武器，
CSGCZBuyWeaponReq =  CSGCZBuyWeaponReq or BaseClass(BaseProtocolStruct)
function CSGCZBuyWeaponReq:__init()
	self.msg_type = 4923
end

function CSGCZBuyWeaponReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)

	MsgAdapter.WriteInt(self.item_seq)  ---配置表里的
	MsgAdapter.WriteInt(self.num)
end





--玩家详细信息
SCChallengeFieldOpponentInfo =  SCChallengeFieldOpponentInfo or BaseClass(BaseProtocolStruct)
function SCChallengeFieldOpponentInfo:__init()
	self.msg_type = 4931
end

function SCChallengeFieldOpponentInfo:Decode()
	local role_count = MsgAdapter.ReadInt()
	for i=1,role_count do
		local role_vo = ProtocolStruct.ReadOpponentInfo()
		Field1v1Data.Instance:AddRoleInfo(role_vo)
	end
end

--斗法封神战败提示
SCChallengeFieldBeDefeatNotice =  SCChallengeFieldBeDefeatNotice or BaseClass(BaseProtocolStruct)
function SCChallengeFieldBeDefeatNotice:__init()
	self.msg_type = 4932
end

function SCChallengeFieldBeDefeatNotice:Encode()
end

--更新公告信息
SCUpdateNoticeInfo =  SCUpdateNoticeInfo or BaseClass(BaseProtocolStruct)
function SCUpdateNoticeInfo:__init()
	self.msg_type = 4936
end

function SCUpdateNoticeInfo:Decode()
	self.server_version = MsgAdapter.ReadInt()				-- 现在版本的版本号
	self.fetch_reward_version = MsgAdapter.ReadInt()		-- 前一个版本的版本号
end


--竞技场信息奖励元宝下发
SCChallengeFieldRewardGoldNotice =  SCChallengeFieldRewardGoldNotice or BaseClass(BaseProtocolStruct)
function SCChallengeFieldRewardGoldNotice:__init()
	self.msg_type = 4937
	self.user_info_gold = {}
end

function SCChallengeFieldRewardGoldNotice:Decode()
	self.user_info_gold = {}
	self.user_info_gold.reward_bind_gold = MsgAdapter.ReadInt()				-- 元宝数量
end


--请求领取封测活动奖励
CSCloseBetaActivityOperaReq =  CSCloseBetaActivityOperaReq or BaseClass(BaseProtocolStruct)
function CSCloseBetaActivityOperaReq:__init()
	self.msg_type = 4968

	self.opera_type = 0
	self.param_1 = 0
	self.param_2 = 0
	self.param_3 = 0
end

function CSCloseBetaActivityOperaReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)

	MsgAdapter.WriteShort(self.opera_type)
	MsgAdapter.WriteShort(self.param_1)
	MsgAdapter.WriteShort(self.param_2)
	MsgAdapter.WriteShort(self.param_3)
end

--封测活动信息
SCCloseBetaActivityInfo =  SCCloseBetaActivityInfo or BaseClass(BaseProtocolStruct)
function SCCloseBetaActivityInfo:__init()
	self.msg_type = 4933
end

function SCCloseBetaActivityInfo:Decode()
	self.has_fetch_login_reward = MsgAdapter.ReadChar()					-- 是否已经领取当日登录奖励
	self.has_fetch_guild_reward = MsgAdapter.ReadChar()					-- 是否已经领取仙盟奖励
	self.has_fetch_marry_reward = MsgAdapter.ReadChar()					-- 是否已经领取了结婚奖励
	self.has_fetch_online_reward = MsgAdapter.ReadChar()				-- 是否已经领取了当日的在线奖励
	self.fetch_uplevel_reward_flag = MsgAdapter.ReadInt()				-- 升级奖励领取标记
	self.join_activity_flag = MsgAdapter.ReadInt()						-- 参与活动标记
	self.fetch_activity_reward_flag = MsgAdapter.ReadInt()				-- 领取活动奖励标记
	self.expfb_satisfy_reward_cond_flag = MsgAdapter.ReadInt()			-- 经验本满足奖励条件标记
	self.expfb_fetch_reward_flag = MsgAdapter.ReadInt()					-- 经验本领取奖励标记
	self.equipfb_satisfy_reward_cond_flag = MsgAdapter.ReadInt()		-- 装备本满足奖励条件标记
	self.equipfb_fetch_reward_flag = MsgAdapter.ReadInt()				-- 装备本领取奖励标记
	self.tdfb_satisfy_reward_cond_flag = MsgAdapter.ReadInt()			-- 塔防本满足奖励条件标记
	self.tdfb_fetch_reward_flag = MsgAdapter.ReadInt()					-- 塔防本领取奖励标记
	self.challengefb_satisfy_reward_cond_flag = MsgAdapter.ReadInt()	-- 挑战本满足奖励条件标记
	self.challengefb_fetch_reeward_flag = MsgAdapter.ReadInt()			-- 挑战本领取奖励标记
	self.total_login_days = MsgAdapter.ReadInt()						-- 总共登录天数
	self.online_time = MsgAdapter.ReadInt()								-- 总共在线时间
end

--请求幸运列表
CSChallengeFieldGetLuckyInfo =  CSChallengeFieldGetLuckyInfo or BaseClass(BaseProtocolStruct)
function CSChallengeFieldGetLuckyInfo:__init()
	self.msg_type = 4963
end

function CSChallengeFieldGetLuckyInfo:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

--请求英雄榜
CSChallengeFieldGetRankInfo =  CSChallengeFieldGetRankInfo or BaseClass(BaseProtocolStruct)
function CSChallengeFieldGetRankInfo:__init()
	self.msg_type = 4962
end

function CSChallengeFieldGetRankInfo:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

--获得用户信息和战报
CSChallengeFieldGetUserInfo =  CSChallengeFieldGetUserInfo or BaseClass(BaseProtocolStruct)
function CSChallengeFieldGetUserInfo:__init()
	self.msg_type = 4958
end

function CSChallengeFieldGetUserInfo:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

--刷新挑战列表
CSChallengeFieldResetOpponentList =  CSChallengeFieldResetOpponentList or BaseClass(BaseProtocolStruct)
function CSChallengeFieldResetOpponentList:__init()
	self.msg_type = 4959
end

function CSChallengeFieldResetOpponentList:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

--挑战请求
CSChallengeFieldFightReq =  CSChallengeFieldFightReq or BaseClass(BaseProtocolStruct)
function CSChallengeFieldFightReq:__init()
	self.msg_type = 4960

	self.opponent_index = 0
	self.ignore_rank_pos = 0
	self.is_auto_buy = 0
	self.rank_pos = 0
end

function CSChallengeFieldFightReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)

	MsgAdapter.WriteShort(self.opponent_index)
	MsgAdapter.WriteChar(self.ignore_rank_pos)
	MsgAdapter.WriteChar(self.is_auto_buy)
	MsgAdapter.WriteInt(self.rank_pos)
end

--领取积分奖励
CSChallengeFieldFetchJifenRewardReq =  CSChallengeFieldFetchJifenRewardReq or BaseClass(BaseProtocolStruct)
function CSChallengeFieldFetchJifenRewardReq:__init()
	self.msg_type = 4961
	self.reward_seq = 0
end

function CSChallengeFieldFetchJifenRewardReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)

	MsgAdapter.WriteShort(self.reward_seq)
	MsgAdapter.WriteShort(0)
end

--领取声望
CSChallengeFieldFetchShengwang =  CSChallengeFieldFetchShengwang or BaseClass(BaseProtocolStruct)
function CSChallengeFieldFetchShengwang:__init()
	self.msg_type = 4965
	self.reward_seq = 0
end

function CSChallengeFieldFetchShengwang:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

--购买挑战次数
CSChallengeFieldBuyJoinTimes =  CSChallengeFieldBuyJoinTimes or BaseClass(BaseProtocolStruct)
function CSChallengeFieldBuyJoinTimes:__init()
	self.msg_type = 4966
	self.reward_seq = 0
end

function CSChallengeFieldBuyJoinTimes:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

--获取玩家详细信息
CSChallengeFieldGetOpponentInfo =  CSChallengeFieldGetOpponentInfo or BaseClass(BaseProtocolStruct)
function CSChallengeFieldGetOpponentInfo:__init()
	self.msg_type = 4967
	self.type = 0
end

function CSChallengeFieldGetOpponentInfo:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.type)
	MsgAdapter.WriteShort(0)
end

--幸运转盘活动操作请求
CSLuckyRollActivityOperaReq =  CSLuckyRollActivityOperaReq or BaseClass(BaseProtocolStruct)
function CSLuckyRollActivityOperaReq:__init()
	self.msg_type = 4969
	self.opera_type = 0 	--0、获取信息 1、摇奖请求 2.领取额外奖励
end

function CSLuckyRollActivityOperaReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.opera_type)
	MsgAdapter.WriteShort(0)
end


-- 更新公告领取奖励请求
CSUpdateNoticeFetchReward =  CSUpdateNoticeFetchReward or BaseClass(BaseProtocolStruct)
function CSUpdateNoticeFetchReward:__init()
	self.msg_type = 4970
end

function CSUpdateNoticeFetchReward:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

-- 登录时下发答题次数
SCQuestionAnswerTimes =  SCQuestionAnswerTimes or BaseClass(BaseProtocolStruct)
function SCQuestionAnswerTimes:__init()
	self.msg_type = 4929

	self.answer_times = 0
end

function SCQuestionAnswerTimes:Decode()
	self.answer_times = MsgAdapter.ReadInt()
end

-- 星座遗迹信息
SCXingzuoYijiChangeBoxAndBoss =  SCXingzuoYijiChangeBoxAndBoss or BaseClass(BaseProtocolStruct)
function SCXingzuoYijiChangeBoxAndBoss:__init()
	self.msg_type = 4941
end

function SCXingzuoYijiChangeBoxAndBoss:Decode()
	self.now_boss_num = MsgAdapter.ReadShort()
	self.now_box_num = MsgAdapter.ReadShort()
	self.gather_box_num_list = {}
	for i = 1, 4 do
		self.gather_box_num_list[i] = MsgAdapter.ReadShort()
	end
	self.next_boss_refresh_time = MsgAdapter.ReadUInt()
end

--请求开服活动领取信息
CSOpenGameActivityFetchReward =  CSOpenGameActivityFetchReward or BaseClass(BaseProtocolStruct)
function CSOpenGameActivityFetchReward:__init()
	self.msg_type = 4957
	self.reward_type = 0
	self.seq = 0
end

function CSOpenGameActivityFetchReward:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.reward_type)
	MsgAdapter.WriteShort(self.seq)
end

--请求开服活动信息
CSOpenGameActivityInfoReq =  CSOpenGameActivityInfoReq or BaseClass(BaseProtocolStruct)
function CSOpenGameActivityInfoReq:__init()
	self.msg_type = 4956
end

function CSOpenGameActivityInfoReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end