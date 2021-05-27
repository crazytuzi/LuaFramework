--===================================请求==================================

-- 删除物品
CSDeleteItemReq = CSDeleteItemReq or BaseClass(BaseProtocolStruct)
function CSDeleteItemReq:__init()
	self:InitMsgType(8, 1)
	self.series = 0
end

function CSDeleteItemReq:Encode()
	self:WriteBegin()
	CommonReader.WriteSeries(self.series)
end

-- 获取背包列表(返回 8 4)
CSGetBagListReq = CSGetBagListReq or BaseClass(BaseProtocolStruct)
function CSGetBagListReq:__init()
	self:InitMsgType(8, 2)
end

function CSGetBagListReq:Encode()
	self:WriteBegin()
end

-- 获取扩大背包费用(返回8 5)
CSGetExpandBagCost = CSGetExpandBagCost or BaseClass(BaseProtocolStruct)
function CSGetExpandBagCost:__init()
	self:InitMsgType(8, 3)
	self.expand_num = 0
end

function CSGetExpandBagCost:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.expand_num)
end

-- 扩大背包
CSExpandBagReq = CSExpandBagReq or BaseClass(BaseProtocolStruct)
function CSExpandBagReq:__init()
	self:InitMsgType(8, 4)
	self.expand_num = 0
end

function CSExpandBagReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUShort(self.expand_num)
end

-- 拆分
CSSplitItemReq = CSSplitItemReq or BaseClass(BaseProtocolStruct)
function CSSplitItemReq:__init()
	self:InitMsgType(8, 5)
	self.series = 0
	self.split_num = 0
end

function CSSplitItemReq:Encode()
	self:WriteBegin()
	CommonReader.WriteSeries(self.series)
	MsgAdapter.WriteUShort(self.split_num)
end

-- 合并
CSMergeItemReq = CSMergeItemReq or BaseClass(BaseProtocolStruct)
function CSMergeItemReq:__init()
	self:InitMsgType(8, 6)
	self.source_series = 0
	self.target_series = 0
end

function CSMergeItemReq:Encode()
	self:WriteBegin()
	CommonReader.WriteSeries(self.source_series)
	CommonReader.WriteSeries(self.target_series)
end

-- 使用物品(返回8 10)
CSUseItemReq = CSUseItemReq or BaseClass(BaseProtocolStruct)
function CSUseItemReq:__init()
	self:InitMsgType(8, 7)
	self.series = 0
	self.is_hero = 0
	self.param = 0
	self.num = 0
	self.target_role_name = ""
end

function CSUseItemReq:Encode()
	self:WriteBegin()
	CommonReader.WriteSeries(self.series)
	MsgAdapter.WriteUChar(self.is_hero)
	MsgAdapter.WriteInt(self.param)
	MsgAdapter.WriteUInt(self.num)
	MsgAdapter.WriteStr(self.target_role_name)
end

-- -- 操作物品(返回协议8 8)
-- CSOperateItemReq = CSOperateItemReq or BaseClass(BaseProtocolStruct)
-- function CSOperateItemReq:__init()
-- 	self:InitMsgType(8, 8)
-- 	self.item_num = 0
-- end

-- function CSOperateItemReq:Encode()
-- 	self:WriteBegin()
-- end

-- 获取处理一件装备需要的消耗
CSGetDisposeEquipNeed = CSGetDisposeEquipNeed or BaseClass(BaseProtocolStruct)
function CSGetDisposeEquipNeed:__init()
	self:InitMsgType(8, 9)
	self.series = 0
end

function CSGetDisposeEquipNeed:Encode()
	self:WriteBegin()
	CommonReader.WriteSeries(self.series)
end

-- 灌注源泉
CSFillSourceReq = CSFillSourceReq or BaseClass(BaseProtocolStruct)
function CSFillSourceReq:__init()
	self:InitMsgType(8, 11)
	self.drugs_series = 0
	self.source_series = 0
end

function CSFillSourceReq:Encode()
	self:WriteBegin()
	CommonReader.WriteSeries(self.drugs_series)
	CommonReader.WriteSeries(self.source_series)
