------------------------------------------------------
module(..., package.seeall)

local require = require

require("logic/entity/i3k_entity_trap_def");
require("logic/entity/i3k_entity")
local ENTITYBASE = i3k_entity;
local BASE = require("logic/entity/i3k_hero").i3k_hero;

------------------------------------------------------
i3k_entity_trap = i3k_class("i3k_entity_trap",BASE);
------------------------------------------------------

function i3k_entity_trap:ctor(guid)
	self._entityType		= eET_Trap;
	self._PVPColor			= -2;
	self._aiController		= nil;
	self._trapaiController  = nil;
	self._TrapTarget		= {}
	self._hp				= -1;
	self._trapinit			= true;
end

function i3k_entity_trap:CreateFromCfg()
	if self._gcfg_base then
		self:CreateRes(self._gcfg_base.modelID);
	else
		return false;
	end
	
	return true;
end

function i3k_entity_trap:CreatePreRes(gid)
	local gcfg_external = i3k_db_traps_external[gid];
	if not gcfg_external then
		return false;
	end

	local gcfg_base	= i3k_db_traps_base[gcfg_external.baseID]
	if not gcfg_base then
		return false;
	end

	self._gid			= gid;
	self._gcfg_base		= gcfg_base;
	self._gcfg_external	= gcfg_external; 
	self._trapinit		= true;
	local world = i3k_game_get_world();
	local trapaiMgr = nil ;
	
	if world._syncRpc then
		trapaiMgr = require("logic/entity/ai/i3k_trap_mgr_net");
	else
		trapaiMgr = require("logic/entity/ai/i3k_trap_mgr");
	end	

	
	local aiMgr = require("logic/entity/ai/i3k_ai_mgr");

	self._aiController = aiMgr.create_mgr(self);

	self._lvl = gcfg_base.lvl;
	if gcfg_base.TrapType then 
		if world._syncRpc then
			self._trapaiController = trapaiMgr.create_mgr_net(self);
		else
			self._trapaiController = trapaiMgr.create_mgr(self);
		end	
	end
	self._trapskill = nil;
	self._CurTransLogic = 0;
	self._entityType	= eET_Trap;
	self._activeonce = true;	

	local ntype = 0;
	if gcfg_base then
		ntype = gcfg_base.TrapType;  
	end
	
	self._ntype = ntype

	local skillId = -1;
	if gcfg_base then
		skillId = gcfg_base.SkillID;
	end

	self._skillId = skillId

	local LogicId = -1;
	if gcfg_external then
		LogicId = gcfg_external.TrapLogicID;
	end

	self._LogicId = LogicId

	--self:CreateFromCfg(self._gid, self._gcfg_base.name, cfg, self._gcfg_base.lvl, {}, false);

	self._lvl	= lvl;
	self._cfg	= self._gcfg_base;
	self._cname	= self._gcfg_base.name;
	self._name	= self._gcfg_base.name;
	self._obstacleValid
				= self._gcfg_base.ObstacleType ~= 0;
	if self._ntype == eEntityTrapType_AOE and gcfg_external.Life ~= -1 then
		self._showstyle		= eShowStyle_TTF;
	end
	self:ShowTitleNode(true);

	if self._gcfg_external.SkillID ~= -1 then
		self._trapskill = self:InitSkill(self._gcfg_external.SkillID);
		self._sklllTargets = {}
	end

	if self._obstacleValid then
		local obstacle = require("logic/battle/i3k_obstacle");
		self._obstacle = obstacle.i3k_obstacle.new(i3k_gen_entity_guid_new(obstacle.i3k_obstacle.__cname,i3k_gen_entity_guid()));
		if self._obstacle:Create(self._gcfg_external.Pos, self._gcfg_external.Direction, self._gcfg_base.obstacleType, self._gcfg_base.obstacleArgs) then
			self._obstacle:Show(false, true,10);
			self._obstacle:SetHittable(false)
		else
			self._obstacle = nil;
		end
	end
	self._behavior:Set(eEBShiftResist)
	self._properties = self:InitProperties();
	self._IsAttack = i3k_bit_op:_and(self._gcfg_external.ActiveMask,eTrapActiveAttack)
	self._trapinit		= true;
	return true;
