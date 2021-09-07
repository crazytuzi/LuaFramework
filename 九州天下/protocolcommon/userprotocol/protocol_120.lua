
SCCrossRandActivityStatus = SCCrossRandActivityStatus or BaseClass(BaseProtocolStruct)
function SCCrossRandActivityStatus:__init()
	self.msg_type = 12000

	self.activity_type = 0
	self.status = 0
	self.begin_time = 0
	self.end_time = 0
end

function SCCrossRandActivityStatus:Decode()
	
	self.activity_type = MsgAdapter.ReadShort()
	self.status = MsgAdapter.ReadShort()
	self.begin_time = MsgAdapter.ReadUInt()
	self.end_time = MsgAdapter.ReadUInt()
end

CSCrossRandActivityRequest = CSCrossRandActivityRequest or BaseClass(BaseProtocolStruct)
function CSCrossRandActivityRequest:__init()
	self.msg_type = 12001

	self.activity_type = 0
	self.opera_type = 0
	self.param_1 = 0
	self.param_2 = 0
	self.param_3 = 0
end

function CSCrossRandActivityRequest:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.activity_type)
	MsgAdapter.WriteShort(self.opera_type)
	MsgAdapter.WriteInt(self.param_1)
	MsgAdapter.WriteInt(self.param_2)
	MsgAdapter.WriteInt(self.param_3)
end

SCCrossRAChongzhiRankChongzhiInfo = SCCrossRAChongzhiRankChongzhiInfo or BaseClass(BaseProtocolStruct)
function SCCrossRAChongzhiRankChongzhiInfo:__init()
	self.msg_type = 12003

	self.total_chongzhi = 0
end

function SCCrossRAChongzhiRankChongzhiInfo:Decode()
	self.total_chongzhi =  MsgAdapter.ReadUInt()
end

SCCrossRAZhenYanMiBaoInfo = SCCrossRAZhenYanMiBaoInfo or BaseClass(BaseProtocolStruct)
function SCCrossRAZhenYanMiBaoInfo:__init()
	self.msg_type = 12005

	self.total_chongzhi = 0										-- 活动期间充值额度
	self.my_words = {}											-- 已选文字
	self.change_count = 0										-- 已改字次数
	self.lottery_cost = 0										-- 奖池现有金额
	self.guess_counts = {}										-- 全服猜人数
end

function SCCrossRAZhenYanMiBaoInfo:Decode()
	self.total_chongzhi = MsgAdapter.ReadUInt()

	self.my_words = {}
	for i = 0, COMMON_CONSTS.RARE_TREASURE_MAX - 1 do
		self.my_words[i] = MsgAdapter.ReadChar()
	end

	MsgAdapter.ReadChar()
	MsgAdapter.ReadChar()
	MsgAdapter.ReadChar()

	self.change_count = MsgAdapter.ReadUInt()
	self.lottery_cost = MsgAdapter.ReadUInt()

	self.guess_counts = {}
	for i = 0, COMMON_CONSTS.RARE_TREASURE_MAX - 1 do
		local data = {}
		for j = 0, COMMON_CONSTS.RARE_TREASURE_MAX - 1 do
			data[j] = MsgAdapter.ReadUInt()
		end
		self.guess_counts[i] = data
	end
end

SCCrossRAZhenYanMiBaoLotteryInfo = SCCrossRAZhenYanMiBaoLotteryInfo or BaseClass(BaseProtocolStruct)
function SCCrossRAZhenYanMiBaoLotteryInfo:__init()
	self.msg_type = 12006

	self.true_words = {}
	self.cur_pool = -1
	self.is_open = 0
end

function SCCrossRAZhenYanMiBaoLotteryInfo:Decode()
	self.true_words = {}
	for i = 0, COMMON_CONSTS.RARE_TREASURE_MAX - 1 do
		self.true_words[i] = MsgAdapter.ReadChar()
	end
	self.cur_pool = MsgAdapter.ReadChar()
	self.is_open = MsgAdapter.ReadChar()
	MsgAdapter.ReadChar()
end