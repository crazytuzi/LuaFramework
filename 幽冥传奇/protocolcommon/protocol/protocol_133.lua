--=====================================请求===========================================

-- 购买npc商店的物品
-- 133 1
CSBuyNpcShopReq = CSBuyNpcShopReq or BaseClass(BaseProtocolStruct)
function CSBuyNpcShopReq:__init()
	self:InitMsgType(133, 1)
	self.npc_id = 0
	self.item_id = 0
	self.item_num = 0
end

function CSBuyNpcShopReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.npc_id)
	MsgAdapter.WriteUShort(self.item_id)
	MsgAdapter.WriteUShort(self.item_num)
end


-- 请求npc商店数据
CSReqNpcStoreData = CSReqNpcStoreData or BaseClass(BaseProtocolStruct)
function CSReqNpcStoreData:__init()
	self:InitMsgType(133, 3)
	self.npc_id = 0
end

function CSReqNpcStoreData:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.npc_id)
end

CSSaleItemToShop = CSSaleItemToShop or BaseClass(BaseProtocolStruct)
function CSSaleItemToShop:__init()
	self:InitMsgType(133, 4)
	self.npc_id = 0
	self.series = 0
end

function CSSaleItemToShop:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.npc_id)
	MsgAdapter.WriteLL(self.series)
end

-- 背包商店回购物品(返回133, 5)
CSBagShopRecycle = CSBagShopRecycle or BaseClass(BaseProtocolStruct)
function CSBagShopRecycle:__init()
	self:InitMsgType(133, 5)
	self.npc_id = 0
	self.series = 0
end

function CSBagShopRecycle:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.npc_id)
	MsgAdapter.WriteLL(self.series)
end

--请求购买次数
CSReqNpcShopData = CSReqNpcShopData or BaseClass(BaseProtocolStruct)
function CSReqNpcShopData:__init()
	self:InitMsgType(133, 6)
end

function CSReqNpcShopData:Encode()
	self:WriteBegin()
end
--=====================================下发===========================================
-- 下发npc商店数据
SCNpcStoreData = SCNpcStoreData or BaseClass(BaseProtocolStruct)
function SCNpcStoreData:__init()
	self:InitMsgType(133,3)
	self.npc_id = 0
	self.shop_list = {}
end

function SCNpcStoreData:Decode()
	self.npc_id = MsgAdapter.ReadUChar()
	self.count = MsgAdapter.ReadUChar()
	self.shop_list = {}
	for i = 1, self.count do
		local v = {}
		v.name = MsgAdapter.ReadStr()
		self.item_list_content = MsgAdapter.ReadUChar()
		v.item_list = {}
		for i = 1, self.item_list_content do
			local v1 = {}
			v1.item_id = MsgAdapter.ReadUShort()
			v.item_list[i] = v1
		end
		self.shop_list[i] = v
	end
end

-- 出售物品给商店
-- 133 4
-- (uchar) npc商店id
-- (int64) 物品实例id
SCSaleItemToStore = SCSaleItemToStore or BaseClass(BaseProtocolStruct)
function SCSaleItemToStore:__init()
	self:InitMsgType(133, 4)
	self.npc_id = 0
	self.series = 0
end

function SCSaleItemToStore:Decode()
	self.npc_id = MsgAdapter.ReadUChar()
	self.series = MsgAdapter.ReadLL()
end

SCShopBuyBack  = SCShopBuyBack or BaseClass(BaseProtocolStruct)
function SCShopBuyBack:__init()
	self:InitMsgType(133, 5)
	self.npc_id = 0
	self.series = 0
end

function SCShopBuyBack:Decode()
	self.npc_id = MsgAdapter.ReadUChar()
	self.series = MsgAdapter.ReadLL()
end
-- 商店回购物品
-- 133 5
-- (uchar) npc商店id
-- (int64) 物品实例id

SCBagShopLimitTime = SCBagShopLimitTime or BaseClass(BaseProtocolStruct)
function SCBagShopLimitTime:__init()
	self:InitMsgType(133,6)
	self.item_list_count = 0 
	self.item_list = {}
end

function SCBagShopLimitTime:Decode()
	self.item_list_count = MsgAdapter.ReadUInt()
	self.item_list = {}
	for i = 1, self.item_list_count do
		local v = {}
		v.item_id = MsgAdapter.ReadUShort()
		v.buy_time = MsgAdapter.ReadUInt()
		self.item_list[i] = v
	end
	--PrintTable(self.item_list)
end

SCBagShopSingleLimitTime = SCBagShopSingleLimitTime or BaseClass(BaseProtocolStruct)
function SCBagShopSingleLimitTime:__init()
	self:InitMsgType(133, 7)
	self.item_id  = 0
	self.buy_time = 0
end

function SCBagShopSingleLimitTime:Decode()
	self.item_id  = MsgAdapter.ReadUShort()
	self.buy_time = MsgAdapter.ReadUInt()
end