-----------------请求-----------------
-- 获取本人的寄卖物品
CSGetMyConsignItemsReq = CSGetMyConsignItemsReq or BaseClass(BaseProtocolStruct)
function CSGetMyConsignItemsReq:__init()
	self:InitMsgType(27, 1)
end

function CSGetMyConsignItemsReq:Encode()
	self:WriteBegin()
end

-- 搜索物品
CSSearchConsignItemsReq = CSSearchConsignItemsReq or BaseClass(BaseProtocolStruct)
function CSSearchConsignItemsReq:__init()
	self:InitMsgType(27, 2)
end

function CSSearchConsignItemsReq:Encode()
	self:WriteBegin()
end

-- 寄卖物品
CSConsignItemReq = CSConsignItemReq or BaseClass(BaseProtocolStruct)
function CSConsignItemReq:__init()
	self:InitMsgType(27, 3)
	self.item_guid = 0
	self.item_price = 0			-- 单价
end

function CSConsignItemReq:Encode()
	self:WriteBegin()
	CommonReader.WriteSeries(self.item_guid)
	MsgAdapter.WriteUInt(self.item_price)
end

-- 取消寄卖
CSCancelConsignItemReq = CSCancelConsignItemReq or BaseClass(BaseProtocolStruct)
function CSCancelConsignItemReq:__init()
	self:InitMsgType(27, 4)
	self.item_guid = 0
	self.item_handle = 0 		-- 寄售物品某项句柄
	self.operation = 0			-- 0是取消, 1是回收（即物品到期）
end

function CSCancelConsignItemReq:Encode()
	self:WriteBegin()
	CommonReader.WriteSeries(self.item_guid)
	MsgAdapter.WriteUInt(self.item_handle)
	MsgAdapter.WriteUChar(self.operation)
end

-- 购买物品
CSBuyConsignItemReq = CSBuyConsignItemReq or BaseClass(BaseProtocolStruct)
function CSBuyConsignItemReq:__init()
	self:InitMsgType(27, 5)
	self.item_guid = 0
	self.item_handle = 0 		-- 寄售物品某项句柄
end

function CSBuyConsignItemReq:Encode()
	self:WriteBegin()
	CommonReader.WriteSeries(self.item_guid)
	MsgAdapter.WriteUInt(self.item_handle)
end

-- 兑换红钻
CSExchangeDrillReq = CSExchangeDrillReq or BaseClass(BaseProtocolStruct)
function CSExchangeDrillReq:__init()
	self:InitMsgType(27, 6)
	self.red_drill_num = 0 			-- 兑换红钻数量
end

function CSExchangeDrillReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUInt(self.red_drill_num)
end


-----------------下发-----------------
-- 下发本人的寄卖物品
SCGetMyConsignItems = SCGetMyConsignItems or BaseClass(BaseProtocolStruct)
function SCGetMyConsignItems:__init()
	self:InitMsgType(27, 1)
	self.item_num = 0
	self.item_list = {}
end

function SCGetMyConsignItems:Decode()
	self.item_num = MsgAdapter.ReadUShort()
	self.item_list = {}
	for i=1, self.item_num do
		local item_info = {}
		item_info.item_data = CommonReader.ReadItemData()
		item_info.remain_time = MsgAdapter.ReadUInt() 		-- (uint)寄卖的剩余时间,单位秒, 小以等于0为已过期
		item_info.money_type = MsgAdapter.ReadUChar() 		-- (uchar)金钱类型, 查看 eMoneyType 定义
		item_info.item_price = MsgAdapter.ReadUInt() 		-- (uint)价格
		item_info.item_handle = MsgAdapter.ReadUInt() 		-- (uint)本项物品的句柄

		self.item_list[i] = item_info
	end
end

-- 下发搜索结果
SCSearchConsignItems = SCSearchConsignItems or BaseClass(BaseProtocolStruct)
function SCSearchConsignItems:__init()
	self:InitMsgType(27, 2)
	self.index = 0 		--从0开始
	self.item_num = 0
	self.item_list = {}
end

function SCSearchConsignItems:Decode()
	self.index = MsgAdapter.ReadInt()
	self.item_num = MsgAdapter.ReadInt()
	self.item_list = {}
	for i=1, self.item_num do
		local item_info = {}
		item_info.item_data = CommonReader.ReadItemData()
		item_info.remain_time = MsgAdapter.ReadUInt() 		-- (uint)寄卖的剩余时间,单位秒, 小以等于0为已过期
		item_info.money_type = MsgAdapter.ReadUChar() 		-- (uchar)金钱类型, 查看 eMoneyType 定义
		item_info.item_price = MsgAdapter.ReadUInt() 		-- (uint)价格
		item_info.item_handle = MsgAdapter.ReadUInt() 		-- (uint)本项物品的句柄
		item_info.seller_name = MsgAdapter.ReadStr() 		-- (string)卖家名字
		item_info.item_data.item_handle = item_info.item_handle
		self.item_list[i] = item_info
	end
end

-- 增加寄卖物品的结果
SCConsignItem = SCConsignItem or BaseClass(BaseProtocolStruct)
function SCConsignItem:__init()
	self:InitMsgType(27, 3)
	self.result = 0 		-- (uchar)1成功, 0失败
end

function SCConsignItem:Decode()
	self.result = MsgAdapter.ReadUChar()
end

-- 取消寄卖
SCCancelConsignItem = SCCancelConsignItem or BaseClass(BaseProtocolStruct)
function SCCancelConsignItem:__init()
	self:InitMsgType(27, 4)
	self.result = 0 		-- (uchar)1成功, 0失败
end

function SCCancelConsignItem:Decode()
	self.result = MsgAdapter.ReadUChar()
end

-- 购买物品的结果
SCBuyConsignItem = SCBuyConsignItem or BaseClass(BaseProtocolStruct)
function SCBuyConsignItem:__init()
	self:InitMsgType(27, 5)
	self.result = 0 		-- (uchar)1成功, 0失败
end

function SCBuyConsignItem:Decode()
	self.result = MsgAdapter.ReadUChar()
end

-- 广播增加物品
SCAddConsignItem = SCAddConsignItem or BaseClass(BaseProtocolStruct)
function SCAddConsignItem:__init()
	self:InitMsgType(27, 9)
	self.item_info = {}
end

function SCAddConsignItem:Decode()
	self.item_info = {}
	self.item_info.item_data = CommonReader.ReadItemData()
	self.item_info.remain_time = MsgAdapter.ReadUInt() 		-- (uint)寄卖的剩余时间,单位秒, 小以等于0为已过期
	self.item_info.money_type = MsgAdapter.ReadUChar() 		-- (uchar)金钱类型, 查看 eMoneyType 定义
	self.item_info.item_price = MsgAdapter.ReadUInt() 		-- (uint)价格
	self.item_info.item_handle = MsgAdapter.ReadUInt() 		-- (uint)本项物品的句柄
	self.item_info.seller_name = MsgAdapter.ReadStr() 		-- (string)卖家名字
	self.item_info.item_data.item_handle = self.item_info.item_handle
end

-- 广播删除物品
SCDelConsignItem = SCDelConsignItem or BaseClass(BaseProtocolStruct)
function SCDelConsignItem:__init()
	self:InitMsgType(27, 10)
	self.item_handle = 0
end

function SCDelConsignItem:Decode()
	self.item_handle = MsgAdapter.ReadUInt()
end