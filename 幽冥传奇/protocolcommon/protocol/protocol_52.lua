--=======================请求消息============
--激活、进阶翅膀(返回 52 1)
CSWingUpGradeReq = CSWingUpGradeReq or BaseClass(BaseProtocolStruct)
function CSWingUpGradeReq:__init()
	self:InitMsgType(52, 1)
	self.auto_upgrade = 0	--是否一键进阶，0-否， 1-是
	self.use_gold = 0 		--是否自动购买材料, 0 - 否, 1 - 是
end

function CSWingUpGradeReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.auto_upgrade)
	MsgAdapter.WriteUChar(self.use_gold)
end

--装备神羽
CSEquipmentShenyu = CSEquipmentShenyu or BaseClass(BaseProtocolStruct)
function CSEquipmentShenyu:__init()
	self:InitMsgType(52, 2)
	self.guid = 0	
end

function CSEquipmentShenyu:Encode()
	self:WriteBegin()
	CommonReader.WriteSeries(self.guid)
end

--转换神羽
CSChangeShenyu = CSChangeShenyu or BaseClass(BaseProtocolStruct)
function CSChangeShenyu:__init()
	self:InitMsgType(52, 3)
	self.guid = 0	--原物品的guid
	self.id = 0		--目标的物品id
end

function CSChangeShenyu:Encode()
	self:WriteBegin()
	CommonReader.WriteSeries(self.guid)
	MsgAdapter.WriteUShort(self.id)
end

--脱下影翼
CSEquipTakeoff = CSEquipTakeoff or BaseClass(BaseProtocolStruct)
function CSEquipTakeoff:__init()
	self:InitMsgType(52, 4)
	self.equ_index = 0 	    -- 装备的槽位id
end

function CSEquipTakeoff:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.equ_index)
end

-- 翅膀装备幻化
CSWingEquipHhReq = CSWingEquipHhReq or BaseClass(BaseProtocolStruct)
function CSWingEquipHhReq:__init()
	self:InitMsgType(52, 5)
	self.hh_equip_index = 0
end

function CSWingEquipHhReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.hh_equip_index)
end

-- 取消幻化
CSCanCelDieReq = CSCanCelDieReq or BaseClass(BaseProtocolStruct)
function CSCanCelDieReq:__init()
	self:InitMsgType(52, 6)
end

function CSCanCelDieReq:Encode()
	self:WriteBegin()
end

--=======================下发消息=======================
--所有装备
SCWingInfo = SCWingInfo or BaseClass(BaseProtocolStruct)
function SCWingInfo:__init()
	self:InitMsgType(52, 1)
	self.equipment_num = 0
	self.equip_list = {}
	self.equip_index = 0
end

function SCWingInfo:Decode()
	self.equip_index = MsgAdapter.ReadUChar()
	self.equipment_num = MsgAdapter.ReadUChar()
	self.equip_list = {}
	for i = 0, self.equipment_num - 1 do
		self.equip_list[i] = CommonReader.ReadItemData()
	end
end

--添加装备
SCAddEquipment = SCAddEquipment or BaseClass(BaseProtocolStruct)
function SCAddEquipment:__init()
	self:InitMsgType(52, 2)
	self.item = CommonStruct.ItemDataWrapper()
end

function SCAddEquipment:Decode()
	self.item = CommonReader.ReadItemData()
end

-- 下发脱下装备位置
SCTakeoffEquipIndex = SCTakeoffEquipIndex or BaseClass(BaseProtocolStruct)
function SCTakeoffEquipIndex:__init()
	self:InitMsgType(52, 3)
	self.take_index = 0
end

function SCTakeoffEquipIndex:Decode()
	self.take_index = MsgAdapter.ReadUChar()
end

-- 更新公告幻化结果
SCUpdataDieResult = SCUpdataDieResult or BaseClass(BaseProtocolStruct)
function SCUpdataDieResult:__init()
	self:InitMsgType(52, 4)
	self.up_equip_index = 0
end

function SCUpdataDieResult:Decode()
	self.up_equip_index = MsgAdapter.ReadUChar()
end