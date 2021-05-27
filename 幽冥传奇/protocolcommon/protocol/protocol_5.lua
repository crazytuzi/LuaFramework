
-- 请求技能数据
CSSkillInfoReq = CSSkillInfoReq or BaseClass(BaseProtocolStruct)
function CSSkillInfoReq:__init()
	self:InitMsgType(5, 1)
end

function CSSkillInfoReq:Encode()
	self:WriteBegin()
end

-- 使用技能
CSUseSkillReq = CSUseSkillReq or BaseClass(BaseProtocolStruct)
function CSUseSkillReq:__init()
	self:InitMsgType(5, 2)
	self.skill_id = 0
	self.obj_id = 0
	self.pos_x = 0
	self.pos_y = 0
	self.dir = 0
end

function CSUseSkillReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUShort(self.skill_id)
	MsgAdapter.WriteLL(self.obj_id)
	MsgAdapter.WriteUShort(self.pos_x)
	MsgAdapter.WriteUShort(self.pos_y)
	MsgAdapter.WriteUChar(self.dir)
end

-- 升级技能
CSUpSkillReq = CSUpSkillReq or BaseClass(BaseProtocolStruct)
function CSUpSkillReq:__init()
	self:InitMsgType(5, 3)
	self.skill_id = 0
end

function CSUpSkillReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUShort(self.skill_id)
end

-- 技能同步cd
CSSynSkillCDReq = CSSynSkillCDReq or BaseClass(BaseProtocolStruct)
function CSSynSkillCDReq:__init()
	self:InitMsgType(5, 4)
	self.skill_id = 0
end

function CSSynSkillCDReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUShort(self.skill_id)
end

-- 近身攻击
CSNearAttackReq = CSNearAttackReq or BaseClass(BaseProtocolStruct)
function CSNearAttackReq:__init()
	self:InitMsgType(5, 6)
	self.obj_id = 0
end

function CSNearAttackReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteLL(self.obj_id)
end

-- 开始吟唱
CSSkillReadingReq = CSSkillReadingReq or BaseClass(BaseProtocolStruct)
function CSSkillReadingReq:__init()
	self:InitMsgType(5, 7)
	self.skill_id = 0
	self.target_id = 0
	self.pos_x = 0
	self.pos_y = 0
	self.dir = 0
end

function CSSkillReadingReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUShort(self.skill_id)
	MsgAdapter.WriteLL(self.target_id)
	MsgAdapter.WriteUShort(self.pos_x)
	MsgAdapter.WriteUShort(self.pos_x)
	MsgAdapter.WriteUChar(self.dir)
end

-- 开始采集怪
CSCollectingReq = CSCollectingReq or BaseClass(BaseProtocolStruct)
function CSCollectingReq:__init()
	self:InitMsgType(5, 8)
	self.target_id = 0
	self.pos_x = 0
	self.pos_y = 0
	self.dir = 0
end

function CSCollectingReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteLL(self.target_id)
	MsgAdapter.WriteUShort(self.pos_x)
	MsgAdapter.WriteUShort(self.pos_x)
	MsgAdapter.WriteUChar(self.dir)
end

-- 删除技能的秘籍
CSDelSkillBookReq = CSDelSkillBookReq or BaseClass(BaseProtocolStruct)
function CSDelSkillBookReq:__init()
	self:InitMsgType(5, 9)
	self.skill_id = 0
end

function CSDelSkillBookReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUShort(self.skill_id)
end

-- 设置技能开启
CSLearnSkillBookReq = CSLearnSkillBookReq or BaseClass(BaseProtocolStruct)
function CSLearnSkillBookReq:__init()
	self:InitMsgType(5, 10)
	self.skill_id = 0
	self.is_unlock = 0		--1启用,0关闭
end

function CSLearnSkillBookReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUShort(self.skill_id)
	MsgAdapter.WriteUChar(self.is_unlock)
end

-- 学习秘籍
CSLearnSkillBookReq = CSLearnSkillBookReq or BaseClass(BaseProtocolStruct)
function CSLearnSkillBookReq:__init()
	self:InitMsgType(5, 11)
	self.skill_id = 0
	self.book_id = 0
end

function CSLearnSkillBookReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUShort(self.skill_id)
	MsgAdapter.WriteUShort(self.book_id)
end

-- 使用技能丹
CSUseSkillDanReq = CSUseSkillDanReq or BaseClass(BaseProtocolStruct)
function CSUseSkillDanReq:__init()
	self:InitMsgType(5, 12)
	self.skill_id = 0
end

function CSUseSkillDanReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUShort(self.skill_id)
end

--================================下发================================

-- 下发已经学习的技能列表
SCSkillListInfoAck = SCSkillListInfoAck or BaseClass(BaseProtocolStruct)
function SCSkillListInfoAck:__init()
	self:InitMsgType(5, 1)
	self.count = 0
	self.skill_list = {}
end

function SCSkillListInfoAck:Decode()
	self.count = MsgAdapter.ReadUChar()
	for i = 1, self.count do
		local vo = {}
		vo.skill_id = MsgAdapter.ReadUShort()
		vo.skill_level = MsgAdapter.ReadUChar()
		vo.book_stuff_id = MsgAdapter.ReadUShort()
		vo.skill_cd = CommonReader.ReadMsCD()
		vo.skill_exp = MsgAdapter.ReadInt()
		vo.book_limit_time = MsgAdapter.ReadUInt()
		vo.is_disable = MsgAdapter.ReadUChar()
		self.skill_list[i] = vo
	end
end

-- 升级技能的结果
SCUpSkillResult = SCUpSkillResult or BaseClass(BaseProtocolStruct)
function SCUpSkillResult:__init()
	self:InitMsgType(5, 2)
	self.skill_id = 0
	self.skill_level = 0
