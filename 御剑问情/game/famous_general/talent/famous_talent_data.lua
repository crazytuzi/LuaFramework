FamousTalentData = FamousTalentData or BaseClass()

function FamousTalentData:__init()
	FamousTalentData.Instance = self
	self.talent_info_list = {}
	local talent_cfg = ConfigManager.Instance:GetAutoConfig("greate_soldier_config_auto")
	self.talent_list_cfg = ListToMap(talent_cfg.talent_list, "talent_type")
	self.talent_grid_list_cfg = ListToMap(talent_cfg.grid_list, "grid_id")

	self.talent_skill_cfg = ListToMap(talent_cfg.talent_skill, "skill_id", "skill_star")
	self.talent_skill_item_cfg = ListToMapList(talent_cfg.talent_skill, "book_id")
	self.talent_skill_type_cfg = ListToMapList(talent_cfg.talent_skill, "skill_type")

	RemindManager.Instance:Register(RemindName.FamousTalent, BindTool.Bind(self.GetTalentRemind, self))

	self.talent_tab_info_list = {
		TALENT_TYPE.TALENT_MOUNT,
		TALENT_TYPE.TALENT_WING,
		TALENT_TYPE.TALENT_HALO,
		TALENT_TYPE.TALENT_FIGHTMOUNT,
		TALENT_TYPE.TALENT_SHENGGONG,
		TALENT_TYPE.TALENT_SHENYI,
		TALENT_TYPE.TALENT_FOOTPRINT,
	}
end

function FamousTalentData:__delete()
	RemindManager.Instance:UnRegister(RemindName.FamousTalent)
	FamousTalentData.Instance = nil
end

function FamousTalentData:SetTalentAllInfo(talent_info_list)
	self.talent_info_list = talent_info_list
end

function FamousTalentData:GetTalentAllInfo()
	return self.talent_info_list
end

function FamousTalentData:SetTalentOneGridInfo(protocol)
	self.talent_info_list[protocol.talent_type] = self.talent_info_list[protocol.talent_type] or {}
	self.talent_info_list[protocol.talent_type][protocol.talent_index] = protocol.grid_info
end

function FamousTalentData:GetTalentSkillConfig(skill_id, skill_star)
	if nil == self.talent_skill_cfg[skill_id] then
		return
	end
	return self.talent_skill_cfg[skill_id][skill_star]
end

function FamousTalentData:GetTalentTypeFirstConfigBySkillType(skill_type)
	local skill_cfg_list = self.talent_skill_type_cfg[skill_type]
	return skill_cfg_list[1]
end

function FamousTalentData:GetTalentQualityTypeByItemId(item_id)
	local skill_cfg_list = self.talent_skill_item_cfg[item_id]
	return skill_cfg_list[1].skill_quality, skill_cfg_list[1].skill_type
end

function FamousTalentData:GetTalentConfig(talent_type)
	return self.talent_list_cfg[talent_type]
end

function FamousTalentData:GetTalentTabInfoList()
	return self.talent_tab_info_list
end

function FamousTalentData:GetTalentCapability(talent_type)
	local attribute = self:GetTalentAttr(talent_type)
	local capability = CommonDataManager.GetCapabilityCalculation(attribute)

	for k,v in pairs(self.talent_info_list[talent_type]) do
		if v.is_open and v.skill_id > 0 then
			local skill_cfg = self:GetTalentSkillConfig(v.skill_id, v.skill_star)
			if skill_cfg.capability > 0 then
				capability = capability + skill_cfg.capability
			end
		end
	end

	return capability
end

function FamousTalentData:GetIsShowTalentRedPoint(talent_type)
	local is_show = OpenFunData.Instance:CheckIsHide("famous_general_talent")
	if not is_show then
		return false
	end
	local talent_list = self.talent_info_list[talent_type]
	if nil == talent_list then
		return false
	end

	for k,v in pairs(talent_list) do
		if 1 == v.is_open then
			if 0 == v.skill_id then
				local select_info = {talent_type = talent_type, grid_index = k}
				local item_list = self:GetBagTalentBookItems(select_info, true)
				if #item_list > 0 then
					return true
				end
			else
				local skill_cfg = self:GetTalentSkillConfig(v.skill_id, v.skill_star)
				if nil ~= skill_cfg then
					local item_num = ItemData.Instance:GetItemNumInBagById(skill_cfg.need_item_id)
					if item_num >= skill_cfg.need_item_count then
						return true
					end
				end
			end
		end
	end

	return false
