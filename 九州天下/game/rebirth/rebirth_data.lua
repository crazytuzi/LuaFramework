RebirthData = RebirthData or BaseClass()

RebirthData.BaseAttrType = {[1] = "gongji",[2] = "mingzhong",[3] = "baoji",[4] = "ignore_fangyu",[5] = "hurt_increase",
	[6] = "max_hp",[7] = "fangyu",[8] = "hurt_reduce",[9] = "shanbi",[10] = "jianren"}
RebirthData.UpAttrType = {[1] = "gongji",[2] = "fangyu",[3] = "max_hp",[4] = "ignore_fangyu",[5] = "hurt_increase",[6] = "hurt_reduce"}

function RebirthData:__init()
	if RebirthData.Instance then
		print_error("[RebirthData] Attemp to create a singleton twice !")
	end
	RebirthData.Instance = self
end

function RebirthData:__delete()
	RebirthData.Instance = nil
end

function RebirthData:SetRebirthAllInfo(protocol)
	self.zhuansheng_level = protocol.zhuansheng_level
	self.cur_bless = protocol.cur_bless
	self.suit_activity_grade = protocol.suit_activity_grade
	self.suit_opened_grade = protocol.suit_opened_grade
	self.inuse_equip_list = protocol.inuse_equip_list
end

-- 当前转生等级
function RebirthData:GetRebirthLevel()
	return self.zhuansheng_level or 0
end

-- 当前祝福值
function RebirthData:GetCurBless()
	return self.cur_bless or 0
end

-- 套装当前激活等级
function RebirthData:GetSuitActivityGrade()
	return self.suit_activity_grade or 0
end

 --套装开启的等级
function RebirthData:GetSuitOpenedGrade()
	return  self.suit_opened_grade or 0
end

-- 10个槽信息
function RebirthData:GetInuseEquipList()
	return self.inuse_equip_list or {}
end

function RebirthData:GetAllRebirthCfg()
	if not self.all_rebirth_cfg then
		self.all_rebirth_cfg = ConfigManager.Instance:GetAutoConfig("new_zhuansheng_cfg_auto")
	end
	return self.all_rebirth_cfg or {}
end

-- 转生级别
function RebirthData:GetRebirthCfg()
	if not self.rebirth_cfg then
		self.rebirth_cfg = self:GetAllRebirthCfg().zhuansheng_grade
	end
	return self.rebirth_cfg
end

-- 根据等级获取单个属性
function RebirthData:GetOneRebirthCfgByLevel(level)
	if not self.one_rebirth_cfg then
		self.one_rebirth_cfg = ListToMap(self:GetRebirthCfg(), "zhuansheng_level")
	end
	return self.one_rebirth_cfg[level] or {}
end

-- 套装级别配置
function RebirthData:GetSuitGradeCfg(suit_grade)
	if not self.suit_grade_cfg then
		self.suit_grade_cfg = ListToMap(self:GetAllRebirthCfg().suit_grade_cfg, "suit_grade")
	end
	return self.suit_grade_cfg[suit_grade] or {}
end

-- 根据套装级别获取套装前缀配置
function RebirthData:GetSuitPrefixCfg(suit_grade)
	if not self.suit_prefix_cfg then
		self.suit_prefix_cfg =  ListToMap(self:GetAllRebirthCfg().suit_prefix, "suit_grade")
	end
	return self.suit_prefix_cfg[suit_grade] or {}
end

-- 获得装备的最低等级
function RebirthData:GetEquipLevel()
	local inuse_equip_list = self:GetInuseEquipList()
	local mini_equip_list = {}
	if not next(inuse_equip_list) then return mini_equip_list end
	for i = 1,GameEnum.ZHUANSHENGSYSTEM_SLOT_COUNT_MAX do
		local level_list = {}
		for j = 1, GameEnum.ZHUANSHENGSYSTEM_ATTR_VALUE do
			if inuse_equip_list[i].attr_param[j].attr_type ~= 0 then
				table.insert(level_list, inuse_equip_list[i].attr_param[j].attr_level)
			end
		end
		table.sort(level_list,function(a, b) return a < b end)
		if level_list[1] then
			mini_equip_list[i] = {}
			mini_equip_list[i].level = level_list[1]
			mini_equip_list[i].seq = i
		end
	end
	return mini_equip_list
end

