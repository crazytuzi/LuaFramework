------------------------------------------------------
module(..., package.seeall)

local require = require

local BASE = require("logic/entity/i3k_hero").i3k_hero
require("logic/entity/i3k_entity")
local BASEENTITY = i3k_entity
------------------------------------------------------
i3k_biography_career = i3k_class("i3k_biography_career", BASE);

function i3k_biography_career:ctor(guid)
	self._entityType	= eET_Player
	self._birthPos		= Engine.SVector3(0, 0, 0);
	self._timetick		= 0;
	self._deadTimeLine	= -1;
	self._inBiographyCareer = true;
	self._bindSkills = { };
	local guids = string.split(self._guid, "@");
	self._realGUID		= guids[2];
	self._soaringDisplay = {weaponDisplay = 0, footEffect = 0}
end

function i3k_biography_career:Create(id)
	local cfg = i3k_db_generals[math.abs(id)]
	if not cfg then
		return false;
	end
	self._bwType = g_i3k_game_context:GetTransformBWtype()
	self._fashion = g_i3k_db.i3k_db_get_general_fashion(id, g_i3k_game_context:GetRoleGender());
	self._face = self._fashion.faceSkin[1]
	self._hair = self._fashion.hairSkin[1]
	self._needUpdateProperty = false; -- 是否刷新角色属性 
	local allSkills = g_i3k_game_context:getBiographyCareerSkills()
	local skills = {}
	if allSkills and allSkills[id] then
		local level = i3k_db_wzClassLand[math.abs(id)].skillLevel
		for k, v in ipairs(allSkills[id]) do
			skills[v] = {id = v, lvl = level}
		end
	end
	local name = cfg.name
	return self:CreateFromCfg(id, name, cfg, 1, skills, true)
end

function i3k_biography_career:CreateTitle(reset)
	local _T = require("logic/entity/i3k_entity_title");
	if reset then
		if self._title and self._title.node then
			self._title.node:Release();
			self._title.node = nil;
		end
		self._title = nil;
	end
	local title = { };
	title.node = _T.i3k_entity_title.new();
	if title.node:Create("hero_title_node_" .. self._guid) then
		title.bbar	= title.node:AddBloodBar(-0.5, 1, 0.5, 0.25 * 0.5);
		title.name	= title.node:AddTextLable(-0.5, 1, -0.5, 0.5, tonumber("0xffffffff", 16), g_i3k_game_context:GetRoleName());
	else
		title.node = nil;
	end
	return title;
end

function i3k_biography_career:InitSkills(resetBinds)
	local cooltimes = { };
	if self._attacks then
		for k,v in pairs(self._attacks) do
			if not v:CanUse() then
				cooltimes[v._id] = v._coolTick
			end
		end
	end
	if self._skills then
		for k,v in pairs(self._skills) do
			if not v:CanUse() then
				cooltimes[v._id] = v._coolTick
			end
		end
	end
	self._attacks	= { }; -- 普通攻击
	self._attackIdx	= 1; -- 普通攻击索引
	self._skills	= { }; -- 主动技能
	self._ultraSkill= nil;
	self._dodgeSkill= nil;
	self._DIYSkill	= nil;
	self._seq_skill = { valid = false, parent = nil, skill = nil };
	self._attackID	= -1; -- 攻击序列索引
	self._attackLst = { }; -- 攻击序列
	if self._dodgeSkill then
		if not self._dodgeSkill:CanUse() then
			cooltimes[self._dodgeSkill._id] = self._dodgeSkill._coolTick
		end
	end
	local cfg = self._cfg;
	if cfg then
		-- init attacks
		if cfg.attacks then
			for k, v in ipairs(cfg.attacks) do
				local scfg = i3k_db_skills[v];
				if scfg then
					local skill = require("logic/battle/i3k_skill");
					if skill then
						local _skill = skill.i3k_skill_create(self, scfg, 1, 0, skill.eSG_Attack);
						if cooltimes[v] then
							_skill:CalculationCoolTime(cooltimes[v]);
						end
						if _skill then
							table.insert(self._attacks, _skill);
						end
					end
				end
			end
		end
		local allSkills = g_i3k_game_context:getBiographyCareerSkills()
		local skills = {}
		if allSkills and allSkills[self._id] then
			local level = i3k_db_wzClassLand[math.abs(self._id)].skillLevel
			for k, v in ipairs(allSkills[self._id]) do
				skills[v] = {id = v, lvl = level}
			end
		end
		if skills then
			for k, v in pairs(skills) do
				local vsl = v;
				if vsl then
					local lvl = vsl.lvl;
					local valid = (lvl ~= nil and lvl > 0)
					local scfg = i3k_db_skills[v.id];
					if valid and scfg then
						local skill = require("logic/battle/i3k_skill");
						if skill then
							local _skill = skill.i3k_skill_create(self, scfg, lvl, 0, skill.eSG_Skill);
							if cooltimes[v.id] then
								_skill:CalculationCoolTime(cooltimes[v.id]);
							end
							if _skill then
								self._skills[k] = _skill;
							end
						end
					end
				end
			end
		end
		if cfg.dodgeSkill then
			local scfg = i3k_db_skills[cfg.dodgeSkill];
			if scfg then
				local skill = require("logic/battle/i3k_skill");
				if skill then
					self._dodgeSkill = skill.i3k_skill_create(self, scfg, 1, 0, skill.eSG_Skill, changeTick);
					if cooltimes[cfg.dodgeSkill] then
						self._dodgeSkill:CalculationCoolTime(cooltimes[cfg.dodgeSkill]);
					end
				end
			end
		end
		self:InitPlayerAttackList()
	end
	if resetBinds then
		self._bindSkills = { };
	end