end

function FamousTalentData:GetBagTalentBookItems(select_info, only_need_has)
	local stuff_cfg = self:GetTalentBookItems()
	local bag_item_list = ItemData.Instance:GetBagItemDataList()
	local temp_list = {}
	for k,v in pairs(bag_item_list) do
		if stuff_cfg[v.item_id] then
			if nil == select_info then
				table.insert(temp_list, v)
			else
				local talent_skill_quality, talent_skill_type = self:GetTalentQualityTypeByItemId(v.item_id)
				if 0 == talent_skill_quality then
					local talent_cfg = self:GetTalentConfig(select_info.talent_type)
					--顶级技能槽只能装特定顶级技能
					if (GameEnum.TALENT_SKILL_GRID_MAX_NUM - 1) == select_info.grid_index then
						if talent_cfg.skill_type == talent_skill_type then
							table.insert(temp_list, v)
							if only_need_has then
								return temp_list
							end
						end
					else
						local has_same_type = false
						--过滤相同类型技能
						for k,v in pairs(self.talent_info_list[select_info.talent_type]) do
							local skill_cfg = self:GetTalentSkillConfig(v.skill_id, 0)
							if nil ~= skill_cfg and talent_skill_type == skill_cfg.skill_type then
								has_same_type = true
								break
							end
							--过滤顶级技能
							for k,v in pairs(self.talent_list_cfg) do
								if v.skill_type == talent_skill_type then
									has_same_type = true
									break
								end
							end
						end

						if not has_same_type then
							table.insert(temp_list, v)
							if only_need_has then
								return temp_list
							end
						end
					end
				end
			end
		end
	end
	return temp_list
end

function FamousTalentData:GetTalentBookItems()
	local item_list = {}
	for k, v in pairs(self.talent_skill_cfg) do
		if v[0] and v[0].book_id then
			local key = v[0].book_id
			item_list[key] = key
		end
	end
	return item_list
end

function FamousTalentData:GetTalentRemind()
	for k,v in pairs(self.talent_tab_info_list) do
		if self:GetIsShowTalentRedPoint(v) then
			return 1
		end
	end
	return 0
end

