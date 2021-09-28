------------------------------------------------------
module(..., package.seeall)

local require = require

local BASE =
	require("logic/entity/i3k_hero").i3k_hero;


------------------------------------------------------
i3k_monster_base = i3k_class("i3k_monster_base", BASE);
function i3k_monster_base:ctor(guid)
end

function i3k_monster_base:UpdateEquipProps(props)
end

function i3k_monster_base:UpdateTalentProps(props, updateEffector)
end

function i3k_monster_base:UpdateFightSPProps(props)
end
-- disable
function i3k_monster_base:UpdateWeaponProps()
end

function i3k_monster_base:UpdateFactionSkillProps()
end

------------------------------------------------------
i3k_monster = i3k_class("i3k_monster", i3k_monster_base);
function i3k_monster:ctor(guid)
	self._entityType	= eET_Monster;
	self._isBoss		= false;
	self._birthPos		= Engine.SVector3(0, 0, 0);
	self._buffs		= { };
	self._talentChangeSkill = {}
	self._talentChangeAi = {}
	self._skilldeny = 0;
	self._bwType = 0;
	self._hpDrop = {}
end

function i3k_monster:Create(id, agent)
	local cfg = i3k_db_monsters[id];
	if not cfg then
		return false;
	end
	
	self._baseCfg = cfg
	self._isBoss = cfg.boss ~= 0;
	self._bwType = cfg.camp or 0;
	local skills = { };
	if cfg.skills then
		for k, v in ipairs(cfg.skills) do
			skills[v] = { id = v, lvl = cfg.slevel[k] or 0 };
		end
	end

	for k,v in pairs(cfg.statusList) do
		self._behavior:Set(tonumber(v))
	end
	
	if cfg.hasOutline == 1 then
		self:EnableOutline(true, cfg.outlineColor);
	end

	return self:CreateFromCfg(id, cfg.name, cfg, cfg.level, skills, agent);
end

function i3k_monster:CanRelease()
	return true;
end

function i3k_monster:CreateTitle()
	local _T = require("logic/entity/i3k_entity_title");

	local title = { };

	title.node = _T.i3k_entity_title.new();
	if title.node:Create("monster_title_node_" .. self._guid) then
		--[[title.name	= title.node:AddTextLable(-0.5, 1, 0, 0.5, tonumber("0xffffffff", 16), self._name);
		title.bbar	= title.node:AddBloodBar(-0.5, 1, 0.5, 0.25 * 0.5, true);--]]
		title = self:CreateTitleFromCfg(title)
	else
		title.node = nil;
	end

	return title;
end

function i3k_monster:CreateTitleFromCfg(title)
	local titleMul = {}
	local color = tonumber("0xffffffff", 16)
	local showName = self:GetMonsterShowName()
	if self._baseCfg.typeDesc ~= "" then
		titleMul = {
		[1] = {isText = true, isTypeName = true, x = -0.5, w = 1, y = -0.5, h = 0.5, name = self._cfg.typeDesc},
		[2] = {isText = true, isTypeName = false, x = -0.5, w = 0.2, y = -0.1, h = 0.5, name = showName},
		[3] = {isText = false, x = -0.5, w = 1, y = 0.5, h = 0.125},
		}
	else
		titleMul = {
		[1] = {isText = true, x = -0.5, w = 1, y = -0.5, h = 0.5, name = showName},
		[2] = {isText = false, x = -0.5, w = 1, y = 0.5, h = 0.25 * 0.5}
		}
	end
	title.nameTb = {}
	for i, e in ipairs(titleMul) do
		if e.isText then
			if e.isTypeName then
				title.typeName = title.node:AddTextLable(e.x, e.w, e.y, e.h, color, e.name);
			else
				title.name = title.node:AddTextLable(e.x, e.w, e.y, e.h, color, e.name);
			end
		else
			title.bbar = title.node:AddBloodBar(e.x, e.w, e.y, e.h, true);
		end
	end
	return title
end

