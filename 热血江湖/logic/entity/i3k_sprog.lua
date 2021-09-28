------------------------------------------------------
module(..., package.seeall)

local require = require

local BASE = require("logic/entity/i3k_hero").i3k_hero
require("logic/entity/i3k_entity")
local BASEENTITY = i3k_entity
------------------------------------------------------
i3k_sprog = i3k_class("i3k_sprog", BASE);
function i3k_sprog:ctor(guid)
	self._entityType	= eET_Player
	self._birthPos		= Engine.SVector3(0, 0, 0);
	self._inSprog 	= true;

	local guids = string.split(self._guid, "@");
	self._realGUID		= guids[2];
end

function i3k_sprog:Create(id, level, gender)
	local cfg = i3k_db_new_player_guide_init[id];
	if not cfg then
		return false;
	end
	self._fashion = g_i3k_db.i3k_db_get_general_fashion(id, gender or 1);
	self._fashionInfo
					= { };
	self._skineffectInfo		= { };
	self._gender	= gender or 1
	local h = g_i3k_db.i3k_db_get_general_fashion_hair_res(self._fashion);
	local f = g_i3k_db.i3k_db_get_general_fashion_face_res(self._fashion);
	self._hair = h[1].id;
	self._face		= f[1].id;
	self._bwType	= BWType or 0;


	self._needUpdateProperty = false; -- 不刷新角色属性
	local skills = { }
	if cfg.skills then
		for i, e in ipairs(cfg.skills) do
			skills[e] = { id = e, lvl = cfg.skillsLvl[i]};
		end
	end
	local roleName = g_i3k_game_context:GetRoleName()
	return self:CreateFromCfg(id, roleName, cfg, level, skills, true, fromType)
end

function i3k_sprog:CreateTitle(reset)
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
		title.name	= title.node:AddTextLable(-0.5, 1, 0, 0.5, tonumber("0xffffffff", 16), self._name);
	else
		title.node = nil;
	end

	return title;
end

function i3k_sprog:InitSkills(resetBinds)
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
	if self._dodgeSkill then
		if not self._dodgeSkill:CanUse() then
			cooltimes[self._dodgeSkill._id] = self._dodgeSkill._coolTick
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

	local cfg = self._cfg; -- 是这个东西 local cfg = i3k_db_new_player_guide_init[id];
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
		if cfg.dodgeSkill then -- init dodgeSkill
			local scfg = i3k_db_skills[cfg.dodgeSkill];
			if scfg then
				local skill = require("logic/battle/i3k_skill");
				if skill then
					self._dodgeSkill = skill.i3k_skill_create(self, scfg, 1, 0, skill.eSG_Skill);
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

function i3k_sprog:OnInitBaseProperty(props)
	local properties = BASE.OnInitBaseProperty(self, props);

	local all_hp		= 0;
	local all_atkN		= 0;
	local all_defN		= 0;
	local all_atr		= 0;
	local all_ctr		= 0;
	local all_acrN		= 0;
	local all_tou		= 0;
	local all_atkA		= 0;

	local cfg = self._cfg
	local _lvl = self._lvl - 1

	all_hp		= all_hp		+ cfg.hpOrg		+ cfg.hpInc1		* _lvl * _lvl + cfg.hpInc2		* _lvl;
	all_atkN	= all_atkN		+ cfg.atkNOrg	+ cfg.atkNInc1		* _lvl * _lvl + cfg.atkNInc2	* _lvl;
	all_defN	= all_defN		+ cfg.defNOrg	+ cfg.defNInc1		* _lvl * _lvl + cfg.defNInc2	* _lvl;
	all_atr		= all_atr		+ cfg.atrOrg	+ cfg.atrInc1		* _lvl * _lvl + cfg.atrInc2		* _lvl;
	all_ctr		= all_ctr		+ cfg.ctrOrg	+ cfg.ctrInc1		* _lvl * _lvl + cfg.ctrInc2		* _lvl;
	all_acrN	= all_acrN		+ cfg.acrNOrg	+ cfg.acrNInc1		* _lvl * _lvl + cfg.acrNInc2	* _lvl;
	all_tou		= all_tou		+ cfg.touOrg	+ cfg.touInc1		* _lvl * _lvl + cfg.touInc2		* _lvl;
	all_atkA	= all_atkA		+ cfg.atkAOrg	+ cfg.atkAInc1		* _lvl * _lvl + cfg.atkAInc2	* _lvl;

	properties[ePropID_maxHP			]:Set(all_hp,		ePropType_Base);
	properties[ePropID_atkN				]:Set(all_atkN,		ePropType_Base);
	properties[ePropID_defN				]:Set(all_defN,		ePropType_Base);
	properties[ePropID_atr				]:Set(all_atr,		ePropType_Base);
	properties[ePropID_ctr				]:Set(all_ctr,		ePropType_Base);
	properties[ePropID_acrN				]:Set(all_acrN,		ePropType_Base);
	properties[ePropID_tou				]:Set(all_tou,		ePropType_Base);
	properties[ePropID_atkA				]:Set(all_atkA,		ePropType_Base);

	return properties;
end

function i3k_sprog:CanRelease()
	return false;
end

function i3k_sprog:Release()

	if self._skills then
		for k, v in pairs(self._skills) do
			v:OnReset();
		end
	end
	
	if self._attacks then
		for k, v in pairs(self._attacks) do
			v:OnReset();
		end
	end

	if self._dodgeSkill then
		self._dodgeSkill:OnReset();
	end
	
	BASE.Release(self);
	
end

function i3k_sprog:ClearAutofightTriggerSkill() --继承于hero

end

function i3k_sprog:AddAutofightTriggerSkill()

end

function i3k_sprog:UpdateFightSp(curFightSP, byBuff)

end

function i3k_sprog:GetGUID()
	return self._realGUID;
end
