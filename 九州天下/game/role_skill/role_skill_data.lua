RoleSkillData = RoleSkillData or BaseClass()

local PROFESSOIN_SKILL_NUM = 5 	-- 主动技能数

local PASSVIE_SKILL_ID_STAR = 41	-- 被动技能起始ID
local PASSVIE_SKILL_ID_END = 49		-- 被动技能结束ID

function RoleSkillData:__init()
	if RoleSkillData.Instance then
		print_error("[RoleSkillData] Attemp to create a singleton twice !")
	end
	RoleSkillData.Instance = self
	self.skill_tips_cfg = nil
	self.talent_cfg = nil
	self.talent_data = {}
	self.team_skill_info = {}
	self.shenji_skill_info = {}

	self.cur_client_index = 1
	self.last_grade = 0
	self.last_bless = 0

	RemindManager.Instance:Register(RemindName.ShenJiSkill, BindTool.Bind(self.CheckShenJiRed, self))
end

function RoleSkillData:__delete()
	RoleSkillData.Instance = nil
	RemindManager.Instance:UnRegister(RemindName.ShenJiSkill)
end

function RoleSkillData:GetTeamSkillCfgAuto()
	return ConfigManager.Instance:GetAutoConfig("teamskill_cfg_auto").team_skill
end

function RoleSkillData:GetTeamSkillCfg()
	if nil == self.team_skill_cfg then
		self.team_skill_cfg = ListToMap(self:GetTeamSkillCfgAuto(), "skill_type", "index", "level")
	end
	return self.team_skill_cfg
end

function RoleSkillData:GetTeamLeverNumber()
	if nil == self.team_level_number then
		self.team_level_number = ListToMapList(self:GetTeamSkillCfgAuto(), "skill_type")
	end
	return self.team_level_number
end

function RoleSkillData:GetTeamSkillLevelNumber()
	local team_level_number = self:GetTeamLeverNumber()	
	if team_level_number[0] then
		return #team_level_number[0] - 1
	end
end

function RoleSkillData:GetTeamSkillClientList()
	if nil == self.team_skill_client_list then
		self.team_skill_client_list = ConfigManager.Instance:GetAutoConfig("teamskill_cfg_auto").client_skill_info
	end
	return self.team_skill_client_list
end

function RoleSkillData:GetSkillTipsCfg()
	if nil == self.skill_tips_cfg then
		self.skill_tips_cfg = ConfigManager.Instance:GetAutoConfig("skill_tips_auto").skill_tips or {}
	end
	return self.skill_tips_cfg
end

function RoleSkillData:GetSkillName(index)
	local cfg = self:GetSkillTipsCfg()
	if cfg and cfg[index] then
		return cfg[index].res_id
	end
end

function RoleSkillData:GetIsCri(skill_id)
	if skill_id >= 5 and skill_id <= 8 then
		return true
	end
	return false
end

-- 技能列表
function RoleSkillData:GetAllSkillList()
	local profession_skill_data = {}
	local passive_skill_data = {}
	local roleskill_auto = ConfigManager.Instance:GetAutoConfig("roleskill_auto")
	local skillinfo = roleskill_auto.skillinfo
	local prof = PlayerData.Instance:GetRoleBaseProf()
	for skill_id, v in pairs(skillinfo) do
		if prof == math.modf(skill_id / 100) then
			profession_skill_data[v.skill_index] = v
		end
		for i = PASSVIE_SKILL_ID_STAR, PASSVIE_SKILL_ID_END do
			if i == skill_id then
				passive_skill_data[v.skill_index] = v
			end
		end
	end

	return profession_skill_data, passive_skill_data
end

function RoleSkillData:SkillPassiveRemind()
	if not OpenFunData.Instance:CheckIsHide("role_skill_player") then return 0 end
	local _, skill_list = self:GetAllSkillList()
	-- 被动技能
	for k, v in pairs(skill_list) do
		local skill_cfg = ConfigManager.Instance:GetAutoConfig("roleskill_auto")["s".. v.skill_id]
		if skill_cfg then
			local passive_info = SkillData.Instance:GetSkillInfoById(v.skill_id)
			local level = passive_info and passive_info.level or 0
			if level < #skill_cfg then
				local count = ItemData.Instance:GetItemNumInBagById(skill_cfg[level + 1].item_cost_id)
				if count >= skill_cfg[level + 1].item_cost and PlayerData.Instance.role_vo.coin >= skill_cfg[level + 1].coin_cost then
					return 1
				end
			end
		end
	end
	return 0
