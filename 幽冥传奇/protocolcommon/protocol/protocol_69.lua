-- ===================================请求==================================

-- 神炉升级与激活
CSGodFurnaceUpReq = CSGodFurnaceUpReq or BaseClass(BaseProtocolStruct)
function CSGodFurnaceUpReq:__init()
	self:InitMsgType(69, 1)
	self.slot = 0
end

function CSGodFurnaceUpReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.slot)
end

-- 灌注印记(烈焰神力)
CSGFAddGodPowerReq = CSGFAddGodPowerReq or BaseClass(BaseProtocolStruct)
function CSGFAddGodPowerReq:__init()
	self:InitMsgType(69, 2)
	self.item_id_list = {} -- 印记物品类型个数
end

function CSGFAddGodPowerReq:Encode()
	self:WriteBegin()
	local item_num = #self.item_id_list
	MsgAdapter.WriteUChar(item_num)
	for i = 1, item_num do
		MsgAdapter.WriteInt(self.item_id_list[i])
	end
end

-- 神炉穿上装备
CSGodFurnacePutOnEquipReq = CSGodFurnacePutOnEquipReq or BaseClass(BaseProtocolStruct)
function CSGodFurnacePutOnEquipReq:__init()
	self:InitMsgType(69, 3)
	self.series = 0
	self.equip_slot = 0
end

function CSGodFurnacePutOnEquipReq:Encode()
	self:WriteBegin()
	CommonReader.WriteSeries(self.series)
	MsgAdapter.WriteUChar(self.equip_slot)
end

-- 合成圣物
CSSynthesisGodItemReq = CSSynthesisGodItemReq or BaseClass(BaseProtocolStruct)
function CSSynthesisGodItemReq:__init()
	self:InitMsgType(69, 4)
	self.item_list = 0
end

function CSSynthesisGodItemReq:Encode()
	self:WriteBegin()
	local item_num = #self.item_list
	MsgAdapter.WriteUChar(item_num)
	for i = 1, #self.item_list do
		CommonReader.WriteSeries(self.item_list[i].series)
	end
end


-- ===================================下发==================================

-- 下发所有神炉数据
SCAllGodFurnaceData = SCAllGodFurnaceData or BaseClass(BaseProtocolStruct)
function SCAllGodFurnaceData:__init()
	self:InitMsgType(69, 1)
	self.equip_list = {}
	self.gf_data = {}
	self.god_power_val = 0
	self.god_power_level = 0
end

function SCAllGodFurnaceData:Decode()
	self.gf_data = {}
	for i = 1, MsgAdapter.ReadUChar() do
		self.gf_data[i - 1] = {level = MsgAdapter.ReadUShort()}
	end

	self.god_power_level = MsgAdapter.ReadUShort()	-- 烈焰神力等级
	self.god_power_val = MsgAdapter.ReadUInt()	-- 烈焰神力印记值

	self.equip_list = {}
	for i = 1, MsgAdapter.ReadUChar() do
		local equip = CommonReader.ReadItemData()
		self.equip_list[equip.deport_id] = equip
	end
end

-- 下发神炉升级结果
SCGodFurnaceUpResult = SCGodFurnaceUpResult or BaseClass(BaseProtocolStruct)
function SCGodFurnaceUpResult:__init()
	self:InitMsgType(69, 2)
	self.slot = 0		-- 神炉类型索引(从0起)
	self.level = 0	-- 神炉等级
end

function SCGodFurnaceUpResult:Decode()
	self.slot = MsgAdapter.ReadUChar()
	self.level = MsgAdapter.ReadUShort()
end

-- 下发灌注印记结果
SCGodFurnaceAddValResult = SCGodFurnaceAddValResult or BaseClass(BaseProtocolStruct)
function SCGodFurnaceAddValResult:__init()
	self:InitMsgType(69, 3)
	self.level = 0		-- 等级
	self.val = 0		-- 印记值
end

function SCGodFurnaceAddValResult:Decode()
	self.level = MsgAdapter.ReadUShort()
	self.val = MsgAdapter.ReadUInt()
end

-- 下发穿上结果
SCGFPutOnEquipResult = SCGFPutOnEquipResult or BaseClass(BaseProtocolStruct)
function SCGFPutOnEquipResult:__init()
	self:InitMsgType(69, 4)
	self.equip_data = CommonStruct.ItemDataWrapper()
end

function SCGFPutOnEquipResult:Decode()
	self.equip_data = CommonReader.ReadItemData()
end

-- 合成成功
SCSynthesisGodItem = SCSynthesisGodItem or BaseClass(BaseProtocolStruct)
function SCSynthesisGodItem:__init()
	self:InitMsgType(69, 5)
	self.item_id = 0
end

function SCSynthesisGodItem:Decode()
	self.item_id = MsgAdapter.ReadUInt()
end
