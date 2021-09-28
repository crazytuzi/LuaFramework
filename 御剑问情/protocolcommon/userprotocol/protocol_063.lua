-- 玩家答题请求
CSQAAnswerReq = CSQAAnswerReq or BaseClass(BaseProtocolStruct)

function CSQAAnswerReq:__init()
	self.msg_type = 6300
	self.is_use_item = 0
	self.choose = 0
end

function CSQAAnswerReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.is_use_item)
	MsgAdapter.WriteShort(self.choose)
end

-- 玩家请求使用变身卡
CSQAUseCardReq = CSQAUseCardReq or BaseClass(BaseProtocolStruct)

function CSQAUseCardReq:__init()
	self.msg_type = 6301
	self.target_uid = 0
end

function CSQAUseCardReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.target_uid)
end

--请求答题榜首的信息
CSFirstPosReq = CSFirstPosReq or BaseClass(BaseProtocolStruct)
function CSFirstPosReq:__init()
	self.msg_type = 6302
end

function CSFirstPosReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

--返回题榜首的位置
SCSendFirstPos = SCSendFirstPos or BaseClass(BaseProtocolStruct)
function SCSendFirstPos:__init()
	self.msg_type = 6350
	self.pos_x = 0
	self.pos_y = 0
end

function SCSendFirstPos:Decode()
	self.pos_x = MsgAdapter.ReadInt()
	self.pos_y = MsgAdapter.ReadInt()
end

-- 获取答题排名信息
SCQARankInfo = SCQARankInfo or BaseClass(BaseProtocolStruct)

function SCQARankInfo:__init()
	self.msg_type = 6352
	self.self_score = 0
	self.self_rank = 0
	self.is_finish = 0
	self.reserve_1 = 0
	self.reserve_2 = 0
	self.RANK_NUM = 100
	self.rank_count = 0
	self.rank_list = {}
end

function SCQARankInfo:Decode()
	self.rank_list = {}
	self.self_score = MsgAdapter.ReadInt()
	self.self_rank = MsgAdapter.ReadInt()
	self.is_finish = MsgAdapter.ReadChar()
	self.reserve_1 = MsgAdapter.ReadChar()
	self.reserve_2 = MsgAdapter.ReadShort()
	self.rank_count = MsgAdapter.ReadInt()
	for i = 1, self.rank_count do
		self.rank_list[i] = {}
		self.rank_list[i].uid = MsgAdapter.ReadInt()
		self.rank_list[i].score = MsgAdapter.ReadInt()
		self.rank_list[i].name = MsgAdapter.ReadStrN(32)
	end
end

-- 获取玩家个人答题信息
SCQARoleInfo = SCQARoleInfo or BaseClass(BaseProtocolStruct)

function SCQARoleInfo:__init()
	self.msg_type = 6353
	self.notify_reason = 0
	self.question_right_count = 0
	self.question_wrong_count = 0
	self.curr_score = 0
	self.question_exp = 0
end

function SCQARoleInfo:Decode()
	self.notify_reason = MsgAdapter.ReadShort()
	self.question_right_count = MsgAdapter.ReadChar()
	self.question_wrong_count = MsgAdapter.ReadChar()
	self.curr_score = MsgAdapter.ReadInt()
	self.question_exp = MsgAdapter.ReadInt()
end

-- 获取答题内容
SCQAQuestionBroadcast = SCQAQuestionBroadcast or BaseClass(BaseProtocolStruct)

function SCQAQuestionBroadcast:__init()
	self.msg_type = 6354
	self.curr_question_begin_time = 0
	self.curr_question_end_time = 0
	self.broadcast_question_total = 0
	self.curr_question_id = 0
	self.is_exchange = 0
	self.curr_question_str = ""
	self.curr_answer0_desc_str = ""
	self.curr_answer1_desc_str = ""
end

function SCQAQuestionBroadcast:Decode()
	self.curr_question_begin_time = MsgAdapter.ReadUInt()
	self.curr_question_end_time = MsgAdapter.ReadUInt()
	self.broadcast_question_total = MsgAdapter.ReadShort()
	self.curr_question_id = MsgAdapter.ReadShort()
	self.is_exchange = MsgAdapter.ReadInt()
	self.curr_question_str = MsgAdapter.ReadStrN(128)
	self.curr_answer0_desc_str = MsgAdapter.ReadStrN(128)
	self.curr_answer1_desc_str = MsgAdapter.ReadStrN(128)
end

-- 玩家回答结果
SCQAnswerResult = SCQAnswerResult or BaseClass(BaseProtocolStruct)

function SCQAnswerResult:__init()
	self.msg_type = 6355
	self.result = 0
	self.right_result = 0
end

function SCQAnswerResult:Decode()
	self.result = MsgAdapter.ReadInt()
	self.right_result = MsgAdapter.ReadInt()
end