end

function i3k_biography_career:OnInitBaseProperty(props)
	local properties = BASE.OnInitBaseProperty(self, props)
	self:updateBiographyProp(properties)
	self:UpdateTalentProps(properties, true)
	self:UpdatePassiveProp(properties)
	self:UpdateCombatTypeProp(properties)
	return properties
end

function i3k_biography_career:CanRelease()
	return false;
end

function i3k_biography_career:InitPlayerAttackList()
	if self:IsPlayer() then
		self._attackLst = { }
		local normalskill = {}
		local heroUseSkills = {}
		for k, v in pairs(self._bindSkills) do
			table.insert(heroUseSkills, v)
		end
		for k, v in ipairs(heroUseSkills) do
			local scfg = i3k_db_skills[v];
			if scfg and scfg.useorder >= 1 then
				local nskill = {order = scfg.useorder,skill = v}
				table.insert(normalskill, nskill);
			end
		end
		if #normalskill > 0 then
			table.sort(normalskill, function(d1, d2)
				return d1.order < d2.order
			end)
		end
		for k,v in ipairs(normalskill) do
			table.insert(self._attackLst, v.skill)
		end
	end
end

function i3k_biography_career:ClearAutofightTriggerSkill()
	
end

function i3k_biography_career:AddAutofightTriggerSkill() 
	
end

function i3k_biography_career:UpdateFightSp(curFightSP, byBuff)

end

function i3k_biography_career:GetGUID()
	return self._realGUID;
end

function i3k_biography_career:updateBiographyCareerProp()
	self:updateBiographyProp()
	self:UpdateTalentProps(nil, false)
	self:UpdatePassiveProp()
	self:UpdateCombatTypeProp()
end

function i3k_biography_career:updateBiographyProp(props)
	local _props = props or self._properties;
	for k, v in pairs(_props) do
		v:Set(0, ePropType_Biography, false, ePropChangeType_Base);
		v:Set(0, ePropType_Biography, false, ePropChangeType_Percent);
	end
	local careerData = g_i3k_game_context:getBiographyCareerInfo()
	if careerData and careerData[self._id] then
		local taskId = careerData[self._id].taskId
		local baseProps = i3k_db_wzClassLand_prop[i3k_db_wzClassLand_task[self._id][taskId].changeClassID].props
		for k, v in ipairs(baseProps) do
			if v.propId ~= 0 then
				local prop = _props[v.propId];
				prop:Set(prop._valueBIO.Base + v.propValue, ePropType_Biography)
			end
		end
		self:OnMaxHpChangedCheck()
	end
end

--重写心法
function i3k_biography_career:UpdateTalentProps(props, updateEffector)
	local _props = props or self._properties;
	for k, v in pairs(_props) do
		v:Set(0, ePropType_Talent,false,ePropChangeType_Base);
		v:Set(0, ePropType_Talent,false,ePropChangeType_Percent);
	end
	if g_i3k_game_context then
		local qigong = g_i3k_game_context:getBiographyCareerQigong()
		if qigong and qigong[self._id] then
			for k, v in ipairs(qigong[self._id]) do
				local props = g_i3k_db.i3k_db_get_talent_props(v, i3k_db_wzClassLand[self._id].xinfaLevel);
				for k1, v1 in pairs(props) do
					local prop = _props[k1];
					if prop then
						prop:Set(prop._valueT.Base + v1 , ePropType_Talent, false, ePropChangeType_Base);
					end
				end
			end
		end
	end
	if updateEffector then
		self:UpdateTalentEffector(_props)
	end
	self:OnMaxHpChangedCheck()
end

function i3k_biography_career:UpdateTalentEffector(props)
	self:ClsTalents()
	self:ResetExtProperty(true)
	local careerData = g_i3k_game_context:getBiographyCareerInfo()
	if careerData and careerData[self._id] then
		local talent = careerData[self._id].equipSpirits
		if talent then
			local level = i3k_db_wzClassLand[self._id].xinfaLevel
			for id, _ in pairs(talent) do
				self:AddTalent(id, level)
			end
		end
		self:UpdateExtProperty(props)
	end
