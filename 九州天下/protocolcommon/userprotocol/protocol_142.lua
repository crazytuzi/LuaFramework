--跨服3V3匹配状态
SCCrossMultiuserChallengeMatchingState = SCCrossMultiuserChallengeMatchingState or BaseClass(BaseProtocolStruct)
function SCCrossMultiuserChallengeMatchingState:__init()
	self.msg_type = 14200
end

function SCCrossMultiuserChallengeMatchingState:Decode()
	self.matching_state = MsgAdapter.ReadInt()
	local user_count = MsgAdapter.ReadInt()
	self.user_list = {}
	for i = 1, user_count do
		local vo = {}
		vo.plat_type = MsgAdapter.ReadInt()
		vo.server_id = MsgAdapter.ReadInt()
		vo.role_id = MsgAdapter.ReadInt()
		vo.role_name = MsgAdapter.ReadStrN(32)
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

--跨服3V3排行
SCMultiuserChallengeRankList = SCMultiuserChallengeRankList or BaseClass(BaseProtocolStruct)
function SCMultiuserChallengeRankList:__init()
	self.msg_type = 14201
end

function SCMultiuserChallengeRankList:Decode()
	self.rank_type = MsgAdapter.ReadShort()
	local count = MsgAdapter.ReadShort()
	self.rank_list = {}
	for i = 1, count do
		local vo = {}
		vo.plat_type = MsgAdapter.ReadInt()
		vo.server_id = MsgAdapter.ReadInt()
		vo.role_id = MsgAdapter.ReadInt()
		vo.user_name = MsgAdapter.ReadStrN(32)
		vo.level = MsgAdapter.ReadShort()
		vo.prof = MsgAdapter.ReadChar()
		vo.sex = MsgAdapter.ReadChar()
		vo.match_total_count = MsgAdapter.ReadShort()
		vo.win_percent = MsgAdapter.ReadShort()
		vo.rank_value = MsgAdapter.ReadInt()
		vo.capability = MsgAdapter.ReadInt()
		self.rank_list[i] = vo
	end
end

--跨服3V3匹配通知
SCMultiuserChallengeHasMatchNotice = SCMultiuserChallengeHasMatchNotice or BaseClass(BaseProtocolStruct)
function SCMultiuserChallengeHasMatchNotice :__init()
	self.msg_type = 14202
end

function SCMultiuserChallengeHasMatchNotice :Decode()
	self.has_match = MsgAdapter.ReadInt()
end

-- 请求跨服3v3排行榜
CSGetMultiuserChallengeRankList = CSGetMultiuserChallengeRankList or BaseClass(BaseProtocolStruct)
function CSGetMultiuserChallengeRankList:__init()
	self.msg_type = 14250
	self.rank_type = 0
end

function CSGetMultiuserChallengeRankList:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.rank_type)
end

-- 请求跨服3v3是否有
CSCheckMultiuserChallengeHasMatch = CSCheckMultiuserChallengeHasMatch or BaseClass(BaseProtocolStruct)
function CSCheckMultiuserChallengeHasMatch:__init()
	self.msg_type = 14251
end

function CSCheckMultiuserChallengeHasMatch:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end