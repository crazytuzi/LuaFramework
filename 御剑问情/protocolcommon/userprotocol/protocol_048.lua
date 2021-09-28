-- 返回宝物仓库的全部物品
SCSelfChestShopItemList = SCSelfChestShopItemList or BaseClass(BaseProtocolStruct)
function SCSelfChestShopItemList:__init()
	self.msg_type = 4800
end

function SCSelfChestShopItemList:Decode()
	self.shop_type = MsgAdapter.ReadShort()
	MsgAdapter.ReadShort()

	self.chest_item_info = {}
	self.chest_item_info_index = {}

	self.count = MsgAdapter.ReadInt()
	for i = 0, self.count - 1 do
		self.chest_item_info[i] = SCSelfChestShopItemList.ChestItemInfo()
	end
end

function SCSelfChestShopItemList.ChestItemInfo()
	local t = {}
	t.item_id = MsgAdapter.ReadUShort()
	t.num = MsgAdapter.ReadShort()
	t.is_bind = MsgAdapter.ReadChar()
	t.shop_type = MsgAdapter.ReadChar()
	t.server_grid_index = MsgAdapter.ReadShort()
	t.param = CommonStruct.ItemParamData()
	t.param.has_lucky = MsgAdapter.ReadShort()
	t.param.strengthen_level = MsgAdapter.ReadShort()
	t.sh_order = MsgAdapter.ReadChar()
	MsgAdapter.ReadChar()
	-- MsgAdapter.ReadShort()

	t.param.xianpin_type_list = {}
	for i=1,COMMON_CONSTS.XIANPIN_MAX_NUM do
		local xianpin_type = MsgAdapter.ReadChar()
		if xianpin_type > 0 then
			table.insert(t.param.xianpin_type_list, xianpin_type)
		end
	end
	return t
end

-- 返回每次开宝箱得到的物品
SCChestShopItemListPerBuy = SCChestShopItemListPerBuy or BaseClass(BaseProtocolStruct)
function SCChestShopItemListPerBuy:__init()
	self.msg_type = 4801
end

function SCChestShopItemListPerBuy:Decode()
	self.shop_type = MsgAdapter.ReadShort()
	MsgAdapter.ReadShort()
	self.count = MsgAdapter.ReadInt()
	self.chest_item_info = {}
	for i = 1, self.count do
		self.chest_item_info[i] = SCSelfChestShopItemList.ChestItemInfo()
	end
end

-- 发送宝箱免费信息
SCChestShopFreeInfo = SCChestShopFreeInfo or BaseClass(BaseProtocolStruct)
function SCChestShopFreeInfo:__init()
	self.msg_type = 4802
end

function SCChestShopFreeInfo:Decode()
	self.chest_shop_next_free_time_1 = MsgAdapter.ReadUInt()
	self.chest_shop_jl_next_free_time_1 = MsgAdapter.ReadUInt()
end

-- 获取自己宝箱商店物品列表
CSGetSelfChestShopItemList = CSGetSelfChestShopItemList or BaseClass(BaseProtocolStruct)
function CSGetSelfChestShopItemList:__init()
	self.msg_type = 4850
	self.shop_type = 0
end

function CSGetSelfChestShopItemList:Encode()
	MsgAdapter.WriteBegin(self.msg_type)

	MsgAdapter.WriteShort(self.shop_type)
	MsgAdapter.WriteShort(0)
end

-- 寻宝
CSBuyChestShopItem = CSBuyChestShopItem or BaseClass(BaseProtocolStruct)
function CSBuyChestShopItem:__init()
	self.msg_type = 4851
	self.mode = 1
	self.shop_type = CHEST_SHOP_TYPE.CHEST_SHOP_TYPE_EQUIP
end

function CSBuyChestShopItem:Encode()
	MsgAdapter.WriteBegin(self.msg_type)

	MsgAdapter.WriteShort(self.shop_type)
	MsgAdapter.WriteShort(self.mode)
	MsgAdapter.WriteShort(0)
	MsgAdapter.WriteShort(0)
end

-- 拉取宝箱商店购买消息列表
CSGetChestShopNews = CSGetChestShopNews or BaseClass(BaseProtocolStruct)
function CSGetChestShopNews:__init()
	self.msg_type = 4853
end

function CSGetChestShopNews:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

-- 提取宝箱商店物品
CSFetchChestShopItem = CSFetchChestShopItem or BaseClass(BaseProtocolStruct)
function CSFetchChestShopItem:__init()
	self.msg_type = 4852
	self.grid_index = -1
	self.if_fetch_all = 0
	self.shop_type = 0