end

-- 丢弃金币
CSDiscardGoldReq = CSDiscardGoldReq or BaseClass(BaseProtocolStruct)
function CSDiscardGoldReq:__init()
	self:InitMsgType(8, 14)
	self.num = 0
end

function CSDiscardGoldReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUInt(self.num)
end

-- 获取能升级的装备
CSGetCanUpEquipReq = CSGetCanUpEquipReq or BaseClass(BaseProtocolStruct)
function CSGetCanUpEquipReq:__init()
	self:InitMsgType(8, 15)
end

function CSGetCanUpEquipReq:Encode()
	self:WriteBegin()
end

-- 使用完美强化符物品
CSUsePerfectStrengthenTalisman = CSUsePerfectStrengthenTalisman or BaseClass(BaseProtocolStruct)
function CSUsePerfectStrengthenTalisman:__init()
	self:InitMsgType(8, 16)
	self.equip_series = 0
	self.talisman_series = 0
	self.equip_pos = 0									-- <=0则遍历查找获得装备所在的位置,英雄身上或角色向上, 如果 > 0 用作英雄id
end

-- 砸金蛋
CSBreakGoldenEggReq = CSBreakGoldenEggReq or BaseClass(BaseProtocolStruct)
function CSBreakGoldenEggReq:__init()
	self:InitMsgType(8, 17)
	self.egg_index = 0
end

function CSBreakGoldenEggReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.egg_index)
end

-- 幸运大抽奖
CSLuckyDrawReq = CSLuckyDrawReq or BaseClass(BaseProtocolStruct)
function CSLuckyDrawReq:__init()
	self:InitMsgType(8, 18)
	self.opt_type = 0
end

function CSLuckyDrawReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.opt_type)
end

-- 装备合成,宝石合成
CSComposeEquipGem = CSComposeEquipGem or BaseClass(BaseProtocolStruct)
function CSComposeEquipGem:__init()
	self:InitMsgType(8, 19)
	self.compose_type = 1								-- 1装备合成, 2宝石合成, 3.神装合成，4.战装合成
	self.compose_index = 0								-- 合成类型索引,对应配置表
	self.item_index = 0									-- 装备索引
	self.stone_type = 0
	self.item_id = 0											
	self.is_onekey_compose = 0							-- 是否一键合成, 1是, 0否，如果没有为0	
	self.is_bag = 0 			-- 1在背包, 2在身上
	-- self.fashion_type = 0
	-- self.fashion_series = 0
	-- self.fashion_index = 0
	-- self.fashion_series1 = 0
	-- self.fashion_series2 = 0
	-- self.fashion_series3 = 0					
end

function CSComposeEquipGem:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.compose_type)
	MsgAdapter.WriteUChar(self.compose_index)
	MsgAdapter.WriteUChar(self.item_index)
	if self.compose_type == 2 then
		MsgAdapter.WriteUChar(self.stone_type)
	end
	MsgAdapter.WriteUShort(self.item_id)
	MsgAdapter.WriteUChar(self.is_onekey_compose)
	if self.compose_type == 8 then
		MsgAdapter.WriteUChar(self.is_bag)
		-- if self.is_bag == 1 then
		-- 	CommonReader.WriteSeries(self.fashion_series1)
		-- else
		-- 	MsgAdapter.WriteUChar(self.fashion_type)
		-- 	MsgAdapter.WriteUChar(self.fashion_series)
		-- 	MsgAdapter.WriteUChar(self.fashion_index)
		-- end
		-- CommonReader.WriteSeries(self.fashion_series2)
		-- CommonReader.WriteSeries(self.fashion_series3)
	end
end

-- 物品合成
CSComposeItem = CSComposeItem or BaseClass(BaseProtocolStruct)
function CSComposeItem:__init()
	self:InitMsgType(8, 34)
	self.compose_type = 0								-- 1神羽合成, 2宝石合成
	self.secompose_type =0 								--合成二级索引，从1开始，看配置ItemSynthesisConfig
	self.compose_index = 0								-- 合成类型索引,对应配置表，从1开始									
	self.is_onekey_compose = 0							--是否一键合成，1：是   0：否
	self.compose_num = 0 								--合成次数，一键合成开启才有效
