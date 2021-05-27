------------------------------------------------------------
-- 神炉Data
------------------------------------------------------------
ComposeData = ComposeData or BaseClass()
--配置顺序：血符、神盾、武魂、灵珠、勋章、复活戒指、麻痹戒指、护体戒指
ComposeType = 
{
	Xuefu = 1,
	Shendun = 2,
	Baoshi = 3,
	Hunzhu = 4,
	XunZhang = 5,
	FuhuoRing = 6,
	MabiRing = 7,
	HutiRing = 8,

}

-- 神兵激活状态
ComposeGodArmActiveState = {
	CanActive = -1,			-- 可激活
	NoActive = 0,			-- 不可激活
	Actived = 1, 			-- 已激活
}

function ComposeData:__init()
	if ComposeData.Instance then
		ErrorLog("[ComposeData]:Attempt to create singleton twice!")
	end

	ComposeData.Instance = self
	self.active_god_arm_num = 0 		-- 已激活神兵数量
end

function ComposeData:__delete()
	ComposeData.Instance = nil
	self.dataDic = nil
end

function ComposeData:GetComposeTypeByItemType(item_type, index)
	if item_type == ItemData.ItemType.itStoveBloodRune then
		return ComposeType.Xuefu
	elseif item_type == ItemData.ItemType.itStoveShield then
		return ComposeType.Shendun
	elseif 	item_type == ItemData.ItemType.itStoveDiamond then
		return ComposeType.Baoshi
	elseif 	item_type == ItemData.ItemType.itStoveSealBead then
		return ComposeType.Hunzhu
	elseif 	item_type == ItemData.ItemType.itDecoration then
		return ComposeType.XunZhang
	elseif 	item_type == ItemData.ItemType.itSpecialRing then
		if index == TabIndex.compose_new_mb then
			return ComposeType.MabiRing
		elseif index == TabIndex.compose_new_ht	 then
			return ComposeType.HutiRing
		elseif index == TabIndex.compose_new_fh	 then
			return ComposeType.FuhuoRing
		end
	end
	return -1	
end	

function ComposeData:GetItemTypeByComposeType(compose_type)
	if compose_type == ComposeType.Xuefu then
		return ItemData.ItemType.itStoveBloodRune, 0
	elseif compose_type == ComposeType.Shendun then
		return ItemData.ItemType.itStoveShield, 0
	elseif compose_type == ComposeType.Baoshi then
		return ItemData.ItemType.itStoveDiamond, 0
	elseif compose_type == ComposeType.Hunzhu then
		return ItemData.ItemType.itStoveSealBead, 0
	elseif compose_type == ComposeType.XunZhang then
		return ItemData.ItemType.itDecoration, 0
	elseif compose_type == ComposeType.MabiRing or compose_type == ComposeType.HutiRing then
		return ItemData.ItemType.itSpecialRing, 0
	elseif compose_type == ComposeType.FuhuoRing then
		return ItemData.ItemType.itSpecialRing, 1
	end
	return ItemData.ItemType.itStoveBloodRune, 0
end

--根据类型获取配置
function ComposeData:GetConfigByType(type)

	return EquipFurnaceCfg[type]
end	

function ComposeData:GetStepStar(level)
	--print("总数:" , level)
	if level == 0 then
		return 1,1
	end	
	local step = math.floor((level - 1) * 0.1) + 1
	local star = (level - 1) % 10 + 1
	--print("阶数:" , step , star)
	return step,star
end	

function ComposeData:GetStepStarConfig(type,level)
	local step,star = self:GetStepStar(level)
	local config = self:GetConfigByType(type) --得到对应类型的配置
	return config[step]
end	

--获取消耗
function ComposeData:GetConsume(type,level)
	local step,star = self:GetStepStar(level)
	local config = self:GetConfigByType(type) --得到对应类型的配置
	local currentStepConfig = config[step] --得到当前阶数配置
	if currentStepConfig then
		local currentConsumeConfig = currentStepConfig.upgradeConsumes
		if star <= #currentConsumeConfig then
			return currentConsumeConfig[star]
		end	
	end
	step = step + 1
	star = 1
	currentStepConfig = config[step] 

	if currentStepConfig then
		currentConsumeConfig = currentStepConfig.upgradeConsumes
		return currentConsumeConfig[star]
	end	
	return nil
end	

