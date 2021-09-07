--公会Boss红包详细信息
SCGuildBossRedBagInfo =  SCGuildBossRedBagInfo or BaseClass(BaseProtocolStruct)
function SCGuildBossRedBagInfo:__init()
	self.msg_type = 4300
end

function SCGuildBossRedBagInfo:Decode()
	self.total_gold_num = MsgAdapter.ReadInt()
	self.creater_uid = MsgAdapter.ReadInt()
	self.creater_name = MsgAdapter.ReadStrN(32)
	self.avatar_key_big = MsgAdapter.ReadInt()
	self.avatar_key_small = MsgAdapter.ReadInt()
	self.sex = MsgAdapter.ReadChar()
	self.prof = MsgAdapter.ReadChar()
	MsgAdapter.ReadShort()
	self.creater_guild_id = MsgAdapter.ReadInt()
	self.creater_guild_name = MsgAdapter.ReadStrN(32)
	self.fetch_user_count = MsgAdapter.ReadInt()
	self.log_list = {}
	for i = 1, self.fetch_user_count do
		self.log_list[i] = {}
		self.log_list[i].uid = MsgAdapter.ReadInt()
		self.log_list[i].gold_num = MsgAdapter.ReadInt()
		self.log_list[i].name = MsgAdapter.ReadStrN(32)
	end
	local index = 0
	local gold = 0
	for k,v in pairs(self.log_list) do
		if gold < v.gold_num then
			gold = v.gold_num
			index = k
		end
	end
	if index > 0 then
		self.log_list[index].is_luck = true
	end
end

CSGuildChangeAvatar = CSGuildChangeAvatar or BaseClass(BaseProtocolStruct)
function CSGuildChangeAvatar:__init()
	self.msg_type = 4302

	self.avatar_key_big = 0
	self.avatar_key_small = 0
end

function CSGuildChangeAvatar:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteUInt(self.avatar_key_big)
	MsgAdapter.WriteUInt(self.avatar_key_small)
end

--  公会抛骰子
SCGulidSaiziInfo =  SCGulidSaiziInfo or BaseClass(BaseProtocolStruct)
function SCGulidSaiziInfo:__init()
	self.msg_type = 4303
end

function SCGulidSaiziInfo:Decode()
 	self.today_guild_pao_saizi_times = MsgAdapter.ReadInt() --每天公会抛骰子次数
 	self.today_last_guild_pao_saizi_time = MsgAdapter.ReadLL()  -- 最后一次抛骰子时间
 	self.today_guild_saizi_score = MsgAdapter.ReadInt() -- 每天骰子积分
 	self.pao_saizi_num = MsgAdapter.ReadInt() -- 抛到什么分数
 	self.guild_saizi_rank_list = {}  -- 排行信息
 	for i = 1,GUILD_PAWN.MAX_MEMBER_COUNT do
 		self.guild_saizi_rank_list[i] = {}
		self.guild_saizi_rank_list[i].uid = MsgAdapter.ReadInt()
		self.guild_saizi_rank_list[i].score = MsgAdapter.ReadInt()
		self.guild_saizi_rank_list[i].name = MsgAdapter.ReadStrN(32)
 	end
end



-- 公会抛骰子
CSGulidPaoSaizi = CSGulidPaoSaizi or BaseClass(BaseProtocolStruct)
function CSGulidPaoSaizi:__init()
	self.msg_type = 4304
end

function CSGulidPaoSaizi:Encode()
	MsgAdapter.WriteBegin(self.msg_type)

end

-- 筛子请求信息
CSReqGulidSaiziInfo = CSReqGulidSaiziInfo or BaseClass(BaseProtocolStruct)
function CSReqGulidSaiziInfo:__init()
	self.msg_type = 4305
end

function CSReqGulidSaiziInfo:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

-- 请求公会签到信息
CSGuildSinginReq = CSGuildSinginReq or BaseClass(BaseProtocolStruct)
function CSGuildSinginReq:__init()
	self.msg_type = 4310
end

function CSGuildSinginReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.req_type)
	MsgAdapter.WriteShort(self.param1)
end

-- 公会签到信息
SCGuildSinginAllInfo = SCGuildSinginAllInfo or BaseClass(BaseProtocolStruct)
function SCGuildSinginAllInfo:__init()
	self.msg_type = 4315
end

function SCGuildSinginAllInfo:Decode()
	self.is_signin_today = MsgAdapter.ReadInt()						-- 今天是否已签到
	self.signin_count_month = MsgAdapter.ReadChar()					-- 月签到次数
	self.guild_signin_fetch_reward_flag = MsgAdapter.ReadChar()		-- 工会总签到
	self.guild_signin_count_today = MsgAdapter.ReadShort()			-- 工会总签到次
end

-- 国家同盟奖励
SCGuildYesterdayQiyunRankInfo = SCGuildYesterdayQiyunRankInfo or BaseClass(BaseProtocolStruct)
function SCGuildYesterdayQiyunRankInfo:__init()
	self.msg_type = 4316
end

function SCGuildYesterdayQiyunRankInfo:Decode()
	self.yesterday_qiyun_rank_is_fetch_login_reward = MsgAdapter.ReadChar()			-- 登陆奖励
	self.yesterday_qiyun_rank_is_fetch_zhanshi_reward = MsgAdapter.ReadChar()		-- 国家战事奖励
	self.war_even_complete_count = MsgAdapter.ReadShort()							-- 战事总次数
end