
-- 转发交易请求给对方
SCReqTradeRoute = SCReqTradeRoute or BaseClass(BaseProtocolStruct)
function SCReqTradeRoute:__init()
	self.msg_type = 2300
end

function SCReqTradeRoute:Decode()
	self.req_uid = MsgAdapter.ReadInt()
	self.req_name = MsgAdapter.ReadStrN(32)
	self.level = MsgAdapter.ReadInt()
	self.sex = MsgAdapter.ReadChar()
	self.prof = MsgAdapter.ReadChar()
	self.camp = MsgAdapter.ReadChar()
	MsgAdapter.ReadChar()
	self.avatar_key_big = MsgAdapter.ReadUInt()						-- 大头像
	self.avatar_key_small = MsgAdapter.ReadUInt()					-- 小头像
end

-- 将元宝放上交易架
SCTradeGold = SCTradeGold or BaseClass(BaseProtocolStruct)
function SCTradeGold:__init()
	self.msg_type = 2301
end

function SCTradeGold:Decode()
	self.is_me = MsgAdapter.ReadInt()	--0 是自己，1对方
	self.gold = MsgAdapter.ReadInt()
	self.coin = MsgAdapter.ReadInt()
end

-- 将物品放上交易架
SCTradeItem = SCTradeItem or BaseClass(BaseProtocolStruct)
function SCTradeItem:__init()
	self.msg_type = 2302
end

function SCTradeItem:Decode()
	self.is_me = MsgAdapter.ReadShort()	--0 是自己，1对方
	self.trade_index = MsgAdapter.ReadShort()
	self.knapsack_index = MsgAdapter.ReadShort()
	MsgAdapter.ReadShort()
	self.item_id = MsgAdapter.ReadUShort()
	self.num = MsgAdapter.ReadShort()
	self.invalid_time = MsgAdapter.ReadUInt()
end

-- 将物品放上交易架 (带参数物品[装备])
SCTradeItemParam = SCTradeItemParam or BaseClass(BaseProtocolStruct)
function SCTradeItemParam:__init()
	self.msg_type = 2303
end

function SCTradeItemParam:Decode()
	self.is_me = MsgAdapter.ReadShort()	--0 是自己，1对方
	self.trade_index = MsgAdapter.ReadShort()
	self.knapsack_index = MsgAdapter.ReadShort()
	MsgAdapter.ReadShort()
	self.item_wrapper = ProtocolStruct.ReadItemDataWrapper()
end

-- 交易状态返回
SCTradeState = SCTradeState or BaseClass(BaseProtocolStruct)
function SCTradeState:__init()
	self.msg_type = 2304
end

function SCTradeState:Decode()
	self.trade_state = MsgAdapter.ReadShort()
	self.other_trade_state = MsgAdapter.ReadShort()
	self.other_uid = MsgAdapter.ReadInt()
	self.other_name = MsgAdapter.ReadStrN(32)
end



-------------发送------------

-- 请求与某人交易
CSReqTrade = CSReqTrade or BaseClass(BaseProtocolStruct)
function CSReqTrade:__init()
	self.msg_type = 2350
	self.uid = 0
end

function CSReqTrade:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.uid)
end

-- 交易请求返回
CSReqTradeRet = CSReqTradeRet or BaseClass(BaseProtocolStruct)
function CSReqTradeRet:__init()
	self.msg_type = 2351
	self.result = 0 		--1 同意 0 不同意
	self.reserve_sh = 0
	self.req_uid = 0
end

function CSReqTradeRet:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.result)
	MsgAdapter.WriteShort(self.reserve_sh)
	MsgAdapter.WriteInt(self.req_uid)
end

-- 请求交易锁定
CSTradeLockReq = CSTradeLockReq or BaseClass(BaseProtocolStruct)
function CSTradeLockReq:__init()
	self.msg_type = 2352
end

function CSTradeLockReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

-- 请求交易确认
CSTradeAffirmReq = CSTradeAffirmReq or BaseClass(BaseProtocolStruct)
function CSTradeAffirmReq:__init()
	self.msg_type = 2353
end

function CSTradeAffirmReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

-- 取消交易
CSTradeCancle = CSTradeCancle or BaseClass(BaseProtocolStruct)
function CSTradeCancle:__init()
	self.msg_type = 2354
end

function CSTradeCancle:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

-- 请求将财富放上交易架
CSTradeGoldReq = CSTradeGoldReq or BaseClass(BaseProtocolStruct)
function CSTradeGoldReq:__init()
	self.msg_type = 2355
	self.gold = 0
	self.coin = 0
end

function CSTradeGoldReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.gold)
	MsgAdapter.WriteInt(self.coin)
end

-- 请求将物品放上交易架
CSTradeItemReq = CSTradeItemReq or BaseClass(BaseProtocolStruct)
function CSTradeItemReq:__init()
	self.msg_type = 2356
	self.trade_index = 0 		--交易架下标
	self.knapsack_index = 0 	--背包下标，-1 代表删除该trade_index
	self.item_num = 0 			--交易数量
end

function CSTradeItemReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.trade_index)
	MsgAdapter.WriteShort(self.knapsack_index)
	MsgAdapter.WriteInt(self.item_num)
end

-- 请求使用土豪金
CSUseTuHaoJinReq = CSUseTuHaoJinReq or BaseClass(BaseProtocolStruct)
function CSUseTuHaoJinReq:__init()
	self.msg_type = 2399
	self.use_tohaojin_color = 0
	self.reserve_1 = 0
	self.reserve_2 = 0
end

function CSUseTuHaoJinReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteChar(self.use_tohaojin_color)
	MsgAdapter.WriteChar(self.reserve_1)
	MsgAdapter.WriteShort(self.reserve_2)
end