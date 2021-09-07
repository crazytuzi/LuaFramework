MojieData = MojieData or BaseClass(BaseEvent)
MOJIE_MAX_TYPE = 4 --魔戒最大类型
MojieData.Attr = {"gong_ji", "max_hp", "fang_yu", "ice_master",  "fire_master",  "thunder_master", "poison_master", "per_xixue", "per_stun"}
MojieData.MOJIE_EVENT = "mojie_event"	--魔戒信息变化
MojieData.ITEM_ID_T = {[0] = 26700, 26701, 26702, 26703}
MojieData.SKILL_T = {70, 71, 72}
function MojieData:__init()
	if MojieData.Instance then
		print_error("[MojieData] 尝试创建第二个单例模式")
	end

	MojieData.Instance = self
	self.mojie_list = {}
	self:IntiMojieInfo()
	self:AddEvent(MojieData.MOJIE_EVENT)
	self.mojieconfig_auto = ConfigManager.Instance:GetAutoConfig("mojieconfig_auto")
	RemindManager.Instance:Register(RemindName.Mojie, BindTool.Bind(self.GetMojieRemind, self))
	RemindManager.Instance:Register(RemindName.GouYu, BindTool.Bind(self.GetGouYuRemind, self))
	RemindManager.Instance:Register(RemindName.JieZhi, BindTool.Bind(self.GetShiPinRemind, self, EQUIPMENT_TYPE.EQUIPMENT_TYPE_ZHIJIE))
	RemindManager.Instance:Register(RemindName.GuaZhui, BindTool.Bind(self.GetShiPinRemind, self, EQUIPMENT_TYPE.EQUIPMENT_TYPE_GUAZHUI))

	self.level_list = {}			-- 勾玉首饰等级列表
	self.mojieconfig_auto_level = ListToMap(self.mojieconfig_auto.level or {}, "mojie_type","mojie_level")
	self.mojieconfig_stuff_level = ListToMap(self.mojieconfig_auto.level or {}, "up_level_stuff_id","mojie_level")
	self.get_mojie_open_level = ListToMapList(self.mojieconfig_auto.level or {}, "mojie_type","has_skill")
	self.mojie_config_auto_skill = ListToMap(self.mojieconfig_auto.skill or {}, "skill_id","level")
end

function MojieData:__delete()
	RemindManager.Instance:UnRegister(RemindName.Mojie)
	RemindManager.Instance:UnRegister(RemindName.GouYu)
	RemindManager.Instance:UnRegister(RemindName.JieZhi)
	RemindManager.Instance:UnRegister(RemindName.GuaZhui)
	MojieData.Instance = nil
end

function MojieData:IntiMojieInfo()
	for i = 0, MOJIE_MAX_TYPE do
		local vo = {}
		vo.item_id = MojieData.ITEM_ID_T[i] or 26700
		vo.mojie_skill_type = 0
		vo.mojie_level = 0
		vo.mojie_skill_id = 0
		vo.mojie_skill_level = 0
		vo.param = CommonStruct.ItemParamData()
		self.mojie_list[i] = vo
	end
end

function MojieData:SetMojieInfo(info)
	for k,v in pairs(info) do
		self.mojie_list[k].mojie_skill_type = v.mojie_skill_type
		self.mojie_list[k].mojie_level = v.mojie_level
		self.mojie_list[k].mojie_skill_id = v.mojie_skill_id
		self.mojie_list[k].mojie_skill_level = v.mojie_skill_level
	end
	self:NotifyEventChange(MojieData.MOJIE_EVENT)
end

function MojieData:GetMojieInfo()
	return self.mojie_list
end

function MojieData.IsMojieSkill(skill_id)
	for k,v in pairs(MojieData.SKILL_T) do
		if v == skill_id then
			return true
		end
	end
	return false
end

function MojieData:GetMojieLevelById(skill_id)
	for k,v in pairs(self.mojie_list) do
		if v.mojie_skill_id == skill_id then
			return v.mojie_level
		end
	end
	return 0
end

