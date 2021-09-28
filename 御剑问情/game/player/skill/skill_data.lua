--------------------------------------------------------
--技能数据管理
--------------------------------------------------------
SkillData = SkillData or BaseClass()

local normal_skill_list = {
	{111, 112, 113},
	{211, 212, 213},
	{311, 312, 313},
	{411, 412, 413},
	{600},
}
SkillData.ANGER_SKILL_ID = 5
SkillData.SKILL_INFO_GET = false

function SkillData:__init()
	if SkillData.Instance then
		print_error("[SkillData] Attemp to create a singleton twice !")
	end
	SkillData.Instance = self

	self.default_skill_index = 0
	self.skill_list = {}
	self.global_cd_end = 0

	self.UP_SKILL_ITEM_ID = 26500
	self.other_skill_info = {}
	self.goddes_skill_id = 0
	RemindManager.Instance:Register(RemindName.PlayerSkill, BindTool.Bind(self.GetPlayerSkillRemind, self))
	self.mieShi_skill_cfg = ListToMap(ConfigManager.Instance:GetAutoConfig("rolegoalconfig_auto").skill, "skill_type", "skill_level")
end

function SkillData:__delete()
	RemindManager.Instance:UnRegister(RemindName.PlayerSkill)

	SkillData.Instance = nil
	self.skill_list = nil
end

function SkillData:GetDefaultSkillIndex()
	return self.default_skill_index
end

function SkillData:SetDefaultSkillIndex(default_skill_index)
	self.default_skill_index = default_skill_index
end

function SkillData:SetSkillList(skill_list)
	SkillData.SKILL_INFO_GET = true
	self.skill_list = {}
	for k, v in pairs(skill_list) do
		self.skill_list[v.skill_id] = v
		self:CalcSkillCondition(v)
	end
	GlobalEventSystem:Fire(MainUIEventType.ROLE_SKILL_CHANGE, "list")
end

function SkillData:SetSkillInfo(skill_info)
	self.skill_list[skill_info.skill_id] = skill_info
	self:CalcSkillCondition(skill_info)
	GlobalEventSystem:Fire(MainUIEventType.ROLE_SKILL_CHANGE, "skill", skill_info.skill_id)
end

function SkillData:CalcSkillCondition(skill_info)
	skill_info.cd_end_time = 0
	skill_info.cost_mp = 0

	local cfg = SkillData.GetSkillConfigByIdLevel(skill_info.skill_id, skill_info.level)
	if cfg ~= nil then
		local cd = math.min(skill_info.last_perform + cfg.cd_s - TimeCtrl.Instance:GetServerTime(), cfg.cd_s)
		skill_info.cd_end_time = Status.NowTime + cd
		skill_info.cost_mp = cfg.cost_mp or 0
	end
end

function SkillData:GetNextLevelSkillVo(skill_id)
	local skill_info = self:GetSkillInfoById(skill_id)
	local now_level = skill_info ~= nil and skill_info.level or 0
	return self.GetSkillConfigByIdLevel(skill_id,now_level + 1)
end

function SkillData:GetLearnSkillIsEnoughLevel(skill_id)
	local next_skill_vo = self:GetNextLevelSkillVo(skill_id)
	if next_skill_vo ~= nil and next_skill_vo.learn_level_limit > PlayerData.Instance.role_vo.level then
		return false
	end
	return true
end

function SkillData:GetLeanSkillIEnoughNWS(skill_id)
	local next_skill_vo = self:GetNextLevelSkillVo(skill_id)
	if next_skill_vo ~= nil and next_skill_vo.zhenqi_cost > PlayerData.Instance.role_vo.nv_wa_shi then
		return false
	end
	return true
end

function SkillData:GetLeanSkillIEnoughCoin(skill_id)
	local next_skill_vo = self:GetNextLevelSkillVo(skill_id)
	if next_skill_vo ~= nil and not PlayerData.GetIsEnoughAllCoin(next_skill_vo.coin_cost) then
		return false
	end
	return true
end