end

function CSFetchChestShopItem:Encode()
	MsgAdapter.WriteBegin(self.msg_type)

	MsgAdapter.WriteShort(self.shop_type)
	MsgAdapter.WriteShort(self.grid_index)
	MsgAdapter.WriteShort(self.if_fetch_all)
	MsgAdapter.WriteShort(0)
end


-- 请求宝箱免费信息
CSChestShopGetFreeInfo = CSChestShopGetFreeInfo or BaseClass(BaseProtocolStruct)
function CSChestShopGetFreeInfo:__init()
	self.msg_type = 4856
end

function CSChestShopGetFreeInfo:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

--购买商城物品
CSShopBuy = CSShopBuy or BaseClass(BaseProtocolStruct)
function CSShopBuy:__init()
	self.msg_type = 4854
	self.item_id = 0
	self.item_num = 0
	self.is_bind = 0
	self.is_use = 0			--是否直接使
	self.reserve_ch1 = 0
	self.reserve_ch2 = 0
end

function CSShopBuy:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteUShort(self.item_id)
	MsgAdapter.WriteUShort(self.item_num)
	MsgAdapter.WriteChar(self.is_bind)
	MsgAdapter.WriteChar(self.is_use)
	MsgAdapter.WriteChar(self.reserve_ch1)
	MsgAdapter.WriteChar(self.reserve_ch2)

end

--消耗积分兑换物品请求
CSScoreToItemConvert = CSScoreToItemConvert or BaseClass(BaseProtocolStruct)
function CSScoreToItemConvert:__init()
	self.msg_type = 4855
	self.scoretoitem_type = 0
	self.index = 0
	self.num = 0
end

function CSScoreToItemConvert:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.scoretoitem_type)
	MsgAdapter.WriteShort(self.index)
	MsgAdapter.WriteShort(self.num)
end

--兑换记录信息请求
CSGetConvertRecordInfo = CSGetConvertRecordInfo or BaseClass(BaseProtocolStruct)
function CSGetConvertRecordInfo:__init()
	self.msg_type = 4857
end

function CSGetConvertRecordInfo:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

-- 寻宝自动回收
CSChestShopAutoRecycle = CSChestShopAutoRecycle or BaseClass(BaseProtocolStruct)
function CSChestShopAutoRecycle:__init()
	self.msg_type = 4858
	self.max_color = 0
	self.is_auto = 1
	self.grid_index = 0
end

function CSChestShopAutoRecycle:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.shop_type)
	MsgAdapter.WriteShort(self.max_color) --参照GameEnum.I_COLOR_PURPLE
	MsgAdapter.WriteShort(self.is_auto)
	MsgAdapter.WriteShort(self.grid_index)
end

--服务器兑换记录信息
SCConvertRecordInfo = SCConvertRecordInfo or BaseClass(BaseProtocolStruct)
function SCConvertRecordInfo:__init()
	self.msg_type = 4803
	self.gouyu_record = {}
	self.convert_record = {}
	self.lifetime_record_list = {}
end

local MAX_GOUYU_CONVERT_TYPE = 120
function SCConvertRecordInfo:Decode()
	local record_count = MsgAdapter.ReadShort()
	local lifetime_record_count = MsgAdapter.ReadShort()
	self.gouyu_record = {}
	self.gy_exchange_count = 0
	for i = 0, MAX_GOUYU_CONVERT_TYPE - 1 do
		self.gouyu_record[i] = MsgAdapter.ReadChar()
		if self.gouyu_record[i] == 1 then
			self.gy_exchange_count = self.gy_exchange_count + 1
		end
	end
	self.convert_record = {}
	for i = 1, record_count do
		local one_record = {}
		one_record.reserve = MsgAdapter.ReadUShort()
		one_record.convert_type = MsgAdapter.ReadChar()
		one_record.reserve_1 = MsgAdapter.ReadChar()
		one_record.convert_count = MsgAdapter.ReadShort()
		one_record.seq = MsgAdapter.ReadShort()
		table.insert(self.convert_record, one_record)
	end
	self.lifetime_record_list = {}
	for i = 1, lifetime_record_count do
		local one_record = {}
		one_record.reserve = MsgAdapter.ReadShort()
		one_record.convert_type = MsgAdapter.ReadChar()
		one_record.reserve_1 = MsgAdapter.ReadChar()
		one_record.convert_count = MsgAdapter.ReadShort()
		one_record.seq = MsgAdapter.ReadShort()
		table.insert(self.lifetime_record_list, one_record)
	end
