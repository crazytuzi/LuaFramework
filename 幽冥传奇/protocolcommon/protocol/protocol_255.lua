-- 登录请求
CSLoginReq = CSLoginReq or BaseClass(BaseProtocolStruct)
function CSLoginReq:__init()
	self:InitMsgType(255, 1)
	self.account = ""
	self.password = ""
	self.server_span_id = 1
	self.server_id = 1
	self.sign = "ab6e03537c22c1b7f6763178a5882df7"
	self.identity = "000000198010100000"
	self.plat_info = ""
	self.dev_info = ""
end

function CSLoginReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteStr(self.account)
	MsgAdapter.WriteStr(self.password)
	MsgAdapter.WriteUInt(self.server_span_id)
	MsgAdapter.WriteUInt(self.server_id)
	MsgAdapter.WriteStr(self.sign)
	MsgAdapter.WriteStr(self.identity)
	MsgAdapter.WriteStr(self.plat_info)
	MsgAdapter.WriteStr(self.dev_info)
end

-- 创建帐号
CSCreateAccountReq = CSCreateAccountReq or BaseClass(BaseProtocolStruct)
function CSCreateAccountReq:__init()
	self:InitMsgType(255, 2)
	self.account = ""
	self.password = ""
	self.identity = "000000198010100000"
end

function CSCreateAccountReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteStr(self.account)
	MsgAdapter.WriteStr(self.password)
	MsgAdapter.WriteStr(self.identity)
end

-- 请求角色列表
CSRoleListReq = CSRoleListReq or BaseClass(BaseProtocolStruct)
function CSRoleListReq:__init()
	self:InitMsgType(255, 3)
end

function CSRoleListReq:Encode()
	self:WriteBegin()
end

-- 请求创建角色
CSCreateRoleReq = CSCreateRoleReq or BaseClass(BaseProtocolStruct)
function CSCreateRoleReq:__init()
	self:InitMsgType(255, 4)
	self.name = ""
	self.sex = 0
	self.prof = 0
	self.avatar = 0
	self.camp = 0
	self.spid = 0
	self.adid = 0
end

function CSCreateRoleReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteStr(self.name)
	MsgAdapter.WriteChar(self.sex)
	MsgAdapter.WriteChar(self.prof)
	MsgAdapter.WriteChar(self.avatar)
	MsgAdapter.WriteUChar(self.camp)
	MsgAdapter.WriteStr(self.spid)
	MsgAdapter.WriteInt(self.adid)
end

-- 请求删除角色
CSDelRoleReq = CSDelRoleReq or BaseClass(BaseProtocolStruct)
function CSDelRoleReq:__init()
	self:InitMsgType(255, 5)
	self.role_id = 0
end

function CSDelRoleReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUInt(self.role_id)
end

----------------------------------------------------------------------

-- 登录失败
SCLoginFailAck = SCLoginFailAck or BaseClass(BaseProtocolStruct)
function SCLoginFailAck:__init()
	self:InitMsgType(255, 1)
	self.error_code = 0
end

function SCLoginFailAck:Decode()
	self.error_code = MsgAdapter.ReadUChar()
end

-- 角色列表返回
SCRoleListAck = SCRoleListAck or BaseClass(BaseProtocolStruct)
function SCRoleListAck:__init()
	self:InitMsgType(255, 2)
	self.account_id = 0
	self.role_count = 0
	self.role_list = {}
end

