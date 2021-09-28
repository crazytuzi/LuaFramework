----------------------------------------------------------------
module(..., package.seeall)

local require = require

require("i3k_state_base");
require("logic/entity/i3k_entity");

local BASE = i3k_entity;
------------------------------------------------------
local g_i3k_skill_guid	= 0;
local eStep_Attack		= 0;
local eStep_Rush		= 1;
local eStep_Fly			= 2;
local eStep_omnislash	= 3;

i3k_attacker_net = i3k_class("i3k_attacker_net", BASE);
function i3k_attacker_net:Create(hero, skill, targets, passive, parentSkill )

	g_i3k_skill_guid = g_i3k_skill_guid + 1;

	if BASE.Create(self, g_i3k_skill_guid) then
		self._targets	= { };
		self._newtarget = nil;
		if targets then
			for v, t in pairs(targets) do
				table.insert(self._targets, t);
			end
		end
		local c = skill._cfg;
		self._hero			= hero;
		self._skill			= skill;
		self._curAction		= c.action;
		self._parentSkill	= parentSkill;
		self._flightSkill	= false;
		self._triNextSeq	= false;
		if skill._id == 9999999 and hero._DIYSkillID then
			local DIYcfg = i3k_db_create_kungfu_showargs_new[hero._DIYSkillID];
			if DIYcfg then
				self._curAction = DIYcfg.attackActionName
			end
		end
		if c.showname == 1 then
			hero:ShowInfo(attacker, eEffectID_ExSkill.style,  c.name , i3k_db_common.engine.durNumberEffect[2] / 1000);
		end
		self._endAttack		= false;
		self._attackSuc		= false;
		self._flightSkill	= c.isFlySkill == 1;
		self._aoeSkill		= (c.scope.type ~= eSScopT_Single) and (c.scope.type ~= eSScopT_Owner);
		self._duration		= 0;
		self._timeTick      = 0;
		self._passive		= passive;
		self._stype			= skill._gtype;
		self._childs = { };
		self.rushinit = false;
		self._moveTime	= 0;
		self._step	= eStep_Attack;
		
		if self._skill._cfg.charge.time and self._skill._cfg.charge.time > 0 then
			self._skill:TriggerVFX(eVFXStartCharge, nil);
			self._chargeTime = self._skill._cfg.charge.time;
		end
		self:StartAttacker();
		self._skill:TriggerVFX(eVFXBegin, nil);

		return true;
	end

	return false;
end

function i3k_attacker_net:OnUpdate(dTime)
	BASE.OnUpdate(self, dTime);
	self._duration = self._duration + dTime * 1000;
	self._timeTick = self._timeTick + dTime * 1000;
	if self._chargeTime and self._chargeTime > 0 and self._timeTick > self._chargeTime then
		self:OnAttack();
		if self._flightSkill then --TODO
		else
			local triIdx = self._eventTriIdx;
			if triIdx and self._eventTriNum then
				if triIdx <= self._eventTriNum then
					if self._duration > self._eventTriTime[triIdx] then
						self._eventTriIdx = self._eventTriIdx + 1;
					end
				end
			end
		end
	end

	if self._step == eStep_Rush then
		self._skill:TriggerVFX(eVFXStartBehavior, nil);
		self:OnRushUpdate(dTime);
	end

	if self._step == eStep_Fly then
		self:OnFlyUpdate(dTime)
	end
	
	if self._step == eStep_omnislash then
		self:OnOmnUpdate(dTime);
	end
	
	if self._warnEffectID then
		if self._duration > self._skill._warnTime then
			g_i3k_actor_manager:ReleaseSceneNode(self._warnEffectID);
			g_i3k_game_context:ClearWarnEffectCache(self._warnEffectID);
			self._warnEffectID = nil;
		end
	end
	if self._skill._duration > 0 then
		if self._duration > 1.5 * self._skill._duration then
			self:StopAttack();
		end
	end
	
	return not self._endAttack;
