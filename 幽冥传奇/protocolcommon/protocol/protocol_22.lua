--===================================请求==================================
--玩家看了一条消息
CSRoleViewMsg = CSRoleViewMsg or BaseClass(BaseProtocolStruct)
function CSRoleViewMsg:__init()
	self:InitMsgType(22, 1)
	self.msg_id = 0
end

function CSRoleViewMsg:Encode()
	self:WriteBegin()
	MsgAdapter.WriteLL(self.msg_id)
end

--===================================下发==================================

--发送给客户端的消息
SCAddOneMsg = SCAddOneMsg or BaseClass(BaseProtocolStruct)
function SCAddOneMsg:__init()
	self:InitMsgType(22, 1)
	self.msg_id = 0
	self.msg_type = 0 		--查看(enum tagMsgType)定义, 如果类型=42为脚本离线消息需要对应的脚本离线消息id, 查看(OfflineMsgIds )定义
	self.msg_title = ""		
	self.msg_btn_txt = ""	--按钮格式: 按钮1名称;按钮2名称/操作类型,参数1 默认“确定”则使用"", 没有为""
end

function SCAddOneMsg:Decode()
	self.msg_id = MsgAdapter.ReadLL()
	self.msg_type = MsgAdapter.ReadUChar()
	self.msg_title = MsgAdapter.ReadStr()
	self.msg_btn_txt = MsgAdapter.ReadStr()
end

--删除一条消息
SCDelOneMsg = SCDelOneMsg or BaseClass(BaseProtocolStruct)
function SCDelOneMsg:__init()
	self:InitMsgType(22, 2)
	self.msg_id = 0
end

function SCDelOneMsg:Decode()
	self.msg_id = MsgAdapter.ReadLL()
end

--返回处理结果
SCReturnMsgResult = SCReturnMsgResult or BaseClass(BaseProtocolStruct)
function SCReturnMsgResult:__init()
	self:InitMsgType(22, 3)
	self.msg_id = 0
	self.result = 0  	 --1成功, 0失败
end

function SCReturnMsgResult:Decode()
	self.msg_id = MsgAdapter.ReadLL()
	self.result = MsgAdapter.ReadUChar()
end

--下发移动寻径消息
SCAddMoveRoutingMsg = SCAddMoveRoutingMsg or BaseClass(BaseProtocolStruct)
function SCAddMoveRoutingMsg:__init()
	self:InitMsgType(22, 4)
	self.msg_content = ""
	self.msg_title = ""
	self.scene_name = ""
	self.x = 0
	self.y = 0
end

function SCAddMoveRoutingMsg:Decode()
	self.msg_content = MsgAdapter.ReadStr()
	self.msg_title = MsgAdapter.ReadStr()
	self.scene_name = MsgAdapter.ReadStr()
	self.x = MsgAdapter.ReadUShort()
	self.y = MsgAdapter.ReadUShort()
end