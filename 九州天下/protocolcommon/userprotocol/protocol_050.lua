SCDayCounterInfo = SCDayCounterInfo or BaseClass(BaseProtocolStruct)
function SCDayCounterInfo:__init()
	self.msg_type = 5000
end

function SCDayCounterInfo:Decode()
	self.daycount_list = {}
	for i = 0, 255 do
		self.daycount_list[i] = MsgAdapter.ReadUChar()
	end
end

-- 计算变更后调用
SCDayCounterItemInfo = SCDayCounterItemInfo or BaseClass(BaseProtocolStruct)
function SCDayCounterItemInfo:__init()
	self.msg_type = 5001
end

function SCDayCounterItemInfo:Decode()
	self.day_counter_id = MsgAdapter.ReadShort()
	self.day_counter_value = MsgAdapter.ReadShort()
end

-- 魔戒信息
SCMojieInfo = SCMojieInfo or BaseClass(BaseProtocolStruct)
function SCMojieInfo:__init()
	self.msg_type = 5050
	self.mojie_list = {}
end

function SCMojieInfo:Decode()
	self.mojie_list = {}
	for i = 0, MOJIE_MAX_TYPE - 1 do
		self.mojie_list[i] = {}
		self.mojie_list[i].mojie_skill_type = MsgAdapter.ReadShort()
		self.mojie_list[i].mojie_level = MsgAdapter.ReadShort()
		self.mojie_list[i].mojie_skill_id = MsgAdapter.ReadShort()
		self.mojie_list[i].mojie_skill_level = MsgAdapter.ReadShort()
	end
end

--请求魔戒信息
CSMojieGetInfo =  CSMojieGetInfo or BaseClass(BaseProtocolStruct)
function CSMojieGetInfo:__init()
	self.msg_type = 5075
end

function CSMojieGetInfo:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

--魔戒升级请求
CSMojieUplevelReq =  CSMojieUplevelReq or BaseClass(BaseProtocolStruct)
function CSMojieUplevelReq:__init()
	self.msg_type = 5076
	self.mojie_type = 0
	self.is_auto_buy = 0
end

function CSMojieUplevelReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.mojie_type)
	MsgAdapter.WriteChar(self.is_auto_buy)
	MsgAdapter.WriteChar(0)
	MsgAdapter.WriteShort(0)
end

--请求改变魔戒技能
CSMojieChangeSkillReq =  CSMojieChangeSkillReq or BaseClass(BaseProtocolStruct)
function CSMojieChangeSkillReq:__init()
	self.msg_type = 5077
	self.mojie_skill_id = 0
	self.mojie_skill_type = 0
	self.mojie_skill_level = 0
end

function CSMojieChangeSkillReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.mojie_skill_id)
	MsgAdapter.WriteShort(self.mojie_skill_type)
	MsgAdapter.WriteInt(self.mojie_skill_level)
end