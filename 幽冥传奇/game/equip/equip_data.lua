--------------------------------------------------------
--玩家身上的装备数据管理
--------------------------------------------------------
EquipData = EquipData or BaseClass(BaseData)

-- 装备的存储位置每一个表示什么
EquipData.EquipSlot = {
	itWeaponPos = 0,					-- 武器位置
	itDressPos = 1,						-- 衣服
	itHelmetPos = 2,					-- 头盔
	itNecklacePos = 3,					 -- 项链
	itLeftBraceletPos = 4,				-- 左边的手镯
	itRightBraceletPos = 5,				-- 右边的手镯
	itLeftRingPos = 6,					-- 左边的戒指位置
	itRightRingPos = 7,					-- 右边的戒指位置
	itGirdlePos = 8,					-- 腰带
	itShoesPos = 9,						-- 鞋子	9

	itBaseEquipMaxPos = 9,				-- 基础装备最大位置


	--最新位置定义
	itWarmBloodDivineswordPos = 10,      --热血神剑 10
	itWarmBloodGodNailPos = 11,			--热血神甲
	itWarmBloodElbowPadsPos = 12,		--热血面甲
	itWarmBloodShoulderPadsPos = 13,     --热血护肩
	itWarmBloodPendantPos = 14,			--热血吊坠
	itWarmBloodKneecapPos = 15,			--热血护膝     15
	itWarmBloodEquipMaxPos = 15,         --热血装备最大位置

	itHandedDownWeaponPos=16,--传世_武器  16
	itHandedDownDressPos = 17,			--传世_衣服
	itHandedDownHelmetPos = 18,			--传世_头盔
	itHandedDownNecklacePos = 19,		--传世_项链
	itHandedDownLeftBraceletPos = 20,	--传世_左手镯
	itHandedDownRightBraceletPos = 21,	--传世_右手镯
	itHandedDownLeftRingPos = 22,		--传世_左戒指
	itHandedDownRightRingPos = 23,		--传世_右戒指
	itHandedDownGirdlePos = 24,			--传世_腰带
	itHandedDownShoesPos = 25,			--传世_鞋子
	itHandedDownEquipMaxPos = 25,  		-- 传世装备最大位置


	itGlovePos = 26,  --灭霸_手套 26

	itSpecialRingLeftPos = 27,				--左边特戒 27
	itSpecialRingRightPos = 28,				--右边特戒 28

	itMinLuxuryEquipPos = 29,
	itSubmachineGunPos = 29,			--冲锋枪 29
	itOpenCarPos = 30,				--敞篷车
	itAnCrownPos=31,				--皇冠
	itGoldenSkullPos =32,			--金骷髅
	itGoldChainPos=33,				-- 金链子
	itGoldPipePos = 34,				--金烟斗
	itGoldDicePos = 35,				--金骰子
	itGlobeflowerPos = 36,			--金莲花
	itJazzHatPos = 37,				-- 爵士帽
	itRolexPos= 38,					--劳力士
	itDiamondRingPos = 39,			--钻戒
	itGentlemenBootsPos = 40,		--绅士靴 40
	itMaxLuxuryEquipPos = 40,

	itKillArrayShaPos = 41,			--杀阵_天煞 41
	itKillArrayMostPos = 42,			--杀阵_天绝
	itKillArrayRobberyPos = 43,		--杀阵_天劫
	itKillArrayLifePos = 44,			--杀阵_天命 44

	itGodWarHelmetPos = 45,			--战神_头盔	45
	itGodWarNecklacePos = 46,		--战神_项链
	itGodWarLeftBraceletPos = 47,	--战神_左手镯
	itGodWarRightBraceletPos= 48,	--战神_右手镯
	itGodWarLeftRingPos = 49,		--战神_左戒指
	itGodWarRightRingPos = 50,		--战神_右戒指
	itGodWarGirdlePos = 51,			--战神_腰带
	itGodWarShoesPos =52,			--战神_鞋子 52
	-- itMaxEquipPos = 52,
}




require("scripts/game/equip/equip_changshi_data")

-- 装备左右手
EquipData.EQUIP_HAND_POS = {
	LEFT = 0,
	RIGHT = 1,
}

-- 装备的左右手位置 缺省为左手
EquipData.SLOT_HAND_POS = {
	[EquipData.EquipSlot.itRightBraceletPos] = EquipData.EQUIP_HAND_POS.RIGHT,
	[EquipData.EquipSlot.itRightRingPos] = EquipData.EQUIP_HAND_POS.RIGHT,
	[EquipData.EquipSlot.itHandedDownRightBraceletPos] = EquipData.EQUIP_HAND_POS.RIGHT,
	[EquipData.EquipSlot.itHandedDownRightRingPos] = EquipData.EQUIP_HAND_POS.RIGHT,
	[EquipData.EquipSlot.itSpecialRingRightPos] = EquipData.EQUIP_HAND_POS.RIGHT,
	[EquipData.EquipSlot.itGodWarRightBraceletPos] = EquipData.EQUIP_HAND_POS.RIGHT,
	[EquipData.EquipSlot.itGodWarRightRingPos] = EquipData.EQUIP_HAND_POS.RIGHT,
}

-- 物品类型对应的装备位置
-- 0左 1右
EquipData.ItemTypeToSlot = {
	[ItemData.ItemType.itWeapon]   = {[0] = EquipData.EquipSlot.itWeaponPos},
	[ItemData.ItemType.itDress]    = {[0] = EquipData.EquipSlot.itDressPos},
	[ItemData.ItemType.itHelmet]   = {[0] = EquipData.EquipSlot.itHelmetPos},
	[ItemData.ItemType.itNecklace] = {[0] = EquipData.EquipSlot.itNecklacePos},
	[ItemData.ItemType.itBracelet] = {[0] = EquipData.EquipSlot.itLeftBraceletPos, EquipData.EquipSlot.itRightBraceletPos},
	[ItemData.ItemType.itRing]     = {[0] = EquipData.EquipSlot.itLeftRingPos, EquipData.EquipSlot.itRightRingPos},
	[ItemData.ItemType.itGirdle]   = {[0] = EquipData.EquipSlot.itGirdlePos},
	[ItemData.ItemType.itShoes]    = {[0] = EquipData.EquipSlot.itShoesPos},



	[ItemData.ItemType.itHandedDownDress]    = {[0] = EquipData.EquipSlot.itHandedDownDressPos},
	[ItemData.ItemType.itHandedDownHelmet]   = {[0] = EquipData.EquipSlot.itHandedDownHelmetPos},
	[ItemData.ItemType.itHandedDownNecklace] = {[0] = EquipData.EquipSlot.itHandedDownNecklacePos},
	[ItemData.ItemType.itHandedDownBracelet] = {[0] = EquipData.EquipSlot.itHandedDownLeftBraceletPos, EquipData.EquipSlot.itHandedDownRightBraceletPos},
	[ItemData.ItemType.itHandedDownRing]     = {[0] = EquipData.EquipSlot.itHandedDownLeftRingPos, EquipData.EquipSlot.itHandedDownRightRingPos},
	[ItemData.ItemType.itHandedDownGirdle]   = {[0] = EquipData.EquipSlot.itHandedDownGirdlePos},
	[ItemData.ItemType.itHandedDownShoes]    = {[0] = EquipData.EquipSlot.itHandedDownShoesPos},
	[ItemData.ItemType.itHandedDownWeapon]   = {[0] = EquipData.EquipSlot.itHandedDownWeaponPos},
	[ItemData.ItemType.itSpecialRing]		 = {[0] = EquipData.EquipSlot.itSpecialRingLeftPos, EquipData.EquipSlot.itSpecialRingRightPos},

    [ItemData.ItemType.itSubmachineGun]      ={[0] = EquipData.EquipSlot.itSubmachineGunPos},
    [ItemData.ItemType.itOpenCar]            ={[0] = EquipData.EquipSlot.itOpenCarPos},
    [ItemData.ItemType.itAnCrown]            ={[0] = EquipData.EquipSlot.itAnCrownPos},
    [ItemData.ItemType.itGoldenSkull]        ={[0] = EquipData.EquipSlot.itGoldenSkullPos},
    [ItemData.ItemType.itGoldChain]          ={[0] = EquipData.EquipSlot.itGoldChainPos},
    [ItemData.ItemType.itGoldPipe]           ={[0] = EquipData.EquipSlot.itGoldPipePos},
    [ItemData.ItemType.itGoldDice]           ={[0] = EquipData.EquipSlot.itGoldDicePos},
    [ItemData.ItemType.itGlobeflower]        ={[0] = EquipData.EquipSlot.itGlobeflowerPos},
    [ItemData.ItemType.itJazzHat]            ={[0] = EquipData.EquipSlot.itJazzHatPos},
    [ItemData.ItemType.itRolex]              ={[0] = EquipData.EquipSlot.itRolexPos},
    [ItemData.ItemType.itDiamondRing]        ={[0] = EquipData.EquipSlot.itDiamondRingPos},
    [ItemData.ItemType.itGentlemenBoots]     ={[0] = EquipData.EquipSlot.itGentlemenBootsPos},
    [ItemData.ItemType.itGlove]     		 ={[0] = EquipData.EquipSlot.itGlovePos},

 -- --    --新热血装备
    [ItemData.ItemType.itWarmBloodDivinesword] = {[0] = EquipData.EquipSlot.itWarmBloodDivineswordPos},     -- 热血神剑
	[ItemData.ItemType.itWarmBloodGodNail] = {[0] = EquipData.EquipSlot.itWarmBloodGodNailPos},        -- 热血神甲
	[ItemData.ItemType.itWarmBloodElbowPads] = {[0] = EquipData.EquipSlot.itWarmBloodElbowPadsPos},      -- 热血面甲
	[ItemData.ItemType.itWarmBloodShoulderPads] = {[0] = EquipData.EquipSlot.itWarmBloodShoulderPadsPos},	-- 热血护肩
	--[ItemData.ItemType.itWarmBloodHats] = {[0] = EquipData.EquipSlot.itWarmBloodHatsPos},			-- 热血斗笠
	--[ItemData.ItemType.itWarmBloodWarDrum] = {[0] = EquipData.EquipSlot.itWarmBloodWarDrumPos},		-- 热血战鼓
	[ItemData.ItemType.itWarmBloodPendant] = {[0] = EquipData.EquipSlot.itWarmBloodPendantPos},		-- 热血吊坠
	[ItemData.ItemType.itWarmBloodKneecap] = {[0] = EquipData.EquipSlot.itWarmBloodKneecapPos},		-- 热血护膝
	-- --杀神装备
	[ItemData.ItemType.itKillArraySha] = {[0] = EquipData.EquipSlot.itKillArrayShaPos},		-- 天煞
	[ItemData.ItemType.itKillArrayMost] = {[0] = EquipData.EquipSlot.itKillArrayMostPos},		-- 天绝
	[ItemData.ItemType.itKillArrayRobbery] = {[0] = EquipData.EquipSlot.itKillArrayRobberyPos},		-- 杀阵_天劫
	[ItemData.ItemType.itKillArrayLife] = {[0] = EquipData.EquipSlot.itKillArrayLifePos},		-- 天命

	--战神装备
	[ItemData.ItemType.itGodWarHelmet] = {[0] = EquipData.EquipSlot.itGodWarHelmetPos},      --战神--头盔
	[ItemData.ItemType.itGodWarNecklace] = {[0] = EquipData.EquipSlot.itGodWarNecklacePos},	  --战神 -- 项链
	[ItemData.ItemType.itGodWarBracelet] = {[0] = EquipData.EquipSlot.itGodWarLeftBraceletPos, [1] = EquipData.EquipSlot.itGodWarRightBraceletPos},		--战神-- 手镯
	[ItemData.ItemType.itGodWarRing] = {[0] = EquipData.EquipSlot.itGodWarLeftRingPos, [1] = EquipData.EquipSlot.itGodWarRightRingPos},		  --战神-- 戒指
	[ItemData.ItemType.itGodWarGirdle] = {[0] = EquipData.EquipSlot.itGodWarGirdlePos},	--战神-- 腰带
	[ItemData.ItemType.itGodWarShoes] = {[0] = EquipData.EquipSlot.itGodWarShoesPos},		-- 战神-- 鞋子
}

