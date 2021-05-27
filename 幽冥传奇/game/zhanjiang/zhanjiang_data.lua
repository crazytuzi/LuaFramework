--------------------------------------------------------
--战将相关数据
--------------------------------------------------------
ZhanjiangData = ZhanjiangData or BaseClass()
-- ========================英雄状态========================
HERO_STATE = {
				REST = 0,          	--休息状态
				SHOW = 1,         	--放出状态
				MERGE = 2,          --合体状态
}

local HeroAttrCfgIDStart = 260							--战将属性配置起始Id
ZhanjiangData.HeroLvMax = HeroConfig.maxlev			--战将最高等级
ZhanjiangData.EXPENDMONEY = 100000 						--宠物出战与合体消耗的绑定金币数量
ZhanjiangData.ConsumeId = HeroConfig.consumeid

function ZhanjiangData:__init()
	if ZhanjiangData.Instance then
		ErrorLog("[ZhanjiangData] Attemp to create a singleton twice !")
	end
	
	ZhanjiangData.Instance = self
	self.last_attr_val_t = {}
	self.hero_attr_val_t = {}
	self.owned_equip_t = {}
	self.next_lev_attr_t = {}
	self.next_lev_lianti_attr = {}
	self.hero_data = {
						level = 1, 
						need_bindGold = HeroConfig.upgradecfg[1].value, 
						bind_gold = 0
					}
	self.hero_state = nil
	self.prev_state = nil      --上一次状态
	self.up_hero_lv_resul = nil
	self.up_lianti_resul = nil
	self.item_config_callback_bind = BindTool.Bind(self.ItemConfigCallBack, self)
end

function ZhanjiangData:__delete()
	ZhanjiangData.Instance = nil

	if ItemData.Instance then
		ItemData.Instance:UnNotifyItemConfigCallBack(self.item_config_callback_bind)
	end
end

--获取英雄战将配置
function ZhanjiangData.getModel(name)
	if name == "zhangchong" then
		return self
	elseif name == "zhangchong" then
		return self
	end
end

--获取英雄战将配置
function ZhanjiangData.GetHeroUpgradeCfg(n_lev)
	return HeroConfig.upgradecfg[n_lev]
end

function ZhanjiangData:ItemConfigCallBack()
	self:SortEquipList()
end

--是否激活成功
function ZhanjiangData:IsActivatedSucc()
	return (next(self.hero_attr_val_t) ~= nil)
end

