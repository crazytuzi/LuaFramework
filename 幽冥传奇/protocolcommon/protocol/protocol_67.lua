
-- 激活/穿上 时装(返回 67 1)
CSEquipFashionReq = CSEquipFashionReq or BaseClass(BaseProtocolStruct)
function CSEquipFashionReq:__init()
	self:InitMsgType(67, 1)
	self.equip_type = 0
	self.slot = 0
	self.series = 0
end

function CSEquipFashionReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.equip_type)
	MsgAdapter.WriteUShort(self.slot)
	CommonReader.WriteSeries(self.series)
end

-- 升级时装(返回 67 2)
CSEquipUpgradeFashionReq = CSEquipUpgradeFashionReq or BaseClass(BaseProtocolStruct)
function CSEquipUpgradeFashionReq:__init()
	self:InitMsgType(67, 2)
	self.equip_type = 0
	self.slot = 0
end

function CSEquipUpgradeFashionReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.equip_type)
	MsgAdapter.WriteUShort(self.slot)
end

-- 获取时装信息(返回 67 3)
CSGetFashionInfo = CSGetFashionInfo or BaseClass(BaseProtocolStruct)
function CSGetFashionInfo:__init()
	self:InitMsgType(67, 3)
	self.fashion_type = 0
end

function CSGetFashionInfo:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.fashion_type)
end

-- 形象操作(返回 67 4)
CSFashionChangeReq= CSFashionChangeReq or BaseClass(BaseProtocolStruct)
function CSFashionChangeReq:__init()
	self:InitMsgType(67, 4)
	self.req = 0 	--1保存形象, 2取消形象
	self.equip_type = 0 --1衣服, 2武器
	self.slot = 0
end

function CSFashionChangeReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.req)
	MsgAdapter.WriteUChar(self.equip_type)
	MsgAdapter.WriteUShort(self.slot)
end

-- ===================================下发==================================

-- 激活/装上时装结果
SCEquipFuwenResult = SCEquipFuwenResult or BaseClass(BaseProtocolStruct)
function SCEquipFuwenResult:__init()
	self:InitMsgType(67, 1)
	self.equip_type = 0 --1衣服, 2武器
	self.slot = 0	--槽位，从1开始
	self.item_id = 0	--物品id
	self.grade = 0	--物品等级
	self.show_id = 0	--显示id
end

function SCEquipFuwenResult:Decode()
	self.equip_type = MsgAdapter.ReadUChar()
	self.slot = MsgAdapter.ReadUShort()
	self.item_id = MsgAdapter.ReadUShort()
	self.grade = MsgAdapter.ReadUShort()
	self.show_id = MsgAdapter.ReadUShort()
end

-- 升级时装结果
SCEquipUpgradeFashionResult = SCEquipUpgradeFashionResult or BaseClass(BaseProtocolStruct)
function SCEquipUpgradeFashionResult:__init()
	self:InitMsgType(67, 2)
	self.equip_type = 0
	self.slot = 0
	self.grade = 0
end

function SCEquipUpgradeFashionResult:Decode()
	self.equip_type = MsgAdapter.ReadUChar()
	self.slot = MsgAdapter.ReadUShort()
	self.grade = MsgAdapter.ReadUShort()
end

-- 时装信息结果
SCFashionInfo = SCFashionInfo or BaseClass(BaseProtocolStruct)
function SCFashionInfo:__init()
	self:InitMsgType(67, 3)
	self.fashion_type = 0
	self.fashion_t = {}
end

function SCFashionInfo:Decode()
	self.fashion_type = MsgAdapter.ReadUChar()
	local type_count = MsgAdapter.ReadUShort()
	self.fashion_t = {}
	for i = 1, type_count do
		local vo = {}
		vo.item_id = MsgAdapter.ReadUShort()
		vo.show_id = MsgAdapter.ReadUShort()
		vo.grade = MsgAdapter.ReadUShort()
		vo.slot = MsgAdapter.ReadUShort()
		vo.equip_type = MsgAdapter.ReadUChar()
		table.insert(self.fashion_t, vo)
	end
end

-- 形象操作结果
SCFashionChangeResult = SCFashionChangeResult or BaseClass(BaseProtocolStruct)
function SCFashionChangeResult:__init()
	self:InitMsgType(67, 4)
	self.req = 0
	self.equip_type = 0 --1衣服, 2武器
	self.slot = 0
end

function SCFashionChangeResult:Decode()
	self.req = MsgAdapter.ReadUChar()
	self.equip_type = MsgAdapter.ReadUChar()
	self.slot = MsgAdapter.ReadUShort()
end

-- 删除时装
SCDeleteFashion = SCDeleteFashion or BaseClass(BaseProtocolStruct)
function SCDeleteFashion:__init()
	self:InitMsgType(67, 5)
	self.equip_type = 0
	self.slot = 0
end

function SCDeleteFashion:Decode()
	self.equip_type = MsgAdapter.ReadUChar()
	self.slot = MsgAdapter.ReadUShort()
end