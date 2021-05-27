---------------------------------------------
-- 押镖
---------------------------------------------

--刷新个人镖车(返回145 24)
CSRefreshQualityReq = CSRefreshQualityReq or BaseClass(BaseProtocolStruct)
function CSRefreshQualityReq:__init()
	self:InitMsgType(145, 3)
	self.is_onekey_to_top = 0		--(uchar)是否一键四级镖车 1是,0否
	self.is_buy_token = 0			--(uchar)是否勾选元宝购买运镖令
end

function CSRefreshQualityReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.is_onekey_to_top)
	MsgAdapter.WriteUChar(self.is_buy_token)
end

--开始押镖(139 13, 145 21)
CSStartEscortingReq = CSStartEscortingReq or BaseClass(BaseProtocolStruct)
function CSStartEscortingReq:__init()
	self:InitMsgType(145, 4)
	self.is_buy_insure = 0				--(uchar)是否购买保险
end

function CSStartEscortingReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.is_buy_insure)
end

-- 请求交镖(返回139 13)
CSSubmitEscortReq = CSSubmitEscortReq or BaseClass(BaseProtocolStruct)
function CSSubmitEscortReq:__init()
	self:InitMsgType(145, 9)
end

function CSSubmitEscortReq:Encode()
	self:WriteBegin()
end

-- 请求改变押镖状态(返回 145 29)
CSChangeEscortStateReq = CSChangeEscortStateReq or BaseClass(BaseProtocolStruct)
function CSChangeEscortStateReq:__init()
	self:InitMsgType(145, 10)
	self.escort_state = 2 -- 1押镖, 2暂停押镖
end

function CSChangeEscortStateReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.escort_state)
end

-- 护送押镖面板请求放弃护送(返回 145 26)
CSQuitEscortReq = CSQuitEscortReq or BaseClass(BaseProtocolStruct)
function CSQuitEscortReq:__init()
	self:InitMsgType(145, 19)
end

function CSQuitEscortReq:Encode()
	self:WriteBegin()
end

-- 继续护送(145 27)
CSContinueEscortReq = CSContinueEscortReq or BaseClass(BaseProtocolStruct)
function CSContinueEscortReq:__init()
	self:InitMsgType(145, 22)
end

function CSContinueEscortReq:Encode()
	self:WriteBegin()
end

CSTransmitToCarReq = CSTransmitToCarReq or BaseClass(BaseProtocolStruct)
function CSTransmitToCarReq:__init()
	self:InitMsgType(145, 26)
end

function CSTransmitToCarReq:Encode()
	self:WriteBegin()
end

-- 购买鼓舞次数
CSBuyInspireReq = CSBuyInspireReq or BaseClass(BaseProtocolStruct)
function CSBuyInspireReq:__init()
	self:InitMsgType(145, 28)
	self.act_id = 0
end

function CSBuyInspireReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.act_id)
end

---------------------------------------------

-- 放弃护送结果
SCQuitEscortResultPost = SCQuitEscortResultPost or BaseClass(BaseProtocolStruct)
function SCQuitEscortResultPost:__init()
	self:InitMsgType(145, 26)
	self.result = 0			-- (uchar)1成功
end

function SCQuitEscortResultPost:Decode()
	self.result = MsgAdapter.ReadUChar()
end

-- 移动到镖车旁
SCMoveToEsCarNear = SCMoveToEsCarNear or BaseClass(BaseProtocolStruct)
function SCMoveToEsCarNear:__init()
	self:InitMsgType(145, 27)
	self.scene_id = 0										-- (int)场景id
	self.scene_name = ""									-- (string)场景名
	self.pos_x = 0											-- (ushort)x
	self.pos_y = 0											-- (ushort)y
end

function SCMoveToEsCarNear:Decode()
	self.scene_id = MsgAdapter.ReadInt()
	self.scene_name = MsgAdapter.ReadStr()
	self.pos_x = MsgAdapter.ReadUShort()
	self.pos_y = MsgAdapter.ReadUShort()
end

