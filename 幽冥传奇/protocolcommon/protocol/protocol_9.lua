
-- 发聊天信息
CSChatReq = CSChatReq or BaseClass(BaseProtocolStruct)
function CSChatReq:__init()
	self:InitMsgType(9, 1)
	self.channel_type = 0
	self.content = ""
	self.content_type = 0
	self.identifying_code = 1			--(为0错误)
end

function CSChatReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.channel_type)
	MsgAdapter.WriteStr(self.content)
	MsgAdapter.WriteUChar(self.content_type)
	MsgAdapter.WriteUInt(self.identifying_code)
end

-- 发私聊
CSPrivateChatReq = CSPrivateChatReq or BaseClass(BaseProtocolStruct)
function CSPrivateChatReq:__init()
	self:InitMsgType(9, 2)
	self.target_name = ""
	self.content = ""
	self.content_type = 0
	self.identifying_code = 1			--(为0错误)
end

function CSPrivateChatReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteStr(self.target_name)
	MsgAdapter.WriteStr(self.content)
	MsgAdapter.WriteUChar(self.content_type)
	MsgAdapter.WriteUInt(self.identifying_code)
end

-- GM发公告
CSGMNoticeReq = CSGMNoticeReq or BaseClass(BaseProtocolStruct)
function CSGMNoticeReq:__init()
	self:InitMsgType(9, 3)
	self.content = ""
	self.size = 0
end

function CSGMNoticeReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteStr(self.content)
	MsgAdapter.WriteInt(self.size)
end

-- 提交游戏建议
CSGameProposalReq = CSGameProposalReq or BaseClass(BaseProtocolStruct)
function CSGameProposalReq:__init()
	self:InitMsgType(9, 5)
	self.proposal_type = 0
	self.title = ""
	self.content = ""
end

function CSGameProposalReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.proposal_type)
	MsgAdapter.WriteStr(self.title)
	MsgAdapter.WriteStr(self.content)
end


--=====================================下发=====================================

-- 发聊天信息
SCChannelChatAck = SCChannelChatAck or BaseClass(BaseProtocolStruct)
function SCChannelChatAck:__init()
	self:InitMsgType(9, 1)
	self.channel_type = 0
	self.role_id = 0
	self.name = ""
	self.content = ""
	self.sex = 0
	self.flag = 0
	self.zhuansheng = 0
	self.fengshen_lv = 0
	self.sbk_occupation = 0
	self.horn_num = 0
	self.identifying_code = 0
	self.camp_id = 0
	self.camp_occupation = 0
end

function SCChannelChatAck:Decode()
	self.channel_type = MsgAdapter.ReadUChar()
	self.role_id = MsgAdapter.ReadUInt()
	self.name = MsgAdapter.ReadStr()
	self.content = MsgAdapter.ReadStr()
	if self.channel_type == CHANNEL_TYPE.SYSTEM then
		self.sex = MsgAdapter.ReadUChar()
		self.flag = MsgAdapter.ReadUChar()
		self.zhuansheng = MsgAdapter.ReadUChar()
		self.fengshen_lv = MsgAdapter.ReadUChar()
		self.sbk_occupation = MsgAdapter.ReadUChar()
		self.vip = MsgAdapter.ReadUChar()
		self.content_type = MsgAdapter.ReadUChar()
		self.identifying_code = MsgAdapter.ReadUInt()
	elseif self.channel_type == CHANNEL_TYPE.HELP then
		self.sex = MsgAdapter.ReadUChar()
		self.flag = MsgAdapter.ReadUChar()					--(|=1 免费, |=2 vip)
		self.camp_id = MsgAdapter.ReadUChar()
		self.camp_occupation = MsgAdapter.ReadUChar()
		self.sbk_occupation = MsgAdapter.ReadUChar()
		self.vip = MsgAdapter.ReadUChar()
		self.content_type = MsgAdapter.ReadUChar()
		self.identifying_code = MsgAdapter.ReadUInt()
	else
		self.sex = MsgAdapter.ReadUChar()
		self.flag = MsgAdapter.ReadUChar()					--(|=1 是否为vip, |=8 是否免费, |=16 武林盟主, |=32 是否为名人堂, |=0x40 GM1级为指导员：聊天框加前缀 无视聊天等级)
		self.zhuansheng = MsgAdapter.ReadUChar()
		self.fengshen_lv = MsgAdapter.ReadUChar()
		self.sbk_occupation = MsgAdapter.ReadUChar()
		self.vip = MsgAdapter.ReadUChar()
		self.content_type = MsgAdapter.ReadUChar()
		self.identifying_code = MsgAdapter.ReadUInt()
	end