function MojieData.IsMojie(item_id)
	for k,v in pairs(MojieData.ITEM_ID_T) do
		if v == item_id then
			return true
		end
	end
	return false
end

function MojieData:GetOneMojieInfo(mojie_type)
	return self.mojie_list[mojie_type]
end


function MojieData:GetMojieInfoBySkillId(skill_id)
	for k,v in pairs(self.mojie_list) do
		if v.mojie_skill_id == skill_id then
			return v
		end
	end
	return nil
end

function MojieData:GetMojieLevel(mojie_type)
	if self.mojie_list[mojie_type] then
		return self.mojie_list[mojie_type].mojie_level, self.mojie_list[mojie_type].mojie_skill_level
	end
	return 0, 0
end

function MojieData:GetMojieCfg(mojie_type, mojie_level)
	-- for i,v in ipairs(self.mojieconfig_auto.level) do
	-- 	if v.mojie_type == mojie_type and v.mojie_level == mojie_level then
	-- 		return v
	-- 	end
	-- end

	if self.mojieconfig_auto_level[mojie_type] then
		return self.mojieconfig_auto_level[mojie_type][mojie_level]
	end

	return nil
end

function MojieData:GetMojieCfgForStuffId(mojie_stuff_id, mojie_level)
	-- for i,v in ipairs(self.mojieconfig_auto.level) do
	-- 	if v.up_level_stuff_id == mojie_stuff_id and v.mojie_level == mojie_level then
	-- 		return v
	-- 	end
	-- end

	if self.mojieconfig_stuff_level[mojie_stuff_id] then
		return self.mojieconfig_stuff_level[mojie_stuff_id][mojie_level]
	end

	return nil
end


function MojieData:GetMojieOpenLevel(mojie_type)
	if nil ~= self.get_mojie_open_level[mojie_type][1][1] then
		local mojie_item = {}
		mojie_item = self.get_mojie_open_level[mojie_type][1][1]
		return mojie_item.mojie_level,mojie_item.skill_level,mojie_item.skill_id,mojie_item.mojie_name
	end

	return 0, 0, 0, ""
end

function MojieData:GetMojieName(mojie_type, mojie_level)
	-- for i,v in ipairs(self.mojieconfig_auto.level) do
	-- 	if v.mojie_type == mojie_type and v.mojie_level == mojie_level then
	-- 		return v.mojie_name
	-- 	end
	-- end

	if nil ~= self.mojieconfig_auto_level[mojie_type][mojie_level] then
		return self.mojieconfig_auto_level[mojie_type][mojie_level].mojie_name
	end
	return ""
end

function MojieData:GetMojieRemind()
	return self:IsShowMojieRedPoint() and 1 or 0
end

function MojieData:IsShowMojieRedPoint(mojie_type)
	local level = GameVoManager.Instance:GetMainRoleVo().level
	for i,v in ipairs(self.mojieconfig_auto.level) do
		if mojie_type then
			if ItemData.Instance:GetItemNumInBagById(v.up_level_stuff_id) >= v.up_level_stuff_num and mojie_type == v.mojie_type and
				v.up_level_limit <= level and (self:GetOneMojieInfo(v.mojie_type) and v.mojie_level == self:GetOneMojieInfo(v.mojie_type).mojie_level)
				and self:GetMojieCfg(mojie_type, v.mojie_level + 1) and self:GetOneMojieInfo(v.mojie_type).mojie_skill_id >= 0 then
				return true
			end
		else
			if ItemData.Instance:GetItemNumInBagById(v.up_level_stuff_id) >= v.up_level_stuff_num and self:GetMojieCfg(v.mojie_type, v.mojie_level + 1) and
				v.up_level_limit <= level and (self:GetOneMojieInfo(v.mojie_type) and v.mojie_level == self:GetOneMojieInfo(v.mojie_type).mojie_level)
				and self:GetMojieCfg(v.mojie_type, v.mojie_level + 1) and self:GetOneMojieInfo(v.mojie_type).mojie_skill_id >= 0 then
				return true
			end
		end
	end
	return false
end

