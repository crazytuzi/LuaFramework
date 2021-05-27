-- 请求穿上/替换守护神装
CSWearGuardEquipReq = CSWearGuardEquipReq or BaseClass(BaseProtocolStruct)
function CSWearGuardEquipReq:__init()
	self:InitMsgType(53, 1)
end

function CSWearGuardEquipReq:Encode()
	self:WriteBegin()
	CommonReader.WriteSeries(self.series)
end

---------------------------------------------------------------
-- 接收穿上/替换守护神装结果
SCWearGuardEquipResult = SCWearGuardEquipResult or BaseClass(BaseProtocolStruct)
function SCWearGuardEquipResult:__init()
	self:InitMsgType(53, 1)
	self.slot = 0 -- 槽位
	self.item = {} -- 守护神装
end

function SCWearGuardEquipResult:Decode()
	self.slot = MsgAdapter.ReadInt()
	self.equip = CommonReader.ReadItemData()
end

-- 接收所有守护神装信息
SCAllGuardEquipInfo = SCAllGuardEquipInfo or BaseClass(BaseProtocolStruct)
function SCAllGuardEquipInfo:__init()
	self:InitMsgType(53, 2)
	self.all_guard_equip = {}
end

function SCAllGuardEquipInfo:Decode()
	local num = MsgAdapter.ReadUChar()
	local list = {}
	for i = 1, num do
		local slot = MsgAdapter.ReadUChar()
		list[slot] = CommonReader.ReadItemData()
	end
	self.all_guard_equip = list
end