-- 装备位置对应的物品类型
EquipData.SlotToItemType = {}
for item_type, slot_t in pairs(EquipData.ItemTypeToSlot) do
	for _, slot in pairs(slot_t) do
		EquipData.SlotToItemType[slot] = item_type
	end
end

-- 事件
EquipData.CHANGE_ONE_EQUIP = "change_one_equip"
EquipData.CHANGE_EQUIP_REASON = {
	DEL = 1,
	TAKE_OFF = 2,
	PUT_ON = 3,
}

EquipData.CHUANSHI_DATA_CHANGE = "chuanshi_data_change"
EquipData.REXUE_ZHULING_DATA_CHANGE = "rexue_zhuling_data_change"

function EquipData:__init()
	if EquipData.Instance then
		ErrorLog("[EquipData] Attemp to create a singleton twice !")
	end
	EquipData.Instance = self

	-----------------------------------------------------------------------------
	-- 旧代码 begin
	self.grid_data_list = {}	
	self.equip_change_list = {}	
	self.notify_data_change_callback_list = {}		--身上装备有更新变化时进行回调
	self.stone_infos = {} 							--宝石孔列表
	self.fabao_info = {
		fabao_id = 0,
		fabao_gain_time = 0
	}
	self.suit_level = 0
	self.gem_level = 0
	self.godequip_level = 0
	self.level_data = {}
	self.max_stone_data = {}
	self.index_t = {}
	self.suit_level_t = {}
	self.peerless_level = 0
	self.peerless_level_t = {}
	self.peerless_index_t = {}
	self.level_t = {}
	self.god_equip = {}
	self.godequip_level_t = {}	
	self.xiefu_equip_level = 0
	self.zhanhun_equip_level = 0
	-- 旧代码 end
	-----------------------------------------------------------------------------



	self.equip_list = {}
	self:InitChuanShi()
	--self:InitRexueEquip()

	--===豪装套装属性数据=====---------
	--self.suit_type_list = {5,6,7} --默认套装类型
	self.haozhuang_list = {}
	self.type_suit_data = {}
	self.level_suit_data = {}

	self.cur_level_data = {}

	--======传世套装属性===========----------------
	self.chuanshi_list = {}
	self.chuanshi_level_suit_data = {}
	self.chuanshi_level = 0

	---=====普通装备套装属性===
	self.normal_equip_suit_list = {}
	self.normal_suit_type_data = {}
	self.normal_suitLvel_data = {}
	self.cur_normal_level_data = {}
	-----------=====-----------

	--==至尊套装==-----
	self.zhizun_equip_suit_list = {}
	self.zhizun_suitlevel_data = {}
	self.zhizun_level = 0
	--==霸者套装=------
	self.bazhe_equip_suit_list = {}
	self.bazhe_suitlevel_data = {}
	self.bazhe_level = 0
	--==战神套装==---
	self.zhan_shen_equip_list = {}
	self.zhan_shen_level_data = {}
	self.zhan_shen_level = 0
	--===杀神套装=== ---
	self.sha_shen_equip_list = {}
	self.sha_shen_level_data = {}
	self.sha_shen_level = 0
	--===========-----------
	self.special_equip_data = nil

	self:BindGlobalEvent(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind(self.OnRecvMainRoleInfo, self))
	self:BindGlobalEvent(OtherEventType.STRENGTH_INFO_CHANGE, BindTool.Bind(self.StrengthChangeCallback, self))
	self:BindGlobalEvent(OtherEventType.STONE_INLAY_INFO_CHANGE, BindTool.Bind(self.OnStoneInlayChanged, self))
	self:BindGlobalEvent(OtherEventType.MOLDINGSOUL_INFO_CHANGE, BindTool.Bind(self.OnMoldingSoulChanged, self))
	self:BindGlobalEvent(OtherEventType.APOTHEOSIS_INFO_CHANGE, BindTool.Bind(self.OnApotheosisChanged, self))
	self:BindGlobalEvent(OtherEventType.SHENZHU_INFO_CHANGE, BindTool.Bind(self.OnShenzhuChange, self))
end

function EquipData:__delete()
	EquipData.Instance = nil
end

function EquipData:OnRecvMainRoleInfo()
end


function EquipData:SetSpecailData(data)
	self.special_equip_data = data
end

function EquipData:GetSpecailData()
	return self.special_equip_data
end
---------------------------------------------------------------------------------------------------------------------------
-- 装备额外属性

-- 强化索引
-- EquipData.EQ_QH_MAP = {
-- 	[EquipData.EquipSlot.itWeaponPos] = 0,					--武器
-- 	[EquipData.EquipSlot.itDressPos] = 1,					--衣服
-- 	[EquipData.EquipSlot.itHelmetPos] = 2,					--头盔
-- 	[EquipData.EquipSlot.itNecklacePos] = 3,				--项链
-- 	[EquipData.EquipSlot.itLeftBraceletPos] = 4,				--手镯
-- 	[EquipData.EquipSlot.itRightBraceletPos] = 5,				--手镯
-- 	[EquipData.EquipSlot.itLeftRingPos] = 6,					--戒指
-- 	[EquipData.EquipSlot.itRightRingPos] = 7,					--戒指
-- 	[EquipData.EquipSlot.itGirdlePos] = 8,					--腰带
-- 	[EquipData.EquipSlot.itShoesPos] = 9,					--鞋子
-- }
-- EquipData.QH_EQ_MAP = {}
-- for k, v in pairs(EquipData.EQ_QH_MAP) do
-- 	EquipData.QH_EQ_MAP[v] = k
-- end

function EquipData:StrengthChangeCallback(strength_slot)
	if nil ~= strength_slot then
		self:UpdateRoleSelfData(strength_slot)
	else
		for i = 0, EquipData.EquipSlot.itBaseEquipMaxPos do
			self:UpdateRoleSelfData(i)
		end
	end
end

function EquipData:OnStoneInlayChanged(equip_slot)
	if equip_slot then
		self:UpdateRoleSelfData(equip_slot)
	else
		for i = 0, EquipData.EquipSlot.itBaseEquipMaxPos do
			self:UpdateRoleSelfData(i)
		end
	end
end

function EquipData:OnMoldingSoulChanged(equip_slot)
	if equip_slot then
		self:UpdateRoleSelfData(equip_slot)
	else
		for i = 0, EquipData.EquipSlot.itBaseEquipMaxPos do
			self:UpdateRoleSelfData(i)
		end
	end
end

function EquipData:OnApotheosisChanged(equip_slot)
	if equip_slot then
		self:UpdateRoleSelfData(equip_slot)
	else
		for i = 0, EquipData.EquipSlot.itBaseEquipMaxPos do
			self:UpdateRoleSelfData(i)
		end
	end
end

function EquipData:OnShenzhuChange(equip_slot)
	if equip_slot then
		self:UpdateRoleSelfData(equip_slot)
	else
		for i = 0, EquipData.EquipSlot.itBaseEquipMaxPos do
			self:UpdateRoleSelfData(i)
		end
	end
end

function EquipData:UpdateRoleSelfData(slot)
	local equip = self:GetEquipDataBySolt(slot)
	if nil == equip then
		return
	end

	-- 强化等级
	local qh_info = QianghuaData.Instance:GetOneStrengthList(slot)
	equip.strengthen_level = qh_info.strengthen_level

	-- 宝石镶嵌
	local all_inset_info = StoneData.Instance:GetEquipInsetInfo()
	local equip_inset_info = all_inset_info[slot + 1]
	if equip_inset_info then
		for index, v in pairs(equip_inset_info) do
			equip["slot_" .. index] = v.stone_index
		end
	end

	-- 铸魂
	equip.slot_soul = MoldingSoulData.Instance:GetEqSoulLevel(slot + 1)

	-- 精炼
	equip.slot_apotheosis = AffinageData.Instance:GetAffinageLevelBySlot(slot)

	-- 神铸等级
	equip.shenzhu_level, equip.shenzhu_slot = ReXueGodEquipData.Instance:GetShenzhuLevelByEquipSlot(slot)

	-- 神格等级
	equip.shenge_level = ReXueGodEquipData.Instance:GetShengeLevelByEquipSlot(slot)
end
---------------------------------------------------------------------------------------------------------------------------

function EquipData:SetDataList(equip_list)
	self.haozhuang_list = {}
	self.chuanshi_list = {}
	self.normal_equip_list = {}	
	self.bazhe_equip_suit_list = {}
	self.zhizun_equip_suit_list = {}
	self.zhan_shen_equip_list = {}
	self.sha_shen_equip_list = {}
	for k, v in pairs(equip_list) do
		local item_cfg = ItemData.Instance:GetItemConfig(v.item_id)
		local slot = self:GetEquipSlotByType(item_cfg.type, v.hand_pos)
		if slot then
			v.frombody = true	-- 自身装备
			self.equip_list[slot] = v
			self:UpdateRoleSelfData(slot)
		end
		if ( slot >= EquipData.EquipSlot.itSubmachineGunPos and slot <= EquipData.EquipSlot.itGentlemenBootsPos) then
			self.haozhuang_list[slot] = v
		end
		if ( slot >= EquipData.EquipSlot.itWarmBloodDivineswordPos and slot <= EquipData.EquipSlot.itWarmBloodGodNailPos) then
			self.zhizun_equip_suit_list[slot] = v
		end
		if (slot >= EquipData.EquipSlot.itWeaponPos and  slot <= EquipData.EquipSlot.itShoesPos) then
			local config = ItemData.Instance:GetItemConfig(v.item_id)
			if (config.suitId > 0 ) then
				self.normal_equip_list[slot] = v
			end
		end
		if (slot >= EquipData.EquipSlot.itWarmBloodElbowPadsPos and  slot <= EquipData.EquipSlot.itWarmBloodKneecapPos) then
			self.bazhe_equip_suit_list[slot] = v
		end

		if (slot >= EquipData.EquipSlot.itGodWarHelmetPos and  slot <= EquipData.EquipSlot.itGodWarShoesPos) then
			self.zhan_shen_equip_list[slot] = v
		end
		if (slot >= EquipData.EquipSlot.itKillArrayShaPos and  slot <= EquipData.EquipSlot.itKillArrayLifePos) then
			self.sha_shen_equip_list[slot] = v
		end
	end




	self:SetTypeListData()
	--self:SetChuanShiLIstSuit()
	self:SetNormalListData()
	self:SetZhiZunSuitConfig()
	self:SetBazheInfo()
	self:SetZhanShendata()
	self:SetShaShendata()
end

function EquipData:SetTypeListData()
	self.type_suit_data = {}
	for k, v in pairs(HaoZHuangTypeListCfg) do
		self.type_suit_data[v] = {}
		for k1, v1 in pairs(self.haozhuang_list) do
			local config = ItemData.Instance:GetItemConfig(v1.item_id)
			if config.suitType == v then
				table.insert(self.type_suit_data[v], {type = config.type, suitType = v, suit_id = config.suitId, item_data = v1})
			end
		end
	end
	self.level_data_t = {}
	self.cur_level_data = {}
	for k, v in pairs(self.type_suit_data) do
		self.cur_level_data[k] = {suitlevel = 0, count = 0}
		self.level_data_t[k] = {}
		local config = SuitPlusConfig[k]
		for k1, v1 in pairs(config.list) do
			self.level_data_t[k][v1.suitId] = {}
			local data, num = self:GetSuitIdData(v1.suitId, v, v1.count)
			self.level_data_t[k][v1.suitId] = {bool = data, count = num, need_count = v1.count}
			if data > 0 then
				self.cur_level_data[k] = {suitlevel = v1.suitId, count = num}
			end
		end
	end	
end

function EquipData:GetCurDataByType(type)
	return self.cur_level_data[type]
