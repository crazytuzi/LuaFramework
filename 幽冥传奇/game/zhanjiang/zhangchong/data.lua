--------------------------------------------------------
--战将相关数据
--------------------------------------------------------
local ZhangchongData = BaseClass()
local UPDATE_CFG = nil 				-- 升级消耗配置 不可修改
local ATTR_CFG = nil 				-- 等级属性配置 不可修改

ZhangchongData.DATA_CHANGE = "data_change"				--英雄数据改变
ZhangchongData.SKILL_CHANGE = "skill_change"			--英雄技能列表改变
ZhangchongData.HERO_STATE_CHANGE = "hero_state_change"	--英雄状态改变
ZhangchongData.OPEAT_CALLBACK = "opeat_callback"		--操作回调
ZhangchongData.EQ_CHANGE = "eq_change"		--操作回调

function ZhangchongData:__init(hero_type)
	--数据派发组件
	GameObject.Extend(self):AddComponent(EventProtocol):ExportMethods()

	self.hero_type = hero_type
	self.info_t = {} 			--服务端存储计算，宠物属性及信息
	self.info_t.attrs = {} 		--服务端存储计算，宠物属性
	self.skill_t = {} 			--宠物技能数据
	self.hero_state = nil
	
	self.zhanchong_suit_level_data = {}
	self.zhanchong_suit_level = nil

	--init cfg
	UPDATE_CFG = HeroConfig.upgradecfg
	for k,v in ipairs(HeroLevelAttrs) do
		if v.heroType == hero_type then
			ATTR_CFG = v.lvAttrs
			break
		end
	end
end

function ZhangchongData:__delete()
end

--获取英雄战将配置
function ZhangchongData:GetHeroUpgradeCfg(n_lev)
	return UPDATE_CFG[n_lev]
end

function ZhangchongData:IsMaxLevel()
	return self.info_t.level and self.info_t.level >= #UPDATE_CFG
	-- return true
end

function ZhangchongData:GetHeroUpgradeConsum()
	local cfg = UPDATE_CFG[self.info_t.level and self.info_t.level + 1 or 1]  or UPDATE_CFG[#UPDATE_CFG]
	return cfg.money.count
end

-- 可提升3级时提醒
function ZhangchongData:GetRemindHeroUpgradeConsum()
	local level = self.info_t.level and self.info_t.level + 1 or 1
	local cfg = UPDATE_CFG[level]
	local next_m = UPDATE_CFG[level + 1] 
	local next_next_m = UPDATE_CFG[level + 2] 

	return (cfg and cfg.money.count or 0) + (next_m and next_m.money.count or 0) + (next_next_m and next_next_m.money.count or 0)
end

function ZhangchongData:Getlevel()
	return self.info_t.level
end

function ZhangchongData:GetJie(level)
	local level = level or self.info_t.level
	local jie = math.ceil(level and level / 10 or 1)
	jie = jie > 0 and jie or 1
	return jie
end

function ZhangchongData:GetPart(level)
	local level = level or self.info_t.level
	local part = level and level % 10 or 1
	if level and level ~= 0 and part == 0 then
		part = 10
	end
	return part
end

function ZhangchongData:IsHaveHunHuan()
	return self.info_t.hunhuan_sign and self.info_t.hunhuan_sign > 0
end

local slot2type = {
	[1] = ItemData.ItemType.itHeroCuff,
	[2] = ItemData.ItemType.itHeroNecklace,
	[3] = ItemData.ItemType.itHeroDecorations,
	[4] = ItemData.ItemType.itHeroArmor,
}
function ZhangchongData:GetCanEquip()
	local data_t = self:GetOwnedEquipList()
	for i = 1, 4 do
		if BagData.Instance:GetBestEqByType(slot2type[i], data_t[i]) then
			return 1
		end
	end

	return 0
end

-- 是否可升级
function ZhangchongData:GetCanUp()
	return not self:IsMaxLevel() and self:GetHeroUpgradeConsum() <= RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_COIN)
end