-- 镖车刷新品质
SCRefreshQualityResultPost = SCRefreshQualityResultPost or BaseClass(BaseProtocolStruct)
function SCRefreshQualityResultPost:__init()
	self:InitMsgType(145, 24)
	self.quality = 0									-- (uchar)镖车品质
	self.refr_time = 0									-- (uchar)刷新次数
end

function SCRefreshQualityResultPost:Decode()
	self.quality = MsgAdapter.ReadUChar()
	self.refr_time = MsgAdapter.ReadUChar()
end

-- 请求改变押镖状态结果, (如果失败不返回)
SCEscortStateChange = SCEscortStateChange or BaseClass(BaseProtocolStruct)
function SCEscortStateChange:__init()
	self:InitMsgType(145, 29)
	self.escort_state = 2									--(uchar)1押镖, 2暂停押镖
end

function SCEscortStateChange:Decode()
	self.escort_state = MsgAdapter.ReadUChar()
end


---------------------------------------------
-- 膜拜城主
---------------------------------------------

-- 膜拜或者鄙视(返回 145 13)
CSWorshipOrDespiseReq = CSWorshipOrDespiseReq or BaseClass(BaseProtocolStruct)
function CSWorshipOrDespiseReq:__init()
	self:InitMsgType(145, 5)
	self.type = 0								-- (uchar)支持类型 1=鄙视, 2=膜拜
end

function CSWorshipOrDespiseReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.type)
end

-- 膜拜刷新倍率(返回 145 28)
CSWorshipRefreshRateReq = CSWorshipRefreshRateReq or BaseClass(BaseProtocolStruct)
function CSWorshipRefreshRateReq:__init()
	self:InitMsgType(145, 6)
	self.money_type = 1							-- (uchar)金钱1=绑金, 2=元宝
end

function CSWorshipRefreshRateReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.money_type)
end

-- 进行膜拜城主泡点活动(返回 145 21)
CSWorshipChatelainReq = CSWorshipChatelainReq or BaseClass(BaseProtocolStruct)
function CSWorshipChatelainReq:__init()
	self:InitMsgType(145, 25)
end

function CSWorshipChatelainReq:Encode()
	self:WriteBegin()
end

-- 领取城主累计元宝
CSWorshipReceiveRewardsReq = CSWorshipReceiveRewardsReq or BaseClass(BaseProtocolStruct)
function CSWorshipReceiveRewardsReq:__init()
	self:InitMsgType(145, 27)
end

function CSWorshipReceiveRewardsReq:Encode()
	self:WriteBegin()
end

---------------------------------------------

-- 鄙视或膜拜
SCWorshipOrDespisePost = SCWorshipOrDespisePost or BaseClass(BaseProtocolStruct)
function SCWorshipOrDespisePost:__init()
	self:InitMsgType(145, 13)
	self.despise_per = 0								-- (uchar)鄙视百分比
	self.worship_per = 0								-- (uchar)膜拜百分比
	self.cur_times = 0									-- (uchar)当前膜拜/鄙视次数
	self.this_time_exp = 0								-- (uint)此次膜拜的经验
	self.total_exp = 0									-- (uint)膜拜的总经验
	self.award_count = 0								-- (int)城主奖金数
end

function SCWorshipOrDespisePost:Decode()
	self.despise_per = MsgAdapter.ReadUChar()
	self.worship_per = MsgAdapter.ReadUChar()
	self.cur_times = MsgAdapter.ReadUChar()
	self.award_count = MsgAdapter.ReadInt()
end

-- 膜拜刷新奖励
SCWorshipRefreAward = SCWorshipRefreAward or BaseClass(BaseProtocolStruct)
function SCWorshipRefreAward:__init()
	self:InitMsgType(145, 28)
	self.award_index = 0			-- (uchar)奖励索引
end

function SCWorshipRefreAward:Decode()
	self.award_index = MsgAdapter.ReadUChar()
end

