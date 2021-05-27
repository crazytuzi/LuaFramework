--===================================请求==================================

-- 读取一封邮件
CSReadMailReq = CSReadMailReq or BaseClass(BaseProtocolStruct)
function CSReadMailReq:__init()
	self:InitMsgType(64, 1)
	self.mail_id = 0
end

function CSReadMailReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUInt(self.mail_id)
end

-- 删除邮件
CSMailDelReq = CSMailDelReq or BaseClass(BaseProtocolStruct)
function CSMailDelReq:__init()
	self:InitMsgType(64, 2)
	self.mail_id_list = {}
end

function CSMailDelReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(#self.mail_id_list)
	for i, v in ipairs(self.mail_id_list) do
		MsgAdapter.WriteUInt(v)
	end
end

-- 提取奖励
CSMailGetRewardReq = CSMailGetRewardReq or BaseClass(BaseProtocolStruct)
function CSMailGetRewardReq:__init()
	self:InitMsgType(64, 3)
	self.mail_id = 0
end

function CSMailGetRewardReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUInt(self.mail_id)
end

--加载所有邮件
CSAllMailAddReq = CSAllMailAddReq or BaseClass(BaseProtocolStruct)
function CSAllMailAddReq:__init()
	self:InitMsgType(64, 4)
end

function CSAllMailAddReq:Encode()
	self:WriteBegin()
end

CSAllMailAcceptReq = CSAllMailAcceptReq or BaseClass(BaseProtocolStruct)
function CSAllMailAcceptReq:__init()
	self:InitMsgType(64, 5)
end

function CSAllMailAcceptReq:Encode()
	self:WriteBegin()
end
--===================================下发==================================

-- 下发添加邮件结果
SCMailInfo = SCMailInfo or BaseClass(BaseProtocolStruct)
function SCMailInfo:__init()
	self:InitMsgType(64, 1)
	self.mail_id = 0
	self.mail_type = 0
	self.reward_type = 0
	self.is_read = 0
	self.is_get_reward = 0
	self.sender_id = 0
	self.title = ""
	self.reward_item = 0 
	self.send_time = 0
	self.mail_content_index = ""
	self.mail_content_spare = ""
	self.content_desc = ""
	self.item_data = nil
end

function SCMailInfo:Decode()
	self.mail_id = MsgAdapter.ReadUInt()
	self.mail_type = MsgAdapter.ReadUChar()
	self.reward_type = MsgAdapter.ReadUChar()
	self.is_read = MsgAdapter.ReadUChar()
	self.is_get_reward = MsgAdapter.ReadUChar()
	self.sender_id = MsgAdapter.ReadInt()
	self.title = MsgAdapter.ReadStr()
	self.reward_item = MsgAdapter.ReadInt()
	self.send_time = CommonReader.ReadServerUnixTime()
	if self.mail_type == 5 then
		self.mail_content_index = MsgAdapter.ReadStr()
	elseif self.mail_type == MailEventType.mailNewCrossRetBagItem then
		self.item_data = CommonReader.ReadItemData()
	else
		self.mail_content_spare = MsgAdapter.ReadStr()
	end
	self.content_desc = MsgAdapter.ReadStr()
end

-- 下发删除邮件结果
SCMailDelAck = SCMailDelAck or BaseClass(BaseProtocolStruct)
function SCMailDelAck:__init()
	self:InitMsgType(64, 2)
	self.mail_id = 0
end

function SCMailDelAck:Decode()
	self.mail_id = MsgAdapter.ReadUInt()
end

-- 下发查看邮件
SCMailReadAck = SCMailReadAck or BaseClass(BaseProtocolStruct)
function SCMailReadAck:__init()
	self:InitMsgType(64, 3)
	self.mail_id = 0
end

function SCMailReadAck:Decode()
	self.mail_id = MsgAdapter.ReadUInt()
end

-- 下发提取奖励
SCMailGetRewardAck = SCMailGetRewardAck or BaseClass(BaseProtocolStruct)
function SCMailGetRewardAck:__init()
	self:InitMsgType(64, 4)
	self.mail_id = 0
end

function SCMailGetRewardAck:Decode()
	self.mail_id = MsgAdapter.ReadUInt()
end

--下发加载邮件
SCMailLoading = SCMailLoading or BaseClass(BaseProtocolStruct)
function SCMailLoading:__init()
	self:InitMsgType(64, 5)
	self.mail_tab = {}
	self.total_packet_count = 0
	self.packet_idx = 0
end

function SCMailLoading:Decode()
	self.total_packet_count = MsgAdapter.ReadUShort()
	self.packet_idx = MsgAdapter.ReadUShort()
	local mail_count = MsgAdapter.ReadUShort()
	self.mail_tab = {}
	for i = 1, mail_count do
		local v = {}
		v.mail_id = MsgAdapter.ReadUInt()
		v.mail_type = MsgAdapter.ReadUChar()
		v.reward_type = MsgAdapter.ReadUChar()
		v.is_read = MsgAdapter.ReadUChar()
		v.is_get_reward = MsgAdapter.ReadUChar()
		v.sender_id = MsgAdapter.ReadInt()
		v.title = MsgAdapter.ReadStr()
		v.reward_item = MsgAdapter.ReadInt()
		v.send_time = CommonReader.ReadServerUnixTime()
		if v.mail_type == 5 then
			v.mail_content_index = MsgAdapter.ReadStr()
		elseif v.mail_type == MailEventType.mailNewCrossRetBagItem then
			v.item_data = CommonReader.ReadItemData()
		else
			v.mail_content_spare = MsgAdapter.ReadStr()
		end
		v.content_desc = MsgAdapter.ReadStr()
		self.mail_tab[i] = v
	end
end

--全部接收
SCGetALLMailReward = SCGetALLMailReward or BaseClass(BaseProtocolStruct)
function SCGetALLMailReward:__init()
	self:InitMsgType(64, 6)
	self.mail_item_list = {}
end

function SCGetALLMailReward:Decode()
	local mail_count = MsgAdapter.ReadUShort()
	self.mail_item_list = {}
	for i = 1, mail_count do
		local v = {}
		v.mail_id = MsgAdapter.ReadUInt()
		v.is_read = MsgAdapter.ReadUChar()
		v.is_get_reward = MsgAdapter.ReadUChar()
		self.mail_item_list[i] = v
	end
end