end

function CSComposeItem:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.compose_type)
	MsgAdapter.WriteUChar(self.secompose_type)
	MsgAdapter.WriteUShort(self.compose_index)
	MsgAdapter.WriteUChar(self.is_onekey_compose)
	MsgAdapter.WriteUInt(self.compose_num)
end

-- 炼金材料
CSAlchemyMaterialReq = CSAlchemyMaterialReq or BaseClass(BaseProtocolStruct)
function CSAlchemyMaterialReq:__init()
	self:InitMsgType(8, 21)
	self.alchemy_type = 1								-- 1开始炼金术, 2炼金奖励
end

function CSAlchemyMaterialReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.alchemy_type)
end

-- 炼金状态
CSalchemyStateReq = CSalchemyStateReq or BaseClass(BaseProtocolStruct)
function CSalchemyStateReq:__init()
	self:InitMsgType(8, 22)
end

function CSalchemyStateReq:Encode()
	self:WriteBegin()
end

-- 天兵神器锻造
CSTianBingArtifactForging = CSTianBingArtifactForging or BaseClass(BaseProtocolStruct)
function CSTianBingArtifactForging:__init()
	self:InitMsgType(8, 23)
	self.forging_type = 1								-- 1神器2神甲3法宝
	self.level = 0
end

function CSTianBingArtifactForging:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.forging_type)
	MsgAdapter.WriteUChar(self.level)
end

-- 提取金刚石
CSExtractDiamondReq = CSExtractDiamondReq or BaseClass(BaseProtocolStruct)
function CSExtractDiamondReq:__init()
	self:InitMsgType(8, 24)
	self.extract_type = 1								-- 1提取10颗 2提取100颗
end

function CSExtractDiamondReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.extract_type)
end

-- 材料兑换金刚石
CSExChangeDiamondReq = CSExChangeDiamondReq or BaseClass(BaseProtocolStruct)
function CSExChangeDiamondReq:__init()
	self:InitMsgType(8, 25)
	self.ExChange_type = 1								-- 1兑换5个,2兑换10个,3兑换20个,4兑换30个
end

function CSExChangeDiamondReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.ExChange_type)
end

-- 装备镶嵌宝石
CSEquipInlayGemReq = CSEquipInlayGemReq or BaseClass(BaseProtocolStruct)
function CSEquipInlayGemReq:__init()
	self:InitMsgType(8, 28)
	self.inlay_hole_index = 0
	self.equip_pos = 0									-- 0镶嵌身上的装备, 1镶嵌背包的装备
	self.equip_series = 0
	self.gem_series = 0
end

function CSEquipInlayGemReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.inlay_hole_index)
	MsgAdapter.WriteUChar(self.equip_pos)
	CommonReader.WriteSeries(self.equip_series)
	CommonReader.WriteSeries(self.gem_series)
end

-- 卸下宝石
CSEquipUnloadGemReq = CSEquipUnloadGemReq or BaseClass(BaseProtocolStruct)
function CSEquipUnloadGemReq:__init()
	self:InitMsgType(8, 29)
	self.inlay_hole_index = 0
	self.equip_pos = 0									-- 0卸下身上的装备宝石, 1卸下背包的装备宝石
	self.equip_series = 0
end

function CSEquipUnloadGemReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.inlay_hole_index)
	MsgAdapter.WriteUChar(self.equip_pos)
	CommonReader.WriteSeries(self.equip_series)
end


-- 装备分解
CSEquipDecompose = CSEquipDecompose or BaseClass(BaseProtocolStruct)
function CSEquipDecompose:__init()
	self:InitMsgType(8, 30)
	self.decomp_type = 0                            -- 分解类型
	self.series = 0
end

function CSEquipDecompose:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.decomp_type)
	CommonReader.WriteSeries(self.series)
end