function i3k_monster:InitProperties()
	-- 基础属性
	local properties = i3k_entity.InitProperties(self);

	return properties;
end

function i3k_monster:OnInitBaseProperty(props)
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
	properties[ePropID_behealGain]		= i3k_entity_property.new(self, ePropID_behealGain,	1);
	properties[ePropID_internalForces]	= i3k_entity_property.new(self, ePropID_internalForces,		0);
	properties[ePropID_dex]			= i3k_entity_property.new(self, ePropID_dex,		0);
	properties[ePropID_armorMaxValue]	= i3k_entity_property.new(self, ePropID_armorMaxValue, 0);
	properties[ePropID_buffMaster1]		= i3k_entity_property.new(self, ePropID_buffMaster1, 1);
	properties[ePropID_buffMaster2]		= i3k_entity_property.new(self, ePropID_buffMaster2, 1);
	properties[ePropID_buffMaster3]		= i3k_entity_property.new(self, ePropID_buffMaster3, 1);
	properties[ePropID_attackUp]		= i3k_entity_property.new(self, ePropID_hero, 1);
	properties[ePropID_WindDamage]	= i3k_entity_property.new(self, ePropID_WindDamage, 0);
	properties[ePropID_WindDefence]	= i3k_entity_property.new(self, ePropID_WindDefence, 0);
	properties[ePropID_FireDamage]	= i3k_entity_property.new(self, ePropID_FireDamage, 0);
	properties[ePropID_FireDefence]	= i3k_entity_property.new(self, ePropID_FireDefence, 0);
	properties[ePropID_SoilDamage]	= i3k_entity_property.new(self, ePropID_SoilDamage, 0);
	properties[ePropID_SoilDefence]	= i3k_entity_property.new(self, ePropID_SoilDefence, 0);
	properties[ePropID_WoodDamage]	= i3k_entity_property.new(self, ePropID_WoodDamage, 0);
	properties[ePropID_WoodDefence]	= i3k_entity_property.new(self, ePropID_WoodDefence, 0);
	properties[ePropID_DexMaster]	= i3k_entity_property.new(self, ePropID_DexMaster, 1);
	properties[ePropID_CampMaster]	= i3k_entity_property.new(self, ePropID_CampMaster, 0);
	properties[ePropID_OutATK]		= i3k_entity_property.new(self, ePropID_OutATK, 1);
	properties[ePropID_WithinATK]	= i3k_entity_property.new(self, ePropID_WithinATK, 1);
	properties[ePropID_ElementATK]	= i3k_entity_property.new(self, ePropID_ElementATK, 1);
	properties[ePropID_SteedFightDamage]	= i3k_entity_property.new(self, ePropID_SteedFightDamage, 0);
	properties[ePropID_SteedFightDefend]	= i3k_entity_property.new(self, ePropID_SteedFightDefend, 0);

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
	local armorValue	= 0;
	local outATK		= 0;
	local withinATK		= 0;
	local elementATK	= 0;

	local all_windDamage		= 0;
	local all_windDefence		= 0;
	local all_fireDamage		= 0;
	local all_fireDefence		= 0;
	local all_soilDamage		= 0;
	local all_soilDefence		= 0;
	local all_woodDamage		= 0;
	local all_woodDefence		= 0;
	local all_steedFightDamage	= 0;
	local all_steedFightDefend	= 0;
	local all_internalForces	= 0;
	local all_dex				= 0;

	if cfg then
		all_hp		= all_hp		+ cfg.hpOrg;
		all_atkN	= all_atkN		+ cfg.atkNOrg;
		all_defN	= all_defN		+ cfg.defNOrg;
		all_atr		= all_atr		+ cfg.atrOrg;
		all_ctr		= all_ctr		+ cfg.ctrOrg;
		all_acrN	= all_acrN		+ cfg.acrNOrg;
		all_tou		= all_tou		+ cfg.touOrg;
		all_atkA	= all_atkA		+ cfg.atkAOrg;
		all_atkC	= all_atkC		+ cfg.atkCOrg;
		all_defC	= all_defC		+ cfg.defCOrg;
		all_atkW	= all_atkW		+ cfg.atkWOrg;
		all_defW	= all_defW		+ cfg.defWOrg;
		armorValue  = armorValue	+ cfg.ArmorValue;
		outATK  	= outATK		+ cfg.outATK;
		withinATK  	= withinATK		+ cfg.withinATK;
		elementATK  = elementATK	+ cfg.elementATK;
		speed		= cfg.speed;
		alertRange	= cfg.checkRange;

		all_windDamage			= all_windDamage		+ cfg.windDamageOrg;
		all_windDefence			= all_windDefence		+ cfg.windDefenceOrg;
		all_fireDamage			= all_fireDamage		+ cfg.fireDamageOrg;
		all_fireDefence			= all_fireDefence		+ cfg.fireDefenceOrg;
		all_soilDamage			= all_soilDamage		+ cfg.soilDamageOrg;
		all_soilDefence			= all_soilDefence		+ cfg.soilDefenceOrg;
		all_woodDamage			= all_woodDamage		+ cfg.woodDamageOrg;
		all_woodDefence			= all_woodDefence		+ cfg.woodDefenceOrg;
		all_steedFightDamage	= all_steedFightDamage	+ cfg.steedFightDamageOrg;
		all_steedFightDefend	= all_steedFightDefend	+ cfg.steedFightDefendOrg;
		all_internalForces		= all_internalForces	+ cfg.internalForcesOrg;
		all_dex					= all_dex				+ cfg.dexOrg;
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
	properties[ePropID_behealGain		]:Set(0,		ePropType_Base);
	properties[ePropID_internalForces	]:Set(all_internalForces,		ePropType_Base);
	properties[ePropID_dex			]:Set(all_dex,			ePropType_Base);
	properties[ePropID_armorMaxValue]:Set(armorValue,	ePropType_Base);
	properties[ePropID_attackUp			]:Set(0,		ePropType_Base);
	properties[ePropID_WindDamage		]:Set(all_windDamage,		ePropType_Base)
	properties[ePropID_WindDefence		]:Set(all_windDefence,		ePropType_Base)
	properties[ePropID_FireDamage		]:Set(all_fireDamage,		ePropType_Base)
	properties[ePropID_FireDefence		]:Set(all_fireDefence,		ePropType_Base)
	properties[ePropID_SoilDamage		]:Set(all_soilDamage,		ePropType_Base)
	properties[ePropID_SoilDefence		]:Set(all_soilDefence,		ePropType_Base)
	properties[ePropID_WoodDamage		]:Set(all_woodDamage,		ePropType_Base)
	properties[ePropID_WoodDefence		]:Set(all_woodDefence,		ePropType_Base)
	properties[ePropID_DexMaster		]:Set(0,		ePropType_Base)
	properties[ePropID_CampMaster		]:Set(0,		ePropType_Base)
	properties[ePropID_OutATK			]:Set(outATK,	ePropType_Base)
	properties[ePropID_WithinATK		]:Set(withinATK,ePropType_Base)
	properties[ePropID_ElementATK		]:Set(elementATK,ePropType_Base)
	properties[ePropID_SteedFightDamage]:Set(all_steedFightDamage, ePropType_Base)
	properties[ePropID_SteedFightDefend]:Set(all_steedFightDefend, ePropType_Base)




	return properties;
