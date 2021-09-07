-- 9022 特殊场景临时变身
CSBianshenOnDieReq = CSBianshenOnDieReq or BaseClass(BaseProtocolStruct)

function CSBianshenOnDieReq:__init()
	self.msg_type = 9022
end

function CSBianshenOnDieReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end



--9023 特殊场景临时变身信息
SCBianshenInfo = SCBianshenInfo or BaseClass(BaseProtocolStruct)

function SCBianshenInfo:__init()
	self.msg_type = 9023
	self.cur_die_times = 0
end

function SCBianshenInfo:Decode()
	self.cur_die_times = MsgAdapter.ReadShort() 		-- 当前死亡次数（变身后清零）
	MsgAdapter.ReadShort()
end

-- 9024 领取神级奖
CSShenjiSkillFetchRewardReq = CSShenjiSkillFetchRewardReq or BaseClass(BaseProtocolStruct)
function CSShenjiSkillFetchRewardReq:__init()
	self.msg_type = 9024
	self.req_type = 0
	self.param_1 = 0
end

function CSShenjiSkillFetchRewardReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.req_type)
	MsgAdapter.WriteShort(self.param_1)
end



--9025 神级技能信息
SCShenjiSkillInfo = SCShenjiSkillInfo or BaseClass(BaseProtocolStruct)
function SCShenjiSkillInfo:__init()
	self.msg_type = 9025
	self.has_fatch_reward = 0
	self.camp_jungong = 0
end

function SCShenjiSkillInfo:Decode()
	self.has_fatch_reward = MsgAdapter.ReadChar()
	MsgAdapter.ReadChar()
	MsgAdapter.ReadShort()
	self.camp_jungong = MsgAdapter.ReadInt()
end