-- 兑换战魂值
CSConvertWarsoul = CSConvertWarsoul or BaseClass(BaseProtocolStruct)
function CSConvertWarsoul:__init()
	self:InitMsgType(8, 31)
	self.index = 0
end

function CSConvertWarsoul:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.index)
end

CSDiamondsCreateReq = CSDiamondsCreateReq or BaseClass(BaseProtocolStruct)
function CSDiamondsCreateReq:__init()
	self:InitMsgType(8, 33)
	self.item_type = 0
	self.create_type = 0
end
function CSDiamondsCreateReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.item_type)
	MsgAdapter.WriteUChar(self.create_type)
end


CSDuiHuanItemReq = CSDuiHuanItemReq or BaseClass(BaseProtocolStruct)
function CSDuiHuanItemReq:__init( ... )
	self:InitMsgType(8,35)
	self.index = 0 --兑换索引
end

function CSDuiHuanItemReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUShort(self.index)
end

-- 选择使用物品
CSSelectItem = CSSelectItem or BaseClass(BaseProtocolStruct)
function CSSelectItem:__init()
	self:InitMsgType(8, 36)
	self.id = 0                             -- 物品id
	self.pro = 0                            -- 职业
	self.index = 0                          -- 索引
	self.num = 0
end

function CSSelectItem:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUShort(self.id)
	MsgAdapter.WriteUChar(self.pro)
	MsgAdapter.WriteUChar(self.index)
	MsgAdapter.WriteUChar(self.num)
end

-- 删除宝箱
CSDeleteBox = CSDeleteBox or BaseClass(BaseProtocolStruct)
function CSDeleteBox:__init()
	self:InitMsgType(8, 37)
	self.series = 0 -- 物品的guid
end

function CSDeleteBox:Encode()
	self:WriteBegin()
	CommonReader.WriteSeries(self.series)
end

--===================================下发==================================

-- 下发删除一个物品
SCDeleteOneItem = SCDeleteOneItem or BaseClass(BaseProtocolStruct)
function SCDeleteOneItem:__init()
	self:InitMsgType(8, 1)
	self.series = 0
end

function SCDeleteOneItem:Decode()
	self.series = CommonReader.ReadSeries()
end

-- 添加一个新物品到背包
SCAddOneItemToBag = SCAddOneItemToBag or BaseClass(BaseProtocolStruct)
function SCAddOneItemToBag:__init()
	self:InitMsgType(8, 2)
	self.reason = 0
	self.equip = CommonStruct.ItemDataWrapper()
end

function SCAddOneItemToBag:Decode()
	self.reason = MsgAdapter.ReadUChar() 
	self.equip = CommonReader.ReadItemData()
end

-- 物品的数量发生改变
SCItemChangeNum = SCItemChangeNum or BaseClass(BaseProtocolStruct)
function SCItemChangeNum:__init()
	self:InitMsgType(8, 3)
	self.series = 0
	self.num = 0
end

function SCItemChangeNum:Decode()
	self.series = CommonReader.ReadSeries()
	self.num = MsgAdapter.ReadUShort()
end

-- 玩家的背包物品
SCRoleBagItemList = SCRoleBagItemList or BaseClass(BaseProtocolStruct)
function SCRoleBagItemList:__init()
	self:InitMsgType(8, 4)
	self.pack_idx = 0	--数据包索引
	self.item_list = {}
end

function SCRoleBagItemList:Decode()
	self.pack_idx = MsgAdapter.ReadInt()
	self.item_list = {}
	local num = MsgAdapter.ReadUShort()
	for i = 0, num - 1 do
		self.item_list[i] = CommonReader.ReadItemData()
	end
end

-- 获取背包扩展需要的费用
SCExpandBagCost = SCExpandBagCost or BaseClass(BaseProtocolStruct)
function SCExpandBagCost:__init()
	self:InitMsgType(8, 5)
	self.is_can_expand = 0						-- 1能扩展背包
	self.cost = 0
end

function SCExpandBagCost:Decode()
	self.is_can_expand = MsgAdapter.ReadUChar()
	self.cost = MsgAdapter.ReadInt()
