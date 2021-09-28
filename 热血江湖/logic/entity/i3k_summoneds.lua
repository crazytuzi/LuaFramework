------------------------------------------------------
module(..., package.seeall)

local require = require

local BASE =
	require("logic/entity/i3k_mercenary").i3k_mercenary;


------------------------------------------------------
i3k_summoneds = i3k_class("i3k_summoneds", BASE);
function i3k_summoneds:ctor(guid)
	self._isBoss		= false;
	self._taskHoster	= nil;
	self._entityType	= eET_Summoned;
end

function i3k_summoneds:Create(hosterSkills , level, slevel, agent, summonedId)
	local summonedId = summonedId or self:getBestId(hosterSkills);
	if not summonedId then
		return false;
	end
	local cfg = i3k_db_summoned[summonedId];

	if not cfg then
		return false;
	end

	self.id = id
	self._cfg = cfg;
	self._lvl = level
	self._aliveTick		= 0;
	self._aliveDuration	= cfg.duration;
	self._subType = cfg.subType --子标签 1是符灵卫 2是金箍棒的分身
	local skills = { };
	if cfg.skills then
		for k, v in ipairs(cfg.skills) do
			skills[v] = { id = v, lvl = slevel[k] or 0 };
		end
	end
	return self:CreateFromCfg(id, cfg.name, cfg, level, skills, agent);
end

function i3k_summoneds:getBestId(hosterSkills)
	local summonedId = nil;
	for k, v in pairs(hosterSkills) do
		if v._cfg.summonedId and v._cfg.summonedId > 0 then
			if summonedId then 
				if v._cfg.summonedId > summonedId  then
					summonedId = v._cfg.summonedId
				end
			else
				summonedId = v._cfg.summonedId
			end
		end
	end
	return summonedId;
end

function i3k_summoneds:CreateTitle()
	local _T = require("logic/entity/i3k_entity_title");

	local title = { };

	title.node = _T.i3k_entity_title.new();
	if title.node:Create("summoned_title_node_" .. self._guid) then
		title.name	= title.node:AddTextLable(-0.5, 1, -0.5, 0.5, tonumber("0xffffffff", 16), self._name);
		title.bbar	= title.node:AddBloodBar(-0.5, 1, 0.5, 0.25 * 0.5);
	else
		title.node = nil;
	end

	return title;
end

function i3k_summoneds:InitProperties()
	-- 基础属性
	local properties = i3k_entity.InitProperties(self);
	self:UpdateSummonedProp(properties);
	return properties;
end