end

function EquipData:GetLevelt(type)
	return self.level_data_t[type]
end

function EquipData:GetSuitIdData(suitId, data, need_count)
	local n = 0
	for k, v in pairs(data) do
		if v.suit_id >= suitId then
			n = n + 1
		end
	end
	if n >= need_count then
		return 1, n
	end
	return 0, n
end

--===普通装备===----------
function EquipData:SetNormalListData()
	self.normal_suit_type_data = {}
	for k, v in pairs(NorMalEquipTypeListCfg) do
		self.normal_suit_type_data[v] = {}
		for k1, v1 in pairs(self.normal_equip_list) do
			local config = ItemData.Instance:GetItemConfig(v1.item_id)
			if config.suitType == v then
				table.insert(self.normal_suit_type_data[v], {type = config.type, suitType = v, suit_id = config.suitId, item_data = v1})
			end
		end
	end

	self.normal_suitLvel_data = {}
	self.cur_normal_level_data = {}
	for k, v in pairs(self.normal_suit_type_data) do
		self.cur_normal_level_data[k] = {suitlevel = 0, count = 0}
		self.normal_suitLvel_data[k] = {}
		local config = SuitPlusConfig[k]
		for k1, v1 in pairs(config.list) do
			self.normal_suitLvel_data[k][v1.suitId] = {}
			local data, num = self:GetNormalSuitIdData(v1.suitId, v, v1.count, config.calctype)
			self.normal_suitLvel_data[k][v1.suitId] = {bool = data, count = num, need_count = v1.count}
			if data > 0 then
				self.cur_normal_level_data[k] = {suitlevel = v1.suitId, count = num}
			end
		end
	end	
end

function EquipData:GetNormalSuitIdData(suitId, data, need_count, calctype)
	local n = 0
	for k, v in pairs(data) do
		if calctype ~= 0 then
			if v.suit_id == suitId then
				n = n + 1
			end
		elseif calctype == 0 then
			if v.suit_id == suitId then
				n = n + 1
			end
		end
	end
	if n >= need_count then
		return 1, n
	end
	return 0, n
end

function EquipData:GetCurNomalDataByType(type)
	return self.cur_normal_level_data[type]
end

function EquipData:GetNoemalLevelt(type)
	return self.normal_suitLvel_data[type]
end

function EquipData:GetNormalText(suittype, suitlevel, config)
	local suit_level_data = self:GetNoemalLevelt(suittype)
	local cur_suit_level_data = suit_level_data[suitlevel] or suit_level_data[1]

	local cur_config = config.list[suitlevel] or config.list[1]
	local name = cur_config.name 

	local color = cur_suit_level_data.bool > 0 and "00ff00" or "a6a6a6"

	
	local text6 = cur_suit_level_data.bool > 0 and Language.HaoZhuang.active[2] or Language.HaoZhuang.active[1]
	local text1 = string.format("{color;%s;%s}", color, name .. "  " .. text6) .. "\n"
	

	local text2 = "" 
	local type_data = NormalListSuitTypeByType[suittype]
	for k, v in pairs(type_data) do
		local name = Language.EquipTypeName[v]
		local slot = self:GetEquipSlotByType(v, 0)
		if  v == ItemData.ItemType.itBracelet or v == ItemData.ItemType.itRing then --右边戒指和右边手镯
			slot1 = self:GetEquipSlotByType(v, 1)
		end
		
		local equip = EquipData.Instance:GetEquipDataBySolt(slot) 
		local equip2 =  EquipData.Instance:GetEquipDataBySolt(slot1)
		local color = "a6a6a6"
		if v == ItemData.ItemType.itBracelet or v == ItemData.ItemType.itRing then
			if equip or equip2 then
				local item_config1 = ItemData.Instance:GetItemConfig(equip and equip.item_id or 0)
				local item_config2 = ItemData.Instance:GetItemConfig(equip2 and equip2.item_id or 0)
				if config.calctype ~= 0 then
					if item_config1.suitId == suitlevel or item_config2.suitId == suitlevel then 
						color = "00ff00"
					end
				elseif config.calctype == 0 then
					if item_config.suitId >= suitlevel or item_config2.suitId >= suitlevel then 
						color = "00ff00"
					end
				end
			end
		else
			if equip then
				local item_config = ItemData.Instance:GetItemConfig(equip.item_id)
				if config.calctype ~= 0 then
					if item_config.suitId == suitlevel then 
						color = "00ff00"
					end
				elseif config.calctype == 0 then
					if item_config.suitId >= suitlevel then 
						color = "00ff00"
					end
				end
			end
		end
		text2 = text2 .. string.format(Language.HaoZhuang.active2, color, name) .. " "
	end
	local text3 = string.format(Language.HaoZhuang.active1, text2) .. "\n"


	local attr = cur_config.attrs
	local normat_attrs, special_attr =  RoleData.Instance:GetSpecailAttr(attr)

	local bool_color = cur_suit_level_data.bool > 0 and "ffffff" or "a6a6a6"
	local bool_color1 = cur_suit_level_data.bool > 0 and "ff0000" or "a6a6a6"
	local text4 =  string.format("{color;%s;%s}", "dcb73d", "基础属性：") .. "\n" .. string.format("{color;%s;%s}", bool_color, RoleData.FormatAttrContent(attr)) .."\n"
	local text5 = ""
	local text = text1..text3..text4..text5
	return text
end

--==-----------
function EquipData:PutOnEquip(equip)
	local item_cfg = ItemData.Instance:GetItemConfig(equip.item_id)
	local slot = self:GetEquipSlotByType(item_cfg.type, equip.hand_pos)
	
	if slot then
		equip.frombody = true	-- 自身装备
		self.equip_list[slot] = equip
		self:UpdateRoleSelfData(slot)
		self:DispatchEvent(EquipData.CHANGE_ONE_EQUIP, {reason = EquipData.CHANGE_EQUIP_REASON.PUT_ON, slot = slot})
		BagData.ResetRecycelEquipList()

		if ( slot >= EquipData.EquipSlot.itSubmachineGunPos and slot <= EquipData.EquipSlot.itGentlemenBootsPos) then
			self.haozhuang_list[slot] = equip
			self:SetTypeListData()
		end
		--屏蔽传世
		-- if ( slot >= EquipData.EquipSlot.itHandedDownWeaponPos and slot <= EquipData.EquipSlot.itHandedDownShoesPos) then
		-- 	self.chuanshi_list[slot] = equip
		-- 	self:SetChuanShiLIstSuit()
		-- end

		if ( slot >= EquipData.EquipSlot.itWarmBloodDivineswordPos and slot <= EquipData.EquipSlot.itWarmBloodGodNailPos) then
			self.zhizun_equip_suit_list[slot] = equip
			self:SetZhiZunSuitConfig()
		end

		if (slot >= EquipData.EquipSlot.itWeaponPos and  slot <= EquipData.EquipSlot.itShoesPos) then
			local config = ItemData.Instance:GetItemConfig(equip.item_id)
			if (config.suitId > 0 ) then
				self.normal_equip_list[slot] = equip
				self:SetNormalListData()
			end
		end

		if (slot >= EquipData.EquipSlot.itWarmBloodElbowPadsPos and  slot <= EquipData.EquipSlot.itWarmBloodKneecapPos) then
			self.bazhe_equip_suit_list[slot] = equip
			self:SetBazheInfo()
		end
		if (slot >= EquipData.EquipSlot.itGodWarHelmetPos and  slot <= EquipData.EquipSlot.itGodWarShoesPos) then
			self.zhan_shen_equip_list[slot] = equip
			self:SetZhanShendata()
		end

		if (slot >= EquipData.EquipSlot.itKillArrayShaPos and  slot <= EquipData.EquipSlot.itKillArrayLifePos) then
			self.sha_shen_equip_list[slot] = equip
			self:SetShaShendata()
		end
	end 
	
end




function EquipData:DelOneEquip(series)
	local equip, slot = self:GetEquipBySeries(series)
	if slot then
		equip.num = 0
		local last_equip = self.equip_list[slot]
		self.equip_list[slot] = nil
		self:DispatchEvent(EquipData.CHANGE_ONE_EQUIP, {reason = EquipData.CHANGE_EQUIP_REASON.DEL, slot = slot, last_equip = last_equip})
		BagData.ResetRecycelEquipList()

		if ( slot >= EquipData.EquipSlot.itSubmachineGunPos and slot <= EquipData.EquipSlot.itGentlemenBootsPos) then
			self.haozhuang_list[slot] = nil
			self:SetTypeListData()
		end


		-- if ( slot >= EquipData.EquipSlot.itHandedDownWeaponPos and slot <= EquipData.EquipSlot.itHandedDownShoesPos) then
		-- 	self.chuanshi_list[slot] = nil
		-- 	self:SetChuanShiLIstSuit()
		-- end

		if ( slot >= EquipData.EquipSlot.itWarmBloodDivineswordPos and slot <= EquipData.EquipSlot.itWarmBloodGodNailPos) then
			self.zhizun_equip_suit_list[slot] = nil
			self:SetZhiZunSuitConfig()
		end

		if (slot >= EquipData.EquipSlot.itWeaponPos and  slot <= EquipData.EquipSlot.itShoesPos) then
			local config = ItemData.Instance:GetItemConfig(equip.item_id)
			if (config.suitId > 0 ) then
				self.normal_equip_list[slot] = nil
				self:SetNormalListData()
			end
		end

		if (slot >= EquipData.EquipSlot.itWarmBloodElbowPadsPos and  slot <= EquipData.EquipSlot.itWarmBloodKneecapPos) then
			self.bazhe_equip_suit_list[slot] = nil
			self:SetBazheInfo()
		end

		if (slot >= EquipData.EquipSlot.itGodWarHelmetPos and  slot <= EquipData.EquipSlot.itGodWarShoesPos) then
			self.zhan_shen_equip_list[slot] = nil
			self:SetZhanShendata()
		end
		if (slot >= EquipData.EquipSlot.itKillArrayShaPos and  slot <= EquipData.EquipSlot.itKillArrayLifePos) then
			self.sha_shen_equip_list[slot] = nil
			self:SetShaShendata()
		end
	end


end

function EquipData:TakeOffOneEquip(series)
	local equip, slot = self:GetEquipBySeries(series)
	if slot then
		equip.num = 0
		self.equip_list[slot] = nil
		self:DispatchEvent(EquipData.CHANGE_ONE_EQUIP, {reason = EquipData.CHANGE_EQUIP_REASON.TAKE_OFF, slot = slot})
		BagData.ResetRecycelEquipList()

		if ( slot >= EquipData.EquipSlot.itSubmachineGunPos and slot <= EquipData.EquipSlot.itGentlemenBootsPos) then
			self.haozhuang_list[slot] = nil
			self:SetTypeListData()
		end

		-- if ( slot >= EquipData.EquipSlot.itHandedDownWeaponPos and slot <= EquipData.EquipSlot.itHandedDownShoesPos) then
		-- 	self.chuanshi_list[slot] = nil
		-- 	self:SetChuanShiLIstSuit()
		-- end

		if ( slot >= EquipData.EquipSlot.itWarmBloodDivineswordPos and slot <= EquipData.EquipSlot.itWarmBloodGodNailPos) then
			self.zhizun_equip_suit_list[slot] = nil
			self:SetZhiZunSuitConfig()
		end

		if (slot >= EquipData.EquipSlot.itWeaponPos and  slot <= EquipData.EquipSlot.itShoesPos) then
			local config = ItemData.Instance:GetItemConfig(equip.item_id)
			if (config.suitId > 0 ) then
				self.normal_equip_list[slot] = nil
				self:SetNormalListData()
			end
		end

		if (slot >= EquipData.EquipSlot.itWarmBloodElbowPadsPos and  slot <= EquipData.EquipSlot.itWarmBloodKneecapPos) then
			self.bazhe_equip_suit_list[slot] = nil
			self:SetBazheInfo()
		end
		if (slot >= EquipData.EquipSlot.itGodWarHelmetPos and  slot <= EquipData.EquipSlot.itGodWarShoesPos) then
			self.zhan_shen_equip_list[slot] = nil
			self:SetZhanShendata()
		end
		if (slot >= EquipData.EquipSlot.itKillArrayShaPos and  slot <= EquipData.EquipSlot.itKillArrayLifePos) then
			self.sha_shen_equip_list[slot] = nil
			self:SetShaShendata()
		end
	end
