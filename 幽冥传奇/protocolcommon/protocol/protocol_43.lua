--宝石系统
--穿上宝石
CSWearDiamondReq = CSWearDiamondReq or BaseClass(BaseProtocolStruct)
function CSWearDiamondReq:__init()
	self:InitMsgType(43, 1)	
	self.diamond_type = 0   	--0 玩家 1英雄
	self.equipslot_pos = 0   --装备槽位置 
	self.diamond_pos = 0     --宝石槽位置
	self.series = 0
	self.hero_id = 0 --玩家为0
end

function CSWearDiamondReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.diamond_type)
	MsgAdapter.WriteUChar(self.equipslot_pos)
	MsgAdapter.WriteUChar(self.diamond_pos)
	ItemSeries.Write(self.series)
	MsgAdapter.WriteUInt(self.hero_id)
end

--脱下宝石
CSGetOffDiamondReq = CSGetOffDiamondReq or BaseClass(BaseProtocolStruct)
function CSGetOffDiamondReq:__init()
	self:InitMsgType(43, 2)
	self.diamond_type = 0 	--0 玩家 1英雄
	self.equipslot_pos = 0  --装备槽位置 
	self.diamond_pos = 0   --宝石槽位置
	self.hero_id = 0 --玩家为0
end

function CSGetOffDiamondReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.diamond_type)
	MsgAdapter.WriteUChar(self.equipslot_pos)
	MsgAdapter.WriteUChar(self.diamond_pos)
	MsgAdapter.WriteUInt(self.hero_id)
end


--获取自身宝石数据
CSGetRoleDiamondDataReq = CSGetRoleDiamondDataReq or BaseClass(BaseProtocolStruct)
function CSGetRoleDiamondDataReq:__init()
	self:InitMsgType(43, 3)
	self.role_model = 0	--0玩家 --1英雄
end

function CSGetRoleDiamondDataReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.role_model)
end

--升级宝石
CSUpgradeDiamondReq = CSUpgradeDiamondReq or BaseClass(BaseProtocolStruct)
function CSUpgradeDiamondReq:__init()
	self:InitMsgType(43, 4)
	self.role_model = 0
	self.equipslot_pos = 0
	self.diamond_pos = 0
	self.hero_id = 0
	self.use_gold = 0
end

function CSUpgradeDiamondReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.role_model)
	MsgAdapter.WriteUChar(self.equipslot_pos)
	MsgAdapter.WriteUChar(self.diamond_pos)
	MsgAdapter.WriteUInt(self.hero_id)
	MsgAdapter.WriteUChar(self.use_gold)
end

--查看其他玩家宝石
CSCheckPlayerDiamondData = CSCheckPlayerDiamondData or BaseClass(BaseProtocolStruct)
function CSCheckPlayerDiamondData:__init()
	self:InitMsgType(43,5)
	self.wnd_type = 0
	self.role_id = 0
	self.player_name = ""
	self.role_model = 0
end

function CSCheckPlayerDiamondData:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.wnd_type)
	MsgAdapter.WriteUInt(self.role_id)
	MsgAdapter.WriteStr(self.player_name)
	MsgAdapter.WriteUChar(self.role_model)
end

--一键分解
CSOneKeyDecompose = CSOneKeyDecompose or BaseClass(BaseProtocolStruct)
function CSOneKeyDecompose:__init()
	self:InitMsgType(43, 7)
	self.level = 0  --低于或者等于的宝石等级
end

function CSOneKeyDecompose:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.level)
end

--分解宝石
CSDeComposeDiamondReq = CSDeComposeDiamondReq or BaseClass(BaseProtocolStruct)
function CSDeComposeDiamondReq:__init()
	self:InitMsgType(43,6)
	self.series = 0
end

function CSDeComposeDiamondReq:Encode()
	self:WriteBegin()
	ItemSeries.Write(self.series)
end

CSSmeltDiamondReq = CSSmeltDiamondReq or BaseClass(BaseProtocolStruct)
function CSSmeltDiamondReq:__init()
	self:InitMsgType(43,8)
	self.oprate_type = 0
end

function CSSmeltDiamondReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.oprate_type)
end

---------------数据下发---
--通知客户端装上宝石
SCWearDiamondData = SCWearDiamondData or BaseClass(BaseProtocolStruct)
function SCWearDiamondData:__init()
	self:InitMsgType(43, 1)
	self.role_model = 0
	self.diamond_data = CommonStruct.SingleEquipDiaMondData()