-- 是否可提醒
function ZhangchongData:GetIsRemind()
	return not self:IsMaxLevel() and self:GetRemindHeroUpgradeConsum() <= RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_COIN)
end

-- 下发
local type2slot = {
	[ItemData.ItemType.itHeroCuff] = 1 ,
	[ItemData.ItemType.itHeroNecklace] = 2 ,
	[ItemData.ItemType.itHeroDecorations] = 3 ,
	[ItemData.ItemType.itHeroArmor] = 4 ,
}

function ZhangchongData:PutOnEquipData(protocol)
	self.eq_list[type2slot[protocol.item_data.type]] = protocol.item_data
	self:DispatchEvent(ZhangchongData.EQ_CHANGE, {})
end

function ZhangchongData:PutOffEquipData(protocol)
	for i,v in pairs(self.eq_list) do
		if v.series == protocol.series then
			self.eq_list[i] = nil
			break 
		end
	end
	RemindManager.Instance:DoRemindDelayTime(RemindName.DiamondPetCanActivate)
	self:DispatchEvent(ZhangchongData.EQ_CHANGE, {})
end

function ZhangchongData:GetOwnedEquipList()
	return self.eq_list or {}
end

function ZhangchongData:SetOwnedEquipList(protocol)
	self.eq_list = {}
	for i,v in ipairs(protocol.equip_data_list) do
		self.eq_list[type2slot[v.type]] = v
	end
end

function ZhangchongData:SetHeroInfo(protocol)
	self.info_t.hero_id = protocol.hero_id
	self.info_t.type = protocol.hero_type
	self.info_t.name = protocol.hero_name
	self.info_t.monster_id = protocol.monster_id
	self.info_t.hunhuan_sign = protocol.hunhuan_sign
	self.info_t[OBJ_ATTR.ENTITY_MODEL_ID] = protocol.model_id
	self.info_t[OBJ_ATTR.ACTOR_WING_APPEARANCE] = protocol.wing_id
	self.info_t[OBJ_ATTR.ACTOR_WEAPON_APPEARANCE] = protocol.weapon_id
	self.info_t.level = protocol.hero_level
	self.info_t.entity_type = EntityType.Monster
	self.info_t.attrs = {}

	table.insert(self.info_t.attrs, {type = GAME_ATTRIBUTE_TYPE.MAX_HP_ADD, value = protocol.max_hp})
	table.insert(self.info_t.attrs, {type = GAME_ATTRIBUTE_TYPE.PHYSICAL_ATTACK_MIN_ADD, value = protocol.min_phy_atk})
	table.insert(self.info_t.attrs, {type = GAME_ATTRIBUTE_TYPE.PHYSICAL_ATTACK_MAX_ADD, value = protocol.max_phy_atk})
	table.insert(self.info_t.attrs, {type = GAME_ATTRIBUTE_TYPE.PHYSICAL_DEFENCE_MIN_ADD, value = protocol.min_phy_def})
	table.insert(self.info_t.attrs, {type = GAME_ATTRIBUTE_TYPE.PHYSICAL_DEFENCE_MAX_ADD, value = protocol.max_phy_def})
	-- table.insert(self.info_t.attrs, {type = GAME_ATTRIBUTE_TYPE.MAGIC_ATTACK_MIN_ADD, value = protocol.min_magic_atk})
	-- table.insert(self.info_t.attrs, {type = GAME_ATTRIBUTE_TYPE.MAGIC_ATTACK_MAX_ADD, value = protocol.max_magic_atk})
	-- table.insert(self.info_t.attrs, {type = GAME_ATTRIBUTE_TYPE.WIZARD_ATTACK_MIN_ADD, value = protocol.min_daoshu_atk})
	-- table.insert(self.info_t.attrs, {type = GAME_ATTRIBUTE_TYPE.WIZARD_ATTACK_MAX_ADD, value = protocol.max_daoshu_atk})
	-- table.insert(self.info_t.attrs, {type = GAME_ATTRIBUTE_TYPE.ATTACK_BOSS_CRIT_RATE, value = protocol.critical_chance})
	-- table.insert(self.info_t.attrs, {type = GAME_ATTRIBUTE_TYPE.ATTACK_BOSS_CRIT_VALUE, value = protocol.critical_value})
	table.insert(self.info_t.attrs, {type = GAME_ATTRIBUTE_TYPE.DIZZY_RATE_ADD, value = protocol.paralyze_rate})
	-- table.insert(self.info_t.attrs, {type = GAME_ATTRIBUTE_TYPE.MAX_MP_ADD, value = protocol.max_mp})
	-- table.insert(self.info_t.attrs, {type = GAME_ATTRIBUTE_TYPE.MAGIC_DEFENCE_MIN_ADD, value = protocol.min_magic_def})
	-- table.insert(self.info_t.attrs, {type = GAME_ATTRIBUTE_TYPE.MAGIC_DEFENCE_MAX_ADD, value = protocol.max_magic_def})

	self:DispatchEvent(ZhangchongData.DATA_CHANGE, {})