end

--========z至尊套装属性====---------
function EquipData:SetZhiZunSuitConfig( ... )
	self.zhizun_suitlevel_data = {}
	self.zhizun_level = 0
	local suit_config = SuitPlusConfig[10]
	for k, v in pairs(suit_config.list) do
		self.zhizun_suitlevel_data[v.suitId] = {bool = 0, count = 0, need_count = v.count}
		local bool_data,num = self:GetSuitDataCommon(v.suitId,v.count, self.zhizun_equip_suit_list, suit_config.calctype)
		self.zhizun_suitlevel_data[v.suitId].bool = bool_data
		self.zhizun_suitlevel_data[v.suitId].count = num
		if bool_data > 0 then
			self.zhizun_level = v.suitId
		end
	end
end


function EquipData:GetSuitDataCommon(suitId, count, list, calctype)
	local bool_data = 0
	local num = 0

	for k, v in pairs(list) do
		local config = ItemData.Instance:GetItemConfig(v.item_id)
		if calctype ~= 0 then --不向下兼容
			if config.suitId == suitId then
				num = num + 1
			end
		else
			if config.suitId >= suitId then
				num = num + 1
			end
		end
	end
	if num >= count then
		bool_data = 1
	end
	return bool_data, num
end

function EquipData:GetZhiZunSuitLevel(  )
	return self.zhizun_level
end

function EquipData:GetZunZhiSuitData(  )
	return self.zhizun_suitlevel_data
end

--==--霸者套装------

function EquipData:SetBazheInfo()
	self.bazhe_suitlevel_data = {}
	self.bazhe_level = 0
	local suit_config = SuitPlusConfig[11]
	for k, v in pairs(suit_config.list) do
		self.bazhe_suitlevel_data[v.suitId] = {bool = 0, count = 0, need_count = v.count}
		local bool_data,num = self:GetSuitDataCommon(v.suitId,v.count, self.bazhe_equip_suit_list, suit_config.calctype)
		self.bazhe_suitlevel_data[v.suitId].bool = bool_data
		self.bazhe_suitlevel_data[v.suitId].count = num
		if bool_data > 0 then
			self.bazhe_level = v.suitId
		end
	end
end

function EquipData:GetBaZheSuitLevel()
	return self.bazhe_suitlevel_data
end

function EquipData:GetBazheLevel()
	return self.bazhe_level
end
--==战神套装属性==------
function EquipData:SetZhanShendata( ... )
	self.zhan_shen_level_data = {}
	self.zhan_shen_level = 0
	local suit_config = SuitPlusConfig[12]
	for k, v in pairs(suit_config.list) do
		self.zhan_shen_level_data[v.suitId] = {bool = 0, count = 0, need_count = v.count}
		local bool_data,num = self:GetSuitDataCommon(v.suitId,v.count, self.zhan_shen_equip_list, suit_config.calctype)
		self.zhan_shen_level_data[v.suitId].bool = bool_data
		self.zhan_shen_level_data[v.suitId].count = num
		if bool_data > 0 then
			self.zhan_shen_level = v.suitId
		end
	end
end

function EquipData:GetZhanShenLevel()
	return self.zhan_shen_level
end

function EquipData:GetZhanShenSuitLevel()
	return self.zhan_shen_level_data
end

--=杀神套装属性==-----------
function EquipData:SetShaShendata( ... )
	self.sha_shen_level_data = {}
	self.sha_shen_level = 0
	local suit_config = SuitPlusConfig[13]
	for k, v in pairs(suit_config.list) do
		self.sha_shen_level_data[v.suitId] = {bool = 0, count = 0, need_count = v.count}
		local bool_data,num = self:GetSuitDataCommon(v.suitId,v.count, self.sha_shen_equip_list, suit_config.calctype)
		self.sha_shen_level_data[v.suitId].bool = bool_data
		self.sha_shen_level_data[v.suitId].count = num
		if bool_data > 0 then
			self.sha_shen_level = v.suitId
		end
	end
end

function EquipData:GetShaShenLevel()
	return self.sha_shen_level
end

function EquipData:GetSheShenSuitLevel()
	return self.sha_shen_level_data
end

-- --===传世套装属性===---------
-- function EquipData:SetChuanShiLIstSuit()
-- 	self.chuanshi_level_suit_data = {}
-- 	self.chuanshi_level = 0
-- 	local suit_config = SuitPlusConfig[9] --传世套装类型为9
-- 	for k, v in pairs(suit_config.list) do
-- 		self.chuanshi_level_suit_data[v.suitId] = {bool = 0, count = 0, need_count = v.count}
-- 		local bool_data, num = self:GetChuanSHiSuitData(v.suitId, v.count)
-- 		self.chuanshi_level_suit_data[v.suitId].bool = bool_data
-- 		self.chuanshi_level_suit_data[v.suitId].count = num
-- 		if bool_data > 0 then
-- 			self.chuanshi_level = v.suitId
-- 		end
-- 	end
-- 	--PrintTable(self.chuanshi_level_suit_data)
-- end

-- function EquipData:GetChuanSHiSuitData(suitId, count)
-- 	local bool_data = 0
-- 	local num = 0
-- 	for k, v in pairs(self.chuanshi_list) do
-- 		local config = ItemData.Instance:GetItemConfig(v.item_id)
-- 		if config.suitId >= suitId then
-- 			num = num + 1
-- 		end
-- 	end
-- 	if num >= count then
-- 		bool_data = 1
-- 	end
-- 	return bool_data, num
-- end

-- function EquipData:GetChuanShiSuitLevel()
-- 	return self.chuanshi_level 
-- end

-- function EquipData:GetCHuanhiLevelT()
-- 	return self.chuanshi_level_suit_data
-- end

-- function EquipData:GetChuanShiAllShowText(suitlevel, suitType)
-- 	local config = SuitPlusConfig[suitType]
	

-- 	local cur_suit_level_data = self.chuanshi_level_suit_data[suitlevel] or self.chuanshi_level_suit_data[1]
-- 	local text1 = ""
-- 	if suitlevel <= 0 then
-- 		text1 = string.format(Language.Role.ChuanshiShowTip1, "a6a6a6",Language.Role.ChuanShiSUitName[1], "ff0000", cur_suit_level_data.count, cur_suit_level_data.need_count, "a6a6a6", Language.HaoZhuang.active[1]).."\n"
-- 	else
-- 		local text6 = cur_suit_level_data.bool > 0 and Language.HaoZhuang.active[2] or Language.HaoZhuang.active[1]
-- 		local color1 = cur_suit_level_data.bool > 0 and "00ff00" or "a6a6a6"
-- 		local color2 = cur_suit_level_data.bool > 0 and "00ff00" or "ff0000"
-- 		text1 = string.format(Language.Role.ChuanshiShowTip1, color1,Language.Role.ChuanShiSUitName[1], color2, cur_suit_level_data.count, cur_suit_level_data.need_count, color1, text6).."\n"
-- 	end

-- 	local text2 = "" 
-- 	local text21 = ""
-- 	local text22 = ""
-- 	local type_data = ChuangShiSuitSlot[suitType]
-- 	for k, v in pairs(type_data) do
-- 		local name = Language.Role.ChuanshiEquipname[v]
		
-- 		local equip = self:GetEquipDataBySolt(v)
-- 		local color = "a6a6a6"
-- 		if equip then
-- 			local itemm_config = ItemData.Instance:GetItemConfig(equip.item_id)
		
-- 			if itemm_config.suitId >= suitlevel then
-- 				color = "00ff00"
-- 			end
-- 		end
-- 		if k <= 5 then
-- 			text21 = text21 .. string.format(Language.HaoZhuang.active2, color, name) .. " "
-- 		else
-- 			text22 = text22 .. string.format(Language.HaoZhuang.active2, color, name) .. " "
-- 		end
-- 	end
-- 	local text2 = text21 .. "\n"..text22 .."\n"
	
-- 	local attr_config = config.list[suitlevel] or config.list[1]
-- 	local attr = attr_config.attrs
-- 	local normat_attrs, special_attr =  RoleData.Instance:GetSpecailAttr(attr)

-- 	local bool_color = cur_suit_level_data.bool > 0 and "ffffff" or "a6a6a6"
-- 	local bool_color1 = cur_suit_level_data.bool > 0 and "ff0000" or "a6a6a6"
-- 	local text4 =  string.format("{color;%s;%s}", "dcb73d", "基础属性：") .. "\n" .. string.format("{color;%s;%s}", bool_color, RoleData.FormatAttrContent(normat_attrs)) .."\n"
-- 	local text5 = ""
-- 	if (#special_attr > 0) then
-- 		local special_content = RoleData.FormatRoleAttrStr(special_attr, nil, prof_ignore)
-- 		text5 = string.format("{color;%s;%s}", "dcb73d", "特殊属性：") .. "\n" .. string.format("{color;%s;%s}", bool_color, RoleData.FormatAttrContent(special_attr)) .."\n"
-- 	end
-- 	local text = text1..text2..text4..text5
-- 	return text
-- end

--==-----传世套装属性===-----
function EquipData:GetEquipBySeries(series)
	for k, v in pairs(self.equip_list) do
		if v.series == series then
			return v, k
		end
	end
end

function EquipData:GetEquipData()
	return self.equip_list
end

function EquipData:GetEquipDataBySolt(slot)
	return self.equip_list[slot]
end

-- 根据物品类型和左右手得到装备位置
function EquipData:GetFreeHandPosByType(type)
	local slot = EquipData.ItemTypeToSlot[type]
	if slot[1] then
		if nil == self.equip_list[slot[0]] then
			return slot[0]
		end
		return slot[1]
	end
	return slot[0]
end

-- 根据物品类型和左右手得到装备位置
function EquipData:GetEquipSlotByType(type, hand_pos)
	local slot = EquipData.ItemTypeToSlot[type]
	if slot then
		hand_pos = hand_pos or EquipData.EQUIP_HAND_POS.LEFT
		return slot[hand_pos]
	end
	return -1
end

-- 根据装备位置得到物品类型
function EquipData:GetTypeByEquipSlot(slot)
	return EquipData.SlotToItemType[slot] or -1
end

function EquipData.GetEquipHandPos(equip_slot)
	return EquipData.SLOT_HAND_POS[equip_slot] or EquipData.EQUIP_HAND_POS.LEFT
end

-- 是否可以装备
function EquipData.CanEquip(equip_data, ignore_t)
	if nil == equip_data then
		return false
	end

	if ignore_t == true then return true end

	ignore_t = ignore_t or {}

	local item_cfg = ItemData.Instance:GetItemConfig(equip_data.item_id)	
	for k, v in pairs(item_cfg.conds) do
		if nil == ignore_t[v.cond] then
			if v.cond == ItemData.UseCondition.ucLevel then
				if not RoleData.Instance:IsEnoughLevelZhuan(v.value) then
					return false
				end
			end
			if v.cond == ItemData.UseCondition.ucMinCircle then
				if v.value > RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE) then
					return false
				end
			end
			if v.cond == ItemData.UseCondition.ucGender then
				if v.value ~= RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SEX) then
					return false
				end
			end
			if v.cond == ItemData.UseCondition.ucJob then
				if v.value ~= 0 and v.value ~= RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF) then
					return false
				end
			end
		end
	end

	return true
end