--根据技能id获得info
function SkillData:GetSkillInfoById(skill_id)
	return self.skill_list[skill_id]
end


--获取当前的仙女技能
function SkillData:GetCurGoddessSkill()
	if self.goddes_skill_id > 0 and nil ~= self.skill_list[self.goddes_skill_id] then
		return self.skill_list[self.goddes_skill_id]
	end

	for k,v in pairs(self.skill_list) do
		if GoddessData.Instance:IsGoddessSkill(k) then
			self.goddes_skill_id = k -- 缓存防止每次战斗进行查询
			return v
		end
	end

	return nil
end

function SkillData:GetSkillIndex(skill_id)
	if nil == self.skill_list[skill_id] then
		return 0
	end
	return self.skill_list[skill_id].index
end

function SkillData:GetRealSkillIndex(skill_id)
	local index = self:GetSkillIndex(skill_id)
	if PlayerData.Instance.role_vo.special_appearance == SPECIAL_APPEARANCE_TYPE.SPECIAL_APPERANCE_TYPE_TERRITORYWAR then
		local special_skills = ClashTerritoryData.Instance:GetSkillList()
		for k,v in pairs(special_skills) do
			if index == 3 then
				if v.skill_index > 3 then
					return v.skill_index
				end
			elseif v.skill_index <= 3 then
				return v.skill_index
			end
		end
	end
	return index
end

function SkillData:GetSkillCDEndTime(skill_id)
	if nil == self.skill_list[skill_id] then
		return self.global_cd_end
	end

	return math.max(self.global_cd_end, self.skill_list[skill_id].cd_end_time)
end

function SkillData:GetGlobalCDEndTime()
	return self.global_cd_end
end

function SkillData:GetSkillList()
	return self.skill_list
end

function SkillData:IsSkillCD(skill_id)
	if PlayerData.Instance.role_vo.special_appearance == SPECIAL_APPEARANCE_TYPE.SPECIAL_APPERANCE_TYPE_TERRITORYWAR then
		local index = self:GetRealSkillIndex(skill_id)
		local special_skill =  ClashTerritoryData.Instance:GetSkillInfoById(index)
		if nil == special_skill or special_skill.cd_end_time > Status.NowTime then
			return true
		else
			return false
		end
	end
	-- if skill_id == SkillData.ANGER_SKILL_ID then
	-- 	return PlayerData.Instance.role_vo.nuqi < COMMON_CONSTS.NUQI_FULL
	-- end
	local skill_info = self:GetSkillInfoById(skill_id)
	if nil == skill_info or skill_info.cd_end_time > Status.NowTime then
		return true
	end
	return false
end

function SkillData:CanUseSkill(skill_id, ignore_global_cd)
	local skill_info = self:GetSkillInfoById(skill_id)

	if PlayerData.Instance.role_vo.special_appearance == SPECIAL_APPEARANCE_TYPE.SPECIAL_APPERANCE_TYPE_TERRITORYWAR then
		local index = self:GetRealSkillIndex(skill_id)
		local special_skill = ClashTerritoryData.Instance:GetSkillInfoById(index)
		if special_skill then
			if not ignore_global_cd and special_skill.cd_end_time > Status.NowTime then
				return false, 0
			else
				local cfg = ClashTerritoryData.Instance:GetTerritorySkillCfg(index)
				if cfg == nil then
					return false, 0
				end
				return true, cfg.distance or 1
			end
		end
	end

	if nil == skill_info or skill_info.cd_end_time > Status.NowTime then
		return false, 0, Language.Common.SkillCD
	end

	if not ignore_global_cd and self.global_cd_end > Status.NowTime then
		return false, 0
	end

	if PlayerData.Instance:GetAttr("mp") < skill_info.cost_mp then
		return false, 0
	end

	local cfg = SkillData.GetSkillConfigByIdLevel(skill_info.skill_id, skill_info.level)
	if cfg == nil then
		return false, 0
	end

	-- 如果是必杀技
	-- if skill_info.skill_id == 5 then
	-- 	local nuqi = GameVoManager.Instance:GetMainRoleVo().nuqi
	-- 	if not nuqi or nuqi < COMMON_CONSTS.NUQI_FULL then
	-- 		return false, 0
	-- 	end
	-- end

	return true, cfg.distance or 1