-- 领取城主累计元宝返回结果
SCWorshipReceiveAward = SCWorshipReceiveAward or BaseClass(BaseProtocolStruct)
function SCWorshipReceiveAward:__init()
	self:InitMsgType(145, 31)
	self.is_receive = 0		    	-- (uchar)1已领取, 0未领取
end

function SCWorshipReceiveAward:Decode()
	self.is_receive = MsgAdapter.ReadUChar()
end


---------------------------------------------
-- 活动请求
---------------------------------------------

-- 退出活动
CSExitActivity = CSExitActivity or BaseClass(BaseProtocolStruct)
function CSExitActivity:__init()
	self:InitMsgType(145, 20)
	self.act_id = 0
end

function CSExitActivity:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUInt(self.act_id)
end


---------------------------------------------
-- 活动下发
---------------------------------------------

-- 参与活动的活动信息
SCParticipateActivity  = SCParticipateActivity or BaseClass(BaseProtocolStruct)
function SCParticipateActivity:__init()
	self:InitMsgType(145, 20)
	self.act_id = 0				--(uint)活动id
	self.left_sec = 0			--(uint)返回剩余秒数
end

function SCParticipateActivity:Decode()
	self.act_id = MsgAdapter.ReadUInt()
	if self.act_id == DAILY_ACTIVITY_TYPE.BI_GUAN then
		self.left_sec = MsgAdapter.ReadUInt()
	end
end

--  更新活动数据
SCRefreActivityData = SCRefreActivityData or BaseClass(BaseProtocolStruct)
function SCRefreActivityData:__init()
	self:InitMsgType(145, 21)
	self.act_id = 0					-- (uint)活动id
	self.act_data_t = {}			-- 活动数据表
end