function EquipData.CheckHasLimit(item_cfg, ignore_level)
	for k, v in pairs(item_cfg.conds) do
		if v.cond == ItemData.UseCondition.ucLevel then
			if not ignore_level and not RoleData.Instance:IsEnoughLevelZhuan(v.value) then
				return true
			end
		end
		if v.cond == ItemData.UseCondition.ucMinCircle then
			if not ignore_level and v.value > RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE) then
				return true
			end
		end
		if v.cond == ItemData.UseCondition.ucGender then
			if v.value ~= RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SEX) then
				return true
			end
		end
		if v.cond == ItemData.UseCondition.ucJob then
			if v.value ~= 0 and v.value ~= RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF) then
				return true
			end
		end
		-- if v.cond == ItemData.UseCondition.ucRuneSuitID and boss_index then
		-- 	if v.value ~= boss_index then
		-- 		return true
		-- 	end
		-- end
		-- if v.cond == ItemData.UseCondition.ucRuneTakeOnPos and fuwen_index then
		-- 	if v.value ~= fuwen_index then
		-- 		return true
		-- 	end
		-- end
	end
	return ItemData.Instance:GetItemUseLimit(item_cfg.item_id)
end

-- 获取背包和身上战力最高的基础装备组合
local normal_equip_list = {
	[EquipData.EquipSlot.itWeaponPos]        = {score = 0},
	[EquipData.EquipSlot.itDressPos]         = {score = 0},
	[EquipData.EquipSlot.itHelmetPos]        = {score = 0},
	[EquipData.EquipSlot.itNecklacePos]      = {score = 0},
	[EquipData.EquipSlot.itLeftBraceletPos]  = {score = 0},
	[EquipData.EquipSlot.itRightBraceletPos] = {score = 0},
	[EquipData.EquipSlot.itLeftRingPos]      = {score = 0},
	[EquipData.EquipSlot.itRightRingPos]     = {score = 0},
	[EquipData.EquipSlot.itGirdlePos]        = {score = 0},
	[EquipData.EquipSlot.itShoesPos]         = {score = 0},
	[EquipData.EquipSlot.itSpecialRingLeftPos] = {score = 0},
	[EquipData.EquipSlot.itSpecialRingRightPos]= {score = 0},}
function EquipData:GetBestEquipList()
	for k, v in pairs(normal_equip_list) do
		local equip = self:GetEquipDataBySolt(k)
		-- 最好的装备（初始为身上的装备）
		v.score = ItemData.Instance:GetItemScoreByData(equip)
		v.best_equip_data = equip

		-- 当前身上的装备
		v.now_equip_score = v.score
		v.now_equip_data = equip

		-- 第二好的装备
		v.last_best_equip_data = equip
		v.last_score = v.score
	end

	for k, v in pairs(BagData.Instance:GetItemDataList()) do
		local locked = false	-- 判断中的装备锁定中
		for _, hand_pos in pairs(EquipData.EQUIP_HAND_POS) do -- 一件装备要同时判断左右手谁更合适
			local equip_slot = self:GetEquipSlotByType(v.type, hand_pos)
			if normal_equip_list[equip_slot] and EquipData.CanEquip(v) then
				local info = normal_equip_list[equip_slot]
				local score = ItemData.Instance:GetItemScoreByData(v)
				if info.score < score then-- 一个比较好的装备
					if locked then -- 左右手准备抢装备
						local another_info
						if hand_pos == EquipData.EQUIP_HAND_POS.LEFT then
							another_info = normal_equip_list[self:GetEquipSlotByType(v.type, EquipData.EQUIP_HAND_POS.RIGHT)]
						else
							another_info = normal_equip_list[self:GetEquipSlotByType(v.type, EquipData.EQUIP_HAND_POS.LEFT)]
						end
						if nil ~= another_info and another_info.last_score > info.score then
							-- 当前位置评分更低,给评分较低的位置
							info.last_best_equip_data = info.best_equip_data
							info.last_score = info.score
							info.best_equip_data = v
							info.score = score

							-- 另一个位置还原为第二好的装备(another要知足，不要那么贪心)
							another_info.best_equip_data = another_info.last_best_equip_data
							another_info.score = another_info.last_score
						end
					else
						info.last_best_equip_data = info.best_equip_data
						info.last_score = info.score
						info.best_equip_data = v
						info.score = score
						locked = true
					end
				end
			end
		end
	end
	return normal_equip_list
end

-- 获取最好的手套
function EquipData:GetBestHandEquip(role_equip)
	local best_eq = role_equip
	local item_type = ItemData.ItemType.itGlove
	for i,v in pairs(BagData.Instance:GetBagItemDataListByType(item_type)) do
		if EquipData.CanEquip(v) then
			if ItemData.Instance:GetItemScoreByData(best_eq) < ItemData.Instance:GetItemScoreByData(v) then
				best_eq = v
			end
		end
	end
	
	return best_eq ~= role_equip and best_eq or nil
end

-- 检查当前装备是否比装备在身上的装备更好
function EquipData:GetIsBetterEquip(item_data, ignore_t)
	if item_data == nil or IS_ON_CROSSSERVER then return false end
	local item_cfg, item_type = ItemData.Instance:GetItemConfig(item_data.item_id)
	if item_cfg == nil or not ItemData.GetIsEquip(item_data.item_id) then
		return false
	end
	if not EquipData.CanEquip(item_data, ignore_t) then
		return false
	end

	-- local item_score = ItemData.Instance:GetItemScoreByData(item_data)
	-- for _, hand_pos in pairs(EquipData.EQUIP_HAND_POS) do
	-- 	local equip_slot = self:GetEquipSlotByType(item_data.type, hand_pos)
	-- 	if nil ~= equip_slot and equip_slot >= 0 then
	-- 		local self_equip = self:GetEquipDataBySolt(equip_slot)
	-- 		if item_score > ItemData.Instance:GetItemScoreByData(self_equip) then
	-- 			return true, hand_pos, equip_slot, item_score
	-- 		end
	-- 	end
	-- end

	local item_score = ItemData.Instance:GetItemScoreByData(item_data)
	if item_cfg.type == ItemData.ItemType.itBracelet
	or item_cfg.type == ItemData.ItemType.itRing
	or item_cfg.type == ItemData.ItemType.itSpecialRing then
		local equip_slot_left = self:GetEquipSlotByType(item_data.type, EquipData.EQUIP_HAND_POS.LEFT)
		local equip_slot_right = self:GetEquipSlotByType(item_data.type, EquipData.EQUIP_HAND_POS.RIGHT)
		local left_equip = self:GetEquipDataBySolt(equip_slot_left)
		local right_equip = self:GetEquipDataBySolt(equip_slot_right)
		if(left_equip and right_equip) then
			local score_left = ItemData.Instance:GetItemScoreByData(left_equip)
			local score_right = ItemData.Instance:GetItemScoreByData(right_equip)
			if(score_left < score_right) then 		--左边装备评分小
				if(item_score>score_left) then
					return true, EquipData.EQUIP_HAND_POS.LEFT,equip_slot_left,item_score
				else
					return false
				end
			else
				if(item_score>score_right) then  	--右边装备评分小
					return true, EquipData.EQUIP_HAND_POS.RIGHT,equip_slot_right,item_score
				else
					return false
				end
			end
		elseif(left_equip and right_equip == nil) then
			return true, EquipData.EQUIP_HAND_POS.RIGHT,equip_slot_right,item_score
		elseif(left_equip == nil and right_equip) then
			return true, EquipData.EQUIP_HAND_POS.LEFT,equip_slot_left,item_score
		else
			return true, EquipData.EQUIP_HAND_POS.LEFT,equip_slot_left,item_score
		end
	else
		local equip_slot = self:GetEquipSlotByType(item_data.type, 0)
		if nil ~= equip_slot and equip_slot >= 0 then
			local self_equip = self:GetEquipDataBySolt(equip_slot)
			if item_score > ItemData.Instance:GetItemScoreByData(self_equip) then
				return true, 0, equip_slot, item_score
			end
		end
	end

	return false
end

--===获得最好的热血装备
function EquipData:GetBestRexueByCurRexueData(item_data, slot)
	local is_best = false
	local max_best = item_data
	local item_type = self:GetTypeByEquipSlot(slot)
	local max_score = ItemData.Instance:GetItemScoreByData(item_data)
	for k,v in pairs(BagData.Instance:GetReXueData()) do
		local item_cfg = ItemData.Instance:GetItemConfig(v.item_id)

		if item_cfg.type == item_type then 
			if item_data == nil then
				is_best = true
				max_best = v
				max_score = ItemData.Instance:GetItemScoreByData(v)
			else
				local score = ItemData.Instance:GetItemScoreByData(v)
				if score > max_score then
					is_best = true
					max_best = v
					max_score = score
				end
			end
		end

	end
	return is_best, max_best
end


----------------------------------------------------
-- 热血装备 begin
----------------------------------------------------
-- function EquipData:InitRexueEquip()
-- 	self.rexue_zhuling_data = {}
-- 	for i = EquipData.EquipSlot.itWarmBloodDivineswordPos, EquipData.EquipSlot.itWarmBloodEquipMaxPos do
-- 		self.rexue_zhuling_data[i] = {
-- 			level = 0,	-- 等级
-- 			val = 0,	-- 注灵值
-- 		}
-- 	end

-- 	--RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRexueCanUpRemind, self), RemindName.RexueCanUp)
-- end

-- function EquipData:SetRexueZhuling(slot, level, val)
-- 	slot = EquipData.GetRexueEquipSlotByCfgIndex(slot)

-- 	if self.rexue_zhuling_data[slot] then
-- 		self.rexue_zhuling_data[slot].level = level
-- 		self.rexue_zhuling_data[slot].val = val
-- 		self:DispatchEvent(EquipData.REXUE_ZHULING_DATA_CHANGE)

-- 		RemindManager.Instance:DoRemind(RemindName.RexueCanUp)
-- 	end
-- end

-- function EquipData:GetRexueZhulingData(slot)
-- 	return self.rexue_zhuling_data[slot] or {level = 0, val = 0}
-- end

-- function EquipData.GetRexueEquipSlotByCfgIndex(cfg_slot)
-- 	return cfg_slot + EquipData.EquipSlot.itWarmBloodDivineswordPos
-- end

-- function EquipData.GetRexueCfgSlotIndex(slot)
-- 	return slot - EquipData.EquipSlot.itWarmBloodDivineswordPos
-- end

-- function EquipData.GetRexueConsumeItemTable()
-- 	return WarmBloodEquipConfig.spiritCfg.itemSpirit
-- end

-- function EquipData.GetRexueZhulingConsumeCfg(slot, level)
-- 	slot = EquipData.GetRexueCfgSlotIndex(slot)

-- 	local upSpirit = WarmBloodEquipConfig.spiritCfg.upSpirit
-- 	if upSpirit[slot] and upSpirit[slot][level] then
-- 		return upSpirit[slot][level]
-- 	end
-- end

-- function EquipData.GetRexueZhulingAttrs(slot, level, prof)
-- 	slot = EquipData.GetRexueCfgSlotIndex(slot)
-- 	prof = prof or RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)

-- 	local slot_cfg = ConfigManager.Instance:GetServerConfig("item/itemEnhance/WarmBloodEquipSpiritAttrs/WarmBloodSlot" .. slot .. "SpiritAttrsCfg")
-- 	slot_cfg = slot_cfg and slot_cfg[1]
-- 	if slot_cfg and slot_cfg[prof] then
-- 		return slot_cfg[prof][level] or {}
-- 	end
-- end

-- function EquipData.GetRexueFumoCfg(slot, item_id, prof)
-- 	slot = EquipData.GetRexueCfgSlotIndex(slot)
-- 	prof = prof or RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)

-- 	local EnchantingCfg = WarmBloodEquipConfig.EnchantingCfg
-- 	if EnchantingCfg[slot] and EnchantingCfg[slot][prof] then
-- 		return EnchantingCfg[slot][prof][item_id]
-- 	end
-- end

-- EquipData.REXUE_FLITER_TYPE = {
-- 	BASE_ATTR = 1,
-- 	SPECIAL_ATTR = 2,
-- }
-- function EquipData.RexueAttrsFilter(attr_cfg, fliter_type, prof)
-- 	prof = prof or RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
-- 	local def_cfg = EquipData.GetRexueClientCfg().attr_types[fliter_type]
-- 	def_cfg = def_cfg and def_cfg[prof]
-- 	if nil == def_cfg then
-- 		return attr_cfg
-- 	end

