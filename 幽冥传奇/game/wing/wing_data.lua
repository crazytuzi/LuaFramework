
WingData = WingData or BaseClass()

WingData.ShowStarLevel = 8

WingData.WING_UPGRADE		 = "wing_upgrade"
WingData.WING_ATTR_CHANGE 	 = "wing_attr_change"
WingData.WING_FEATHER_CHANGE = "wing_feather_change"
WingData.WING_EXP_CHANGE	 = "wing_exp_change"
WingData.SHENYU_DATA_CHANGE	 = "shenyu_data_change"

WingData.job = {
		[1] = {require("scripts/config/server/config/swing/JobLevelCfg/SwingJob1LevelCfg")},
		[2] = {require("scripts/config/server/config/swing/JobLevelCfg/SwingJob2LevelCfg")},
		[3] = {require("scripts/config/server/config/swing/JobLevelCfg/SwingJob3LevelCfg")},
}

function WingData:__init()
	if WingData.Instance then
		ErrorLog("[WingData] Attemp to create a singleton twice !")
	end
	WingData.Instance = self
	self.wing_config = {}
	self.wing_level_config = SwingLevelConfig
	self.equipment_num = 0	
	self.ronghun_data_list = {}
	self.cl_item = {}
	self.cl_need_num = 0
	self.hc_item_id = 0
	self.skill = {}
	self.equip_info = {}
	self.wing_equip = {}
	--翅膀等级
	self.wing_level = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SWING_LEVEL)
	--翅膀经验
	self.wing_exp = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SWING_EXP)
	--羽毛
	self.feather_counts = 0
	--配置列表
	self.job_list = {
		[1] = {require("scripts/config/server/config/swing/JobLevelCfg/SwingJob1LevelCfg")},
		[2] = {require("scripts/config/server/config/swing/JobLevelCfg/SwingJob2LevelCfg")},
		[3] = {require("scripts/config/server/config/swing/JobLevelCfg/SwingJob3LevelCfg")},
	}

	self.equip_data = {326, 327, 328, 329, 330, 331, 332, 333, 334, 335, 336, 337}
	self.wing_suit_level_data = {}
	self.wing_suit_level = nil

	RoleData.Instance:AddEventListener(RoleData.ROLE_ATTR_CHANGE, BindTool.Bind(self.WingDataChange, self))
	EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.BagDataChange, self))--监听背包变化
	GameObject.Extend(self):AddComponent(EventProtocol):ExportMethods()

	self.wing_equ_data = {}
	self.equ_data = {}
end

function WingData:__delete()
	WingData.Instance = nil
end
function WingData:BagDataChange()
	self:ChangeAboutFeatherData()
	RemindManager.Instance:DoRemindDelayTime(RemindName.ShenYu)
	self:DispatchEvent(WingData.SHENYU_DATA_CHANGE)
end

function WingData:WingDataChange()
	self:ChangeAboutFeatherData()
	if self.old_wing_level ~= nil and self.old_wing_level ~= RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SWING_LEVEL) then
		self:ChangeAboutLevelData()
	end
	if self.wing_exp ~= nil and self.wing_exp ~= RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SWING_EXP) then
		self:ChangeAboutExpData()
	end
end

--返回拥有羽毛数量和需要羽毛数量
function WingData:ChangeAboutFeatherData()
	self.feather_counts = BagData.Instance:GetItemNumInBagById(self.wing_level_config.featherItemId)
	local role_gold = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_GOLD)
	local has_count, need_count = 0 ,0
	has_count = self.feather_counts
	need_count = self:GetNeedFeather()
	self:DispatchEvent(WingData.WING_FEATHER_CHANGE, {has_count = has_count, need_count = need_count})
	RemindManager.Instance:DoRemindDelayTime(RemindName.WingUpgrade)
	return {has_count = has_count, need_count = need_count}
end

