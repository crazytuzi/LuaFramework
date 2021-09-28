ShenShouData = ShenShouData or BaseClass()

function ShenShouData:__init()
	if ShenShouData.Instance ~= nil then
		print_error("[ShenShouData] attempt to create singleton twice!")
		return
	end
	ShenShouData.Instance = self

	self.grid_list = {}  		-- 神兽背包信息
	self.shenshou_list = {}		-- 神兽信息
	self.extra_zhuzhan_count = 0 -- 神兽额外助战位
	self.score = 0 				-- 唤灵积分
	self.huanling_list = {}		-- 唤灵列表
	self.select_seq = 0 		-- 抽到的唤灵物品seq
	self.cur_draw_times = 0 	-- 当前抽奖次数
	self.floating_label_list = {} -- 抽到物品的提示
	self.is_anim = false		-- 是否正在动画
	self.shenshou_cfg = ConfigManager.Instance:GetAutoConfig("shenshou_cfg_auto")

	self.shen_shou_back_packinfo = {}
	self.is_flush_shen_shou_back_packinfo = false

	self.equip_level = {}
	for k,v in ipairs(self.shenshou_cfg.equip_level)do
		self.equip_level[v.strength_level * 100 + v.slot_index] = v
	end
	self.equip_level_info = ListToMapList(self.shenshou_cfg.equip_level, "slot_index")
	self.other_cfg = self.shenshou_cfg.other

	self.equip_sshecheng_make = self:InitEquipSSHeChengMakeData()
	RemindManager.Instance:Register(RemindName.ShenShou, BindTool.Bind(self.GetShenShouEquipRemind, self))
	RemindManager.Instance:Register(RemindName.ShenShouFuling, BindTool.Bind(self.GetShenShouQiangHuaRemind, self))
	RemindManager.Instance:Register(RemindName.ShenShouHuanling, BindTool.Bind(self.GetShenShouHuanlingRemind, self))
	RemindManager.Instance:Register(RemindName.ShenShouCompose, BindTool.Bind(self.GetShenShouComposeRemind, self))
end

function ShenShouData:__delete()
    RemindManager.Instance:UnRegister(RemindName.ShenShou)
    RemindManager.Instance:UnRegister(RemindName.ShenShouFuling)
    RemindManager.Instance:UnRegister(RemindName.ShenShouHuanling)
     RemindManager.Instance:UnRegister(RemindName.ShenShouCompose)
    ShenShouData.Instance = nil
end

function ShenShouData:GetExtraNumCfg(extra_num)
	for k,v in pairs(self.shenshou_cfg.extra_num_cfg) do
		if extra_num == v.extra_num then
			return v
		end
	end
	return nil
end

function ShenShouData:SetExtraZhuZhanCount(count)
	self.extra_zhuzhan_count = count
end

function ShenShouData:GetExtraZhuZhanCount()
	return self.extra_zhuzhan_count
end

-- 设置神兽信息
function ShenShouData:SetShenshouListInfo(shenshou_list)
	self.shenshou_list = shenshou_list
end

-- 返回神兽信息
function ShenShouData:GetShenshouListInfo()
	return self.shenshou_list
end

-- 设置神兽背包信息
function ShenShouData:SetShenshouGridList(grid_list)
	self.grid_list = grid_list
	self.is_flush_shen_shou_back_packinfo = true
end

-- 设置神兽背包信息
function ShenShouData:GetShenshouGridList()
	return self.grid_list
end