end

function i3k_entity_trap:IsDestory()
	return self._entity == nil or self._destory;
end

function i3k_entity_trap:CanRelease()
	return true;
end

function i3k_entity_trap:CreateTitle()
	local _T = require("logic/entity/i3k_entity_title");

	local title = { };


	return title;
end

function i3k_entity_trap:InitProperties()
	-- 基础属性
	local properties = i3k_entity.InitProperties(self);

	return properties;
end



function i3k_entity_trap:OnInitBaseProperty(props)
	local gid	= self._gid;
	local gcfg_base	= self._gcfg_base;
	local gcfg_external	= self._gcfg_external;
	local lvl = gcfg_base.lvl;
	--update all properties

	-- 基础属性
	local properties = i3k_entity.OnInitBaseProperty(self, props);

	-- add new property
	properties[ePropID_maxHP]		= i3k_entity_property.new(self, ePropID_maxHP,			0);
	properties[ePropID_atkN]		= i3k_entity_property.new(self, ePropID_atkN,			0);
	properties[ePropID_defN]		= i3k_entity_property.new(self, ePropID_defN,			0);
	properties[ePropID_atr]			= i3k_entity_property.new(self, ePropID_atr,			0);
	properties[ePropID_ctr]			= i3k_entity_property.new(self, ePropID_ctr,			0);
	properties[ePropID_acrN]		= i3k_entity_property.new(self, ePropID_acrN,			1);
	properties[ePropID_defA]		= i3k_entity_property.new(self, ePropID_defA,			1);
	properties[ePropID_tou]			= i3k_entity_property.new(self, ePropID_tou,			0);
	properties[ePropID_atkA]		= i3k_entity_property.new(self, ePropID_atkA,			1);
	properties[ePropID_defA]		= i3k_entity_property.new(self, ePropID_defA,			1);
	properties[ePropID_deflect]		= i3k_entity_property.new(self, ePropID_deflect,		1);
	properties[ePropID_atkD]		= i3k_entity_property.new(self, ePropID_atkD,			1);
	properties[ePropID_atkH]		= i3k_entity_property.new(self, ePropID_atkH,			0);
	properties[ePropID_atkC]		= i3k_entity_property.new(self, ePropID_atkC,			0);
	properties[ePropID_defC]		= i3k_entity_property.new(self, ePropID_defC,			0);
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
	properties[ePropID_res1]		= i3k_entity_property.new(self, ePropID_res1,			0);
	properties[ePropID_res2]		= i3k_entity_property.new(self, ePropID_res2,			0);
	properties[ePropID_res3]		= i3k_entity_property.new(self, ePropID_res3,			0);
	properties[ePropID_res4]		= i3k_entity_property.new(self, ePropID_res4,			0);
	properties[ePropID_res5]		= i3k_entity_property.new(self, ePropID_res5,			0);
	properties[ePropID_alertRange] 	= i3k_entity_property.new(self, ePropID_alertRange,		0);
	properties[ePropID_maxSP]		= i3k_entity_property.new(self, ePropID_maxSP,			0);
	properties[ePropID_sp]			= i3k_entity_property.new(self, ePropID_sp,				0);
	properties[ePropID_mercenarydmgTo]	= i3k_entity_property.new(self, ePropID_mercenarydmgTo,	1);
	properties[ePropID_behealGain]		= i3k_entity_property.new(self, ePropID_behealGain,	1);
	

	local all_hp		= 1;
	if gcfg_external.Life ~= -1 then
		all_hp = gcfg_external.Life
	end
	self._hp = all_hp
	self._trapinit		= true;
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

	-- update all properties
	properties[ePropID_lvl			]:Set(lvl,		ePropType_Base);
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
	properties[ePropID_speed		]:Set(0,		ePropType_Base);
	properties[ePropID_alertRange		]:Set(alertRange,	ePropType_Base);
	properties[ePropID_maxSP		]:Set(0,		ePropType_Base);
	properties[ePropID_sp			]:Set(0,			ePropType_Base);
	properties[ePropID_mercenarydmgTo	]:Set(0,			ePropType_Base);
	properties[ePropID_behealGain		]:Set(0,			ePropType_Base);

	return properties;