end

function SCUpSkillResult:Decode()
	self.skill_id = MsgAdapter.ReadUShort()
	self.skill_level = MsgAdapter.ReadUChar()
end

-- 学习秘籍返回
SCLearnSkillResult = SCLearnSkillResult or BaseClass(BaseProtocolStruct)
function SCLearnSkillResult:__init()
	self:InitMsgType(5, 3)
	self.skill_id = 0
	self.book_id = 0
	self.end_time = 0
end

function SCLearnSkillResult:Decode()
	self.skill_id = MsgAdapter.ReadUShort()
	self.book_id = MsgAdapter.ReadUShort()
	self.end_time = MsgAdapter.ReadUInt()
end

-- 技能的经验发生改变
SCSkillExpChange = SCSkillExpChange or BaseClass(BaseProtocolStruct)
function SCSkillExpChange:__init()
	self:InitMsgType(5, 4)
	self.skill_id = 0
	self.skill_exp = 0
end

function SCSkillExpChange:Decode()
	self.skill_id = MsgAdapter.ReadUShort()
	self.skill_exp = MsgAdapter.ReadUInt()
end

-- 临时删除一个技能的CD
SCTemporaryDelSkillCD = SCTemporaryDelSkillCD or BaseClass(BaseProtocolStruct)
function SCTemporaryDelSkillCD:__init()
	self:InitMsgType(5, 5)
	self.skill_id = 0
	self.skill_cd = 0
end

function SCTemporaryDelSkillCD:Decode()
	self.skill_id = MsgAdapter.ReadUShort()
	self.skill_cd = CommonReader.ReadMsCD()
end

-- 受到其他玩家攻击
SCBeAttacked = SCBeAttacked or BaseClass(BaseProtocolStruct)
function SCBeAttacked:__init()
	self:InitMsgType(5, 6)
	self.target_id = 0
end

function SCBeAttacked:Decode()
	self.target_id = MsgAdapter.ReadLL()
end

-- 自身给目标造成了伤害
SCAttackOutput = SCAttackOutput or BaseClass(BaseProtocolStruct)
function SCAttackOutput:__init()
	self:InitMsgType(5, 7)
	self.target_id = 0
	self.reduce_hp = 0
	self.sound_id = 0 				--没有为0
end

function SCAttackOutput:Decode()
	self.target_id = MsgAdapter.ReadLL()
	self.reduce_hp = MsgAdapter.ReadInt()
	self.sound_id = MsgAdapter.ReadUShort()
end

-- 停止或者启用一个技能
SCSkillSwitch = SCSkillSwitch or BaseClass(BaseProtocolStruct)
function SCSkillSwitch:__init()
	self:InitMsgType(5, 9)
	self.skill_id = 0
	self.switch = 0
end

function SCSkillSwitch:Decode()
	self.skill_id = MsgAdapter.ReadUShort()
	self.switch = MsgAdapter.ReadUChar()
end

-- 删除技能的秘籍
SCDelSkillBook = SCDelSkillBook or BaseClass(BaseProtocolStruct)
function SCDelSkillBook:__init()
	self:InitMsgType(5, 10)
	self.skill_id = 0
end

function SCDelSkillBook:Decode()
	self.skill_id = MsgAdapter.ReadUShort()
end

-- 遗忘一个技能
SCForgetSkill = SCForgetSkill or BaseClass(BaseProtocolStruct)
function SCForgetSkill:__init()
	self:InitMsgType(5, 11)
	self.skill_id = 0
end

function SCForgetSkill:Decode()
	self.skill_id = MsgAdapter.ReadUShort()
end

-- 设置技能的冷却时间
SCSetSkillCD = SCSetSkillCD or BaseClass(BaseProtocolStruct)
function SCSetSkillCD:__init()
	self:InitMsgType(5, 12)
	self.skill_id = 0
	self.skill_level = 0
	self.skill_cd = 0
end

function SCSetSkillCD:Decode()
	self.skill_id = MsgAdapter.ReadUShort()
	self.skill_level = MsgAdapter.ReadUChar()
	self.skill_cd = CommonReader.ReadMsCD()
end

-- 采集怪物结束进度条进度
SCCollectingPer = SCCollectingPer or BaseClass(BaseProtocolStruct)
function SCCollectingPer:__init()
	self:InitMsgType(5, 14)
	self.dir = 0
	self.time = 0
end

function SCCollectingPer:Decode()
	self.dir = MsgAdapter.ReadUChar()
	self.time = MsgAdapter.ReadInt()
end

-- 播放引导性特效
SCOpenSkillReadingEff = SCOpenSkillReadingEff or BaseClass(BaseProtocolStruct)
function SCOpenSkillReadingEff:__init()
	self:InitMsgType(5, 15)
	self.id = 0
	self.value = 0
end

function SCOpenSkillReadingEff:Decode()
	self.id = MsgAdapter.ReadUInt()
	self.value = MsgAdapter.ReadUInt()
end

-- 广播使用烈焰神力技能
SCPerformFireSkill = SCPerformFireSkill or BaseClass(BaseProtocolStruct)
function SCPerformFireSkill:__init()
	self:InitMsgType(5, 16)
	self.atker_obj_id = 0
	self.beatker_obj_id = 0
	self.skill_id = 0
	self.skill_level = 0
end

function SCPerformFireSkill:Decode()
	self.atker_obj_id = MsgAdapter.ReadLL()
	self.beatker_obj_id = MsgAdapter.ReadLL()
	self.skill_id = MsgAdapter.ReadUShort()
	self.skill_level = MsgAdapter.ReadUChar()
end