end

function SkillData:UseSkill(skill_id)
	self.global_cd_end = Status.NowTime + 0.3

	local skill_info = self:GetSkillInfoById(skill_id)
	if nil ~= skill_info then
		local cfg = SkillData.GetSkillConfigByIdLevel(skill_info.skill_id, skill_info.level)
		local count_cd = ShengXiaoData.Instance:GetMijiToSkillCd()
		local cd_s = cfg.cd_s
		if count_cd ~= 0 then
			cd_s = cd_s - cd_s * count_cd / 10000
		end
		if nil ~= cfg then
			if cfg.cd_s > 0  then
				skill_info.cd_end_time = Status.NowTime + cd_s
			else
				skill_info.cd_end_time = Status.NowTime + cd_s + 0.3
			end
		end
	end
	if PlayerData.Instance.role_vo.special_appearance == SPECIAL_APPEARANCE_TYPE.SPECIAL_APPERANCE_TYPE_TERRITORYWAR then
		local spec_skill = ClashTerritoryData.Instance:GetSkillInfoById(skill_id)
		if spec_skill then
			local cfg = ClashTerritoryData.Instance:GetTerritorySkillCfg(skill_id)
			if nil ~= cfg then
				if cfg.cd_s > 0  then
					spec_skill.cd_end_time = Status.NowTime + cfg.cd_s
				else
					spec_skill.cd_end_time = Status.NowTime + cfg.cd_s + 0.3
				end
			end
		end
	end
	GlobalEventSystem:Fire(ObjectEventType.MAIN_ROLE_USE_SKILL, skill_id)
end

function SkillData.IsBuffSkill(skill_id)
	local client_cfg = SkillData.GetSkillinfoConfig(skill_id)
	if client_cfg and client_cfg.is_buff == 1 then
		return true
	end
	return false
end


--根据id和等级获得技能Config
function SkillData.GetSkillConfigByIdLevel(skill_id, level)
	local roleskill_auto = ConfigManager.Instance:GetAutoConfig("roleskill_auto")
	local cfg = roleskill_auto.normal_skill[skill_id]
	if cfg ~= nil then
		return cfg
	end
	cfg = roleskill_auto["s" .. skill_id]
	if cfg ~= nil then
		return cfg[level]
	end

	return nil
end

function SkillData.GetSkillarchConfig(bskill_id)
	return ConfigManager.Instance:GetAutoConfig("roleskill_auto").skillarch[bskill_id]
end

function SkillData.GetSkillinfoConfig(skill_id)
	return ConfigManager.Instance:GetAutoConfig("roleskill_auto").skillinfo[skill_id]
end

function SkillData.GetSkillCanMove(skill_id)
	if ConfigManager.Instance:GetAutoConfig("roleskill_auto").skillinfo[skill_id] then
		return ConfigManager.Instance:GetAutoConfig("roleskill_auto").skillinfo[skill_id].can_move == 1
	end
	return false
end

local skill_info_cfg = nil
function SkillData.GetSkillBloodDelay(skill_id)
	skill_info_cfg = ConfigManager.Instance:GetAutoConfig("roleskill_auto").skillinfo[skill_id]
	return skill_info_cfg and skill_info_cfg.blood_delay or 0.1
end

function SkillData.IsAoeSkill(skill_id)
	local skill_config = SkillData.GetSkillConfigByIdLevel(skill_id, 1)
	if nil ~= skill_config then
		return skill_config.enemy_num > 1
	end

	skill_config = ConfigManager.Instance:GetAutoConfig("monsterskill_auto").skill_list[skill_id]
	if nil ~= skill_config then
		return skill_config.is_aoe == 1
	end

	return false
end

-- 非普通攻击
function SkillData.IsNotNormalSkill(skill_id)
	for _, v in ipairs(normal_skill_list) do
		for _, sid in ipairs(v) do
			if sid == skill_id then
				return false
			end
		end
	end

	return true
