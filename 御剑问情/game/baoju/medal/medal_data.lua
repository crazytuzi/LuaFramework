MedalData = MedalData or BaseClass()

function MedalData:__init()
	if MedalData.Instance then
		print_error("[MedalData] 尝试创建第二个单例模式")
		return
	end
	MedalData.Instance = self
	local cfg = ConfigManager.Instance:GetAutoConfig("xunzhangconfig_auto")
	self.upgrade_stuff_id_list = {}
	self.level_cfg = cfg.level_attr
	self.suit_cfg = cfg.suit_attr
	self.medal_list = {}
	self.medal_total_level = 0
	self.medal_total_data_index = 0

	self:SetAllUpgradeStuffID()
	self.medal_max_level = self.suit_cfg[#self.suit_cfg].total_level or 9999
	RemindManager.Instance:Register(RemindName.Medal, BindTool.Bind(self.GetMedalRemind, self))
end

function MedalData:__delete()
	RemindManager.Instance:UnRegister(RemindName.Medal)
	MedalData.Instance = nil
end

--根据灵玉ID获取灵玉的最大等级
function MedalData:GetLingYuMaxLevel(id)
	if not self.level_cfg then return 1000 end
	for k,v in pairs(self.level_cfg) do
		if v.xunzhang_id == id then
			return v.level_limit
		end
	end
	return 1000
end

--物品数据改变时,处理红点
function MedalData:HandleRedPoint()
	self:CheckMedalCanUpgrade()
end

--检测所有勋章是否能升级
function MedalData:GetMedalRemind()
	return self:CheckMedalCanUpgrade() and 1 or 0
end

--检测所有勋章是否能升级
function MedalData:CheckMedalCanUpgrade()
	local show_red = false
	--判断功能开启
	if not OpenFunData.Instance:CheckIsHide("baoju") then
		return show_red
	end
	for k,v in pairs(self.medal_list) do
		local cfg = self:GetLevelCfgByIdAndLevel(v.id, v.level)
		if v.level < self:GetLingYuMaxLevel(v.id) then
			local had_num = ItemData.Instance:GetItemNumInBagById(cfg.uplevel_stuff_id)
			if had_num >= cfg.uplevel_stuff_num then
				--存在能升级的勋章
				v.can_upgrade = true
				show_red = true
			else
				v.can_upgrade = false
			end
		else
			v.can_upgrade = false
		end
	end
	local list = TaskData.Instance:GetTaskCompletedList()
	if list[OPEN_FUNCTION_TYPE_ID.MEDAL] ~= 1 then
		return false
	end
	return show_red
end

--根据勋章类型和等级获取Cfg
function MedalData:GetLevelCfgByIdAndLevel(id, level)
	for k,v in pairs(self.level_cfg) do
		if v.xunzhang_id == id then
			local info = self:CalculateAttr(v, level)										--计算属性值
			info.uplevel_stuff_num = self:CalculateStuffNum(info.uplevel_stuff_num, level) 	--计算升级消耗
			return info
		end
	end
end

--计算等级对属性的加成
function MedalData:CalculateAttr(original_info, level)
	local info = self:CalculateNormalAttr(original_info, level)
	info = self:CalculateSpecialAttr(info, level)
	return info
end

--最终属性 = 普通属性 * 灵玉等级
function MedalData:CalculateNormalAttr(original_info, level)
	local attr_name = {"maxhp", "gongji", "fangyu", "mingzhong", "shanbi", "baoji", "jianren", "per_jingzhun", "per_baoji", "per_pofang", "per_mianshang"}
	local info = TableCopy(original_info)
	for k,v in pairs(info) do
		for i,name in pairs(attr_name) do
			if k == name then 
				info[name] = v * level
			end
		end
	end
	return info 
end

--0~9级：属性 * 0，10~19级：属性 * 1, 20~29级：属性 * 2
function MedalData:CalculateSpecialAttr(original_info, level)
	local attr_name = {"per_monster_exp", "per_boss_hurt", "per_monster_hurt"}
	local info = TableCopy(original_info)
	for k,v in pairs(info) do
		for i,name in pairs(attr_name) do
			if k == name then 
				if k == "per_monster_exp" then 	--该属性为百分比，其他属性是万分比
					v = v * 100
				end
				local addition_coe = math.floor(level / 10)
				info[k] = v * addition_coe
			end
		end
	end
	return info
end

--根据等级计算出该等级下升级所需材料(升级消耗 = 系数 * MIN(0.3 + 当前等级 * 0.05, 1) （向上取整）)
function MedalData:CalculateStuffNum(original_stuff_Num, level)
	local result = math.ceil(original_stuff_Num * math.min(0.3 + level * 0.05 , 1))
	return result
end

--根据升级材料获得勋章能否升级
function MedalData:GetAllUpgradeStuffID(id)
	local match_data = nil
	for k,v in pairs(self.level_cfg) do
		if v.uplevel_stuff_id == id then
			for k2,v2 in pairs(self.medal_list) do
				if v2.id == v.xunzhang_id then
					match_data = v
					break
				end
			end
		end
	end
end

--设置所有升级材料的ID
function MedalData:SetAllUpgradeStuffID()
	for k,v in pairs(self.level_cfg) do
		if self.upgrade_stuff_id_list[v.uplevel_stuff_id] == nil then
			self.upgrade_stuff_id_list[v.uplevel_stuff_id] = v.uplevel_stuff_id
		end
	end
end

--设置勋章数据
function MedalData:SetMedalInfo(protocol)
	local last_index = self.medal_total_data_index
	self.medal_total_level = 0
	local count = 1
	for k,v in pairs(protocol.level_list) do
		self.medal_total_level = self.medal_total_level + v
		if self.medal_list[count] ~= nil then
			self.medal_list[count].level = v
			self.medal_list[count].id = k
		else
			local data = {}
			data.level = v
			data.id = k
			self.medal_list[count] = data
		end
		count = count + 1
	end
	if self.medal_total_level == 0 then
		self.medal_total_data_index = 1
	else
		for k,v in pairs(self.suit_cfg) do
			if v.total_level <= self.medal_total_level then
				self.medal_total_data_index = k
			end
		end
	end

	if last_index < self.medal_total_data_index then
		MedalCtrl.Instance:ShowCurrentIcon()
	end
	self:CheckMedalCanUpgrade()
end

-- 判断勋章是否达到一阶
function MedalData:GetMedalIsOneJie()
	for k,v in pairs(self.suit_cfg) do
		if v.total_level <= self.medal_total_level then
			return true
		end
	end
	return false
end

--获取所有勋章数据
function MedalData:GetMedalInfo()
	return self.medal_list
end

--获取勋章套装属性配置
function MedalData:GetMedalSuitCfg()
	return self.suit_cfg
end

-- 判断当前套装是否激活
function MedalData:GetIsActiveById(id)
	return self.suit_cfg[id].total_level
end

--获取勋章总等级
function MedalData:GetMedalTotalLevel()
	return self.medal_total_level
end

--获取当前勋章套装属性的数据编号
function MedalData:GetMedalTotalDataIndex()
	return self.medal_total_data_index
end

--获取当前勋章套装颜色
function MedalData:GetMedalSuitRgbByColor(color)
	local rbg = {
		[1] = TEXT_COLOR.GREEN,
		[2] = TEXT_COLOR.BLUE,
		[3] = TEXT_COLOR.PURPLE,
		[4] = TEXT_COLOR.ORANGE,
		[5] = TEXT_COLOR.RED,
	}
	return rbg[color] or TEXT_COLOR.GREEN
end

function MedalData:GetMedalSuitActiveCfg()
	local level = 0
	local cfg = nil
	for k, v in pairs(MedalData.Instance:GetMedalSuitCfg()) do
		if v.total_level <= MedalData.Instance:GetMedalTotalLevel() and level < v.total_level then
			level = v.total_level
			cfg = v
		end
	end
	return cfg
end

-- 计算当前所有勋章总战力
function MedalData:CalculateCap()
	local attr = CommonStruct.Attribute()
	for k1,v1 in pairs(self.medal_list) do
		for k2,v2 in pairs(self.level_cfg) do
			if v1.id == v2.xunzhang_id then
				local info = self:CalculateAttr(v2, v1.level)
				local attr_cfg = CommonDataManager.GetAttributteByClass(info)
				attr = CommonDataManager.AddAttributeAttr(attr, attr_cfg)
				break
			end
		end
	end
	return CommonDataManager.GetCapability(attr)
end

-- 当前阶数
function MedalData:GetCurActiveJie()
	local cur_jie = 0
	for k,v in pairs(self.suit_cfg) do
		if self.medal_total_level >= v.total_level then
			cur_jie = cur_jie + 1
		end
	end
	return cur_jie
end

-- 最高等级
function MedalData:GetMaxLevel()
	return self.medal_max_level
end

-- 勋章对应的形象id
function MedalData:GetMedalResId(index)
	if index == nil or self.suit_cfg[index] == nil then return end
	return self.suit_cfg[index].res_id
end