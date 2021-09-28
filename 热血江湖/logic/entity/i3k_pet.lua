------------------------------------------------------
module(..., package.seeall)

local require = require

local BASE =
	require("logic/entity/i3k_mercenary").i3k_mercenary;


------------------------------------------------------
i3k_pet = i3k_class("i3k_pet", BASE);
function i3k_pet:ctor(guid)
	self._isBoss		= false;
	self._taskHoster	= nil;
	self._entityType	= eET_Pet;
end

function i3k_pet:Create(id , level, slevel, agent)
	local cfg = nil;
	if id > 0 then
		cfg = i3k_db_fightpet[id];
	else
		cfg = i3k_db_missionnpcs[id];
	end

	if not cfg then
		return false;
	end

	self.id = id
	self._cfg = cfg;
	self._lvl = level
	self._aliveTick		= 0;
	self._aliveDuration	= cfg.duration;

	local skills = { };
	if cfg.skills then
		for k, v in ipairs(cfg.skills) do
			skills[v] = { id = v, lvl = slevel[k] or 0 };
		end
	end

	return self:CreateFromCfg(id, cfg.name, cfg, level, skills, agent);
end

function i3k_pet:CreateTitle()
	local _T = require("logic/entity/i3k_entity_title");

	local title = { };

	title.node = _T.i3k_entity_title.new();
	if title.node:Create("pet_title_node_" .. self._guid) then
		title.name	= title.node:AddTextLable(-0.5, 1, -0.5, 0.5, tonumber("0xffffffff", 16), self._name);
		title.bbar	= title.node:AddBloodBar(-0.5, 1, 0.5, 0.25 * 0.5);
	else
		title.node = nil;
	end

	return title;
end

function i3k_pet:InitProperties()
	-- 基础属性
	local properties = i3k_entity.InitProperties(self);

	return properties;
end

function i3k_pet:OnInitBaseProperty(props)
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
	properties[ePropID_maxSP]		= i3k_entity_property.new(self, ePropID_maxSP,			0);
	properties[ePropID_sp]			= i3k_entity_property.new(self, ePropID_sp,				0);
	properties[ePropID_mercenarydmgTo]	= i3k_entity_property.new(self, ePropID_mercenarydmgTo,		1);
	properties[ePropID_mercenarydmgBy]	= i3k_entity_property.new(self, ePropID_mercenarydmgBy,		1);
	properties[ePropID_internalForces]	= i3k_entity_property.new(self, ePropID_internalForces,		0);
	properties[ePropID_dex]			= i3k_entity_property.new(self, ePropID_dex,		0);


	local all_hp		= 0;
	local all_atkN		= 0;
	local all_defN		= 0;
	local all_defA		= 0;
	local all_atr		= 0;
	local all_ctr		= 0;
	local all_acrN		= 0;
	local all_tou		= 0;
	local all_atkA		= 0;
	local all_defA		= 0;
	local all_deflect	= 0;
	local all_atkD		= 0;
	local all_atkH		= 0;
	local all_atkC		= 0;
	local all_defC		= 0;
	local all_atkW		= 0;
	local all_defW		= 0;
	local all_masterC	= 0;
	local all_masterW	= 0;
	local all_healA		= 0;
	local all_sbd		= 0;
	local all_shell		= 0;

	local all_dmgToH	= 0;
	local all_dmgToB	= 0;
	local all_dmgToD	= 0;
	local all_dmgToA	= 0;
	local all_dmgToO	= 0;
	local all_dmgByH	= 0;
	local all_dmgByB	= 0;
	local all_dmgByD	= 0;
	local all_dmgByA	= 0;
	local all_dmgByO	= 0;

	local all_res1		= 0;
	local all_res2		= 0;
	local all_res3		= 0;
	local all_res4		= 0;
	local all_res5		= 0;

	local speed			= 0;
	local all_sp		= i3k_db_common.general.maxEnergy;
	local alertRange	= i3k_db_common.general.alertRange;

	if cfg then
		all_hp		= all_hp		+ cfg.hpOrg[lvl];
		all_atkN	= all_atkN		+ cfg.atkNOrg[lvl];
		all_defN	= all_defN		+ cfg.defNOrg[lvl];
		all_atr		= all_atr		+ cfg.atrOrg[lvl];
		all_ctr		= all_ctr		+ cfg.ctrOrg[lvl];
		all_acrN	= all_acrN		+ cfg.acrNOrg[lvl];
		all_tou		= all_tou		+ cfg.touOrg[lvl];
		all_atkA	= all_atkA		+ cfg.atkAOrg[lvl];
		all_atkH	= all_atkH		+ cfg.atkHOrg[lvl]
		speed		= cfg.speed;
		alertRange	= cfg.checkRange;
	end

	-- update all properties
	properties[ePropID_lvl			]:Set(lvl,			ePropType_Base);
	properties[ePropID_maxHP		]:Set(all_hp,		ePropType_Base);
	properties[ePropID_atkN			]:Set(all_atkN,		ePropType_Base);
	properties[ePropID_defN			]:Set(all_defN,		ePropType_Base);
	properties[ePropID_atr			]:Set(all_atr,		ePropType_Base);
	properties[ePropID_ctr			]:Set(all_ctr,		ePropType_Base);
	properties[ePropID_acrN			]:Set(all_acrN,		ePropType_Base);
	properties[ePropID_tou			]:Set(all_tou,		ePropType_Base);
	properties[ePropID_atkA			]:Set(all_atkA,		ePropType_Base);
	properties[ePropID_defA			]:Set(all_defA,		ePropType_Base);
	properties[ePropID_deflect		]:Set(all_deflect,	ePropType_Base);
	properties[ePropID_atkD			]:Set(all_atkD,		ePropType_Base);
	properties[ePropID_atkH			]:Set(all_atkH,		ePropType_Base);
	properties[ePropID_atkC			]:Set(all_atkC,		ePropType_Base);
	properties[ePropID_defC			]:Set(all_defC,		ePropType_Base);
	properties[ePropID_atkW			]:Set(all_atkW,		ePropType_Base);
	properties[ePropID_defW			]:Set(all_defW,		ePropType_Base);
	properties[ePropID_masterC		]:Set(all_masterC,	ePropType_Base);
	properties[ePropID_masterW		]:Set(all_masterW,	ePropType_Base);
	properties[ePropID_healA		]:Set(all_healA,	ePropType_Base);
	properties[ePropID_sbd			]:Set(all_sbd,		ePropType_Base);
	properties[ePropID_shell		]:Set(all_shell,	ePropType_Base);
	properties[ePropID_dmgToH		]:Set(all_dmgToH,	ePropType_Base);
	properties[ePropID_dmgToB		]:Set(all_dmgToB,	ePropType_Base);
	properties[ePropID_dmgToD		]:Set(all_dmgToD,	ePropType_Base);
	properties[ePropID_dmgToA		]:Set(all_dmgToA,	ePropType_Base);
	properties[ePropID_dmgToO		]:Set(all_dmgToO,	ePropType_Base);
	properties[ePropID_dmgByH		]:Set(all_dmgByH,	ePropType_Base);
	properties[ePropID_dmgByB		]:Set(all_dmgByB,	ePropType_Base);
	properties[ePropID_dmgByD		]:Set(all_dmgByD,	ePropType_Base);
	properties[ePropID_dmgByA		]:Set(all_dmgByA,	ePropType_Base);
	properties[ePropID_dmgByO		]:Set(all_dmgByO,	ePropType_Base);
	properties[ePropID_res1			]:Set(all_res1,		ePropType_Base);
	properties[ePropID_res2			]:Set(all_res2,		ePropType_Base);
	properties[ePropID_res3			]:Set(all_res3,		ePropType_Base);
	properties[ePropID_res4			]:Set(all_res4,		ePropType_Base);
	properties[ePropID_res5			]:Set(all_res5,		ePropType_Base);
	properties[ePropID_speed		]:Set(speed,		ePropType_Base);
	properties[ePropID_alertRange	]:Set(alertRange,	ePropType_Base);
	properties[ePropID_maxSP		]:Set(all_sp,		ePropType_Base);
	properties[ePropID_sp			]:Set(0,			ePropType_Base);
	properties[ePropID_mercenarydmgTo	]:Set(0,		ePropType_Base);
	properties[ePropID_mercenarydmgBy	]:Set(0,		ePropType_Base);
	properties[ePropID_internalForces	]:Set(0,		ePropType_Base);
	properties[ePropID_dex	]:Set(0,		ePropType_Base);
		


	return properties;
