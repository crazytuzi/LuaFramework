--------------------------------------------------------
--玩家身上的装备数据管理
--------------------------------------------------------
EquipData = EquipData or BaseClass()
StonePlusCfg = StonePlusCfg or {} --暂时屏蔽错误使用,服务器配置了新数据使用另外的数据
SuitPlusConfig = SuitPlusConfig or {}  --暂时屏蔽错误使用,服务器配置了新数据使用另外的数据
EquipData.SpecialRingType = {
	FH = 1,				--复活
	MB = 2,				--麻痹
	HS = 3,				--护身
}
EquipData.EquipIndex = 
{
	Weapon = 0,					--武器
	Dress = 1,					--衣服
	Helmet = 2,					--头盔
	Necklace = 3,				--项链
	Bracelet  = 4,				--手镯
	BraceletR  = 5,				--手镯
	
	Ring = 6,					--戒指
	RingR = 7,					--戒指
	Girdle = 8,					--腰带
	Shoes = 9,					--鞋子
	
	BloodRune =10,				--血符
	Shield = 11,				--护盾
	EquipDiamond = 12,        	--武魂
	SealBead = 13,				--灵珠
	Decoration = 14,          	--勋章
	SpecialRing = 15,       	--左特殊戒指
	SpecialRingR = 16,       	--右特殊戒指
	ShoulderPads = 17, 			-- 护肩
	Earring = 18, 				-- 护坠
	HeartMirror = 19,			-- 护镜
	Kneecap = 20,				-- 护膝
	WarRune = 21,				-- 战符  --人物显示位置，与英雄区分，客户端自己定义
	-- Meterial = 19,           --玉佩
	-- Seal = 20,              	--圣珠
	--================英雄装备槽位begin==================
	HeroWeapon = 21,										-- 英雄-武器
	HeroDress = 22,											-- 英雄-衣服
	HeroHelmet = 23,										-- 英雄-头盔
	HeroNecklace = 24,					 					-- 英雄-项链
	HeroLeftBracelet = 25,									-- 英雄-左边的手镯
	HeroRightBracelet = 26,									-- 英雄-右边的手镯
	HeroLeftRing = 27,										-- 英雄-左边的戒指
	HeroRightRing = 28,										-- 英雄-右边的戒指
	HeroGirdle = 29,										-- 英雄-腰带
	HeroShoes = 30,											-- 英雄-鞋子
	HeroSaintShouder = 31,									-- 英雄-护肩(圣装)
	HeroSaintPendant = 32,									-- 英雄-护坠(圣装)
	HeroSaintMirror = 33,									-- 英雄-护镜(圣装)
	HeroSaintKneecap = 34,									-- 英雄-护膝(圣装)
--================英雄装备槽位end==================
	

	--AnklePad = 35,				--护踝(官职)
	NorEquipMaxIndex = 36,
	-- WeaponExtend = 32,			--神器
	-- HatsPos = 33,				--斗笠
	-- FashionDress = 34,        	--神甲
	-- ElbowPads = 35,				--面甲
	-- ShoulderPads = 36,			--护肩
	-- Earring = 37,				--耳坠
	-- Kneecap = 38,				--护膝
	-- HeartMirror = 39,			--护心镜
	EquipMaxIndex = 40,
	Swing = 41,					--翅膀 
	MagicWeapon = 42,			--法宝
}

EquipData.SuitNum = { -- 神铸套装
	[1] = 3, 
	[2] = 6,
	[3] = 9,
}

