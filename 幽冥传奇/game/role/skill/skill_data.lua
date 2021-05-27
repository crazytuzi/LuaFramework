--------------------------------------------------------
--技能数据管理
--------------------------------------------------------

SkillData = SkillData or BaseClass(BaseData)


SkillData.SKILL_EXP_CHANGE = "skill_exp_change"
SkillData.SKILL_DATA_CHANGE = "skill_data_change"

SkillData.SKILL_CONDITION = {
	LEVEL = 1, 				-- 等级
	SKILL_BOOK = 3, 				-- 等级
	HP = 7,					-- 生命消耗
	MP = 8,					-- 魔法消耗
	DISTANCE = 13,			-- 和目标的距离小于一定距离
	SLD = 21,				-- 熟练度
	EIGHT_DIR_LINE_DISTANCE = 35,	-- 和目标需要在8方向直线上
}
SKILL_BAR_COUNT = 8

SKILL_SPELL_TYPE = {
	TARGET = 0,				-- 对目标使用
	AREA = 2,				-- 对区域使用
	SELF = 3,				-- 对自己使用
	NONE = 4,				-- 直接使用
}

SKILL_TYPE = {
	PHYSICS_ATTACK = 0, 		-- 物理攻击,
	PASSIVE = 1, 				-- 被动,
	MAGIC_ATTACK = 2, 			-- 魔法攻击,
	POISON_ATTACK= 3, 			-- 毒物攻击,
	LIFE_SKILL= 4, 				-- 表示生活技能,
	OTHER_SKILL= 5, 			-- 其他特殊技能(比如光环类)
}

SKILL_CLASS = {
	SUPER_SKILL = 8,
}

ALL_SKILL_LIST = {
	{1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 16, 122, 123},
	{11, 12, 13, 14, 15, 17, 18, 20, 32, 83},
	{21, 23, 24, 25, 26, 27, 28, 29, 30, 33},
}

SPECIAL_SKILL_LIST = {}

NOT_SETING_SKILL = SetBag{3, 12, 22, 122, 123, 124}
						
local cache_skill_bar_settd_t = {}
function SkillData:__init()
	if SkillData.Instance then
		ErrorLog("[SkillData] Attemp to create a singleton twice !")
	end
	SkillData.Instance = self

	self.global_cd = 0
	self.skill_list = {}		-- skill_id, skill_level, book_stuff_id, skill_cd, skill_exp, book_limit_time, is_disable
	self.act_skill_list = {}
	self.all_skill_list = {}
	self.client_skill_index_map = {}
	self.cache_new_skill = {}
	self.refine_skill_buff = {}
	self:InitSkillClientIndexMap()
	self.skill_list_first_flag = true
end

function SkillData:__delete()
	SkillData.Instance = nil
end

function SkillData:SetRefineSkillBuff()
	self.refine_skill_buff = {}
	for i = EquipData.EquipIndex.Weapon, EquipData.EquipIndex.Shoes do
		local equip = EquipData.Instance:GetGridData(i)
		if equip then
			for i = 1, equip.refine_count do
				if equip.refine_attr[i] and equip.refine_attr[i].type == GAME_ATTRIBUTE_TYPE.ADD_SKILL_LEVEL then
					local skill_id, level = RefineData.GetSkillIdAndLevel(equip.refine_attr[i].value)
					if self.refine_skill_buff[skill_id] == nil then
						self.refine_skill_buff[skill_id] = level
					else
						self.refine_skill_buff[skill_id] = self.refine_skill_buff[skill_id] + level
					end
				end
			end
		end
	end
end


function SkillData:GetRefineSkillLevel(skill_id)
	return self.refine_skill_buff[skill_id] or 0
end

