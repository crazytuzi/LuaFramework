
-- 增加buff
SCAddBuff = SCAddBuff or BaseClass(BaseProtocolStruct)
function SCAddBuff:__init()
	self:InitMsgType(4, 1)
	self.obj_id = 0
	self.buff_id = 0
	self.buff_type = 0
	self.buff_group = 0
	self.buff_time = 0
	self.buff_name = ""
	self.buff_value = 0
	self.buff_cycle = 0
	self.buff_icon = 0
	self.buff_attr_list = {} -- 鼓舞buff类型属性集
end

function SCAddBuff:Decode()
	self.obj_id = MsgAdapter.ReadLL()
	self.buff_id = MsgAdapter.ReadUShort()
	self.buff_type = MsgAdapter.ReadUShort()
	self.buff_group = MsgAdapter.ReadUChar()
	if self.buff_type == 139 then
		self.buff_time = MsgAdapter.ReadInt()
	else
		self.buff_time = CommonReader.ReadCD()
	end 
	self.buff_name = MsgAdapter.ReadStr()
	self.buff_value = CommonReader.ReadObjBuffAttr(self.buff_type)
	self.buff_cycle = MsgAdapter.ReadUShort()
	self.buff_icon = MsgAdapter.ReadUChar()
	local count = MsgAdapter.ReadInt()
	self.buff_attr_list = {}
	for i = 1, count do
		self.buff_attr_list[i] = {}
		self.buff_attr_list[i].type = MsgAdapter.ReadUShort()
		self.buff_attr_list[i].value = CommonReader.ReadObjBuffAttr(self.buff_attr_list[i].type)
	end
end

-- 删除一个buff
SCDelBuff = SCDelBuff or BaseClass(BaseProtocolStruct)
function SCDelBuff:__init()
	self:InitMsgType(4, 2)
	self.obj_id = 0
	self.buff_type = 0
	self.buff_group = 0
end

function SCDelBuff:Decode()
	self.obj_id = MsgAdapter.ReadLL()
	self.buff_type = MsgAdapter.ReadUShort()
	self.buff_group = MsgAdapter.ReadUChar()
end

-- 根据buff类型删除buff
SCDelBuffByType = SCDelBuffByType or BaseClass(BaseProtocolStruct)
function SCDelBuffByType:__init()
	self:InitMsgType(4, 3)
	self.obj_id = 0
	self.buff_type = 0
end

function SCDelBuffByType:Decode()
	self.obj_id = MsgAdapter.ReadLL()
	self.buff_type = MsgAdapter.ReadUShort()
end

-- 更新buff
SCUpdateBuff = SCUpdateBuff or BaseClass(BaseProtocolStruct)
function SCUpdateBuff:__init()
	self:InitMsgType(4, 4)
	self.obj_id = 0
	self.buff_id = 0
	self.buff_type = 0
	self.buff_group = 0
	self.buff_time = 0
end

function SCUpdateBuff:Decode()
	self.obj_id = MsgAdapter.ReadLL()
	self.buff_id = MsgAdapter.ReadUShort()
	self.buff_type = MsgAdapter.ReadUShort()
	self.buff_group = MsgAdapter.ReadUChar()
	if self.buff_type == 139 then
		self.buff_time = MsgAdapter.ReadInt()
	else
		self.buff_time = CommonReader.ReadCD()
	end 
end