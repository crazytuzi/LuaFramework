
-- 登录返回
SCLoginAck = SCLoginAck or BaseClass(BaseProtocolStruct)
function SCLoginAck:__init()
	self.msg_type = 7000
end

function SCLoginAck:Decode()
	self.role_id = MsgAdapter.ReadInt()
	self.result = MsgAdapter.ReadShort()
	MsgAdapter.ReadChar()
	self.is_merged_server = MsgAdapter.ReadChar()
	self.scene_id = MsgAdapter.ReadInt()
	self.last_scene_id = MsgAdapter.ReadInt()
	self.key = MsgAdapter.ReadStrN(32)
	self.time = MsgAdapter.ReadUInt()
	self.gs_hostname = MsgAdapter.ReadStrN(64)
	self.gs_port = MsgAdapter.ReadUShort()
	self.gs_index = MsgAdapter.ReadUShort()
	self.server_time = MsgAdapter.ReadUInt()
end

-- 角色列表返回
SCRoleListAck = SCRoleListAck or BaseClass(BaseProtocolStruct)
function SCRoleListAck:__init()
	self.msg_type = 7001
end

function SCRoleListAck:Decode()
	self.server_time = MsgAdapter.ReadUInt()
	MsgAdapter.ReadShort()
	self.result = MsgAdapter.ReadShort()
	self.count = MsgAdapter.ReadInt()
	self.role_list = {}
	for i=1, self.count do
		self.role_list[i] = {}
		self.role_list[i].role_id = MsgAdapter.ReadInt()
		self.role_list[i].role_name = MsgAdapter.ReadStrN(32)
		self.role_list[i].avatar = MsgAdapter.ReadChar()
		self.role_list[i].sex = MsgAdapter.ReadChar()
		self.role_list[i].prof = MsgAdapter.ReadChar()
		self.role_list[i].country = MsgAdapter.ReadChar()
		self.role_list[i].level = MsgAdapter.ReadInt()
		self.role_list[i].create_time = MsgAdapter.ReadUInt()
		self.role_list[i].last_login_time = MsgAdapter.ReadUInt()
		self.role_list[i].wuqi_id = MsgAdapter.ReadUShort()
		self.role_list[i].shizhuang_wuqi = MsgAdapter.ReadChar()
		self.role_list[i].shizhuang_body = MsgAdapter.ReadChar()
		self.role_list[i].wing_used_imageid = MsgAdapter.ReadShort()
		self.role_list[i].halo_used_imageid = MsgAdapter.ReadShort()
		self.role_list[i].yaoshi_used_imageid = MsgAdapter.ReadShort()			--腰饰
		self.role_list[i].toushi_used_imageid = MsgAdapter.ReadShort()			--头饰
		self.role_list[i].qilinbi_used_imageid = MsgAdapter.ReadShort()			--麒麟臂
		self.role_list[i].mask_used_imageid = MsgAdapter.ReadShort()			--面具
	end
end

-- 合服后的角色列表返回
SCMergeRoleListAck = SCMergeRoleListAck or BaseClass(BaseProtocolStruct)
function SCMergeRoleListAck:__init()
	self.msg_type = 7005
end

function SCMergeRoleListAck:Decode()
	self.count = MsgAdapter.ReadInt()
	self.combine_role_list = {}
	for i = 1, self.count do
		local role_item = {}
		role_item.role_id = MsgAdapter.ReadInt()
		role_item.role_name = MsgAdapter.ReadStrN(32)
		role_item.avatar = MsgAdapter.ReadChar()
		role_item.sex = MsgAdapter.ReadChar()
		role_item.prof = MsgAdapter.ReadChar()
		role_item.country = MsgAdapter.ReadChar()
		role_item.level = MsgAdapter.ReadInt()
		role_item.result = MsgAdapter.ReadInt()
		role_item.create_time = MsgAdapter.ReadUInt()
		role_item.last_login_time = MsgAdapter.ReadUInt()
		role_item.wuqi_id = MsgAdapter.ReadUShort()
		role_item.shizhuang_wuqi = MsgAdapter.ReadChar()
		role_item.shizhuang_body = MsgAdapter.ReadChar()
		role_item.wing_used_imageid = MsgAdapter.ReadShort()
		role_item.halo_used_imageid = MsgAdapter.ReadShort()
		role_item.yaoshi_used_imageid = MsgAdapter.ReadShort()			--腰饰
		role_item.toushi_used_imageid = MsgAdapter.ReadShort()			--头饰
		role_item.qilinbi_used_imageid = MsgAdapter.ReadShort()			--麒麟臂
		role_item.mask_used_imageid = MsgAdapter.ReadShort()			--面具
		self.combine_role_list[i] = role_item
	end
end

-- 各职业人数信息
SCProfNumInfo = SCProfNumInfo or BaseClass(BaseProtocolStruct)
function SCProfNumInfo:__init()
	self.msg_type = 7006
end

function SCProfNumInfo:Decode()
	self.prof1_num = MsgAdapter.ReadInt()
	self.prof2_num = MsgAdapter.ReadInt()
	self.prof3_num = MsgAdapter.ReadInt()
	self.prof4_num = MsgAdapter.ReadInt()
end

-- 心跳包返回
SCLHeartBeat = SCLHeartBeat or BaseClass(BaseProtocolStruct)
function SCLHeartBeat:__init()
	self.msg_type = 7007
end

function SCLHeartBeat:Decode()
end

-- 心跳包
CSLHeartBeat = CSLHeartBeat or BaseClass(BaseProtocolStruct)
function CSLHeartBeat:__init()
	self.msg_type = 7052
	self.is_game_world_protocol = false
end

function CSLHeartBeat:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

-- 登录请求
CSLoginReq = CSLoginReq or BaseClass(BaseProtocolStruct)
function CSLoginReq:__init()
	self.msg_type = 7056
	self.is_game_world_protocol = false

	self.rand_1 = 0
	self.login_time = 0
	self.key = ""
	self.plat_name = ""
	self.rand_2 = 0
	self.plat_fcm = 0
	self.plat_server_id = 0
end

function CSLoginReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.rand_1)
	MsgAdapter.WriteUInt(self.login_time)
	MsgAdapter.WriteStrN(self.key, 32)
	MsgAdapter.WriteStrN(self.plat_name, 64)
	MsgAdapter.WriteInt(self.rand_2)
	MsgAdapter.WriteShort(0)
	MsgAdapter.WriteShort(self.plat_server_id)
end

-- 角色请求
CSRoleReq = CSRoleReq or BaseClass(BaseProtocolStruct)
function CSRoleReq:__init()
	self.msg_type = 7057

	self.rand_1 = 0
	self.login_time = 0
	self.key = ""
	self.plat_name = ""
	self.plat_server_id = 0
	self.plat_fcm = 0
	self.rand_2 = 0
	self.role_id = 0
end

function CSRoleReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.rand_1)
	MsgAdapter.WriteUInt(self.login_time)
	MsgAdapter.WriteStrN(self.key, 32)
	MsgAdapter.WriteStrN(self.plat_name, 64)
	MsgAdapter.WriteShort(self.plat_server_id)
	MsgAdapter.WriteChar(0)
	MsgAdapter.WriteChar(self.plat_fcm)
	MsgAdapter.WriteInt(self.rand_2)
	MsgAdapter.WriteInt(self.role_id)
end
