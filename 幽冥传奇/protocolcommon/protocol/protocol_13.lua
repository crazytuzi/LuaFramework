-- 发起交易(HANDLE：实体ID)
CSExchangeReq = CSExchangeReq or BaseClass(BaseProtocolStruct)
function CSExchangeReq:__init()
	self:InitMsgType(13, 1)
	self.role_name = ""
end

function CSExchangeReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteStr(self.role_name)
end

--回应交易请求
CSRespondExchangeReq = CSRespondExchangeReq or BaseClass(BaseProtocolStruct)
function CSRespondExchangeReq:__init()
	self:InitMsgType(13, 2)
	self.role_id = 0
	self.bool_accept = 0  --true接受, false拒绝
end

function CSRespondExchangeReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteLL(self.role_id)
	MsgAdapter.WriteChar(self.bool_accept)
end

--添加交易物品
CSAddExchangeItemReq = CSAddExchangeItemReq or BaseClass(BaseProtocolStruct)
function CSAddExchangeItemReq:__init()
	self:InitMsgType(13, 3)
	self.serial = 0  
end

function CSAddExchangeItemReq:Encode()
	self:WriteBegin()
	CommonReader.WriteSeries(self.serial)
end

--改变交易金钱的数量
CSChangeExchangeMoneyNumberReq = CSChangeExchangeMoneyNumberReq or BaseClass(BaseProtocolStruct)
function CSChangeExchangeMoneyNumberReq:__init()
	self:InitMsgType(13, 4)
	self.money_number = 0  
	self.money_type = 0
end

function CSChangeExchangeMoneyNumberReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUInt(self.money_number)
	MsgAdapter.WriteUChar(self.money_type)
end

--锁定交易
CSLockingExchangeReq = CSLockingExchangeReq or BaseClass(BaseProtocolStruct)
function CSLockingExchangeReq:__init()
	self:InitMsgType(13, 5)
end

function CSLockingExchangeReq:Encode()
	self:WriteBegin()
end

--取消交易
CSCancleExchangeReq = CSCancleExchangeReq or BaseClass(BaseProtocolStruct)
function CSCancleExchangeReq:__init()
	self:InitMsgType(13, 6)
	self.bool_exchange = 0
end

function CSCancleExchangeReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteChar(self.bool_exchange)
end


--确认交易、
CSSureExchangeReq = CSSureExchangeReq or BaseClass(BaseProtocolStruct)
function CSSureExchangeReq:__init()
	self:InitMsgType(13, 7)
end

function CSSureExchangeReq:Encode()
	self:WriteBegin()
end

--===================================下发==================================

--发送交易请求(HANDLE：交易申请人实体ID，String：交易申请人名称
SCSendExchangereq = SCSendExchangereq or BaseClass(BaseProtocolStruct)
function SCSendExchangereq:__init()
	self:InitMsgType(13, 1)
	self.role_entity_id = 0
	self.my_name = ""
end

function SCSendExchangereq:Decode()
    self.role_entity_id = MsgAdapter.ReadLL()
	self.my_name = MsgAdapter.ReadStr()
end

--交易被拒绝([String：对方名称])
SCExchangeRefuse = SCExchangeRefuse or BaseClass(BaseProtocolStruct)
function SCExchangeRefuse:__init()
	self:InitMsgType(13, 2)
	self.opposite_side_name = ""
end

function SCExchangeRefuse:Decode()
	self.opposite_side_name = MsgAdapter.ReadStr()
end

--开始交易
SCBeginExchange = SCBeginExchange or BaseClass(BaseProtocolStruct)
function SCBeginExchange:__init()
	self:InitMsgType(13, 3)
	self.opposite_role_id = 0
	self.opposite_name = ""
	self.opposite_lev = 0
end

function SCBeginExchange:Decode()
	self.opposite_role_id = MsgAdapter.ReadLL()
	self.opposite_name = MsgAdapter.ReadStr()
	self.opposite_lev = MsgAdapter.ReadUShort()
end

--返回自己投入交易物品结果
SCSelfInputItemResult = SCSelfInputItemResult or BaseClass(BaseProtocolStruct)
function SCSelfInputItemResult:__init()
	self:InitMsgType(13, 4)
	self.serial = 0				--物品序列号
	self.is_add_succe = 0		--是否添加成功
end

function SCSelfInputItemResult:Decode()
	self.serial = CommonReader.ReadSeries()
	self.is_add_succe = MsgAdapter.ReadChar()
end

--交易对方添加物品(每添加一个物品到交易框里, 都会返回当前添加的CUserItem：物品数据)
SCOppositeInputItem = SCOppositeInputItem or BaseClass(BaseProtocolStruct)
function SCOppositeInputItem:__init()
	self:InitMsgType(13, 5)
	self.item = CommonStruct.ItemDataWrapper()
end

function SCOppositeInputItem:Decode()
	self.item = CommonReader.ReadItemData()
end

--返回改变交易金钱数量结果(bool：改变成功否，INT：当前我交易的金钱数量)
SCMyChangeExchangeMoneyResult = SCMyChangeExchangeMoneyResult or BaseClass(BaseProtocolStruct)
function SCMyChangeExchangeMoneyResult:__init()
	self:InitMsgType(13, 6)
	self.bool_success = 0
	self.money_number = 0
	self.money_type = 0
end

function SCMyChangeExchangeMoneyResult:Decode()
	self.bool_success = MsgAdapter.ReadChar()
	self.money_number = MsgAdapter.ReadUInt()
	self.money_type = MsgAdapter.ReadUChar()
end

--交易对方改变交易金钱数量(INT：金钱数量)
SCOppositeChangeExchangeMoneyResult = SCOppositeChangeExchangeMoneyResult or BaseClass(BaseProtocolStruct)
function SCOppositeChangeExchangeMoneyResult:__init()
	self:InitMsgType(13, 7)
	self.money_number = 0
	self.money_type = 0
end

function SCOppositeChangeExchangeMoneyResult:Decode()
	self.money_number = MsgAdapter.ReadUInt()
	self.money_type = MsgAdapter.ReadUChar()
end

--交易锁定状态变更(bool：我是否锁定，bool：对方是否锁定)
SCExchanLockStateChangeResult = SCExchanLockStateChangeResult or BaseClass(BaseProtocolStruct)
function SCExchanLockStateChangeResult:__init()
	self:InitMsgType(13, 8)
	self.myself_locking = 0   --自己上锁, 1锁定, 0没锁定
	self.opposite_locking = 0 --对方是否已锁定, 1锁定, 0没锁定
end

function SCExchanLockStateChangeResult:Decode()
	self.myself_locking = MsgAdapter.ReadChar()
	self.opposite_locking = MsgAdapter.ReadChar()
end

--取消交易
SCCancleExchange = SCCancleExchange or BaseClass(BaseProtocolStruct)
function SCCancleExchange:__init()
	self:InitMsgType(13, 9)
end

function SCCancleExchange:Decode()
end

--交易尚未锁定
SCExchangeNotLock = SCExchangeNotLock or BaseClass(BaseProtocolStruct)
function SCExchangeNotLock:__init()
	self:InitMsgType(13, 10)
	self.locking_state = 0    --0没锁定, 1锁定
end

function SCExchangeNotLock:Decode()
	self.locking_state = MsgAdapter.ReadUChar()
end

--交易完成
SCExchangeComplete = SCExchangeComplete or BaseClass(BaseProtocolStruct)
function SCExchangeComplete:__init()
	self:InitMsgType(13, 11)
end

function SCExchangeComplete:Decode()
end