-- 获得装备的最小等级
function RebirthData:GetMiniEquipLevel()
	local mini_equip_list = self:GetEquipLevel()
	local temp_list = {}
	for k, v in pairs(mini_equip_list) do
		table.insert(temp_list, v)
	end
	table.sort(temp_list, function(a, b) 
		if a and b then
			if a.level == b.level then
				local open_grade = RebirthData.Instance:GetSuitOpenedGrade()
				local inuse_equip_list = self:GetInuseEquipList()
				local a_pre = inuse_equip_list[a.seq].prefix_type
				local is_a_prefix = RebirthData.Instance:GetIsPreFix(open_grade, a.seq , a_pre)

				local b_pre = inuse_equip_list[b.seq].prefix_type
				local is_b_prefix = RebirthData.Instance:GetIsPreFix(open_grade, b.seq , b_pre)
				
				a.prefix = 0
				b.prefix = 0
				
				if is_a_prefix then
					a.prefix = 1
				elseif is_b_prefix then
					b.prefix = 1
				end

				if a.prefix == 0 and b.prefix == 0 then
					return a.seq <= b.seq
				else
					return a.prefix <= b.prefix
				end
			end
			return a.level < b.level
		end
	end)

	local _, v = next(temp_list)
	return v
end

-- 套装基础属性配置
function RebirthData:GetSuitBaseAttrCfg(suit_grade,slot_pox)
	if not self.suit_base_attr_cfg then
		self.suit_base_attr_cfg = ListToMap(self:GetAllRebirthCfg().suit_base_attr_cfg, "suit_grade","slot_pox")
	end
	return self.suit_base_attr_cfg[suit_grade][slot_pox]
end

-- 根据套装index、装备index获取额外属性
function RebirthData:GetExtraAttrtCfg(suit_grade,index)
	local extra_attr_cfg = {}
	if index == 0 then return extra_attr_cfg end

	local suit_activity_grade = self:GetSuitActivityGrade()
	local is_open = suit_grade <= suit_activity_grade
	if is_open then -- 已激活,读配置
		local suit_prefix_cfg = self:GetSuitPrefixCfg(suit_grade)
		local pre = suit_prefix_cfg["slot_" .. index .. "_prefix"]
		local vo = {attr_type = pre,attr_level = 5}
		for i = 1,4 do
			extra_attr_cfg[i] = vo
		end
	else -- 未激活，读协议
		local inuse_equip_list = self:GetInuseEquipList()
		local attr_param = inuse_equip_list[index].attr_param
		for k,v in pairs(attr_param) do
			if v.attr_type ~= 0 and v.attr_level ~= 0 then
				table.insert(extra_attr_cfg, v)
			end
		end
	end
	return extra_attr_cfg
end

-- 根据套装index、装备index获取洗练属性
function RebirthData:GetXilianAttrCfg(suit_grade,index)
	local xilianl_attr_cfg = {}
	if index == 0 then return xilianl_attr_cfg end

	local suit_activity_grade = self:GetSuitActivityGrade()
	local is_open = suit_grade <= suit_activity_grade
	if not is_open then
		local inuse_equip_list = self:GetInuseEquipList()
		local attr_xilian_param = inuse_equip_list[index].attr_xilian_param
		for k,v in pairs(attr_xilian_param) do
			if v.attr_type ~= 0 and v.attr_level ~= 0 then
				table.insert(xilianl_attr_cfg, v)
			end
		end
	end

	return xilianl_attr_cfg
end

-- 属性升级概率配置
function RebirthData:GetUpAttrRateCfg(suit_grade,atte_type,attr_grade)
	if not self.up_attr_rate_cfg then
		self.up_attr_rate_cfg = ListToMap(self:GetAllRebirthCfg().up_attr_rate_cfg, "suit_grade","atte_type","attr_grade")
	end
	return self.up_attr_rate_cfg[suit_grade][atte_type][attr_grade] or {}
end

-- 判断当前属性是否为LV5且属性相同
function RebirthData:IsSameAttr(index)
	local inuse_equip_list = self:GetInuseEquipList()
	if inuse_equip_list[index] then
		local extra_attr = inuse_equip_list[index].attr_param
		local attr_type, attr_level = extra_attr[1].attr_type, extra_attr[1].attr_level
		if attr_level < 5 then return false end
		for i = 2, GameEnum.ZHUANSHENGSYSTEM_ATTR_VALUE - 1 do
			if extra_attr[i].attr_type ~= attr_type then
				return false
			end
			if extra_attr[i].attr_level ~= attr_level then
				return false
			end
		end
	end

	return true
end

-- 物品说明配置
function RebirthData:GetItemInstruction(suit_grade)
	if not self.item_instruction then
		self.item_instruction = ListToMap(self:GetAllRebirthCfg().item_instruction, "suit_grade")
	end
	return self.item_instruction[suit_grade] or {}
end