function ZhanjiangData:SetHeroAttrData(protocol)
	self.hero_attr_val_t.hero_id = protocol.hero_id
	self.hero_attr_val_t.hero_type = protocol.hero_type
	self.hero_attr_val_t.hero_name = protocol.hero_name
	self.hero_attr_val_t.model_id = protocol.model_id
	self.hero_attr_val_t.monster_id = protocol.monster_id
	self.hero_attr_val_t.wing_id = protocol.wing_id
	self.hero_attr_val_t.weapon_id = protocol.weapon_id
	self.hero_attr_val_t.level = protocol.hero_level
	self.hero_attr_val_t.attrs = {}

	table.insert(self.hero_attr_val_t.attrs, {type = GAME_ATTRIBUTE_TYPE.MAX_HP_ADD, value = protocol.max_hp})
	table.insert(self.hero_attr_val_t.attrs, {type = GAME_ATTRIBUTE_TYPE.PHYSICAL_ATTACK_MIN_ADD, value = protocol.min_phy_atk})
	table.insert(self.hero_attr_val_t.attrs, {type = GAME_ATTRIBUTE_TYPE.PHYSICAL_ATTACK_MAX_ADD, value = protocol.max_phy_atk})
	table.insert(self.hero_attr_val_t.attrs, {type = GAME_ATTRIBUTE_TYPE.MAGIC_ATTACK_MIN_ADD, value = protocol.min_magic_atk})
	table.insert(self.hero_attr_val_t.attrs, {type = GAME_ATTRIBUTE_TYPE.MAGIC_ATTACK_MAX_ADD, value = protocol.max_magic_atk})
	table.insert(self.hero_attr_val_t.attrs, {type = GAME_ATTRIBUTE_TYPE.WIZARD_ATTACK_MIN_ADD, value = protocol.min_daoshu_atk})
	table.insert(self.hero_attr_val_t.attrs, {type = GAME_ATTRIBUTE_TYPE.WIZARD_ATTACK_MAX_ADD, value = protocol.max_daoshu_atk})
	-- table.insert(self.hero_attr_val_t.attrs, {type = GAME_ATTRIBUTE_TYPE.DIZZY_RATE_ADD, value = protocol.paralyze_rate})
	table.insert(self.hero_attr_val_t.attrs, {type = GAME_ATTRIBUTE_TYPE.ATTACK_BOSS_CRIT_RATE, value = protocol.critical_chance})
	table.insert(self.hero_attr_val_t.attrs, {type = GAME_ATTRIBUTE_TYPE.ATTACK_BOSS_CRIT_VALUE, value = protocol.critical_value})
	-- table.insert(self.hero_attr_val_t.attrs, {type = GAME_ATTRIBUTE_TYPE.MAX_MP_ADD, value = protocol.max_mp})
	-- table.insert(self.hero_attr_val_t.attrs, {type = GAME_ATTRIBUTE_TYPE.PHYSICAL_DEFENCE_MIN_ADD, value = protocol.min_phy_def})
	-- table.insert(self.hero_attr_val_t.attrs, {type = GAME_ATTRIBUTE_TYPE.PHYSICAL_DEFENCE_MAX_ADD, value = protocol.max_phy_def})
	-- table.insert(self.hero_attr_val_t.attrs, {type = GAME_ATTRIBUTE_TYPE.MAGIC_DEFENCE_MIN_ADD, value = protocol.min_magic_def})
	-- table.insert(self.hero_attr_val_t.attrs, {type = GAME_ATTRIBUTE_TYPE.MAGIC_DEFENCE_MAX_ADD, value = protocol.max_magic_def})

end