end

function i3k_biography_career:UpdatePassiveProp(props)
	local _props = props or self._properties;
	for k, v in pairs(_props) do
		v:Set(0, ePropType_SkillPassive, false, ePropChangeType_Base);
		v:Set(0, ePropType_SkillPassive, false, ePropChangeType_Percent);
	end
	self:ClsPassivesAi()
	local addPropTb = {}
	local all_skills = g_i3k_game_context:getBiographyCareerSkills()
	local level = i3k_db_wzClassLand[self._id].skillLevel
	local state = i3k_db_wzClassLand[self._id].skillState
	for k, v in ipairs(all_skills) do
		if g_i3k_db.i3k_db_get_skill_type(v) == eSE_PASSIVE then -- 被动技能
			local skillDataCfg = i3k_db_skill_datas[v][level]
			for _, e in ipairs(skillDataCfg.additionalProp) do
				if e.propsCount[state+1] then
					addPropTb[e.propID] = e.propsCount[state + 1]
				end
			end
			for _, n in ipairs(skillDataCfg.additionalAiID) do
				local tgcfgId = n[state + 1]
				if tgcfgId then
					local tgcfg =  i3k_db_ai_trigger[tgcfgId]
					local mgr = self._triMgr
					if mgr then
						local TRI = require("logic/entity/ai/i3k_trigger");
						local tri = TRI.i3k_ai_trigger.new(self);
						if tri:Create(tgcfg,-1,tgcfgId) then
							local tid = mgr:RegTrigger(tri, self);
							if tid >= 0 then
								table.insert(self._passivesTids, tid);
							end
						end
					end
				end
			end
		end
	end
	for k, v in pairs(addPropTb) do
		local prop = _props[k];
		if prop then
			prop:Set(prop._valueSP.Base + v, ePropType_SkillPassive, false, ePropChangeType_Base);
		end
	end
	self:OnMaxHpChangedCheck()
end

--拳师姿态属性影响
function i3k_biography_career:UpdateCombatTypeProp(props)
	local _props  = props or self._properties
	local combatType = self._combatType
	for k, v in pairs(_props) do
		v:Set(0, ePropType_CombatType, false, ePropChangeType_Base)
		v:Set(0, ePropType_CombatType, false, ePropChangeType_Percent);
	end
	if combatType > 0 then
		local data = i3k_db_skill_AddData[g_BOXER_ADDTYPE[combatType]]
		local xinfa1, xinfa2 = self:UpdateCombatTypeByXinfa(combatType, data)
		local prop1 = _props[data.arg1]
		prop1:Set(prop1._valueCBT.Percent + data.arg2 + xinfa1, ePropType_CombatType, false, ePropChangeType_Percent)
		local prop2 = _props[data.arg3]
		prop2:Set(prop2._valueCBT.Percent + data.arg4 + xinfa2, ePropType_CombatType, false, ePropChangeType_Percent)
	end
	self:OnMaxHpChangedCheck()
end

function i3k_biography_career:UpdateCombatTypeByXinfa(combatType, data)
	local addValue1, addValue2 = 0, 0
	local careerData = g_i3k_game_context:getBiographyCareerInfo()
	if careerData and careerData[self._id] then
		local talent = careerData[self._id].equipSpirits
		if talent then
			for id, _ in pairs(talent) do
				local level = i3k_db_wzClassLand[self._id].xinfaLevel
				local tDataList = g_i3k_db.i3k_db_get_talent_effector(id, level)
				for _, xiaoGuoData in ipairs(tDataList) do
					if xiaoGuoData.type == g_XINFA_COMBATTYPE and xiaoGuoData.args.combatTypeID == combatType then
						addValue1 = addValue1 + xiaoGuoData.args.addArg1
						addValue2 = addValue2 + xiaoGuoData.args.addArg2
					end
				end
			end
		end
		return addValue1, addValue2
	end
end

--重写装备特效
function i3k_biography_career:AttachEquipEffect()
	local careerData = g_i3k_game_context:getBiographyCareerInfo()
	if careerData and careerData[self._id] then
		local taskId = careerData[self._id].taskId
		if taskId > 0 then
			local effectids = i3k_db_wzClassLand_prop[i3k_db_wzClassLand_task[self._id][taskId].changeClassID].weaponEffect
			if next(effectids) then
				local effects = {}
				for k, v in ipairs(effectids) do
					effects[v] = true
				end
				self:AttachEquipEffectByPartID(1, effects)
			else
				self:DetachEquipEffectByPartID(1)
			end
		end
	end
end

function i3k_biography_career:changeEquipSkin(partId, equipId)
	self:DetachEquip(partId, false)
	self:AttachEquip(equipId, true)
end