end

function i3k_monster:OnSelected(val)
	BASE.OnSelected(self, val);
	if self:GetEntityType() == eET_Monster then
		if val == false then
			g_i3k_game_context:OnCancelSelectHandler()
			return;
		end
		local maxhp = self:GetPropertyValue(ePropID_maxHP)
		local curhp = self:GetPropertyValue(ePropID_hp)
		local curArmor = self:GetPropertyValue(ePropID_armorCurValue);
		local maxArmor = self:GetPropertyValue(ePropID_armorMaxValue);
		local buffs = {}
		for k,v in pairs (self._buffs) do
			buffs[v._id] = v._endTime-v._timeLine;
		end
		local showName  = self:GetMonsterShowName()
		g_i3k_game_context:OnSelectMonsterHandler(self._id, curhp, maxhp, buffs, curArmor, maxArmor, showName, self._guid)
	end
end

function i3k_monster:CanAttack()
	local ret = BASE.CanAttack(self);
	if self._cfg.trait == 0 then -- 被动
		ret = ret and i3k_table_length(self._enmities) > 0;
	end

	return ret;
end

function i3k_monster:Birth(pos)
	self._birthPos = pos;

	self:SetPos(pos);
end

function i3k_monster:StopMove()
	BASE.StopMove(self);

	self._behavior:Clear(eEBRetreat);