--获取属性
function ComposeData:GetAttr(type, level)
	local attrConfig = nil
	if type == ComposeType.Xuefu then
		attrConfig = ConfigManager.Instance:GetServerConfig("attr/FurnaceBloodRuneAttrsConfig")[1]
	elseif 	type == ComposeType.Shendun then
		attrConfig = ConfigManager.Instance:GetServerConfig("attr/FurnaceShieldAttrsConfig")[1]
	elseif 	type == ComposeType.Baoshi then
		attrConfig = ConfigManager.Instance:GetServerConfig("attr/FurnaceDiamondAttrsConfig")[1]
	elseif 	type == ComposeType.Hunzhu then
		attrConfig = ConfigManager.Instance:GetServerConfig("attr/FurnaceSealBeadAttrsConfig")[1]
	elseif type == ComposeType.FuhuoRing then
		attrConfig = ConfigManager.Instance:GetServerConfig("attr/FurnaceReliveRingAttrsConfig")[1]
	elseif type  ==  ComposeType.MabiRing then
		attrConfig = ConfigManager.Instance:GetServerConfig("attr/FurnaceDizzyRingAttrsConfig")[1]
	elseif type  ==  ComposeType.HutiRing then
		attrConfig = ConfigManager.Instance:GetServerConfig("attr/FurnaceProtectRingAttrsConfig")[1]
	end	

	if attrConfig then
		local step, star = self:GetStepStar(level)
		if attrConfig[step] then
			return attrConfig[step][star]
		end	
	end	
	return {}
end	

function ComposeData:GetRemindData(equip_type)
	local equip = nil 
	local num = nil
	if equip_type == ComposeType.Xuefu then
		equip = EquipData.Instance:GetEquipByType(ItemData.ItemType.itStoveBloodRune)
		num = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_MAGIC_SOUL)
	elseif equip_type == ComposeType.Shendun then
		equip = EquipData.Instance:GetEquipByType(ItemData.ItemType.itStoveShield)
		num = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SHIELD_SPIRIT)
	elseif equip_type == ComposeType.Baoshi then
		equip = EquipData.Instance:GetEquipByType(ItemData.ItemType.itStoveDiamond)
		num = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_GEM_CRYSTAL)
	elseif equip_type == ComposeType.Hunzhu then
		equip = EquipData.Instance:GetEquipByType(ItemData.ItemType.itStoveSealBead)
		num = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PEARL_CHIP)
	end
	if equip == nil then
		return 1 
	else
		local level = equip.compose_level
		local next_consume = ComposeData.Instance:GetConsume(equip_type, level + 1)
		if next_consume == nil then
			return 0
		else
			local equip_level, cur_level = 0, 0
			equip_level = self:GetRingCircle(equip_type, level + 1) or 100
			_, cur_level = self:GetRingCircle(equip_type, level + 1)
			local circle = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)
			local level = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
			--local true_level = circle*CIRCLEMAXLEVEl + level
			if circle >= equip_level and level >= cur_level then
				if next_consume[1] and next_consume[1].count ~= nil then
					if num and num >= next_consume[1].count then
						return 1
					else
						return 0 
					end
				else
					return 0 
				end
			else
				return 0
			end
		end
	end
end

function ComposeData:GetXFUpLvData()
	local consume = self:GetRemindData(ComposeType.Xuefu)
	return consume > 0 and 1 or 0
end

function ComposeData:GetShieldUpGradeData()
	local consume = self:GetRemindData(ComposeType.Shendun)
	return consume > 0 and 1 or 0
end

function ComposeData:GetDiamondUpLvData()
	local consume = self:GetRemindData(ComposeType.Baoshi)
	return consume > 0 and 1 or 0
end

function ComposeData:GetSoulBeadUpLvData()
	local consume = self:GetRemindData(ComposeType.Hunzhu)
	return consume > 0 and 1 or 0
end

function ComposeData:GetSpecialRingData(equip_type, index)

	local equip = nil 
	local num = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_RING_CRYSTAL) or 0
	local equip =  EquipData.Instance:GetEquipByType(ItemData.ItemType.itSpecialRing, index)
	if equip == nil then
		local level = 0
		local next_consume = ComposeData.Instance:GetConsume(equip_type, level + 1)
		local equip_level, cur_level = 0, 0
		equip_level = self:GetRingCircle(equip_type, level + 1) or 100
		_, cur_level = self:GetRingCircle(equip_type, level + 1)
		if next_consume ~= nil then
			local circle = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)
			local level = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
			--local true_level = circle*CIRCLEMAXLEVEl + level
			if circle >= equip_level and level >= cur_level then 
				if next_consume[1] and next_consume[1].count ~= nil then
					if ItemData.Instance:GetItemNumInBagById(next_consume[1].id, nil) >= next_consume[1].count then
						return 1
					else
						return 0
					end
				else
					return 0 
				end
			else
				return 0
			end
		else
			return 0
		end
	else
		local level = equip.compose_level
		local next_consume = ComposeData.Instance:GetConsume(equip_type, level + 1)
		local equip_level, cur_level = 0, 0
		equip_level = self:GetRingCircle(equip_type, level + 1) or 100
		_, cur_level = self:GetRingCircle(equip_type, level + 1)
		if next_consume ~= nil then
			if #next_consume > 1 then
				local circle = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)
				local level = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
				--local true_level = circle*CIRCLEMAXLEVEl + level
				if circle >= equip_level and level >= cur_level then 
					if next_consume[1] and next_consume[1].count ~= nil and next_consume[2] and next_consume[2].count then
						if num >= next_consume[2].count and ItemData.Instance:GetItemNumInBagById(next_consume[1].id, nil) >= next_consume[1].count then
							return 1
						else
							return 0
						end
					else
						return 0 
					end
				else
					return 0 
				end
			else
				if RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE) >= equip_level then
					if next_consume[1] and next_consume[1].count ~= nil then
						if num and num >= next_consume[1].count then
							return 1
						else
							return 0 
						end
					else
						return 0 
					end
				else
					return 0 
				end
			end
		else
			return 0 
		end
	end