function ZhanjiangData:SetHeroAttrData1(protocol)
	if self.last_attr_val_t == nil or self.hero_attr_val_t.monster_id ~= protocol.monster_id then
		self.last_attr_val_t = TableCopy(self.hero_attr_val_t)									-- 保存上一级的属性
	end

	self.hero_attr_val_t.hero_id = protocol.hero_id
	self.hero_attr_val_t.hero_type = protocol.hero_type
	self.hero_attr_val_t.hero_name = protocol.hero_name
	self.hero_attr_val_t.model_id = protocol.model_id
	self.hero_attr_val_t.monster_id = protocol.monster_id
	self.hero_attr_val_t.wing_id = protocol.wing_id
	self.hero_attr_val_t.weapon_id = protocol.weapon_id
	self.hero_attr_val_t.level = protocol.hero_level
	self.hero_attr_val_t.attrs = {}

	table.insert(self.hero_attr_val_t.attrs, {type = GAME_ATTRIBUTE_TYPE.MAX_HP_ADD, value = protocol.max_hp})
	table.insert(self.hero_attr_val_t.attrs, {type = GAME_ATTRIBUTE_TYPE.PHYSICAL_ATTACK_MIN_ADD, value = protocol.min_phy_atk})
	table.insert(self.hero_attr_val_t.attrs, {type = GAME_ATTRIBUTE_TYPE.PHYSICAL_ATTACK_MAX_ADD, value = protocol.max_phy_atk})
	table.insert(self.hero_attr_val_t.attrs, {type = GAME_ATTRIBUTE_TYPE.MAGIC_ATTACK_MIN_ADD, value = protocol.min_magic_atk})
	table.insert(self.hero_attr_val_t.attrs, {type = GAME_ATTRIBUTE_TYPE.MAGIC_ATTACK_MAX_ADD, value = protocol.max_magic_atk})
	table.insert(self.hero_attr_val_t.attrs, {type = GAME_ATTRIBUTE_TYPE.WIZARD_ATTACK_MIN_ADD, value = protocol.min_daoshu_atk})
	table.insert(self.hero_attr_val_t.attrs, {type = GAME_ATTRIBUTE_TYPE.WIZARD_ATTACK_MAX_ADD, value = protocol.max_daoshu_atk})
	-- table.insert(self.hero_attr_val_t.attrs, {type = GAME_ATTRIBUTE_TYPE.DIZZY_RATE_ADD, value = protocol.paralyze_rate})
	table.insert(self.hero_attr_val_t.attrs, {type = GAME_ATTRIBUTE_TYPE.ATTACK_BOSS_CRIT_RATE, value = protocol.critical_chance})
	table.insert(self.hero_attr_val_t.attrs, {type = GAME_ATTRIBUTE_TYPE.ATTACK_BOSS_CRIT_VALUE, value = protocol.critical_value})
	-- table.insert(self.hero_attr_val_t.attrs, {type = GAME_ATTRIBUTE_TYPE.MAX_MP_ADD, value = protocol.max_mp})
	-- table.insert(self.hero_attr_val_t.attrs, {type = GAME_ATTRIBUTE_TYPE.PHYSICAL_DEFENCE_MIN_ADD, value = protocol.min_phy_def})
	-- table.insert(self.hero_attr_val_t.attrs, {type = GAME_ATTRIBUTE_TYPE.PHYSICAL_DEFENCE_MAX_ADD, value = protocol.max_phy_def})
	-- table.insert(self.hero_attr_val_t.attrs, {type = GAME_ATTRIBUTE_TYPE.MAGIC_DEFENCE_MIN_ADD, value = protocol.min_magic_def})
	-- table.insert(self.hero_attr_val_t.attrs, {type = GAME_ATTRIBUTE_TYPE.MAGIC_DEFENCE_MAX_ADD, value = protocol.max_magic_def})

end

--获取英雄属性列表
function ZhanjiangData:GetHeroAttrList()
	return self.hero_attr_val_t.attrs
end

--战将、附体属性数据
function ZhanjiangData:GetHeroAttrData()
	local title_attrs = self.hero_attr_val_t.attrs
	--战将属性
	local zhanjiang_attr_data = RoleData.FormatRoleAttrStr(title_attrs, nil, 0)
	--附体属性
	local futi_attr_data = ZhanjiangData.CalcuFutiAttrs(title_attrs)

	return zhanjiang_attr_data, futi_attr_data
end

--计算附体属性
function ZhanjiangData.CalcuFutiAttrs(data_list)
	local attrs_title = {}
	for i = 2, 7, 1 do
		local temp_t = {type = data_list[i].type, value = math.floor(data_list[i].value / 10)}
		table.insert(attrs_title, temp_t)
	end
	local attrs_str_t = RoleData.FormatRoleAttrStr(attrs_title)
	local fight_power = {
				type = "fight_power", value = CommonDataManager.GetAttrSetScore(attrs_title), 
				value_str = tostring(CommonDataManager.GetAttrSetScore(attrs_title)),
				}

	table.insert(attrs_str_t, 1, fight_power)

	return attrs_str_t
end

function ZhanjiangData.CalcuFutiAttrsCfg(zhu_attrs)
	local attrs_title = {}
	for i = 2, 7, 1 do
		local temp_t = {type = zhu_attrs[i].type, value = math.floor(zhu_attrs[i].value / 10)}
		table.insert(attrs_title, temp_t)
	end
	return attrs_title
end

--获取英雄其他信息（属性除外）
function ZhanjiangData:GetOtherInfoList()
	local other_info = {
						hero_id = self.hero_attr_val_t.hero_id,
						type = self.hero_attr_val_t.hero_type,
						name = self.hero_attr_val_t.hero_name,
						model_id = self.hero_attr_val_t.model_id,
						monster_id = self.hero_attr_val_t.monster_id,
						wing_id = self.hero_attr_val_t.wing_id,
						weapon_id = self.hero_attr_val_t.weapon_id,
						level = self.hero_attr_val_t.level,
					}
	return other_info
