
-- GM回复
SCGMCommand = SCGMCommand or BaseClass(BaseProtocolStruct)
function SCGMCommand:__init()
	self.msg_type = 3000
end

function SCGMCommand:Decode()
	self.type = MsgAdapter.ReadStrN(64)
	self.result = MsgAdapter.ReadStrN(1024)
end

-- 发送GM命令
CSGMCommand = CSGMCommand or BaseClass(BaseProtocolStruct)
function CSGMCommand:__init()
	self.msg_type = 3050

	self.cmd_type = ""		-- 64
	self.command = ""	-- 1024
end

function CSGMCommand:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteStrN(self.cmd_type, 64)
	MsgAdapter.WriteStrN(self.command, 1024)
end