-- 	local map = {}
-- 	for k, v in pairs(def_cfg) do
-- 		map[v] = 1
-- 	end
-- 	local filter_cfg = {}
-- 	for k, v in pairs(attr_cfg) do
-- 		if map[v.type] then
-- 			filter_cfg[#filter_cfg + 1] = v
-- 		end
-- 	end
-- 	return filter_cfg
-- end

-- function EquipData.GetRexueEquipClientCfg(slot, item_id)
-- 	slot = EquipData.GetRexueCfgSlotIndex(slot)
-- 	local rx_client_cfg = EquipData.GetRexueClientCfg()
-- 	if rx_client_cfg and rx_client_cfg.equip_cfg[slot] then
-- 		return rx_client_cfg.equip_cfg[slot][item_id]
-- 	end
-- end

-- function EquipData.GetRexueFirstEquip(slot, prof)
-- 	slot = EquipData.GetRexueCfgSlotIndex(slot)
-- 	prof = prof or RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)

-- 	local EnchantingCfg = WarmBloodEquipConfig.EnchantingCfg
-- 	if EnchantingCfg[slot] and EnchantingCfg[slot][prof] then
-- 		local item_id
-- 		for k, v in pairs(EnchantingCfg[slot][prof]) do
-- 			if item_id == nil then
-- 				item_id = k
-- 			elseif item_id > k then
-- 				item_id = k
-- 			end
-- 		end
-- 		return item_id
-- 	end
-- 	return 
-- end

-- function EquipData.GetRexueClientCfg()
-- 	return ConfigManager.Instance:GetClientConfig("rexue_cfg")
-- end

-- -- 有热血装备可提升
-- function EquipData:GetRexueCanUpRemind()
-- 	for i = EquipData.EquipSlot.itWarmBloodDivineswordPos, EquipData.EquipSlot.itWarmBloodEquipMaxPos do
-- 		if self:GetRexueCanUp(i) > 0 then
-- 			return 1
-- 		end
-- 	end
-- 	return 0
-- end

-- -- 热血装备可操作
-- function EquipData:GetRexueCanUp(equip_slot)
-- 	return (self:GetRexueCanAct(equip_slot) + self:GetRexueCanZhuling(equip_slot) + self:GetRexueCanFumo(equip_slot))
-- end

-- -- 热血装备是否可注灵
-- function EquipData:GetRexueCanZhuling(equip_slot)
-- 	local zl_data = self:GetRexueZhulingData(equip_slot)
-- 	local consume_cfg = EquipData.GetRexueZhulingConsumeCfg(equip_slot, zl_data.level + 1)
-- 	if consume_cfg then
-- 		local item_type = self:GetTypeByEquipSlot(equip_slot)
-- 		local consume_item_table = EquipData.GetRexueConsumeItemTable()
-- 		for k, v in pairs(BagData.Instance:GetItemDataList()) do
-- 			if consume_item_table[v.item_id] and v.type == item_type then
-- 				return 1
-- 			end
-- 		end
-- 	end

-- 	return 0
-- end

-- -- 热血装备是否可激活
-- function EquipData:GetRexueCanAct(equip_slot)
-- 	local equip = self:GetEquipDataBySolt(equip_slot)
-- 	local item_type = self:GetTypeByEquipSlot(equip_slot)
-- 	if nil == equip then
-- 		for k, v in pairs(BagData.Instance:GetItemDataList()) do
-- 			if v.type == item_type then
-- 				return 1
-- 			end
-- 		end
-- 	end
-- 	return 0
-- end

-- -- 热血装备是否可附魔
-- function EquipData:GetRexueCanFumo(equip_slot)
-- 	local equip = self:GetEquipDataBySolt(equip_slot)
-- 	local is_enough = false
-- 	if nil ~= equip then
-- 		local fumo_cfg = EquipData.GetRexueFumoCfg(equip_slot, equip.item_id)
-- 		if fumo_cfg then
-- 			local need_id = fumo_cfg.consume[1].id
-- 			local need_num = fumo_cfg.consume[1].count
-- 			local have_num = BagData.Instance:GetItemNumInBagById(need_id)
-- 			is_enough = have_num >= need_num
-- 		end
-- 	end
-- 	return is_enough and 1 or 0
-- end
----------------------------------------------------
-- 热血装备 end
----------------------------------------------------


------------------------------------------------------------------------------------------------------------------------
-- 豪装
------------------------------------------------------------------------------------------------------------------------
function EquipData:GetLuxuryEquipEffectId(item_id, equip_slot)
	local cfg = HoweEquipSynthesisCfg.effect_list[equip_slot] or {}
	for _, v in pairs(cfg) do
		if v.item_id == item_id then
			return v.effect_id
		end
	end
	return 0
end



































-------------------------------------------------------------------------------------------------------------------------
-- 以下为旧代码
-------------------------------------------------------------------------------------------------------------------------

EquipData.EquipIndex = {------------------------- 废弃的定义，不要用
	MainEquipBeginIndex = 1,	--主装备begin

	Weapon = 1,					--武器
	Dress = 2,					--衣服
	Helmet = 3,					--头盔
	Necklace = 4,				--项链
	Bracelet = 5,				--手镯
	BraceletR  = 6,				--手镯
	Ring = 7,					--戒指
	RingR = 8,					--戒指
	Girdle = 9,					--腰带
	Shoes = 10,					--鞋子

	Meterial = 11,           	--玉佩
	AnklePad = 12,				--官印
	Shield = 13,				--护盾
	Decoration = 14,          	--勋章
	EquipDiamond = 15,        	--宝石
	Seal = 16,              	--圣珠
	SpecialRing = 17,       	--左特殊戒指
	SpecialRingR = 18,       	--右特殊戒指
	WarDrum = 19,				-- 战鼓

	MainEquipEndIndex = 19,		--主装备end

	SecondaryEquipBeginIndex = 20,	--次要的装备begin

	PeerlessBeginIndex = 20,
	PeerlessWeaponPos = 20,		--绝世神装_武器
	PeerlessDressPos = 21,		--绝世神装_衣服
	PeerlessHelmetPos = 22,		--绝世神装_头盔
	PeerlessNecklacePos = 23,	--绝世神装_项链
	PeerlessBraceletPos = 24,	--绝世神装_手镯
	PeerlessBraceletPosR = 25,	--绝世神装_右手镯
	PeerlessRingPos = 26,		--绝世神装_戒指
	PeerlessRingPosR = 27,		--绝世神装_右戒指
	PeerlessGirdlePos = 28,		--绝世神装_腰带
	PeerlessShoesPos = 29,		--绝世神装_鞋子
	PeerlessEndIndex = 29,

	LunhuiBeginIndex = 30,
	ElbowPads = 30,				--面甲
	ShoulderPads = 31,			--护肩
	Earring = 32,				--耳坠
	Kneecap = 33,				--护膝
	HeartMirror = 34,			--护心镜
	LunhuiEndIndex = 35,

	CrossEquipBeginIndex = 36,
	CrossEquipElbowPads = 36,			--六界战装-面甲
	CrossEquipShoulderPads = 37,		--六界战装-护肩
	CrossEquipEarring = 38,				--六界战装-耳坠
	CrossEquipKneecap = 39,				--六界战装-护膝
	CrossEquipHeartMirror = 40,			--六界战装-护心镜
	CrossEquipEndIndex = 41,

	SecondaryEquipEndIndex = 41,	--次要的装备end

	EquipMaxIndex = 41,				--主角装备的最大索引

	Swing = 100,				--翅膀 
	MagicWeapon = 101,			--法宝
	FootPrint = 102,			--足迹
	PrimitiveRingPos = 103, 	--洪荒戒指
	HatsPos = 104,				--斗笠

	WeaponExtend = 200,			--神器
	FashionDress = 201,        	--神甲
}
function EquipData:XuelianChangeCallback(index)
	if index then
		local equip_data = self.grid_data_list[index]
		if equip_data then
			local slot_xuelian = EquipmentData.Instance:GetEqBmLevelByEquipIndex(index)
			equip_data.slot_xuelian = slot_xuelian
			for k,v in pairs(self.notify_data_change_callback_list) do  --物品有变化，通知观察者，带消息体
				v(false, equip_data.item_id, index, 2)	
			end
		end
	else
		for k,v in pairs(self.grid_data_list) do
			local slot_xuelian = EquipmentData.Instance:GetEqBmLevelByEquipIndex(k)
			v.slot_xuelian = slot_xuelian
		end
		for k,v in pairs(self.notify_data_change_callback_list) do  --物品有变化，通知观察者，不带消息体
			v(true)	
		end
	end
end

function EquipData:SortDataList()
	local list = self.grid_data_list
	for k,v in pairs(self.equip_list) do
		ItemData.Instance:GetItemConfig(v.item_id)
		local index = self:GetEquipIndexByType(v.type, v.hand_pos)
		if index >= 0 then
			v.index = index
			local slot_strength = QianghuaData.Instance:GetOneStrengthLvByEquipIndex(index)
			v.slot_strength = slot_strength
			local slot_xuelian = EquipmentData.Instance:GetEqBmLevelByEquipIndex(index)
			v.slot_xuelian = slot_xuelian
			local slot_soul = MoldingSoulData.Instance:GetEqSoulLevelByEquipIndex(index)
			v.slot_soul = slot_soul
			local slot_apotheosis = AffinageData.Instance:GetAffinageLevelBySlot(index - EquipData.EquipIndex.Weapon + 1)
			v.slot_apotheosis = slot_apotheosis
			local inlay_list = StoneData.Instance:GetEquipInsetInfo() and StoneData.Instance:GetEquipInsetInfo()[index - EquipData.EquipIndex.Weapon + 1]
			if inlay_list then
				for k1, v1 in pairs(inlay_list) do 
					v["slot_" .. k1] = v1.stone_index
				end
			end
			local cross_eq_data = CrossServerData.Instance:GetCrossEquipData(index) -- 跨服装备数据
			if cross_eq_data then
				v.cross_stars = cross_eq_data.cross_stars
				v.cross_grade = cross_eq_data.cross_grade
			end
			list[index] = v
			self.equip_list[k] = nil
		end
	end
	for k,v in pairs(self.notify_data_change_callback_list) do  --物品有变化，通知观察者，不带消息体
		v(true)	
	end
end

--得到宝石信息
function EquipData:SetGemLevel()
	-- 找到一个满足条件的加成
	self.gem_level = 0
	for i = #StonePlusCfg, 1, -1 do
		local count = 0
		for k, v in pairs(StoneData.Instance:GetEquipInsetInfo()) do
			local flag = false
			for k1, v1 in pairs(v) do
				local level = StoneData.FormatStoneLevel(v1.stone_index)
				if level >= StonePlusCfg[i].level then
					flag = true
					break
				end
			end
			if flag then
				count = count + 1
			end
		end
		if count == StonePlusCfg[i].count then
			self.gem_level = i
			break
		end
	end

	self.max_stone_data = {}
	for k, v in pairs(StoneData.Instance:GetEquipInsetInfo()) do
		local max_level = 0
		for k1, v1 in pairs(v) do
			local level = StoneData.FormatStoneLevel(v1.stone_index)
			if level >= max_level then
				max_level = level
			end
		end
		self.max_stone_data[k] = max_level
	end
end