function i3k_summoneds:OnInitBaseProperty(props)
	local id	= self._id;
	local lvl	= self._lvl;
	local cfg	= self._cfg;

	-- 基础属性
	local properties = i3k_entity.OnInitBaseProperty(self, props);

	-- add new property
	properties[ePropID_maxHP]		= i3k_entity_property.new(self, ePropID_maxHP,			0);
	properties[ePropID_atkN]		= i3k_entity_property.new(self, ePropID_atkN,			0);
	properties[ePropID_defN]		= i3k_entity_property.new(self, ePropID_defN,			0);
	properties[ePropID_atr]			= i3k_entity_property.new(self, ePropID_atr,			0);
	properties[ePropID_ctr]			= i3k_entity_property.new(self, ePropID_ctr,			0);
	properties[ePropID_acrN]		= i3k_entity_property.new(self, ePropID_acrN,			0);
	properties[ePropID_defA]		= i3k_entity_property.new(self, ePropID_defA,			0);
	properties[ePropID_tou]			= i3k_entity_property.new(self, ePropID_tou,			0);
	properties[ePropID_atkA]		= i3k_entity_property.new(self, ePropID_atkA,			1);
	properties[ePropID_defA]		= i3k_entity_property.new(self, ePropID_defA,			1);
	properties[ePropID_deflect]		= i3k_entity_property.new(self, ePropID_deflect,		1);
	properties[ePropID_atkD]		= i3k_entity_property.new(self, ePropID_atkD,			1);
	properties[ePropID_atkH]		= i3k_entity_property.new(self, ePropID_atkH,			0);
	properties[ePropID_atkC]		= i3k_entity_property.new(self, ePropID_atkC,			0);
	properties[ePropID_defC]		= i3k_entity_property.new(self, ePropID_defC,			0);
	properties[ePropID_atkW]		= i3k_entity_property.new(self, ePropID_atkW,			0);
	properties[ePropID_defW]		= i3k_entity_property.new(self, ePropID_defW,			0);
	properties[ePropID_masterC]		= i3k_entity_property.new(self, ePropID_masterC,		0);
	properties[ePropID_masterW]		= i3k_entity_property.new(self, ePropID_masterW,		0);
	properties[ePropID_healA]		= i3k_entity_property.new(self, ePropID_healA,			0);
	properties[ePropID_sbd]			= i3k_entity_property.new(self, ePropID_sbd,			0);
	properties[ePropID_shell]		= i3k_entity_property.new(self, ePropID_shell,			0);
	properties[ePropID_dmgToH]		= i3k_entity_property.new(self, ePropID_dmgToH,			1);
	properties[ePropID_dmgToB]		= i3k_entity_property.new(self, ePropID_dmgToB,			1);
	properties[ePropID_dmgToD]		= i3k_entity_property.new(self, ePropID_dmgToD,			1);
	properties[ePropID_dmgToA]		= i3k_entity_property.new(self, ePropID_dmgToA,			1);
	properties[ePropID_dmgToO]		= i3k_entity_property.new(self, ePropID_dmgToO,			1);
	properties[ePropID_dmgByH]		= i3k_entity_property.new(self, ePropID_dmgByH,			1);
	properties[ePropID_dmgByB]		= i3k_entity_property.new(self, ePropID_dmgByB,			1);
	properties[ePropID_dmgByD]		= i3k_entity_property.new(self, ePropID_dmgByD,			1);
	properties[ePropID_dmgByA]		= i3k_entity_property.new(self, ePropID_dmgByA,			1);
	properties[ePropID_dmgByO]		= i3k_entity_property.new(self, ePropID_dmgByO,			1);
	properties[ePropID_res1]		= i3k_entity_property.new(self, ePropID_res1,			1);
	properties[ePropID_res2]		= i3k_entity_property.new(self, ePropID_res2,			1);
	properties[ePropID_res3]		= i3k_entity_property.new(self, ePropID_res3,			1);
	properties[ePropID_res4]		= i3k_entity_property.new(self, ePropID_res4,			1);
	properties[ePropID_res5]		= i3k_entity_property.new(self, ePropID_res5,			1);
	properties[ePropID_alertRange] 	= i3k_entity_property.new(self, ePropID_alertRange,		0);
	properties[ePropID_maxSP]		= i3k_entity_property.new(self, ePropID_maxSP,			0);
	properties[ePropID_sp]			= i3k_entity_property.new(self, ePropID_sp,				0);
	properties[ePropID_attackUp]		= i3k_entity_property.new(self, ePropID_hero, 1);
	properties[ePropID_mercenarydmgTo]	= i3k_entity_property.new(self, ePropID_mercenarydmgTo,		1);
	properties[ePropID_mercenarydmgBy]	= i3k_entity_property.new(self, ePropID_mercenarydmgBy,		1);
	properties[ePropID_internalForces]	= i3k_entity_property.new(self, ePropID_internalForces,		0);
	properties[ePropID_dex]			= i3k_entity_property.new(self, ePropID_dex,		0);

	local speed			= 0;
	local all_sp		= i3k_db_common.general.maxEnergy;
	local alertRange	= i3k_db_common.general.alertRange;

	if cfg then
		speed		= cfg.speed;
		alertRange	= cfg.checkRange;
	end

	-- update all properties
	properties[ePropID_lvl			]:Set(lvl,		ePropType_Base);
	properties[ePropID_maxHP		]:Set(0,		ePropType_Base);
	properties[ePropID_atkN			]:Set(0,		ePropType_Base);
	properties[ePropID_defN			]:Set(0,		ePropType_Base);
	properties[ePropID_atr			]:Set(0,		ePropType_Base);
	properties[ePropID_ctr			]:Set(0,		ePropType_Base);
	properties[ePropID_acrN			]:Set(0,		ePropType_Base);
	properties[ePropID_tou			]:Set(0,		ePropType_Base);
	properties[ePropID_atkA			]:Set(0,		ePropType_Base);
	properties[ePropID_defA			]:Set(0,		ePropType_Base);
	properties[ePropID_deflect		]:Set(0,		ePropType_Base);
	properties[ePropID_atkD			]:Set(0,		ePropType_Base);
	properties[ePropID_atkH			]:Set(0,		ePropType_Base);
	properties[ePropID_atkC			]:Set(0,		ePropType_Base);
	properties[ePropID_defC			]:Set(0,		ePropType_Base);
	properties[ePropID_atkW			]:Set(0,		ePropType_Base);
	properties[ePropID_defW			]:Set(0,		ePropType_Base);
	properties[ePropID_masterC		]:Set(0,		ePropType_Base);
	properties[ePropID_masterW		]:Set(0,		ePropType_Base);
	properties[ePropID_healA		]:Set(0,		ePropType_Base);
	properties[ePropID_sbd			]:Set(0,		ePropType_Base);
	properties[ePropID_shell		]:Set(0,		ePropType_Base);
	properties[ePropID_dmgToH		]:Set(0,		ePropType_Base);
	properties[ePropID_dmgToB		]:Set(0,		ePropType_Base);
	properties[ePropID_dmgToD		]:Set(0,		ePropType_Base);
	properties[ePropID_dmgToA		]:Set(0,		ePropType_Base);
	properties[ePropID_dmgToO		]:Set(0,		ePropType_Base);
	properties[ePropID_dmgByH		]:Set(0,		ePropType_Base);
	properties[ePropID_dmgByB		]:Set(0,		ePropType_Base);
	properties[ePropID_dmgByD		]:Set(0,		ePropType_Base);
	properties[ePropID_dmgByA		]:Set(0,		ePropType_Base);
	properties[ePropID_dmgByO		]:Set(0,		ePropType_Base);
	properties[ePropID_res1			]:Set(0,		ePropType_Base);
	properties[ePropID_res2			]:Set(0,		ePropType_Base);
	properties[ePropID_res3			]:Set(0,		ePropType_Base);
	properties[ePropID_res4			]:Set(0,		ePropType_Base);
	properties[ePropID_res5			]:Set(0,		ePropType_Base);
	properties[ePropID_speed		]:Set(speed,		ePropType_Base);
	properties[ePropID_alertRange	]:Set(alertRange,	ePropType_Base);
	properties[ePropID_maxSP		]:Set(all_sp,		ePropType_Base);
	properties[ePropID_sp			]:Set(0,			ePropType_Base);
	properties[ePropID_mercenarydmgTo	]:Set(0,		ePropType_Base);
	properties[ePropID_mercenarydmgBy	]:Set(0,		ePropType_Base);
	properties[ePropID_internalForces	]:Set(0,		ePropType_Base);
	properties[ePropID_dex	]:Set(0,		ePropType_Base);
	properties[ePropID_attackUp			]:Set(0,		ePropType_Base);
		


	return properties;