end

function SkillData.GetMonsterSkillConfig(skill_id)
	return ConfigManager.Instance:GetAutoConfig("monsterskill_auto").skill_list[skill_id]
end

function SkillData.RepleCfgContent(source, skill_vo)
	if not source or not skill_vo then
		return ""
	end
	local len = string.len(source)
	local rule = '%[([^%]]-)%]%%'
	local key = ""
	local rep = ""

	local var = 1
	while var <= len do
		var = var + 1
		local i, j = string.find(source, rule)
		if i and i < var then
			var = j
			key = string.sub(source, i + 1, j - 2)
			rep = skill_vo[key] / 100
			source = string.gsub(source, '%[' .. key .. '%]%%', rep .. "%%")
		end
	end

	len = string.len(source)
	rule = '%[(.-)%]'
	var = 1
	while var <= len do
		var = var + 1
		local i, j = string.find(source, rule)
		if i and i < var then
			var = j
			key = string.sub(source, i + 1, j -1)
			rep = skill_vo[key]
			source = string.gsub(source, '%[' .. key .. '%]', rep)
		end
	end
	return source
end

--获得某个技能的可学习状态
--应付多种状态，使用时用取模方法
-- function SkillData:GetLearnSkillStatus(skill_id)
-- 	local flag = 0
-- 	local skill_info = self:GetSkillInfoById(skill_id)
-- 	local now_level = skill_info ~= nil and skill_info.level or 0

-- 	local next_skill_vo = self.GetSkillConfigByIdLevel(skill_id,now_level + 1)
-- 	if next_skill_vo == nil then
-- 		flag = 10000 			--满级
-- 		return flag
-- 	end
-- 	if next_skill_vo.learn_level_limit > PlayerData.Instance.role_vo.level then
-- 		flag = 10000 + 1		--人物等级不足
-- 	elseif next_skill_vo.zhenqi_cost ~= 0 and next_skill_vo.zhenqi_cost > PlayerData.Instance.role_vo.nv_wa_shi then
-- 		flag = 10000 + 1 * 10 	--女娲石
-- 	elseif not self:GetLeanSkillIEnoughCoin(skill_id) then
-- 		flag = 10000 + 1 * 100 	--铜币不足
-- 	elseif "" ~= next_skill_vo.item_cost and 0 ~= next_skill_vo.item_cost
-- 		and ItemData.Instance:GetItemNumInBagById(self.UP_SKILL_ITEM_ID) < next_skill_vo.item_cost then
-- 		flag = 10000 + 1 * 1000 	--物品不足
-- 	end
-- 	if flag ~= 0 then	--若不能升级学习直接返回
-- 		return flag
-- 	end
-- 	flag = 20000
-- 	if now_level == 0 then
-- 		flag = 20000			--可学
-- 	else
-- 		flag = 20000 + 1 * 10	--可升级
-- 	end
-- 	return flag
-- end

function SkillData:SetSkillOtherSkillInfo(protocol)
	if protocol.skill124_effect_baoji == 1  and nil ~= self.other_skill_info.skill124_effect_star then
		self.other_skill_info.skill124_effect_star = self.other_skill_info.skill124_effect_star + 1
	else
		self.other_skill_info.skill124_effect_star = protocol.skill124_effect_star
	end
	self.other_skill_info.skill124_effect_baoji = protocol.skill124_effect_baoji
end

function SkillData:CheckIsNew(skill_list, is_init)
	if is_init == 1 then
		return
	end

	for k, v in pairs(skill_list) do
		if self.skill_list[v.skill_id] == nil then
			GlobalTimerQuest:AddDelayTimer(function ()
				TipsCtrl.Instance:ShowGetNewSkillView(v.skill_id)
			end,0.1)
			break
		end
	end
end

function SkillData:GetPlayerSkillRemind()
	return self:IsShowSkillRedPoint() and 1 or 0
end