function EquipData:SetGodEquipData()
	local sex = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SEX) 
	local config = HallowRuleData.Instance:GetConfig(sex)
	self.god_equip = {}
	for k,v in pairs(self.grid_data_list) do
		if k == EquipData.EquipIndex.WeaponExtend or k == EquipData.EquipIndex.FashionDress then
			self.god_equip[k] = v.item_id
		end
	end 
	self.godequip_level_t = {}	
	self.god_index_t = {}
	for k,v in pairs(self.god_equip) do
		for k1, v1 in pairs(config) do
			for i,v2 in ipairs(v1.items) do
				if v == v2 then
					self.godequip_level_t[k1] = self.godequip_level_t[k1] or 0
					self.godequip_level_t[k1] = self.godequip_level_t[k1] + 1 
					self.god_index_t[k] = k1
				end
			end
		end
	end
	local count = 0
	local level = 0
	self.godequip_level = 0
	self.god_level_t = {}
	local function suit()
		if self.godequip_level_t[level] then
			self.god_level_t[level] = self.godequip_level_t[level]
			for k,v in pairs(self.godequip_level_t) do
				if k > level then
					self.god_level_t[level] = self.god_level_t[level] + v
				end
			end
			if self.god_level_t[level] >= #config[level].items then
				if level >= self.godequip_level then
					self.godequip_level = level
				end
			end
		end
		level = level + 1
		if level <= #config then
			suit()
		end
	end
	suit()
end

function EquipData:GetGodEquipLevel()
	return self.godequip_level
end

function EquipData:GetGodEquipData()
	return self.godequip_level_t
end

function EquipData:GetEquipRuleData()
	return self.god_index_t
end

function EquipData:GetCurrentLevel()
	return self.gem_level
end

function EquipData:GetGemJiaChengData()
	return self.level_data
end

function EquipData:GetGemData()
	return self.max_stone_data
end

--套装ID
function EquipData:SetSuitEquipCount()
	self.suit_level_t = {}
	self.index_t = {}
	local n = 0
	for k,v in pairs(self.grid_data_list) do
		for k1, v1 in pairs(SuitPlusConfig) do
			for i,v2 in ipairs(v1.items) do
				if v.item_id == v2 then
					self.suit_level_t[k1] = self.suit_level_t[k1] or 0
					self.suit_level_t[k1] = self.suit_level_t[k1] + 1 
					self.index_t[k] = k1
				end
			end
		end
	end
	self.level_t = {}
	local level = 1
	self.suit_level = 0
	local count = 0
	local function suit()
		if self.suit_level_t[level] then
			self.level_t[level] = self.suit_level_t[level]
			for k,v in pairs(self.suit_level_t) do
				if k > level then
					self.level_t[level] = self.level_t[level] + v
				end
			end
			if self.level_t[level] >= #SuitPlusConfig[level].items then
				if level >= self.suit_level then
					self.suit_level = level
				end
			end
		end
		level = level + 1
		if level <= #SuitPlusConfig then
			suit()
		end
	end
	suit()
end

--套装等级
function EquipData:GetSuitEquipLevel()
	return self.suit_level
end

--套装等级以及数量
function EquipData:GetSuitLevelList()
	return self.suit_level_t
end

--得到神器装备槽的套装等级以及序列号
function EquipData:GetSuitIndexLevel()
	return self.index_t
end

--绝世套装ID
function EquipData:SetPeerlessEquipCount()
	self.peerless_level_t = {}
	self.peerless_index_t = {}
	local n = 0
	for k,v in pairs(self.grid_data_list) do
		for k1, v1 in pairs(RoleRuleData.Instance:GetPeerlessSuitPlusConfig()) do
			for i,v2 in ipairs(v1.items) do
				if k - EquipData.EquipIndex.PeerlessWeaponPos == i - 1 and v.item_id == v2 then
					self.peerless_level_t[k1] = self.peerless_level_t[k1] or 0
					self.peerless_level_t[k1] = self.peerless_level_t[k1] + 1 
					self.peerless_index_t[k] = k1
				end
			end
		end
	end
	self.level_t = {}
	local level = 1
	self.peerless_level = 0
	local count = 0
	local function suit()
		if self.peerless_level_t[level] then
			self.level_t[level] = self.peerless_level_t[level]
			for k,v in pairs(self.peerless_level_t) do
				if k > level then
					self.level_t[level] = self.level_t[level] + v
				end
			end
			local peerless_cfg = RoleRuleData.Instance:GetPeerlessSuitPlusConfig()[level]
			if peerless_cfg and self.level_t[level] >= #peerless_cfg.items then
				if level >= self.peerless_level then
					self.peerless_level = level
				end
			end
		end
		level = level + 1
		if level <= #RoleRuleData.Instance:GetPeerlessSuitPlusConfig() then
			suit()
		end
	end
	suit()
end

--套装等级
function EquipData:GetPeerlessEquipLevel()
	return self.peerless_level
end

--套装等级以及数量
function EquipData:GetPeerlessLevelList()
	return self.peerless_level_t
end

--得到神器装备槽的套装等级以及序列号
function EquipData:GetPeerlessIndexLevel()
	return self.peerless_index_t
end

function EquipData:GetDataList()
	return self.grid_data_list
end

function EquipData:GetEquipByType(type, hand_pos)
	local index = self:GetEquipIndexByType(type, hand_pos)
	if index >= 0 then
		return self.grid_data_list[index]
	end
end

-- 获取法宝信息
function EquipData:GetFabaoInfo()
	return self.fabao_info
end

-- 获取血符等级
function EquipData:GetXueFuLevel()
	return self.xiefu_equip_level
end

-- 获取战魂等级
function EquipData:GetZhanHunLevel()
	return self.zhanhun_equip_level
end

--获得某个格子的数据
function EquipData:GetGridData(index)
	return self.grid_data_list[index]
end

--获取身上装备数量
function EquipData:GetDataCount()
	local count = 0
	for k,v in pairs(self.grid_data_list) do
		count = count + 1
	end
	return count
end

--改变某个格中的数据
function EquipData:ChangeDataInGrid(data)
	if data == nil then
		return
	end
	if not ItemData.Instance:GetItemConfig(data.item_id) then
		if data.num > 0 then
			table.insert(self.equip_change_list, data)
		end
		return 
	end
	local item_config = ItemData.Instance:GetItemConfig(data.item_id)
	data.index = self:GetEquipIndexByType(item_config.type, data.hand_pos)
	if data.index < 0 then
		return
	end

	local change_reason = 2
	local change_item_id = data.item_id
	local change_item_index = data.index
	local t = self:GetGridData(data.index)
	if t ~= nil and data.num == 0 then --delete
		change_reason = 0
		change_item_id = t.item_id
		self.grid_data_list[data.index] = nil
	elseif t == nil	 then			   --add
		change_reason = 1
	end
	if change_reason ~= 0 then
		local slot_strength = QianghuaData.Instance:GetOneStrengthLvByEquipIndex(data.index)
		data.slot_strength = slot_strength
		local slot_xuelian = EquipmentData.Instance:GetEqBmLevelByEquipIndex(data.index)
		data.slot_xuelian = slot_xuelian
		local slot_soul = MoldingSoulData.Instance:GetEqSoulLevelByEquipIndex(data.index)
		data.slot_soul = slot_soul
		local slot_apotheosis = AffinageData.Instance:GetAffinageLevelBySlot(data.index - EquipData.EquipIndex.Weapon + 1)
		data.slot_apotheosis = slot_apotheosis
		local inlay_list = StoneData.Instance:GetEquipInsetInfo() and StoneData.Instance:GetEquipInsetInfo()[data.index - EquipData.EquipIndex.Weapon + 1]
		if inlay_list then
			for k1, v1 in pairs(inlay_list) do 
				data["slot_" .. k1] = v1.stone_index
			end
		end
		local cross_eq_data = CrossServerData.Instance:GetCrossEquipData(index) -- 跨服装备数据
		if cross_eq_data then
			data.cross_stars = cross_eq_data.cross_stars
			data.cross_grade = cross_eq_data.cross_grade
		end
		data.frombody = true
		self.grid_data_list[data.index] = data
	end

	for k,v in pairs(self.notify_data_change_callback_list) do  --物品有变化，通知观察者，带消息体
		v(false, change_item_id, change_item_index, change_reason)	
	end
	--self:SetSuitEquipCount()   --这个套装视乎没有
	self:SetPeerlessEquipCount()
	self:SetGodEquipData()
end

