------------------------------------------------------
module(..., package.seeall)

local require = require

local BASE = require("logic/entity/i3k_hero").i3k_hero
require("logic/entity/i3k_entity")
local BASEENTITY = i3k_entity
------------------------------------------------------
i3k_spy_life = i3k_class("i3k_spy_life", BASE);

function i3k_spy_life:ctor(guid)
	self._entityType	= eET_Player
	self._birthPos		= Engine.SVector3(0, 0, 0);
	self._timetick		= 0;
	self._deadTimeLine	= -1;
	self._inSpyStory = true;
	self._bindSkills = { };
	local guids = string.split(self._guid, "@");
	self._realGUID		= guids[2];
end

function i3k_spy_life:Create(camp, id)
	local cfgID = math.abs(id)
	local cfg = i3k_db_spy_story_generals[camp][id];
	local name = g_i3k_game_context:GetRoleName()
	
	if not cfg then
		return false;
	end
	
	self._fashion = nil;
	self._needUpdateProperty = false; -- 是否刷新角色属性 
	local skills = { }
	cfg.modelID =  g_i3k_db.i3k_db_get_spy_story_modelID(g_i3k_game_context:GetRoleGender(), cfg)
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
	
	return self:CreateFromCfg(id, name, cfg, 1, skills, true, false)
end

function i3k_spy_life:CreateTitle(reset)
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

function i3k_spy_life:InitSkills(resetBinds)
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
	self._ultraSkill = nil;
	self._dodgeSkill = nil;
	self._DIYSkill	= nil;

	self._seq_skill = { valid = false, parent = nil, skill = nil };

	self._attackID	= -1; -- 攻击序列索引
	self._attackLst = { }; -- 攻击序列

	local cfg = self._cfg;
	if cfg then
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
		
		if cfg.dodgeSkill then
			local scfg = i3k_db_skills[cfg.dodgeSkill];
			if scfg then
				local skill = require("logic/battle/i3k_skill");
				if skill then
					self._dodgeSkill = skill.i3k_skill_create(self, scfg, 1, 0, skill.eSG_Skill, changeTick);
					
					if cooltimes[cfg.dodgeSkill] then
						self._dodgeSkill:CalculationCoolTime(cooltimes[cfg.dodgeSkill]);
					end
					
					--self._dodgeSkill:ChangeSkillTick(eCfg.args[1])
				end
			end
		end
		
		self:InitPlayerAttackList()
		
	end
	
	if resetBinds then
		self._bindSkills = { };
	end
end

function i3k_spy_life:OnInitBaseProperty(props)
	local properties = BASE.OnInitBaseProperty(self, props);
	local temProperties = {}
	return properties;	
end

function i3k_spy_life:CanRelease()
	return false;
end

function i3k_spy_life:InitPlayerAttackList()
	if self:IsPlayer() then
		self._attackLst = { }
		local normalskill = {}
		local heroUseSkills = g_i3k_game_context:getSpyStorySkills()
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

function i3k_spy_life:ClearAutofightTriggerSkill() --继承于hero
	
end

function i3k_spy_life:AddAutofightTriggerSkill() 
	
end

function i3k_spy_life:UpdateFightSp(curFightSP, byBuff)

end

function i3k_spy_life:GetGUID()
	return self._realGUID;
end

function i3k_spy_life:SetTitleVisiable(vis)
	if self._title and self._title.node then
		self._title.node:SetVisible(vis);
	end
end

function i3k_spy_life:ClearFightTime() -- 继承重写 为了屏蔽title
	-- self._fighttime = 0
	
	-- if not g_i3k_game_context:getdesertBattleViewEntity() then
		
	-- 	local world = i3k_game_get_world()
	
	-- 	if world then
	-- 		world:ResetTitleShow();
	-- 	end
	-- end
end