end

--得到对应的转数
function ComposeData:GetRingCircle(type, level)
	local step,star = self:GetStepStar(level)
	local config = self:GetConfigByType(type) --得到对应类型的配置
	local currentStepConfig = config[step] 		--得到当前阶数配置
	local equip_level = 0 
	local cur_level = 0
	if currentStepConfig then
		local item_cfg = ItemData.Instance:GetItemConfig(currentStepConfig.itemId)
		if item_cfg == nil then return end
		for k,v in pairs(item_cfg.conds) do
			if v.cond == ItemData.UseCondition.ucMinCircle then
				equip_level = v.value
			end
			if v.cond == ItemData.UseCondition.ucLevel then
				cur_level = v.value
			end
		end
	end
	return equip_level, cur_level 
end


function ComposeData:GetMbRingUpLv()
	local consume = self:GetSpecialRingData(ComposeType.MabiRing,0) or 0
	return consume > 0 and 1 or 0
end

function ComposeData:GetFTRingUpLv()
	local consume = self:GetSpecialRingData(ComposeType.HutiRing,0) or 0
	return consume > 0 and 1 or 0
end

function ComposeData:GetFHRingUpLv()
	local consume = self:GetSpecialRingData(ComposeType.FuhuoRing,1) or 0
	return consume > 0 and 1 or 0
end


function ComposeData:GetType(item_type, hand_pos, useType)
	if item_type == ItemData.ItemType.itSpecialRing then
		if hand_pos == 0 then
			if useType == 2 then
				return ComposeType.MabiRing
			elseif useType == 3 then
				return ComposeType.HutiRing
			end
		else
			return ComposeType.FuhuoRing
		end
	end
end

function ComposeData:GetComposeItemTypeByComposeType(compose_type)
	if compose_type == ComposeType.Xuefu then
		return ItemData.ItemType.itStoveBloodRune
	elseif compose_type == ComposeType.Shendun then
		return ItemData.ItemType.itStoveShield
	elseif compose_type == ComposeType.Baoshi then
		return ItemData.ItemType.itStoveDiamond
	elseif compose_type == ComposeType.Hunzhu then
		return ItemData.ItemType.itStoveSealBead
	elseif compose_type == ComposeType.XunZhang then
		return ItemData.ItemType.itDecoration
	end
end

--======================神兵begin====================
function ComposeData:InitComposeGodArmData()
	self.god_arm_data = {}
	self.god_arm_consume_item_id = nil
	local prof = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
	for k, v in ipairs(TheShenArmyCfg.TheShenArmyList) do
		local tmp = {}
		tmp.name = v.name[prof]
		tmp.id = v.id
		tmp.icon = v.icon[prof] or 0
		tmp.picNum = v.picNum				-- 激活需要点亮的图鉴数
		tmp.consumes = v.consumes
		tmp.active_state = 0				-- 激活状态 (0:不可激活 1:已激活 -1:可激活)
		tmp.can_selec = k == 1 				-- 是否可被选中
		tmp.lit_num = 0 					-- 已点亮图鉴数
		tmp.eff_id = v.effId[prof]			-- 特效ID
		self.god_arm_data[k] = tmp
		if self.god_arm_consume_item_id == nil then
			self.god_arm_consume_item_id = v.consumes[1].id
		end
	end

end

function ComposeData:SetGodArmData(protocol)
	self.active_god_arm_num = 0
	for k, v in pairs(protocol.info_list) do
		local data = self.god_arm_data[k]
		if data then
			data.lit_num = v.lit_num
			if v.active_state ~= ComposeGodArmActiveState.Actived then
				data.active_state = v.lit_num < data.picNum and v.active_state or ComposeGodArmActiveState.CanActive
			else
				data.active_state = v.active_state
				self.active_god_arm_num = self.active_god_arm_num + 1
			end
			if k ~= 1 then
				data.can_selec = data.active_state ~= ComposeGodArmActiveState.NoActive
				local last_data = self.god_arm_data[k - 1]
				data.can_selec = last_data.active_state == ComposeGodArmActiveState.Actived
			end
		end
	end