--更改经验变化
function WingData:ChangeAboutExpData()
	self.wing_exp = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SWING_EXP)
	local startLv_cfg, per,per_text,isShowStar,eightLevelRemind, nextUp_consumeBlessings = nil, nil, nil, 0, false, 0

	local wing_cfg, grade, wind_id = self:GetWingcfgAndGard()

	for k,v in pairs(self.wing_config) do
		if k == self.wing_level+1 then
			nextUp_consumeBlessings = v.consumeBlessings
		end
	end

	if wing_cfg then 
		per = math.min(self.wing_exp / nextUp_consumeBlessings * 100, 100)
		per_text = grade < WingData.ShowStarLevel and self.wing_exp .. "/" ..  nextUp_consumeBlessings or ""
	end

	if self.wing_level >= WingData.ShowStarLevel then
		isShowStar = (self.wing_level - WingData.ShowStarLevel) % 10
	end

	if grade ~= nil and  self.old_wind_exp ~= nil and self.old_wind_exp ~= self.wing_exp then
		local change_val = self.wing_exp - self.old_wind_exp
		if change_val < 0 and self.old_wind_Exp == WingData.ShowStarLevel - 1 and grade == WingData.ShowStarLevel - 1 then	-- 8阶提醒
			eightLevelRemind = true
		end
	end
	self:SetShowStarNum(grade)
	local vo = {wing_cfg = wing_cfg, per =per,  per_text = per_text, isShowStar = isShowStar,eightLevelRemind = eightLevelRemind, wind_star = self.wing_exp, wind_id = wind_id}
	--派发翅膀经验改变消息
	self:DispatchEvent(WingData.WING_EXP_CHANGE, vo)
	self.old_wind_Exp = self.wing_exp
	return vo
end

--更新等级变化数据
function WingData:ChangeAboutLevelData()
	self.wing_level = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SWING_LEVEL)

	--需要传递的参数  isUp,appearanceID,garde,wing_item_cfg
	local isUp,appearanceID,wing_item_cfg = nil,nil,nil

	local wing_cfg, grade, wind_id = self:GetWingcfgAndGard()

	--判断是激活还是升级
	isUp, isActive = self:JudgeActiveOrUp(wind_id)

	if wing_cfg then 
		--获取翅膀显示外观
		appearanceID = wing_cfg.appearanceId
		--获取翅膀名字
		wing_item_cfg = wing_cfg.name
	end
	--获取属性相关配置
	attr_data = self:ChangeAboutAttrData(self.wing_level)

	--计算当前翅膀的等阶
	local level_jie = self:GetWingJie()

	--派发翅膀升级消息
	self:DispatchEvent(WingData.WING_UPGRADE, {isUp = isUp,isActive = isActive,appearanceID = appearanceID,level_jie = level_jie,wing_item_cfg = wing_item_cfg,wing_exp = self.wing_exp, attr_data = attr_data})
	--刷新经验相关
	self:ChangeAboutExpData()

	self.old_wing_level = self.wing_level
	self.old_wind_id = wind_id
	return {isUp = isUp, isActive = isActive ,appearanceID = appearanceID,level_jie = level_jie,wing_item_cfg = wing_item_cfg,wing_exp = self.wing_exp, attr_data = attr_data}
end

--计算当前翅膀的等阶
function WingData:GetWingJie(level)
	local level_jie = 0
	local grade = level or RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SWING_LEVEL)
	if grade < 8 then 
		level_jie = grade
	else
		level_jie = self.wing_config[grade].rankNum
	end
	return level_jie
end

-- 计算传过来的等级对应的阶数和星数
function WingData.GetWingLevelAndGrade(value)
	if value < 8 then return value, 0 end
	local level = 0
	local grade = 0
	level = ((value - 8) - ((value - 8) % 10)) / 10 + 8
	grade = (value - 8) % 10

	return level, grade
end

--当前属性和下一级属性
function WingData:ChangeAboutAttrData(grade)
	local cur_attr_cfg = grade >= self.ShowStarLevel and self:GetWingAttrData(grade) or self:GetWingAttrData(grade)
	local next_grade= grade
	next_grade = grade+1
	
	local nwxt_attr_cfg = self:GetWingAttrData(next_grade) 

	--需要派发的数据 cur_attr_data next_attr_data
	local cur_attr_data, next_attr_data = nil, nil

	if cur_attr_cfg then
		cur_attr_data = RoleData.FormatRoleAttrStr(cur_attr_cfg)
	end
	if nwxt_attr_cfg then
		next_attr_data = RoleData.FormatRoleAttrStr(nwxt_attr_cfg)
	end

	return {cur_attr_data = cur_attr_data, next_attr_data = next_attr_data}
end

function WingData:SetShowStarNum(grade)
	self.show_star_num = grade >= self.ShowStarLevel
end
function WingData:IsShowStar()
	return self.show_star_num
end