function SkillData:InitAllSkillList()
	self.all_skill_list = {}
	local prof = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
	for key, value in ipairs(ALL_SKILL_LIST) do
		for i, v in ipairs(value) do
			if cc.FileUtils:getInstance():isFileExist("scripts/config/server/config/skill/skillData/Skill_" .. v .. ".lua") then
				local skill_cfg = SkillData.GetSkillCfg(v)
				if skill_cfg and (skill_cfg.vocation == prof or skill_cfg.vocation == 0) and not skill_cfg.isDelete and skill_cfg.skillClass ~= SKILL_CLASS.SUPER_SKILL then
					if IsInTable(v, SPECIAL_SKILL_LIST) then	-- 标记特殊技能
						skill_cfg.is_special = true
					end
					table.insert(self.all_skill_list, skill_cfg)
				end
			end
		end
	end
end

function SkillData:InitSkillClientIndexMap()
	self.client_skill_index_map = {}
	for k,v in pairs(ALL_SKILL_LIST) do
		for k1,v1 in pairs(v) do
			self.client_skill_index_map[v1] = k1
		end
	end
	return 0
end

function SkillData:GetSkillClientIndex(skill_id)
	return self.client_skill_index_map[skill_id] or 0
end

function SkillData:GetSkillAuto(skill_id)
	if nil == SettingData.CanSetAutoSkill[skill_id] then
		-- 不能"设置"自动战斗的技能默认可以自动战斗
		return true
	end

	local client_index = self:GetSkillClientIndex(skill_id)
	return SettingCtrl.Instance:GetAutoSkillSetting(client_index)
end

-- 获取可在技能栏使用的物品
--该列表 需要显示每样物品的所有数量(原代码写法, 修改方法时需兼容之前功能)
local skill_bar_item = SetBag{486, 487, 488, 489, 490, 460, 454, 455, 456, 457}	--快捷使用道具
function SkillData:GetSkillBarItemList()
	local list = BagData.Instance:GetItemDataList()

	local item_list = {}
	local bag_list = {}
	--筛选物品id
	for k,v in pairs(list) do
		if skill_bar_item[v.item_id] then
			item_list[v.item_id] = true
		end
	end

	--网格所需数据
	for item_id in pairs(item_list) do
		table.insert(bag_list, {item_id = item_id, num = BagData.Instance:GetItemNumInBagById(item_id)})
	end
	bag_list[0] = table.remove(bag_list, 1)
	
	return bag_list
end

function SkillData:GetSkillList()
	return self.skill_list
end

function SkillData:GetAllCanSetSkillList()
	local list = {}
	for i,v in ipairs(self.all_skill_list) do
		if not NOT_SETING_SKILL[v.id] then
			table.insert(list, {skill_id = v.id})
		end
	end

	table.sort(list, function (a, b)
		local a_is_act = nil ~= self.skill_list[a.skill_id]
		local b_is_act = nil ~= self.skill_list[b.skill_id]
		-- if a_is_act and b_is_act then
			return a.skill_id < b.skill_id
		-- end
	end)

	return list
end

-- 获取已激活的技能
-- not_special 排除必杀技能
function SkillData:GetActSkillList(not_special)
	not_special = nil ~= not_special and not_special or false

	local show_act_skill_list = {}
	for k, v in pairs(self.act_skill_list) do
		local skill_info = SkillData.Instance:GetSkill(v.skill_id)
		if nil ~= skill_info and skill_info.skill_level > 0 and (not_special and not IsInTable(v.skill_id, SPECIAL_SKILL_LIST)) then
			table.insert(show_act_skill_list, v)
		end
	end
	return show_act_skill_list
end

function SkillData:GetAllSkillList()
	return self.all_skill_list
end

function SkillData:GetShowSkillList()
	local a_list = self:GetAllSkillList()
	local s_list = {} 	-- 特殊
	local n_list = {} 	-- 普通

	for k,v in pairs(a_list) do
		if v.is_special then
			-- 在这里处理特殊技能是否显示
			-- local skill_info = SkillData.Instance:GetSkill(v.id)
			-- if nil ~= skill_info and skill_info.skill_level > 0 then
			-- 	table.insert(s_list, v)
			-- end
			table.insert(s_list, v)
		else
			table.insert(n_list, v)
		end
	end

	return n_list, s_list