end

--获取英雄模型数据
function ZhanjiangData:GetHeroModelIdData()
	local other_info = self:GetOtherInfoList()
	local model_data = {}
	model_data = {
					[OBJ_ATTR.ENTITY_MODEL_ID] = other_info.model_id,
					[OBJ_ATTR.ACTOR_WING_APPEARANCE] = other_info.wing_id,
					[OBJ_ATTR.ACTOR_WEAPON_APPEARANCE] = other_info.weapon_id,
					entity_type = EntityType.Humanoid,
				}
	return model_data
end

--设置已有装备列表
function ZhanjiangData:SetOwnedEquipList(protocol)
	if protocol.equip_count < 1 then
		self.owned_equip_t = {}
	else
		self.owned_equip_t = protocol.equip_data_list
	end
	self:SortEquipList(true)
end

function ZhanjiangData:GetMaxEquipRemindNum()
	local num = 0
	for k, v in pairs(ZhanJiangEquipType) do
		if nil ~= self:GetMaxEquipByType(v) then
			num = num + 1
		end
	end
	return num
end

function ZhanjiangData:GetMaxEquipByType(equip_type)
	local score = 0
	local data = nil
	for k, v in pairs(self.owned_equip_t) do
		local item_cfg = ItemData.Instance:GetItemConfig(v.item_id)
		if nil ~= item_cfg then
			if item_cfg.type == equip_type then
				score = ItemData.Instance:GetItemScore(item_cfg)
			end
		end
	end

	local bag_data_list = BagData.Instance:GetItemDataList(equip_type)
	for k,v in pairs(bag_data_list) do
		local item_cfg = ItemData.Instance:GetItemConfig(v.item_id)
		if item_cfg and not EquipData.CheckHasLimit(item_cfg) and score < ItemData.Instance:GetItemScore(item_cfg) then
			score = ItemData.Instance:GetItemScore(item_cfg)
			data = v
		end
	end

	return data
end

-- 给穿戴着的装备排序
function ZhanjiangData:SortEquipList(is_force)
	if not self.sort_success or is_force then
		local temp_list = {}
		for k, v in pairs(self.owned_equip_t) do
			local item_cfg = ItemData.Instance:GetItemConfig(v.item_id)
			if nil == item_cfg then
				self.sort_success = false
				ItemData.Instance:NotifyItemConfigCallBack(self.item_config_callback_bind)
				return
			end
			if item_cfg.type == ItemData.ItemType.itHeroCuff then
				temp_list[1] = v
			elseif item_cfg.type == ItemData.ItemType.itHeroNecklace then
				temp_list[2] = v
			elseif item_cfg.type == ItemData.ItemType.itHeroHolyFlute then
				temp_list[3] = v
			end
		end
		self.owned_equip_t = temp_list
		self.sort_success = true
		if ItemData.Instance then
			ItemData.Instance:UnNotifyItemConfigCallBack(self.item_config_callback_bind)
		end
	end
end

--获取已有装备列表
function ZhanjiangData:GetOwnedEquipList()
	return self.owned_equip_t
end

--设置下一级英雄属性
function ZhanjiangData:SetHeroNextLevAttr(protocol)
	self.next_lev_attr_t = {}
	for i,v in ipairs(protocol.attr_info_list) do
		if v.type ~= GAME_ATTRIBUTE_TYPE.MAX_MP_ADD and 
				v.type ~= GAME_ATTRIBUTE_TYPE.PHYSICAL_DEFENCE_MIN_ADD and
				v.type ~= GAME_ATTRIBUTE_TYPE.PHYSICAL_DEFENCE_MAX_ADD and
				v.type ~= GAME_ATTRIBUTE_TYPE.MAGIC_DEFENCE_MIN_ADD and
				v.type ~= GAME_ATTRIBUTE_TYPE.MAGIC_DEFENCE_MAX_ADD then
			local temp_t = {type = v.type, value = v.value}
			table.insert(self.next_lev_attr_t, temp_t)
		end
	end