end


function i3k_entity_trap:SetTarget(target)
	table.insert(self._TrapTarget,target)
end

function i3k_entity_trap:Release()
	if self._entity then
		if self._shadowEffID then
			self._entity:RmvHosterChild(self._shadowEffID);
			self._shadowEffID = nil;
		end
		if self._obstacle then
			self._obstacle:Release()
			self._obstacle = nil;
		end
		self._entity:Release();
		self._entity = nil;
	end
	BASE.Release(self);
end

function i3k_entity_trap:GetTarget()
	return self._TrapTarget;
end

function i3k_entity_trap:IsAttackable(attacker)
	if self._IsAttack ~= 0 and self:GetStatus() == eSTrapActive then
		return true; 
	end
	return false;
end


function i3k_entity_trap:SetAiComp(atype)
	if self._trapaiController then
		self._trapaiController:ChangeTrap(atype);
		self._traptype = atype;
	end
end


function i3k_entity_trap:OnUpdate(dTime)
	if self._trapskill then
		if self._attacker then
			for k, v in ipairs(self._attacker) do
				v:OnUpdate(dTime);
			end
		end	
	end
	--ENTITYBASE.OnUpdate(self, dTime);
	
	--[[if self._turnMode then
		self._turnTick = self._turnTick + dTime;
		if self._turnTick <= 0.1 then
			local d = self._turnTick / 0.1;

			local f = i3k_vec3_lerp(self._turnOriDir, self._turnDir, d);

			self:SetFaceDir(f.x, f.y, f.z);
		else
			self._turnMode = false;

			self:SetFaceDir(self._turnDir.x, self._turnDir.y, self._turnDir.z);
		end
	end--]]
	

	if self._trapaiController then
		self._trapaiController:OnUpdate(dTime);
	end

	--[[
	if self._obstacle then
		self._obstacle:OnUpdate(dTime);
	end
	]]
end

function i3k_entity_trap:OnLogic(dTick)
	if self._trapskill then
		if self._attacker then
			local rmvs = { };
			for k, v in ipairs(self._attacker) do
				if not v:OnLogic(dTick) then
					v:Release();

					table.insert(rmvs, k);
				end
			end

			for k = #rmvs, 1, -1 do
				table.remove(self._attacker, rmvs[k]);
			end
		end
		if self._updateAlives then
			self._updateAliveTick = self._updateAliveTick + dTick * i3k_engine_get_tick_step();
			if self._updateAliveTick > 500 then -- 0.5秒更新一次????
				self._updateAliveTick = 0;

				self:UpdateAlives();
			end
		end
	end
	ENTITYBASE.OnLogic(self, dTick);

	if self._trapaiController then
		self._trapaiController:OnLogic(dTick);
	end

	--[[
	if self._obstacle then
		self._obstacle:OnLogic(dTick);
	end
	]]
end



function i3k_entity_trap:SetTrapBehavior(ntype,activeonce)	
	if not activeonce then
		self._activeonce = false;
	end
	self:SetAiComp(ntype);
end

function i3k_entity_trap:GetStatus()
	if self and self._trapaiController and self._trapaiController._statu then
		return self._trapaiController._statu
	end
	return -1;
end