end

function SCWearDiamondData:Decode()
	self.role_model = MsgAdapter.ReadUChar()
	self.diamond_data = CommonReader.ReadDiamondData()
end

--通知客户端脱下宝石
SCGetOffDiamondData = SCGetOffDiamondData or BaseClass(BaseProtocolStruct)
function SCGetOffDiamondData:__init()
	self:InitMsgType(43, 2)
	self.role_model = 0
	self.diamond_data = CommonStruct.SingleEquipDiaMondData()
end

function SCGetOffDiamondData:Decode()
	self.role_model = MsgAdapter.ReadUChar()
	self.diamond_data = CommonReader.ReadDiamondData()
end

SCRoleDiamondData = SCRoleDiamondData or BaseClass(BaseProtocolStruct)
function SCRoleDiamondData:__init()
	self:InitMsgType(43, 3)
	self.role_model = 0
	self.equip_slot_num = 0
	self.slot_data = {}
end

function SCRoleDiamondData:Decode()
	self.role_model = MsgAdapter.ReadUChar()
	self.equip_slot_num = MsgAdapter.ReadUChar()
	self.slot_data = {}
	for i = 1, self.equip_slot_num do
		self.slot_data[i] = CommonReader.ReadDiamondData()
	end
end

--宝石升级结果
SCUpgradeDiamondResult = SCUpgradeDiamondResult or BaseClass(BaseProtocolStruct)
function SCUpgradeDiamondResult:__init()
	self:InitMsgType(43,4)
	self.role_model = 0
	self.diamond_data = CommonStruct.SingleEquipDiaMondData()
end

function SCUpgradeDiamondResult:Decode()
	self.role_model = MsgAdapter.ReadUChar()
	self.diamond_data = CommonReader.ReadDiamondData()
end

--下发其他玩家的宝石数据
SCPlayerDiamondData = SCPlayerDiamondData or BaseClass(BaseProtocolStruct)
function SCPlayerDiamondData:__init()
	self:InitMsgType(43,5)
	self.wnd_type = 0
	self.player_name = " "
	self.role_model = 0
	self.equip_slot_num = 0
	self.player_slot_data = {}
end

function SCPlayerDiamondData:Decode()
	self.wnd_type = MsgAdapter.ReadUChar()
	self.player_name = MsgAdapter.ReadStr()
	self.role_model = MsgAdapter.ReadUChar()
	self.equip_slot_num = MsgAdapter.ReadUChar()
	self.player_slot_data = {}
	for i = 1, self.equip_slot_num do
		self.player_slot_data[i] = CommonReader.ReadDiamondData()
	end
end

SCOpeningsSlots = SCOpeningsSlots or BaseClass(BaseProtocolStruct)
function SCOpeningsSlots:__init()
	self:InitMsgType(43, 6)
	self.role_model = 0
	self.equipment_slots_pos = 0
	self.diamond_pos = 0 
	self.single_slot_data = 0
end

function SCOpeningsSlots:Decode()
	self.role_model = MsgAdapter.ReadUChar()
	self.equipment_slots_pos = MsgAdapter.ReadUChar()
	self.diamond_pos = MsgAdapter.ReadUChar()
	self.single_slot_data = MsgAdapter.ReadUShort()
end

SCPolishDiamondData = SCPolishDiamondData or BaseClass(BaseProtocolStruct)
function SCPolishDiamondData:__init()
	self:InitMsgType(43, 7)
	self.polish_result = 0
	
end

function SCPolishDiamondData:Decode()
	self.polish_result = MsgAdapter.ReadUChar()
	
end
--宝石熔炼
SCSmeltDiamond =  SCSmeltDiamond or BaseClass(BaseProtocolStruct)
function SCSmeltDiamond:__init()
	self:InitMsgType(43, 8)
	self.item_id = 0
	self.info_list = {}
end

function SCSmeltDiamond:Decode()
	self.item_id = MsgAdapter.ReadShort()
	self.info_list = {}
	self.count = MsgAdapter.ReadUChar()
	for i = 1, self.count do
		local v = {}
		v.role_name = MsgAdapter.ReadStr()
		v.itme_type = MsgAdapter.ReadUChar()
		v.item_id = MsgAdapter.ReadShort()
		v.itme_num = MsgAdapter.ReadInt()
		self.info_list[i] = v
	end
end