end

--设置下一级练体属性
function ZhanjiangData:SetHeroNextLiantiAttr(protocol)
	self.next_lev_lianti_attr = {}
	for i,v in ipairs(protocol.attr_info_list) do
		local temp_t = {type = v.type, value = v.value}
		table.insert(self.next_lev_lianti_attr, temp_t)
	end
	for k,v in pairs(self.next_lev_lianti_attr) do
		SortTools.KeyLowerSorter(v.type)
	end
end

--获取战将下级属性(不包括练体属性，如对boss暴击率)
function ZhanjiangData:GetHeroNextLvAttrsData()
	local next_lv_attrs_t = {}
	for k,v in pairs(self.next_lev_attr_t) do
		table.insert(next_lv_attrs_t, v)
	end
	return next_lv_attrs_t
end

--设置下一级战将各属性增加值
function ZhanjiangData:SetHeroNextAttrsAdd()
	if self:IsActivatedSucc() and self.hero_data.level < ZhanjiangData.HeroLvMax then 
		local cur_fu_ti_attrs = ZhanjiangData.CalcuFutiAttrsCfg(self.hero_attr_val_t.attrs)
		local cur_fight_power = {
					type = "fight_power", value = CommonDataManager.GetAttrSetScore(cur_fu_ti_attrs), 
					value_str = tostring(CommonDataManager.GetAttrSetScore(cur_fu_ti_attrs)),
				}

		local last_fu_ti_attrs = ZhanjiangData.CalcuFutiAttrsCfg(self.last_attr_val_t.attrs)
		local last_fight_power = {
					type = "fight_power", value = CommonDataManager.GetAttrSetScore(last_fu_ti_attrs), 
					value_str = tostring(CommonDataManager.GetAttrSetScore(last_fu_ti_attrs)),
				}

		local fight_add = {type = cur_fight_power.type, value = cur_fight_power.value - last_fight_power.value}

		local zhu_add = CommonDataManager.LerpAttributeAttr(self.last_attr_val_t.attrs, self.hero_attr_val_t.attrs)
		local fu_add = CommonDataManager.LerpAttributeAttr(last_fu_ti_attrs, cur_fu_ti_attrs)
		table.insert(fu_add, 1, fight_add)
		return RoleData.FormatRoleAttrStr(zhu_add, nil, 0), RoleData.FormatRoleAttrStr(fu_add)
	end
end

--穿上装备
function ZhanjiangData:PutOnEquipData(protocol)
	table.insert(self.owned_equip_t, protocol.item_data)
	self:SortEquipList(true)
end

--脱掉装备
function ZhanjiangData:PutOffEquipData(protocol)
	local del_index = nil
	for k, v in pairs(self.owned_equip_t) do
		if v.series == protocol.series then
			self.owned_equip_t[k] = nil
			self:SortEquipList(true)
			return
		end
	end
end

--设置英雄数据
function ZhanjiangData:SetHeroData(protocol)
	self.hero_data = {
						level = protocol.hero_level, 					
						need_bindGold = protocol.need_bindGold,								--下级英雄需要金币值
						bind_gold = protocol.cur_bindGold,									--当前绑金
					}
end

function ZhanjiangData:GetHeroData()
	return self.hero_data
end

--设置英雄状态
function ZhanjiangData:SetHeroState(protocol)
	self.hero_state = protocol.hero_state
end

function ZhanjiangData:GetHeroState()
	return self.hero_state or HERO_STATE.REST
end

--记录上一次英雄状态
function ZhanjiangData:SetHeroPreState(state)
	self.prev_state = state or HERO_STATE.REST
end

function ZhanjiangData:GetHeroPreState()
	return self.prev_state or HERO_STATE.REST
end

--设置升级英雄结果
function ZhanjiangData:SetUpHeroLvResult(protocol)
	self.up_hero_lv_resul = protocol.is_succeed