function EquipData:__init()
	self.grid_data_list = {}	
	self.equip_list = {}	
	self.equip_change_list = {}	
	EquipData.Instance = self
	self.notify_data_change_callback_list = {}		--身上装备有更新变化时进行回调
	self.stone_infos = {} 							--宝石孔列表
	self.fabao_info = {
		fabao_id = 0,
		fabao_gain_time = 0
	}
	self.gem_Lv_list = {}
	self.suit_level = 0
	self.gem_level = 0
	self.level_data = {}
	self.max_stone_data = {}
	self.index_t = {}
	self.level_t = {}
	self.xiefu_equip_level = 0
	self.zhanhun_equip_level = 0
	--升铸套装属性
	self.god_zhu_equip = {}
	self.godequip_level = {}
	self.god_level_t = {}
	--至尊套装
	self.extreme_equip = {}
	GlobalEventSystem:Bind(OtherEventType.STRENGTH_INFO_CHANGE, BindTool.Bind1(self.StrengthChangeCallback, self))
	
	EquipData.EquipTypeByEquipIndex = {
		[EquipData.EquipIndex.Weapon] = ItemData.ItemType.itWeapon,	 			--武器
		[EquipData.EquipIndex.Dress] = ItemData.ItemType.itDress,		 		--衣服
		[EquipData.EquipIndex.Helmet] = ItemData.ItemType.itHelmet,				--头盔
		[EquipData.EquipIndex.Necklace] = ItemData.ItemType.itNecklace,			--项链
		[EquipData.EquipIndex.Decoration] = ItemData.ItemType.itDecoration,		--勋章	
		[EquipData.EquipIndex.Bracelet] = ItemData.ItemType.itBracelet,			--手镯
		[EquipData.EquipIndex.BraceletR] = ItemData.ItemType.itBracelet,		--右手镯
		[EquipData.EquipIndex.Ring] = ItemData.ItemType.itRing,					--戒指
		[EquipData.EquipIndex.RingR] = ItemData.ItemType.itRing,				--右戒指
		[EquipData.EquipIndex.Girdle] = ItemData.ItemType.itGirdle,				--腰带
		[EquipData.EquipIndex.Shoes] = ItemData.ItemType.itShoes,				--鞋子
		[EquipData.EquipIndex.SealBead] = ItemData.ItemType.itStoveSealBead,	--灵珠
		[EquipData.EquipIndex.Shield] = ItemData.ItemType.itStoveShield,		--护盾
		[EquipData.EquipIndex.BloodRune] = ItemData.ItemType.itStoveBloodRune,	--血符
		[EquipData.EquipIndex.EquipDiamond] = ItemData.ItemType.itStoveDiamond,	--武魂
		[EquipData.EquipIndex.SpecialRing] = ItemData.ItemType.itSpecialRing,	--神炉特殊戒指
		[EquipData.EquipIndex.SpecialRingR] = ItemData.ItemType.itSpecialRing,	--神炉右特殊戒指
		[EquipData.EquipIndex.Earring] = ItemData.ItemType.itSaintPenDantPos,	--护坠
		[EquipData.EquipIndex.ShoulderPads] = ItemData.ItemType.itSaintShouderPos,--护肩
		[EquipData.EquipIndex.Kneecap] = ItemData.ItemType.itSaintrKneecapPos,	--护膝
		[EquipData.EquipIndex.HeartMirror] = ItemData.ItemType.itSaintMirrorPos,--护镜
		[EquipData.EquipIndex.WarRune] = ItemData.ItemType.itWarRunePos,		--战符
	}
	
	EquipData.EquipIndexByEquipType = {
		[ItemData.ItemType.itWeapon] = EquipData.EquipIndex.Weapon,				--武器
		[ItemData.ItemType.itDress] = EquipData.EquipIndex.Dress,				--衣服
		[ItemData.ItemType.itHelmet] = EquipData.EquipIndex.Helmet,				--头盔
		[ItemData.ItemType.itNecklace] = EquipData.EquipIndex.Necklace,			--项链
		[ItemData.ItemType.itDecoration] = EquipData.EquipIndex.Decoration,		--勋章
		[ItemData.ItemType.itBracelet] = EquipData.EquipIndex.Bracelet,			--手镯
		[ItemData.ItemType.itBracelet + 10000] = EquipData.EquipIndex.BraceletR,--右手镯
		[ItemData.ItemType.itRing] = EquipData.EquipIndex.Ring,					--戒指
		[ItemData.ItemType.itRing + 10000] = EquipData.EquipIndex.RingR,		--右戒指
		[ItemData.ItemType.itGirdle] = EquipData.EquipIndex.Girdle,				--腰带
		[ItemData.ItemType.itShoes] = EquipData.EquipIndex.Shoes,				--鞋子
		[ItemData.ItemType.itStoveSealBead] = EquipData.EquipIndex.SealBead,	--灵珠
		[ItemData.ItemType.itStoveShield] = EquipData.EquipIndex.Shield,		--护盾
		[ItemData.ItemType.itStoveBloodRune] = EquipData.EquipIndex.BloodRune,	--血符
		[ItemData.ItemType.itStoveDiamond] = EquipData.EquipIndex.EquipDiamond,	--武魂
		[ItemData.ItemType.itSpecialRing] = EquipData.EquipIndex.SpecialRing,	--神炉特殊戒指
		[ItemData.ItemType.itSpecialRing + 10000] = EquipData.EquipIndex.SpecialRingR,--神炉右特殊戒指
		[ItemData.ItemType.itSaintPenDantPos] = EquipData.EquipIndex.Earring,	--护坠
		[ItemData.ItemType.itSaintShouderPos] = EquipData.EquipIndex.ShoulderPads,	--护肩
		[ItemData.ItemType.itSaintrKneecapPos] = EquipData.EquipIndex.Kneecap,				--护膝
		[ItemData.ItemType.itSaintMirrorPos] = EquipData.EquipIndex.HeartMirror,  	--护镜
		[ItemData.ItemType.itWarRunePos] = EquipData.EquipIndex.WarRune,  	--战符
	}


	--将数组形式变成字典形式
	self.equip_score_valuation = {}
	for k,v in pairs(EquipValuation) do
		local job_attr = {}
		self.equip_score_valuation[k] = job_attr
		local temp_attr = EquipValuation[k]
		for k1, v1 in pairs(temp_attr) do
			job_attr[v1.attrId] = v1
		end	
	end	