end

CSMysteriosshopOperate = CSMysteriosshopOperate or BaseClass(BaseProtocolStruct)
function CSMysteriosshopOperate:__init()
	self.msg_type = 4859
	self.operate_type = 0
	self.item_seq = 0
	self.item_num = 0
end

function CSMysteriosshopOperate:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	--购买时：item_seq 商品序列号seq   item_num 数量
	MsgAdapter.WriteInt(self.operate_type)
	MsgAdapter.WriteInt(self.item_seq)
	MsgAdapter.WriteInt(self.item_num)
end

--获取积分数量请求
CSGetSocreInfoReq = CSGetSocreInfoReq or BaseClass(BaseProtocolStruct)
function CSGetSocreInfoReq:__init()
	self.msg_type = 4860
end

function CSGetSocreInfoReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

--服务器发送积分信息
SCSendScoreInfo = SCSendScoreInfo or BaseClass(BaseProtocolStruct)
function SCSendScoreInfo:__init()
	self.msg_type = 4861
end

function SCSendScoreInfo:Decode()
	self.chest_shop_mojing = MsgAdapter.ReadInt()
	self.chest_shop_shengwang = MsgAdapter.ReadInt()
	self.chest_shop_gongxun = MsgAdapter.ReadInt()
	self.chest_shop_weiwang = MsgAdapter.ReadInt()
	self.chest_shop_treasure_credit = MsgAdapter.ReadInt()
	self.chest_shop_jingling_credit = MsgAdapter.ReadInt()
	self.chest_shop_happytree_grow = MsgAdapter.ReadInt()
	self.chest_shop_jifen = MsgAdapter.ReadInt()
	self.chest_shop_blue_lingzhi = MsgAdapter.ReadInt()
	self.chest_shop_purple_lingzhi = MsgAdapter.ReadInt()
	self.chest_shop_orange_lingzhi = MsgAdapter.ReadInt()
	self.chest_shop_guanghui = MsgAdapter.ReadInt()
	self.chest_shop_precious_boss_score = MsgAdapter.ReadInt()
end

--服务器发送积分信息改变
SCSendScoreInfoNotice = SCSendScoreInfoNotice or BaseClass(BaseProtocolStruct)
function SCSendScoreInfoNotice:__init()
	self.msg_type = 4862
end

function SCSendScoreInfoNotice:Decode()
	self.chest_shop_mojing = MsgAdapter.ReadInt()
	self.chest_shop_shengwang = MsgAdapter.ReadInt()
	self.chest_shop_gongxun = MsgAdapter.ReadInt()
	self.chest_shop_weiwang = MsgAdapter.ReadInt()
	self.chest_shop_treasure_credit = MsgAdapter.ReadInt()
	self.chest_shop_jingling_credit = MsgAdapter.ReadInt()
	self.chest_shop_happytree_grow = MsgAdapter.ReadInt()
	self.chest_shop_jifen = MsgAdapter.ReadInt()
	self.chest_shop_blue_lingzhi = MsgAdapter.ReadInt()
	self.chest_shop_purple_lingzhi = MsgAdapter.ReadInt()
	self.chest_shop_orange_lingzhi = MsgAdapter.ReadInt()
	self.chest_shop_guanghui = MsgAdapter.ReadInt()
	self.chest_shop_precious_boss_score = MsgAdapter.ReadInt()
end

-- 寻宝记录类型返回
CSChestShopRecordList = CSChestShopRecordList or BaseClass(BaseProtocolStruct)
function CSChestShopRecordList:__init()
	self.msg_type = 4863
	self.shop_type = 1
end

function CSChestShopRecordList:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.shop_type)
	MsgAdapter.WriteShort(0)
end

-- 寻宝记录返回
SCChestShopRecordList = SCChestShopRecordList or BaseClass(BaseProtocolStruct)
function SCChestShopRecordList:__init()
	self.msg_type = 4864
end

function SCChestShopRecordList:Decode()
	self.count = MsgAdapter.ReadShort()
	self.record_type = MsgAdapter.ReadShort()
	self.record_list = {}
	for i = 1, self.count do
		local vo = {}
		vo.role_name = MsgAdapter.ReadStrN(32)
		vo.item_id = MsgAdapter.ReadUShort()
		MsgAdapter.ReadShort()
		self.record_list[i] = vo
	end
end

--刷新时全服广播
SCMysteriosNpcRefresh = SCMysteriosNpcRefresh or BaseClass(BaseProtocolStruct)
function SCMysteriosNpcRefresh:__init()
	self.msg_type = 4804