end
--升级英雄是否成功
function ZhanjiangData:IsUpHeroLvSucc()
	return self.up_hero_lv_resul == 1
end

--设置升级练体结果
function ZhanjiangData:SetUpLiantiLvResult(protocol)
	self.up_lianti_resul = protocol.is_succeed
end
--升级练体是否成功
function ZhanjiangData:IsUpLiantiLvSucc()
	return self.up_lianti_resul == 1
end

function ZhanjiangData:SetHPChanged(protocol)
	
end

function ZhanjiangData:GetHeroRemindNum()
	-- if RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL) < HeroConfig.actorLV then return 0 end
	-- if self.hero_data.level < ZhanjiangData.HeroLvMax then
	-- 	local own = BagData.Instance:GetItemNumInBagById(ZhanjiangData.ConsumeId)
	-- 	local cost = ZhanjiangData.GetHeroUpgradeCfg(self.hero_data.level).value
	-- 	return own >= cost and 1 or 0
	-- end
 -- 	return 0
end

-- function ZhanjiangData:CanRonghun()
-- 	local num = 0
-- 	for k, v in pairs(self.ronghun_data_list) do
-- 		num = self:CanRonghunLevelup(v)
-- 		if num > 0 then break end
-- 	end
-- 	return num
-- end

-- function ZhanjiangData:CanRonghunLevelup(data)
-- 	if data == nil then return 0 end
-- 	if data.level < self:GetRonghunMaxLevel(data.slot) then
-- 		local consume = self:GetRonghunUpGradeData(data.slot, data.level + 1)
-- 		if consume then
-- 			local num_in_bag = BagData.Instance:GetItemNumInBagById(consume.item_id)
-- 			if num_in_bag >= consume.num then
-- 				return 1
-- 			end
-- 		end
-- 	end
-- 	return 0
-- end

-- function ZhanjiangData:GetExerciseRemindNum()
-- 	local exercise_lev = self.hero_data.exer_ener_lev
-- 	if exercise_lev < ZhanjiangData.ExerciseLvMax then
-- 		local own = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PET_SPIRIT)
-- 		local cost = ZhanjiangData.GetHeroExerciseCfg(exercise_lev + 1).mana
-- 		return own >= cost and 1 or 0
-- 	end
--  	return 0
-- end

function ZhanjiangData:IsShowExerciseRemindIcon()
	-- local exercise_lev = self.hero_data.exer_ener_lev
	-- if exercise_lev < ZhanjiangData.ExerciseLvMax then
	-- 	local own = self.hero_data.spirit_value
	-- 	local cost = ZhanjiangData.GetHeroExerciseCfg(exercise_lev + 1).mana
	-- 	return (own >= cost) and true or false
	-- end
	return false
end

-- --获取战将属性配置
-- function ZhanjiangData.GetHeroAttrsCfg()
-- 	local cfg = {}
-- 	for i = HeroAttrCfgIDStart, HeroAttrCfgIDStart + ZhanjiangData.HeroLvMax - 1, 1 do
-- 		local temp_t = {
-- 			{type = GAME_ATTRIBUTE_TYPE.MAX_HP_ADD, value = StdMonster[i].nMaxHp},
-- 			{type = GAME_ATTRIBUTE_TYPE.PHYSICAL_ATTACK_MIN_ADD, value = StdMonster[i].nPhysicalAttackMin},
-- 			{type = GAME_ATTRIBUTE_TYPE.PHYSICAL_ATTACK_MAX_ADD, value = StdMonster[i].nPhysicalAttackMax},
-- 			{type = GAME_ATTRIBUTE_TYPE.MAGIC_ATTACK_MIN_ADD, value = StdMonster[i].nMagicAttackMin},
-- 			{type = GAME_ATTRIBUTE_TYPE.MAGIC_ATTACK_MAX_ADD, value = StdMonster[i].nMagicAttackMax},
-- 			{type = GAME_ATTRIBUTE_TYPE.WIZARD_ATTACK_MIN_ADD, value = StdMonster[i].nWizardAttackMin},
-- 			{type = GAME_ATTRIBUTE_TYPE.WIZARD_ATTACK_MAX_ADD, value = StdMonster[i].nWizardAttackMax},
-- 		}
-- 		table.insert(cfg, temp_t)			
-- 	end
-- 	return cfg
-- end

