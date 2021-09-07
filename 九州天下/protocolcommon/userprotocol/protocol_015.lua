
-- 背包物品列表
SCKnapsackInfoAck = SCKnapsackInfoAck or BaseClass(BaseProtocolStruct)
function SCKnapsackInfoAck:__init()
	self.msg_type = 1500
end

function SCKnapsackInfoAck:Decode()
	self.max_knapsack_valid_num = MsgAdapter.ReadShort();
	self.max_storage_valid_num = MsgAdapter.ReadShort();
	self.item_count = MsgAdapter.ReadInt();
	self.info_list = {}
	for i = 1, self.item_count do
		local info = ProtocolStruct.ReadKnapsackInfo()
		self.info_list[info.index] = info
	end
end

-- 物品信息变更
SCKnapsackItemChange = SCKnapsackItemChange or BaseClass(BaseProtocolStruct)
function SCKnapsackItemChange:__init()
	self.msg_type = 1501
end

function SCKnapsackItemChange:Decode()
	self.change_type = MsgAdapter.ReadShort()
	self.reason_type = MsgAdapter.ReadShort()
	self.is_bind = MsgAdapter.ReadShort()
	self.index = MsgAdapter.ReadShort()
	self.item_id = MsgAdapter.ReadUShort()
	self.num = MsgAdapter.ReadShort()
	self.invalid_time = MsgAdapter.ReadUInt()
end

--背包物品参数列表
SCKnapsackInfoParam = SCKnapsackInfoParam or BaseClass(BaseProtocolStruct)
function SCKnapsackInfoParam:__init()
	self.msg_type = 1502
end

function SCKnapsackInfoParam:Decode()
	self.info_list = {}
	self.count = MsgAdapter.ReadInt()
	for i=1,self.count do
		t = {}
		t.index = MsgAdapter.ReadShort()
		t.reserve = MsgAdapter.ReadShort()
		t.param = ProtocolStruct.ReadItemParamData()
		self.info_list[t.index] = t
	end
end

--带参数的物品信息变更
SCKnapsackItemChangeParam = SCKnapsackItemChangeParam or BaseClass(BaseProtocolStruct)
function SCKnapsackItemChangeParam:__init()
	self.msg_type = 1503
end

function SCKnapsackItemChangeParam:Decode()
	self.change_type = MsgAdapter.ReadShort()
	self.reason_type = MsgAdapter.ReadShort()
	self.index = MsgAdapter.ReadShort()
	self.reserve = MsgAdapter.ReadShort()
	self.item_id = MsgAdapter.ReadUShort()
	self.num = MsgAdapter.ReadShort()
	self.is_bind = MsgAdapter.ReadShort()
	self.has_param = MsgAdapter.ReadShort()
	self.invalid_time = MsgAdapter.ReadUInt()
	self.gold_price = MsgAdapter.ReadInt()

	if self.has_param == 1 then
		self.param = ProtocolStruct.ReadItemParamData()
	end
end

--使用物品成功
SCUseItemSuc = SCUseItemSuc or BaseClass(BaseProtocolStruct)
function SCUseItemSuc:__init()
	self.msg_type = 1504
end

function SCUseItemSuc:Decode()
	self.item_id = MsgAdapter.ReadUShort()
end

--背包最大格子数
SCKnapsackMaxGridNum = SCKnapsackMaxGridNum or BaseClass(BaseProtocolStruct)
function SCKnapsackMaxGridNum:__init()
	self.msg_type = 1505
end

function SCKnapsackMaxGridNum:Decode()
	self.max_grid_num = MsgAdapter.ReadInt()
end

--仓库最大格子数
SCStorageMaxGridNum = SCStorageMaxGridNum or BaseClass(BaseProtocolStruct)
function SCStorageMaxGridNum:__init()
	self.msg_type = 1506
end

function SCStorageMaxGridNum:Decode()
	self.max_grid_num = MsgAdapter.ReadInt()
end

--缺少某物品的返回
SCLeckItem = SCLeckItem or BaseClass(BaseProtocolStruct)
function SCLeckItem:__init()
	self.msg_type = 1512
end

function SCLeckItem:Decode()
	self.item_id = MsgAdapter.ReadInt()
	self.item_count = MsgAdapter.ReadInt()
end

--请求背包信息
CSKnapsackInfoReq = CSKnapsackInfoReq or BaseClass(BaseProtocolStruct)
function CSKnapsackInfoReq:__init()
	self.msg_type = 1550
end

function CSKnapsackInfoReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

--使用物品请求
CSUseItem = CSUseItem or BaseClass(BaseProtocolStruct)
function CSUseItem:__init()
	self.msg_type = 1551
