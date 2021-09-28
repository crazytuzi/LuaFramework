-- 物品上架返回
SCAddPublicSaleItemAck = SCAddPublicSaleItemAck or BaseClass(BaseProtocolStruct)
function SCAddPublicSaleItemAck:__init()
	self.msg_type = 9600
	self.ret = 0    										-- 成功返回0
	self.sale_index = -1
end

function SCAddPublicSaleItemAck:Decode()
	self.ret = MsgAdapter.ReadInt()
	self.sale_index = MsgAdapter.ReadInt()
end

-- 物品下架返回
SCRemovePublicSaleItemAck = SCRemovePublicSaleItemAck or BaseClass(BaseProtocolStruct)
function SCRemovePublicSaleItemAck:__init()
	self.msg_type = 9601
	self.ret = 0
	self.sale_index = -1
end

function SCRemovePublicSaleItemAck:Decode()
	self.ret = MsgAdapter.ReadInt()
	self.sale_index = MsgAdapter.ReadInt()
end

-- 购买物品返回
SCBuyPublicSaleItemAck = SCBuyPublicSaleItemAck or BaseClass(BaseProtocolStruct)
function SCBuyPublicSaleItemAck:__init()
	self.msg_type = 9602
	self.ret = 0
	self.seller_uid = -1
	self.sale_index = -1
end

function SCBuyPublicSaleItemAck:Decode()
	self.ret = MsgAdapter.ReadInt()
	self.seller_uid = MsgAdapter.ReadInt()
	self.sale_index = MsgAdapter.ReadInt()
end

-- 获取自己出售物品列表
SCGetPublicSaleItemListAck = SCGetPublicSaleItemListAck or BaseClass(BaseProtocolStruct)
function SCGetPublicSaleItemListAck:__init()
	self.msg_type = 9603
	self.count = 0
	self.sale_item_list = {}
end

function SCGetPublicSaleItemListAck:Decode()
	self.count = MsgAdapter.ReadInt()
	self.sale_item_list = {}
	for i = 1, self.count do
		local sale_item = ProtocolStruct.ReadItemDataWrapper()
		sale_item.sale_index = MsgAdapter.ReadInt()
		sale_item.sale_type = MsgAdapter.ReadInt()
		sale_item.level = MsgAdapter.ReadInt()
		sale_item.prof = MsgAdapter.ReadShort()
		sale_item.color = MsgAdapter.ReadShort()
		sale_item.gold_price = MsgAdapter.ReadInt()
		sale_item.sale_value = MsgAdapter.ReadInt()
		sale_item.price_type = MsgAdapter.ReadShort()
		sale_item.sale_item_type = MsgAdapter.ReadShort()
		sale_item.sale_time = MsgAdapter.ReadUInt()
		sale_item.due_time = MsgAdapter.ReadUInt()
		table.insert(self.sale_item_list, sale_item)
	end
end

-- 搜索
CSPublicSaleSearch = CSPublicSaleSearch or BaseClass(BaseProtocolStruct)
function CSPublicSaleSearch:__init()
	self.msg_type = 9650
	self.item_type = 0													-- 指定类型 0为不指定
	self.level = 0														-- 指定等级 0为不指定
	self.level_interval = 0												-- 等级区间
	self.prof = 0														-- 指定职业 0为不指定
	self.color = 0														-- 指定颜色 0为不指定
	self.color_interval = 0 											-- 颜色区间
	self.order = 0														-- 指定阶数 0为不指定
	self.order_interval = 0 											-- 阶数区间
	self.page_item_count = 4											-- 一页显示几个物品
	self.req_page = 0													-- 请求第几页
	self.total_page = 0													-- 总页数 客户端没有总页数的时候 要填成0 如果已经有总页数 填上总页数
	self.fuzzy_type_count = 0
	self.fuzzy_type_list = {}
end

function CSPublicSaleSearch:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.item_type)
	MsgAdapter.WriteShort(self.level)
	MsgAdapter.WriteShort(self.level_interval)
	MsgAdapter.WriteShort(self.prof)
	MsgAdapter.WriteShort(self.color)
	MsgAdapter.WriteShort(self.color_interval)
	MsgAdapter.WriteShort(self.order)
	MsgAdapter.WriteShort(self.order_interval)
	MsgAdapter.WriteShort(self.page_item_count)
	MsgAdapter.WriteInt(self.req_page)
	MsgAdapter.WriteInt(self.total_page)
	MsgAdapter.WriteInt(self.fuzzy_type_count)

	for i = 1, self.fuzzy_type_count do
		local fuzzy_type = self.fuzzy_type_list[i]
		MsgAdapter.WriteInt(fuzzy_type.item_sale_type)
		MsgAdapter.WriteInt(fuzzy_type.item_count)
		local item_id_list = fuzzy_type.item_id_list
		for k, v in pairs(item_id_list) do
			MsgAdapter.WriteInt(v)
		end
	end
end

-- 搜索返回
SCPublicSaleSearchAck = SCPublicSaleSearchAck or BaseClass(BaseProtocolStruct)
function SCPublicSaleSearchAck:__init()
	self.msg_type = 9604
	self.cur_page = 0
	self.total_page = 0
	self.count = 0
	self.saleitem_list = {}
end

function SCPublicSaleSearchAck:Decode()
	self.cur_page = MsgAdapter.ReadInt()
	self.total_page = MsgAdapter.ReadInt()
	self.count = MsgAdapter.ReadInt()
	self.saleitem_list = {}
	local seller_uid, seller_name = 0, ""
	for i = 1, self.count do
		seller_uid = MsgAdapter.ReadInt()
		seller_name = MsgAdapter.ReadStrN(32)
		local saleitem = ProtocolStruct.ReadItemDataWrapper()
		saleitem.seller_uid = seller_uid
		saleitem.seller_name = seller_name
		saleitem.sale_index = MsgAdapter.ReadInt()
		saleitem.sale_type = MsgAdapter.ReadInt()
		saleitem.level = MsgAdapter.ReadInt()
		saleitem.prof = MsgAdapter.ReadShort()
		saleitem.color = MsgAdapter.ReadShort()
		saleitem.gold_price = MsgAdapter.ReadInt()
		saleitem.sale_value = MsgAdapter.ReadInt()
		saleitem.price_type = MsgAdapter.ReadShort()
		saleitem.sale_item_type = MsgAdapter.ReadShort()
		saleitem.sale_time = MsgAdapter.ReadUInt()
		saleitem.due_time = MsgAdapter.ReadUInt()
		table.insert(self.saleitem_list, saleitem)
	end
end