function FamousTalentData:GetTalentAttr(talent_type)
	local attribute = CommonStruct.Attribute()
	if nil == self.talent_info_list[talent_type] then
		return attribute
	end

	for k,v in pairs(self.talent_info_list[talent_type]) do
		if v.is_open and v.skill_id > 0 then
			local skill_cfg = self:GetTalentSkillConfig(v.skill_id, v.skill_star)
			-- 固定值
			if TALENT_SKILL_TYPE.TALENT_SKILL_TYPE_0 == skill_cfg.skill_type then
				attribute.max_hp = attribute.max_hp + skill_cfg.value
			elseif TALENT_SKILL_TYPE.TALENT_SKILL_TYPE_1 == skill_cfg.skill_type then
				attribute.gong_ji = attribute.gong_ji + skill_cfg.value
			elseif TALENT_SKILL_TYPE.TALENT_SKILL_TYPE_2 == skill_cfg.skill_type then
				attribute.fang_yu = attribute.fang_yu + skill_cfg.value
			elseif TALENT_SKILL_TYPE.TALENT_SKILL_TYPE_3 == skill_cfg.skill_type then
				attribute.ming_zhong = attribute.ming_zhong + skill_cfg.value
			elseif TALENT_SKILL_TYPE.TALENT_SKILL_TYPE_4 == skill_cfg.skill_type then
				attribute.shan_bi = attribute.shan_bi + skill_cfg.value
			elseif TALENT_SKILL_TYPE.TALENT_SKILL_TYPE_5 == skill_cfg.skill_type then
				attribute.bao_ji = attribute.bao_ji + skill_cfg.value
			elseif TALENT_SKILL_TYPE.TALENT_SKILL_TYPE_6 == skill_cfg.skill_type then
				attribute.jian_ren = attribute.jian_ren + skill_cfg.value
			elseif TALENT_SKILL_TYPE.TALENT_SKILL_TYPE_7 == skill_cfg.skill_type then
				attribute.constant_zengshang = attribute.constant_zengshang + skill_cfg.value
			elseif TALENT_SKILL_TYPE.TALENT_SKILL_TYPE_8 == skill_cfg.skill_type then
				attribute.constant_mianshang = attribute.constant_mianshang + skill_cfg.value

			-- 百分比+固定值 固定值部分
			elseif TALENT_SKILL_TYPE.TALENT_SKILL_TYPE_10 == skill_cfg.skill_type then
				attribute.max_hp = attribute.max_hp + skill_cfg.value
			elseif TALENT_SKILL_TYPE.TALENT_SKILL_TYPE_11 == skill_cfg.skill_type then
				attribute.gong_ji = attribute.gong_ji + skill_cfg.value
			elseif TALENT_SKILL_TYPE.TALENT_SKILL_TYPE_12 == skill_cfg.skill_type then
				attribute.fang_yu = attribute.fang_yu + skill_cfg.value
			elseif TALENT_SKILL_TYPE.TALENT_SKILL_TYPE_13 == skill_cfg.skill_type then
				attribute.ming_zhong = attribute.ming_zhong + skill_cfg.value
			elseif TALENT_SKILL_TYPE.TALENT_SKILL_TYPE_14 == skill_cfg.skill_type then
				attribute.shan_bi = attribute.shan_bi + skill_cfg.value
			elseif TALENT_SKILL_TYPE.TALENT_SKILL_TYPE_15 == skill_cfg.skill_type then
				attribute.bao_ji = attribute.bao_ji + skill_cfg.value
			elseif TALENT_SKILL_TYPE.TALENT_SKILL_TYPE_16 == skill_cfg.skill_type then
				attribute.jian_ren = attribute.jian_ren + skill_cfg.value
			elseif TALENT_SKILL_TYPE.TALENT_SKILL_TYPE_17 == skill_cfg.skill_type then
				attribute.constant_zengshang = attribute.constant_zengshang + skill_cfg.value
			elseif TALENT_SKILL_TYPE.TALENT_SKILL_TYPE_18 == skill_cfg.skill_type then
				attribute.constant_mianshang = attribute.constant_mianshang + skill_cfg.value
			end
		end 
	end

	--本页天赋百分比
	for k,v in pairs(self.talent_info_list[talent_type]) do
		if v.is_open and v.skill_id > 0 then
			local skill_cfg = self:GetTalentSkillConfig(v.skill_id, v.skill_star)
			if TALENT_SKILL_TYPE.TALENT_SKILL_TYPE_10 == skill_cfg.skill_type then
				attribute.max_hp = math.floor(attribute.max_hp * (1 + skill_cfg.per / 10000))
			elseif TALENT_SKILL_TYPE.TALENT_SKILL_TYPE_11 == skill_cfg.skill_type then
				attribute.gong_ji = math.floor(attribute.gong_ji * (1 + skill_cfg.per / 10000))
			elseif TALENT_SKILL_TYPE.TALENT_SKILL_TYPE_12 == skill_cfg.skill_type then
				attribute.fang_yu = math.floor(attribute.fang_yu * (1 + skill_cfg.per / 10000))
			elseif TALENT_SKILL_TYPE.TALENT_SKILL_TYPE_13 == skill_cfg.skill_type then
				attribute.ming_zhong = math.floor(attribute.ming_zhong * (1 + skill_cfg.per / 10000))
			elseif TALENT_SKILL_TYPE.TALENT_SKILL_TYPE_14 == skill_cfg.skill_type then
				attribute.shan_bi = math.floor(attribute.shan_bi * (1 + skill_cfg.per / 10000))
			elseif TALENT_SKILL_TYPE.TALENT_SKILL_TYPE_15 == skill_cfg.skill_type then
				attribute.bao_ji = math.floor(attribute.bao_ji * (1 + skill_cfg.per / 10000))
			elseif TALENT_SKILL_TYPE.TALENT_SKILL_TYPE_16 == skill_cfg.skill_type then
				attribute.jian_ren = math.floor(attribute.jian_ren * (1 + skill_cfg.per / 10000))
			elseif TALENT_SKILL_TYPE.TALENT_SKILL_TYPE_17 == skill_cfg.skill_type then
				attribute.constant_zengshang = math.floor(attribute.constant_zengshang * (1 + skill_cfg.per / 10000))
			elseif TALENT_SKILL_TYPE.TALENT_SKILL_TYPE_18 == skill_cfg.skill_type then
				attribute.constant_mianshang = math.floor(attribute.constant_mianshang * (1 + skill_cfg.per / 10000))
			end
		end
	end

	-- --对应系统进阶属性百分比
	-- for k,v in pairs(self.talent_info_list[talent_type]) do
	-- 	if v.is_open and v.skill_id > 0 then
	-- 		local skill_cfg = self:GetTalentSkillConfig(v.skill_id, v.skill_star)
	-- 		if TALENT_SKILL_TYPE.TALENT_SKILL_TYPE_9 == skill_cfg.skill_type then
	-- 			local attr = CommonStruct.Attribute()
	-- 			if TALENT_TYPE.TALENT_MOUNT == talent_type then
	-- 				attr = MountData.Instance:GetLevelAttribute()
	-- 			elseif TALENT_TYPE.TALENT_WING == talent_type then
	-- 				attr = WingData.Instance:GetLevelAttribute()
	-- 			elseif TALENT_TYPE.TALENT_HALO == talent_type then
	-- 				attr = HaloData.Instance:GetLevelAttribute()
	-- 			elseif TALENT_TYPE.TALENT_FIGHTMOUNT == talent_type then
	-- 				attr = FightMountData.Instance:GetLevelAttribute()
	-- 			elseif TALENT_TYPE.TALENT_SHENGGONG == talent_type then
	-- 				attr = ShengongData.Instance:GetLevelAttribute()
	-- 			elseif TALENT_TYPE.TALENT_FOOTPRINT == talent_type then
	-- 				attr = ShenyiData.Instance:GetLevelAttribute()
	-- 			elseif TALENT_TYPE.TALENT_SHENYI == talent_type then
	-- 				attr = FootData.Instance:GetLevelAttribute()
	-- 			end

	-- 			local extra_attr = CommonStruct.Attribute()
	-- 			if nil ~= skill_cfg then
	-- 				for k, v in pairs(attr) do
	-- 					extra_attr[k] = math.floor(v * (skill_cfg.per / 10000))
	-- 				end
	-- 			end

	-- 			attribute = CommonDataManager.AddAttributeAttr(attribute, extra_attr)
	-- 		end
	-- 	end
	-- end
	return attribute