end

function CSUseItem:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.index)
	MsgAdapter.WriteShort(self.num)
	MsgAdapter.WriteShort(self.equip_index)
	MsgAdapter.WriteShort(0)
end

--移动物品请求
CSMoveItem = CSMoveItem or BaseClass(BaseProtocolStruct)
function CSMoveItem:__init()
	self.msg_type = 1552
end

function CSMoveItem:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.from_index)
	MsgAdapter.WriteShort(self.to_index)
end

--丢弃物品请求
CSDiscardItem = CSDiscardItem or BaseClass(BaseProtocolStruct)
function CSDiscardItem:__init()
	self.msg_type = 1553
	self.index = 0
	self.item_id_in_client = 0
	self.item_num_in_client = 0
	self.discard_num = 0
	self.discard_medthod = 0
end

function CSDiscardItem:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.index)
	MsgAdapter.WriteUShort(self.item_id_in_client)
	MsgAdapter.WriteInt(self.item_num_in_client)
	MsgAdapter.WriteShort(0)
	MsgAdapter.WriteShort(self.discard_num)
	MsgAdapter.WriteInt(self.discard_medthod)
end

--整理合并请求
CSKnapsackStoragePutInOrder = CSKnapsackStoragePutInOrder or BaseClass(BaseProtocolStruct)
function CSKnapsackStoragePutInOrder:__init( )
	self.msg_type = 1554
	self.is_storage = 0
	self.ignore_bind = 0
end

function CSKnapsackStoragePutInOrder:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.is_storage)	--整理的是哪个，1为仓库，0为背包
	MsgAdapter.WriteShort(self.ignore_bind)	--是否忽略绑定，1为是，0为否
end

-- 背包、仓库扩展
CSKnapsackStorageExtendGridNum = CSKnapsackStorageExtendGridNum or BaseClass(BaseProtocolStruct)
function CSKnapsackStorageExtendGridNum:__init( )
	self.msg_type = 1555
	self.type = 0 				--1为仓库，0为背包
	self.extend_num = 0
	self.can_use_gold = 1
end

function CSKnapsackStorageExtendGridNum:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.type)
	MsgAdapter.WriteShort(self.extend_num)
	MsgAdapter.WriteShort(self.can_use_gold)
	MsgAdapter.WriteShort(0)
end

-- 物品合成请求
CSItemCompose = CSItemCompose or BaseClass(BaseProtocolStruct)
function CSItemCompose:__init( )
	self.msg_type = 1557

	self.product_seq = 0				-- 合成配方
	self.num = 0						-- 合成数量
	self.compose_type = 0				-- 合成类型
end

function CSItemCompose:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.product_seq)
	MsgAdapter.WriteShort(self.num)
	MsgAdapter.WriteShort(self.compose_type)
end

-- 拾取物品
CSPickItem = CSPickItem or BaseClass(BaseProtocolStruct)
CSPickItem.MAX_PICK_ITEM = 255			-- 最多255个
function CSPickItem:__init()
	self.msg_type = 1559

	self.item_objid_list = {}
end

function CSPickItem:Encode()
	MsgAdapter.WriteBegin(self.msg_type)

	MsgAdapter.WriteInt(#self.item_objid_list)
	for k,v in pairs(self.item_objid_list) do
		MsgAdapter.WriteUShort(v)
	end
end

-- 拾取物品响应
SCPickItem = SCPickItem or BaseClass(BaseProtocolStruct)
SCPickItem.MAX_PICK_ITEM = 255			-- 最多255个
function SCPickItem:__init()
	self.msg_type = 1562

	self.item_objid_list = {}
end

function SCPickItem:Decode()
	local id_count = MsgAdapter.ReadInt()
	for i=1,id_count do
		self.item_objid_list[i] = MsgAdapter.ReadUShort()
	end
end

--奖励物品返回
SCRewardListInfo = SCRewardListInfo or BaseClass(BaseProtocolStruct)
function SCRewardListInfo:__init()
	self.msg_type = 1563
end

function SCRewardListInfo:Decode()
	self.notice_reward_type = MsgAdapter.ReadInt()
	self.mojing = MsgAdapter.ReadInt()
	self.reward_num = MsgAdapter.ReadInt()
	self.reward_list = {}
	for i = 1, self.reward_num do
		self.reward_list[i] = {}
		self.reward_list[i].item_id = MsgAdapter.ReadInt()
		self.reward_list[i].num = MsgAdapter.ReadInt()
		self.reward_list[i].is_bind = MsgAdapter.ReadInt()
	end
end