end

function EquipData:__delete()
  	self.grid_data_list = nil
  	self.notify_data_change_callback_list = nil
  	EquipData.Instance = nil
end



function EquipData:StrengthChangeCallback(index)
	if index then
		local equip_data = self.grid_data_list[index]
		if equip_data then
			local slot_strength = EquipmentData.Instance:GetOneStrengthLvByEquipIndex(index)
			equip_data.slot_strength = slot_strength
			for k,v in pairs(self.notify_data_change_callback_list) do  --物品有变化，通知观察者，带消息体
				v(false, equip_data.item_id, index, 2)	
			end
		end
	else
		for k,v in pairs(self.grid_data_list) do
			local slot_strength = EquipmentData.Instance:GetOneStrengthLvByEquipIndex(k)
			v.slot_strength = slot_strength
		end
		for k,v in pairs(self.notify_data_change_callback_list) do  --物品有变化，通知观察者，不带消息体
			v(true)	
		end
	end
end

function EquipData:SortDataList()
	local list = self.grid_data_list
	for k,v in pairs(self.equip_list) do
		if ItemData.Instance:GetItemConfig(v.item_id) then
			local config = ItemData.Instance:GetItemConfig(v.item_id)
			local hand_pos = 0
			if config.type == ItemData.ItemType.itSpecialRing then
				if config.useType == 2 or config.useType == 3 then
					hand_pos = 0
				else
					hand_pos = 1
				end
			else
				hand_pos = v.hand_pos
			end
			local index = self:GetEquipIndexByType(config.type, hand_pos)
			if index >= 0 then
				v.index = index
				local slot_strength = EquipmentData.Instance:GetOneStrengthLvByEquipIndex(index)
				v.slot_strength = slot_strength
				list[index] = v
				self.equip_list[k] = nil
			end
		end
	end
	-- local prof = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
	-- local offic = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_OFFICE)
	-- if offic > 0 then
	-- 	local offic_data = CommonStruct.ItemDataWrapper()
	-- 	--offic_data.item_id = OFFICE_ID[prof]
	-- 	offic_data.num = 1
	-- 	offic_data.is_bind = 1
	-- 	offic_data.office_level = offic
	-- 	offic_data.frombody = true
	-- 	self.grid_data_list[EquipData.EquipIndex.AnklePad] = offic_data
	-- end
	for k,v in pairs(self.notify_data_change_callback_list) do  --物品有变化，通知观察者，不带消息体
		v(true)	
	end
	self:SetGodExtremeData()
	--self:GetGodEquipNumAddCircle()