--绑定数据改变时的回调方法.用于任意物品有更新时进行回调
function EquipData:NotifyDataChangeCallBack(callback)
	self:UnNotifyDataChangeCallBack(callback)
	self.notify_data_change_callback_list[#self.notify_data_change_callback_list + 1] = callback
end

--移除绑定回调
function EquipData:UnNotifyDataChangeCallBack(callback)
	for k,v in pairs(self.notify_data_change_callback_list) do
		if v == callback then
			self.notify_data_change_callback_list[k] = nil
			return
		end
	end
end

--穿戴上就不能脱下的装备
function EquipData.CannotTakeOffEquip(equip_type)
	if equip_type == ItemData.ItemType.itDecoration --勋章
		or equip_type == ItemData.ItemType.itEquipDiamond --宝石
		or equip_type == ItemData.ItemType.itMeterial --玉佩
		or equip_type == ItemData.ItemType.itShield --盾牌
		or equip_type == ItemData.ItemType.itSeal --圣珠
		-- or equip_type == ItemData.ItemType.itSpecialRing --特殊戒指
		or equip_type == ItemData.ItemType.itAnklePad --官印
		or equip_type == ItemData.ItemType.itWarDrum -- 战鼓
		or equip_type == ItemData.ItemType.itHatsPos --斗笠 
		or equip_type == ItemData.ItemType.itEarring --耳坠
		or equip_type == ItemData.ItemType.itShoulderPads --护肩
		or equip_type == ItemData.ItemType.itElbowPads --面甲
		or equip_type == ItemData.ItemType.itKneecap --护膝
		or equip_type == ItemData.ItemType.itHeartMirror --护心
		then
		return true
	end
	return false
end

--通过装备类型获得可以放置的索引
function EquipData:GetEquipIndexByType(type, hand_pos)
	if type == ItemData.ItemType.itWeapon then 
		return EquipData.EquipIndex.Weapon
	elseif type == ItemData.ItemType.itDress then 
		return EquipData.EquipIndex.Dress
	elseif type == ItemData.ItemType.itHelmet then 
		return EquipData.EquipIndex.Helmet
	elseif type == ItemData.ItemType.itNecklace then 
		return EquipData.EquipIndex.Necklace
	elseif type == ItemData.ItemType.itDecoration then 
		return EquipData.EquipIndex.Decoration
	elseif type == ItemData.ItemType.itBracelet then 
		if hand_pos == 0 then
			return EquipData.EquipIndex.Bracelet
		else
			return EquipData.EquipIndex.BraceletR
		end
	elseif type == ItemData.ItemType.itRing then 
		if hand_pos == 0 then
			return EquipData.EquipIndex.Ring
		else
			return EquipData.EquipIndex.RingR
		end
	elseif type == ItemData.ItemType.itGirdle then 
		return EquipData.EquipIndex.Girdle
	elseif type == ItemData.ItemType.itShoes then 
		return EquipData.EquipIndex.Shoes
	elseif type == ItemData.ItemType.itEquipDiamond then 
		return EquipData.EquipIndex.EquipDiamond
	elseif type == ItemData.ItemType.itMeterial then 
		return EquipData.EquipIndex.Meterial
	elseif type == ItemData.ItemType.itFashionDress then 
		return EquipData.EquipIndex.FashionDress
	elseif type == ItemData.ItemType.itSwing then 
		return EquipData.EquipIndex.Swing
	elseif type == ItemData.ItemType.itWeaponExtend then 
		return EquipData.EquipIndex.WeaponExtend
	elseif type == ItemData.ItemType.itHatsPos then 
		return EquipData.EquipIndex.HatsPos
	elseif type == ItemData.ItemType.itShield then 
		return EquipData.EquipIndex.Shield
	elseif type == ItemData.ItemType.itSeal then 
		return EquipData.EquipIndex.Seal
	elseif type == ItemData.ItemType.itSpecialRing then 
		if hand_pos == 0 then
			return EquipData.EquipIndex.SpecialRing
		else
			return EquipData.EquipIndex.SpecialRingR
		end
	elseif type == ItemData.ItemType.itWarDrum then
		return EquipData.EquipIndex.WarDrum
	elseif type == ItemData.ItemType.itMagicWeapon then 
		return EquipData.EquipIndex.MagicWeapon
	elseif type == ItemData.ItemType.itEarring then 
		return EquipData.EquipIndex.CrossEquipEarring
	elseif type == ItemData.ItemType.itShoulderPads then 
		return EquipData.EquipIndex.CrossEquipShoulderPads
	elseif type == ItemData.ItemType.itElbowPads then 
		return EquipData.EquipIndex.CrossEquipElbowPads
	elseif type == ItemData.ItemType.itKneecap then 
		return EquipData.EquipIndex.CrossEquipKneecap
	elseif type == ItemData.ItemType.itAnklePad then 
		return EquipData.EquipIndex.AnklePad
	elseif type == ItemData.ItemType.itHeartMirror then 
		return EquipData.EquipIndex.CrossEquipHeartMirror
	elseif type == ItemData.ItemType.itPrimitiveRingPos then 
		return EquipData.EquipIndex.PrimitiveRingPos
	elseif type == ItemData.ItemType.itPeerlessWeapon then 
		return EquipData.EquipIndex.PeerlessWeaponPos
	elseif type == ItemData.ItemType.itPeerlessDress then 
		return EquipData.EquipIndex.PeerlessDressPos
	elseif type == ItemData.ItemType.itPeerlessHelmet then 
		return EquipData.EquipIndex.PeerlessHelmetPos
	elseif type == ItemData.ItemType.itPeerlessNecklace then 
		return EquipData.EquipIndex.PeerlessNecklacePos
	elseif type == ItemData.ItemType.itPeerlessBracelet then 
		if hand_pos == 0 then
			return EquipData.EquipIndex.PeerlessBraceletPos
		else
			return EquipData.EquipIndex.PeerlessBraceletPosR
		end
	elseif type == ItemData.ItemType.itPeerlessRing then 
		if hand_pos == 0 then
			return EquipData.EquipIndex.PeerlessRingPos
		else
			return EquipData.EquipIndex.PeerlessRingPosR
		end
	elseif type == ItemData.ItemType.itPeerlessGirdle then 
		return EquipData.EquipIndex.PeerlessGirdlePos
	elseif type == ItemData.ItemType.itPeerlessShoes then 
		return EquipData.EquipIndex.PeerlessShoesPos
	elseif type == ItemData.ItemType.itFootPrint then 
		return EquipData.EquipIndex.FootPrint
	end
	return -1
end

--通过装备索引获得装备类型
function EquipData.GetEquipTypeByIndex(index)
	if index == EquipData.EquipIndex.Weapon then 
		return ItemData.ItemType.itWeapon
	elseif index == EquipData.EquipIndex.Dress then 
		return ItemData.ItemType.itDress
	elseif index == EquipData.EquipIndex.Helmet then 
		return ItemData.ItemType.itHelmet
	elseif index == EquipData.EquipIndex.Necklace then 
		return ItemData.ItemType.itNecklace
	elseif index == EquipData.EquipIndex.Decoration then 
		return ItemData.ItemType.itDecoration
	elseif index == EquipData.EquipIndex.Bracelet or index == EquipData.EquipIndex.BraceletR then 
		return ItemData.ItemType.itBracelet
	elseif index == EquipData.EquipIndex.Ring or index == EquipData.EquipIndex.RingR then 
		return ItemData.ItemType.itRing
	elseif index == EquipData.EquipIndex.Girdle then 
		return ItemData.ItemType.itGirdle
	elseif index == EquipData.EquipIndex.Shoes then 
		return ItemData.ItemType.itShoes
	elseif index == EquipData.EquipIndex.EquipDiamond then 
		return ItemData.ItemType.itEquipDiamond
	elseif index == EquipData.EquipIndex.Meterial then 
		return ItemData.ItemType.itMeterial
	elseif index == EquipData.EquipIndex.FashionDress then 
		return ItemData.ItemType.itFashionDress
	elseif index == EquipData.EquipIndex.Swing then 
		return ItemData.ItemType.itSwing
	elseif index == EquipData.EquipIndex.WeaponExtend then 
		return ItemData.ItemType.itWeaponExtend
	elseif index == EquipData.EquipIndex.HatsPos then 
		return ItemData.ItemType.itHatsPos
	elseif index == EquipData.EquipIndex.Shield then 
		return ItemData.ItemType.itShield
	elseif index == EquipData.EquipIndex.Seal then 
		return ItemData.ItemType.itSeal
	elseif index == EquipData.EquipIndex.SpecialRing or index == EquipData.EquipIndex.SpecialRingR then 
		return ItemData.ItemType.itSpecialRing
	elseif index == EquipData.EquipIndex.WarDrum then
		return ItemData.ItemType.itWarDrum
	elseif index == EquipData.EquipIndex.MagicWeapon then 
		return ItemData.ItemType.itMagicWeapon
	elseif index == EquipData.EquipIndex.Earring then 
		return ItemData.ItemType.itEarring
	elseif index == EquipData.EquipIndex.ShoulderPads then 
		return ItemData.ItemType.itShoulderPads
	elseif index == EquipData.EquipIndex.ElbowPads then 
		return ItemData.ItemType.itElbowPads
	elseif index == EquipData.EquipIndex.Kneecap then 
		return ItemData.ItemType.itKneecap
	elseif index == EquipData.EquipIndex.AnklePad then 
		return ItemData.ItemType.itAnklePad
	elseif index == EquipData.EquipIndex.HeartMirror then 
		return ItemData.ItemType.itHeartMirror
	elseif index == EquipData.EquipIndex.PrimitiveRingPos then 
		return ItemData.ItemType.itPrimitiveRingPos
	elseif index == EquipData.EquipIndex.PeerlessWeaponPos then 
		return ItemData.ItemType.itPeerlessWeapon
	elseif index == EquipData.EquipIndex.PeerlessDressPos then 
		return ItemData.ItemType.itPeerlessDress
	elseif index == EquipData.EquipIndex.PeerlessHelmetPos then 
		return ItemData.ItemType.itPeerlessHelmet
	elseif index == EquipData.EquipIndex.PeerlessNecklacePos then 
		return ItemData.ItemType.itPeerlessNecklace
	elseif index == EquipData.EquipIndex.PeerlessBraceletPos or index == EquipData.EquipIndex.PeerlessBraceletPosR then 
		return ItemData.ItemType.itPeerlessBracelet
	elseif index == EquipData.EquipIndex.PeerlessRingPos or index == EquipData.EquipIndex.PeerlessRingPosR then 
		return ItemData.ItemType.itPeerlessRing
	elseif index == EquipData.EquipIndex.PeerlessGirdlePos then 
		return ItemData.ItemType.itPeerlessGirdle
	elseif index == EquipData.EquipIndex.PeerlessShoesPos then 
		return ItemData.ItemType.itPeerlessShoes
	elseif index == EquipData.EquipIndex.FootPrint then
		return ItemData.ItemType.itFootPrint
	elseif index == EquipData.EquipIndex.CrossEquipElbowPads then
		return ItemData.ItemType.itElbowPads
	elseif index == EquipData.EquipIndex.CrossEquipShoulderPads then
		return ItemData.ItemType.itShoulderPads
	elseif index == EquipData.EquipIndex.CrossEquipEarring then
		return ItemData.ItemType.itEarring
	elseif index == EquipData.EquipIndex.CrossEquipKneecap then
		return ItemData.ItemType.itKneecap
	elseif index == EquipData.EquipIndex.CrossEquipHeartMirror then
		return ItemData.ItemType.itHeartMirror
	end
	return -1
end

--获得装备左右
-- function EquipData:GetEquipHandPos(item_type, useType)
-- 	if item_type == ItemData.ItemType.itBracelet or item_type == ItemData.ItemType.itRing
-- 	or item_type == ItemData.ItemType.itPeerlessBracelet or item_type == ItemData.ItemType.itPeerlessRing then
-- 		local index = self:GetEquipIndexByType(item_type, 0)
-- 		if EquipData.Instance:GetIsBetterEquip(self:GetGridData(index)) then
-- 			return 1
-- 		end
-- 		local strength_index = EquipmentData.Equip[QianghuaData.GetStrengthIndex(index) + 1].equip_slot
-- 		local strength_vo = QianghuaData.Instance:GetOneStrengthList(strength_index)
-- 		local index2 = self:GetEquipIndexByType(item_type, 1)
-- 		local strength_index2 = EquipmentData.Equip[QianghuaData.GetStrengthIndex(index2) + 1].equip_slot
-- 		local strength_vo2 = QianghuaData.Instance:GetOneStrengthList(strength_index2)
-- 		if not EquipData.Instance:GetIsBetterEquip(self:GetGridData(index)) and not EquipData.Instance:GetIsBetterEquip(self:GetGridData(index2)) then
-- 			return strength_vo.strengthen_level < strength_vo2.strengthen_level and 1 or 0
-- 		end
-- 	elseif useType and useType > 0 then
-- 		if useType == EquipData.SpecialRingType.FH then
-- 			return 1
-- 		end
-- 	end
-- 	return 0
-- end

--获得装备部位名字
function EquipData:GetEquipPartNameByType(type)
	return Language.Common.EquipName[type] or ""
end

function EquipData:GetEquipCellNameByType(type)
	return Language.Common.EquipCellName[type] or ""
end

-- 根据物品ID获取人物身上的装备信息
function EquipData:GetEquipInfoFromRole(itemid)
	if itemid and nil ~= self.grid_data_list then
		for k, v in pairs(self.grid_data_list) do
			if itemid == v.item_id then
				return v
			end
		end
	end
end

--是否镶嵌有宝石
function EquipData:GetEquipHasStone(item_data)
	if item_data == nil or not StoneData.IsStoneEquip(item_data.type) then 
		return false 
	end
	local has_stone = false
	for i = 1, 5 do
		if item_data["slot_" .. i] and item_data["slot_" .. i] > 0 then
			has_stone = true
			break
		end
	end
	return has_stone
end

-- 根据物品类型获取身上某件装备
function EquipData:GetRoleEquipByType(item_type, hand_pos)
	hand_pos = hand_pos or 0
	if not self.grid_data_list then return end
	for k,v in pairs(self.grid_data_list) do
		if v.type and v.type == item_type and v.hand_pos and v.hand_pos == hand_pos then
			return v
		end
	end
end

-- 获取是否可以转移宝石
function EquipData:IsItemCanTranStone(item_data, hand_pos)
	if not item_data or not item_data.type or not StoneData.IsStoneEquip(item_data.type) then return false end
	local item_cfg = ItemData.Instance:GetItemConfig(item_data.item_id)
	if item_cfg then
		local lv_limit = 0
		for k,v in pairs(item_cfg.conds) do
			if v.cond == ItemData.UseCondition.ucLevel then
				lv_limit = v.value
			end
		end
		if lv_limit < STONE_LEVEL_LIMIT then return false end
	end

	local role_equip_data = self:GetRoleEquipByType(item_data.type, hand_pos or item_data.hand_pos)
	if not role_equip_data then return false end
	return self:GetEquipHasStone(role_equip_data) and not self:GetEquipHasStone(item_data)
end

-- 改变身上某件装备的属性
function EquipData:EquipInfoChange(equip)
	for k,v in pairs(self.grid_data_list) do
		if v.series == equip.series then
			self.grid_data_list[k] = equip
			for k,v in pairs(self.notify_data_change_callback_list) do  --物品有变化，通知观察者，不带消息体
				v(true)
			end
			break
		end
	end
end

-- 根据序列号从背包或身上装备获取一件装备
function EquipData.GetEquipInBagOrEquip(series)
	if nil == series then
		return nil
	end
	local equip_data = EquipData.Instance:GetEquipBySeries(series)
	if nil ~= equip_data then
		return equip_data, 0
	else
		equip_data = ItemData.Instance:GetItemInBagBySeries(series)
		if nil ~= equip_data then
			return equip_data, 1
		end
	end
end