-- 物品说明配置
function RebirthData:GetItemInstructionBygrade(suit_grade)
	if not self.item_instruction then
		self.item_instruction = ListToMap(self:GetAllRebirthCfg().item_instruction, "suit_grade")
	end
	return self.item_instruction[suit_grade] or {}
end

-- 是否达到指定的前缀
function RebirthData:GetIsPreFix(suit_grade, equip_index, prefix)
	local suit_prefix_cfg = self:GetSuitPrefixCfg(suit_grade)
	return prefix == suit_prefix_cfg["slot_" .. equip_index .. "_prefix"]
end

-- 通过激活等级获取转生等级
function RebirthData:GetZhuanShengLevelByActive(active_level)
	local zhuansheng_level = 0
	local rebirth_cfg = self:GetRebirthCfg()
	for k, v in pairs(rebirth_cfg) do
		if v.activate_need_level <= active_level then
			zhuansheng_level = v.zhuansheng_level
		end
	end

	return zhuansheng_level
end

-- 获取洗炼的属性皆为满级
function RebirthData:GetIsXiLianAllMaxLevel(equip_index)
	local inuse_equip_list = self:GetInuseEquipList()
	local attr_xilian_param = inuse_equip_list[equip_index].attr_xilian_param
	for i = 1, GameEnum.ZHUANSHENGSYSTEM_ATTR_VALUE do
		if attr_xilian_param[i].attr_level < 5 then
			return false
		end
	end

	return true
end

-- 读配置
function RebirthData:GetActivedEquipData(suit_grade)
	local suit_grade_cfg = RebirthData.Instance:GetSuitGradeCfg(suit_grade)
	local all_table = {}
	local temp = {}
	local index = 1
	for i = 1 ,10 do
		-- 可以控制每次取出来的元素
		if i % 2 == 0 then
			temp[2] = {}
			temp[2].item_id = suit_grade_cfg["slot_" .. i .."_itemid"]
			temp[2].index = i
			all_table[index] = temp
			temp = {}
			index = index + 1
		else
			temp[1] = {}
			temp[1].item_id = suit_grade_cfg["slot_" .. i .."_itemid"]
			temp[1].index = i
		end
	end

	return  all_table
end

-- 读协议
function RebirthData:GetCurEquipInfo()
	local inuse_equip_list = self:GetInuseEquipList()
	local all_table = {}
	local temp = {}
	local index = 1
	for i = 1 ,10 do
		if i % 2 == 0 then
			temp[2] = inuse_equip_list[i]
			temp[2].index = i
			all_table[index] = temp
			temp = {}
			index = index + 1
		else
			temp[1] = inuse_equip_list[i]
			temp[1].index = i
		 end
	end

	return all_table
end


function RebirthData:GetSuitEquipData(suit_grade)
	local data = {}
	local suit_activity_grade = RebirthData.Instance:GetSuitActivityGrade()
	local is_open = suit_grade <= suit_activity_grade
	if is_open then 				-- 已激活,读配置
		data = self:GetActivedEquipData(suit_grade)
	else 							-- 未激活，读协议
		data = self:GetCurEquipInfo()
	end

	return data
end

-- 获得套装属性
function RebirthData:GetSuitAttr(suit_grade)
	local suit_grade_cfg = self:GetSuitPrefixCfg(suit_grade)
	for k,v in pairs(Language.Rebirth.SuitAttr) do
		if suit_grade_cfg[k] ~= 0 then
			return suit_grade_cfg[k], v, k
		end
	end
	return 0, "", ""
end

-- 获得装备的id
function RebirthData:GetEquipId(suit_grade,equip_id)
	local suit_grade_cfg = self:GetSuitGradeCfg(suit_grade)
	return suit_grade_cfg["slot_" .. equip_id .. "_itemid"]
end

-- 转生升级红点
function RebirthData:ShowAdvanceRed()
	local rebirth_level = RebirthData.Instance:GetRebirthLevel()
	local one_rebirth_cfg = RebirthData.Instance:GetOneRebirthCfgByLevel(rebirth_level)
	local rebirth_num = ItemData.Instance:GetItemNumInBagById(one_rebirth_cfg.consume_item_id)

	local active_level = RebirthData.Instance:GetSuitActivityGrade()
	local zhuansheng_level = RebirthData.Instance:GetZhuanShengLevelByActive(active_level)
	if rebirth_num > 0 and rebirth_level < zhuansheng_level then
		return true
	end 
	return false
 end 