end

function i3k_summoneds:Bind(hero)
	self._hoster = hero;
	self:UpdateSummonedProp();
	self._hp = self:GetPropertyValue(ePropID_maxHP);
end

function i3k_summoneds:UpdateSummonedProp(props)
	local _props = props or self._properties;
	for k, v in pairs(self:GetPropData()) do
		local prop = _props[k];
		if prop then
			prop:Set(v, ePropType_Base, false, ePropChangeType_Base);
		end
	end
end

function i3k_summoneds:GetPropData()
	local props = {}
	if self._hoster then
		if self._subType == e_TYPE_FULINGWEI then
			for i, e in pairs(i3k_db_prop_id) do
				if e.isInherit ~= 0 then
					local hosterPropValue = self._hoster:GetPropertyValue(i);
					if self._hoster._skills then
						for k, v in pairs(self._hoster._skills) do
							if v._cfg.summonedId and v._cfg.summonedId > 0 then
								props[i] = props[i] and props[i] + hosterPropValue * (v._data.inheritRatio / 10000) or hosterPropValue * (v._data.inheritRatio / 10000);
							end
						end
					end
				end
			end
			for k, v in pairs(self._hoster._skills) do
				if v._cfg.summonedId and v._cfg.summonedId > 0 then
					if v._data.summonedPopId and v._data.summonedPopId > 0 then
						props[v._data.summonedPopId] = props[v._data.summonedPopId] and props[v._data.summonedPopId] + v._data.summonedSkill[1]  or v._data.summonedSkill[1];
					end
				end
			end
		elseif self._subType == e_TYPE_WEAPON_CLONE then
			local inheritRatio = g_i3k_game_context:GetWeaponCloneBodyInheritRatio()
			for i, e in pairs(i3k_db_prop_id) do
				if e.isInherit ~= 0 then
					local hosterPropValue = self._hoster:GetPropertyValue(i);
					props[i] = props[i] and props[i] + hosterPropValue * (inheritRatio / 10000) or hosterPropValue * (inheritRatio / 10000);
				end
			end
		end
		for _, e in ipairs(self._cfg.propTb) do
			if e.propID ~= 0 then
				props[e.propID] = props[e.propID] and props[e.propID] + e.propValue or e.propValue
			end
		end
	end

	return props
end

function i3k_summoneds:BindTaskHoster(entity)
	self._taskHoster = entity
end

function i3k_summoneds:GetAliveTick()
	return self._aliveTick;
end

function i3k_summoneds:GetAliveDuration()
	return self._aliveDuration;
end

function i3k_summoneds:OnSelected(val)
	BASE.OnSelected(self, val);
	if self:GetEntityType() == eET_Pet then
		if val == false then
			g_i3k_game_context:OnCancelSelectHandler()
			return;
		end
		local maxhp = self:GetPropertyValue(ePropID_maxHP)
		local curhp = self:GetPropertyValue(ePropID_hp)
		local buffs = {}
		for k,v in pairs (self._buffs) do
			buffs[v._id] = v._endTime-v._timeLine
		end
		g_i3k_game_context:OnSelectPetHandler(self.id, curhp, maxhp, buffs)
	end
end

function i3k_summoneds:GetFollowTarget()
	if self._taskHoster then
		if i3k_vec3_dist(self._curPos, self._hoster._curPos) > 500 then
			return nil
		end
		return self._taskHoster
	end

	local target = BASE.GetFollowTarget(self);
	if target then
		return target;
	end

	return nil;
end

function i3k_summoneds:OnLogic(dTick)
	BASE.OnLogic(self, dTick);

	self._aliveTick = self._aliveTick + dTick * i3k_engine_get_tick_step();

	return true;
end

function i3k_summoneds:CanRelease()
	return true;
end