-- --获取战将下级属性增加值
-- function ZhanjiangData.GetHeroNextAddAttrsVal(n_lev)
-- 	local attrsCfg = ZhanjiangData.GetHeroAttrsCfg()
-- 	-- 两个属性差值(attr2 - attr1)
-- 	return CommonDataManager.LerpAttributeAttr(attrsCfg[n_lev], attrsCfg[n_lev + 1])
-- end

-- function ZhanjiangData:GetRonghunNameBySlot(slot)
-- 	local range = HeroConfig.HeroMeltSoul and #HeroConfig.HeroMeltSoul or 0
-- 	if slot > 0 and slot <= range then
-- 		return HeroConfig.HeroMeltSoul[slot].itemname
-- 	end
-- 	return ""
-- end

-- function ZhanjiangData:GetRonghunMaxLevel(slot)
-- 	local cfg = HeroConfig.HeroMeltSoul[slot]
-- 	return cfg and cfg.consume and #cfg.consume or 0
-- end

-- function ZhanjiangData:GetRonghunUpGradeData(slot, level)
-- 	local consume_data = {}
-- 	local cfg = HeroConfig.HeroMeltSoul[slot]
-- 	if cfg then
-- 		consume_data.item_id = cfg.itemid
-- 		consume_data.num = cfg.consume[level]
-- 		return consume_data
-- 	end
-- 	return nil
-- end

function ZhanjiangData.GetRonghunAttrCfg(slot, level)
	-- local prof = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
	local cfg = ConfigManager.Instance:GetServerConfig("ActorEvent/HeroMeltSoulAttrs/HeroMeltSoul".. slot .."AttrsCfg")
	return cfg and cfg[1] and cfg[1][level]
end

function ZhanjiangData:GetRonghunTotalAttr()
	local total_tab = {}
	total_tab.total_score = 0
	total_tab.total_level = 0
	total_tab.total_attr_cfg = nil

	for k, v in pairs(self.ronghun_data_list) do
		total_tab.total_level = total_tab.total_level + v.level
		local attr_cfg = ZhanjiangData.GetRonghunAttrCfg(v.slot, v.level)
		if v.level <= 0 then		-- 0级显示属性类型
			attr_cfg = TableCopy(ZhanjiangData.GetRonghunAttrCfg(v.slot, 1))
			for k, v in pairs(attr_cfg) do
				v.value = 0
			end
		end
		if attr_cfg then
			local score = CommonDataManager.GetAttrSetScore(attr_cfg)
			total_tab.total_score = total_tab.total_score + score
			total_tab.total_attr_cfg = CommonDataManager.AddAttr(total_tab.total_attr_cfg, attr_cfg)
		end
	end
	return total_tab
end

function ZhanjiangData:SetRonghunDataList()
	self.ronghun_data_list = {}
	local takeon_rideid = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_MERCENA_LEVEL)			-- 前四个
	local ride_expired_time =  RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_MERCENA_EXP)	-- 后四个
	for i = 1, 8 do
		local data = {}
		data.slot = i
		if i > 4 then
			data.level = bit:_and(bit:_rshift(ride_expired_time, (i - 5) * 8), 0xFF)
		else
			data.level = bit:_and(bit:_rshift(takeon_rideid, (i - 1) * 8), 0xFF)
		end
		table.insert(self.ronghun_data_list, data)
	end
end

function ZhanjiangData:GetRonghunDataList()
	return self.ronghun_data_list
end

function ZhanjiangData:GetZhanjiangScore()
	return CommonDataManager.GetAttrSetScore(self:GetHeroAttrList())
end