end

-- 有技能处于引导设置中，用该接口能拿到真正的技能空位
function SkillData.GetRealOneEmptySkillBarIndex(skill_id)
	if 3 == skill_id or 12 == skill_id or 22 == skill_id then
		if nil == cache_skill_bar_settd_t[0] and nil == SettingData.Instance:GetOneShowSkill(HOT_KEY["SKILL_BAR_" .. 0]) then
			return 0
		end
	else
		for i = 1, SKILL_BAR_COUNT do
			if nil == cache_skill_bar_settd_t[i] and nil == SettingData.Instance:GetOneShowSkill(HOT_KEY["SKILL_BAR_" .. i]) then
				return i
			end
		end
	end
	
	return nil
end

function SkillData:SetSkillList(skill_list)
	self.act_skill_list = {}
	for k, v in pairs(skill_list) do
		local skill_cfg = SkillData.GetSkillCfg(v.skill_id)
		if IsInTable(v.skill_id, SPECIAL_SKILL_LIST) then	-- 标记特殊技能
			v.is_special = true
		end

		-- 取消已学习技能的技能书自动使用
		local cfg = CleintItemShowCfg or {} -- 文件名 cleint_item_effect_cfg
		local skill_book_id = cfg[3] and cfg[3][v.skill_id] -- 当前技能对应的技能书物品ID
		if skill_book_id and cfg[1] then
			cfg[1][skill_book_id] = nil
		end

		if nil == self.skill_list[v.skill_id] and not self.skill_list_first_flag then   ---开启默认自动使用

			if v.is_special then
				v.is_guideing_bisha = true
				GlobalEventSystem:Fire(ObjectEventType.MAIN_ROLE_LEARN_BISHA)
			else
				-- 普通技能自动选择一个技能栏位并开启自动施放
				local client_index = self:GetSkillClientIndex(v.skill_id)
				if client_index > 0 then
					SettingCtrl.Instance:ChangeAutoSkillSetting({[client_index] = true})
				end

				if v.skill_level > 0 and v.is_disable == 0 
				and (skill_cfg.skillType == SKILL_TYPE.PHYSICS_ATTACK
					or skill_cfg.skillType == SKILL_TYPE.MAGIC_ATTACK
					or skill_cfg.skillType == SKILL_TYPE.POISON_ATTACK) then
					local empty_skill_bar_index = SkillData.GetRealOneEmptySkillBarIndex(v.skill_id)
					table.insert(self.cache_new_skill, 1, {skill_id = v.skill_id, bar_index = empty_skill_bar_index})
					if empty_skill_bar_index then
						cache_skill_bar_settd_t[empty_skill_bar_index] = 1	-- 记录正在设置中的技能位置
					end
					GuideCtrl.Instance:OpenSkillRemindView()
				end
			end
		end
		self.skill_list[v.skill_id] = v

		if v.skill_level > 0 and v.is_disable == 0 and (skill_cfg.skillType == SKILL_TYPE.PHYSICS_ATTACK or skill_cfg.skillType == SKILL_TYPE.MAGIC_ATTACK or skill_cfg.skillType == SKILL_TYPE.POISON_ATTACK)
		 and v.skill_id ~= 3 and v.skill_id ~= 12 and v.skill_id ~= 22 and v.skill_id ~= 122 and v.skill_id ~= 123 then
			table.insert(self.act_skill_list, v)
		end
		if self.skill_list_first_flag and (3 == v.skill_id or 12 == v.skill_id or 22 == v.skill_id) then
			SettingCtrl.Instance:SetOneShowSkill({type = SKILL_BAR_TYPE.SKILL , id = v.skill_id}, HOT_KEY["SKILL_BAR_" .. 0])
			GlobalEventSystem:Fire(SettingEventType.SKILL_BAR_CHANGE)
		end

	end
	self.skill_list_first_flag = false
	
	BagData.Instance:SetAutoUse(true)
	self:DispatchEvent(SkillData.SKILL_DATA_CHANGE)