end

function i3k_attacker_net:OnLogic(dTick)
	
	return false;
end

function i3k_attacker_net:NextSequence(skill)
	self._triNextSeq = true;
	
	-- first release current attack
	self._skill:TriggerVFX(eVFXEnd, nil);
	self._skill:ResetVFX();
	
	if self._alter_effect_id then
		self._hero._entity:RmvHosterChild(self._alter_effect_id);
	end
	
	if self._warnEffectID then
		g_i3k_actor_manager:ReleaseSceneNode(self._warnEffectID);
		g_i3k_game_context:ClearWarnEffectCache(self._warnEffectID);
		self._warnEffectID = nil;
	end
	
	if self._models then
		for k, v in ipairs(self._models) do
			g_i3k_actor_manager:LeaveScene(v);
			g_i3k_actor_manager:ReleaseSceneNode(v);
		end
	end
	
	if self._hero and self._hero:IsPlayer() then
		-- send to server
		if self._parentSkill then
			i3k_sbean.map_usefollowskill(self._parentSkill._cfg.id, self._parentSkill:GetSequenceIdx() - 1);
		else
			i3k_sbean.map_usefollowskill(self._skill._cfg.id, self._skill:GetSequenceIdx() - 1);
		end
	else
		skill = self._skill._seq_skill.skills[skill]
	end
	
	return self:Create(self._hero, skill, self._targets, self._passive, self._parentSkill or self._skill);
end

function i3k_attacker_net:OnAttack()
	local d = self._skill._data;
	if not d then
		return false;
	end
	self._eventTriNum	= 0;
	self._eventTriIdx	= 1;
	self._eventTriTime	= { };
	self._eventTriData	= { };
	if self._flightSkill then 
	else
		for k, v in ipairs(d.events) do
			if v.triTime > 0 then
				local valid = v.damage.odds > 0;
				for k1, v1 in ipairs(v.status) do
					if v1.odds > 0 then
						valid = true;
					end
				end

				if valid then
					self._eventTriNum = self._eventTriNum + 1;
					local user = nil
					if self._hero then
						user = self._hero
						if self._hero._hoster then
							user = self._hero._hoster
						end
					end
					table.insert(self._eventTriTime, v.triTime+ self._skill:TalentSkillChange(user,eSCType_Event,eSCEvent_time,k));
					table.insert(self._eventTriData, v);
				end
			end
		end
	end
	self._skill:TriggerVFX(eVFXStartAttack, nil);
	
	return true;
end

function i3k_attacker_net:StartAttacker()
	local h = self._hero;
	local s = self._skill;

	self._targetCheck
					= nil;
	self._endAttack	= false;
	self._attackSuc	= false;
	self._inheritTargets
					= nil;
	self._facade	= not self._isChild and not self._passive and not s._ignoreAct;

	-- play action
	if self._facade then
		h:Play(self._curAction, 1);
	end

	local dir = h._orientation;
	local scope = s._scope;

	if s._specialArgs.omnislash then
		self._skill:TriggerVFX(eVFXBegin, nil);
		self:StartOmnislash();
		self._step = eStep_omnislash;		
	end

	if s._specialArgs.flyInfo then
		self._step = eStep_Fly;
		self._skill:TriggerVFX(eVFXStartBehavior, nil);
		self:StartFly();
	end
	
	if s._warnEff then
		local cfg = i3k_db_effects[s._warnEff];
		if cfg then
			self._warnEffectID = g_i3k_actor_manager:CreateSceneNode(cfg.path, string.format("entity_alert_area_%s_effect_%d", h._guid, s._warnEff));
			if self._warnEffectID > 0 then
				g_i3k_actor_manager:SetLocalTrans(self._warnEffectID, h._curPosE);
				g_i3k_actor_manager:SetLocalScale(self._warnEffectID, cfg.radius);
			end
		end
	end

	if self._warnEffectID and self._warnEffectID > 0 then
		g_i3k_actor_manager:EnterScene(self._warnEffectID);

		g_i3k_actor_manager:SetLocalRotation(self._warnEffectID, Engine.SVector3(h._faceDir.x, h._faceDir.y - math.pi * 0.5, h._faceDir.z));
		g_i3k_actor_manager:Play(self._warnEffectID, -1);
		if s._warnTime and s._warnTime ~= 0 then
			local logicTick = i3k_game_get_logic_tick();
			local warnInfo = {warnID = self._warnEffectID, logicTick = logicTick, manager = g_i3k_actor_manager, warnTime = s._warnTime};
			g_i3k_game_context:SetWarnEffectCache(warnInfo);
		end
	end