end

function ZhangchongData:SetHeroSkillData(protocol)
	self.skill_t = {}
	for i, v in ipairs(protocol.skill_data) do
		local id = v.id or 0
		self.skill_t[id] = v
	end
	
	self:DispatchEvent(ZhangchongData.SKILL_CHANGE, {})
end

--获取英雄属性列表
function ZhangchongData:GetAttrList()
	return self.info_t.attrs
end

--获取英雄技能列表
local skill_list = {
	[HERO_TYPE.ZC] = {
		{is_not_active = true, item_id = 311, icon_id = 117},
		{is_not_active = true, item_id = 312, icon_id = 118},
		{is_not_active = true, item_id = 313, icon_id = 119},
	},

	[HERO_TYPE.JL] = {
		{is_not_active = true, item_id = 318, icon_id = 318},
	},
}
function ZhangchongData:GetSkillList()
	local cur_skill_list = skill_list[self.hero_type]
	for k,v in ipairs(cur_skill_list) do
		local id = v.icon_id or 0
		local vo = self.skill_t[id]
		if vo then
			vo.item_id = cur_skill_list[k].item_id
			vo.icon_id = cur_skill_list[k].icon_id
			cur_skill_list[k] = vo
		end
	end
	return cur_skill_list
end

--战将、附体属性数据
function ZhangchongData:GetTitleAttrStr()
	for k,v in pairs(self.info_t.attrs) do
		if v.type == GAME_ATTRIBUTE_TYPE.DIZZY_RATE_ADD then
			local data = RoleData.FormatRoleAttrStr({{type = GAME_ATTRIBUTE_TYPE.DIZZY_RATE_ADD, value = v.value},}, nil, 0)
			return data[1].type_str .. ":" .. data[1].value_str
		end
	end
	return ""
end

function ZhangchongData:GetHeroAttrData()
	local title_attrs = self.info_t.attrs
	--战将属性
	local zhanjiang_attr_data = RoleData.FormatRoleAttrStr(title_attrs, nil, 0)
	--附体属性
	local futi_attr_data = ZhangchongData.CalcuFutiAttrs(title_attrs)

	return zhanjiang_attr_data, futi_attr_data
end

--设置英雄状态
function ZhangchongData:SetHeroState(protocol)
	self.hero_state = protocol.hero_state
	self:DispatchEvent(ZhangchongData.HERO_STATE_CHANGE, {state = self.hero_state})
end

function ZhangchongData:GetHeroState()
	return self.hero_state or HERO_STATE.REST
end

function ZhangchongData:GetIsZhanChong()
	return self.hero_type == HERO_TYPE.ZC
end

function ZhangchongData:GetHeroType()
	return self.hero_type
end