end

-- 单个主动技能红点
function RoleSkillData:IsShowSkillRedPoint(skill_index)
	local flag = false
	local profession_skill_data, _ = self:GetAllSkillList()
	local skill_id = profession_skill_data[skill_index].skill_id
	local skill_info = SkillData.Instance:GetSkillInfoById(skill_id)
	local skill_cfg = ConfigManager.Instance:GetAutoConfig("roleskill_auto")["s"..skill_id]
	if skill_cfg and skill_info and skill_info.level < #skill_cfg and PlayerData.Instance.role_vo.coin >= skill_cfg[skill_info.level + 1].coin_cost then
		flag = true
	end
	return flag
end

-- 主动技能标签红点
function RoleSkillData:IsShowActiveRedPoint()
	if not OpenFunData.Instance:CheckIsHide("role_skill_active") then return 0 end
	for i = 1, 5 do
		local flag = self:IsShowSkillRedPoint(i)
		if flag then
			return 1
		end
	end
	return 0
end

--单个组队技能红点		策划真恶心
function RoleSkillData:IsShowTeamSkillRedPoint(skill_index)
	local flag = false
	local hight_index = math.floor(skill_index / 2)			--前置等级序号
	local other_cfg = self:GetTeamSkillOtherInfo()
	local skill_info = self.team_skill_info
	-- 铜币和材料足够
	if other_cfg and skill_info and ItemData.Instance:GetItemNumIsEnough(other_cfg.uplevel_skill_stuff_id, 1) and PlayerData.Instance.role_vo.coin > other_cfg.uplevel_skill_need_coin then
		if self.team_skill_info == nil or self.team_skill_info[skill_index] == nil then return end
		if self.team_skill_info[skill_index].level >= self:GetTeamSkillLevelNumber() then
			return false
		end
		if hight_index == 0 then
			if self.team_skill_info[1].level < 60 then 	-- 等级小于60
				flag = true
			else 										-- 等级大于60
				local sum_level = 0
				for i = 1, 4 do
					sum_level = sum_level + self.team_skill_info[i + 3].level
				end
				if self.team_skill_info[1].level < sum_level then 	-- 等级小于4个基础技能之和
					flag = true
				end
			end
		elseif hight_index == 1 then 					-- 前置等级大于30级，大于当前等级
			if other_cfg.learn_median_skill_cond <= self.team_skill_info[hight_index].level and self.team_skill_info[skill_index].level < self.team_skill_info[hight_index].level then
				flag = true
			end
		else
			if other_cfg.learn_base_skill_cond <= self.team_skill_info[hight_index].level and self.team_skill_info[skill_index].level < self.team_skill_info[hight_index].level then
				flag = true
			end
		end
	end
	return flag
end

function RoleSkillData:GetActiveSkillRedInfo()
	local active_skill_info = {}
	local skill_list, _ = self:GetAllSkillList()
	for k,v in pairs(skill_list) do
		local skill_info = SkillData.Instance:GetSkillInfoById(v.skill_id)
		local skill_cfg = ConfigManager.Instance:GetAutoConfig("roleskill_auto")["s"..v.skill_id]
		if skill_cfg and skill_info and skill_info.level < #skill_cfg and PlayerData.Instance.role_vo.coin >= skill_cfg[skill_info.level].coin_cost then
			table.insert(active_skill_info, k)
		end
	end
	return active_skill_info
end

function RoleSkillData:SetRoleTalentData(data)
	if data then
		self.talent_data.exchange_times = data.exchange_times
		self.talent_data.total_talent_points = data.total_talent_points
		self.talent_data.page_index = data.page_index
		self.talent_data.remain_talent_points = data.remain_talent_points
		self.talent_data.is_actived_page = data.is_actived_page
		self.talent_data.talent_attr_list = data.talent_attr_list
	end