end

function i3k_attacker_net:StartRush(dir, info, sender)
	local skill = self._skill;
	if skill then
		skill:TriggerVFX(eVFXStartBehavior, nil);
		self._rushInfo = info;
		self._dir = dir;
		self._startPos	= self._hero._curPosE;
		self._velocity  = ( self._rushInfo.velocity / 100);
		self._height    = ( info.height / 100 );
		self._targetPos = i3k_engine_get_valid_pos(i3k_vec3_to_engine(i3k_logic_pos_to_world_pos(info.endPos)));	
		self._rushLine	= 0;
		if i3k_vec3_dist(self._startPos, self._targetPos) < 0.1 then
			self._middlePos	= i3k_vec3_clone(self._startPos);
			self._targetPos = i3k_vec3_clone(self._startPos);
		else
			self._middlePos	= i3k_vec3_div2(i3k_vec3_add1(self._startPos, self._targetPos), 2);
		end

		if self._rushInfo.type == 2 then
			self._middlePos.y = self._middlePos.y + self._height;
		elseif self._rushInfo.type == 3 then
			if self._hero:GetEntityType() == eET_Player then
				self._hero:chageTitleAction("jump");
			end
		end

		--持续时间
		self._rushDuration1 = i3k_vec3_dist(self._middlePos, self._startPos) / self._velocity;
		self._dir1		= i3k_vec3_normalize1(i3k_vec3_sub1(self._middlePos, self._startPos));
		self._rushDuration2 = i3k_vec3_dist(self._targetPos, self._middlePos) / self._velocity;
		self._dir2      = i3k_vec3_normalize1(i3k_vec3_sub1(self._targetPos, self._middlePos));
		self._rushDuration  = self._rushDuration1 + self._rushDuration2;
	end

	self._step = eStep_Rush;
end

function i3k_attacker_net:OnRushUpdate(dTime)
		if self._rushInfo then
			self._rushLine = self._rushLine + dTime;
			
			if self._rushLine >= self._rushDuration then
				self._hero:UpdateWorldPos(i3k_vec3_to_engine(self._targetPos));
			elseif self._rushLine >= self._rushDuration1 then
				local pos = i3k_vec3_add1(self._hero._curPosE, i3k_vec3_mul2(self._dir2, self._velocity * dTime));
				self._hero:UpdateWorldPos(i3k_vec3_to_engine(pos, false));
			else
				local pos = i3k_vec3_add1(self._hero._curPosE, i3k_vec3_mul2(self._dir1, self._velocity * dTime));
				self._hero:UpdateWorldPos(i3k_vec3_to_engine(pos, false));
			end
		end

	return true;	
end

function i3k_attacker_net:StopRush()
	self._skill:TriggerVFX(eVFXEndBehavior, nil);
	self._behavior:Clear(eEBRush);
	if self._movePos then
		self._hero:SetPos(self._movePos, true);
	end

	self._step = eStep_Attack;
	
	return false;
end