-- 洗练红点
function RebirthData:ShowXilianRed()
	local suit_opened_grade = self:GetSuitOpenedGrade()
	local cfg =self:GetSuitGradeCfg(suit_opened_grade)
	local inuse_equip_list = RebirthData.Instance:GetInuseEquipList()

	local suit_activity_grade = self:GetSuitActivityGrade()
	local suit_opened_grade = self:GetSuitOpenedGrade()
	if suit_activity_grade == suit_opened_grade then
		return false
	end

	for i = 1,GameEnum.ZHUANSHENGSYSTEM_SLOT_COUNT_MAX do
		if inuse_equip_list[i].slot_flag == 0 then	-- 未装备,有装备可以穿戴
			local item_id = cfg["slot_" .. i .. "_itemid"]
			local is_enough = ItemData.Instance:GetItemNumIsEnough(item_id, 1)
			if is_enough then
				return true
			end
		else										-- 有装备可以洗练
			local pre = inuse_equip_list[i].prefix_type
			local is_prefix = RebirthData.Instance:GetIsPreFix(suit_opened_grade, i , pre)

			local suit_opened_grade = self:GetSuitOpenedGrade()
			local suit_grade_cfg = self:GetSuitGradeCfg(suit_opened_grade)
			local item_id = suit_grade_cfg.upgrade_item_id
			local is_enough = ItemData.Instance:GetItemNumIsEnough(item_id, 1)

			if is_enough and not is_prefix then
				return true
			end
		end
	end
	return false
end

function RebirthData:CalCurAttr(rebirth_lv)
	local cur_rebirth_attr = {}
	cur_rebirth_attr.gongji = 0
	cur_rebirth_attr.maxhp = 0
	cur_rebirth_attr.fangyu = 0
	cur_rebirth_attr.mingzhong = 0
	for i=0,rebirth_lv do
		local one_rebirth_cfg = self:GetOneRebirthCfgByLevel(i)
		cur_rebirth_attr.gongji = cur_rebirth_attr.gongji + one_rebirth_cfg.gongji
		cur_rebirth_attr.maxhp = cur_rebirth_attr.maxhp + one_rebirth_cfg.maxhp
		cur_rebirth_attr.fangyu = cur_rebirth_attr.fangyu + one_rebirth_cfg.fangyu
		cur_rebirth_attr.mingzhong = cur_rebirth_attr.mingzhong + one_rebirth_cfg.mingzhong
	end
	return cur_rebirth_attr
end

-- 属性总览
function RebirthData:GetAttrTotal(cur_select)
	local capability_value = 0
	local total_attr_cfg = CommonStruct.Attribute()

	local suit_activity_grade = self:GetSuitActivityGrade()
	local is_open = cur_select <= suit_activity_grade

	for i = 1,GameEnum.ZHUANSHENGSYSTEM_SLOT_COUNT_MAX do
		local suit_base_attr_cfg = RebirthData.Instance:GetSuitBaseAttrCfg(cur_select, i - 1)
		local attr_type = Language.Rebirth.BaseAttrType[suit_base_attr_cfg.base_attr_type]

		local inuse_equip_list = self:GetInuseEquipList()
		if is_open or (not is_open and inuse_equip_list[i].slot_flag) ~= 0 then
			-- 基础属性表
			local base_attr_cfg = {}
			base_attr_cfg[RebirthData.BaseAttrType[suit_base_attr_cfg.base_attr_type]] = suit_base_attr_cfg.base_attr_value
			local base_data = CommonDataManager.GetAttributteByClass(base_attr_cfg)

			local extra_attr_cfg = RebirthData.Instance:GetExtraAttrtCfg(cur_select, i)
			-- 额外属性表
			for k,v in pairs(extra_attr_cfg) do
				local up_attr_rate_cfg = RebirthData.Instance:GetUpAttrRateCfg(cur_select, v.attr_type,v.attr_level)
				local up_attr_cfg ={}
				up_attr_cfg[RebirthData.UpAttrType[v.attr_type]] = up_attr_rate_cfg.attr_value
				local up_base_data = CommonDataManager.GetAttributteByClass(up_attr_cfg)
				base_data = CommonDataManager.AddAttributeAttr(base_data, up_base_data)
			end
			total_attr_cfg = CommonDataManager.AddAttributeAttr(total_attr_cfg, base_data)
		end
	end

	if is_open then
		local value, suit_type, attr_type = RebirthData.Instance:GetSuitAttr(cur_select)
		local blank_begin, blank_end = string.find(attr_type, "per")
		if blank_begin and blank_end then
			value = value / 100
		end
		total_attr_cfg[attr_type] = total_attr_cfg[attr_type] + value
	end

	local capability_value = CommonDataManager.GetCapability(total_attr_cfg)

	return capability_value, total_attr_cfg
end