end

function RoleSkillData:GetRoleTalentData()
	return self.talent_data
end

function RoleSkillData:GetPageIsActiveByIndex(index)
	local is_actived_page = self:GetRoleTalentData().is_actived_page
	local flag = bit:d2b(is_actived_page)
	if 1 == flag[33 - index] then
		return true
	else
		return false
	end
end

function RoleSkillData:GetRoleTalentCfg()
	if nil == self.talent_cfg then
		self.talent_cfg = ConfigManager.Instance:GetAutoConfig("talent_system_cfg_auto") or {}
	end
	return self.talent_cfg
end

function RoleSkillData:CheckRoleTalentRedPoint()
	local talent_data = self:GetRoleTalentData()
	local remain_talent_points = talent_data.remain_talent_points or 0
	if remain_talent_points > 0 then
		return 1
	else
		return 0
	end
end

function RoleSkillData:GetRoleTalentPagesActiveCost(index)
	local cfg = self:GetRoleTalentCfg().other[1]
	local cost = 0
	if nil ~= cfg then
		if 2 == index then
			cost = cfg.open_second_page_price
		elseif 3 == index then
			cost = cfg.open_third_page_price
		elseif 4 == index then
			cost = cfg.open_forth_page_price
		end
	end
	return cost
end

function RoleSkillData:GetOtherByStr(str)
	return ConfigManager.Instance:GetAutoConfig("teamskill_cfg_auto").other[1][str]
end

function RoleSkillData:GetExchangeData()
	local talent_cfg = self:GetRoleTalentCfg()
	local role_level = GameVoManager.Instance:GetMainRoleVo().level
	local talent_data = self:GetRoleTalentData()
	local need_exp = 0
	local bind_gold = 0
	local is_can = true
	local data = {}
	if talent_cfg and talent_data then
		local already_convert = talent_data.total_talent_points
		local exchange_cfg = talent_cfg.exchange_cfg
		for k,v in pairs(exchange_cfg) do
			if role_level >= v.level then
				if already_convert < v.exchange_times then
					if data.need_exp == nil then
						data.need_exp = v.need_exp
					end

					if data.bind_gold == nil then
						data.bind_gold = v.bind_gold
					end
				end

				data.exchange_times = v.exchange_times
			end
		end
	end

	if data.need_exp == nil then
		is_can = false
		data.need_exp = Language.Common.IsMaxLabel
	end

	if data.bind_gold == nil then
		is_can = false
		data.bind_gold = Language.Common.IsMaxLabel
	end
	return data
end

function RoleSkillData:GetRoleAttrList()
	local data = {}
	local talent_cfg = self:GetRoleTalentCfg()
	local talent_data = self:GetRoleTalentData()
	if talent_data and talent_cfg then
		local force = talent_data.talent_attr_list[1]
		local command = talent_data.talent_attr_list[2]
		local wisdom = talent_data.talent_attr_list[3]
		for k,v in pairs(talent_cfg.attrs_cfg) do
			if 0 == v.talent_type then
				data.gongji = v.gongji * math.floor(force/v.add_attr_per_points)
			elseif 1 == v.talent_type then
				data.maxhp = v.maxhp * math.floor(command/v.add_attr_per_points)
			elseif 2 == v.talent_type then
				data.fangyu = v.fangyu * math.floor(wisdom/v.add_attr_per_points)
			end
		end
	end
	return data
end

function RoleSkillData:GetCurUpLevelSkillId(skill_id)
	local skil_list, _ = self:GetAllSkillList()
	local i = 1
	for k,v in pairs(skil_list) do
		if skill_id == v.skill_id then
			i = k + 1
			if i > #skil_list then
				i = 1
			end
			local skill_info = SkillData.Instance:GetSkillInfoById(skil_list[i].skill_id)
			local skill_cfg = ConfigManager.Instance:GetAutoConfig("roleskill_auto")["s".. skil_list[i].skill_id]
			local next_cfg = skill_cfg[skill_info.level + 1]
			if next_cfg and PlayerData.GetIsEnoughAllCoin(next_cfg.coin_cost) then
				return skil_list[i], i
			end
		end
	end
	return nil, nil