-- 返回神兽背包信息
function ShenShouData:GetShenshouBackpackInfo()
	if self.is_flush_shen_shou_back_packinfo then
		local grid_list = {}
		for k,v in pairs(self.grid_list) do
			local vo = {}
			vo.index = v.index
			vo.item_id = v.item_id
			vo.strength_level = v.strength_level
			vo.shuliandu = v.shuliandu
			vo.attr_list = {}
			vo.attr_list = v.attr_list
			local item_cfg = self:GetShenShouEqCfg(v.item_id)
			vo.is_equip = item_cfg.is_equip
			vo.quality = item_cfg.quality
			vo.slot_index = item_cfg.slot_index
			vo.star_count = self:GetStarCount(v, item_cfg)
			grid_list[#grid_list + 1] = vo
		end
		self.shen_shou_back_packinfo = grid_list
		self.is_flush_shen_shou_back_packinfo = false
	end
	return self.shen_shou_back_packinfo
end

function ShenShouData:GetStarCount(param, item_cfg)
	local star_count = 0
	if param and item_cfg then
		for k,v in pairs(param.attr_list) do
			if v.attr_type > 0 then
				local random_cfg = self:GetRandomAttrCfg(item_cfg.quality, v.attr_type) or {}
				if random_cfg.is_star_attr == 1 then
					star_count = star_count + 1
				end
			end
		end
	end
	return star_count
end

function ShenShouData:SortList(quality, star_count, is_equip)
	return function(a, b)
		local order_a = 100000
		local order_b = 100000
		if a[is_equip] > b[is_equip] then
			order_a = order_a + 1000
		elseif a[is_equip] < b[is_equip] then
			order_b = order_b + 1000
		elseif a[is_equip] == b[is_equip] then
			if a[quality] > b[quality] then
				order_a = order_a + 1000
			elseif a[quality] < b[quality] then
				order_b = order_b + 1000
			elseif a[quality] == b[quality] then
				if a[star_count] > b[star_count] then
					order_a = order_a + 1000
				elseif a[star_count] < b[star_count] then
					order_b = order_b + 1000
				end
			end
		end

		return order_a > order_b
	end
end

function ShenShouData:SortList2(is_better, quality, star_count, is_equip)
	return function(a, b)
		local order_a = 100000
		local order_b = 100000
		if a[is_better] > b[is_better] then
			order_a = order_a + 10000
		elseif a[is_better] < b[is_better] then
			order_b = order_b + 10000
		elseif a[is_equip] > b[is_equip] then
			order_a = order_a + 1000
		elseif a[is_equip] < b[is_equip] then
			order_b = order_b + 1000
		elseif a[is_equip] == b[is_equip] then
			if a[quality] > b[quality] then
				order_a = order_a + 100
			elseif a[quality] < b[quality] then
				order_b = order_b + 100
			elseif a[quality] == b[quality] then
				if a[star_count] > b[star_count] then
					order_a = order_a + 10
				elseif a[star_count] < b[star_count] then
					order_b = order_b + 10
				end
			end
		end

		return order_a > order_b
	end
end

-- 筛选装备
function ShenShouData:FilterShenShouEq(quality, star)
	local list = {}
	local i = 1

	local bag_cfg = TableCopy(self:GetShenshouBackpackInfo())
	if star == 0 then
		if quality == -1 then
			table.sort(bag_cfg, self:SortList("quality", "star_count", "is_equip"))
			return bag_cfg
		else
			for k,v in ipairs(bag_cfg) do
				if quality == v.quality then
					list[i] = v
					i = i + 1
				end
			end
			table.sort(list, self:SortList("quality", "star_count", "is_equip"))
			return list
		end
	else
		if quality == -1 then
			for k,v in ipairs(bag_cfg) do
				if star == v.star_count and v.is_equip ==1 then
					list[i] = v
					i = i + 1
				end
			end
			table.sort(list, self:SortList("quality", "star_count", "is_equip"))
			return list
		else
			for k,v in ipairs(bag_cfg) do
				if quality == v.quality and star == v.star_count and v.is_equip ==1 then
					list[i] = v
					i = i + 1
				end
			end
			table.sort(list, self:SortList("quality", "star_count", "is_equip"))
			return list
		end
	end
end

-- 筛选装备(向上取)
function ShenShouData:UpFilterShenShouEq(quality, star, shou_id)
	local list = {}
	for k,v in ipairs(self:GetShenshouBackpackInfo()) do
		if quality <= v.quality and (star == 0 or star == v.star_count) and ((quality == 0 and star == 0) or v.is_equip ==1) and v.is_equip == 1 then
			v.is_better = self:GetIsBetterShenShouEquip(v, shou_id or 1) and 1 or 0
			table.insert(list, v)
		end
	end
	table.sort(list, self:SortList2("is_better", "quality", "star_count", "is_equip"))
	return list
end

-- 获得某个神兽是否激活
function ShenShouData:IsShenShouActive(shou_id)
	local eq_num = 0
	local shenshou_list = self:GetShenshouListInfo()
	for k,v in pairs(shenshou_list) do
		if shou_id == v.shou_id then
			for k1,v1 in pairs(v.equip_list) do
				if v1.item_id ~= 0 then
					eq_num = eq_num + 1
				end
			end
		end
	end
	return (eq_num == GameEnum.SHENSHOU_MAX_EQUIP_SLOT_INDEX + 1)
end

-- 获得某个神兽是否助战
function ShenShouData:IsShenShouZhuZhan(shou_id)
	local shenshou_list = self:GetShenshouListInfo()
	for k,v in pairs(shenshou_list) do
		if shou_id == v.shou_id then
			return (v.has_zhuzhan == 1)
		end
	end
	return false
end

-- 获取神兽装备配置
function ShenShouData:GetShenShouEqCfg(item_id)
	for k,v in pairs(self.shenshou_cfg.equip_cfg) do
		if item_id == v.item_id then
			return v
		end
	end
	return nil
end

-- 获取助战神兽数量
function ShenShouData:GetZhuZhanNum()
	local num = 0
	local shenshou_list = self:GetShenshouListInfo()
	for k,v in pairs(shenshou_list) do
		if v.has_zhuzhan == 1 then
			num = num + 1
		end
	end
	return num
end

-- 获取神兽信息
function ShenShouData:GetShenshouList(shou_id)
	local shenshou_list = self:GetShenshouListInfo()
	for k,v in pairs(shenshou_list) do
		if shou_id == v.shou_id then
			return v
		end
	end
	return nil
end

-- 获取一只神兽某个装备格子数据
function ShenShouData:GetOneSlotData(shou_id, slot_index)
	local shenshou_data = self:GetShenshouList(shou_id)
	if shenshou_data then
		for k,v in pairs(shenshou_data.equip_list) do
			if slot_index == v.slot_index then
				return v
			end
		end
		return nil
	end
end

-- 获取神兽装备基础属性配置
function ShenShouData:GetShenshouBaseList(slot_index, quality)
	for k,v in pairs(self.shenshou_cfg.equip_base_attr) do
		if slot_index == v.slot_index and quality == v.quality then
			return v
		end
	end
	return nil
end

-- 获取神兽装备升级属性配置
function ShenShouData:GetShenshouLevelList(slot_index, strength_level)
	return self.equip_level[strength_level * 100 + slot_index]
end

function ShenShouData:GetRandomAttrCfg(quality, attr_type)
	for k,v in pairs(self.shenshou_cfg.equip_attr) do
		if quality == v.quality and attr_type == v.attr_type then
			return v
		end
	end
	return nil
end

-- 获得一只神兽身上装备品质要求表
function ShenShouData:GetQualityRequirement(shou_id)
	local list = {}
	for k,v in pairs(self.shenshou_cfg.slot_need_quality_cfg) do
		if shou_id == v.shou_id then
			list[#list + 1] = v
		end
	end
	return list
end

-- 获得对应格子装备品质要求
function ShenShouData:GetQualityRequirementCfg(shou_id, slot)
	for k,v in pairs(self.shenshou_cfg.slot_need_quality_cfg) do
		if shou_id == v.shou_id and slot == v.slot then
			return v
		end
	end
	return nil
end

function ShenShouData:GetShenshouListData()
	local shenshou_cfg = TableCopy(self.shenshou_cfg.shou_cfg)
	for k,v in ipairs(shenshou_cfg) do
		v.has_zhuzhan = self:IsShenShouZhuZhan(v.shou_id)
		v.zhuzhan_num = self:GetZhuZhanNum()
		v.zonghe_pingfen = self:GetOneShenShouCap(v.shou_id)
		v.show_remind_bg = self:GetShenShouHasRemindImg(v.shou_id)
	end

	return shenshou_cfg
end

function ShenShouData:GetShenshouSeclectIndex()
	local shou_list = self:GetShenshouListData()
	local max_pingfen = 0
	for i=1, #shou_list do
		if shou_list[i].zonghe_pingfen >= max_pingfen and shou_list[i].has_zhuzhan then
			max_pingfen = shou_list[i].zonghe_pingfen
		end
	end

	for k,v in pairs(shou_list) do
		if max_pingfen == v.zonghe_pingfen then
			return k
		end
	end
	return 1
end

function ShenShouData:GetShenShouCfg(shou_id)
	for k,v in ipairs(self.shenshou_cfg.shou_cfg) do
		if shou_id == v.shou_id then
			return v
		end
	end
	return nil
end

-- 计算一只神兽的评分
function ShenShouData:GetOneShenShouCap(shou_id)
	local shenshou_list = self:GetShenshouList(shou_id)
	local zonghe_pingfen = 0
	-- 计算装备评分
	local eq_pingfen = 0
	if shenshou_list then
		for k,v in pairs(shenshou_list.equip_list) do
			if v.item_id > 0 then
				local one_eq_pingfen = self:GetShenShouItemScore(v, shou_id)							-- 一件装备综合评分
				eq_pingfen = eq_pingfen + one_eq_pingfen 												-- 装备总综合评分
			end
		end
	end

	-- 计算神兽基础属性评分
	local shou_cfg = self:GetShenShouCfg(shou_id)
	local shenshou_base_struct = CommonDataManager.GetAttributteByClass(shou_cfg)
	local shenshou_base_capability = CommonDataManager.GetCapability(shenshou_base_struct, nil, nil, true)
	zonghe_pingfen = eq_pingfen + shenshou_base_capability
	return zonghe_pingfen
end

-- 计算一只神兽身上所有装备的属性表
function ShenShouData:GetOneShenShouAttr(shou_id)
	local shenshou_list = self:GetShenshouList(shou_id)
	local equip_total_attr = CommonStruct.Attribute()
	if shenshou_list then
		for k,v in pairs(shenshou_list.equip_list) do
			if v.item_id > 0 then
				local shenshou_equip_cfg = self:GetShenShouEqCfg(v.item_id)
				if shenshou_equip_cfg then
					local base_shenshou_cfg = self:GetShenshouBaseList(shenshou_equip_cfg.slot_index, shenshou_equip_cfg.quality)
					local strength_shenshou_cfg = self:GetShenshouLevelList(shenshou_equip_cfg.slot_index, v.strength_level)
					local base_attr_struct = CommonDataManager.GetAttributteByClass(base_shenshou_cfg)
					local strength_attr_struct = CommonDataManager.GetAttributteByClass(strength_shenshou_cfg)
					local equip_attr = CommonDataManager.AddAttributeAttr(base_attr_struct, strength_attr_struct)
					equip_total_attr = CommonDataManager.AddAttributeAttr(equip_total_attr, equip_attr)
				end
			end
		end
	end
	return equip_total_attr
end

-- 计算一只神兽身上所有装备的基础属性表
function ShenShouData:GetOneShenShouBaseAttr(shou_id, bag_data)
	local shenshou_list = self:GetShenshouList(shou_id)
	local equip_total_attr = CommonStruct.Attribute()
	local bag_shenshou_equip_cfg = nil
	if bag_data then
		bag_shenshou_equip_cfg = ShenShouData.Instance:GetShenShouEqCfg(bag_data.item_id)
	end
	if shenshou_list then
		for k,v in pairs(shenshou_list.equip_list) do
			if v.item_id > 0 or (bag_shenshou_equip_cfg and bag_shenshou_equip_cfg.slot_index + 1 == k) then
				local shenshou_equip_cfg = (bag_shenshou_equip_cfg and bag_shenshou_equip_cfg.slot_index + 1 == k) and bag_shenshou_equip_cfg or self:GetShenShouEqCfg(v.item_id)
				if shenshou_equip_cfg then
					local base_shenshou_cfg = self:GetShenshouBaseList(shenshou_equip_cfg.slot_index, shenshou_equip_cfg.quality)
					local base_attr_struct = CommonDataManager.GetAttributteByClass(base_shenshou_cfg)
					equip_total_attr = CommonDataManager.AddAttributeAttr(equip_total_attr, base_attr_struct)
				end
			end
		end
	end
	return equip_total_attr
end

-- 获得可强化的装备列表
function ShenShouData:GetShenShouEqListData()
	local shenshou_list = self:GetShenshouListInfo()
	local index = 1
	local list = {}
	for k,v in pairs(shenshou_list) do
		if v and v.has_zhuzhan == 1 and v.equip_list then
			for k1, v1 in pairs(v.equip_list) do
				if v.shou_id > 0 and v1.item_id > 0 then
					list[index] = v1
					list[index].shou_id = v.shou_id
					local item_cfg = self:GetShenShouEqCfg(v1.item_id)
					list[index].quality = item_cfg.quality
					list[index].star_count = self:GetStarCount(v1, item_cfg)
					list[index].is_equip = item_cfg.is_equip
					index = index + 1
				end
			end
		end
	end
	table.sort(list, self:SortList("quality", "star_count", "is_equip"))
	return list
end

-- 获得当前选择装备的数据
function ShenShouData:GetCurEqData(index)
	local eq_data = self:GetShenShouEqListData()
	for k,v in pairs(eq_data) do
		if index == k then
			return v
		end
	end
	return nil
end

-- 筛选强化材料
function ShenShouData:FilterShenShouQhStuff(quality)
	local list = {}
	local i = 1

	local bag_cfg = self:GetShenshouBackpackInfo()
	if quality == -1 then
		table.sort(bag_cfg, self:SortList("quality", "star_count", "is_equip"))
		return bag_cfg
	elseif quality == 0 then
		for k,v in ipairs(bag_cfg) do
			if v.is_equip == 0 then
				list[i] = v
				i = i + 1
			end
		end
		table.sort(list, self:SortList("quality", "star_count", "is_equip"))
		return list
	else
		for k,v in pairs(bag_cfg) do
			if quality >= v.quality and v.is_equip ==1 then
				list[i] = v
				i = i + 1
			end
		end
		table.sort(list, self:SortList("quality", "star_count", "is_equip"))
		return list
	end
end

-- 获取一只神兽的技能列表
function ShenShouData:GetOneShouSkill(shou_id)
	local shou_cfg = self:GetShenShouCfg(shou_id)
	local loop = 0
	local list = {}
	if shou_cfg then
		for i=1, 4 do
			if shou_cfg["skill_id_" .. i] ~= "" and shou_cfg["skill_level_" .. i] ~= "" then
				list[loop] = {}
				list[loop].skill_type = shou_cfg["skill_id_" .. i]
				list[loop].level = shou_cfg["skill_level_" .. i]
				loop = loop + 1
			end
		end
	end
	return list
end

-- 获取神兽技能信息
function ShenShouData:GetShenShouSkillCfg(skill_type, level)
	for k,v in pairs(self.shenshou_cfg.skill_cfg) do
		if skill_type == v.skill_type and level == v.level then
			return v
		end
	end
	return nil
end

-- 神兽装备特殊属性战力值
function ShenShouData:GetShenShouEqCapability(shou_attr_list, shou_id, bag_data)
	local is_active = self:IsShenShouActive(shou_id)
	local base_shou_cfg = self:GetShenShouCfg(shou_id)
	local attr_list = {}
	if is_active then
		for k,v in pairs(shou_attr_list) do
			if v.attr_type > 0 then
				attr_list[v.attr_type] = v.attr_value
			end
		end
		local base_shou_attr = CommonDataManager.GetAttributteByClass(base_shou_cfg)
		local equip_all_base_attr = self:GetOneShenShouBaseAttr(shou_id, bag_data)
		base_shou_attr = CommonDataManager.AddAttributeAttr(base_shou_attr, equip_all_base_attr)
		local attr_t = CommonStruct.Attribute()
		attr_t.max_hp = (attr_list[1] or 0) * 0.0001 * base_shou_attr.max_hp + (attr_list[10] or 0)
		attr_t.gong_ji = (attr_list[2] or 0) * 0.0001 * base_shou_attr.gong_ji + (attr_list[11] or 0)
		attr_t.fang_yu = (attr_list[3] or 0) * 0.0001 * base_shou_attr.fang_yu + (attr_list[12] or 0)
		attr_t.shan_bi = (attr_list[4] or 0) * 0.0001 * base_shou_attr.shan_bi + (attr_list[13] or 0)
		attr_t.ming_zhong = (attr_list[5] or 0) * 0.0001 * base_shou_attr.ming_zhong + (attr_list[14] or 0)
		attr_t.bao_ji = (attr_list[6] or 0) * 0.0001 * base_shou_attr.bao_ji + (attr_list[15] or 0)
		attr_t.jian_ren = (attr_list[7] or 0) * 0.0001 * base_shou_attr.jian_ren + (attr_list[16] or 0)
		attr_t.constant_zengshang = (attr_list[8] or 0) * 0.0001 * base_shou_attr.constant_zengshang + (attr_list[17] or 0)
		attr_t.constant_mianshang = (attr_list[9] or 0) * 0.0001 * base_shou_attr.constant_mianshang + (attr_list[18] or 0)

		local capability = CommonDataManager.GetCapability(attr_t, nil, nil, true)

		return capability
	else
		return 0
	end
end

--获得一件神兽装备综合评分
function ShenShouData:GetShenShouItemScore(item_data, shou_id)
	if item_data == nil or item_data.item_id <= 0 then
		return 0
	end

	local item_cfg = self:GetShenShouEqCfg(item_data.item_id)

	if item_cfg == nil or item_cfg.is_equip == 0 then
		return 0
	end
	local eq_pingfen = 0

	local shenshou_equip_cfg = self:GetShenShouEqCfg(item_data.item_id)
	if nil == shenshou_equip_cfg then return 0 end
	local base_shenshou_cfg = self:GetShenshouBaseList(shenshou_equip_cfg.slot_index, shenshou_equip_cfg.quality)
	local strength_shenshou_cfg = self:GetShenshouLevelList(shenshou_equip_cfg.slot_index, item_data.strength_level)
	local strength_attr_struct = CommonDataManager.GetAttributteByClass(strength_shenshou_cfg)
	local base_capability = CommonDataManager.GetCapability(base_shenshou_cfg, nil, nil, true)      			-- 装备基础评分
	local strengthen_capability = CommonDataManager.GetCapability(strength_attr_struct, nil, nil, true)   		-- 锻造总评分
	local bestattr_capability = self:GetShenShouEqCapability(item_data.attr_list, shou_id)  -- 极品属性追加总评分
	local zhuangbei_pingfen = base_capability + strengthen_capability +  bestattr_capability 	-- 装备综合评分
	eq_pingfen = eq_pingfen + zhuangbei_pingfen

	return eq_pingfen
end

function ShenShouData:GetIsBetterShenShouEquip(item_data, shou_id)
	if item_data == nil then return false end

	local item_cfg = self:GetShenShouEqCfg(item_data.item_id)

	if item_cfg == nil or item_cfg.is_equip == 0 then
		return false
	end

	local cur_shou_id = shou_id
	local shenshou_list = self:GetShenshouList(cur_shou_id)

	local empty_cell_num = 1

	if shenshou_list then
		for k,v in pairs(shenshou_list.equip_list) do
			if v.item_id > 0 then		--非空位，比较评分
				if v.slot_index == item_cfg.slot_index then
					empty_cell_num = empty_cell_num - 1
					if self:GetShenShouItemScore(item_data, shou_id) > self:GetShenShouItemScore(v, shou_id) then
						return true
					end
				end
			else
				if v.slot_index == item_cfg.slot_index then
					local quality_requirement = self:GetQualityRequirementCfg(cur_shou_id, v.slot_index)
					if item_cfg.quality < quality_requirement.slot_need_quality then
						return false
					end
				end
			end
		end

		if empty_cell_num > 0 then	-- 有对应的空格子
			return true
		else
			return false
		end
	else
		local quality_requirement = self:GetQualityRequirement(cur_shou_id)
		for k,v in pairs(quality_requirement) do
			if v.slot == item_cfg.slot_index then
				if item_cfg.quality < v.slot_need_quality then
					return false
				end
			end
		end
		return true
	end
end

function ShenShouData:GetHasBetterShenShouEquip(item_data, shou_id, i)
	local quality_requirement = self:GetQualityRequirementCfg(shou_id, i - 1)
	local bag_cfg = self:GetShenshouBackpackInfo()
	for k,v in ipairs(bag_cfg) do
		if v.is_equip == 1 and v.slot_index == quality_requirement.slot and v.quality >= quality_requirement.slot_need_quality
			and self:GetShenShouItemScore(v, shou_id) > self:GetShenShouItemScore(item_data, shou_id) then
			return true
		end
	end
	return false
end

-- 某只神兽是否可激活
function ShenShouData:IsOneShenShouCanActive(shou_id)
	local shenshou_list = ShenShouData.Instance:GetShenshouList(shou_id)
	if shenshou_list then
		local num1 = 0
		local num2 = 0
		local num3 = 0
		for k, v in pairs(shenshou_list.equip_list) do
			if v.item_id <= 0 then
				if self:GetHasBetterShenShouEquip(v, shou_id, k) then
					num1 = num1 + 1
				end
			else
				num2 = num2 + 1
			end
		end
		return (num1 + num2) == 5
	else
		local num = 0
		for i=1, 5 do
			if self:GetHasBetterShenShouEquip(nil, shou_id, i) then
				num = num + 1
			end
		end
		return num == 5
	end
end

-- 助战神兽是否已满
function ShenShouData:IsFullZhuZhan()
	local other_cfg = ConfigManager.Instance:GetAutoConfig("shenshou_cfg_auto").other[1]
	local extra_zhuzhan_count = self:GetExtraZhuZhanCount()
	local total_zhuxhan_num = extra_zhuzhan_count + other_cfg.default_zhuzhan_count
	return self:GetZhuZhanNum() == total_zhuxhan_num
end

-- 某只神兽是否显示红点
function ShenShouData:GetShenShouHasRemindImg(shou_id)
	if self:IsFullZhuZhan() then
		if self:IsShenShouZhuZhan(shou_id) then
			for i = 1, 5 do
				local cell_data = self:GetOneSlotData(shou_id, i - 1)
				if self:GetHasBetterShenShouEquip(cell_data, shou_id, i) then
					return true
				end
			end
			return false
		else
			return false
		end
	else
		if self:IsShenShouActive(shou_id) then
			for i = 1, 5 do
				local cell_data = self:GetOneSlotData(shou_id, i - 1)
				if self:GetHasBetterShenShouEquip(cell_data, shou_id, i) then
					return true
				end
			end
			return false
		else
			return self:IsOneShenShouCanActive(shou_id)
		end
	end
end

function ShenShouData:GetShenShouEquipRemind()
	local num = 0
	local shenshou_cfg = self.shenshou_cfg.shou_cfg
	for k,v in ipairs(shenshou_cfg) do
		if self:GetShenShouHasRemindImg(v.shou_id) then
			num = num + 1
		end
	end
	return num
end

-- 神兽身上装备是否全部强化到满级
function ShenShouData:IsAllEqQhMax(eq_data)
	for k,v in pairs(eq_data) do
		if v.strength_level < GameEnum.SHENSHOU_EQ_MAX_LV then
			return false
		end
	end
	return true
end

function ShenShouData:GetShenShouQiangHuaRemind()
	local eq_data = self:GetShenShouEqListData()
	if #eq_data > 0 then
		local is_all_max = self:IsAllEqQhMax(eq_data)
		if is_all_max then
			return 0
		else
			return #self:FilterShenShouQhStuff(0) + #self:FilterShenShouQhStuff(1)
		end
	else
		return 0
	end
end

function ShenShouData:GetShenShouHuanlingRemind()
	local score = self:GetHuanLingScore()
	local huanling_get_draw = self:GetHuanLingDrawTime()
	local spend_score = self:GetHuanLingConsume(huanling_get_draw)
	local cue_draw = self:GetHuanLingDrawLimit()
	local num = (score > spend_score and huanling_get_draw < cue_draw) and 1 or 0
	return num
end

function ShenShouData:GetShenShouComposeRemind()
	local compose_list = {{need_qualit = 4, need_start_num = 2}, {need_qualit = 4, need_start_num = 3}}
	local num = 0
	for i,v in ipairs(compose_list) do
		local need_item_id, need_num = ShenShouData.Instance:GetIsNeedStuff(compose_list[i])
		local has_num = ItemData.Instance:GetItemNumInBagById(need_item_id)
		local equip_list = ShenShouData.Instance:GetShenshouComposeNum(compose_list[i])
		if need_item_id == 0 then
			num = math.floor(equip_list / 3)
		else
			num = math.min(math.floor(equip_list / 3), math.floor(has_num / need_num))
		end
	end
	return num
end

function ShenShouData:SetIsFlyMsg(is_fly)
	self.is_fly_msg = is_fly
end

function ShenShouData:GetIsFlyMsg()
	return self.is_fly_msg
end

function ShenShouData:GetCanQhLv(slot_index, cell_data, left_shuliandu)
	local target_cell_data = TableCopy(cell_data)
	if left_shuliandu > 0 then
		for i=1, GameEnum.SHENSHOU_EQ_MAX_LV do
			local cur_shuliandu_cfg = self:GetShenshouLevelList(slot_index, target_cell_data.strength_level)
			local next_shuliandu_cfg = self:GetShenshouLevelList(slot_index, target_cell_data.strength_level + 1)
			if cur_shuliandu_cfg == nil or next_shuliandu_cfg == nil then
				break
			end
			local upgrade_need_shuliandu = cur_shuliandu_cfg.upgrade_need_shulian - target_cell_data.shuliandu
			if left_shuliandu >= upgrade_need_shuliandu then
				left_shuliandu = left_shuliandu - upgrade_need_shuliandu
				target_cell_data.strength_level = target_cell_data.strength_level + 1
				target_cell_data.shuliandu = 0
			else
				target_cell_data.shuliandu = target_cell_data.shuliandu + left_shuliandu
				left_shuliandu = 0
			end
		end
	end
	return target_cell_data.strength_level
end

function ShenShouData:SetShenshouHuanlingListInfo(protocol)
	self.score = protocol.score
	self.huanling_list = protocol.huanling_list
	self.cur_draw_times = protocol.cur_draw_times
end

function ShenShouData:SetShenshouHuanlingDrawInfo(protocol)
	self.score = protocol.score
	self.select_seq = protocol.seq
	self.cur_draw_times = protocol.cur_draw_times
end

function ShenShouData:GetHuanLingScore()
	return self.score
end

function ShenShouData:GetHuanLingDrawTime()
	return self.cur_draw_times
end

function ShenShouData:GetResultIndex()
	return self.select_seq + 1
end

function ShenShouData:GetHuanLingDrawLimit()
	return ConfigManager.Instance:GetAutoConfig("shenshou_cfg_auto").other[1].huanling_draw_limit
end

function ShenShouData:GetHuanLingRefreshConsume()
	return ConfigManager.Instance:GetAutoConfig("shenshou_cfg_auto").other[1].huanling_refresh_consume
end



function ShenShouData:InitEquipSSHeChengMakeData()
	local equipforge_cfg = ConfigManager.Instance:GetAutoConfig("shenshou_cfg_auto")
	local data_list = {}
	for k, v in ipairs(equipforge_cfg.compose_cfg) do
		data_list[v.give_start_num * 10000 + v.v_item_id] = v
	end
	return data_list
end

function ShenShouData:GetSSEquinHechengItemData(give_start_num, item_id)
	return self.equip_sshecheng_make[give_start_num * 10000 + item_id]
end

function ShenShouData:GetSSHechengEquipmentItemList(demand_data)
	local need_start_num = demand_data.need_start_num
	local need_qualit = demand_data.need_qualit
	local can_hecheng_item = ShenShouData.Instance:FilterShenShouEq(need_qualit, need_start_num)
	local already_select_index = ShenShouComposeView.Instance:GetEquipSSHeChengSacrificeList()
	for i = #can_hecheng_item, 1, -1 do
		for _, index in ipairs(already_select_index) do
			if can_hecheng_item[i].index == index then
				table.remove(can_hecheng_item, i)
				break
			end
		end
	end
	return can_hecheng_item
end

function ShenShouData:GetHuanLingList()
	local item_cfg = ConfigManager.Instance:GetAutoConfig("shenshou_cfg_auto").huanling_refresh_cfg or {}
	local item_list = {}
	for i = 1, GameEnum.SHENSHOU_MAX_RERFESH_ITEM_COUNT do
		item_list[i] = {}
		local huanling_seq = 0

		if self.huanling_list and self.huanling_list[i] then
			huanling_seq = self.huanling_list[i].huanling_seq and (self.huanling_list[i].huanling_seq + 1) or 0
		end
		
		if huanling_seq > 0 and item_cfg[huanling_seq] then
			item_list[i].item = item_cfg[huanling_seq].item
			item_list[i].draw = self.huanling_list[i].draw
		end	
	end

	return item_list
end

function ShenShouData:GetHuanLingConsume(draw_times)
	local draw_cfg = ConfigManager.Instance:GetAutoConfig("shenshou_cfg_auto").huanling_draw_cfg or {}
	for k,v in pairs(draw_cfg) do
		if draw_times == v.draw_times then
			return v.score
		end
	end
	return draw_cfg[#draw_cfg].score or 0
end

function ShenShouData:SetFloatingLabel(str)
	table.insert(self.floating_label_list, str)
end

function ShenShouData:StartFloatingLabel()
	for k,v in pairs(self.floating_label_list) do
		TipsCtrl.Instance:ShowFloatingLabel(v)
	end
	self.floating_label_list = {}
end

function ShenShouData:GetLevelInfoByIndex(solt_index)
	solt_index = solt_index or 0
	return self.equip_level_info[solt_index] or {}
end

function ShenShouData:GetOther()
	return self.other_cfg or {}
end

function ShenShouData:GetRanAttrList(quality, legend_num)
	local legend_attr_list = {}
	local rand_attr = {}
	local gonglve_legend_attr = ConfigManager.Instance:GetAutoConfig("shenshou_cfg_auto").equip_attr
	for k,v in pairs(gonglve_legend_attr) do
		if quality == v.quality and v.is_star_attr == 1 then
			table.insert(legend_attr_list, v)
		end
	end

	local num_list = GameMath.RandList(1, #legend_attr_list, legend_num)
	for k,v in pairs(num_list) do
		table.insert(rand_attr, legend_attr_list[v])
	end

	return rand_attr
end

function ShenShouData:GetShenshouComposeNum(data)
	local need_qualit = data.need_qualit
	local need_start_num = data.need_start_num
	local can_hecheng_item = ShenShouData.Instance:FilterShenShouEq(need_qualit, need_start_num)
	return #can_hecheng_item
end

function ShenShouData:GetIsNeedStuff(data)
	local need_qualit = data.need_qualit
	local need_start_num = data.need_start_num
	local compose_cfg = ConfigManager.Instance:GetAutoConfig("shenshou_cfg_auto").compose_cfg
	for i,v in ipairs(compose_cfg) do
		if v.need_start_num == need_start_num and v.need_qualit == need_qualit then
			return v.item_id, v.item_num
		end
	end
	return 0, 0
end