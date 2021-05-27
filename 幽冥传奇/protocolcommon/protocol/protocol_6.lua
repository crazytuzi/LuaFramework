--============================请求============================

-- 查询所有的正在进行的任务的数据
CSTaskListReq = CSTaskListReq or BaseClass(BaseProtocolStruct)
function CSTaskListReq:__init()
	self:InitMsgType(6, 1)
end

function CSTaskListReq:Encode()
	self:WriteBegin()
end

-- 完成任务
CSCompleteTaskReq = CSCompleteTaskReq or BaseClass(BaseProtocolStruct)
function CSCompleteTaskReq:__init()
	self:InitMsgType(6, 3)
	self.task_id = 0
end

function CSCompleteTaskReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUShort(self.task_id)
end

-- 放弃一个任务
CSTaskGiveup = CSTaskGiveup or BaseClass(BaseProtocolStruct)
function CSTaskGiveup:__init()
	self:InitMsgType(6, 4)
	self.task_id = 0
end

function CSTaskGiveup:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUShort(self.task_id)
end

-- 可接任务列表
CSTaskCanAccept = CSTaskCanAccept or BaseClass(BaseProtocolStruct)
function CSTaskCanAccept:__init()
	self:InitMsgType(6, 11)
end

function CSTaskCanAccept:Encode()
	self:WriteBegin()
end

-- 触发任务事件
CSTriggerTaskEvent = CSTriggerTaskEvent or BaseClass(BaseProtocolStruct)
function CSTriggerTaskEvent:__init()
	self:InitMsgType(6, 14)
	self.event_id = 0 --(目前只有,1=客户端下载了登陆器)
end

function CSTriggerTaskEvent:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.event_id)
end

-- 提交支线任务
CSConmitSubTaskReq = CSConmitSubTaskReq or BaseClass(BaseProtocolStruct)
function CSConmitSubTaskReq:__init()
	self:InitMsgType(6, 15)
	self.task_id = 0
end

function CSConmitSubTaskReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUShort(self.task_id)
end

-- 请求任务排序列表
CSTaskOrderListReq = CSTaskOrderListReq or BaseClass(BaseProtocolStruct)
function CSTaskOrderListReq:__init()
	self:InitMsgType(6, 16)
end

function CSTaskOrderListReq:Encode()
	self:WriteBegin()
end

--============================下发============================

-- 所有的正在进行的任务的数据
SCTaskListAck = SCTaskListAck or BaseClass(BaseProtocolStruct)
function SCTaskListAck:__init()
	self:InitMsgType(6, 1)
	self.result = 0 --0成功, 1任务数据还没从数据库读入
	self.count = 0
	self.task_list = {}
end

function SCTaskListAck:Decode()
	self.result = MsgAdapter.ReadUChar()
	self.count = MsgAdapter.ReadUShort()
	self.task_list = {}
	for i = 1, self.count do
		self.task_list[i] = CommonReader.ReadTaskInfo()
	end
end

--新增一个任务
SCAddTask = SCAddTask or BaseClass(BaseProtocolStruct)
function SCAddTask:__init()
	self:InitMsgType(6, 2)
	self.task_info = nil
end

function SCAddTask:Decode()
	self.task_info = CommonReader.ReadTaskInfo()
end

--完成一个任务
SCFinishTask = SCFinishTask or BaseClass(BaseProtocolStruct)
function SCFinishTask:__init()
	self:InitMsgType(6, 3)
	self.task_id = 0
	self.error_code = 0
end

function SCFinishTask:Decode()
	self.task_id = MsgAdapter.ReadUShort()
	self.error_code = MsgAdapter.ReadUChar()
end

--放弃一个任务
SCGiveupTask = SCGiveupTask or BaseClass(BaseProtocolStruct)
function SCGiveupTask:__init()
	self:InitMsgType(6, 4)
	self.task_id = 0
	self.error_code = 0
end

function SCGiveupTask:Decode()
	self.task_id = MsgAdapter.ReadUShort()
	self.error_code = MsgAdapter.ReadChar()
end

--可接任务列表
SCAcceptTaskList = SCAcceptTaskList or BaseClass(BaseProtocolStruct)
function SCAcceptTaskList:__init()
	self:InitMsgType(6, 5)
	self.count = 0
	self.accept_list = {}
