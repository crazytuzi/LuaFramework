-- 拍卖物品上架
CSAddPublicSaleItem = CSAddPublicSaleItem or BaseClass(BaseProtocolStruct)
function CSAddPublicSaleItem:__init()
	self.msg_type = 4450
	self.sale_index = -1
	self.knapsack_index = -1
	self.item_num = 0
	self.gold_price = 0
	self.keep_time_type = 2							-- 0:六小时 1：12小时 2：24小时
	self.is_to_world = 0
	self.sale_value = 0
	self.sale_item_type = 0
	self.price_type = 0
end

function CSAddPublicSaleItem:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.sale_index)
	MsgAdapter.WriteShort(self.knapsack_index)
	MsgAdapter.WriteShort(self.item_num)
	MsgAdapter.WriteInt(self.gold_price)
	MsgAdapter.WriteInt(self.keep_time_type)
	MsgAdapter.WriteInt(self.is_to_world)
	MsgAdapter.WriteInt(self.sale_value)
	MsgAdapter.WriteShort(self.sale_item_type)
	MsgAdapter.WriteShort(self.price_type)
end

-- 拍卖物品下架
CSRemovePublicSaleItem = CSRemovePublicSaleItem or BaseClass(BaseProtocolStruct)
function CSRemovePublicSaleItem:__init()
	self.msg_type = 4451
	self.sale_index = -1
end

function CSRemovePublicSaleItem:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.sale_index)
end

-- 购买拍卖物品
CSBuyPublicSaleItem = CSBuyPublicSaleItem or BaseClass(BaseProtocolStruct)
function CSBuyPublicSaleItem:__init()
	self.msg_type = 4452
	self.seller_uid = 0
	self.sale_index = -1
	self.item_id = 0
	self.item_num = 0
	self.gold_price = 0
	self.sale_value = 0
	self.sale_item_type = 0
	self.price_type = 0
end

function CSBuyPublicSaleItem:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.seller_uid)
	MsgAdapter.WriteInt(self.sale_index)
	MsgAdapter.WriteInt(self.item_id)
	MsgAdapter.WriteInt(self.item_num)
	MsgAdapter.WriteInt(self.gold_price)
	MsgAdapter.WriteInt(self.sale_value)
	MsgAdapter.WriteShort(self.sale_item_type)
	MsgAdapter.WriteShort(self.price_type)
end

-- 发送自己的拍卖物品信息到世界聊天窗
CSPublicSaleSendItemInfoToWorld = CSPublicSaleSendItemInfoToWorld or BaseClass(BaseProtocolStruct)
function CSPublicSaleSendItemInfoToWorld:__init()
	self.msg_type = 4454
	self.sale_index = -1
	self.reserve = 0
end

function CSPublicSaleSendItemInfoToWorld:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.sale_index)
	MsgAdapter.WriteShort(self.reserve)
end

-- 请求拍卖品种类数量 
CSPublicSaleTypeCountReq = CSPublicSaleTypeCountReq or BaseClass(BaseProtocolStruct)
function CSPublicSaleTypeCountReq:__init()
	self.msg_type = 4455
end

function CSPublicSaleTypeCountReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

-- 拍卖品种类数量下发
SCPublicSaleTypeCountAck = SCPublicSaleTypeCountAck or BaseClass(BaseProtocolStruct)
function SCPublicSaleTypeCountAck:__init()
	self.msg_type = 4456
	self.info_list = {}
end

function SCPublicSaleTypeCountAck:Decode()
	local count = MsgAdapter.ReadInt()
	self.info_list = {}
	for i = 1, count do
		local vo = {}
		vo.sale_type = MsgAdapter.ReadInt()
		vo.item_count = MsgAdapter.ReadInt()
		self.info_list[i] = vo
	end
end

-- 获得自己的所有拍卖物品信息
CSPublicSaleGetUserItemList = CSPublicSaleGetUserItemList or BaseClass(BaseProtocolStruct)
function CSPublicSaleGetUserItemList:__init()
	self.msg_type = 4453
end

function CSPublicSaleGetUserItemList:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

-- 市场更高阶提示框请求
CSPublicSaleCheckGoodItem = CSPublicSaleCheckGoodItem or BaseClass(BaseProtocolStruct)
function CSPublicSaleCheckGoodItem:__init()
	self.msg_type = 4457
end

function CSPublicSaleCheckGoodItem:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

--市场更高阶提示框提醒回复
SCPublicSaleNoticeGoodItem = SCPublicSaleNoticeGoodItem or BaseClass(BaseProtocolStruct)
function SCPublicSaleNoticeGoodItem:__init()
	self.msg_type = 4458
	self.item_id = 0
	self.star = 0
end

function SCPublicSaleNoticeGoodItem:Decode()
	self.item_id = MsgAdapter.ReadUShort()
	self.star = MsgAdapter.ReadShort()
end