function MojieData:GetGouYuRemind()
	local level = self:GetLevelInfo(EQUIPMENT_TYPE.EQUIPMENT_TYPE_GOUYU)
	local gouyu_level = self:GetGouyuCfg().gouyu_level
	if self:GetIsMaxLevel() then return 0 end
	return ItemData.Instance:GetItemNumInBagById(gouyu_level[level].stuff_id) >= gouyu_level[level].stuff_num and 1 or 0
end

function MojieData:GetShiPinRemind(shipin_type)
	if shipin_type == EQUIPMENT_TYPE.EQUIPMENT_TYPE_ZHIJIE then
		local level = self:GetLevelInfo(EQUIPMENT_TYPE.EQUIPMENT_TYPE_ZHIJIE)
		local jiezhi_level = self:GetGuazhuiLevelCfg(EQUIPMENT_TYPE.EQUIPMENT_TYPE_ZHIJIE, level)
		local max_level = self:GetGuazhuiMaxCfg(EQUIPMENT_TYPE.EQUIPMENT_TYPE_ZHIJIE)
		if level >= max_level.level then return 0 end
		return ItemData.Instance:GetItemNumInBagById(jiezhi_level.stuff_id) >= jiezhi_level.stuff_num and 1 or 0
	else
		local level = self:GetLevelInfo(EQUIPMENT_TYPE.EQUIPMENT_TYPE_GUAZHUI)
		local guazhui_level = self:GetGuazhuiLevelCfg(EQUIPMENT_TYPE.EQUIPMENT_TYPE_GUAZHUI, level)
		local max_level = self:GetGuazhuiMaxCfg(EQUIPMENT_TYPE.EQUIPMENT_TYPE_GUAZHUI)
		if level >= max_level.level then return 0 end
		return ItemData.Instance:GetItemNumInBagById(guazhui_level.stuff_id) >= guazhui_level.stuff_num and 1 or 0
	end
	
end

function MojieData:IsShowGouYuRedPoint(mojie_type)
	if ItemData.Instance:GetItemNumInBagById(default_table.stuff_id) >= default_table.stuff_num then
		return true
	end
	return false
end

-- 设置勾玉信息
function MojieData:SetLevelListInfo(level_list)
	self.level_list = level_list			
end

function MojieData:SetLevelListTypeInfo(types, level)
	self.level_list[types] = level
end

-- 勾玉的等级
function MojieData:GetLevelInfo(types)
	return self.level_list[types] or 0
end

function MojieData:GetGouyuCfg()
	if nil == self.gouyu_cfg then
		self.gouyu_cfg = ConfigManager.Instance:GetAutoConfig("gouyu_config_auto")
	end
	return self.gouyu_cfg
end


function MojieData:GetGouyuLevelCfg(level)
	local gouyu_level_cfg = self:GetGouyuCfg().gouyu_level
	if gouyu_level_cfg and gouyu_level_cfg[level] then
		return gouyu_level_cfg[level]
	end
end

