--勋章信息
SCAllXunZhangInfo = SCAllXunZhangInfo or BaseClass(BaseProtocolStruct)
function SCAllXunZhangInfo:__init()
	self.msg_type = 5800
end

function SCAllXunZhangInfo:Decode()
	self.level_list = {}
	for i=0,5 do
		self.level_list[i] = MsgAdapter.ReadShort()
	end
end

--勋章升级
CSXunZhangUplevelReq = CSXunZhangUplevelReq or BaseClass(BaseProtocolStruct)
function CSXunZhangUplevelReq:__init()
	self.msg_type = 5801
	self.xunzhang_id = 0
	self.is_only_bind = 0
end

function CSXunZhangUplevelReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.xunzhang_id)
	MsgAdapter.WriteInt(self.is_only_bind)
end

--至宝信息
SCAllZhiBaoInfo = SCAllZhiBaoInfo or BaseClass(BaseProtocolStruct)
function SCAllZhiBaoInfo:__init()
	self.msg_type = 5805
end

function SCAllZhiBaoInfo:Decode()
	self.exp = MsgAdapter.ReadInt()
	self.level = MsgAdapter.ReadShort()
	self.use_image = MsgAdapter.ReadShort()
	self.huanhua_using_type = MsgAdapter.ReadShort()

	local list_count = MsgAdapter.ReadShort()
	self.huanhua_level_list = {}
	for i=0,list_count - 1 do
		self.huanhua_level_list[i] = MsgAdapter.ReadShort()
	end
end

--至宝升级
CSZhiBaoUplevel = CSZhiBaoUplevel or BaseClass(BaseProtocolStruct)
function CSZhiBaoUplevel:__init()
	self.msg_type = 5806
end

function CSZhiBaoUplevel:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

--使用形象
CSZhiBaoUseImage = CSZhiBaoUseImage or BaseClass(BaseProtocolStruct)
function CSZhiBaoUseImage:__init()
	self.msg_type = 5807
	self.use_image = 0
end

function CSZhiBaoUseImage:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.use_image)
end

--激活幻化形象 0、激活 1、升级 2、使用
CSZhiBaoHuanHua = CSZhiBaoHuanHua or BaseClass(BaseProtocolStruct)
function CSZhiBaoHuanHua:__init()
	self.msg_type = 5808
	self.big_type = 0
	self.type = 0
end

function CSZhiBaoHuanHua:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.big_type)
	MsgAdapter.WriteInt(self.type)
end

--至宝攻击
SCZhiBaoAttack = SCZhiBaoAttack or BaseClass(BaseProtocolStruct)
function SCZhiBaoAttack:__init()
	self.msg_type = 5852
end

function SCZhiBaoAttack:Decode()
	self.attacker_id = MsgAdapter.ReadUShort()
	self.target_id = MsgAdapter.ReadUShort()
	self.skill_index = MsgAdapter.ReadShort()		-- skill_idx：  天雷：0，雷阵：1；
	self.is_baoji = MsgAdapter.ReadShort()			-- is_baoji：  否：0，是：1；
	self.hurt = MsgAdapter.ReadInt()
end