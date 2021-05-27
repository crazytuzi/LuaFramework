--================================请求================================
--装备符文
CSClothBattleFuwenReq = CSClothBattleFuwenReq or BaseClass(BaseProtocolStruct)
function CSClothBattleFuwenReq:__init()
	self:InitMsgType(70, 2)
	self.uid = 0
	self.slot = 0
end

function CSClothBattleFuwenReq:Encode()
	self:WriteBegin()
	CommonReader.WriteSeries(self.uid)
	MsgAdapter.WriteUChar(self.slot - 1)
end

--升级
CSUpLevelBattleFuwenReq = CSUpLevelBattleFuwenReq or BaseClass(BaseProtocolStruct)
function CSUpLevelBattleFuwenReq:__init()
	self:InitMsgType(70, 3)
	self.slot = 0
end

function CSUpLevelBattleFuwenReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.slot - 1)
end

--脱下
CSUnClothBattleFuwenReq = CSUnClothBattleFuwenReq or BaseClass(BaseProtocolStruct)
function CSUnClothBattleFuwenReq:__init()
	self:InitMsgType(70, 4)
	self.slot = 0
end

function CSUnClothBattleFuwenReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.slot - 1)
end

--分解
CSDecomposeBattleFuwenReq = CSDecomposeBattleFuwenReq or BaseClass(BaseProtocolStruct)
function CSDecomposeBattleFuwenReq:__init()
	self:InitMsgType(70, 5)
	self.decompose_item_list = nil
end

function CSDecomposeBattleFuwenReq:Encode()
	self:WriteBegin()
	local legth = 0
	for k,v in pairs(self.decompose_item_list) do
		legth = legth + 1
	end
	MsgAdapter.WriteInt(legth)

	for uid, _ in pairs(self.decompose_item_list) do
		CommonReader.WriteSeries(uid)
	end
end


--分解
CSReplaceBattleFuwenReq = CSReplaceBattleFuwenReq or BaseClass(BaseProtocolStruct)
function CSReplaceBattleFuwenReq:__init()
	self:InitMsgType(70, 7)
	self.uid = 0
	self.slot = 0
end

function CSReplaceBattleFuwenReq:Encode()
	self:WriteBegin()
	CommonReader.WriteSeries(self.uid)
	MsgAdapter.WriteUChar(self.slot - 1)
end






--================================下发================================

----战纹系统
-- 已佩戴战纹信息
SCBattleFuwenInfo = SCBattleFuwenInfo or BaseClass(BaseProtocolStruct)
function SCBattleFuwenInfo:__init()
	self:InitMsgType(70, 1)
	self.info = {}
end

function SCBattleFuwenInfo:Decode()
	local num = MsgAdapter.ReadUChar()
	for i = 1, num do
		local vo = CommonReader.ReadItemData()
		self.info[vo.deport_id + 1] = vo
	end
end

--装备符文
SCClothBattleFuwenInfo = SCClothBattleFuwenInfo or BaseClass(BaseProtocolStruct)
function SCClothBattleFuwenInfo:__init()
	self:InitMsgType(70, 2)
	self.item_data = nil
	self.slot = 0
end

function SCClothBattleFuwenInfo:Decode()
	self.item_data = {}
	self.item_data = CommonReader.ReadItemData()
	self.slot = self.item_data.deport_id + 1
end

--升级
SCUpLevelBattleFuwenInfo = SCUpLevelBattleFuwenInfo or BaseClass(BaseProtocolStruct)
function SCUpLevelBattleFuwenInfo:__init()
	self:InitMsgType(70, 3)
	self.slot = 0
	self.level = 0
end

function SCUpLevelBattleFuwenInfo:Decode()
	self.slot = MsgAdapter.ReadUChar() + 1
	self.level = MsgAdapter.ReadUInt()
end

--脱下
SCUnClothBattleFuwenInfo = SCUnClothBattleFuwenInfo or BaseClass(BaseProtocolStruct)
function SCUnClothBattleFuwenInfo:__init()
	self:InitMsgType(70, 4)
	self.slot = 0
end

function SCUnClothBattleFuwenInfo:Decode()
	self.slot = MsgAdapter.ReadUChar() + 1
end

--分解
SCDecomposeBattleFuwenInfo = SCDecomposeBattleFuwenInfo or BaseClass(BaseProtocolStruct)
function SCDecomposeBattleFuwenInfo:__init()
	self:InitMsgType(70, 5)
	self.zw_jinghua = 0		--战纹精华
end

function SCDecomposeBattleFuwenInfo:Decode()
	local zw_num = MsgAdapter.ReadInt()
	self.zw_jinghua = MsgAdapter.ReadUInt()
end

--战纹精华 发生改动主动下发
SCBattleFuwenJingHuaInfo = SCBattleFuwenJingHuaInfo or BaseClass(BaseProtocolStruct)
function SCBattleFuwenJingHuaInfo:__init()
	self:InitMsgType(70, 6)
	self.zw_jinghua = 0		--战纹精华
end

function SCBattleFuwenJingHuaInfo:Decode()
	self.zw_jinghua = MsgAdapter.ReadUInt()
end

--装备符文
SCReplaceBattleFuwenInfo = SCReplaceBattleFuwenInfo or BaseClass(BaseProtocolStruct)
function SCReplaceBattleFuwenInfo:__init()
	self:InitMsgType(70, 7)
	self.item_data = nil
	self.slot = 0
end

function SCReplaceBattleFuwenInfo:Decode()
	self.item_data = {}
	self.item_data = CommonReader.ReadItemData()
	self.slot = self.item_data.deport_id + 1
end
----end