function i3k_attacker_net:StartFly()
	local skill = self._skill;
	if skill._specialArgs.flyInfo then
	self._flyInfo	= skill._specialArgs.flyInfo;
	self._curPos	= i3k_vec3_clone(self._hero._curPos);
		if self._flyInfo.type == 1 then
			self._deltaTime	= 0;
			self._moveTime	= 0;
			self._moveEnd	= true;
			self._movePos	= self._curPos;
			self._moveDir	= { x = 0, y = 0, z = 0 };
			self._target = self._targets[1];
			if not self._target then
				return false;
			end
			local cfg = i3k_db_models[self._flyInfo.modelID];
			if cfg then
				self._modelID = g_i3k_actor_manager:CreateSceneNode(cfg.path, string.format("attack_fly_model_%s_%d_%d", self._hero._guid, 1, self._flyInfo.modelID));
				if self._modelID > 0 then
					g_i3k_actor_manager:SetLocalTrans(self._modelID, i3k_vec3_to_engine(self._hero._curPosE));
					g_i3k_actor_manager:SetLocalScale(self._modelID, cfg.scale);
					g_i3k_actor_manager:SelectAction(self._modelID, self._flyInfo.action);
					g_i3k_actor_manager:Play(self._modelID, -1);
					g_i3k_actor_manager:EnterScene(self._modelID);
				end
			end
			return true;
		end
	end	
end

function i3k_attacker_net:OnFlyUpdate(dTime)
	if self._flyInfo.type == 1 then
		self:SetFlyPos(self._movePos, true);
		self._deltaTime	= dTime * 1000;
		self._moveTime	= 0;
		self._moveEnd	= true;
		if not self._target then
			return false;
		end
		local p1 = i3k_vec3_clone(self._target._curPos);
		local p2 = i3k_vec3_clone(self._curPos);
		if i3k_vec3_dist(p1, p2) < 100 then 
			if self._modelID and self._modelID > 0 then
				g_i3k_actor_manager:LeaveScene(self._modelID);
				g_i3k_actor_manager:ReleaseSceneNode(self._modelID);
				self._modelID = nil;
			end
			self._step = eStep_Attack
			return false;
		else
			self._moveEnd = false;
			self._moveDir = i3k_vec3_normalize1(i3k_vec3_sub1(p1, p2));
			self._movePos = i3k_vec3_add1(self._curPos, i3k_vec3_mul2(self._moveDir, (self._flyInfo.speed / 1000) * self._deltaTime));

			if self._modelID and self._modelID > 0 then
				local angle = i3k_vec3_angle1(p1, p2, i3k_vec3(1, 0, 0));
				g_i3k_actor_manager:SetLocalRotation(self._modelID, 0, angle - math.pi * 0.5, 0);
			end
		end
		
		if self._skill._specialArgs.triSkillOnDamage then
			local target = self._targets[1];
			if target then
				self._skill:TriggerVFX(eVFXDamage, { target });
			end
		end
		
		if not self._moveEnd then
			self._moveTime = i3k_integer(self._moveTime + dTime * 1000);
			if self._moveTime >= self._deltaTime then
				self._moveEnd 	= true;
				self._moveTime 	= self._deltaTime;
			end

			local cp = i3k_vec3_2_int(i3k_vec3_lerp(self._curPos, self._movePos, self._moveTime / self._deltaTime));
			self:SetFlyPos(cp, false);
		end
	end
	
	return true;	
end

function i3k_attacker_net:SetFlyPos(pos, real)
	if self._modelID and self._modelID > 0 then
		g_i3k_actor_manager:SetLocalTrans(self._modelID, i3k_vec3_to_engine(i3k_logic_pos_to_world_pos(pos)));
	end

	if real then
		self._curPos = pos;
	end
end

function i3k_attacker_net:StartOmnislash()
	local skill = self._skill;
		
	if skill._specialArgs.omnislash then
		local om = skill._specialArgs.omnislash;
		self._start     = false;
		self._curPos    =   i3k_vec3_clone(self._hero._curPos);
		self._taktTime      = om.taktTime ;
		self._twinkleTimes  = om.twinkleTimes;
		self._targetRadius  = om.targetRadius;
		self._damageTick	= 0;
		self._damageData 	= skill._data.events[1];
		self._target = self._targets[1];
		if not self._target then
			return false;
		end
	end	