end
function EquipData:SetDataList(protocol)

	local role_equip_list = {}
	local hero_equip_list = {}
	for _,v in pairs(protocol.equip_list) do
		if ZhanjiangData.IsHeroEquip(v) then
			table.insert(hero_equip_list,v)
		else	
			table.insert(role_equip_list,v)
		end	
	end	
	self.equip_list = role_equip_list
	ZhanjiangData.Instance:InitEquip(hero_equip_list)

	self:SortDataList()
	EquipmentData.Instance:UpdateEquipsSkillLevel()
	ZhanjiangData.Instance:UpdateEquipsSkillLevel()
end

function EquipData:GetEquipList()
	return self.equip_list
end

function EquipData:SetGodExtremeData()
	self.extreme_equip = {}
	for k, v in pairs(self.grid_data_list) do
		-- local config = ItemData.Instance:GetItemConfig(v.item_id)
		-- if config ~= nil and config.flags.primeEquip then
			table.insert(self.extreme_equip, v)
		--end
	end
end

function EquipData:GetExtremeData()
	return self.extreme_equip
end

--暂时弃用
-- function EquipData:GetGodEquipNumAddCircle()
-- 	self.god_zhu_equip = {}
-- 	for k, v in pairs(self.grid_data_list) do
-- 		if EquipmentData.Instance:BoolIsGodZhuEquip(v.item_id) then
-- 			local config = ItemData.Instance:GetItemConfig(v.item_id)
-- 			if config ~= nil then
-- 				local item_data = {item = v, suit_level = config.suitLevel}
-- 				table.insert(self.god_zhu_equip, item_data)
-- 			end
-- 		end
-- 	end
-- 	self.index_t = {}
-- 	for k, v in pairs(self.god_zhu_equip) do
-- 		for i = 1, #Language.Role.Suit_Text do
-- 			if i == v.suit_level then
-- 				self.index_t[i] = self.index_t[i] or 0
-- 				self.index_t[i] = self.index_t[i] + 1 
-- 			end
-- 		end
-- 	end
-- 	local num = 0
-- 	if  #self.god_zhu_equip >= 3 and  #self.god_zhu_equip <= 5 then
-- 		num = 3
-- 	elseif #self.god_zhu_equip >= 6 and  #self.god_zhu_equip <= 8 then
-- 		num = 6
-- 	elseif #self.god_zhu_equip >= 9 and  #self.god_zhu_equip <= 10 then
-- 		num = 9
-- 	else
-- 		num = 0
-- 	end
-- 	self.god_level_t = {}
-- 	self.godequip_level = {}
-- 	for k, v in pairs(EquipData.SuitNum) do
-- 		if num > 0 then
-- 			local level = 0
-- 			local function suit()
-- 				self.god_level_t[level] = self.index_t[level] or 0
-- 				for k,v in pairs(self.index_t) do
-- 					if k > level then
-- 						self.god_level_t[level] = self.god_level_t[level]  + v
-- 					end
-- 				end

-- 				if self.god_level_t[level] >= v then
-- 					if level >= (self.godequip_level[v] or 0) then
-- 						self.godequip_level[v] = level
-- 					end
-- 				end
-- 			-- end
-- 				level = level + 1
-- 				if level <= #Language.Role.Suit_Text then
-- 					suit()
-- 				end
-- 			end
-- 			suit()
-- 		else
-- 			local level = 0
-- 			local function suit()
-- 			-- if self.index_t[level] then
-- 				self.god_level_t[level] = self.index_t[level] or 0
-- 				for k,v in pairs(self.index_t) do
-- 					if k > level then
-- 						self.god_level_t[level] = self.god_level_t[level]  + v
-- 					end
-- 				end
-- 				level = level + 1
-- 				if level <= #Language.Role.Suit_Text then
-- 					suit()
-- 				end
-- 			end
-- 			suit()
-- 			self.godequip_level[v] = 0
-- 		end
-- 	end
-- end

-- function EquipData:GetSuitStep()
-- 	return self.godequip_level
-- end

-- function EquipData:GetGodEquipNum()
-- 	return #self.god_zhu_equip
-- end