--判断是升级还是激活
function WingData:JudgeActiveOrUp(wind_id)
	if self.old_wind_id ~= nil and wind_id == 1 then
		isActive = true
		isUp = false
	elseif self.old_wing_level ~= nil and self.old_wing_level + 1 == wind_id then
		isUp = true
		isActive = false
	else
		isUp = false
		isActive = false
	end
	function GetActiveOrUp()
		return isUp, isActive
	end
	return GetActiveOrUp()
end

--获取背包中精羽的数量
function WingData:SetFeatherNums()
	self.feather_counts = BagData.Instance:GetItem(self.wing_level_config.featherItemId)
end
--获取当前拥有的精羽
function WingData:GetFeatherNums()
	return self.feather_counts
end

function WingData:GetWingConfig()
	return self.wing_config
end

function WingData:GetWingUpgrade()
	return self:ChangeAboutLevelData()
end

function WingData:GetExpChangeData()
	return self:ChangeAboutExpData()
end


function WingData:GetWingcfgAndGard()
	local wind_id = self.wing_level
	local wing_cfg, gard = self:GetWingCfg()
	return  wing_cfg, gard, wind_id
end

function WingData:GetWingUpdateTip()
	local  wing_cfg, gard, wind_id = self:GetWingcfgAndGard()
	if gard >= WingData.ShowStarLevel then
		return Language.Wing.WingUpdateTip8_15 
	else
		return Language.Wing.WingUpdateTip1_7
	end
	
end

function WingData:GetWingLevel()
	return self.wing_level
end

function WingData:GetWingStar()
	return RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SWING_EXP)
end

function WingData:GetWingAttrData(grade)
	for k,v in pairs(self.wing_config) do
		if k == grade then
			return v.attr
		end
	end
end

function WingData.GetWingAttrCfg(grade, star)
	for k,v in pairs(SwingAttrsConfig) do
		if k == grade then
			for k1,v1 in pairs(v) do
				if k1 == star then
					return v1
				end
			end
		end
	end
end

function WingData:GetWingCfg()
	local index = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)

	self.wing_config = self.job_list[index][1][1]
	for k,v in pairs(self.wing_config) do
		if v.appearanceId == self:GetWingJie() then
			return v, k
		end
	end
	return nil, 0
end

function WingData:GetNeedFeather()
	for k,v in pairs(self.wing_config) do
		if k == self.wing_level + 1 then
			return v.featherCount
		end
	end
	return 0
end

function WingData.GetWingUpLevelCfg(wing_id)
	for k,v in pairs(SwingEquipConfig.SwingEquipTable) do
		if v.appearance == wing_id then
			return v, k
		end
	end
	return nil, 0
end

function WingData.GetWingStoneMaxCount(stone_id)
	local cfg = WingData.GetWingUpLevelCfg(RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SWING_ID))
	if cfg then
		for k,v in pairs(SwingEquipConfig.stones) do
			if stone_id == v then
				return cfg.maxStones[k] or 0
			end
		end
	end
	return 0
end

function WingData:GetWingScore()
	local wind_id = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SWING_LEVEL)
	local attr_cfg = {}
	if wind_id ~= 0 then
		attr_cfg = self.wing_config[wind_id].attr
	end
	return CommonDataManager.GetAttrSetScore(attr_cfg or {})
end

function WingData.GetWingMaxLevel()
	return #SwingEquipConfig.SwingEquipTable
end

function WingData:GetWingShowArray()
	local wing_show_cfg = {}
	for k, v in pairs(self.wing_config) do
		table.insert( wing_show_cfg, v.appearanceId)
	end
	local show_cfg = self:DeleteSameElementFormTable(wing_show_cfg)
	return show_cfg;
end

function WingData:GetWingNameArray()
	local name_cfg = {}
	local name_index = 1
	for k, v in pairs(self.wing_config) do
		if name_index == v.appearanceId then
			table.insert( name_cfg, v.name)
			name_index = name_index + 1
		end
	end
	return name_cfg
end

function WingData:SetSkillIdAndLevel(index)
	local wing_cfg = self.wing_config
	local skill_id = 0
	local skill_level = 0
	if index == 1 then
		skill_id =  wing_cfg[4].skillid
		skill_level =  wing_cfg[4].skilllv
	elseif index == 2 then
		skill_id =  wing_cfg[6].skillid
		skill_level =  wing_cfg[6].skilllv
	elseif index == 3 then
		skill_id =  wing_cfg[8].skillid
		skill_level =  wing_cfg[8].skilllv
	else
		local i = index * 20 - 52
		skill_id =  wing_cfg[i].skillid
		skill_level =  wing_cfg[i].skilllv
	end
	self.skill = {id = skill_id, level = skill_level}
