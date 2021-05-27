--===================================请求==================================

-- 邀请切磋(好像只在前端处理)
CSInvitePK = CSInvitePK or BaseClass(BaseProtocolStruct)
function CSInvitePK:__init()
	self:InitMsgType(24, 1)
	self.role_name = ""
end

function CSInvitePK:Encode()
	self:WriteBegin()
	MsgAdapter.WriteStr(self.role_name)
end

-- 玩家回复邀请
CSInvitePKReply = CSInvitePKReply or BaseClass(BaseProtocolStruct)
function CSInvitePKReply:__init()
	self:InitMsgType(24, 2)
	self.result = 0  --0拒绝, 1接受
	self.role_name = ""
end

function CSInvitePKReply:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.result)
	MsgAdapter.WriteStr(self.role_name)
end

-- 设置自由PK模式
CSSetPKMode = CSSetPKMode or BaseClass(BaseProtocolStruct)
function CSSetPKMode:__init()
	self:InitMsgType(24, 3)
	self.mode = 0  
end

function CSSetPKMode:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.mode)
end

-- 被PK邀请人的回应，是接受还是拒绝
CSPkReqAnswer = CSPkReqAnswer or BaseClass(BaseProtocolStruct)
function CSPkReqAnswer:__init()
	self:InitMsgType(24, 4)
	self.answer = 0			-- 0拒绝, 1接受
	self.req_name = ""		-- 邀请人名字
	self.scene_id = 0
	self.scene_name = ""
	self.x = 0
	self.y = 0
end

function CSPkReqAnswer:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.answer)
	MsgAdapter.WriteStr(self.req_name)
	MsgAdapter.WriteInt(self.scene_id)
	MsgAdapter.WriteStr(self.scene_name)
	MsgAdapter.WriteUShort(self.x)
	MsgAdapter.WriteUShort(self.y)
end

--===================================下发==================================

-- 服务器下发邀请的消息
SCPKInvite = SCPKInvite or BaseClass(BaseProtocolStruct)
function SCPKInvite:__init()
	self:InitMsgType(24, 1)
	self.name = ""
end

function SCPKInvite:Decode()
	self.name = MsgAdapter.ReadStr()
end

-- 给双方下发开始切磋的消息
SCPKInfo = SCPKInfo or BaseClass(BaseProtocolStruct)
function SCPKInfo:__init()
	self:InitMsgType(24, 2)
	self.obj_id = 0
	self.begin_or_over = 0  --1开始, 0结束
	self.over_time = 0
end

function SCPKInfo:Decode()
	self.obj_id = MsgAdapter.ReadLL()
	self.begin_or_over = MsgAdapter.ReadUChar()
	if self.begin_or_over == 1 then
		self.over_time = MsgAdapter.ReadInt()
	end
end

-- pK模式改变
SCPKModeChange = SCPKModeChange or BaseClass(BaseProtocolStruct)
function SCPKModeChange:__init()
	self:InitMsgType(24, 3)
	self.mode = 0
end

function SCPKModeChange:Decode()
	self.mode = MsgAdapter.ReadUChar()
end

-- PK邀请
SCPlayerPkReq = SCPlayerPkReq or BaseClass(BaseProtocolStruct)
function SCPlayerPkReq:__init()
	self:InitMsgType(24, 4)
	self.req_name = ""
	self.scene_id = 0
	self.scene_name = ""
	self.x = 0
	self.y = 0
end

function SCPlayerPkReq:Decode()
	self.req_name = MsgAdapter.ReadStr()
	self.scene_id = MsgAdapter.ReadInt()
	self.scene_name = MsgAdapter.ReadStr()
	self.x = MsgAdapter.ReadUShort()
	self.y = MsgAdapter.ReadUShort()
end