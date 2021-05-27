--=====================================请求===========================================
-- 开始抽奖(返回 138 1)
CSStartOnlineReward = CSStartOnlineReward or BaseClass(BaseProtocolStruct)
function CSStartOnlineReward:__init()
	self:InitMsgType(138,1)
	self.index = 0				--抽奖索引, 从1开始
end

function CSStartOnlineReward:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.index)
end

-- 请求下发奖品(返回 138 2)
CSGetOnlineReward = CSGetOnlineReward or BaseClass(BaseProtocolStruct)
function CSGetOnlineReward:__init()
	self:InitMsgType(138,2)
	self.index = 0
end 

function CSGetOnlineReward:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.index)
end

-- 请求领取在线奖励信息(返回 138 4)
CSOnlineRewardInfo = CSOnlineRewardInfo or BaseClass(BaseProtocolStruct)
function CSOnlineRewardInfo:__init()
	self:InitMsgType(138,4)
end 

function CSOnlineRewardInfo:Encode()
	self:WriteBegin()
end

--=====================================下发===========================================
-- 抽奖返回结果
SCOnlineRewardResult = SCOnlineRewardResult or BaseClass(BaseProtocolStruct)
function SCOnlineRewardResult:__init()
	self:InitMsgType(138, 1)
	self.draw_index = 0
	self.reward_index = 0
end

function SCOnlineRewardResult:Decode()
	self.draw_index = MsgAdapter.ReadUChar()
	self.reward_index = MsgAdapter.ReadUChar()
end

-- 下发奖品
SCGetOnlineReward = SCGetOnlineReward or BaseClass(BaseProtocolStruct)
function SCGetOnlineReward:__init()
	self:InitMsgType(138, 2)
	self.result = 0 
end

function SCGetOnlineReward:Decode()
	self.result = MsgAdapter.ReadUInt()
end

-- 领取在线奖励信息
SCOnlineRewardInfo = SCOnlineRewardInfo or BaseClass(BaseProtocolStruct)
function SCOnlineRewardInfo:__init()
	self:InitMsgType(138, 4)
	self.online_time = 0
	self.online_reward_mark = 0
	self.reward_item_index_list = {}
end

function SCOnlineRewardInfo:Decode()
	self.online_time = MsgAdapter.ReadUInt()
	self.online_reward_mark = MsgAdapter.ReadUInt()
	-- for i = 1, MsgAdapter.ReadUChar() do
	-- 	local data = {}
	-- 	data.draw_index = MsgAdapter.ReadUChar()
	-- 	data.item_index = MsgAdapter.ReadUChar()
	-- 	self.reward_item_index_list[i] = data
	-- end
end