end

function WingData:GetSkillIdAndLevel()
	return self.skill
end

function WingData:GetAdvStuffWayConfig()
	return {
		string.format(Language.Equipment.CommonTips, SwingLevelConfig.featherItemId) ..
		string.format(Language.Equipment.OpenVew, ViewName.FubenCL, nil, Language.Wing.FeatherFuben),
	}
end

--去除简单表中相同的元素
function WingData:DeleteSameElementFormTable(source_table)
    -- 保存转换后的结果
    local results_table = {}
    --去除表中的相同项
    local temp = {}
    for key,val in pairs(source_table) do
        temp[val]=true --在lua中key不允许有重复，因此形成的新数组，就能够实现去重复元素了。
    end
    --将key插入到新的table，构成最终的结果
    for key,val in pairs(temp) do
       table.insert(results_table,key)                
    end
    --对数组进行重排序
    table.sort(results_table)

    return results_table
end

-----------------神翼合成预览数据-------------------------------
-- 神翼背包显示
function WingData:WingBagItem()
	local bag_list = {}
	local function sort(a, b)
		if a.item_id ~= b.item_id then
			return a.item_id > b.item_id
		else
			return a.is_bind < b.is_bind
		end
	end

	local cfg_list = {}
	for i,v in ipairs(SwingLevelConfig.WingItemid or {}) do
		cfg_list[v] = true
	end

	local item_type = ItemData.ItemType.itItemEquivalence
	local bag_item_list = BagData.Instance:GetBagItemDataListByType(item_type)
	for k,v in pairs(bag_item_list) do
		if cfg_list[v.item_id] then
			table.insert(bag_list, v)
		end
	end

	local item_type = ItemData.ItemType.itWingEquip
	local bag_item_list = BagData.Instance:GetBagItemDataListByType(item_type)
	for k,v in pairs(bag_item_list) do
		table.insert(bag_list, v)
	end

	table.sort(bag_list, sort)
	bag_list[0] = table.remove(bag_list, 1)

	return bag_list
end

function WingData:SetWingCompoundData(item)
	self:GetCompoundNeedNum(item)
end

function WingData:GetCompoundNeedNum(item)
	local item_id = item.item_id
	local index = WingData.Instance:GetCompodunIndex(item_id)
	if index ~= 0 then
		local can_compound = false
		local cfg_list = ItemSynthesisConfig and ItemSynthesisConfig[1] and ItemSynthesisConfig[1].list or {}
		local cur_cfg = cfg_list[index] or {}
		local item_list = cur_cfg.itemList or {}
		for k, v in pairs(item_list) do
			if v.consume[1].id == item_id then
				-- self.cl_need_num = v.consume[1].count
				-- self.hc_item_id = v.award[1].id
				self.cur_compose_cfg = v
				self.compose_index = k
				can_compound = true
			end
		end

		if can_compound then
			self.cl_item = item
		else
			SysMsgCtrl.Instance:FloatingTopRightText("投入的装备已是最高阶")
		end
	end
end

-- 获取材料的数据和数量
function WingData:GetClData()
	return self.cl_item
end

-- 获取材料所需数量和合成物品
function WingData:GetHcData()
	return self.compose_index, self.cur_compose_cfg or {}
end

-- 获取神翼合成
function WingData:GetCompodunIndex(item_id)
	for k, v in pairs(SwingLevelConfig.WingItemid) do
		if v == item_id then
			return k
		end
	end

	local item_cfg = ItemData.Instance:GetItemConfig(item_id)
	if item_cfg.type == ItemData.ItemType.itWingEquip then
		return item_cfg.stype + 1
	end

	return 0
end

-- 影翼的数据
function WingData:SetEquipInfoData(protocol)
	self.equip_info = protocol.equip_list
	local function sort(a, b)
		if a.index ~= b.index then
			return a.index < b.index
		end
	end

	for i = 1, 12 do
		local vo = {}
		vo.item_id = self.equip_data[i]
		vo.index = i
		vo.cfg = self:GetEquipIsHhOrBag(self.equip_data[i]) and ItemData.Instance:GetItemConfig(self.equip_data[i]) or nil
		vo.is_hh = protocol.equip_index
		table.insert(self.wing_equ_data, vo)
	end

	for i, item in pairs(self.equip_info) do
		local item_cfg = ItemData.Instance:GetItemConfig(item.item_id)
		local slot_index = item_cfg.stype + 1
		if self.wing_equ_data[slot_index] then
			self.wing_equ_data[slot_index].cfg = item
		end
	end
	
	table.sort(self.wing_equ_data, sort)
