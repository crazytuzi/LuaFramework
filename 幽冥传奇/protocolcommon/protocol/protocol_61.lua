--===================================请求==================================
-- 获取数据(返回 61 1)
CSGetFootprintInfoReq = CSGetFootprintInfoReq or BaseClass(BaseProtocolStruct)
function CSGetFootprintInfoReq:__init()
	self:InitMsgType(61, 1)
end

function CSGetFootprintInfoReq:Encode()
	self:WriteBegin()
end

-- 激活足迹(返回 61 2)
CSActFootprintReq = CSActFootprintReq or BaseClass(BaseProtocolStruct)
function CSActFootprintReq:__init()
	self:InitMsgType(61, 2)
	self.fp_item_id = 0
end

function CSActFootprintReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteInt(self.fp_item_id)
end

-- 穿戴足迹(返回 61 3)
CSUseFootprintReq = CSUseFootprintReq or BaseClass(BaseProtocolStruct)
function CSUseFootprintReq:__init()
	self:InitMsgType(61, 3)
	self.fp_item_id = 0
end

function CSUseFootprintReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteInt(self.fp_item_id)
end

--===================================下发==================================
-- 足迹信息
SCFootprintInfo = SCFootprintInfo or BaseClass(BaseProtocolStruct)
function SCFootprintInfo:__init()
	self:InitMsgType(61, 1)
	self.foot_print_list = {}
	self.using_fp_item_id = 0
end

function SCFootprintInfo:Decode()
	local data_num = MsgAdapter.ReadUChar()
	self.foot_print_list = {}
	for i = 1, data_num do
		local fp_item_id = MsgAdapter.ReadInt()
		local fp_data = {
			item_id = fp_item_id,
			duration_time = MsgAdapter.ReadInt(),		-- 持续时间(秒) 只计算在线时间
			sc_time = NOW_TIME,
		}
		self.foot_print_list[fp_item_id] = fp_data
	end
	self.using_fp_item_id = MsgAdapter.ReadInt()		-- 当前穿戴的装备id
end

-- 激活结果
SCActFootprintResult = SCActFootprintResult or BaseClass(BaseProtocolStruct)
function SCActFootprintResult:__init()
	self:InitMsgType(61, 2)
	self.fp_item_id = 0
	self.duration_time = 0
end

function SCActFootprintResult:Decode()
	self.fp_item_id = MsgAdapter.ReadInt()
	self.duration_time = MsgAdapter.ReadInt()		-- 持续时间(秒) 只计算在线时间
end

-- 穿戴结果
SCUseFootprintResult = SCUseFootprintResult or BaseClass(BaseProtocolStruct)
function SCUseFootprintResult:__init()
	self:InitMsgType(61, 3)
	self.fp_item_id = 0
end

function SCUseFootprintResult:Decode()
	self.fp_item_id = MsgAdapter.ReadInt()
end