end

function SCMysteriosNpcRefresh:Decode()
	self.disappeartime = MsgAdapter.ReadInt()
	self.nextrefreshtime = MsgAdapter.ReadInt()
	self.npc_sceneid = MsgAdapter.ReadInt()
	self.npc_x = MsgAdapter.ReadInt()
	self.npc_y = MsgAdapter.ReadInt()
end

--数量变化时广播只会广播当前场景的人，因此打开面板时要主动请求信息
SCMysteriosshopInfo = SCMysteriosshopInfo or BaseClass(BaseProtocolStruct)
function SCMysteriosshopInfo:__init()
	self.msg_type = 4805
end

function SCMysteriosshopInfo:Decode()
	self.saleitem_list = {}
	for i=1, 9 do
		local vo = {}
		vo.seq = MsgAdapter.ReadInt()
		vo.buynum = MsgAdapter.ReadInt()
		self.saleitem_list[i] = vo
	end
end


--至尊寻宝-------------------------------------------------------------------
CSRareChestShopReq = CSRareChestShopReq or BaseClass(BaseProtocolStruct)
function CSRareChestShopReq:__init()
	self.msg_type = 4806
	self.times = 0
end

function CSRareChestShopReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.times)
end

CSMysteriosshopinMallOperate = CSMysteriosshopinMallOperate or BaseClass(BaseProtocolStruct)
function CSMysteriosshopinMallOperate:__init()
	self.msg_type = 4807
	self.operate_type = 0 --操作类型，0为神秘商店，1为刷新神秘商店物品,2为刷新神秘商店物品
	self.seq = 0 --购买物品的索引,当type为2时发-1
end

function CSMysteriosshopinMallOperate:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.operate_type)
	MsgAdapter.WriteInt(self.seq)
end


SCSendMysteriosshopItemInfo = SCSendMysteriosshopItemInfo or BaseClass(BaseProtocolStruct)
function SCSendMysteriosshopItemInfo:__init()
	self.msg_type = 4808
end

function SCSendMysteriosshopItemInfo:Decode()
	self.next_shop_item_refresh_time = MsgAdapter.ReadInt()
	self.item_count = MsgAdapter.ReadInt()
	self.seq_list = {}
	for i = 1, self.item_count do
		self.seq_list[i] = {}
		self.seq_list[i].seq = MsgAdapter.ReadInt()
		self.seq_list[i].state = MsgAdapter.ReadInt()
	end
end


--至尊寻宝-------------------------------------------------------------------

--- 爱情契约领取称号 --------------------------------------------------------------------------------------
CSQingyuanLoveContractFetchTitleReq = CSQingyuanLoveContractFetchTitleReq or BaseClass(BaseProtocolStruct)
function CSQingyuanLoveContractFetchTitleReq:__init()
	self.msg_type = 4865
end

function CSQingyuanLoveContractFetchTitleReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end
--- 爱情契约领取称号 --------------------------------------------------------------------------------------

--爱情契约提醒
CSQingyuanLoveContractRemindLover = CSQingyuanLoveContractRemindLover or BaseClass(BaseProtocolStruct)
function CSQingyuanLoveContractRemindLover:__init()
	self.msg_type = 4866
end

function CSQingyuanLoveContractRemindLover:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

--红装兑换
CSRedEquipItemConvert = CSRedEquipItemConvert or BaseClass(BaseProtocolStruct)
function CSRedEquipItemConvert:__init()
	self.msg_type = 4867
end

function CSRedEquipItemConvert:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.seq)
end

--红装全部兑换信息
SCRedEquipItemConvertInfo = SCRedEquipItemConvertInfo or BaseClass(BaseProtocolStruct)
function SCRedEquipItemConvertInfo:__init()
	self.msg_type = 4868
end

function SCRedEquipItemConvertInfo:Decode()
	self.convert_count_list = {}
	for i = 0, COMMON_CONSTS.MAX_RED_EQUIP_CONVERT_COUNT - 1 do
		self.convert_count_list[i] = MsgAdapter.ReadChar()
	end
end

--红装兑换信息变化
SCRedEquipItemConvertSingleInfo = SCRedEquipItemConvertSingleInfo or BaseClass(BaseProtocolStruct)
function SCRedEquipItemConvertSingleInfo:__init()
	self.msg_type = 4869
end

function SCRedEquipItemConvertSingleInfo:Decode()
	self.seq = MsgAdapter.ReadShort()
	self.convert_count = MsgAdapter.ReadChar()
	MsgAdapter.ReadChar()
end