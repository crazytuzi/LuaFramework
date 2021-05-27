--===================================请求==================================

-- 获取成就的数据(返回28 1)
CSAchieveInfoReq = CSAchieveInfoReq or BaseClass(BaseProtocolStruct)
function CSAchieveInfoReq:__init()
	self:InitMsgType(28, 1)
end

function CSAchieveInfoReq:Encode()
	self:WriteBegin()
end

-- 获取成就的奖励(返回28 4)
CSAchieveRewardReq = CSAchieveRewardReq or BaseClass(BaseProtocolStruct)
function CSAchieveRewardReq:__init()
	self:InitMsgType(28, 2)
	self.achieve_id = 0
end

function CSAchieveRewardReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUShort(self.achieve_id)

end

--===================================下发==================================

-- 下发成就的数据
SCAchieveInfo = SCAchieveInfo or BaseClass(BaseProtocolStruct)
function SCAchieveInfo:__init()
	self:InitMsgType(28, 1)
	self.reward_flag_t = {}
	self.count = 0
	self.type_flag_t = {}
end

function SCAchieveInfo:Decode()
	for i = 1, 256 do
		self.reward_flag_t[i] = MsgAdapter.ReadUChar()
	end
	self.count = MsgAdapter.ReadUShort()
	for i = 1, self.count do
		local v = {}
		v.eventid = MsgAdapter.ReadUShort()
		v.counts = MsgAdapter.ReadInt()
		self.type_flag_t[i] = v
	end
end

-- 完成一个成就
SCFinishOneAchieve = SCFinishOneAchieve or BaseClass(BaseProtocolStruct)
function SCFinishOneAchieve:__init()
	self:InitMsgType(28, 2)
	self.achieve_id = 0
	self.badge_id = 0
end

function SCFinishOneAchieve:Decode()
	self.achieve_id = MsgAdapter.ReadUShort()
	self.badge_id = MsgAdapter.ReadUShort()
end

-- 成就一个事件触发了
SCAchieveFinishEventtRigger = SCAchieveFinishEventtRigger or BaseClass(BaseProtocolStruct)
function SCAchieveFinishEventtRigger:__init()
	self:InitMsgType(28, 3)
	self.eventid = 0
	self.achieve_count = 0
end

function SCAchieveFinishEventtRigger:Decode()
	self.eventid = MsgAdapter.ReadUShort()
	self.achieve_count = MsgAdapter.ReadInt()
end

-- 成就领取奖励的结果
SCAchieveRewardResult = SCAchieveRewardResult or BaseClass(BaseProtocolStruct)
function SCAchieveRewardResult:__init()
	self:InitMsgType(28, 4)
	self.achieve_id = 0
	self.result = 0
end

function SCAchieveRewardResult:Decode()
	self.achieve_id = MsgAdapter.ReadUShort()
	self.result = MsgAdapter.ReadUChar()
end

-- 下发称号的数据(现在没用)
-- SCAchieveRewardResult = SCAchieveRewardResult or BaseClass(BaseProtocolStruct)
-- function SCAchieveRewardResult:__init()
-- 	self:InitMsgType(28, 5)
-- end

-- function SCAchieveRewardResult:Decode()

-- end

-- 获得一个称号(现在没用)
SCAchieveAddTitle = SCAchieveAddTitle or BaseClass(BaseProtocolStruct)
function SCAchieveAddTitle:__init()
	self:InitMsgType(28, 6)
	self.title_id = 0
	self.over_time = 0
	self.title_name = ""
end

function SCAchieveAddTitle:Decode()
	self.title_id = MsgAdapter.ReadUShort()
	self.over_time = CommonReader.ReadServerUnixTime()
	self.title_name = MsgAdapter.ReadStr()
end

-- 失去一个称号(现在没用)
SCAchieveLoseTitle = SCAchieveLoseTitle or BaseClass(BaseProtocolStruct)
function SCAchieveLoseTitle:__init()
	self:InitMsgType(28, 7)
	self.title_id = 0
end

function SCAchieveLoseTitle:Decode()
	self.title_id = MsgAdapter.ReadUShort()
end

--下发徽章列表
SCAchieveBadgeList = SCAchieveBadgeList or BaseClass(BaseProtocolStruct)
function SCAchieveBadgeList:__init()
	self:InitMsgType(28, 8)
	self.count = 0
	self.badge_list = {}
end

function SCAchieveBadgeList:Decode()
	self.count = MsgAdapter.ReadUShort()
	self.badge_list = {}
end

-- 获得一个称号(现在没用)
SCAchieveGetTitle = SCAchieveGetTitle or BaseClass(BaseProtocolStruct)
function SCAchieveGetTitle:__init()
	self:InitMsgType(28, 9)
	self.title_name = 0
end

function SCAchieveGetTitle:Decode()
	self.title_name = MsgAdapter.ReadStr()
end

-- 限时称号信息
SCTimeLimitTitleInfo = SCTimeLimitTitleInfo or BaseClass(BaseProtocolStruct)
function SCTimeLimitTitleInfo:__init()
	self:InitMsgType(28, 11)
	self.title_id = 0		-- 头衔id
	self.over_time = 0		-- 过期时间戳, 0为已过期
end

function SCTimeLimitTitleInfo:Decode()
	self.title_id = MsgAdapter.ReadUShort()
	self.over_time = CommonReader.ReadServerUnixTime()
end