function ZhangchongData:GetHeroRemindNum()
	if RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL) < HeroConfig.actorLV then return 0 end
	if self.info_t.level and self.info_t.level < #HeroConfig.upgradecfg then
		local own = BagData.Instance:GetItemNumInBagById(HeroConfig.consumeid)
		--PrintTable(self:GetHeroUpgradeCfg(self.info_t.level), level)
		local cost = self:GetHeroUpgradeCfg(self.info_t.level).money.count
		local next_cost = self:GetHeroUpgradeCfg(self.info_t.level + 1) and self:GetHeroUpgradeCfg(self.info_t.level + 1).money.count or 0
		local next_next_cost = self:GetHeroUpgradeCfg(self.info_t.level + 2) and self:GetHeroUpgradeCfg(self.info_t.level + 2).money.count or 0
		cost = cost + next_cost + next_next_cost
		return own >= cost and 1 or 0
	end
 	return 0
end

function ZhangchongData:GetMaxEquipRemindNum()
	-- if RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL) < HeroConfig.actorLV then return 0 end
	-- if self.info_t.level and self.info_t.level < HeroConfig.maxlev then
	-- 	local own = BagData.Instance:GetItemNumInBagById(HeroConfig.consumeid)
	-- 	local cost = ZhangchongData.GetHeroUpgradeCfg(self.info_t.level).value
	-- 	return own >= cost and 1 or 0
	-- end
 	return 0
end

----------------------------------------------------
--view通用方法

--战将属性展示
function ZhangchongData:SetHeroStateReq(state)
	ZhanjiangCtrl.SetHeroStateReq(self.info_t.hero_id, state)
end

--战将属性展示
function ZhangchongData:GetHeroAttrStr()
	return RoleData.FormatRoleAttrStr(self.info_t.attrs, nil, 0)
end

