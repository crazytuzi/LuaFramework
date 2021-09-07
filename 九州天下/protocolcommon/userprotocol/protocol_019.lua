
--同步設置数据
SCHotkeyInfoAck = SCHotkeyInfoAck or BaseClass(BaseProtocolStruct)
function SCHotkeyInfoAck:__init()
	self.msg_type = 1900
	self.set_data_list = {}
end

function SCHotkeyInfoAck:Decode()
	self.set_data_list = {}
	local count = MsgAdapter.ReadInt()
	for i = 1, count do
		local key_info = {}
		key_info.index = MsgAdapter.ReadChar()
		key_info.type = MsgAdapter.ReadChar()
		key_info.item_id = MsgAdapter.ReadUShort()
		self.set_data_list[key_info.index] = key_info
	end
end

--请求設置数据
CSHotkeyInfoReq = CSHotkeyInfoReq or BaseClass(BaseProtocolStruct)
function CSHotkeyInfoReq:__init()
	self.msg_type = 1950
end

function CSHotkeyInfoReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

--改变設置数据
CSChangeHotkeyReq = CSChangeHotkeyReq or BaseClass(BaseProtocolStruct)
function CSChangeHotkeyReq:__init()
	self.msg_type = 1951
	self.index = 0
	self.type = 0
	self.item_id = 0
end

function CSChangeHotkeyReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteChar(self.index)
	MsgAdapter.WriteChar(self.type)
	MsgAdapter.WriteUShort(self.item_id)
end

CSChangeSetting = CSChangeSetting or BaseClass(BaseProtocolStruct)
function CSChangeSetting:__init ()
	self.msg_type = 1952
	self.index = 0		--选项的index
	self.value = 0  	--1 为设置 0 为取消
end

function CSChangeSetting:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.index)
	MsgAdapter.WriteShort(self.value)
end