end

function RoleSkillData:SetTeamSkillInfo(protocol)
	self.reason_type = protocol.reason_type
	self.team_skill_info = protocol.skill_info
	self.team_skill_check = protocol.checklist
end

function RoleSkillData:GetTeamReasonType()
	return self.reason_type or 0
end

function RoleSkillData:GetTeamSingleCfg(skill_type, skill_index, skill_level)
	local team_skill_cfg = self:GetTeamSkillCfg()
	if team_skill_cfg[skill_type] 	and 
		team_skill_cfg[skill_type][skill_index] and 
		team_skill_cfg[skill_type][skill_index][skill_level] then

		return team_skill_cfg[skill_type][skill_index][skill_level]
	else
		print_warning("team_skill_cfg_error: skill_type, skill_index, skill_level = ", skill_type, skill_index, skill_level)
		return {}
	end
end

function RoleSkillData:CheckIsTeamSkill(skill_id)
	if skill_id == nil then
		return false
	end
	local team_skill_client_list = self:GetTeamSkillClientList()
	if team_skill_client_list == nil then
		return false
	end

	for k,v in pairs(team_skill_client_list) do
		if v.skill_icon == skill_id then
			return true
		end
	end

	return false
end

function RoleSkillData:GetSkillInfo(client_index)
	return self.team_skill_info[client_index] or {}
end

function RoleSkillData:GetTeamSkillCheckList()
	return self.team_skill_check
end

function RoleSkillData:GetTeamSkillOtherInfo()
	return ConfigManager.Instance:GetAutoConfig("teamskill_cfg_auto").other[1]
end

function RoleSkillData:GetLastGrade()
	return self.last_grade
end

function RoleSkillData:GetLastBless()
	return self.last_bless
end

function RoleSkillData:ChangeClick(client_index)
	self.cur_client_index = client_index
	self:SetLastInfo()
end

function RoleSkillData:SetLastInfo()
	local info = self:GetSkillInfo(self.cur_client_index)
	self.last_grade = info.level or 0
	self.last_bless = info.exp or 0
	return info
end

function RoleSkillData:GetTeamAllCap()
	local cap = 0
	local team_skill_client_list = self:GetTeamSkillClientList()
	if team_skill_client_list == nil or self.team_skill_info == nil then
		return cap
	end

	local attr = CommonStruct.Attribute()
	for k,v in pairs(team_skill_client_list) do
		if v ~= nil and self.team_skill_info[v.client_skill_index] ~= nil then
			local data = self:GetTeamSingleCfg(v.skill_type, v.index, self.team_skill_info[v.client_skill_index].level)
			if data ~= nil and next(data) ~= nil then
				attr = CommonDataManager.AddAttributeAttr(attr, CommonDataManager.GetAttributteByClass (data))
			end
		end
	end

	cap = CommonDataManager.GetCapability(attr)
	return cap
end

function RoleSkillData:SetShenJiSkillInfo(protocol)
	self.shenji_skill_info.has_fatch_reward = protocol.has_fatch_reward
	self.shenji_skill_info.camp_jungong = protocol.camp_jungong
end

function RoleSkillData:GetShenJiSkillInfo()
	return self.shenji_skill_info
end

function RoleSkillData:CheckShenJiRed()
	if ClickOnceRemindList[RemindName.ShenJiSkill] == 1 then
		return 1
	end

	local is_red = 0
	if self.shenji_skill_info ~= nil and next(self.shenji_skill_info) ~= nil then
		local cfg = ConfigManager.Instance:GetAutoConfig("other_config_auto")
		if cfg and cfg.other and cfg.other[1] then
			local need_jungong = cfg.other[1].shenji_skill_reward_need_day_jungong
			if need_jungong then
				if self.shenji_skill_info.has_fatch_reward == 0 and self.shenji_skill_info.camp_jungong >= need_jungong then
					is_red = 1
				end
			end
		end	
	end

	return is_red
end

function RoleSkillData:GetCapabilityByLevel(level)
	local capability = 0
	if level == nil then
		return capability
	end
	capability = self:GetRoleTalentCfg().other[1].capability * level

	return capability
end