FamousGeneralData = FamousGeneralData or BaseClass()

local SKILL_TYPE =
{
	FIRST_SKILL = 1,
	SECOND_SKILL = 2,
	THIRD_SKILL = 3,
	PASSIVE_SKILL = 4,
}
local DEF_COLOR = 5

function FamousGeneralData:__init()
	FamousGeneralData.Instance = self
	self.skill_cfg = ConfigManager.Instance:GetAutoConfig("greate_soldier_config_auto").skill
	self.passive_skill_cfg = ConfigManager.Instance:GetAutoConfig("greate_soldier_config_auto").passive_skill
	local grade_cfg = ConfigManager.Instance:GetAutoConfig("greate_soldier_config_auto").grade
	self.grade_cfg = ListToMap(grade_cfg, "grade")
	local cfg = ConfigManager.Instance:GetAutoConfig("greate_soldier_config_auto").level
	self.level_cfg = ListToMap(cfg, "color", "level")
	self.other_cfg = ConfigManager.Instance:GetAutoConfig("greate_soldier_config_auto").other[1]

	self.guangwu_item_id = self.other_cfg.guangwu_shuxingdan
	self.fazhen_item_id = self.other_cfg.fazhen_shuxingdan
	self.max_grade = grade_cfg[#grade_cfg].grade
	self.max_potential_level = cfg[#cfg].level

	self.guangwu_type = SHUXINGDAN_TYPE.SHUXINGDAN_TYPE_GUANGWU
	self.fazhen_type = SHUXINGDAN_TYPE.SHUXINGDAN_TYPE_FAZHEN
	self.general_data_list = {}
	self:InitGeneralList()
	RemindManager.Instance:Register(RemindName.General_Info, BindTool.Bind(self.GetInfoRed, self))
	RemindManager.Instance:Register(RemindName.General_Potential, BindTool.Bind(self.GetPotentialRed, self))
end

function FamousGeneralData:__delete()
	FamousGeneralData.Instance = nil
	RemindManager.Instance:UnRegister(RemindName.General_Info)
	RemindManager.Instance:UnRegister(RemindName.General_Potential)
end

-------------------------------初始化数据---------------------------------
function FamousGeneralData:InitGeneralData(value)
	local general_data = {}
	general_data.name = value.name
	general_data.introduce = value.synopsis
	general_data.color = value.color
	general_data.item_id = value.item_id
	general_data.seq = value.seq
	general_data.model_res_id = value.image_id

	general_data.skill_list = {}
	for i=1,3 do
		general_data.skill_list[i] = self.skill_cfg[i].skill_id
	end
	general_data.skill_list[SKILL_TYPE.PASSIVE_SKILL] = self.passive_skill_cfg[value.active_passive_skill_seq + 1].icon_id

	local skill_cfg = {}
	skill_cfg[1] = SkillData.GetSkillinfoConfig(self.skill_cfg[1].skill_id)
	skill_cfg[2] = SkillData.GetSkillinfoConfig(self.skill_cfg[2].skill_id)
	skill_cfg[3] = SkillData.GetSkillinfoConfig(self.skill_cfg[3].skill_id)

	general_data.skill_name = {}
	for i=1,3 do
		general_data.skill_name[i] = skill_cfg[i].skill_name
	end
	general_data.skill_name[SKILL_TYPE.PASSIVE_SKILL] = self.passive_skill_cfg[value.active_passive_skill_seq + 1].skill_name

	general_data.skill_introduce = {}
	for i=1,3 do
		general_data.skill_introduce[i] = skill_cfg[i].skill_desc
	end
	general_data.skill_introduce[SKILL_TYPE.PASSIVE_SKILL] = self.passive_skill_cfg[value.active_passive_skill_seq + 1].skill_tips

	general_data.attr = {}
	-- local cfg = self.grade_cfg[value.color]
	general_data.attr[1] =  value.maxhp or 0
	general_data.attr[2] =  value.gongji or 0
	general_data.attr[3] =  value.fangyu or 0

	general_data.base_attr = {}
	for k,v in pairs(general_data.attr) do
		general_data.base_attr[k] = v
	end

	general_data.potential_level = 0
	general_data.potential_attr = {}
	general_data.potential_attr[1] = self.level_cfg[value.color][general_data.potential_level].maxhp
	general_data.potential_attr[2] = self.level_cfg[value.color][general_data.potential_level].gongji
	general_data.potential_attr[3] = self.level_cfg[value.color][general_data.potential_level].fangyu

	general_data.potential_item_id = self.level_cfg[value.color][general_data.potential_level].item_id
	general_data.potential_need_blessing = self.level_cfg[value.color][general_data.potential_level].need_exp
	general_data.potential_need_num = self.level_cfg[value.color][general_data.potential_level].item_num

	general_data.active_guangwu_level = value.active_guangwu_level
	general_data.active_fazhen_level = value.active_fazhen_level

	general_data.potential_blessing = 0
	general_data.level = 0
	general_data.is_active = false
	general_data.guangwu_level = 0
	general_data.fazhen_level = 0

	general_data.get_msg = value.get_msg
	general_data.open_panel = value.open_panel
	return general_data
end

-- 初始化武将列表 也是所有数据的起点 如果进行屏蔽 应该在这里进行屏蔽
function FamousGeneralData:InitGeneralList()
	self.general_list = ConfigManager.Instance:GetAutoConfig("greate_soldier_config_auto").greate_soldier
	self.list_num = #self.general_list
	for k,v in ipairs(self.general_list) do
		local general_data = self:InitGeneralData(v)
	    -- 记录数据在原表中的位置，这个位置永远不变
		general_data.sort_index = k
		table.insert(self.general_data_list, general_data)
	end
	self.sort_general_list = TableCopy(self.general_data_list)
end

--------------------------------存储数据------------------------------------------------
-- 设置单个名将的信息(当请求所有时，会一个个发过来)
function FamousGeneralData:SetGreateSoldierItemInfo(protocol)
	-- 如果下一条数据为空的话
	if  self.general_data_list[protocol.seq + 1] == nil then
		return
	end
	
	local data = self.general_data_list[protocol.seq + 1]
	local delay_flush_model = false

	-- 如果没有出战且有可出战的，即可出战
	if GeneralSkillData.Instance:GetMainSlot() == -1 and protocol.item_info.grade == 1 and self.general_data_list[protocol.seq + 1].level == 0 then
		FamousGeneralCtrl.Instance:SendRequest(GREATE_SOLDIER_REQ_TYPE.GREATE_SOLDIER_REQ_TYPE_MAIN_SLOT, protocol.seq)
	end

	-- 如果光武等级升到了开启光武的等级
	if protocol.item_info.guangwu == data.active_guangwu_level and data.guangwu_level + 1 == data.active_guangwu_level then
		delay_flush_model = true
	end

	-- 如果法阵等级升到了开启法阵的等级
	if protocol.item_info.shenwu == data.active_fazhen_level and data.fazhen_level + 1 == data.active_fazhen_level then
		delay_flush_model = true
	end

	-- 如果升级成功
	if self.init then
		if protocol.item_info.level > data.potential_level then
			FamousGeneralCtrl.Instance:FlushView("potential_view", "uplevel")
			FamousGeneralCtrl.Instance:ShowPotentialEffect()
		elseif protocol.item_info.cur_level_exp > data.potential_blessing then
			FamousGeneralCtrl.Instance:FlushView("potential_view", "on_uplevel")
		end
	end

	if self.init then
		if protocol.item_info.grade > data.level then
			FamousGeneralCtrl.Instance:ShowInfoEffect()
		end
		if protocol.item_info.guangwu > data.guangwu_level then
			FamousGeneralCtrl.Instance:ShowGuangwuEffect()
		end
		if protocol.item_info.shenwu > data.fazhen_level then
			FamousGeneralCtrl.Instance:ShowFaZhenEffect()
		end
	end

	data.level = protocol.item_info.grade
	data.potential_level = protocol.item_info.level
	data.is_active = protocol.item_info.grade > 0
	data.potential_blessing = protocol.item_info.cur_level_exp
	data.guangwu_level = protocol.item_info.guangwu
	data.fazhen_level = protocol.item_info.shenwu

	self:DisposeAttr(protocol.seq + 1)
	self:SortGeneralList()

	if delay_flush_model then
		FamousGeneralCtrl.Instance:FlushModel()
	end

	if self.general_data_list[protocol.seq + 2] == nil then
		self.init = true
	end
end

function FamousGeneralData:SetLookGuangwu()
	self.look_guangwu = true
end

function FamousGeneralData:SetLookFaZhen()
	self.look_fazhen = true
end

function FamousGeneralData:GetLookGuangwu()
	return self.look_guangwu or false
end

function FamousGeneralData:GetLookFaZhen()
	return self.look_fazhen or false
end

--------------------------------处理数据-----------------------------------------------
-- 对武将列表根据状态进行排序(过早的优化是万恶之源)
function FamousGeneralData:SortGeneralList()
	self.sort_general_list = TableCopy(self.general_data_list)
	local t = TableSortByCondition(self.sort_general_list, function (value)
		return self.general_data_list[value.sort_index].level > 0
	end)
	self.sort_general_list = t
end

function FamousGeneralData:DisposeAttr(index)
	local cfg = self:GetCfgData(index, self.general_data_list[index].level)
	local data = self.general_data_list[index]
	data.attr[1] = cfg.maxhp
	data.attr[2] = cfg.gongji
	data.attr[3] = cfg.fangyu

	local potential_cfg = self:GetPotentialCfgData(index, data.potential_level)
	data.potential_attr[1] = potential_cfg.maxhp
	data.potential_attr[2] = potential_cfg.gongji
	data.potential_attr[3] = potential_cfg.fangyu

	data.potential_need_blessing = self.level_cfg[data.color][data.potential_level].need_exp or 0
	data.potential_need_num = self.level_cfg[data.color][data.potential_level].item_num or 0
end

function FamousGeneralData:GetCfgData(index, level)
	local def_value = {gongji = 0, maxhp = 0, fangyu = 0}
	if (self.grade_cfg[level] == nil) or index == nil or self.general_data_list[index] == nil then
		return def_value
	end

	if level > 0 then
		return {maxhp = self.general_data_list[index].base_attr[1] * self.grade_cfg[level].grade_rate / 10000,
				gongji = self.general_data_list[index].base_attr[2] * self.grade_cfg[level].grade_rate / 10000,
				fangyu = self.general_data_list[index].base_attr[3] * self.grade_cfg[level].grade_rate / 10000}
	else
		return def_value
	end
end

function FamousGeneralData:GetPotentialCfgData(index, level)
	local def_value = {gongji = 0, maxhp = 0, fangyu = 0}
	if type(level) ~= "number" or index == nil or self.general_data_list[index] == nil then
		return def_value
	end
	local color = self.general_data_list[index].color
	if self.level_cfg[color][level] == nil then
		return def_value
	end
	if level >= 0 then
		return {maxhp = self.level_cfg[color][level].maxhp,
				gongji = self.level_cfg[color][level].gongji,
				fangyu =  self.level_cfg[color][level].fangyu}
	else
		return def_value
	end
end

--------------------------------------判断数据-----------------------------------------------
function FamousGeneralData:IsGeneralMaxLevel(level)
	return level == self.max_grade
end

function FamousGeneralData:IsPotentialMaxLevel(level)
	return level == self.max_potential_level
end

-- 确定标签的显示
function FamousGeneralData:IsShowTab(index)
	local flag = false
	local open_fun_data = OpenFunData.Instance
	if index == TabIndex.famous_general_info then
		flag = open_fun_data:CheckIsHide("famous_general_info")
	elseif index == TabIndex.famous_general_potential then
		flag = open_fun_data:CheckIsHide("famous_general_potential")
	elseif index == TabIndex.famous_general_wakeup then
		flag = open_fun_data:CheckIsHide("famous_general_wakeup")
	elseif index == TabIndex.famous_general_talent then
		flag = open_fun_data:CheckIsHide("famous_general_talent")
	end
	return flag
end

function FamousGeneralData:IsActiveGeneral(index)
	local def_value = false
	if self.sort_general_list[index] == nil then
		return def_value
	end
	local sort_index = self.sort_general_list[index].sort_index
	return self.general_data_list[sort_index].is_active
end

function FamousGeneralData:IsCanUpGeneral(index)
	local def_value = false
	if self.sort_general_list[index] == nil then
		return def_value
	end
	local data = self.sort_general_list[index]

	if self:IsGeneralMaxLevel(data.level) then
		return def_value
	end

	local item_id = self.sort_general_list[index].item_id
	local num = ItemData.Instance:GetItemNumInBagById(item_id)
	if num > 0 then
		return true
	end
	return def_value
end

function FamousGeneralData:IsCanUpImage()
	return self:IsCanUpFaZhenImage() or self:IsCanUpGuangwuImage()
end

function FamousGeneralData:IsCanUpFaZhenImage()
	local show_fazhen = false
	if not self.look_fazhen then
	-- 如果有法阵丹,就可以升级
	local fazhen_item_id = self.fazhen_item_id
	local fazhen_num = ItemData.Instance:GetItemNumInBagById(fazhen_item_id)
	if fazhen_num > 0 then
		show_fazhen = true
	end
	if show_fazhen then
		return true
		end
	end
	return false
end

function FamousGeneralData:IsCanUpGuangwuImage()
	local show_guangwu = false
	if not self.look_guangwu then
		-- 如果有光武丹,就可以升级
		local guangwu_item_id = self.guangwu_item_id
		local guangwu_num = ItemData.Instance:GetItemNumInBagById(guangwu_item_id)
		if guangwu_num > 0 then
			show_guangwu = true
		end
		if show_guangwu then
			return true
		end
	end
	return false
end

function FamousGeneralData:IsCanUpPotential(index)
	local def_value = false
	if self.sort_general_list[index] == nil then
		return def_value
	end
	local cur_data = self.sort_general_list[index]
	if self:IsPotentialMaxLevel(cur_data.potential_level) then
		return def_value
	end
	if not cur_data.is_active then
		return def_value
	end
	local item_id = cur_data.potential_item_id
	local num = ItemData.Instance:GetItemNumInBagById(item_id)
	if num >= cur_data.potential_need_num then
		return true
	end
	return def_value
end

function FamousGeneralData:CheckIsGeneralSkill(skill_id)
	for k,v in pairs(self.skill_cfg) do
		if v.skill_id == skill_id then
			return true
		end
	end
	return false
end

function FamousGeneralData:GetInfoRed()
	local is_show = OpenFunData.Instance:CheckIsHide("tiansheng")
	if not is_show then
		return 0
	end
	for i,v in ipairs(self.sort_general_list) do
		if self:IsCanUpGeneral(i) then
			return 1
		end
		if v.is_active and self:IsCanUpImage() then
			return 1
		end
	end
	return 0
end

function FamousGeneralData:GetPotentialRed()
	local is_show = OpenFunData.Instance:CheckIsHide("famous_general_potential")

	if not is_show then
		return 0
	end

	for i,v in ipairs(self.sort_general_list) do	
		if self:IsCanUpPotential(i) then
			return 1
		end
	end
	return 0
end

function FamousGeneralData:IsShowFaZhen(index)
	if self.sort_general_list[index] == nil then
		return false
	end
	local cur_level = self.sort_general_list[index].fazhen_level
	local active_fazhen_level = self.sort_general_list[index].active_fazhen_level
	return cur_level >= active_fazhen_level
end

function FamousGeneralData:IsShowGuangWu(index)
	if self.sort_general_list[index] == nil then
		return false
	end
	local cur_level = self.sort_general_list[index].guangwu_level
	local active_guangwu_level = self.sort_general_list[index].active_guangwu_level
	return cur_level >= active_guangwu_level
end

--------------------------------------获取数据-----------------------------------------------

-- 获取初始武将列表
function FamousGeneralData:GetGeneralList()
	return self.general_list or {}
end

-- 获取武将总数
function FamousGeneralData:GetListNum()
	return self.list_num or 0
end

-- 返回排序后的武将列表
function FamousGeneralData:GetSortGeneralList()
	return self.sort_general_list
end

-- 获取对应索引的武将的名字（排序后索引）
function FamousGeneralData:GetGeneralName(index)
	local def_value = ""
	if self.sort_general_list[index] == nil then
		return def_value
	end
	local sort_index = self.sort_general_list[index].sort_index
	return self.general_data_list[sort_index].name
end

-- 获取对应索引的武将的介绍（排序后索引）
function FamousGeneralData:GetIntroduce(index)
	local def_value = ""
	if self.sort_general_list[index] == nil then
		return def_value
	end
	local sort_index = self.sort_general_list[index].sort_index
	local cur_data = self.general_data_list[sort_index]
	return cur_data and cur_data.introduce or def_value
end

-- 获取对应索引的武将的等级（排序后索引）
function FamousGeneralData:GetLevel(index)
	local def_value = 0
	if self.sort_general_list[index] == nil then
		return 0
	end
	local sort_index = self.sort_general_list[index].sort_index
	local cur_data = self.general_data_list[sort_index]
	return cur_data and cur_data.level or def_value
end

-- 获取对应索引的武将的属性（排序后索引）
function FamousGeneralData:GetAttr(index, type)
	local def_value = 0
	if self.sort_general_list[index] == nil then
		return def_value
	end
	local sort_index = self.sort_general_list[index].sort_index
	local cur_data = self.general_data_list[sort_index]
	return cur_data and cur_data.attr[type] or def_value
end

function FamousGeneralData:GetNextAttr(index, types)
	local def_value = 0
	if self.sort_general_list[index] == nil or GameEnum.AttrList[types] == nil then
		return def_value
	end
	local sort_index = self.sort_general_list[index].sort_index
	local cur_data = self.general_data_list[sort_index]
	local level = cur_data.level
	if cur_data.level == 0 then
		level = 1
	end
	local next_attr = self:GetCfgData(sort_index, level + 1)
	local cur_attr = self:GetCfgData(sort_index, level)
	return next_attr and next_attr[GameEnum.AttrList[types]] - cur_attr[GameEnum.AttrList[types]] or def_value
end

-- 获取对应索引的武将的技能（排序后索引）
function FamousGeneralData:GetSkillIcon(index, type)
	local def_value = 0
	if self.sort_general_list[index] == nil then
		return def_value
	end
	local sort_index = self.sort_general_list[index].sort_index
	local cur_data = self.general_data_list[sort_index]
	return cur_data and cur_data.skill_list[type] or def_value
end

-- 获取对应seq的技能列表
function FamousGeneralData:GetSkillIconBySeq(seq, types)
	local def_value = 0
	if seq == nil or types == nil then
		return def_value
	end
	local cur_data = self.general_data_list[seq + 1]
	return cur_data and cur_data.skill_list[types] or def_value
end

-- 获取对应索引的武将的技能名（排序后索引）
function FamousGeneralData:GetSkillName(index, type)
	local def_value = ""
	if self.sort_general_list[index] == nil then
		return def_value
	end
	local sort_index = self.sort_general_list[index].sort_index
	local cur_data = self.general_data_list[sort_index]
	return cur_data and cur_data.skill_name[type] or def_value
end

-- 获取对应索引的武将的模型（排序后索引）
function FamousGeneralData:GetGeneralModel(index)
	local def_value = 0
	if self.sort_general_list[index] == nil then
		return def_value
	end
	local sort_index = self.sort_general_list[index].sort_index
	local cur_data = self.general_data_list[sort_index]
	return cur_data and self.general_data_list[sort_index].model_res_id or def_value
end

-- 根据模型获取索引
function FamousGeneralData:GetSeqByImageId(image_id)
	if image_id == nil then
		return 0
	end
	for k,v in pairs( self.general_data_list) do
		if v.model_res_id == image_id then
			return v.seq
		end
	end
	return 0
end

function FamousGeneralData:GetPotentialAttr(index, types)
	local def_value = 0
	if self.sort_general_list[index] == nil or GameEnum.AttrList[types] == nil then
		return def_value
	end
	local cur_data = self.sort_general_list[index].potential_attr[types]
	return cur_data
end

function FamousGeneralData:GetPotentialNextAttr(index, types)
	local def_value = 0
	if self.sort_general_list[index] == nil or GameEnum.AttrList[types] == nil then
		return def_value
	end
	local sort_index = self.sort_general_list[index].sort_index
	local cur_data = self.general_data_list[sort_index]
	local level = cur_data.potential_level
	if cur_data.level == 0 then
		level = 1
	end
	local next_attr = self:GetPotentialCfgData(sort_index, level + 1)
	local cur_data = self.sort_general_list[index].potential_attr[types]
	return next_attr and next_attr[GameEnum.AttrList[types]] - cur_data or def_value
end

function FamousGeneralData:GetPotentialLevel(index)
	local def_value = 0
	if self.sort_general_list[index] == nil then
		return def_value
	end
	local cur_data = self.sort_general_list[index].potential_level
	return cur_data
end

function FamousGeneralData:GetNextPotentialLevel(index)
	local def_value = 0
	if self.sort_general_list[index] == nil then
		return def_value
	end
	local cur_data = self.sort_general_list[index].potential_level + 1
	if self:IsPotentialMaxLevel(cur_data - 1) then
		return def_value
	end
	return cur_data
end

function FamousGeneralData:GetBlessingNum(index)
	local def_value = 0
	if self.sort_general_list[index] == nil then
		return def_value
	end
	local cur_data = self.sort_general_list[index].potential_blessing
	return cur_data
end

function FamousGeneralData:GetTotalBless(index)
	local def_value = 1
	if self.sort_general_list[index] == nil then
		return def_value
	end
	local cur_data = self.sort_general_list[index].potential_need_blessing
	return cur_data
end

function FamousGeneralData:GetPotentialHaveNum(index)
	local def_value = 0
	if self.sort_general_list[index] == nil then
		return def_value
	end
	local item_id = self.sort_general_list[index].potential_item_id
	local num = ItemData.Instance:GetItemNumInBagById(item_id)
	return num
end

function FamousGeneralData:GetPotentialNeedNum(index)
	local def_value = 1
	if self.sort_general_list[index] == nil then
		return def_value
	end
	local cur_data = self.sort_general_list[index].potential_need_num
	return cur_data
end

function FamousGeneralData:GetPotentialItemId(index)
	local def_value = 1
	if self.sort_general_list[index] == nil then
		return def_value
	end
	local cur_data = self.sort_general_list[index].potential_item_id
	return cur_data
end

function FamousGeneralData:GetSkillDesc(index, type)
	local def_value = ""
	if self.sort_general_list[index] == nil then
		return def_value
	end
	local cur_data = self.sort_general_list[index]
	return cur_data and cur_data.skill_introduce[type] or def_value
end

function FamousGeneralData:GetDataSeq(index)
	local def_value = 0
	if self.sort_general_list[index] == nil then
		return def_value
	end
	local cur_data = self.sort_general_list[index].seq
	return cur_data
end

function FamousGeneralData:GetGuangWuLevel(index)
	local def_value = 0
	if self.sort_general_list[index] == nil then
		return def_value
	end
	local sort_index = self.sort_general_list[index].sort_index
	local cur_data = self.general_data_list[sort_index].guangwu_level
	return cur_data
end

function FamousGeneralData:GetFaZhenLevel(index)
	local def_value = 0
	if self.sort_general_list[index] == nil then
		return def_value
	end

	local sort_index = self.sort_general_list[index].sort_index
	local cur_data = self.general_data_list[sort_index].fazhen_level
	return cur_data
end

function FamousGeneralData:GetFaZhenItem()
	return self.fazhen_item_id
end

function FamousGeneralData:GetGuangwuItem()
	return self.guangwu_item_id
end

function FamousGeneralData:GetFaZhenAttr(level)
	local def_value = {gongji = 0, maxhp = 0, fangyu = 0}
	if level == nil then
		return def_value
	end
	local cfg = ConfigManager.Instance:GetAutoConfig("shuxingdan_cfg_auto").reward
	local data_cfg = cfg[self.fazhen_type]
	local cur_data = {maxhp = data_cfg.maxhp * level, gongji = data_cfg.gongji * level, fangyu = data_cfg.fangyu * level}
	return cur_data
end

function FamousGeneralData:GetGuangWuAttr(level)
	local def_value = {gongji = 0, maxhp = 0, fangyu = 0}
	if level == nil then
		return def_value
	end
	local cfg = ConfigManager.Instance:GetAutoConfig("shuxingdan_cfg_auto").reward
	local data_cfg = cfg[self.guangwu_type]
	local cur_data = {maxhp = data_cfg.maxhp * level, gongji = data_cfg.gongji * level, fangyu = data_cfg.fangyu * level}
	return cur_data
end

function FamousGeneralData:GetGuangwuItemNum()
	local num = 0
	num = ItemData.Instance:GetItemNumInBagById(self.guangwu_item_id)
	return num
end

function FamousGeneralData:GetFaZhenItemNum()
	local num = 0
	num = ItemData.Instance:GetItemNumInBagById(self.fazhen_item_id)
	return num
end

function FamousGeneralData:GetFaZhenActiveLevel(index)
	local def_value = 0
	if self.sort_general_list[index] == nil then
		return def_value
	end

	local sort_index = self.sort_general_list[index].sort_index
	local cur_data = self.general_data_list[sort_index].active_fazhen_level
	return cur_data
end

function FamousGeneralData:GetGuangWuActiveLevel(index)
	local def_value = 0
	if self.sort_general_list[index] == nil then
		return def_value
	end

	local sort_index = self.sort_general_list[index].sort_index
	local cur_data = self.general_data_list[sort_index].active_guangwu_level
	return cur_data
end

function FamousGeneralData:GetTotalGeneralPower()
	local total_attr = {maxhp = 0, gongji = 0, fangyu = 0}
	for k,v in pairs(self.general_data_list) do
		local attr = v.attr
		-- 加阶数带来的战力
		total_attr.maxhp = total_attr.maxhp + attr[1]
		total_attr.gongji = total_attr.gongji + attr[2]
		total_attr.fangyu = total_attr.fangyu + attr[3]
		-- 加光武战力
		local guangwu_cfg = self:GetGuangWuAttr(v.guangwu_level)
		for k,v in pairs(total_attr) do
			v = v + guangwu_cfg[k]
		end

		local fazhen_cfg = self:GetFaZhenAttr(v.fazhen_level)
		for k,v in pairs(total_attr) do
			v = v + fazhen_cfg[k]
		end
	end
	
	local fight_power = CommonDataManager.GetCapabilityCalculation(total_attr)
	return fight_power, total_attr
end

function FamousGeneralData:GetSingerGeneralPower(index, fake_level)
	if self.sort_general_list[index] == nil then
		return 0
	end
	local data = self.sort_general_list[index]
	if not data.is_active and not fake_level then
		return 0
	end
	local total_attr = {maxhp = 0, gongji = 0, fangyu = 0}
	local attr = data.attr
	if fake_level then
		local cfg = self:GetCfgData(data.sort_index, 1)
		for i=1, 3 do
			attr[i] = cfg[GameEnum.AttrList[i]]
		end
	end
	-- 加阶数带来的战力
	total_attr.maxhp = total_attr.maxhp + attr[1]
	total_attr.gongji = total_attr.gongji + attr[2]
	total_attr.fangyu = total_attr.fangyu + attr[3]
	-- 加光武战力
	local guangwu_cfg = self:GetGuangWuAttr(data.guangwu_level)
	for k,v in pairs(total_attr) do
		v = v + guangwu_cfg[k]
	end

	local fazhen_cfg = self:GetFaZhenAttr(data.fazhen_level)
	for k,v in pairs(total_attr) do
		v = v + fazhen_cfg[k]
	end
	local fight_power = CommonDataManager.GetCapabilityCalculation(total_attr)
	return fight_power
end
--得到排序获得天神配置
function FamousGeneralData:GetImageCfg(index)
	local cfg = {}
	if nil == index then
		return cfg
	end

	local seq = self:GetDataSeq(index)
	cfg = self.general_list[seq + 1] or {}
	return cfg
end