end

function SkillData.GetOneEmptySkillBarIdnex()
	for i = 1, SKILL_BAR_COUNT do
		if nil == SettingData.Instance:GetOneShowSkill(HOT_KEY["SKILL_BAR_" .. i]) then
			return i
		end
	end
	return nil
end

function SkillData:GetSkillIconId(skill_id)
	local skill_lv = 1
	if self.skill_list[skill_id] then
		skill_lv = self.skill_list[skill_id].skill_level
	end
	local skill_lv_vfg =  SkillData.GetSkillLvCfg(skill_id, skill_lv)
	local icon_id = skill_lv_vfg and skill_lv_vfg.iconID or 2
	
	return icon_id
end

-- 主角的特殊技能id
function SkillData:GetMainRoleSpecSkillId()
	local prof = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
	return SPECIAL_SKILL_LIST[prof] or SPECIAL_SKILL_LIST[1]
end

function SkillData:GetSkill(skill_id)
	return self.skill_list[skill_id]
end

function SkillData:RemoveSkill(skill_id)
	self.skill_list[skill_id] = nil

	for i=HOT_KEY.SKILL_BAR_1,HOT_KEY.SKILL_BAR_8 do
		local data = SettingData.Instance:GetOneShowSkill(i)
		if data ~= nil and data.id == skill_id then
			SettingCtrl.Instance:SetOneShowSkill(nil, i)
			return
		end
	end
	self:DispatchEvent(SkillData.SKILL_DATA_CHANGE)
end

function SkillData:SetSkillLevel(skill_id, skill_level)
	if nil ~= self.skill_list[skill_id] then
		self.skill_list[skill_id].skill_level = skill_level
	end
end

function SkillData:SetSkillBookStuffId(skill_id, book_stuff_id)
	if nil ~= self.skill_list[skill_id] then
		self.skill_list[skill_id].book_stuff_id = book_stuff_id
	end
end

function SkillData:SetSkillCD(skill_id, skill_cd)
	if nil ~= self.skill_list[skill_id] then
		self.skill_list[skill_id].skill_cd = skill_cd
	end
end

function SkillData:SetSkillExp(skill_id, skill_exp)
	if nil ~= self.skill_list[skill_id] then
		self.skill_list[skill_id].skill_exp = skill_exp
	end
	self:DispatchEvent(SkillData.SKILL_EXP_CHANGE, skill_id)
end

function SkillData:SetSkillBookLimitTime(skill_id, book_limit_time)
	if nil ~= self.skill_list[skill_id] then
		self.skill_list[skill_id].book_limit_time = book_limit_time
	end
end

function SkillData:SetSkillIsDisable(skill_id, is_disable)
	if nil ~= self.skill_list[skill_id] then
		self.skill_list[skill_id].is_disable = is_disable
	end
end

function SkillData:GetSkillCD(skill_id)
	if nil ~= self.skill_list[skill_id] then
		return math.max(self.skill_list[skill_id].skill_cd, self.global_cd)
	end

	return self.global_cd
end

function SkillData:GetGlobalCD()
	return self.global_cd
end

-- 技能施放距离条件
function SkillData:GetSkillDisConds(skill_id)
	local conds = {rect_range = nil, eight_dir_line_range = nil}

	local skill = self:GetSkill(skill_id)
	if nil == skill then
		if skill_id == 0 then
			return {rect_range = nil, eight_dir_line_range = 1}
		else
			return conds
		end
	end

	local skill_level_cfg = SkillData.GetSkillLvCfg(skill_id, skill.skill_level)
	if nil == skill_level_cfg then
		return conds
	end

	for k, v in pairs(skill_level_cfg.spellConds) do
		if v.cond == SkillData.SKILL_CONDITION.DISTANCE then
			conds.rect_range = v.value
		elseif v.cond == SkillData.SKILL_CONDITION.EIGHT_DIR_LINE_DISTANCE then
			conds.eight_dir_line_range = v.value
		end
	end

	return conds