--获取属性最大配置
function MojieData:GetGouyuMaxCfg()
	return self:GetGouyuCfg().gouyu_level[#self:GetGouyuCfg().gouyu_level]
end

-- 勾玉是否是最高阶
function MojieData:GetIsMaxLevel()
	local level = MojieData.Instance:GetLevelInfo(EQUIPMENT_TYPE.EQUIPMENT_TYPE_GOUYU)
	if self:GetGouyuMaxCfg() and self:GetGouyuMaxCfg().level then
		if level >= self:GetGouyuMaxCfg().level then
			return true
		end
	end
	return false
end

function MojieData:GetGouyuShowCfg(level)
	local show_cfg = self:GetGouyuCfg().gouyu_show
	if show_cfg then
		for i,v in ipairs(show_cfg) do
			if level >= show_cfg[#show_cfg].gouyu_level then
				return show_cfg[#show_cfg], #show_cfg
			elseif show_cfg[i + 1] and level >= v.gouyu_level and level < show_cfg[i + 1].gouyu_level then
				return v, i
			end
		end
		return show_cfg[1], 1
	end
	return {}
end

--没有attr_cfg这个表
function MojieData:GetGouyuAttrCfg(level)
	local attr_cfg = self:GetGouyuCfg().attr_cfg

	for k,v in pairs(attr_cfg) do
		if v.gouyu_level == level then
			return v
		end
	end
end


-- 是否是勾玉
function MojieData:IsGouyu(item_id)
	local attr_cfg = self:GetGouyuCfg().other
	for k,v in pairs(attr_cfg) do
		if item_id == v.jihuo_need_item_id then
			return true
		end
	end
	return false
end

-- 获取当前兑换的勾玉
function MojieData:GetGouyuActivaCfg()
	local other_cfg = self:GetGouyuCfg().other
	if other_cfg then
		return other_cfg[1]
	end
end

--获取当前技能
function MojieData:GetMojieSkillCfg(skill_id, skill_level)
	-- for k,v in pairs(self.mojieconfig_auto.skill) do
	-- 	if skill_id == v.skill_id and skill_level == v.level then
	-- 		return v
	-- 	end
	-- end
	if self.mojie_config_auto_skill[skill_id] then
		return self.mojie_config_auto_skill[skill_id][skill_level]
	end
end

-- 戒指挂坠配置
function MojieData:GetGuazhuiLevelCfg(index, level)
	local cfg = self:GetGouyuCfg()
	if cfg then
		if EQUIPMENT_TYPE.EQUIPMENT_TYPE_ZHIJIE == index then
			if cfg.jiezhi_level then
				return cfg.jiezhi_level[level] or {}
			end
		else
			if cfg.guazhui_level then
				return cfg.guazhui_level[level] or {}
			end
		end
	end
	return {}
end

--挂坠index
function MojieData:GetGuazhuiIndex(stuff_id)
	local stuff_list = {
		[27761] = EQUIPMENT_TYPE.EQUIPMENT_TYPE_ZHIJIE,
		[27760] = EQUIPMENT_TYPE.EQUIPMENT_TYPE_GUAZHUI
	}
	return stuff_list[stuff_id] or 1
end

function MojieData:GetGuazhuiType(index)
	local stuff_list = {
		[8] = EQUIPMENT_TYPE.EQUIPMENT_TYPE_ZHIJIE,
		[10] = EQUIPMENT_TYPE.EQUIPMENT_TYPE_GUAZHUI
	}
	return stuff_list[index] or 1
end

--戒指挂坠最大配置
function MojieData:GetGuazhuiMaxCfg(index)
	local cfg = self:GetGouyuCfg()
	if cfg then
		if EQUIPMENT_TYPE.EQUIPMENT_TYPE_ZHIJIE == index then
			return cfg.jiezhi_level[#cfg.jiezhi_level]
		else
			return cfg.guazhui_level[#cfg.guazhui_level]
		end
	end
end

function MojieData:GetAttrRate(num)
	return (string.format("%0.4f", (num * 0.0001)) * 10000 / 100) .. " %"
end

function MojieData:GetGouyuTypeName(types, level)
	if types == 0 then
		return self:GetGouyuShowCfg(level).gouyu_open
	else
		return self:GetGuazhuiLevelCfg(types, level).name
	end
end

function MojieData:GetMojieItemList(types)
	for k,v in pairs(self.mojieconfig_auto.level) do
		if v.mojie_type == types then
			return v.up_level_stuff_id
		end
	end
end

function MojieData:GetMojieStuffTypes(stuff_id)
	for k,v in pairs(self.mojieconfig_auto.level) do
		if v.up_level_stuff_id == stuff_id then
			return v.mojie_type + 1 or 1
		end
	end
end

function MojieData:SetMojieGiftBagIndex(bag_index)
	self.mojie_gift_bag_index = bag_index
end

function MojieData:GetMojieGiftBagIndex()
	return self.mojie_gift_bag_index
end

function MojieData:SetMojieGiftId(item_id)
	self.mojie_gift_id = item_id
end

function MojieData:GetMojieGiftId()
	return self.mojie_gift_id
end