end

function FamousTalentData:GetTalentGridActiveCondition(talent_type, grid_id)
	local grid_cfg = self.talent_grid_list_cfg[grid_id]
	if nil == grid_cfg then
		return
	end

	local system_type = FamousGeneralData.Instance:GetGeneralName(talent_type)
	if nil == system_type then
		return
	end

	local str = ""
	if grid_cfg.need_grade > 1 then
		str = string.format(Language.TalentTypeName.GradeCondition, system_type, CommonDataManager.GetDaXie(grid_cfg.need_grade - 1))
	else
		if grid_cfg.pre_quality == 0 then
			str = string.format(Language.TalentTypeName.PreActive, system_type)
		else
			str = string.format(Language.TalentTypeName.PreCondition, Language.TalentTypeName.TalentQuality[grid_cfg.pre_quality])
		end
	end

	return str
end

function FamousTalentData:GetTalentSkillNextConfig(skill_id, skill_star)
	if nil == self.talent_skill_cfg[skill_id] or nil == self.talent_skill_cfg[skill_id][skill_star] then
		return
	end

	local cur_cfg = self.talent_skill_cfg[skill_id][skill_star]
	local next_cfg = self.talent_skill_cfg[skill_id][skill_star + 1]
	if nil == next_cfg then
		local temp_cfg = nil ~= self.talent_skill_cfg[skill_id + 1] and self.talent_skill_cfg[skill_id + 1][0] or {}
		if temp_cfg.skill_type == cur_cfg.skill_type then
			next_cfg = temp_cfg
		end
	end

	return next_cfg
end

function FamousTalentData:GetTalentAttrDataList(skill_cfg, talent_type)
	if nil == skill_cfg then
		return
	end

	local config = TableCopy(Language.TalentTypeName.TalentAttrName[skill_cfg.skill_type])
	if nil == config then
		return {desc = skill_cfg.description}
	end
	for k,v in pairs(config) do
		if nil ~= v.icon then
			v.str = string.format(v.str, skill_cfg.value)
		elseif TALENT_SKILL_TYPE.TALENT_SKILL_TYPE_9 == skill_cfg.skill_type then
			v.str = string.format(v.str, Language.TalentTypeName.TalentTabName[talent_type] or "", skill_cfg.per / 100 .. "%")
		else
			v.str = string.format(v.str, skill_cfg.per / 100 .. "%")
		end
	end

	return config
end

function FamousTalentData:IsBagTalentBookItems(item_id)
	local stuff_cfg = self:GetTalentBookItems()
	return nil ~= stuff_cfg[item_id]
end