end

function i3k_attacker_net:OnOmnUpdate(dTime)
	local skill = self._skill;
	local hero  = self._hero;
	if skill._specialArgs.omnislash then
		if not self._start or self._timeTick >= self._taktTime then
			self._start 	= true;
			self._timeTick 	= 0;
			self._damageTick = self._damageTick + 1;
				if self._damageTick <  self._twinkleTimes then
					local target = self._target;
					if target then
						local ran_signX = i3k_engine_get_rnd_u(-1,1)
						local ran_signZ = i3k_engine_get_rnd_u(-1,1)
						if ran_signX and ran_signX == 0 then
							ran_signX = -1;
						end
						if ran_signZ and ran_signZ == 0 then
							ran_signZ = -1;
						end
						local rnd_x = ran_signX * i3k_engine_get_rnd_u(140, 150);
						local rnd_z = ran_signZ * i3k_engine_get_rnd_u(140, 150);
						if target then
							local pos1 = { x = rnd_x + target._curPos.x, y = target._curPos.y, z = rnd_z + target._curPos.z};
							hero:SetPos(pos1,false, false);
							local p1 = hero._curPos;
							local p2 = target._curPos;
							local rot_y = i3k_vec3_angle1(p2,p1,{ x = 1, y = 0, z = 0 });
							hero:SetFaceDir(0, rot_y, 0);
						end	
					--else	
					end
				--else			
				end	
			end	
		
		return true;
	end	
	
	return false;
end

function i3k_attacker_net:AddChilds(child)
	table.insert(self._childs, child);
end

function i3k_attacker_net:Release(real)
	local skill = self._skill._specialArgs;
		
	if skill.omnislash then
		if self._start then
			if self._hero then
				self._hero:SetPos(self._curPos, true);
			end
		end
	end
	
	if skill.rushInfo then
		if self._hero:GetEntityType() == eET_Player then
			self._hero:chageTitleAction(i3k_db_common.engine.defaultStandAction);
		end
	end
	
	if skill.flyInfo then
		if skill.flyInfo.type == 1 then
			if self._modelID and self._modelID > 0 then
				g_i3k_actor_manager:LeaveScene(self._modelID);
				g_i3k_actor_manager:ReleaseSceneNode(self._modelID);
				self._modelID = nil;
			end
		end	
	end
	
	if self._warnEffectID then
		g_i3k_actor_manager:ReleaseSceneNode(self._warnEffectID);
		g_i3k_game_context:ClearWarnEffectCache(self._warnEffectID);
		self._warnEffectID = nil;
	end
	
	self:StopAttack(false, real);
	
	BASE.Release(self);
end

function i3k_attacker_net:StopAttack(result, real)
	if not self._endAttack then
		local _real =  true
		if not real and real ~= nil then
			_real = real
		end
		
		self._endAttack = true;
		self._skill:TriggerVFX(eVFXEnd, nil);
		self._skill:ResetVFX();

		if not self._skill._canAttack then
			self._hero._behavior:Clear(eEBDisAttack);
		end
		if  _real then
			self._hero:StopAttack(self._skill, result, self._attackSuc);
			if self._parentSkill then	
				self._hero:StopAttack( self._parentSkill, result, self._attackSuc);	
			end
		end
	end
end

function i3k_attacker_net_create(hero, skill, targets, passive, child)
	local attacker = i3k_attacker_net.new(i3k_gen_entity_guid_new(i3k_attacker_net.__cname, i3k_gen_entity_guid()), child or false);
	if attacker:Create(hero, skill, targets, passive) then
		return attacker;
	end
	attacker:Release(); 

	return nil;
end
