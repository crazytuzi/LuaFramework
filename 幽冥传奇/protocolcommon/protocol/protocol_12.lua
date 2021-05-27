-- ===================================请求==================================
-- 从商城购买东西 (返回 12 1)
CSBuyItemFromStore = CSBuyItemFromStore or BaseClass(BaseProtocolStruct)
function CSBuyItemFromStore:__init()
	self:InitMsgType(12, 1)					
	self.buy_id = 0							-- (int)购买id, 查看 Store.lua 配置
	self.buy_count = 0						-- (int)购买数量
	self.item_id = 1						-- (int)购买物品id
	self.auto_use = 0 						-- (uchar)是否立即使用 1是 0不是
end

function CSBuyItemFromStore:Encode()
	self:WriteBegin()
	MsgAdapter.WriteInt(self.buy_id)
	MsgAdapter.WriteInt(self.buy_count)
	MsgAdapter.WriteInt(self.item_id)
	MsgAdapter.WriteUChar(self.auto_use)
end

-- 购买神秘商店物品
CSBuyMysticalItemReq = CSBuyMysticalItemReq or BaseClass(BaseProtocolStruct)
function CSBuyMysticalItemReq:__init()
	self:InitMsgType(12, 2)		
	self.shop_idx = 1 -- 商品索引, 从1开始
end

function CSBuyMysticalItemReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.shop_idx)
end

-- 刷新神秘商店物品
CSRefreshMysticalItemReq = CSRefreshMysticalItemReq or BaseClass(BaseProtocolStruct)
function CSRefreshMysticalItemReq:__init()
	self:InitMsgType(12, 3)	
	self.refresh_type = 0 -- 刷新类型(0免费, 1收费)			
end

function CSRefreshMysticalItemReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.refresh_type)
end

-- 请求提取元宝
CSWithdrawIngotReq = CSWithdrawIngotReq or BaseClass(BaseProtocolStruct)
function CSWithdrawIngotReq:__init()
	self:InitMsgType(12, 4)					
	self.withdraw_num = 0							-- (int)需要提取元宝数量
end

function CSWithdrawIngotReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteInt(self.withdraw_num)
end


-- ===================================下发==================================
-- 回应购买商城物品的结果
SCReplyBuyItemResult = SCReplyBuyItemResult or BaseClass(BaseProtocolStruct)
function SCReplyBuyItemResult:__init()
	self:InitMsgType(12, 1)
	self.is_succeed = 1							-- (uchar)1成功, 0失败
end

function SCReplyBuyItemResult:Decode()
	self.is_succeed = MsgAdapter.ReadUChar()
end

--  下发玩家可提取元宝数量
SCIssuePCanWithdrawIngotNum = SCIssuePCanWithdrawIngotNum or BaseClass(BaseProtocolStruct)
function SCIssuePCanWithdrawIngotNum:__init()
	self:InitMsgType(12, 3)
	self.can_withdraw_num = 0						-- (uint)可提取元宝数量
end

function SCIssuePCanWithdrawIngotNum:Decode()
	self.can_withdraw_num = MsgAdapter.ReadUInt()
end

-- 下发动态商城的数据
SCIssueDynamicStoreData = SCIssueDynamicStoreData or BaseClass(BaseProtocolStruct)
function SCIssueDynamicStoreData:__init()
	self:InitMsgType(12, 4)
	self.goods_num = 0			-- (uchar)商品数量
	self.sold_goods_info_list = {}
end

function SCIssueDynamicStoreData:Decode()
	self.goods_num = MsgAdapter.ReadUChar()
	self.sold_goods_info = {}
	for i = 1, self.goods_num do
		local vo = {}
		vo.item_id = MsgAdapter.ReadInt()				-- 	(int)商品id, 查看 Store.lua 配置
		vo.total_sold_num = MsgAdapter.ReadInt()		-- 	(int)累积销售数量
		vo.sort_id = MsgAdapter.ReadUChar()				-- 	(uchar)分类的ID
		self.sold_goods_info_list[i] = vo
	end
end

-- 获取神秘商店信息
SCMysticalShopData = SCMysticalShopData or BaseClass(BaseProtocolStruct)
function SCMysticalShopData:__init()
	self:InitMsgType(12, 7)

	self.refre_left_time = 0    -- 免费刷新剩余时间
	self.client_time = 0
	self.item_num = 0           -- 商品数量
	self.item_list = {}         -- 商品列表
end

function SCMysticalShopData:Decode()
	self.refre_left_time = MsgAdapter.ReadUInt()
	self.client_time = Status.NowTime
	self.item_num = MsgAdapter.ReadUChar()
	self.item_list = {}
	for i = 1, self.item_num do
		self.item_list[i] = {
			shop_id = i,
			type = MsgAdapter.ReadUChar(),	     --配置类型
			index = MsgAdapter.ReadUShort(),	 --配置索引
			zhekou = MsgAdapter.ReadUChar(),	 --折扣
			money_type = MsgAdapter.ReadUChar(), --金钱类型
			price = MsgAdapter.ReadUInt(),	     --价格
			buy_mark = MsgAdapter.ReadUChar(),   --购买标记
		}
	end
end

-- 下发限购物品信息
SCShopLimitInfo = SCShopLimitInfo or BaseClass(BaseProtocolStruct)
function SCShopLimitInfo:__init()
	self:InitMsgType(12, 8)
	self.shop_limit_list = {}
end

function SCShopLimitInfo:Decode()
	self.shop_limit_list = {}
	for i = 1, MsgAdapter.ReadUShort() do
		self.shop_limit_list[i] = {
			shop_id = MsgAdapter.ReadInt(),
			can_buy_num = MsgAdapter.ReadUChar()
		}
	end
end
