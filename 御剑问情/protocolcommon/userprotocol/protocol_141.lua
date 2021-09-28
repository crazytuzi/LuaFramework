--跨服1v1匹配确认
SCCross1v1MatchAck = SCCross1v1MatchAck or BaseClass(BaseProtocolStruct)
function SCCross1v1MatchAck:__init()
	self.msg_type = 14100
end

function SCCross1v1MatchAck:Decode()
	self.result = MsgAdapter.ReadShort()
	MsgAdapter.ReadShort()
	self.match_end_left_time = MsgAdapter.ReadUInt()
end

--跨服1v1战斗记录
SCCross1v1WeekRecord = SCCross1v1WeekRecord or BaseClass(BaseProtocolStruct)
function SCCross1v1WeekRecord:__init()
	self.msg_type = 14101
end

function SCCross1v1WeekRecord:Decode()
	self.win_this_week = MsgAdapter.ReadShort()
	self.lose_this_week = MsgAdapter.ReadShort()
	local record_count = MsgAdapter.ReadInt()
	self.kf_1v1_news = {}
	for i=1, record_count do
		local vo = {}
		vo.result = MsgAdapter.ReadShort()
		MsgAdapter.ReadShort()
		vo.oppo_plat_type = MsgAdapter.ReadInt()
		vo.oppo_server_id = MsgAdapter.ReadInt()
		vo.oppo_role_uid = MsgAdapter.ReadInt()
		vo.oppo_capability = MsgAdapter.ReadInt()
		vo.oppo_name = MsgAdapter.ReadStrN(32)
		vo.add_score = MsgAdapter.ReadShort()
		vo.add_honor = MsgAdapter.ReadShort()
		self.kf_1v1_news[i] = vo
	end
end

--跨服1v1展示排行
SCCross1V1RankList = SCCross1V1RankList or BaseClass(BaseProtocolStruct)
function SCCross1V1RankList:__init()
	self.msg_type = 14102
end

function SCCross1V1RankList:Decode()
	local count = MsgAdapter.ReadInt()
	self.kf_1v1_show_rank = {}
	for i=1, count do
		local vo = {}
		vo.plat_type = MsgAdapter.ReadInt()
		vo.role_id = MsgAdapter.ReadInt()
		vo.oppo_server_id = MsgAdapter.ReadInt()
		vo.name = MsgAdapter.ReadStrN(32)
		vo.level = MsgAdapter.ReadShort()
		vo.prof = MsgAdapter.ReadChar()
		vo.sex = MsgAdapter.ReadChar()
		vo.score = MsgAdapter.ReadInt()
		vo.max_dur_win_count = MsgAdapter.ReadInt()
		vo.win_percent = MsgAdapter.ReadInt()
		vo.capability = MsgAdapter.ReadInt()
		vo.appearance = ProtocolStruct.ReadRoleAppearance()
		self.kf_1v1_show_rank[i] = vo
	end
end

--跨服1v1匹配结果
SCCross1v1MatchResult = SCCross1v1MatchResult or BaseClass(BaseProtocolStruct)
function SCCross1v1MatchResult:__init()
	self.msg_type = 14103
end

function SCCross1v1MatchResult:Decode()
	self.info = {}
	self.info.result = MsgAdapter.ReadShort()
	self.info.side = MsgAdapter.ReadShort()
	self.info.oppo_plat_type =  MsgAdapter.ReadInt()
	self.info.oppo_sever_id =  MsgAdapter.ReadInt()
	self.info.role_id = MsgAdapter.ReadInt()
	self.info.oppo_name = MsgAdapter.ReadStrN(32)
	self.info.fight_start_time = MsgAdapter.ReadUInt() + TimeCtrl.Instance:GetServerTime()
	self.info.prof = MsgAdapter.ReadChar()
	self.info.sex = MsgAdapter.ReadChar()
	self.info.camp = MsgAdapter.ReadChar()
	MsgAdapter.ReadChar()
	self.info.level = MsgAdapter.ReadInt()
	self.info.fight_end_time = MsgAdapter.ReadUInt() + TimeCtrl.Instance:GetServerTime()
	self.info.capability = MsgAdapter.ReadInt()
end

--跨服1v1挑战结果
SCCross1v1FightResult = SCCross1v1FightResult or BaseClass(BaseProtocolStruct)
function SCCross1v1FightResult:__init()
	self.msg_type = 14104
end

function SCCross1v1FightResult:Decode()
	self.info = {}
	self.info.result = MsgAdapter.ReadShort()
	MsgAdapter.ReadShort()
	self.info.week_win_times = MsgAdapter.ReadInt()
	self.info.week_lose_times =  MsgAdapter.ReadInt()
	self.info.week_score = MsgAdapter.ReadInt()
	self.info.this_honor = MsgAdapter.ReadInt()
	self.info.this_score = MsgAdapter.ReadInt()
	self.info.dur_win_count = MsgAdapter.ReadChar()
	self.info.max_dur_win_count = MsgAdapter.ReadChar()
	self.info.oppo_dur_win_count = MsgAdapter.ReadChar()
	MsgAdapter.ReadChar()
	self.info.self_hp_per = MsgAdapter.ReadShort()
	self.info.oppo_hp_per = MsgAdapter.ReadShort()
end

-- 跨服1v1匹配查询
CSCross1v1MatchQuery = CSCross1v1MatchQuery or BaseClass(BaseProtocolStruct)
function CSCross1v1MatchQuery:__init()
	self.msg_type = 14150
end

function CSCross1v1MatchQuery:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

-- 跨服1v1战斗记录查询
CSCross1v1WeekRecordQuery = CSCross1v1WeekRecordQuery or BaseClass(BaseProtocolStruct)
function CSCross1v1WeekRecordQuery:__init()
	self.msg_type = 14151
end

function CSCross1v1WeekRecordQuery:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

-- 跨服1v1展示排行查询
CSGetCross1V1RankList = CSGetCross1V1RankList or BaseClass(BaseProtocolStruct)
function CSGetCross1V1RankList:__init()
	self.msg_type = 14152
	self.rank_type = 0
end

function CSGetCross1V1RankList:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end