end

function i3k_pet:Bind(hero)
	self._hoster = hero;
end

function i3k_pet:BindTaskHoster(entity)
	self._taskHoster = entity
end

function i3k_pet:GetAliveTick()
	return self._aliveTick;
end

function i3k_pet:GetAliveDuration()
	return self._aliveDuration;
end

function i3k_pet:OnSelected(val)
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

function i3k_pet:GetFollowTarget()
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

	-- if #self._enmities > 0 then
	-- 	--i3k_log("GetFollowTarget2")
	-- 	return nil;
	-- end

	-- if not self._hoster or self._hoster:IsDead() then
	-- 	return nil;
	-- end

	-- if self._forceFollow then
	-- 	return self._forceFollow;
	-- end

	-- local dist = i3k_vec3_len(i3k_vec3_sub1(self._curPos, self._hoster._curPos));
	-- local mindist = 500
	-- if self._cfg.followdist2 and self._cfg.followdist3 then
	-- 	mindist = (self._cfg.followdist2 + self._cfg.followdist3)/2
	-- end
	-- if not mindist then
	-- 	mindist = 500
	-- end

	-- if dist > mindist then
	-- 	return self._hoster;
	-- end

	return nil;
end

function i3k_pet:OnLogic(dTick)
	BASE.OnLogic(self, dTick);

	self._aliveTick = self._aliveTick + dTick * i3k_engine_get_tick_step();

	return true;
end

function i3k_pet:OnDamage(attacker, atr,val, cri, stype, showInfo, update, SourceType, direct, buffid)
	if not self._hp then return; end
	
	if stype == eSE_Damage then
		local cout = cri and 2 or 1
		cout = self._guid == attacker._guid and val or cout
		BASE.OnDamage(self, attacker, atr, cout, cri, stype, showInfo, update, SourceType, direct, buffid);
	end
end

function i3k_pet:CanRelease()
	return true;
end