end

-- 系统提示信息
SCSystemTipsMsg = SCSystemTipsMsg or BaseClass(BaseProtocolStruct)
function SCSystemTipsMsg:__init()
	self:InitMsgType(9, 2)
	self.tips_type = 0
	self.content = ""
end

function SCSystemTipsMsg:Decode()
	self.tips_type = MsgAdapter.ReadUShort()
	self.content = MsgAdapter.ReadStr()
end

-- 私聊
SCPrivateChat = SCPrivateChat or BaseClass(BaseProtocolStruct)
function SCPrivateChat:__init()
	self:InitMsgType(9, 3)
	self.role_id = 0
	self.name = ""
	self.content = ""
	self.sex = 0
	self.flag = 0
	self.zhuansheng = 0
	self.fengshen_lv = 0
	self.is_mingrentang = 0
	self.vip = 0
	self.identifying_code = 0
end

function SCPrivateChat:Decode()
	self.role_id = MsgAdapter.ReadUInt()
	self.name = MsgAdapter.ReadStr()
	self.content = MsgAdapter.ReadStr()
	self.sex = MsgAdapter.ReadUChar()
	self.flag = MsgAdapter.ReadUChar()
	self.zhuansheng = MsgAdapter.ReadUChar()
	self.fengshen_lv = MsgAdapter.ReadUChar()
	self.is_mingrentang = MsgAdapter.ReadUChar()
	self.vip = MsgAdapter.ReadUChar()
	self.content_type = MsgAdapter.ReadUChar()
	self.identifying_code = MsgAdapter.ReadUInt()
end

-- 怪物在附近广播
SCMonsterNearBroadcast = SCMonsterNearBroadcast or BaseClass(BaseProtocolStruct)
function SCMonsterNearBroadcast:__init()
	self:InitMsgType(9, 4)
	self.obj_id = 0
	self.content = ""
	self.show_type = 0
end

function SCMonsterNearBroadcast:Decode()
	self.obj_id = MsgAdapter.ReadLL()
	self.content = MsgAdapter.ReadStr()
	self.show_type = MsgAdapter.ReadUChar()
end

-- 返回游戏建议提交的结果
SCGameProposalResult = SCGameProposalResult or BaseClass(BaseProtocolStruct)
function SCGameProposalResult:__init()
	self:InitMsgType(9, 7)
	self.result = 0 		--1成功
end

function SCGameProposalResult:Decode()
	self.result = MsgAdapter.ReadUChar()
	
end

-- 剩余喇叭数量
SCSurplusHornCount = SCSurplusHornCount or BaseClass(BaseProtocolStruct)
function SCSurplusHornCount:__init()
	self:InitMsgType(9, 8)
	self.count = 0
end

function SCSurplusHornCount:Decode()
	self.count = MsgAdapter.ReadUInt()
	
end

-- 根据频道id清除聊天信息
SCCleanUpChat = SCCleanUpChat or BaseClass(BaseProtocolStruct)
function SCCleanUpChat:__init()
	self:InitMsgType(9, 9)
	self.channel_id = 0
end

function SCCleanUpChat:Decode()
	self.channel_id = MsgAdapter.ReadUChar()
end