function SCRoleListAck:Decode()
	self.account_id = MsgAdapter.ReadInt()
	self.role_count = MsgAdapter.ReadChar()
	self.role_list = {}
	local last_temp = {index = 1, time = 0}
	for i = 1, self.role_count do
		local role_info = {}
		role_info.role_id = MsgAdapter.ReadUInt()						-- 角色id
		role_info.role_name = MsgAdapter.ReadStr()						-- 角色名称
		role_info.avatar = MsgAdapter.ReadUChar()						-- 头像id
		role_info.sex = MsgAdapter.ReadUChar()							-- 性别
		role_info.level = MsgAdapter.ReadUInt()						-- 等级
		role_info.prof = MsgAdapter.ReadUChar()							-- 职业
		role_info.camp = MsgAdapter.ReadUChar()							-- 阵营
		role_info.cycle_level = MsgAdapter.ReadUChar()					-- 转生等级
		role_info.gods_level = MsgAdapter.ReadUChar()					-- 封神等级
		role_info.guild_name = MsgAdapter.ReadStr()						-- 工会名称
		role_info.status = MsgAdapter.ReadUChar()						-- 角色状态  status=0已删除, (status >> 2 & 1)==1 (bit:_and(status, 4) ~= 0) 表示这个是上次登陆的角色
		role_info.last_login_time = MsgAdapter.ReadUInt()
		if role_info.last_login_time > last_temp.time then
			last_temp.index = i
			last_temp.time = role_info.last_login_time
		end
		self.role_list[i] = role_info
	end
	local role = table.remove(self.role_list, last_temp.index)
	table.insert(self.role_list, 1 , role)
	self.last_role_index = MsgAdapter.ReadUChar()						-- 最后一次登录的角色索引
	self.min_camp = MsgAdapter.ReadUChar()						-- 获取最少使用的职业，用于创建角色默认选择的职业选择用
	if self.role_count <= 0 then
		self.param1 = MsgAdapter.ReadUShort()
		self.param2 = MsgAdapter.ReadUChar()
	else
		self.param1 = MsgAdapter.ReadUShort()
		self.param2 = MsgAdapter.ReadUChar()
	end
end

-- 创建角色返回
SCCreateRoleAck = SCCreateRoleAck or BaseClass(BaseProtocolStruct)
function SCCreateRoleAck:__init()
	self:InitMsgType(255, 3)
	self.role_id = 0
	self.result = 0
end

function SCCreateRoleAck:Decode()
	self.role_id = MsgAdapter.ReadUInt()
	self.result = MsgAdapter.ReadChar()		--(0=成功, 110=客户端上传的角色阵营参数错误, 111=客户端上传的角色职业参数错误, 还有返回tagNameServerOPError)
end

-- 删除角色返回
SCDelRoleAck = SCDelRoleAck or BaseClass(BaseProtocolStruct)
function SCDelRoleAck:__init()
	self:InitMsgType(255, 4)
	self.role_id = 0
	self.result = 0
end

function SCDelRoleAck:Decode()
	self.role_id = MsgAdapter.ReadUInt()
	self.result = MsgAdapter.ReadChar()		--(0=成功, 101=sql错误, 112=存在帮派不能删除角色, 114=sql没有准备好)
end

-- 服务器请求向游戏后台发送URL请求
SCServerReqSentHttpReq = SCServerReqSentHttpReq or BaseClass(BaseProtocolStruct)
function SCServerReqSentHttpReq:__init()
	self:InitMsgType(255, 9)
	self.url = ""
end

function SCServerReqSentHttpReq:Decode()
	self.url = MsgAdapter.ReadStr()
end

-- 下发跨服地址
SCCrossServerAddress = SCCrossServerAddress or BaseClass(BaseProtocolStruct)
function SCCrossServerAddress:__init()
	self:InitMsgType(255, 10)
	self.server_id = 0
	self.server_ip = ""
	self.server_port = 0
end

function SCCrossServerAddress:Decode()
	self.server_id = MsgAdapter.ReadInt()
	self.server_ip = MsgAdapter.ReadStr()
	self.server_port = MsgAdapter.ReadInt()
end

-- 返回原服
SCReturnOriginalServer = SCReturnOriginalServer or BaseClass(BaseProtocolStruct)
function SCReturnOriginalServer:__init()
	self:InitMsgType(255, 11)
end

function SCReturnOriginalServer:Decode()
end