function i3k_entity_trap:OnDamage(attacker, val, atr, cri, stype, showInfo, update, SourceType, direct, buffid)
	if self:GetStatus() == eSTrapActive then
		if self._gcfg_external and self._gcfg_external.ActiveMask then
			if  self._IsAttack ~= 0 then
				local logic = i3k_game_get_logic();
				if logic then
					local world = logic:GetWorld();
					if world._syncRpc then
						local args = {trapID = self._gid}
						i3k_sbean.on_trap_click(args)
					else
						local args = {trapID = self._gid,trapState = eSTrapClosed};
						i3k_sbean.sync_privatemap_trap(args)
						self:SetTrapBehavior(eSTrapsInjured,true);
					end
				end
			end
		end
	elseif self:GetStatus() == eSTrapAttack then
		if self._ntype == eEntityTrapType_AOE and self._hp ~= -1 then
			self._hp = self._hp -1
			self:UpdateBloodBar(self._hp / self:GetPropertyValue(ePropID_maxHP));
			local hero = i3k_game_get_player_hero()
			if self:IsPlayer() or attacker:IsPlayer() or (self._hoster and self._hoster:IsPlayer()) or (attacker._hoster and attacker._hoster:IsPlayer()) or ((self:GetEntityType() == eET_Pet or self:GetEntityType() == eET_Skill)  and hero and self._hosterID and hero:GetGuidID() == self._hosterID) or ((attacker:GetEntityType() == eET_Pet or attacker:GetEntityType() == eET_Skill) and hero and attacker._hosterID and hero:GetGuidID() == attacker._hosterID) or g_i3k_game_context:IsTeamMember(attacker:GetGuidID()) or g_i3k_game_context:IsTeamMember(self:GetGuidID()) or g_i3k_game_context:GetWorldMapType() ~= 0 then
				self:ShowInfo(self._entity, eEffectID_Damage.style, eEffectID_Damage.txt .. ' - ' .. 1,nil,eET_Trap);
			end
			if self._hp == 0 then
				self:SetTrapBehavior(eSTrapClosed,true);
			end
		end
	end
end


function i3k_entity_trap:InitSkill(id)
	local scfg = i3k_db_skills[id];
	local skill = require("logic/battle/i3k_skill");
	if skill then
		local _skill = skill.i3k_skill_create(self, scfg, 1, skill.eSG_Skill);
		if _skill then
			return _skill;
		end
	end
	return nil;
end


function i3k_entity_trap:SetTransLogic(logicid)
	self._CurTransLogic = self._CurTransLogic + logicid ;
end

function i3k_entity_trap:ClearTransLogic()
	self._CurTransLogic = 0 
end

function i3k_entity_trap:GetTransLogic()
	return self._CurTransLogic;
end

function i3k_entity_trap:IsDeadActive()
	return self:GetStatus() ~= eSTrapActive;
end

function i3k_entity_trap:OnSelected(val)
	BASE.OnSelected(self, val);

	if self:GetStatus() == eSTrapActive then
		local logic = i3k_game_get_logic();
		if logic then
			local world = logic:GetWorld();
			if world then
				if world._syncRpc then
					local guid = string.split(self._guid, "|")
					local args = {trapID = guid[2]}
					i3k_sbean.on_trap_click(args)
				else
					if self._gcfg_external and self._gcfg_external.ActiveMask then
						if (self._gcfg_external.ActiveMask == eTrapActiveClick) or (self._gcfg_external.ActiveMask == (eTrapActiveClick + eTrapActiveAttack)) then
							i3k_sbean.sync_privatemap_trap({ trapID = self._gid, trapState = eSTrapClosed });

							self:SetTrapBehavior(eSTrapAttack, true);
						end
					end
				end	
			end	
		end
	end
end

function i3k_entity_trap:UpdateAlives()
	local logic		= i3k_game_get_logic();
	self._alives	= { { }, { }, { }, };
	local world = logic:GetWorld();
	if world then
		if self._trapskill then
			local _as = world:GetAliveEntities(self, eGroupType_O);
			if _as then
				for k, v in ipairs(_as) do
					if v.dist < self._trapskill._range then
						table.insert(self._alives[2], v);
					end
				end
            end
			self:UpdateEnmities();
		end
	end
end
function i3k_entity_trap:IsDead()
	if self:IsAttackable() then
		return false
	end
	return true
end