--角色属性数据
function ZhangchongData:GetRoleAttrStr()
	-- if self.hero_type == HERO_TYPE.ZC then
	-- 	return {}
	-- end
	if nil == self.info_t.level then
		return {}
	end
	local attr = {}
	if ATTR_CFG[self.info_t.level] then
		attr = ATTR_CFG[self.info_t.level].addattrs
	elseif self.info_t.level > 0 then
		attr = ATTR_CFG[#ATTR_CFG].addattrs
	end

	return RoleData.FormatRoleAttrStr(attr, nil, 0)
end

--获取英雄其他信息（属性除外）
function ZhangchongData:GetOtherInfoList()
	return self.info_t
end

--获取英雄模型数据
function ZhangchongData:GetHeroModelIdData()
	-- if self:IsHaveHunHuan() or self.hero_type == HERO_TYPE.JL  then
	-- 	return self.info_t
	-- else
	-- 	return {
	-- 		monster_id = self.info_t.monster_id,
	-- 		[OBJ_ATTR.ENTITY_MODEL_ID] = HeroConfig.upgradecfg[self.info_t.level or 1].modles[1],
	-- 		[OBJ_ATTR.ACTOR_WING_APPEARANCE] = self.info_t.wing_id,
	-- 		[OBJ_ATTR.ACTOR_WEAPON_APPEARANCE] = self.info_t.weapon_id,
	-- 	} 
	-- end
	return self.info_t
end

function ZhangchongData:GetZhanjiangScore()
	return CommonDataManager.GetAttrSetScore(self:GetAttrList())
end

--是否激活成功
function ZhangchongData:IsActivatedSucc()
	return (next(self.info_t.attrs) ~= nil)
end

--根据类型取的数据
function ZhangchongData:GetZhaongChongDataByType(type)
	local slot = type2slot[type]
	if self.eq_list then
		return self.eq_list[slot]
	end
	return nil
end

function ZhangchongData:GetSuitDataCommon(suitId, count, list, calctype)
	local bool_data = 0
	local num = 0

	for k, v in pairs(list) do
		local item_id = v.item_id or 0
		local config = ItemData.Instance:GetItemConfig(item_id)
		if calctype == 1 then --不向下兼容
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

-- 获取战宠的套装等级Data
function ZhangchongData:GetZhangchongSuitLevelData()
	local suit_config = SuitPlusConfig and SuitPlusConfig[15] or {}
	for k, v in ipairs(suit_config.list) do
		self.zhanchong_suit_level_data[v.suitId] = {bool = 0, count = 0, need_count = v.count}
		local bool_data,num = self:GetSuitDataCommon(v.suitId, v.count, self.eq_list, suit_config.calctype)
		self.zhanchong_suit_level_data[v.suitId].bool = bool_data
		self.zhanchong_suit_level_data[v.suitId].count = num
		if bool_data > 0 then
			self.zhanchong_suit_level = v.suitId
		end
	end

	return self.zhanchong_suit_level_data, self.zhanchong_suit_level or 0
end

function ZhangchongData:GetTextByTypeData(suittype, suitlevel, config, is_not_show_jichu)
	local suit_level_data = self:GetZhangchongSuitLevelData()
	local cur_suit_level_data = suit_level_data[suitlevel] or suit_level_data[1] or {}
	local text1 = ""
	if suitlevel <= 0 then
		text1 =  string.format("{color;f4ff00;%s}",string.format(Language.HaoZhuang.desc1, 1, "战宠套装", cur_suit_level_data.count or 0, cur_suit_level_data.need_count or 12, Language.HaoZhuang.active[1])).."\n"
	else
		local text6 = cur_suit_level_data.bool > 0 and Language.HaoZhuang.active[2] or Language.HaoZhuang.active[1]
		text1 = string.format("{color;f4ff00;%s}",string.format(Language.HaoZhuang.desc1, suitlevel, "战宠套装", cur_suit_level_data.count or 0, cur_suit_level_data.need_count or 12,text6)).."\n"
	end

	local text2 = "" 
	local text21 = ""
	local type_data = {1, 2, 3, 4}
	for i, slot in ipairs(type_data) do
		local name = Language.Zhanjiang.PetEquipName[slot]
		local equip = self.eq_list[slot]
		local color = "a6a6a6"
		if equip then
			local itemm_config = ItemData.Instance:GetItemConfig(equip.item_id)
		
			if itemm_config.suitId >= suitlevel then
				color = "00ff00"
			end
		end

		if i ~= #type_data then
			text2 = text2 .. string.format("{color;%s;%s}", color, name) .. " "
		else
			text2 = text2 .. string.format("{color;%s;%s}", color, name)
		end
	end
	local text3 = string.format("【%s】", text2) .. "\n"

	local attr_config = config.list[suitlevel] or config.list[1]
	local attr = attr_config.attrs
	local normat_attrs, special_attr =  RoleData.Instance:GetSpecailAttr(attr)
	local text4 = ""
	local text5 = ""
	if cur_suit_level_data.bool then
		local bool_color = cur_suit_level_data.bool > 0 and "ffffff" or "a6a6a6"
		local bool_color1 = cur_suit_level_data.bool > 0 and "ff0000" or "a6a6a6"
		local text7 = is_not_show_jichu and "" or string.format("{color;%s;%s}", "dcb73d", "基础属性：") .. "\n"
		text4 =  text7 .. string.format("{color;%s;%s}", bool_color, RoleData.FormatAttrContent(normat_attrs)) .."\n"
		if (#special_attr > 0) then
			local special_content = RoleData.FormatRoleAttrStr(special_attr, nil, prof_ignore)
			local jilv = (special_content[1].value/100) .."%"
			text5 = string.format("{color;%s;%s}", "dcb73d", "特殊属性：") .. "\n" .. string.format("{color;%s;%s}", bool_color1, string.format(Language.HaoZhuang.desc2, jilv, special_content[2].value))
		end
	else
		local text7 = is_not_show_jichu and "" or string.format("{color;%s;%s}", "dcb73d", "基础属性：") .. "\n"
		text4 =  text7 .. string.format("{color;%s;%s}", "a6a6a6", RoleData.FormatAttrContent(normat_attrs)) .."\n"
		if (#special_attr > 0) then
			local special_content = RoleData.FormatRoleAttrStr(special_attr, nil, prof_ignore)
			local jilv = (special_content[1].value/100) .."%"
			text5 = string.format("{color;%s;%s}", "dcb73d", "特殊属性：") .. "\n" .. string.format("{color;%s;%s}", "a6a6a6", string.format(Language.HaoZhuang.desc2, jilv, special_content[2].value))
		end	
	end
	local text = text1..text3..text4..text5
	return text
end

return ZhangchongData