function SkillData:IsShowSkillRedPoint()
	for i = 41, 47 do
		if self:CanSkillUpLevel(i) then
			return true
		end
	end

	return self:CanMieShiSkillUpLevel()
end

function SkillData:CanMieShiSkillUpLevel()
	self.mieshi_skill_level_list = PersonalGoalsData.Instance:GetSkillLevelList()
	local role_prof = GameVoManager.Instance:GetMainRoleVo().prof

	for k, v in pairs(self.mieShi_skill_cfg) do
		local current_level = self.mieshi_skill_level_list[k]
		local level_cfg = v[current_level]
		if nil ~= level_cfg then
			local material_info = level_cfg["uplevel_stuff_prof" .. role_prof]
			if nil ~= material_info and ItemData.Instance:GetItemNumInBagById(material_info.item_id) >= material_info.num then
				return true
			end
		end
	end

	return false
end

function SkillData:CanSkillUpLevel(skill_id)
	local skill_info = self:GetSkillInfoById(skill_id)
	local skill_level = skill_info and skill_info.level or 0
	local skill_cfg = SkillData.GetSkillConfigByIdLevel(skill_id, skill_level + 1)

	return nil ~= skill_cfg
		and PlayerData.Instance:GetAttr("level") >= skill_cfg.learn_level_limit
		and skill_cfg.item_cost <= ItemData.Instance:GetItemNumInBagById(skill_cfg.item_cost_id)
end

function SkillData.RepleCfgContent(skill_id, level)
	local cfg = SkillData.GetSkillinfoConfig(skill_id)
	local source = cfg and cfg.skill_desc or nil
	local skill_vo = SkillData.GetSkillConfigByIdLevel(skill_id, level)
	if not source or not skill_vo then
		return ""
	end
	local len = string.len(source)
	local rule = '%[([^%]]-)%]%%'
	local key = ""
	local rep = ""

	local var = 1
	while var <= len do
		var = var + 1
		local i, j = string.find(source, rule)
		if i and i < var then
			var = j
			key = string.sub(source, i + 1, j - 2)
			rep = skill_vo[key] / 100
			source = string.gsub(source, '%[' .. key .. '%]%%', rep .. "%%")
		end
	end
	len = string.len(source)
	rule = '%[(.-)%]'
	var = 1
	while var <= len do
		var = var + 1
		local i, j = string.find(source, rule)
		if i and i < var then
		  var = j
		  key = string.sub(source, i + 1, j -1)
		  rep = skill_vo[key]
		  source = string.gsub(source, '%[' .. key .. '%]', rep)
		end
	end
	len = string.len(source)
	rule = '%((.-)%)%%'
	var = 1
	while var <= len do
		var = var + 1
		local i, j = string.find(source, rule)
		if i and i < var then
		  var = j
		  key = string.sub(source, i + 1, j - 2)
		  rep = skill_vo[key] / 1000
		  source = string.gsub(source, '%(' .. key .. '%)%%', rep)
		end
	end
	return source
end

function SkillData:GetPassvieSkillCanUpLevelIndexList(skill_list)
	local list = {}

	for k, v in pairs(skill_list) do
		if self:CanSkillUpLevel(v.skill_id) then
			table.insert(list, k)
		end
	end

	return list
end

-- 客户端记录角色技能增加的熟练度
function SkillData:RecordSkillProficiency(skill_id)
	if nil ~= self.skill_list[skill_id] then
		self.skill_list[skill_id].exp = self.skill_list[skill_id].exp + 1
	end
end

function SkillData:GetSkillProficiency(skill_id)
	if nil ~= self.skill_list[skill_id] then
		return self.skill_list[skill_id].exp
	end
	return 0
end

-- 得到技能施放距离
function SkillData:GetSkillDistance(skill_id)
	local distance = 0
	local skill_info = self:GetSkillInfoById(skill_id)
	if skill_info then
		local cfg = SkillData.GetSkillConfigByIdLevel(skill_info.skill_id, skill_info.level)
		if cfg then
			distance = cfg.distance or 0
		end
	end

	return distance
end