function SCRefreActivityData:Decode()
	self.act_id = MsgAdapter.ReadUInt()

	self.act_data_t = {act_id = self.act_id}
	if self.act_id == DAILY_ACTIVITY_TYPE.JU_MO then
		self.act_data_t.act_left_time = MsgAdapter.ReadUInt()
	elseif self.act_id == DAILY_ACTIVITY_TYPE.BI_GUAN then -- 闭关修炼
		self.act_data_t.act_left_time = MsgAdapter.ReadUInt()
		self.act_data_t.total_revenue = MsgAdapter.ReadStr()
	elseif self.act_id == DAILY_ACTIVITY_TYPE.DUO_BAO_QI_BING then -- 夺宝奇兵
		self.act_data_t.total_revenue = MsgAdapter.ReadStr()
		self.act_data_t.act_left_time= MsgAdapter.ReadInt()
		self.act_data_t.index = MsgAdapter.ReadUChar()
	elseif self.act_id == DAILY_ACTIVITY_TYPE.HANG_HUI then -- 行会闯关
		self.act_data_t.param_count = MsgAdapter.ReadUChar()
		-- 1关数, 2剩余时间
		for i = 1, self.act_data_t.param_count do
			self.act_data_t[i] = MsgAdapter.ReadInt()
		end
	elseif self.act_id == DAILY_ACTIVITY_TYPE.GONG_CHENG then -- 攻城战
		self.act_data_t.ensure_left_time = MsgAdapter.ReadUInt() 			--定归剩余时间
		self.act_data_t.guild_name = MsgAdapter.ReadStr()					--归属行会
		self.act_data_t.act_left_time = MsgAdapter.ReadUInt()				--活动剩余时间
	elseif self.act_id == DAILY_ACTIVITY_TYPE.MO_BAI then -- 膜拜
		self.act_data_t.total_revenue = MsgAdapter.ReadStr()
		self.act_data_t.act_left_time = MsgAdapter.ReadUInt()				--活动剩余时间
	elseif self.act_id == DAILY_ACTIVITY_TYPE.WULIN_ZHENG_BA then -- 武林争霸
		self.act_data_t.param_count = MsgAdapter.ReadUChar()
		for i = 1, self.act_data_t.param_count do
			self.act_data_t[i] = MsgAdapter.ReadInt()
		end
	elseif self.act_id == DAILY_ACTIVITY_TYPE.YUAN_BAO then -- 元宝嘉年华
		self.act_data_t.param_count = MsgAdapter.ReadUChar()
		self.act_data_t.wave_num = MsgAdapter.ReadInt()
		self.act_data_t.left_time = MsgAdapter.ReadInt()
		self.act_data_t.act_left_time = MsgAdapter.ReadInt()
	elseif self.act_id == DAILY_ACTIVITY_TYPE.YA_SONG then -- 押镖
		self.act_data_t.car_name = MsgAdapter.ReadStr()	
		self.act_data_t.is_buy_insure = MsgAdapter.ReadUChar()				--是否买了保险
		self.act_data_t.esc_left_time = MsgAdapter.ReadInt()				--镖车剩余时间
		self.act_data_t.set_esc_left_time = Status.NowTime
		self.act_data_t.is_double = MsgAdapter.ReadUChar()					--是否双倍活动
		self.act_data_t.act_left_time = MsgAdapter.ReadInt()				--活动剩余时间
		self.act_data_t.set_act_left_time = Status.NowTime
		self.act_data_t.max_hp = MsgAdapter.ReadInt() 						--镖车maxhp
		self.act_data_t.award_id = MsgAdapter.ReadChar() 					-- 奖励档次id
		MsgAdapter.ReadChar()-- 剩余押镖次数
	elseif self.act_id == DAILY_ACTIVITY_TYPE.HANG_HUI_BOSS then -- 行会BOSS
		self.act_data_t.boss_order = MsgAdapter.ReadInt()		-- 第几个boss
		self.act_data_t.act_left_time = MsgAdapter.ReadInt()	-- 剩余时间
		self.act_data_t.set_act_left_time = Status.NowTime
		self.act_data_t.inspire_times = MsgAdapter.ReadInt()	-- 鼓舞次数
		self.act_data_t.ranking_count = MsgAdapter.ReadInt()	-- 行会数量
		self.act_data_t.rakning_list = {}
		for i=1, self.act_data_t.ranking_count do
			self.act_data_t.rakning_list[i] = {
				rank = MsgAdapter.ReadInt(), -- 第几名
				id = MsgAdapter.ReadInt(), -- 行会id
				score = MsgAdapter.ReadInt(),-- 积分
				name = MsgAdapter.ReadStr(),-- 行会名字
			}
		end
	elseif self.act_id == DAILY_ACTIVITY_TYPE.ZHEN_YING then -- 阵营战
		self.act_data_t.my_score = MsgAdapter.ReadInt()
		self.act_data_t.act_left_time = MsgAdapter.ReadInt()
		self.act_data_t.set_act_left_time = Status.NowTime
		self.act_data_t.ranking_count = MsgAdapter.ReadUChar()
		self.act_data_t.rakning_list = {}
		for i = 1, self.act_data_t.ranking_count do
			self.act_data_t.rakning_list[i] = {
				name = MsgAdapter.ReadStr(),
				score = MsgAdapter.ReadInt(),
			}
		end
	elseif self.act_id == DAILY_ACTIVITY_TYPE.SHI_JIE_BOSS then -- 世界BOSS
		self.act_data_t.act_left_time = MsgAdapter.ReadInt()	-- 剩余时间
		self.act_data_t.set_act_left_time = Status.NowTime
		self.act_data_t.inspire_times = MsgAdapter.ReadUChar()	-- 鼓舞次数
		self.act_data_t.my_score = MsgAdapter.ReadInt() 		-- 我的积分
		self.act_data_t.ranking_count = MsgAdapter.ReadUChar() 	-- 排行榜数量
		self.act_data_t.rakning_list = {}
		for i = 1, self.act_data_t.ranking_count do
			self.act_data_t.rakning_list[i] = {
				name = MsgAdapter.ReadStr(),  -- 玩家名字
				score = MsgAdapter.ReadInt(), -- 积分
			}
		end
	end
end

-- 退出活动
SCExitActivity = SCExitActivity or BaseClass(BaseProtocolStruct)
function SCExitActivity:__init()
	self:InitMsgType(145, 22)
	self.act_id = 0
end

