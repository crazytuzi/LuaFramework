------------------------------------------------------
module(..., package.seeall)

local require = require

local BASE =
	require("logic/entity/i3k_hero").i3k_hero;



------------------------------------------------------
i3k_skill_entity = i3k_class("i3k_skill_entity", BASE);
function i3k_skill_entity:ctor(guid)
	self._groupType		= eGroupType_U;
	self._entityType	= eET_Skill;
end

function i3k_skill_entity:Create(sid, mid, hoster, pos, level, realm, movespeed)
	self._hoster		= hoster;
	self._attacks		= { };
	self._skills		= { };
	self._cfg		= { speed = 0 };
	self._movespeed		= movespeed;

	if i3k_entity.Create(self, sid) then
		local scfg = i3k_db_skills[sid];
		if scfg then
			local _lvl = level or 1;
			local _rel = realm or 0;

			local _S = require("logic/battle/i3k_skill");
			local _skill = _S.i3k_skill_create(self, scfg, _lvl, _rel, _S.eSG_Skill);
			if _skill then
				local mcfg = i3k_db_models[mid];
				if mcfg and self._entity then
					
					if self._entity:AsyncCreateHosterModel(mcfg.path, string.format("entity_%s", self._guid)) then        
						self._baseScale		= mcfg.scale;
						self:SetScale(self._baseScale);
						self._entity:EnterWorld(false);
					end
				end
				
				self:SetPos(pos);
				self:Show(true, true);
				self:SetHittable(false);
				self:SetFaceDir(0,0.785,0);
				local _A = require("logic/battle/i3k_attacker");
				local attacker = _A.i3k_attacker_create(self, _skill, { }, false, false);
				if attacker then
					self:AddAttacker(attacker);
				end

				self:AddAiComp(eAType_IDLE);
				self:AddAiComp(eAType_DEAD);
				self:AddAiComp(eAType_SKILLENTITY_MOVE);
				self:NeedUpdateAlives(true);

				self._lifeTick	= 0;
				
				local world = i3k_game_get_world();
				if world and not world._syncRpc and self._hoster then
					self._lifeMax	= _skill._duration+ _skill:TalentSkillChange(self._hoster,eSCType_Common,eSCCommon_time);
				else
					self._lifeMax	= _skill._duration
				end
				return true;
			end
		end
	end

	return false;
end

function i3k_skill_entity:InAttackState()
	return true;
end

function i3k_skill_entity:IsDestory()
	return self._entity == nil or self._destory;
end

function i3k_skill_entity:CreateTitle()
	return nil;
end

function i3k_skill_entity:CanRelease()
	return true;
end

function i3k_skill_entity:IsSyncEntity()
	return true;
end

function i3k_skill_entity:OnLogic(dTick)
	
	local world = i3k_game_get_world();
	self._updateAlives = true;
	if world and not world._syncRpc then
		self._lifeTick = self._lifeTick + dTick * i3k_engine_get_tick_step();

		if (self._lifeTick >= self._lifeMax) and #self._attacker == 0 then
			self:OnDead();
		end
	end

	BASE.OnLogic(self, dTick);
end

function i3k_skill_entity:InitProperties()
	local properties =
	{
		[ePropID_speed] = i3k_entity_property.new(self, ePropID_speed,	0),
	};
	local speed = self._movespeed or 0
	properties[ePropID_speed			]:Set(speed,		ePropType_Base);
	return properties;
end

function i3k_skill_entity:IsAttackable(attacker)
	return false;
end

function i3k_skill_entity:CanMove()
	return (self._movespeed ~= 0 and self._movespeed);
end

function i3k_skill_entity:AddAttacker(attacker)
	if attacker then
		table.insert(self._attacker, attacker);
	end
end

function i3k_skill_entity:GetPropertyValue(id)
	if id == ePropID_speed then
		return self._movespeed;
	end
	if self._hoster then
		return self._hoster:GetPropertyValue(id);
	end

	return 0;
end

function i3k_skill_entity:GetProperty(id)
	if self._hoster then
		return self._hoster:GetProperty(id);
	end

	return nil;
end

function i3k_skill_entity:GetEnemyType()
	if not self._hoster then return { [eGroupType_U] = true } ; end

	return self._hoster:GetEnemyType();
end

function i3k_skill_entity:GetHoster()
	return self._hoster;
end

function i3k_skill_entity:MovePaths(paths, force)
	if not self:CanMove() then
		return false;
	end

	local _force = false;
	if force ~= nil then
		_force = force;
	end

	if _force or not self._forceMove then
		self._forceMove		= _force;
		self._velocity		= nil;
		self._targetPos		= nil;
		self._movePaths		= paths or { };
		self._follow		= nil;
		self._moveChanged	= true;

		--self._behavior:Set(eEBMove);
	end
end

function i3k_skill_entity:UpdateProperty(id, type, value, base, showInfo, force)
	BASE.UpdateProperty(self, id, type, value, base, showInfo, force);
	if id == ePropID_speed then
		self._movespeed = value
	end
end
