-- 灵玉操作
CSLingyuOperate = CSLingyuOperate or BaseClass(BaseProtocolStruct)
function CSLingyuOperate:__init()
	self.msg_type = 15100
end

function CSLingyuOperate:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.operate)
	MsgAdapter.WriteInt(self.param1)
	MsgAdapter.WriteInt(self.param2)
	MsgAdapter.WriteInt(self.param3)
end

-- 灵玉信息
SCLingyuInfo = SCLingyuInfo or BaseClass(BaseProtocolStruct)
function SCLingyuInfo:__init()
	self.msg_type = 15101
end

function SCLingyuInfo:Decode()
	self.starlevel_t = {}
	for i=0, 11 do
		self.starlevel_t[i] = {}
		for k=0, 5 do
			self.starlevel_t[i][k] = MsgAdapter.ReadShort()
		end
	end
end

-- 天仙阁信息
SCTianxiangeInfo = SCTianxiangeInfo or BaseClass(BaseProtocolStruct)
function SCTianxiangeInfo:__init()
	self.msg_type = 15102
end

function SCTianxiangeInfo:Decode()
	self.level = MsgAdapter.ReadInt()
end

-- 天仙阁场景信息
SCTianxiangeSceneInfo = SCTianxiangeSceneInfo or BaseClass(BaseProtocolStruct)
function SCTianxiangeSceneInfo:__init()
	self.msg_type = 15103
end

function SCTianxiangeSceneInfo:Decode()
	self.level = MsgAdapter.ReadInt()
	self.time_out_stamp = MsgAdapter.ReadUInt()
	self.is_finish = MsgAdapter.ReadChar()
	self.is_pass = MsgAdapter.ReadChar()
	self.pass_time_s = MsgAdapter.ReadUShort()
end

-- 挑战副本操作
CSChallengeFbOperate = CSChallengeFbOperate or BaseClass(BaseProtocolStruct)
function CSChallengeFbOperate:__init()
	self.msg_type = 15104
	self.operate = 0
end

function CSChallengeFbOperate:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.operate)
	MsgAdapter.WriteInt(self.param1 or 0)
	MsgAdapter.WriteInt(self.param2 or 0)
	MsgAdapter.WriteInt(self.param3 or 0)
end

-- 挑战副本信息
SCNewChallengeFbInfo = SCNewChallengeFbInfo or BaseClass(BaseProtocolStruct)
function SCNewChallengeFbInfo:__init()
	self.msg_type = 15105
end

function SCNewChallengeFbInfo:Decode()
	self.join_times = MsgAdapter.ReadChar()
	self.buy_join_times = MsgAdapter.ReadChar()
	self.item_buy_join_times = MsgAdapter.ReadChar()
	self.free_autofb_times = MsgAdapter.ReadChar()
	self.level_t = {}
	local prev_open = 1
	local prev_pass = 1
	for i = 0, ChallengeFb.MAX_LEVEL - 1 do
		self.level_t[i] = {}
		self.level_t[i].is_pass = MsgAdapter.ReadChar()
		self.level_t[i].fight_layer = MsgAdapter.ReadChar()
		MsgAdapter.ReadShort(0)
		-- 是否开启 (1:开启，-1： 不开启，-1： 不开启，不显示条件)
		if prev_open ~= 1 then
			self.level_t[i].open_type = -2
		elseif self.level_t[i].is_pass == 1 or prev_pass == 1 then
			self.level_t[i].open_type = 1
		else
			self.level_t[i].open_type = -1
		end
		prev_open = self.level_t[i].open_type
		prev_pass = self.level_t[i].is_pass
	end
end

-- 挑战副本 扫荡结果
SCChallengeAutoResult = SCChallengeAutoResult or BaseClass(BaseProtocolStruct)
function SCChallengeAutoResult:__init()
	self.msg_type = 15106
	self.reward_item_list = {}
end

function SCChallengeAutoResult:Decode()
	self.reward_coin = MsgAdapter.ReadInt()
	self.reward_exp = MsgAdapter.ReadInt()
	local count = MsgAdapter.ReadInt()
	self.reward_item_list = {}
	for i = 1, count do
		local vo = {}
		vo.item_id = MsgAdapter.ReadUShort()
		vo.num = MsgAdapter.ReadShort()
		vo.is_bind = MsgAdapter.ReadInt()
		self.reward_item_list[i] = vo
	end
end

-- 挑战副本（灵玉副本）场景信息
SCChallengeSceneInfo = SCChallengeSceneInfo or BaseClass(BaseProtocolStruct)
function SCChallengeSceneInfo:__init()
	self.msg_type = 15107
end

function SCChallengeSceneInfo:Decode()
	self.level = MsgAdapter.ReadShort()
	self.layer = MsgAdapter.ReadShort()
	self.time_out_stamp = MsgAdapter.ReadUInt()
	self.is_finish = MsgAdapter.ReadChar()
	self.is_pass = MsgAdapter.ReadChar()
	self.pass_time_s = MsgAdapter.ReadUShort()
end

