UnionPropertyData = UnionPropertyData or BaseClass()

UnionPropertyType = {  --关联属性类型
	SHOUHUN = 1, 	--兽魂+注灵
	COMPOSE = 2,	--等级+神炉
	JIMAI = 3, 		--经脉+翅膀
	FUMO = 4, 		--勋章+武魂
}

RuleCondition = {   	-- 条件
	ShouHun = 1,  		--兽魂
	JinMai = 2,	 		--筋脉
	Wing = 3, 			--翅膀
	Infuse = 4,			--注灵
	Level = 5, 			--等级
	Compose_Equip = 6,	--神炉装备 
	FuMo_Level = 7, 	--附魔
	Gem_Level = 8, 		--宝石等级
}

function UnionPropertyData:__init()
	if UnionPropertyData.Instance then
		ErrorLog("[UnionPropertyData] Attemp to create a singleton twice !")
	end
	UnionPropertyData.Instance = self
end

function UnionPropertyData:__delete()
	UnionPropertyData.Instance = nil
end

function UnionPropertyData:GetRuleUnionConfigByType(type)
	return ConfigManager.Instance:GetServerConfig("rule/UnionAttrsRulesConfig")[1][type]
end

function UnionPropertyData:GetCondition(rule, index)
	return ConfigManager.Instance:GetServerConfig("rule/UnionAttrsCondRulesConfig")[1][rule][index]
end

function UnionPropertyData:GetProperty(type, index)
	return ConfigManager.Instance:GetServerConfig("attr/UnionAttrsConfig")[1][type][index]
end

function UnionPropertyData:GetHadAndCosumeByRuleAndCondtion(rule, condition)
	if rule == nil or condition == nil then return end
	local cur_data = UnionPropertyData.Instance:GetCondition(rule, condition)
	if rule == RuleCondition.ShouHun then
		local data = BossData.Instance:GetNewShouHunData()
		local num = 0 
		for k, v in pairs(data) do
			if v.shouhun_level >= cur_data.param2 then
				num = num + 1
			end
		end
		return cur_data.param1, cur_data.param2, cur_data.type1, num
	elseif rule == RuleCondition.Infuse then
		local num_1 = 0
		local equip_data = EquipData.Instance:GetDataList()
		for k, v in pairs(equip_data) do
			if v.infuse_level >= cur_data.param2 then
				num_1 = num_1 + 1 
			end
		end
		return cur_data.param1, cur_data.param2, cur_data.type1, num_1
	elseif rule == RuleCondition.FuMo_Level then
		local fumo_level = EquipmentData.Instance:GetFumoInfoData()
		return cur_data.param1, cur_data.param2, cur_data.type1, fumo_level
	elseif rule == RuleCondition.Gem_Level then
		local data = EquipmentData.Instance:GetDiamondData()
		local num = 0
		for k, v in pairs(data) do
			for k, v in pairs(v.diamond_level) do
				if v >= cur_data.param2 then
					num = num + 1
				end
			end
		end	
		return cur_data.param1, cur_data.param2, cur_data.type1, num
	elseif rule == RuleCondition.JinMai then
		local meridian_lv = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_MERIDIAND_LEVEL)
		return cur_data.param1, cur_data.param2, cur_data.type1, meridian_lv
	elseif rule == RuleCondition.Wing then
		local wing_lv = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SWING_ID)
		return cur_data.param1, cur_data.param2, cur_data.type1, wing_lv
	elseif rule == RuleCondition.Level then
		local lv = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
		-- local circle = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)
		-- local num = 0
		-- if cur_data.param1 == 0 then
		-- 	num = cur_data.param2
		-- else
		-- 	num = cur_data.param1
		-- end
		return cur_data.param1, cur_data.param2, cur_data.type1, lv
	elseif rule == RuleCondition.Compose_Equip then
		if cur_data.type1 ~= nil then
			local item_type = ComposeData.Instance:GetComposeItemTypeByComposeType(cur_data.type1)
			local equip = EquipData.Instance:GetEquipByType(item_type)
			local compose_level = 0
			if equip then
				compose_level = equip.compose_level
			end
			return cur_data.param1, cur_data.param2, cur_data.type1, compose_level
		end
	end
	return 0,0,0,0
end