function SCExitActivity:Decode()
	self.act_id = MsgAdapter.ReadUInt()
end

-- 镖车当前血量
SCHuSongCarHpAck = SCHuSongCarHpAck or BaseClass(BaseProtocolStruct)
function SCHuSongCarHpAck:__init()
	self:InitMsgType(145, 30)
	self.car_cur_hp = 0
end

function SCHuSongCarHpAck:Decode()
	self.car_cur_hp = MsgAdapter.ReadUInt()
end


-- 下发购买鼓舞次数结果
SCBuyInspirResultse = SCBuyInspirResultse or BaseClass(BaseProtocolStruct)
function SCBuyInspirResultse:__init()
	self:InitMsgType(145, 32)
	self.act_id = 0
	self.times = 0
end

function SCBuyInspirResultse:Decode()
	self.act_id = MsgAdapter.ReadUChar()
	self.inspire_times = MsgAdapter.ReadUChar()
end

-- 更新世界boss排行榜数据
SCUpdateWorldBossRanking = SCUpdateWorldBossRanking or BaseClass(BaseProtocolStruct)
function SCUpdateWorldBossRanking:__init()
	self:InitMsgType(145, 33)
	self.ranking_count = 0
	self.rakning_list = {}
end

function SCUpdateWorldBossRanking:Decode()
	self.ranking_count = MsgAdapter.ReadUChar()
	self.rakning_list = {}
	for i = 1, self.ranking_count do
		self.rakning_list[i] = {
			name = MsgAdapter.ReadStr(),
			score = MsgAdapter.ReadInt(),
		}
	end
end

-- 更新世界boss排行榜自己的积分
SCUpdateWorldBossMyScore = SCUpdateWorldBossMyScore or BaseClass(BaseProtocolStruct)
function SCUpdateWorldBossMyScore:__init()
	self:InitMsgType(145, 34)
	self.my_score = 0
end

function SCUpdateWorldBossMyScore:Decode()
	self.my_score = MsgAdapter.ReadUInt()
end

-- 接收已击杀世界boss
SCWorldBossDie = SCWorldBossDie or BaseClass(BaseProtocolStruct)
function SCWorldBossDie:__init()
	self:InitMsgType(145, 35)
end

function SCWorldBossDie:Decode()
end

-- 下发热血霸者排行数据
SCReXueBossRanks = SCReXueBossRanks or BaseClass(BaseProtocolStruct)
function SCReXueBossRanks:__init()
	self:InitMsgType(145, 36)
	self.ranks = {}
end

function SCReXueBossRanks:Decode()
	self.ranks = {}
	for i = 1, MsgAdapter.ReadUChar() do
		self.ranks[i] = {
			rank = MsgAdapter.ReadUShort(),
			name = MsgAdapter.ReadStr(),
			score = MsgAdapter.ReadInt(),
		}
	end
end

-- 下发热血霸者自身排行 积分
SCReXueBossScore = SCReXueBossScore or BaseClass(BaseProtocolStruct)
function SCReXueBossScore:__init()
	self:InitMsgType(145, 37)
	self.rank = 0
	self.score = 0
end

function SCReXueBossScore:Decode()	
	self.rank = MsgAdapter.ReadUShort()
	self.score = MsgAdapter.ReadInt()
end

-- 下发热血霸者boss状态
SCReXueBossState = SCReXueBossState or BaseClass(BaseProtocolStruct)
function SCReXueBossState:__init()
	self:InitMsgType(145, 38)
	self.boss_state = 0   -- boss状态, 1刷新, 2死亡
end

function SCReXueBossState:Decode()
	self.boss_state = MsgAdapter.ReadUChar()
end

-- 下发
SCEscortLeftTimes = SCEscortLeftTimes or BaseClass(BaseProtocolStruct)
function SCEscortLeftTimes:__init()
	self:InitMsgType(145, 39)
	self.left_times = 0   -- boss状态, 1刷新, 2死亡
end

function SCEscortLeftTimes:Decode()
	self.left_times = MsgAdapter.ReadUChar()
end