end

function SCAcceptTaskList:Decode()
	self.count = MsgAdapter.ReadUShort()
	self.accept_list = {}
	for i = 1, self.count do
		self.accept_list[i] = CommonReader.ReadTaskInfo()
	end
end

--任务超时
SCTaskOvertime = SCTaskOvertime or BaseClass(BaseProtocolStruct)
function SCTaskOvertime:__init()
	self:InitMsgType(6, 7)
	self.count = 0
	self.task_id_list = {}
end

function SCTaskOvertime:Decode()
	self.count = MsgAdapter.ReadUChar()
	self.task_id_list = {}
	for i = 1, self.count do
		self.task_id_list[i] = MsgAdapter.ReadUShort()
	end
end

--任务的数值
SCTaskValue = SCTaskValue or BaseClass(BaseProtocolStruct)
function SCTaskValue:__init()
	self:InitMsgType(6, 8)
	self.task_id = 0
	self.target_index = 0
	self.cur_value = 0
end

function SCTaskValue:Decode()
	self.task_id = MsgAdapter.ReadUShort()
	self.target_index = MsgAdapter.ReadUChar()
	self.cur_value = MsgAdapter.ReadInt()
end

--增加可接的任务列表
SCAddAcceptTaskList = SCAddAcceptTaskList or BaseClass(BaseProtocolStruct)
function SCAddAcceptTaskList:__init()
	self:InitMsgType(6, 9)
	self.count = 0
	self.accept_list = {}
end

function SCAddAcceptTaskList:Decode()
	self.count = MsgAdapter.ReadUShort()
	self.accept_list = {}
	for i = 1, self.count do
		self.accept_list[i] = CommonReader.ReadTaskInfo()
	end
end

--下发一些任务消耗元宝的系数
SCTaskConsume = SCTaskConsume or BaseClass(BaseProtocolStruct)
function SCTaskConsume:__init()
	self:InitMsgType(6, 13)
	self.double_reward_coefficient = 0
	self.quick_finish_coefficient = 0
	self.accept_again_coefficient = 0
end

function SCTaskConsume:Decode()
	self.double_reward_coefficient = MsgAdapter.ReadFloat()
	self.quick_finish_coefficient = MsgAdapter.ReadFloat()
	self.accept_again_coefficient = MsgAdapter.ReadFloat()
end

-- 更新任务标题
SCTaskTitle = SCTaskTitle or BaseClass(BaseProtocolStruct)
function SCTaskTitle:__init()
	self:InitMsgType(6, 18)
	self.task_id = 0
	self.title = ""
end

function SCTaskTitle:Decode()
	self.task_id = MsgAdapter.ReadUShort()
	self.title = MsgAdapter.ReadStr()
end

-- 任务次数
SCTaskDoConut = SCTaskDoConut or BaseClass(BaseProtocolStruct)
function SCTaskDoConut:__init()
	self:InitMsgType(6, 19)
	self.task_id = 0
	self.now_count = 0
	self.max_count = 0
end

function SCTaskDoConut:Decode()
	self.task_id = MsgAdapter.ReadUShort()
	self.now_count = MsgAdapter.ReadUChar()
	self.max_count = MsgAdapter.ReadUChar()
end

-- 删除一个可接任务
SCRomoveAcceptTask = SCRomoveAcceptTask or BaseClass(BaseProtocolStruct)
function SCRomoveAcceptTask:__init()
	self:InitMsgType(6, 20)
	self.task_id = 0
end

function SCRomoveAcceptTask:Decode()
	self.task_id = MsgAdapter.ReadUShort()
end

-- 下发任务列表顺序及任务状态
SCQuestOrderAndState = SCQuestOrderAndState or BaseClass(BaseProtocolStruct)

function SCQuestOrderAndState:__init()
	self:InitMsgType(6, 21)
	self.task_count = 0
	self.task_state_list = {}
end

function SCQuestOrderAndState:Decode()
	self.task_count = MsgAdapter.ReadUChar()
	self.task_state_list = {}
	for i = 1, self.task_count do
		local data = {
			task_id = MsgAdapter.ReadUShort(),
			task_state = MsgAdapter.ReadUChar(),
		}
		table.insert(self.task_state_list, data)
	end
end