end

-- 影翼装备是否开放
function WingData:GetWingIsOpen()
	local open_cond = "CondId83"
	return GameCondMgr.Instance:GetValue(open_cond)
end

-- 影翼装备是否开放
function WingData.GetNewWingIsOpen()
	local role_level = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
	local role_circle = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)
	local open_days = OtherData.Instance:GetOpenServerDays()
	local wing_lv = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SWING_LEVEL)
	
	local cfg = SwingLevelConfig.equipOpenLimit
	local is_open = role_level >= cfg.level and role_circle >= cfg.circle and open_days >= cfg.serverday and wing_lv >= cfg.swingLv

	return is_open
end

-- 翅膀装备数据
function WingData:SetNewWingEquipData(protocol)
	self.wing_equip = protocol

	for i = 1, 4 do
		local vo = {}
		vo.index = 11+i
		vo.item_id = self:GetWingData(i)
		vo.cfg = self:GetWingData(i) and ItemData.Instance:GetItemConfig(self:GetWingData(i)) or nil

		table.insert(self.equ_data, vo)
	end
end

function WingData:GetWingData(index)
	local data = self.wing_equip
	local id 
	for k, v in pairs(data) do
		local cfg = ItemData.Instance:GetItemConfig(v.item_id)
		if cfg.stype and (cfg.stype - 11) == index then
			id =  v.item_id
		end
	end
	return id
end

-- 下发数据的时候判断是否装备
function WingData:IsWEquip(data)
	local is_equ
	for k, v in pairs(data) do
		local cfg = ItemData.Instance:GetItemConfig(v.item_id)
		if cfg.stype then
			is_equ = true
		end
	end
	return is_equ
end

-- 获取是影翼还是装备
function WingData:IsWingOrEquip(item_id)
	-- for k, v in pairs(self.equip_data) do
	-- 	if id == v then
	-- 		is_wing = true
	-- 	end
	-- end
	local cfg = ItemData.Instance:GetItemConfig(item_id)
	local is_wing = cfg.type == ItemData.ItemType.itWingEquip

	return is_wing
end

-- 背包是否有神翼装备可以装备
function WingData:IsHaveWingEquipOnBag(id)
	if BagData.Instance:GetItemNumInBagById(id) >= 1 then
		return 1
	end

	return 0
end

function WingData:SetAddWingment(list)
	local index = self:GetWingIndex(list.item_id)
	if self.wing_equ_data[index+1] then
		self.wing_equ_data[index+1].cfg = list
	elseif self.equ_data[index-11] then
		self.equ_data[index-11].cfg = list
		self.wing_suit_level_data = {}
		self.wing_suit_level = nil
	end
end

function WingData:GetTakeOffIndex(index)
	if self.wing_equ_data[index+1] then
		self.wing_equ_data[index+1].cfg = nil
	elseif self.equ_data[index-11] then
		self.equ_data[index-11].cfg = nil
		self.wing_suit_level_data = {}
		self.wing_suit_level = nil
	end
end

function WingData:GetWingEquipByIndex(index)
	local equip = nil
	if self.wing_equ_data[index+1] then
		equip = self.wing_equ_data[index+1].cfg
	elseif self.equ_data[index-11] then
		equip = self.equ_data[index-11].cfg
	end
	
	return equip
end

function WingData:GerEquipDataByIndex(index)
	return self.equ_data[index]
end

function WingData:SetDieResult(protocol)
	for i = 1, 12 do
		self.wing_equ_data[i].is_hh = protocol.up_equip_index
	end
end

function WingData:GetNewEquipData()
	return self.equ_data
end

function WingData:GetWingEquipData()
	local equ_data = {}
	local num = 6
	if self:GetWingIsOpen() then
		num = 12
	end

	for k, v in pairs(self.wing_equ_data) do
		if k <= num then
			table.insert(equ_data, v)
		end
	end
	
	return equ_data
end

-- 展示
function WingData:GetWingPreShow()
	local equ_data = {}
	local num = 6
	if self:GetWingIsOpen() then
		num = 12
	end

	for i = 1, num do
		local data = ItemData.Instance:GetItemConfig(self.equip_data[i])
		table.insert(equ_data, data)
	end
	return equ_data
