-- 仙盟驻地请求
CSGuildBackToStation = CSGuildBackToStation or BaseClass(BaseProtocolStruct)
function CSGuildBackToStation:__init()
	self.msg_type = 6264
	self.guild_id = 0
end

function CSGuildBackToStation:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.guild_id)
end

-- 新公会争霸 全局信息（广播）
SCGBGlobalInfoNew =  SCGBGlobalInfoNew or BaseClass(BaseProtocolStruct)
function SCGBGlobalInfoNew:__init()
	self.msg_type = 6255
end

function SCGBGlobalInfoNew:Decode()
	self.guild_score = MsgAdapter.ReadInt()
	self.guild_rank = MsgAdapter.ReadInt()
	self.is_finish = MsgAdapter.ReadChar()
	MsgAdapter.ReadChar()
	MsgAdapter.ReadShort()
	self.rank_count = MsgAdapter.ReadInt()
	self.rank_list = {}
	-- 服务端叫写死10个
	for i = 1, 10 do
		self.rank_list[i] = {}
		self.rank_list[i].guild_id = MsgAdapter.ReadInt()
		self.rank_list[i].score = MsgAdapter.ReadInt()
		self.rank_list[i].guild_name = MsgAdapter.ReadStrN(32)
	end
	self.hold_point_guild_list = {}
	for i = 1, GameEnum.GUILD_BATTLE_NEW_POINT_NUM do
		self.hold_point_guild_list[i] = {}
		self.hold_point_guild_list[i].guild_id = MsgAdapter.ReadInt()
		self.hold_point_guild_list[i].guild_name = MsgAdapter.ReadStrN(32)
		self.hold_point_guild_list[i].blood = MsgAdapter.ReadInt()
		self.hold_point_guild_list[i].max_blood = MsgAdapter.ReadInt()
	end
end

-- 新公会争霸 个人信息
SCGBRoleInfoNew = SCGBRoleInfoNew or BaseClass(BaseProtocolStruct)
function SCGBRoleInfoNew:__init()
	self.msg_type = 6256
end

function SCGBRoleInfoNew:Decode()
	self.kill_role_num = MsgAdapter.ReadInt()
	self.history_get_person_credit = MsgAdapter.ReadInt()
	self.is_add_hudun = MsgAdapter.ReadChar()
	self.sos_times = MsgAdapter.ReadChar()
	-- MsgAdapter.ReadChar()
	-- self.reserve2 = MsgAdapter.ReadShort()
end