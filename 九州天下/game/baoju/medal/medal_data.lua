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
	if not OpenFunData.Instance:CheckIsHide("baoju_medal") then
		return show_red
	end
	for k,v in pairs(self.medal_list) do
		local cfg = self:GetLevelCfgByIdAndLevel(v.id, v.level)
		local next_cfg = self:GetLevelCfgByIdAndLevel(v.id, v.level + 1)
		if next_cfg ~= nil then
			local had_num = ItemData.Instance:GetItemNumInBagById(next_cfg.uplevel_stuff_id)
			if had_num >= next_cfg.uplevel_stuff_num then
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
	-- local list = TaskData.Instance:GetTaskCompletedList()
	return show_red
end

--根据勋章类型和等级获取Cfg
function MedalData:GetLevelCfgByIdAndLevel(id, level)
	for k,v in pairs(self.level_cfg) do
		if v.xunzhang_id == id and v.level == level then
			return v
		end
	end
end

--根据升级材料获得勋章能否升级
function MedalData:GetAllUpgradeStuffID(id)
	local match_data = nil
	for k,v in pairs(self.level_cfg) do
		if v.uplevel_stuff_id == id then
			for k2,v2 in pairs(self.medal_list) do
				if v2.level == v.level and v2.id == v.xunzhang_id then
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
			data.can_upgrade = false
			self.medal_list[count] = data
		end
		count = count + 1
	end
	if self.medal_total_level == 0 then
		self.medal_total_data_index = 1
	else
		self.medal_total_data_index = #self.suit_cfg
		for i,v in ipairs(self.suit_cfg) do
			if self.medal_total_level <= v.total_level then
				self.medal_total_data_index = i
				break
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
			if v1.level == v2.level and v1.id == v2.xunzhang_id then
				local attr_cfg = CommonDataManager.GetAttributteByClass(v2)
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

--最高阶数
function MedalData:GetMaxOtherNum()
	return #self.suit_cfg
end

-- 勋章对应的形象id
function MedalData:GetMedalResId(index)
	if index == nil or self.suit_cfg[index] == nil then return end
	return self.suit_cfg[index].res_id
end