end

-- 刷新一件神兵点亮信息
function ComposeData:UpdateOneGodArmLightNum(protocol)
	-- print("点亮---------")
	-- PrintTable(protocol)
	local update_data = self.god_arm_data[protocol.index]
	if update_data then
		update_data.lit_num = protocol.lit_num
		if update_data.lit_num == update_data.picNum then
			update_data.active_state = ComposeGodArmActiveState.CanActive
		end
	end
end

-- 刷新激活一件神兵后相关数据
function ComposeData:UpdateOneGodArmActive(protocol)
	-- print("激活----------")
	-- PrintTable(protocol)
	local update_data = self.god_arm_data[protocol.index]
	local next_data = self.god_arm_data[protocol.index + 1]
	if update_data then
		update_data.active_state = protocol.active_state
		self.active_god_arm_num = self.active_god_arm_num + 1
		if next_data then
			next_data.can_selec = true
		end
	end
end

function ComposeData:GetGodArmData()
	return self.god_arm_data
end

function ComposeData:GetActiveGodArmNum()
	return self.active_god_arm_num
end

function ComposeData:GetComsumeItemId()
	return self.god_arm_consume_item_id
end

function ComposeData.GetOneAttrContent(index)
	local attr_cfg = ComposeData.GetOneAttrCfg(index)
	if not attr_cfg then return end
	local prof = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
	local real_cfg = CommonDataManager.DelAttrByProf(prof, attr_cfg)
	local attr_str_t = RoleData.FormatRoleAttrStr(real_cfg)
	return attr_str_t
end

function ComposeData:GetAllActiveGodArmAddAttrContent()
	local attr_str_t = {}
	local add_attr_t = {}
	local prof = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
	for i = 1, self.active_god_arm_num, 1 do
		local attr_cfg = ComposeData.GetOneAttrCfg(i)
		if attr_cfg then
			attr_cfg = CommonDataManager.DelAttrByProf(prof, attr_cfg)
			add_attr_t = CommonDataManager.AddAttr(add_attr_t, attr_cfg)
		end
	end
	attr_str_t = RoleData.FormatRoleAttrStr(add_attr_t)
	return attr_str_t
end

function ComposeData.GetOneAttrCfg(index)
	local cfg = ConfigManager.Instance:GetServerConfig("attr/TheShenArmyAttrsConfig")
	if cfg then
		return cfg[1][1][index]
	end
end

--======================神兵end====================
function ComposeData:GetCanActiveUnionProperty()
	local data = UnionPropertyData.Instance:GetRuleUnionConfigByType(UnionPropertyType.COMPOSE)
	local equip_1 = EquipData.Instance:GetEquipByType(ItemData.ItemType.itStoveBloodRune)
	local equip_2 = EquipData.Instance:GetEquipByType(ItemData.ItemType.itStoveShield)
	local equip_3 = EquipData.Instance:GetEquipByType(ItemData.ItemType.itStoveDiamond)
	local equip_4 = EquipData.Instance:GetEquipByType(ItemData.ItemType.itStoveSealBead)
	if equip_1 == nil  or equip_2 == nil or equip_3 == nil or equip_4 == nil then return 0 end
	-- local lv = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
	-- local circle = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)
	for i, v in ipairs(data) do
		--local cur_condition_1 = UnionPropertyData.Instance:GetCondition(v.rule1, v.cond1) --等级
		local cur_condition_2 = UnionPropertyData.Instance:GetCondition(v.rule2, v.cond2)
		local cur_condition_3 = UnionPropertyData.Instance:GetCondition(v.rule3, v.cond3)
		local cur_condition_4 = UnionPropertyData.Instance:GetCondition(v.rule4, v.cond4)
		local cur_condition_5 = UnionPropertyData.Instance:GetCondition(v.rule5, v.cond5)
		-- local bool = false
		-- if cur_condition_1.param1 == 0 then
		-- 	if lv >= cur_condition_1.param2 then
		-- 		bool = true
		-- 	end
		-- else
		-- 	if circle >= cur_condition_1.param1 then
		-- 		bool = true
		-- 	end
		-- end
		if equip_1.compose_level >= cur_condition_2.param1 and equip_2.compose_level >= cur_condition_3.param1 and
			equip_3.compose_level >= cur_condition_4.param1 and equip_4.compose_level >= cur_condition_5.param1 then
			return i 
		end
	end
	return 0
end