end

function WingData:GetEquipIsHhOrBag(id)
	local data = self.equip_info
	for k, v in pairs(data) do
		if v.item_id == id then
			return true
		end
	end
	return false
end

-- 获取装备的index
function WingData:GetWingIndex(id)
	local cfg = ItemData.Instance:GetItemConfig(id)

	return cfg.stype
end

-- 获取影翼的槽位
function WingData:IsWingEquip(id)
	local index = 0
	for k, v in pairs(self.wing_equ_data) do
		if v.cfg and v.cfg.item_id and v.cfg.item_id == id then
			index = k
		end
	end
	return index
end

-- 获取影翼的套装等级Data
function WingData:GetWingSuitLevelData()
	local suit_config = SuitPlusConfig and SuitPlusConfig[15] or {}
	for k, v in ipairs(suit_config.list or {}) do
		self.wing_suit_level_data[v.suitId] = {bool = 0, count = 0, need_count = v.count}
		local bool_data,num = self:GetSuitDataCommon(v.suitId, v.count, self.equ_data, suit_config.calctype)
		self.wing_suit_level_data[v.suitId].bool = bool_data
		self.wing_suit_level_data[v.suitId].count = num
		if bool_data > 0 then
			self.wing_suit_level = v.suitId
		end
	end

	return self.wing_suit_level_data, self.wing_suit_level or 0
end

function WingData:GetSuitDataCommon(suitId, count, list, calctype)
	local bool_data = 0
	local num = 0

	for k, v in pairs(list) do
		local item_id = v.cfg and v.cfg.item_id or 0
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

function WingData:GetTextByTypeData(suittype, suitlevel, config, is_not_show_jichu)
	local suit_level_data = self:GetWingSuitLevelData()
	local cur_suit_level_data = suit_level_data[suitlevel] or suit_level_data[1] or {}
	local text1 = ""
	if suitlevel <= 0 then
		text1 =  string.format("{color;f4ff00;%s}",string.format(Language.HaoZhuang.desc1, 1, "翅膀套装", cur_suit_level_data.count or 0, cur_suit_level_data.need_count or 12, Language.HaoZhuang.active[1])).."\n"
	else
		local text6 = cur_suit_level_data.bool > 0 and Language.HaoZhuang.active[2] or Language.HaoZhuang.active[1]
		text1 = string.format("{color;f4ff00;%s}",string.format(Language.HaoZhuang.desc1, suitlevel, "翅膀套装", cur_suit_level_data.count or 0, cur_suit_level_data.need_count or 12,text6)).."\n"
	end

	local text2 = "" 
	local text21 = ""
	local type_data = {1, 2, 3, 4}
	for i, slot in ipairs(type_data) do
		local name = Language.Wing.WingEquipName[slot]
		local equip = self:GerEquipDataByIndex(slot) and self:GerEquipDataByIndex(slot).cfg
		local color = "a6a6a6"
		if equip then
			local item_cfg = ItemData.Instance:GetItemConfig(equip.item_id)
		
			if item_cfg.suitId >= suitlevel then
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

-- 根据数据获得穿戴中的幻影的槽位	0为未穿戴任何幻影
function WingData.GetRonghunPhantomSlot(role_vo)
	local value = role_vo[OBJ_ATTR.ACTOR_WINGEQUIP_APPEARANCE] or 0	--前8位幻影穿戴数据
	local data = bit:_and(value, 0x000000FF)
	for i = 1, 8 do
		if bit:_rshift(data, i - 1) == 1 then
			return i
		end
	end
	return 0
end

-- 装备可穿戴红点提示
function WingData:SetUpgradeData()
	for k, v in pairs(self.wing_equ_data) do
		if v.cfg == nil then
			if self:IsHaveWingEquipOnBag(v.item_id) == 1 then
				return 1
			end
		end
	end
	return 0
end

-- 翅膀可升级红点
function WingData:WingCanUpRemind()
	local vo = self:ChangeAboutFeatherData()

	return vo.need_count ~= 0 and (vo.has_count >= vo.need_count and 1 or 0) or 0
end

-- 装备幻化槽位
function WingData:GetWingHhIndex(item_id)
	for k, v in pairs(self.wing_equ_data) do
		if item_id == v.item_id then
			if v.is_hh + 1 == v.index then
				return v.is_hh
			end
		end
	end
	return nil
end