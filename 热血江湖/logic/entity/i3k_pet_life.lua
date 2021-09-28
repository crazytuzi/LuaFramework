------------------------------------------------------
module(..., package.seeall)

local require = require

local BASE = require("logic/entity/i3k_hero").i3k_hero
require("logic/entity/i3k_entity")
local BASEENTITY = i3k_entity
------------------------------------------------------
i3k_pet_life = i3k_class("i3k_pet_life", BASE);
function i3k_pet_life:ctor(guid)
	self._entityType	= eET_Player
	self._birthPos		= Engine.SVector3(0, 0, 0);
	self._timetick		= 0;
	self._deadTimeLine	= -1;
	self._inPetLife 	= true;
	self._bindSkills = { };

	local guids = string.split(self._guid, "@");
	self._realGUID		= guids[2];
end

function i3k_pet_life:Create(id, level)
	local cfgID = math.abs(id)
	local cfg = i3k_db_mercenaries[cfgID];
	if not cfg then
		return false;
	end
	
	self._fashion = nil;
	self._needUpdateProperty = false; -- 是否刷新角色属性 
	local skills = { }
	if cfg.skills then
		for k, v in pairs(cfg.skills) do
			if v ~= -1 then
				skills[v] = { id = v, lvl = 1};
			end
		end
		if cfg.ultraSkill then
			skills[cfg.ultraSkill] = { id = cfg.ultraSkill, lvl = 1};
		end
	end
	
	local isAwake = g_i3k_game_context:getPetIsWaken(id) and g_i3k_game_context:getPetWakenUse(id)
	local name = cfg.name
	
	if i3k_game_get_map_type() == g_PET_ACTIVITY_DUNGEON then
		name = g_i3k_game_context:GetRoleName()
	end

	return self:CreateFromCfg(id, name, cfg, level, skills, true, false, isAwake)
end

function i3k_pet_life:CreateTitle(reset)
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
		title.name	= title.node:AddTextLable(-0.5, 1, -0.5, 0.5, tonumber("0xffffffff", 16), self._name);
	else
		title.node = nil;
	end

	return title;
end

function i3k_pet_life:InitSkills(resetBinds)
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

		-- init skills
		if self._validSkills then
			for k, v in pairs(self._validSkills) do
				local vsl = v;
				if vsl then
					local lvl	= vsl.lvl;
					local valid = (lvl ~= nil and lvl > 0);
					
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
		
		self:InitPlayerAttackList()
		
	end
	
	if resetBinds then
		self._bindSkills = { };
	end
end

function i3k_pet_life:OnInitBaseProperty(props)
	local properties = BASE.OnInitBaseProperty(self, props);

	local _lvl = self._lvl - 1
	local allData,PlayData,OtherData = g_i3k_game_context:GetYongbingData()
	local upstarCfg = i3k_db_suicong_upstar[self._id]
	local starlvl = allData[self._id].starlvl
	local xinfaIncrease = upstarCfg[starlvl].xinfaIncrease
	local weaponIncrease = upstarCfg[starlvl].weaponIncrease
	local Increase = upstarCfg[starlvl].hurtIncrease
	local Decrease = upstarCfg[starlvl].hurtAvoid
	
	local data = g_i3k_game_context:GetPetAttributeValue(self._id, self._lvl)
	local spirits = g_i3k_game_context:getPetSpiritsData(self._id)
	local temproperty = {}
	
	for i, e in pairs(data) do
		if i <= 7 then
			for _,v in ipairs(spirits) do
				if v.id ~= 0 then
					local proID, value = g_i3k_game_context:GetMercenarySpirits(self._id, v.id, v.level, 1)
					if proID and e.proID and proID == e.proID and e.proID == ePropID_maxHP then
						e.value = e.value + value
					end
				end
			end
			
			temproperty[e.proID] = e.value			
		end
	end
	
	--计算宠物试炼属性
	local petEquip = g_i3k_game_context:GetPetEquipProps(self._id)
	
	for	k, v in pairs(petEquip) do
		temproperty[k] = (temproperty[k] or 0) + v
	end
		
	for k, v in pairs(temproperty) do
		properties[k]:Set(v, ePropType_Base);
	end
		
	for i,v in ipairs(allData[self._id].breakSkill) do 
		local skilllvl = allData[self._id].breakSkill[i]
		if skilllvl >0 then
			local skill = i3k_db_suicong_breakdata[i][skilllvl]
			if skill.skillType == 1 then
				Increase = Increase + skill.increaseCount
			elseif skill.skillType == 2 then
				Decrease = Decrease + skill.increaseCount
			elseif skill.skillType == 3 then
				xinfaIncrease = xinfaIncrease + skill.increaseCount
			elseif skill.skillType == 4 then
				weaponIncrease = weaponIncrease + skill.increaseCount
			end
		end
	end
	
	local hero = i3k_game_get_player_hero()
	local all_atkC = hero:GetPropertyValue(ePropID_atkC) * (self._cfg.atkCOrg + xinfaIncrease);
	local all_defC = hero:GetPropertyValue(ePropID_defC) * (self._cfg.atkCOrg + xinfaIncrease);
	local all_atkW = hero:GetPropertyValue(ePropID_atkW) * (self._cfg.atkWOrg + weaponIncrease);
	local all_defW = hero:GetPropertyValue(ePropID_defW) * (self._cfg.atkWOrg + weaponIncrease);
	
	properties[ePropID_atkC]:Set(all_atkC, ePropType_Base);
	properties[ePropID_defC]:Set(all_defC, ePropType_Base);
	properties[ePropID_atkW]:Set(all_atkW, ePropType_Base);
	properties[ePropID_defW]:Set(all_defW, ePropType_Base);
	properties[ePropID_mercenarydmgTo]:Set(Increase, ePropType_Base);
	
	return properties;	
end

function i3k_pet_life:CanRelease()
	return false;
end

function i3k_pet_life:InitPlayerAttackList()
	if self:IsPlayer() then
		self._attackLst = { }
		local normalskill = {}
		local heroUseSkills = g_i3k_game_context:GetPetLifeSkills()
		for k, v in pairs(heroUseSkills) do
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

function i3k_pet_life:ClearAutofightTriggerSkill() --继承于hero
	
end

function i3k_pet_life:AddAutofightTriggerSkill() 
	
end

function i3k_pet_life:UpdateFightSp(curFightSP, byBuff)

end

function i3k_pet_life:GetGUID()
	return self._realGUID;
end