-- function EquipData:GetNumT()
-- 	return self.god_level_t
-- end
--弃用结束

--得到神器装备槽的套装等级以及序列号
function EquipData:GetSuitIndexLevel()
	return self.index_t
end

function EquipData:GetDataList()
	return self.grid_data_list
end

function EquipData:GetEquipBySeries(series)
	for k,v in pairs(self.grid_data_list) do
		if v.series == series then
			return v
		end
	end
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
	local hand_pos = 0
	if item_config.type == ItemData.ItemType.itSpecialRing then
		if item_config.useType == 2 or item_config.useType == 3 then
			hand_pos = 0
		else
			hand_pos = 1
		end
	else
		hand_pos = data.hand_pos
	end
	data.index = self:GetEquipIndexByType(item_config.type, hand_pos)
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
		local slot_strength = EquipmentData.Instance:GetOneStrengthLvByEquipIndex(data.index)
		data.slot_strength = slot_strength
		data.frombody = true
		self.grid_data_list[data.index] = data
	end

	EquipmentData.Instance:UpdateEquipsSkillLevel()

	for k,v in pairs(self.notify_data_change_callback_list) do  --物品有变化，通知观察者，带消息体
		v(false, change_item_id, change_item_index, change_reason)	
	end
	self:SetGodExtremeData()
	--self:GetGodEquipNumAddCircle()
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
	if equip_type == ItemData.ItemType.itStoveBloodRune or--血符(神炉装备)
	equip_type == ItemData.ItemType.itStoveShield or--神盾(神炉装备)
	equip_type == ItemData.ItemType.itStoveDiamond or--武魂(神炉装备)
	equip_type == ItemData.ItemType.itDecoration or--勋章(神炉装备)
	equip_type == ItemData.ItemType.itStoveSealBead or--灵珠(神炉装备)
	equip_type == ItemData.ItemType.itSpecialRing  then --特戒(神炉装备)
	-- equip_type == ItemData.ItemType.itWarRunePos then	--战符
		return true
	end
	return false
end

-- 根据装备位置判断是否是神炉装备
function EquipData.IsComposeEquipByEqIndex(equip_index)
	if equip_index == EquipData.EquipIndex.BloodRune or equip_index == EquipData.EquipIndex.Shield or 
		equip_index == EquipData.EquipIndex.EquipDiamond or equip_index == EquipData.EquipIndex.SealBead or 
		equip_index == EquipData.EquipIndex.Decoration or equip_index == EquipData.EquipIndex.SpecialRing or 
		equip_index == EquipData.EquipIndex.SpecialRingR then
		return true
	end
	return false
end

--通过装备类型获得可以放置的索引
function EquipData:GetEquipIndexByType(type, hand_pos)
	if hand_pos == 1 then
		type = type + 10000
	end
	return EquipData.EquipIndexByEquipType[type] or -1
end

--通过装备索引获得装备类型
function EquipData.GetEquipTypeByIndex(index)
	return EquipData.EquipTypeByEquipIndex[index] or -1
end

--获得装备左右
function EquipData:GetEquipHandPos(item_type, useType)
	if item_type == ItemData.ItemType.itBracelet or item_type == ItemData.ItemType.itRing then
		local index = self:GetEquipIndexByType(item_type, 0)
		if EquipData.Instance:GetIsBetterEquip(self:GetGridData(index)) then
			return 1
		end
		local strength_index = EquipmentData.GetStrengthIndex(index)
		local strength_vo = EquipmentData.Instance:GetOneStrengthList(strength_index)
		local index2 = self:GetEquipIndexByType(item_type, 1)
		local strength_index2 = EquipmentData.GetStrengthIndex(index2)
		local strength_vo2 = EquipmentData.Instance:GetOneStrengthList(strength_index2)
		if not EquipData.Instance:GetIsBetterEquip(self:GetGridData(index)) and not EquipData.Instance:GetIsBetterEquip(self:GetGridData(index2)) then
			return strength_vo.strengthen_level < strength_vo2.strengthen_level and 1 or 0
		end
	elseif useType and useType > 0 then
		if useType == EquipData.SpecialRingType.FH then
			return 1
		end
	end
	return 0