end

-- 操作物品结果
SCEnhanceItemResult = SCEnhanceItemResult or BaseClass(BaseProtocolStruct)
function SCEnhanceItemResult:__init()
	self:InitMsgType(8, 8)
	self.series = 0
	self.enhance_type = 0
	self.result = 0								-- 1成功, 0失败
end

function SCEnhanceItemResult:Decode()
	self.series = CommonReader.ReadSeries()
	self.enhance_type = MsgAdapter.ReadUChar()
	self.result = MsgAdapter.ReadUChar()
end

-- 下发某件装备的信息发生变化
SCOneItemInfoChange = SCOneItemInfoChange or BaseClass(BaseProtocolStruct)
function SCOneItemInfoChange:__init()
	self:InitMsgType(8, 9)
	self.equip = CommonStruct.ItemDataWrapper()
end

function SCOneItemInfoChange:Decode()
	self.equip = CommonReader.ReadItemData()
end

-- 使用物品的结果
SCUseItemResult = SCUseItemResult or BaseClass(BaseProtocolStruct)
function SCUseItemResult:__init()
	self:InitMsgType(8, 10)
	self.item_id = 0
	self.result = 0
end

function SCUseItemResult:Decode()
	self.item_id = MsgAdapter.ReadUShort()
	self.result = MsgAdapter.ReadUChar()
end

-- 已弃用 背包获得了一件新的装备(脱下装备和合并,放到仓库不提示获得物品)
SCBagGetNewEquip = SCBagGetNewEquip or BaseClass(BaseProtocolStruct)
function SCBagGetNewEquip:__init()
	self:InitMsgType(8, 13)
	self.series = 0
	self.get_channel = 0					-- 0：其他路径获取  1：主线任务获取 
end

function SCBagGetNewEquip:Decode()
	self.series = CommonReader.ReadSeries()
	self.get_channel = MsgAdapter.ReadUChar()
end

-- 一个物品的时间到期，被系统收回了
SCOneItemExpire = SCOneItemExpire or BaseClass(BaseProtocolStruct)
function SCOneItemExpire:__init()
	self:InitMsgType(8, 14)
	self.series = 0
	self.item_pos = 0					-- 物品位置，0表示背包，1表示装备，2表示仓库
end

function SCOneItemExpire:Decode()
	self.series = CommonReader.ReadSeries()
	self.item_pos = MsgAdapter.ReadUChar()
end

-- 背包添加新的道具
SCBagAddNewItem = SCBagAddNewItem or BaseClass(BaseProtocolStruct)
function SCBagAddNewItem:__init()
	self:InitMsgType(8, 16)
	self.item_id = 0
	self.item_num = 0
	self.item_pos = 0					-- 物品位置，0表示背包，1表示装备，2表示仓库
end

function SCBagAddNewItem:Decode()
	self.item_id = MsgAdapter.ReadUShort()
	self.item_num = MsgAdapter.ReadUChar()
	self.item_pos = MsgAdapter.ReadUChar()
end

-- 下发合成装备结果
SCComposeEquipResult = SCComposeEquipResult or BaseClass(BaseProtocolStruct)
function SCComposeEquipResult:__init()
	self:InitMsgType(8, 19)
	self.item_id = 0
	self.item_type = 0						-- 1装备合成, 2材料合成
	--self.result = 0 	
end

function SCComposeEquipResult:Decode()
	self.item_id = MsgAdapter.ReadUShort()
	self.item_type = MsgAdapter.ReadUChar()
	--self.result = MsgAdapter.ReadUChar()
end

-- 别人给予物品后的通知
SCOtherGiveItemsNotification = SCOtherGiveItemsNotification or BaseClass(BaseProtocolStruct)
function SCOtherGiveItemsNotification:__init()
	self:InitMsgType(8, 21)
end

function SCOtherGiveItemsNotification:Decode()
end

-- 背包不够容纳本次奖励物品
SCBagIsNotEnough = SCBagIsNotEnough or BaseClass(BaseProtocolStruct)
function SCBagIsNotEnough:__init()
	self:InitMsgType(8, 22)