end

-- 返回 是否可用，使用距离
function SkillData:CanUseSkill(skill_id, ignore_global_cd)
	local skill = self:GetSkill(skill_id)
	if nil == skill or (not skill.is_special and (skill.skill_cd > Status.NowTime)) then
		return false, 0
	end

	local skill_level_cfg = SkillData.GetSkillLvCfg(skill_id, skill.skill_level)
	if nil == skill_level_cfg then
		return false, 0
	end

	if not ignore_global_cd and self.global_cd > Status.NowTime then
		return false, 0
	end

	if skill.is_special then
		--必杀技能根据怒气判断
		if RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_ANGER) < FuwenData.Instance:GetMaxAnger() then
			return false, 0, "必杀技冷却中..."
		end
	end

	local range = 1
	for k, v in pairs(skill_level_cfg.spellConds) do
		if v.cond == SkillData.SKILL_CONDITION.HP then
			if RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_HP) < v.value then
				return false, 0
			end
		elseif v.cond == SkillData.SKILL_CONDITION.MP then
			if RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_MP) < v.value then
				return false, 0, "{wordcolor;ff0000;" .. Language.Fight.MPLimit .."}"
			end
		elseif v.cond == SkillData.SKILL_CONDITION.DISTANCE then
			range = v.value
		end
	end

	return true, range
end

function SkillData:OnUseSkill(skill_id)
	local skill = self:GetSkill(skill_id)
	if nil == skill then return end

	local skill_cfg = SkillData.GetSkillCfg(skill_id)
	if nil == skill_cfg then return end

	self.global_cd = math.max(self.global_cd, Status.NowTime + (skill_cfg.commonCd / 1000 or 0))

	local skill_level_cfg = SkillData.GetSkillLvCfg(skill_id, skill.skill_level)
	if nil ~= skill_level_cfg then
		-- 设定技能使用间隔
		if skill_level_cfg.cooldownTime < 500 then
			-- self:SetSkillCD(skill_id, Status.NowTime + 0.2)
		else
			self:SetSkillCD(skill_id, Status.NowTime + skill_level_cfg.cooldownTime / 1000)
		end
	end

	if skill_id == MainuiData.Instance:GetAreaSkillId() then
		MainuiData.Instance:SetAreaSkillId(0)
	end
end

function SkillData.GetSkillCfg(skill_id)
	if cc.FileUtils:getInstance():isFileExist("scripts/config/server/config/skill/skillData/Skill_" .. skill_id .. ".lua") then
		return ConfigManager.Instance:GetServerConfig("skill/skillData/Skill_" .. skill_id)[1]
	end
end

function SkillData.GetSkillLvCfg(skill_id, skill_lv)
	local cfg = ConfigManager.Instance:GetServerConfig("skill/skillData/Skill_" .. skill_id .. "_" .. skill_lv)
	return cfg and cfg[1]
end

function SkillData.GetSkillHasNextLv(skill_id, skill_lv)
	return cc.FileUtils:getInstance():isFileExist("scripts/config/server/config/skill/skillData/Skill_" .. skill_id .. "_" .. (skill_lv + 1) .. ".lua")
end

function SkillData.IsFirewall(skill_id)
	return skill_id == 14
end

-- 获取游戏运行中新获得的技能列表
function SkillData:GetNewSkillList()
	return self.cache_new_skill
end

function SkillData.IsMySkill(skill_id)
	local prof = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
	return IsInTable(skill_id, ALL_SKILL_LIST[prof] or {})
end