end


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
function EquipData.GetEquipHasStone(item_data)
	if item_data == nil or not ItemData.GetIsEquip(item_data.item_id) then return false end
	for i = 1, 5 do
		if item_data["slot_" .. i] and bit:_and(item_data["slot_" .. i], 0x7F) > 0 then
			return true
		end
	end
	return false
end

--检查当前装备是否比装备在身上的装备更好
function EquipData:GetIsBetterEquip(item_data, hadLimit, ignore_level)
	if item_data == nil then return false end
	local item_cfg, item_type = ItemData.Instance:GetItemConfig(item_data.item_id)
	if item_cfg == nil or not ItemData.GetIsEquip(item_data.item_id) then
		return false
	end
	local my_circle = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)
	ignore_level = ignore_level --or my_circle > 0
	local had_limit = (hadLimit == nil) and true or hadLimit
	if had_limit then
		for k,v in pairs(item_cfg.conds) do
			if v.cond == ItemData.UseCondition.ucLevel then
				if not ignore_level and not RoleData.Instance:IsEnoughLevelZhuan(v.value) then
					return false
				end
			end
			if v.cond == ItemData.UseCondition.ucMinCircle then
				if v.value > my_circle then
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
	local empty_cell_num = 1
	if item_cfg.type == ItemData.ItemType.itBracelet or item_cfg.type == ItemData.ItemType.itRing then
		empty_cell_num = 2
	end

	for k,v in pairs(self.grid_data_list) do
		if v ~= nil then				--非空位，比较分数
			local equip_item_cfg, _ = ItemData.Instance:GetItemConfig(v.item_id)
			if equip_item_cfg ~= nil and equip_item_cfg.type == item_cfg.type and equip_item_cfg.useType == item_cfg.useType then
				empty_cell_num = empty_cell_num - 1
				if ItemData.Instance:GetItemScore(item_data) > ItemData.Instance:GetItemScore(v) then
					return true, equip_item_cfg
				end

			end
		end
	end
	if empty_cell_num > 0 then	-- 有对应的空格子
		return true, nil
	else
		return false
	end
end

--根据格子索引得到可穿戴的最大攻击力装备
function EquipData:GetBagBestEquipByType(index)
	local data = {}
	local bag_data = ItemData.Instance:GetBagEquipList()
	for k, v in pairs(bag_data) do
		if ItemData.GetIsEquip(v.item_id) or ItemData.GetIsHeroEquip(v.item_id) then -- 判断是装备
			if ItemData.CanUseByItem(v) == false then  -- 装备是否可用
				local item_cfg = ItemData.Instance:GetItemConfig(v.item_id)
				if item_cfg == nil then
					return 
				end
				if item_cfg.type  == EquipData.GetEquipTypeByIndex(index) then
					data[k] = {}
					data[k].item = v
					data[k].score = ItemData.Instance:GetItemScore(v)
				end
			end 
		end
	end
	local cur_data = {}
	for k, v in pairs(data) do
		table.insert(cur_data, v)
	end
	if #cur_data >= 2 then
		local function sort_baglist()
			return function(c, d)
				if c.score ~= d.score then
					return c.score < d.score
				end
				return c.item.item_id < d.item.item_id
			end
		end
		table.sort(cur_data, sort_baglist())
	end
	return cur_data[#cur_data]
end

function EquipData:GetBoolShowEquipCell()
	local bool_show = true
	if OtherData.Instance:GetCombindDays() <= 0 then
		if OtherData.Instance:GetOpenServerDays() < GlobalConfig.saintEquipValidDay then
			bool_show = false
		else
			bool_show = true
		end
	else
		bool_show = true
	end
	return bool_show
end

function EquipData:GetBoolShowBtn(data)
	for k, v in pairs(self.grid_data_list) do
		if v.series == data.series then
			return true
		end
	end
	return false
end

function EquipData:GetValuationByJobAndType(job, type)
	local job_attr = self.equip_score_valuation[job]
	if job_attr then
		job_attr = job_attr[type]
		return job_attr and job_attr.unitVal or 0
	end
	return 0	
end	