end

function i3k_monster:OnDamage(attacker, atr, val, cri, stype, showInfo, update, SourceType, direct, buffid, armor, isCombo)
	i3k_monster_base.OnDamage(self, attacker, atr, val, cri, stype, showInfo, update, SourceType, direct, buffid, armor, isCombo);

	-- 硬直
	if stype == eSE_Damage and self._hp > 0 then
		if self._hp / self:GetPropertyValue(ePropID_maxHP) < self._cfg.spaHP then
			local odds = i3k_engine_get_rnd_f(0, 1);
			if odds < self._cfg.spaOdds then
				self:OnSpa();
			end
		end
	end
end

function i3k_monster:AddEnmity(entity, force)
	if not entity or not entity:IsAttackable(self) then
		return false;
	end

	if self._isBoss then
		if force then
			for k, v in ipairs(self._enmities) do
				if v._guid == entity._guid then
					table.remove(self._enmities, k);

					break;
				end
			end

			table.insert(self._enmities, 1, entity);
		else
			for k, v in ipairs(self._enmities) do
				if v._guid == entity._guid then
					return false;
				end
			end

			table.insert(self._enmities, entity);
		end
	else
		return BASE.AddEnmity(self, entity, pos);
	end

	return true;
end

function i3k_monster:UpdateAlives()
	if i3k_game_get_logic_tick() - self._lastUpdateAliveTick < 5 then
		self._updateAliveTick = 0;

		return false;
	end
	self._lastUpdateAliveTick = i3k_game_get_logic_tick();

	--i3k_log("monster update alives. stack = " .. self._attackStack);
	self._alives = { { }, { }, { }, };

	local _add = { false, false, false };

	-- 友方
	for i, v in pairs(self._all_alives[1]) do
		if not v.entity:IsDead() then
			_add[1] = true;

			v.dist = i3k_vec3_dist(v.entity._curPos, self._curPos);
			table.insert(self._alives[1], v);
		end
	end

	-- 敌方
	for i, v in pairs(self._all_alives[2]) do
		if not v.entity:IsDead() then
			_add[2] = true;

			v.dist = i3k_vec3_dist(v.entity._curPos, self._curPos);
			table.insert(self._alives[2], v);
		end
	end


		-- 排序
		local _cmp = function(d1, d2)
			return d1.dist < d2.dist;
		end

		-- 友方
		if self._alives[1][1] then
			table.sort(self._alives[1], _cmp);
		end

		-- 敌方
		if self._alives[2][1] then
			table.sort(self._alives[2], _cmp);
		end

		self:UpdateEnmities();
end

function i3k_monster:UpdateEnmities()
	local rmvs = { };
	for k, v in ipairs(self._enmities) do
		local dist = i3k_vec3_len(i3k_vec3_sub1(self._curPos, v._curPos));

		if not v:IsAttackable(self) or v:IsDead() or dist > i3k_db_common.engine.unselectTargetDist then
			table.insert(rmvs, k);
		end
	end

	for k = #rmvs, 1, -1 do
		table.remove(self._enmities, rmvs[k]);
	end
end

function i3k_monster:SetTitleVisiable(vis)
	self:SetBloodBarVisiable(vis);
end