end

function SCBagIsNotEnough:Decode()
end

-- 砸金蛋结果
SCBreakGoldenEggsResult = SCBreakGoldenEggsResult or BaseClass(BaseProtocolStruct)
function SCBreakGoldenEggsResult:__init()
	self:InitMsgType(8, 23)
	self.random_index = 0
	self.golden_eggs = {}
end

function SCBreakGoldenEggsResult:Decode()
	self.random_index = MsgAdapter.ReadUChar()
	local num = MsgAdapter.ReadUChar()
	self.golden_eggs = {}
	for i=1,num do
		self.golden_eggs[i].item_type = MsgAdapter.ReadUChar()
		self.golden_eggs[i].item_id = MsgAdapter.ReadUShort()
		self.golden_eggs[i].item_num = MsgAdapter.ReadInt()
	end
end

-- 下发消费排名
SCConsumeItemRankInfo = SCConsumeItemRankInfo or BaseClass(BaseProtocolStruct)
function SCConsumeItemRankInfo:__init()
	self:InitMsgType(8, 26)
	self.yesterday_rank = {}
	self.total_rank = {}
end 

function SCConsumeItemRankInfo:Decode()
	local max_num = MsgAdapter.ReadUChar()

	self.yesterday_rank = {}
	if MsgAdapter.ReadUChar() == 1 then
		for i=1,max_num do
			self.yesterday_rank[i] = MsgAdapter.ReadStr()
		end
	end
	
	self.total_rank = {}
	if MsgAdapter.ReadUChar() == 1 then
		for i=1,max_num do
			self.total_rank[i] = MsgAdapter.ReadStr()
		end
	end
end

-- 下发炼金结果
SCAlchemyResult = SCAlchemyResult or BaseClass(BaseProtocolStruct)
function SCAlchemyResult:__init()
	self:InitMsgType(8, 30)
	self.result = -1							-- -1失败, >0剩余时间, 0成功
end 

function SCAlchemyResult:Decode()
	self.result = MsgAdapter.ReadInt()
end

-- 下发镶嵌结果(如果没有收到此协议，说明失败了)
SCInlayResult = SCInlayResult or BaseClass(BaseProtocolStruct)
function SCInlayResult:__init()
	self:InitMsgType(8, 31)
end 

function SCInlayResult:Decode()
end

-- 装备分解结果
SCEquipDecompResult = SCEquipDecompResult or BaseClass(BaseProtocolStruct)
function SCEquipDecompResult:__init()
	self:InitMsgType(8, 32)
	self.decomp_result = 0
end

function SCEquipDecompResult:Decode()
	self.decomp_result = MsgAdapter.ReadUChar()
end

-- 战魂兑换结果
SCWarsoulConvert = SCWarsoulConvert or BaseClass(BaseProtocolStruct)
function SCWarsoulConvert:__init()
	self:InitMsgType(8, 33)
	self.left_convert_times = {}
end

function SCWarsoulConvert:Decode()
	self.left_convert_times = {}
	for i = 1, ComposeData.GetWarsoulCfgLen() do
		self.left_convert_times[i] = MsgAdapter.ReadUChar()
	end
end

-- 钻石打造结果 成功时item_id是物品id,失败时为0
SCDiamondsCreateResult = SCDiamondsCreateResult or BaseClass(BaseProtocolStruct)
function SCDiamondsCreateResult:__init()
	self:InitMsgType(8, 34)
	self.item_id = 0
end

function SCDiamondsCreateResult:Decode()
	self.item_id = MsgAdapter.ReadInt()
end

-- 合成结果
SCComposeItemResult = SCComposeItemResult or BaseClass(BaseProtocolStruct)
function SCComposeItemResult:__init()
	self:InitMsgType(8, 35)						
	self.item_type = 0 					--合成类型，1-神羽，2-宝石
	self.result = 0 					--合成结果，1-成功，0-失败
end

function SCComposeItemResult:Decode()
	self.item_type = MsgAdapter.ReadUChar()
	self.result = MsgAdapter.ReadUChar()
end