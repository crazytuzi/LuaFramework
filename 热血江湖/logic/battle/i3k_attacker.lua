----------------------------------------------------------------
module(..., package.seeall)

local require = require

require("i3k_state_base");
require("logic/entity/i3k_entity");

local BASE = i3k_entity;

----------------------------------------------------------------

local eAttackEventInit		= 100;
local eAttackEventCharge	= 101; -- 蓄力
local eAttackEventSpell		= 102; -- 吟唱
local eAttackEventCast		= 103; -- 引导
local eAttackEventRush		= 104; -- 冲锋
local eAttackEventFlash		= 105; -- 闪现
local eAttackEventFly		= 106; -- 飞行
local eAttackEventAttack	= 107; 
local eAttackEventStop		= 108;
local eAttackEventOmnislash = 109; --无敌斩

local eAttackStateInit		= "init";
local eAttackStateCharge	= "charge";
local eAttackStateSpell		= "spell";
local eAttackStateCast		= "cast";
local eAttackStateRush		= "rush";
local eAttackStateFly		= "fly";
local eAttackStateFlash		= "flash";
local eAttackStateAttack	= "attack";
local eAttackStateStop		= "stop";
local eAttackStateOmnislash = "omnislash";

local eFlashFadeInit	= 0;
local eFlashFadeOut		= 1;
local eFlashFadeIn		= 2;

-- rush type
local eRushTargetNone		= 0;	-- 无效
local eRushTargetFixed		= 1;	-- 以某位置
local eRushTargetFighter	= 2;	-- 以武将

------------------------------------------------------
i3k_attack_state = i3k_class("i3k_attack_state", i3k_state_base);
function i3k_attack_state:ctor(impl)
	self._impl		= impl;
	self._timeTick 	= 0;
end

function i3k_attack_state:Entry(fsm, from, evt, to)
	if i3k_state_base.Entry(self, fsm, from, evt, to) then
		self._timeTick = 0;

		return true;
	end

	return false;
end

function i3k_attack_state:OnLogic(dTick)
	if i3k_state_base.OnLogic(self, dTick) then
		self._timeTick = self._timeTick + dTick * i3k_engine_get_tick_step();

		return true;
	end

	return false;
end


------------------------------------------------------
i3k_attack_init = i3k_class("i3k_attack_init", i3k_attack_state);
function i3k_attack_init:ctor(impl)
end

function i3k_attack_init:Do(fsm, evt)
	if i3k_attack_state.Do(self, fsm, evt) then
		self._impl._skill:TriggerVFX(eVFXBegin, nil);

		return true;
	end

	return false;
end

function i3k_attack_init:OnLogic(dTick)
	if i3k_attack_state.OnLogic(self, dTick) then
		self._impl:OnEndInit();

		return true;
	end

	return false;
end


------------------------------------------------------
i3k_attack_spell = i3k_class("i3k_attack_spell", i3k_attack_state);
function i3k_attack_spell:ctor(impl)
end

function i3k_attack_spell:Do(fsm, evt)
	if i3k_attack_state.Do(self, fsm, evt) then
		self._impl._skill:TriggerVFX(eVFXStartSpell, nil);

		return true;
	end

	return false;
end

function i3k_attack_spell:OnLogic(dTick)
	if i3k_attack_state.OnLogic(self, dTick) then
		if self._timeTick > self._impl._skill._cfg.spell.time then
			self._impl:OnEndSpell();
		end

		return true;
	end

	return false;
end


------------------------------------------------------
i3k_attack_charge = i3k_class("i3k_attack_charge", i3k_attack_state);
function i3k_attack_charge:ctor(impl)
end

function i3k_attack_charge:Do(fsm, evt)
	if i3k_attack_state.Do(self, fsm, evt) then
		self._impl._skill:TriggerVFX(eVFXStartCharge, nil);

		return true;
	end

	return false;
end

function i3k_attack_charge:OnLogic(dTick)
	if i3k_attack_state.OnLogic(self, dTick) then
		if self._timeTick > self._impl._skill._cfg.charge.time then
			self._impl:OnEndCharge();
		end

		return true;
	end

	return false;
end


------------------------------------------------------
i3k_attack_cast = i3k_class("i3k_attack_cast", i3k_attack_state);
function i3k_attack_cast:ctor(impl)
	self._start			= false;
	self._triTick		= 0;
	self._damageOdds	= 0;
	self._damageTimes	= 0;
	self._damageData	= 0
end

function i3k_attack_cast:Entry(fsm, from, evt, to)
	if i3k_attack_state.Entry(self, fsm, from, evt, to) then
		local s = self._impl._skill;

		local ci = s._specialArgs.castInfo;
		if not ci then
			return false;
		end

		local d = self._impl._skill._data;
		if not d then
			return false;
		end
		local userentity = nil
		if self._impl._hero then
			userentity = self._impl._hero
			if self._impl._hero._hoster then
				userentity = self._impl._hero._hoster
			end
		end
		--self._start			= false;
		self._triTick		= ci.castTick;
		self._type			= ci.type;
		self._duration		= ci.duration + s:TalentSkillChange(userentity,eSCType_Common,eSCCommon_casttime);
		self._damageTick	= 0;
		self._damageTimes	= ci.castTickCount;
		self._damageData	= d.events[ci.eventID];
		self._damageEventID	= ci.eventID;

		s:TriggerVFX(eVFXStartAttack, nil);

		return true;
	end

	return false;
end

function i3k_attack_cast:OnLogic(dTick)
	if i3k_attack_state.OnLogic(self, dTick) then
		if self._timeTick >= self._triTick then
			--self._start			= true;
			if self._type == 1 then
				self._damageTick
								= self._damageTick + 1;
			elseif self._type == 2 then
				self._damageTick
								= self._damageTick + self._timeTick;
			end
			self._timeTick		= 0;

			self._impl:ProcessDamage(self._damageData, self._damageTick);
		end

		if (self._type == 1 and self._damageTick >= self._damageTimes) or (self._type == 2 and self._damageTick >= self._duration) then
			self._impl:OnEndAttack(true);
		end

		return true;
	end

	return false;
end

------------------------------------------------------
i3k_attack_omnislash = i3k_class("i3k_attack_omnislash",i3k_attack_state);
function i3k_attack_omnislash:ctor(impl)
	self._start	        = false;
	self._taktTime      = 0;
	self._twinkleTimes  = 0;
	self._targetRadius  = 0;	
	self._damageTick    = 0;
end

function i3k_attack_omnislash:Entry(fsm, from, evt, to)
	if i3k_attack_state.Entry(self, fsm, from, evt, to) then
		
		local s = self._impl._skill;
		local om = s._specialArgs.omnislash;
		local curPos = i3k_vec3_clone(self._impl._hero._curPos);
		
		if not om then
			return false;
		end
		
		local d = self._impl._skill._data;
		if not d then
			return false;
		end
		
		local userentity = nil;
		if self._impl._hero then
			userentity = self._impl._hero
			if self._impl._hero._hoster then
				userentity = self._impl._hero._hoster
			end
		end
	
		self._start     = false;
		self._Pos    =   curPos;
		self._taktTime      = om.taktTime ;
		self._twinkleTimes  = om.twinkleTimes;
		self._targetRadius  = om.targetRadius;
		self._damageTick	= 0;
		self._damageData 	= s._data.events[1];
		s:TriggerVFX(eVFXStartAttack,nil);
		
		return true;
	end
	
	return false;
end

function i3k_attack_omnislash:Leave(fsm, evt)
	i3k_attack_state.Leave(self, fsm, evt);
	if self._start then
		local entity = self._impl._hero;
		if entity then
			entity:SetPos(self._Pos, true);   
		end
	end
end

function i3k_attack_omnislash:OnLogic(dTick)
	if i3k_attack_state.OnLogic(self, dTick) then
		local hero = self._impl._hero;
		local logic = i3k_game_get_logic();
		if not self._start or self._timeTick >= self._taktTime then
			self._start 	= true;
			self._timeTick 	= 0;
			self._damageTick = self._damageTick + 1;
			if self._damageTick < self._twinkleTimes then
				local targets = self._impl:GetTargets(self._damageData);
				local target = targets[1];
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
						local world = i3k_game_get_world()
						if world then
							if not world._syncRpc then							
								self._impl:ProcessDamageByTarget(target, self._damageData,1);
							end	
						end		
					end
				else
					self._impl:OnEndAttack(true); 	
				end
			else
				self._impl:OnEndAttack(true);    		
			end	
		end	
		
 		return true;
	end
		
	return false;
end



------------------------------------------------------
i3k_attack_rush = i3k_class("i3k_attack_rush", i3k_attack_state);
function i3k_attack_rush:ctor()
end

function i3k_attack_rush:Entry(fsm, from, evt, to)
	if i3k_attack_state:Entry(self, fsm, from, evt, to) then
		local entity = self._impl._hero;
		local skill = self._impl._skill;

		if not skill._specialArgs.rushInfo then
			return false;
		end

		self._rushInfo	= skill._specialArgs.rushInfo;
		self._agent		= entity:GetAgent();
		self._inited	= false;

		local dir = entity._orientation;

		local dist = self._rushInfo.distance + skill:TalentSkillChange(entity, eSCType_Common, eSCCommon_rushdist);
		local time = dist / self._rushInfo.velocity;

		local moveInfo = i3k_engine_trace_line(entity._curPosE, dir, self._rushInfo.velocity, time);
		if moveInfo.valid then
			if self._agent then
				entity:ReleaseAgent();
			end

			self._inited	= true;
			self._deltaTime = 0;
			self._startPos	= entity._curPos;
			self._targetPos = moveInfo.path;
			self._middlePos	= i3k_vec3_div2(i3k_vec3_add1(self._startPos, self._targetPos), 2);
			if self._rushInfo.type == 2 then
				self._middlePos.y = self._middlePos.y + self._rushInfo.height;
			elseif self._rushInfo.type == 3 then
				local offset = entity:GetTitleOffset()
				entity:ChangeTitleOffset( offset + (self._rushInfo.height / 100));
				if entity:GetEntityType() == eET_Player then
					entity:chageTitleAction("jump");
				end
			end
			self._reachMiddle
							= false;
			self._moveTime	= 0;
			self._moveEnd	= true;
			self._movePos	= self._startPos;
			self._moveDir	= { x = 0, y = 0, z = 0 };

			if entity:IsPlayer() then
				i3k_sbean.map_rushstart(entity, self._targetPos, skill._id);
			elseif entity._hoster and entity._hoster:IsPlayer() then
				local guid = string.split(entity._guid, "|");
				i3k_sbean.map_rushstart(entity, self._targetPos, skill._id, tonumber(guid[2]));
			end

			return true;
		end
	end

	return false;
end

function i3k_attack_rush:Leave(fsm, evt)
	i3k_attack_state.Leave(self, fsm, evt);

	if self._inited then
		local entity = self._impl._hero;

		if self._agent then
			entity:CreateAgent();
		end

		if self._rushInfo.type == 3 then
			local offset = entity:GetTitleOffset()
			if entity:IsInSuperMode() and entity._weapon and entity._weapon.valid and entity._weapon.deform and entity._weapon.deform.type == 2 then
				local mcfg = i3k_db_models[entity._weapon.deform.args];
				if mcfg then
					offset = mcfg.titleOffset
				end
			elseif entity._missionMode.valid and entity._missionMode.mcfg.type == 2 then
				local mcfg = i3k_db_models[entity._missionMode.deform];
				if mcfg then
					offset = mcfg.titleOffset
				end
			end
			entity:ChangeTitleOffset(offset);
		end
		if entity:GetEntityType() == eET_Player then
			entity:chageTitleAction(i3k_db_common.engine.defaultStandAction);
		end
		self:SetPos(self._movePos, true);
	end
end

function i3k_attack_rush:OnUpdate(dTime)
	if i3k_attack_state.OnUpdate(self, dTime) then
		if not self._moveEnd then
			self._moveTime = i3k_integer(self._moveTime + dTime * 1000);
			if self._moveTime >= self._deltaTime then
				self._moveEnd 	= true;
				self._moveTime 	= self._deltaTime;
			end

			local cp = i3k_vec3_2_int(i3k_vec3_lerp(self._startPos, self._movePos, self._moveTime / self._deltaTime));
			self:SetPos(cp, false);
		end

		return true;
	end

	return false;
end

function i3k_attack_rush:OnLogic(dTick)
	if i3k_attack_state.OnLogic(self, dTick) then
		local entity = self._impl._hero;

		-- 同步上一逻辑帧位置
		self:SetPos(self._movePos, true);

		self._deltaTime	= dTick * i3k_db_common.engine.tickStep;
		self._moveTime	= 0;
		self._moveEnd	= true;

		if i3k_vec3_len(i3k_vec3_sub1(self._startPos, self._targetPos)) > 5 then
			self._moveEnd	= false;

			local fpos;
			if self._rushInfo.type == 1 or self._rushInfo.type == 3 then
				fpos = self:CalcMoveInfo1();
			elseif self._rushInfo.type == 2 then
				fpos = self:CalcMoveInfo2();
			else
				self._impl:OnEndRush();

				return false;
			end

			-- move x dir
			if self._moveDir.x > 0 then
				if self._movePos.x > fpos.x then self._movePos.x = fpos.x; end
			else
				if self._movePos.x < fpos.x then self._movePos.x = fpos.x; end
			end

			-- move y dir
			if self._moveDir.y > 0 then
				if self._movePos.y > fpos.y then self._movePos.y = fpos.y; end
			else
				if self._movePos.y < fpos.y then self._movePos.y = fpos.y; end
			end

			-- move z dir
			if self._moveDir.z > 0 then
				if self._movePos.z > fpos.z then self._movePos.z = fpos.z; end
			else
				if self._movePos.z < fpos.z then self._movePos.z = fpos.z; end
			end
		else
			self._impl:OnEndRush();
		end

		return true;
	end

	return false;
end

function i3k_attack_rush:CalcMoveInfo1()
	local p1 = i3k_vec3_clone(self._startPos);
	local p2 = i3k_vec3_clone(self._targetPos);

	self._moveDir = i3k_vec3_normalize1(i3k_vec3_sub1(p2, p1));

	local speed	= self._rushInfo.velocity / 1000;
	self._movePos = i3k_vec3_2_int(i3k_vec3_add1(p1, i3k_vec3_mul2(self._moveDir, speed * self._deltaTime)));

	return p2;
end

function i3k_attack_rush:CalcMoveInfo2()
	local p1 = i3k_vec3_clone(self._startPos);
	local p2 = i3k_vec3_clone(self._targetPos);
	local p3 = i3k_vec3_clone(self._middlePos);

	local p4 = i3k_vec3_clone(p1);
	p4.y = 0;
	local p5 = i3k_vec3_clone(p3);
	p5.y = 0;

	if not self._reachMiddle then
		if i3k_vec3_len(i3k_vec3_sub1(p4, p5)) < 5 then
			self._reachMiddle = true;
		end
	end

	self._moveDir = i3k_vec3_normalize1(i3k_vec3_sub1(p3, p1));
	if self._reachMiddle then
		self._moveDir = i3k_vec3_normalize1(i3k_vec3_sub1(p2, p1));
	end

	local speed	= self._rushInfo.velocity / 1000;
	self._movePos = i3k_vec3_2_int(i3k_vec3_add1(p1, i3k_vec3_mul2(self._moveDir, speed * self._deltaTime)));

	if self._reachMiddle then
		return p2;
	end

	return p3;
end

function i3k_attack_rush:SetPos(pos, real)
	local entity = self._impl._hero;
	if entity then
		--entity:SetPos(pos, real);
		entity:SetPos(i3k_world_pos_to_logic_pos(i3k_engine_get_valid_pos(i3k_logic_pos_to_world_pos(pos))), real);
	end

	if real then
		self._startPos = pos;
	end
end


------------------------------------------------------
i3k_attack_fly = i3k_class("i3k_attack_fly", i3k_attack_state);
function i3k_attack_fly:ctor()
end

function i3k_attack_fly:Entry(fsm, from, evt, to)
	if i3k_attack_state.Entry(self, fsm, from, evt, to) then
		local entity = self._impl._hero;
		local skill = self._impl._skill;

		if not skill._specialArgs.flyInfo then
			return false;
		end

		self._flyInfo	= skill._specialArgs.flyInfo;
		
		self._curPos	= i3k_vec3_clone(entity._curPos);

		if self._flyInfo.type == 1 then
			self._deltaTime	= 0;
			self._moveTime	= 0;
			self._moveEnd	= true;
			self._movePos	= self._curPos;
			self._moveDir	= { x = 0, y = 0, z = 0 };

			self._target = self._impl._targets[1];
			if not self._target then
				return false;
			end

			local cfg = i3k_db_models[self._flyInfo.modelID];
			if cfg then
				self._modelID = g_i3k_actor_manager:CreateSceneNode(cfg.path, string.format("attack_fly_model_%s_%d_%d", entity._guid, self._impl._id, self._flyInfo.modelID));
				if self._modelID > 0 then
					g_i3k_actor_manager:SetLocalTrans(self._modelID, i3k_vec3_to_engine(entity._curPosE));
					g_i3k_actor_manager:SetLocalScale(self._modelID, cfg.scale);
					g_i3k_actor_manager:SelectAction(self._modelID, self._flyInfo.action);
					g_i3k_actor_manager:Play(self._modelID, -1);
					g_i3k_actor_manager:EnterScene(self._modelID);
				end
			end

			return true;
		end
	end

	return false;
end

function i3k_attack_fly:Leave(fsm, evt)
	i3k_attack_state.Leave(self, fsm, evt);

	if self._flyInfo.type == 1 then
		if self._modelID and self._modelID > 0 then
			g_i3k_actor_manager:LeaveScene(self._modelID);
			g_i3k_actor_manager:ReleaseSceneNode(self._modelID);

			self._modelID = nil;
		end
	end
end

function i3k_attack_fly:OnUpdate(dTime)
	if i3k_attack_state.OnUpdate(self, dTime) then
		if self._flyInfo.type == 1 then
			if not self._moveEnd then
				self._moveTime = i3k_integer(self._moveTime + dTime * 1000);
				if self._moveTime >= self._deltaTime then
					self._moveEnd 	= true;
					self._moveTime 	= self._deltaTime;
				end

				local cp = i3k_vec3_2_int(i3k_vec3_lerp(self._curPos, self._movePos, self._moveTime / self._deltaTime));
				self:SetPos(cp, false);
			end
		end

		return true;
	end
end

function i3k_attack_fly:OnLogic(dTick)
	if i3k_attack_state.OnLogic(self, dTick) then
		if self._target:IsDead() then
			self._impl:OnEndFly(false);

			return false;
		end

		if self._flyInfo.type == 1 then
			local entity = self._impl._hero;

			-- 同步上一逻辑帧位置
			self:SetPos(self._movePos, true);

			if self._flyInfo.maxLife > 0 and self._timeTick > self._flyInfo.maxLife then
				self._impl:OnEndFly(false);

				return false;
			end

			self._deltaTime	= dTick * i3k_db_common.engine.tickStep;
			self._moveTime	= 0;
			self._moveEnd	= true;
			local p1 = i3k_vec3_clone(self._target._curPos);
			local p2 = i3k_vec3_clone(self._curPos);
			if i3k_vec3_dist(p1, p2) < 100 then -- TODO 1米??
				self._impl:OnEndFly(true);

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
		end

		return true;
	end

	return false;
end

function i3k_attack_fly:SetPos(pos, real)
	if self._modelID and self._modelID > 0 then
		g_i3k_actor_manager:SetLocalTrans(self._modelID, i3k_vec3_to_engine(i3k_logic_pos_to_world_pos(pos)));
	end

	if real then
		self._curPos = pos;
	end
end

------------------------------------------------------
i3k_attack_flash = i3k_class("i3k_attack_flash", i3k_attack_state);
function i3k_attack_flash:ctor()
	self._flash_step	= eFlashFadeInit;
	self._hide			= false;
end

function i3k_attack_flash:Entry(fsm, from, evt, to)
	if i3k_attack_state.Entry(self, fsm, from, evt, to) then
		return false;
	end

	return false;
end

function i3k_attack_flash:Leave(fsm, evt)
	i3k_attack_state.Leave(self, fsm, evt);
end

function i3k_attack_flash:OnLogic(dTick)
	if i3k_attack_state.OnLogic(dTick) then
		return true;
	end

	return false;
end

------------------------------------------------------
i3k_attack_attack = i3k_class("i3k_attack_attack", i3k_attack_state);
function i3k_attack_attack:ctor()
	self._eventTriNum	= 0;
	self._eventTriIdx	= 1;
	self._eventTriTime	= { };
	self._eventTriData	= { };
end

function i3k_attack_attack:Entry(fsm, from, evt, to)
	if not i3k_attack_state.Do(self, fsm, evt) then return false; end

	local d = self._impl._skill._data;
	if not d then
		return false;
	end

	self._eventTriNum	= 0;
	self._eventTriIdx	= 1;
	self._eventTriTime	= { };
	self._eventTriData	= { };

	if self._impl._flightSkill then -- TODO
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
					if self._impl._hero then
						user = self._impl._hero
						if self._impl._hero._hoster then
							user = self._impl._hero._hoster
						end
					end
					table.insert(self._eventTriTime, v.triTime+ self._impl._skill:TalentSkillChange(user,eSCType_Event,eSCEvent_time,k));
					table.insert(self._eventTriData, v);
				end
			end
		end
	end

	self._impl._skill:TriggerVFX(eVFXStartAttack, nil);

	return true;
end

function i3k_attack_attack:OnLogic(dTick)
	if not i3k_attack_state.OnLogic(self, dTick) then return false; end

	if self._impl._flightSkill then --TODO
	else
		local triIdx = self._eventTriIdx;

		if triIdx <= self._eventTriNum then
			if self._impl._duration > self._eventTriTime[triIdx] then
				self._impl:ProcessDamage(self._eventTriData[triIdx], triIdx);
				self._eventTriIdx = self._eventTriIdx + 1;
			end
		end
	end

	if self._eventTriIdx > self._eventTriNum then
		self._impl:OnEndAttack(true);
	end

	return true;
end

------------------------------------------------------
i3k_attack_stop = i3k_class("i3k_attack_stop", i3k_attack_state);
function i3k_attack_stop:ctor()
end

function i3k_attack_stop:Entry(fsm, from, evt, to)
	if not i3k_attack_state.Do(self, fsm, evt) then return false; end
	
	local user = nil
	if self._impl._hero then
		user = self._impl._hero
		if self._impl._hero._hoster then
			user = self._impl._hero._hoster
		end
	end
	self._duration = self._impl._skill._duration + self._impl._skill:TalentSkillChange(user,eSCType_Common,eSCCommon_time);

	return true;
end

function i3k_attack_stop:OnLogic(dTick)
	if not i3k_attack_state.OnLogic(self, dTick) then return false; end

	if self._impl._duration > self._duration then
		self._impl:StopAttack(true);
	end

	return true;
end

------------------------------------------------------
local g_i3k_skill_guid = 0;

i3k_attacker = i3k_class("i3k_attacker", BASE);
function i3k_attacker:ctor(guid, child)
	self._hero			= nil;
	self._skill			= nil;
	self._isChild		= child or false;
	self._curAction		= "";
	self._endAttack		= false;
	self._duration		= 0;
	self._aoeSkill		= false;
	self._flightSkill	= false;
	self._attackSuc		= false;
	self._targetPos		= i3k_vec3(0, 0, 0);
	self._attack_sm		= i3k_state_machine.new(eAttackStateStop);
	self._TriIdx		= 0;
	self._comboTargets  = { };
	self._comboTime  	= 100;

	-- init state machine
	local init_state = i3k_attack_init.new(self);
	local chrg_state = i3k_attack_charge.new(self);
	local spel_state = i3k_attack_spell.new(self);
	local cast_state = i3k_attack_cast.new(self);
	local rush_state = i3k_attack_rush.new(self);
	local fly_state  = i3k_attack_fly.new(self);
	local flsh_state = i3k_attack_flash.new(self);
	local attk_state = i3k_attack_attack.new(self);
	local stop_state = i3k_attack_stop.new(self);
	local omnislash_state = i3k_attack_omnislash.new(self);

	self._attack_sm:AddTransition(eAttackStateInit,		eAttackEventSpell,	eAttackStateSpell,	spel_state);
	self._attack_sm:AddTransition(eAttackStateInit,		eAttackEventStop,	eAttackStateStop,	stop_state);

	self._attack_sm:AddTransition(eAttackStateSpell,	eAttackEventCharge,	eAttackStateCharge,	chrg_state);
	self._attack_sm:AddTransition(eAttackStateSpell,	eAttackEventStop,	eAttackStateStop,	stop_state);

	self._attack_sm:AddTransition(eAttackStateCharge,	eAttackEventRush,	eAttackStateRush,	rush_state);
	self._attack_sm:AddTransition(eAttackStateCharge,	eAttackEventFly,	eAttackStateFly,	 fly_state);
	self._attack_sm:AddTransition(eAttackStateCharge,	eAttackEventCast,	eAttackStateCast,	cast_state);
	self._attack_sm:AddTransition(eAttackStateCharge,	eAttackEventAttack,	eAttackStateAttack,	attk_state);
	self._attack_sm:AddTransition(eAttackStateCharge,	eAttackEventStop,	eAttackStateStop,	stop_state);
	self._attack_sm:AddTransition(eAttackStateCharge,  eAttackEventOmnislash,   eAttackStateOmnislash,   omnislash_state);

	self._attack_sm:AddTransition(eAttackStateRush,		eAttackEventCast,	eAttackStateCast,	cast_state);
	self._attack_sm:AddTransition(eAttackStateRush,		eAttackEventAttack,	eAttackStateAttack,	attk_state);
	self._attack_sm:AddTransition(eAttackStateRush,   eAttackEventOmnislash,  eAttackStateOmnislash,  omnislash_state);
	self._attack_sm:AddTransition(eAttackStateRush,		eAttackEventStop,	eAttackStateStop,	stop_state);
	

	self._attack_sm:AddTransition(eAttackStateFly,		eAttackEventCast,	eAttackStateCast,	cast_state);
	self._attack_sm:AddTransition(eAttackStateFly,		eAttackEventAttack,	eAttackStateAttack,	attk_state);
	self._attack_sm:AddTransition(eAttackStateFly,    eAttackEventOmnislash,  eAttackStateOmnislash,  omnislash_state);
	self._attack_sm:AddTransition(eAttackStateFly,		eAttackEventStop,	eAttackStateStop,	stop_state);
	
	

	self._attack_sm:AddTransition(eAttackStateCast,		eAttackEventStop,	eAttackStateStop,	stop_state);
	
	self._attack_sm:AddTransition(eAttackStateOmnislash,   eAttackEventStop,	eAttackStateStop,	stop_state);

	self._attack_sm:AddTransition(eAttackStateAttack,	eAttackEventStop,	eAttackStateStop,	stop_state);

	self._attack_sm:AddTransition(eAttackStateStop,		eAttackEventInit,	eAttackStateInit,	init_state);
end

function i3k_attacker:Create(hero, skill, targets, passive, parentSkill)
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
		self._passive		= passive;
		self._stype			= skill._gtype;

		self._attack_sm:ProcessEvent(eAttackEventInit);

		self._childs = { };
		for k, v in ipairs(skill._child_skill) do
			local child = i3k_attacker_create(hero, v, targets, passive, true);
			if child then
				table.insert(self._childs, child);
			end
		end

		return true;
	end

	return false;
end

function i3k_attacker:Release()
	for k, v in ipairs(self._childs) do
		v:Release();
	end

	self:StopAttack(false);

	if self._warnEffectID then
		g_i3k_actor_manager:ReleaseSceneNode(self._warnEffectID);

		self._warnEffectID = nil;
	end

	if self._alter_effect_id then
		self._hero._entity:RmvHosterChild(self._alter_effect_id);
	end

	if self._models then
		for k, v in ipairs(self._models) do
			g_i3k_actor_manager:LeaveScene(v);
			g_i3k_actor_manager:ReleaseSceneNode(v);
		end
	end

	BASE.Release(self);
end

function i3k_attacker:NextSequence(skill)
	self._triNextSeq = true;

	-- first release current attack
	self._attack_sm:ProcessEvent(eAttackEventStop);

	self._skill:TriggerVFX(eVFXEnd, nil);
	self._skill:ResetVFX();

	for k, v in ipairs(self._childs) do
		v:Release();
	end

	if self._warnEffectID then
		g_i3k_actor_manager:ReleaseSceneNode(self._warnEffectID);

		self._warnEffectID = nil;
	end

	if self._alter_effect_id then
		self._hero._entity:RmvHosterChild(self._alter_effect_id);
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

	-- second create new attack use next sequence skill
	return self:Create(self._hero, skill, self._targets, self._passive, self._parentSkill or self._skill);
end

function i3k_attacker:CreateModel(modelID, action)
	local cfg = i3k_db_models[modelID];
	if cfg then
		if not self._models then
			self._models = { };
		end

		local entity = self._hero;

		local _id = g_i3k_actor_manager:CreateSceneNode(cfg.path, string.format("attack_fly_model_%s_%d_%d", entity._guid, self._id, modelID));
		if _id > 0 then
			table.insert(self._models, _id);
			local pos = i3k_vec3_clone(entity._curPosE);

			g_i3k_actor_manager:SetLocalTrans(_id, i3k_vec3_to_engine(pos));
			g_i3k_actor_manager:SetLocalScale(_id, cfg.scale);
			g_i3k_actor_manager:SelectAction(_id, action);
			g_i3k_actor_manager:Play(_id, -1);
			g_i3k_actor_manager:EnterScene(_id);

			return _id;
		end
	end

	return -1;
end

function i3k_attacker:OnUpdate(dTime)
	BASE.OnUpdate(self, dTime);

	local state = self._attack_sm._cur_state_obj;
	if state ~= nil then
		state:OnUpdate(dTime);
	end

	for k, v in ipairs(self._childs) do
		v:OnUpdate(dTime);
	end
end

function i3k_attacker:OnLogic(dTick)
	--if BASE.OnLogic(self, dTick) then
	if dTick > 0 then
		self._duration = self._duration + dTick * i3k_engine_get_tick_step();

		if self._warnEffectID then
			if self._duration > self._skill._warnTime then
				g_i3k_actor_manager:ReleaseSceneNode(self._warnEffectID);

				self._warnEffectID = nil;
			end
		end

		local state = self._attack_sm._cur_state_obj;
		if state ~= nil then
			state:OnLogic(dTick);
		end
		local count = 0;
		if self._comboTargets then
			for k,v in pairs(self._comboTargets) do  
				count = count + 1  
			end  
		end

		if count > 0 then
			self:ProcessCombo();
		end

		for k, v in ipairs(self._childs) do
			v:OnLogic(dTick);
		end

		return not self._endAttack;
	end

	return true;
end

function i3k_attacker:ProcessCombo()
	--连刺
	comboTargets = self._comboTargets;
	events = self._skill._data.events;
	local eventFlag = false;
	local logic = i3k_game_get_logic();
	for sdata, val in pairs(comboTargets) do
		if events ~= nil then
			for k, v in pairs(events) do
				if sdata == events[k] then
					eventFlag = true;
				end
			end
		end
		if eventFlag then
			if self._duration >= self._comboTime then
				self._duration = 0;
				for k, v in pairs(comboTargets[sdata]) do
					if logic then
						local world = logic:GetWorld();
						if world and not world._syncRpc then
							self:ProcessDamageByTarget(v, sdata, 1, true);
						end				
					end
				end
				comboTargets[sdata] = nil;
			end	
		else
			comboTargets[sdata] = nil;
		end
	end
	self._comboTargets = { };
end

function i3k_attacker:StartAttack()
	local h = self._hero;
	local s = self._skill;

	local getCurPos = function()
		local curPos = i3k_vec3_clone(h._curPos);
		if s._initPos then
			curPos = i3k_vec3_clone(s._initPos);
		end

		return curPos;
	end

	self._duration 	= 0;
	self._endAttack	= false;
	self._targetCheck
					= nil;
	self._attackSuc	= false;
	self._inheritTargets
					= nil;
	self._facade	= not self._isChild and not self._passive and not s._ignoreAct;

	-- play action
	if self._facade then
		h:Play(self._curAction, 1);

		--h:PlaySkillAttackEffect();
	end

	local dir = h._orientation;

	local scope = s._scope;

	if scope.type == eSScopT_Owner then
		--h:PlayAttackEffectByTargets({ h }, 0);
		if self._facade then
			h:PlayAttackEffectByPos(getCurPos(), 0);
		end
	elseif scope.type == eSScopT_Single then
		self._targetCheck = function(obj)
			if #self._targets > 0 then
				return false;
			end

			local p1 = i3k_vec3_clone(h._curPos);
			local p2 = i3k_vec3_clone(obj.entity._curPos);
			if i3k_vec3_dist(p1, p2) < s._range then
				table.insert(self._targets, obj.entity);

				h:AddEnmity(obj.entity, true);

				local changetarget = false
				if s._specialArgs and s._specialArgs.castInfo and s._specialArgs.castInfo.changetarget and s._specialArgs.castInfo.changetarget == 1 then
					changetarget = true;
				end

				self._facade = not _isChild and not self._passive and changetarget
				if self._facade then
					local rot_y = i3k_vec3_angle1(p2, p1, { x = 1, y = 0, z = 0 });
					h:SetFaceDir(0, rot_y, 0);
				end

				return true;
			end

			return false;
		end

		if self._facade then
			h:PlayAttackEffectByTargets(self._targets, 0);
		end
	elseif scope.type == eSScopT_CricleO then
		self._targetCheck = function(obj)
			local radius = (h:GetRadius() + obj.entity:GetRadius());

			local dist = i3k_vec3_dist(obj.entity._curPos, getCurPos());

			return (dist - radius) <= scope.arg1;
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

		if self._facade then
			h:PlayAttackEffectByPos(getCurPos(), 0);
		end
	elseif scope.type == eSScopT_CricleT then
		local pos = i3k_vec3_add1(getCurPos(), i3k_vec3_mul2(dir, scope.arg1));

		self._targetCheck = function(obj)
			local radius = obj.entity:GetRadius();
			local dist = i3k_vec3_len(i3k_vec3_sub1(obj.entity._curPos, pos)) - radius;

			return dist <= scope.arg2;
		end

		if s._warnEff then
			local cfg = i3k_db_effects[s._warnEff];
			if cfg then
				self._warnEffectID = g_i3k_actor_manager:CreateSceneNode(cfg.path, string.format("entity_alert_area_%s_effect_%d", h._guid, s._warnEff));
				if self._warnEffectID > 0 then
					g_i3k_actor_manager:SetLocalTrans(self._warnEffectID, i3k_vec3_to_engine(i3k_logic_pos_to_world_pos(pos)));
					g_i3k_actor_manager:SetLocalScale(self._warnEffectID, cfg.radius);
				end
			end
		end

		if self._facade then
			local pos_f = i3k_vec3_clone(pos);
			pos_f.y = 150;
			h:PlayAttackEffectByPos(pos_f, 0);
		end
	elseif scope.type == eSScopT_SectorO then
		local pos1 = i3k_vec3_clone(getCurPos());

		self._targetCheck = function(obj)
			local rot = math.pi * 2 - h._faceDir.y;
			local radian1 = rot + ((scope.arg2 / 2) / 180) * math.pi;
			local radian2 = rot - ((scope.arg2 / 2) / 180) * math.pi;

			local dir2 = i3k_vec3_from_angle(radian1);
			local dir3 = i3k_vec3_from_angle(radian2);

			local r1 = obj.entity:GetRadius();
			local r2 = (h:GetRadius() + obj.entity:GetRadius());

			local dist = i3k_vec3_dist(obj.entity._curPos, getCurPos());
			if (dist - r2) > scope.arg1 then
				return false;
			end

			local arg1 = scope.arg1;

			local pos3 = i3k_vec3_add1(getCurPos(), i3k_vec3_mul2(dir2, arg1));
			local pos4 = i3k_vec3_add1(getCurPos(), i3k_vec3_mul2(dir3, arg1));

			local multiply = function(p, p1, p2)
				return (p.z - p1.z) * (p.x - p2.x) - (p.z - p2.z) * (p.x - p1.x);
			end

			local contain = function(mp1, mp2, mp)
				local _pos = getCurPos();

				local _dp = i3k_vec3_sub1(mp, _pos);

				local _d1 = multiply(mp, mp1, _pos);
				local _d2 = multiply(mp, mp2, _pos);

				if _d1 < 0 and _d2 > 0 or (_d1 == 0 and _d2 == 0)then
					return true;
				end

				return false;
			end
			local becontained = contain(pos3, pos4, obj.entity._curPos);
			local changetarget = false
			if s._specialArgs and s._specialArgs.castInfo and s._specialArgs.castInfo.changetarget and s._specialArgs.castInfo.changetarget == 1 then
				changetarget = true;
			end

			self._facade	= not _isChild and not self._passive and changetarget
			if self._facade then
				if not becontained and not self._newtarget then
					self._newtarget = obj.entity
				end
				if self._newtarget and (becontained or #self._targets > 0) then
					self._newtarget = nil;
				end
			end

			return becontained
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

		if self._facade then
			local pos_f = i3k_vec3_add1(getCurPos(), i3k_vec3_mul2(dir, scope.arg1 / 2));
			pos_f.y = 150;
			h:PlayAttackEffectByPos(pos_f, 0);
		end
	elseif scope.type == eSScopT_RectO then
		local dir2 = i3k_vec3_normalize1(i3k_vec3_cp(i3k_vec3(0, 1, 0), dir));

		local arg1 = scope.arg1;
		local arg2 = scope.arg2;

		local pos1 = i3k_vec3_clone(getCurPos());

		self._targetCheck = function(obj)
			local r1 = obj.entity:GetRadius();
			local r2 = (h:GetRadius() + obj.entity:GetRadius());

			local pos3 = i3k_vec3_add1(getCurPos(), i3k_vec3_mul2(dir, arg1 + r2));

			local _posR1 = i3k_vec3_add1(pos1, i3k_vec3_mul2(dir2,  arg2 + r1));
			local _posR2 = i3k_vec3_add1(pos1, i3k_vec3_mul2(dir2, -arg2 - r1));

			local _posR3 = i3k_vec3_add1(pos3, i3k_vec3_mul2(dir2,  arg2 + r1));
			local _posR4 = i3k_vec3_add1(pos3, i3k_vec3_mul2(dir2, -arg2 - r1));

			local multiply = function(p, p1, p2)
				return (p.z - p1.z) * (p.x - p2.x) - (p.z - p2.z) * (p.x - p1.x);
			end

			local contain = function(mp1, mp2, mp3, mp4, mp)
				local _d1 = multiply(mp, mp1, mp2);
				local _d2 = multiply(mp, mp3, mp4);
				local _d3 = multiply(mp, mp1, mp3);
				local _d4 = multiply(mp, mp2, mp4);

				if _d1 * _d2 <= 0 and _d3 * _d4 <= 0 then
					return true;
				end

				return false;
			end

			return contain(_posR1, _posR2, _posR3, _posR4, obj.entity._curPos);
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

		if self._facade then
			local pos_f = i3k_vec3_add1(getCurPos(), i3k_vec3_mul2(dir, scope.arg1));
			pos_f.y = 150;
			h:PlayAttackEffectByPos(pos_f, 0);
		end
	elseif scope.type == eSScopT_MulC then
		self._targetCheck = function(obj)
			local radius = (h:GetRadius() + obj.entity:GetRadius());

			return false;
		end
	elseif scope.type == eSScopT_Ellipse then
		local pos1 = i3k_vec3_clone(getCurPos());

		self._targetCheck = function(obj)
			local r1 = h:GetRadius();
			local r2 = obj.entity:GetRadius();
			local r = r1 + r2
			local c = math.sqrt((scope.arg1+r) * (scope.arg1+r) - (scope.arg2+r) * (scope.arg2+r));
			local rot1 = h._faceDir.y - math.pi / 2;
			local _p1 = { };
				_p1.x = pos1.x + math.cos(rot1) * c;
				_p1.y = obj.entity._curPos.y;
				_p1.z = pos1.z - math.sin(rot1) * c;
			local _p2 = { };
				_p2.x = pos1.x - math.cos(rot1) * c;
				_p2.y = obj.entity._curPos.y;
				_p2.z = pos1.z + math.sin(rot1) * c;

			local dist1 = i3k_vec3_dist(obj.entity._curPos, _p1)
			local dist2 = i3k_vec3_dist(obj.entity._curPos, _p2)

			return (dist1 + dist2) < (scope.arg1 + r) * 2;
		end
	end

	if self._warnEffectID and self._warnEffectID > 0 then
		g_i3k_actor_manager:EnterScene(self._warnEffectID);

		g_i3k_actor_manager:SetLocalRotation(self._warnEffectID, Engine.SVector3(h._faceDir.x, h._faceDir.y - math.pi * 0.5, h._faceDir.z));
		g_i3k_actor_manager:Play(self._warnEffectID, -1);
	end
end

function i3k_attacker:StopAttack(result)
	if not self._endAttack then
		self._endAttack = true;

		self._attack_sm:ProcessEvent(eAttackEventStop);

		self._skill:TriggerVFX(eVFXEnd, nil);
		self._skill:ResetVFX();

		if not self._skill._canAttack then
			self._hero._behavior:Clear(eEBDisAttack);
		end
		self._hero:StopAttack(self._parentSkill or self._skill, result, self._attackSuc);

	end
end

function i3k_attacker:StartRush()
	-- 切换到冲锋状态
	return self._attack_sm:ProcessEvent(eAttackEventRush);
end

function i3k_attacker:StartFly()
	-- 切换到飞行技能
	return self._attack_sm:ProcessEvent(eAttackEventFly);
end

function i3k_attacker:StartFlash()
	-- 切换到闪现状态
	return self._attack_sm:ProcessEvent(eAttackEventFlash);
end

function i3k_attacker:StartOmnislash()
	--切换到无敌斩状态
	return self._attack_sm:ProcessEvent(eAttackEventOmnislash);
end

function i3k_attacker:StartSummon(info)
	if info then
		if info.type == 1 then
			return self:Summon1(info);
		elseif info.type == 2 then
			return self:Summon2(info);
		end
	end

	return false;
end

function i3k_attacker:Summon1(info)
	if not info or info.type ~= 1 then
		return false;
	end
	local world = i3k_game_get_world();
	if world and not world._syncRpc then
		local s = self._skill;

		local scount = info.count;
		local childs = self._hero:GetSpecialChild(s._id);
		if childs then
			scount = scount - #childs;
		end

		for k = 1, scount do
			local posE = i3k_vec3_clone(self._hero._curPosE);

			local findCnt = 0;
			while true do
				local rnd_x = 0;
				local rnd_z = 0;
				
				local rnd_rot = i3k_engine_get_rnd_f(info.summontype * math.pi / 720 * -1, info.summontype * math.pi / 720);
				local rot = math.pi * 2 - self._hero._faceDir.y - rnd_rot;
				local dir = i3k_vec3_from_angle(rot);
				rnd_x = dir.x * info.radius / 100;
				rnd_z = dir.z * info.radius / 100;

				local _pos = i3k_vec3_clone(posE);
				_pos.x = posE.x + rnd_x;
				_pos.y = posE.y + 1;
				_pos.z = posE.z + rnd_z;
				_pos = i3k_engine_get_valid_pos(i3k_vec3_to_engine(_pos));

				local paths = g_i3k_mmengine:FindPath(self._hero._curPosE, i3k_vec3_to_engine(_pos));
				if paths:size() > 0 then
					posE = paths:front();

					break;
				end

				findCnt = findCnt + 1;
				if findCnt > 5 then
					break;
				end
			end

			local pos = i3k_world_pos_to_logic_pos(posE);

			local M = require("logic/entity/i3k_monster");
			--local monster = M.i3k_monster.new(i3k_gen_entity_guid());
			local monster = M.i3k_monster.new(i3k_gen_entity_guid_new(M.i3k_monster.__cname,i3k_gen_entity_guid()));
			if monster:Create(info.id1, false) then
				monster._summonID = s._id;

				monster:AddAiComp(eAType_IDLE);
				monster:AddAiComp(eAType_AUTO_MOVE);
				monster:AddAiComp(eAType_ATTACK);
				monster:AddAiComp(eAType_AUTO_SKILL);
				monster:AddAiComp(eAType_FIND_TARGET);
				monster:AddAiComp(eAType_SPA);
				monster:AddAiComp(eAType_SHIFT);
				monster:AddAiComp(eAType_DEAD);
				monster:AddAiComp(eAType_GUARD);
				monster:AddAiComp(eAType_RETREAT);
				monster:AddAiComp(eAType_FEAR);
				monster:Birth(pos);
				monster:Show(true, true, 100);
				monster:SetGroupType(eGroupType_E);
				monster:SetFaceDir(0, 0, 0);

				self._hero:AddChild(monster, info.spawn_eff);
			end
		end
	end
	return false; -- 直接切换到攻击
end

function i3k_attacker:Summon2(info)
	if not info or info.type ~= 2 then
		return false;
	end
	local world = i3k_game_get_world();
	if world and not world._syncRpc then
		
		local s = self._skill;

		for k = 1, info.count do
			local posE = i3k_vec3_clone(self._hero._curPosE);

			local findCnt = 0;
			while true do
				local rnd_x = 0;
				local rnd_z = 0;
				
				local rnd_rot = i3k_engine_get_rnd_f(info.summontype*math.pi / 720 * -1, info.summontype*math.pi / 720);
				local rot = math.pi * 2 - self._hero._faceDir.y - rnd_rot;
				local dir = i3k_vec3_from_angle(rot);
				rnd_x = dir.x * info.radius/ 100
				rnd_z = dir.z * info.radius/ 100
				

				local _pos = i3k_vec3_clone(posE);
				_pos.x = posE.x + rnd_x;
				_pos.y = posE.y + 1;
				_pos.z = posE.z + rnd_z;
				_pos = i3k_engine_get_valid_pos(i3k_vec3_to_engine(_pos));

				local paths = g_i3k_mmengine:FindPath(self._hero._curPosE, i3k_vec3_to_engine(_pos));
				if paths:size() > 0 then
					posE = paths:front();

					break;
				end

				findCnt = findCnt + 1;
				if findCnt > 5 then
					break;
				end
			end

			local pos = i3k_world_pos_to_logic_pos(posE);

			local _S = require("logic/entity/i3k_skill_entity");
			--local entity = _S.i3k_skill_entity.new(i3k_gen_entity_guid());
			local movespeed	= info.movespeed + self._skill:TalentSkillChange(self._hero,eSCType_Common,eSCCommon_movespeed)
			local entity = _S.i3k_skill_entity.new(i3k_gen_entity_guid_new(_S.i3k_skill_entity.__cname,i3k_gen_entity_guid()));
			if entity:Create(info.id2, info.id1, self._hero, pos, s._level, s._realm,movespeed) then
				entity._summonID = s._id;
				self._hero:AddChild(entity);
				if movespeed > 0 then
					entity:SetTarget(self._hero);
				end
			end
		end
	end
	return false; -- 直接切换到攻击
end

function i3k_attacker:StartShift(info)
	local h = self._hero;
	local s = self._skill;

	local rot = math.pi * 2 - h._faceDir.y;
	local dir1 = i3k_vec3_from_angle(rot);
	local dir2 = i3k_vec3_normalize1(i3k_vec3_cp(i3k_vec3(0, 1, 0), dir1));

	local scope = s._scope;

	local arg2 = scope.arg2;
	
	local pos1 = i3k_vec3_clone(h._curPos);

	local alives = { };
	if #h._alives[2] > 0 then
		for k, v in ipairs(h._alives[2]) do
			table.insert(alives, v);
		end
	end

	if #h._alives[3] > 0 then
		for k, v in ipairs(h._alives[3]) do
			table.insert(alives, v);
		end
	end

	local logic = i3k_game_get_logic();
	if logic then
		local world = logic:GetWorld();
		if world then
			if (world._mapType ~= g_BASE_DUNGEON and world._openType ~= g_FIELD) or (world._mapType == g_BASE_DUNGEON and world._openType == g_BASE_DUNGEON)then
				local shiftDir = nil;
				self._inheritTargets = { };
				local shiftInfo = { };
				for k, v in ipairs(alives) do
					local target = v.entity;
					if self._targetCheck(v) then
						local dist2 = math.abs(info.distance);
						local dist3 = math.abs(i3k_vec3_dist_2d(h._curPos, target._curPos));
						local dist1 = math.min(dist3, dist2);

						if not shiftDir then
							shiftDir = i3k_vec3_sub1(target._curPos, self._hero._curPos);
							shiftDir.y = 0;
							shiftDir = i3k_vec3_normalize1(shiftDir);
						end

						if dist3 <= 0.5 then
							shiftDir = h._orientation;
						end

						local sign = 1;
						if info.distance < 0 then
							sign = -1;
						end

						if target.OnShift then
							shiftInfo.type		= info.type;
							if info.type == 3 then
								local deltaDist = 150 + i3k_engine_get_rnd_u(0, 50);
								if dist1 > deltaDist then
									dist1 = dist1 + deltaDist;
								end

								shiftInfo.distance	= dist1 * sign;
							else
								shiftInfo.distance	= ((dist2 - dist1) + 150 + i3k_engine_get_rnd_u(0, 50)) * sign;
							end
							shiftInfo.height	= info.height;
							shiftInfo.velocity	= info.velocity;

							if h:IsPlayer() then
								local pos = i3k_vec3_add1(target._curPosE, i3k_vec3_mul2(shiftDir, shiftInfo.distance / 100));

								local moveInfo = i3k_engine_trace_line_ex(target._curPosE, pos);
								if moveInfo.valid then
									local toPos = moveInfo.path;
									if dist2 == 0 then
										toPos = target._curPos;

										shiftInfo.distance = 0;
									end

									--i3k_log("shift step 3 cur pos = " .. i3k_format_pos(target._curPos) .. " new pos = " .. i3k_format_pos(toPos));

									local guid = string.split(target._guid, "|")
									if target:GetEntityType() == eET_Player or target:GetEntityType() == eET_Monster then
										i3k_sbean.map_shiftstart(h, toPos, tonumber(guid[2]), target:GetEntityType(), s._id);
									elseif target:GetEntityType() == eET_Mercenary then
										i3k_sbean.map_shiftstart(h,toPos, tonumber(guid[2]), eET_Mercenary, s._id, tonumber(guid[3]));
									end

									--target:OnShift(shiftDir, shiftInfo, h);
								end
							elseif h:GetEntityType() == eET_Mercenary then
								local player = i3k_game_get_player_hero();
								if player then
									local hoster = h:GetHoster();
									if hoster and hoster:IsPlayer() then
										local pos = i3k_vec3_add1(target._curPosE, i3k_vec3_mul2(shiftDir, shiftInfo.distance / 100));

										local moveInfo = i3k_engine_trace_line_ex(target._curPosE, pos);
										if moveInfo.valid then
											local toPos = moveInfo.path;
											if dist2 == 0 then
												toPos = target._curPos;

												shiftInfo.distance = 0;
											end

											local sguid = string.split(h._guid, "|")
											local guid = string.split(target._guid, "|")
											if target:GetEntityType() == eET_Player or target:GetEntityType() == eET_Monster then
												i3k_sbean.map_shiftstart(h, toPos, tonumber(guid[2]), target:GetEntityType(), s._id, nil, tonumber(sguid[2]))
											elseif target:GetEntityType() == eET_Mercenary then
												i3k_sbean.map_shiftstart(h, toPos, tonumber(guid[3]), eET_Mercenary, s._id, tonumber(guid[2]), tonumber(guid[2]), tonumber(sguid[2]))
											end
											--i3k_log("onshift2")
											--target:OnShift(shiftDir, shiftInfo, h);
										end
									end
								end
							end
						end
					end
				end
			else
				local shiftDir = nil;

				self._inheritTargets = { };
				for k, v in ipairs(alives) do
					local target = v.entity;
					if self._targetCheck(v) then
						local odds1 = i3k_engine_get_rnd_u(0, 10000);
						local odds2 = (s._specialArgs.shiftInfo.odds + s:TalentSkillChange(self, eSCType_Common, eSCCommon_shiftodds)) or 10000;
						if odds1 <= odds2 then
							if not shiftDir then
								shiftDir = i3k_vec3_sub1(target._curPos, self._hero._curPos);
								shiftDir.y = 0;
								shiftDir = i3k_vec3_normalize1(shiftDir);
							end

							local sign = 1;
							if info.distance < 0 then
								sign = -1;
							end

							local dist2 = math.abs(info.distance);
							local dist1 = math.min(i3k_vec3_dist_2d(h._curPos, target._curPos), dist2);

							if target.OnShift then
								local shiftInfo = { };
									shiftInfo.type		= info.type;
									if info.type == 3 then
										local deltaDist = 150 + i3k_engine_get_rnd_u(0, 50);
										if dist1 > deltaDist then
											dist1 = dist1 + deltaDist;
										end

										shiftInfo.distance	= dist1 * sign;
									else
										shiftInfo.distance	= ((dist2 - dist1) + 150 + i3k_engine_get_rnd_u(0, 50)) * sign;
									end
									--shiftInfo.distance	= ((dist2 - dist1) + 150 + i3k_engine_get_rnd_u(0, 50)) * sign;
									shiftInfo.height	= info.height;
									shiftInfo.velocity	= info.velocity;
								target:OnShift(shiftDir, shiftInfo);
							end
						end

						table.insert(self._inheritTargets, target);
					end
				end
			end
		end
	end
end

function i3k_attacker:OnTriSkill(target, cfgs)
	if not self._hero:IsDead() then
		local scfg = i3k_db_skills[cfgs.skillID];
		if scfg then
			local skill = require("logic/battle/i3k_skill");
			if skill then
				local _lvl = cfgs.level;
				if _lvl == -1 then
					_lvl = self._skill._level;
				end

				local _skill = skill.i3k_skill_create(self._hero, scfg, math.max(1, _lvl), 0, skill.eSG_TriSkill);
				if _skill then
					if cfgs.posType == 1 then
						_skill._initPos = target._curPos;
					elseif cfgs.posType == 2 then
					end

					self._hero:StartAttack(_skill);
				end
			end
		end
	end
end

function i3k_attacker:OnEndInit()
	self:StartAttack();

	-- 切换到吟唱状态
	self._attack_sm:ProcessEvent(eAttackEventSpell);
end

function i3k_attacker:OnEndSpell()
	-- 切换到蓄力状态
	self._attack_sm:ProcessEvent(eAttackEventCharge);
end

function i3k_attacker:OnEndCharge()
	-- 切换到攻击状态
	if not self:SwitchAttackBehavior() then
		self:SwitchAttackState();
	end
end

function i3k_attacker:OnEndRush()
	self._skill:TriggerVFX(eVFXEndBehavior, nil);

	self:SwitchAttackState();
end

function i3k_attacker:OnEndFly(suc)
	if suc then
		self:SwitchAttackState();
	else
		self:StopAttack(false);
	end
end

function i3k_attacker:OnEndSummon()
	self._skill:TriggerVFX(eVFXEndBehavior, nil);

	self:SwitchAttackState();
end

function i3k_attacker:OnEndFlash()
	self:SwitchAttackState();
end

function i3k_attacker:SwitchAttackState()
	local s = self._skill;

	if s._specialArgs.castInfo then
		-- 切换到引导状态
		self._attack_sm:ProcessEvent(eAttackEventCast);
	else
		-- 切换到攻击状态
		self._attack_sm:ProcessEvent(eAttackEventAttack);
	end
end

function i3k_attacker:OnEndAttack()
	--self:StopAttack(result);

	self._attack_sm:ProcessEvent(eAttackEventStop);
end

function i3k_attacker:IsCombo(sdata, targets)
	-- 连刺		
	local data = { };				
	local rnd = i3k_engine_get_rnd_f(0, 1);
	local combo = self._hero:GetPropertyValue(ePropID_combo);
	if combo and rnd < combo and self._comboTargets then
		for k, v in pairs(targets) do
			table.insert(data, v);
		end
		-- 连刺提示
		if self._hero:IsPlayer() then 
			self._hero:ShowInfo(self._hero, eEffectID_DeBuff.style, i3k_get_string(1034), nil);
		end
		self._comboTargets[sdata] = data;
	end
end

function i3k_attacker:ProcessDamage(sdata, ticknum)
	local logic = i3k_game_get_logic();
	if logic then
		local world = logic:GetWorld();
		if world then
			if not world._syncRpc then
				local targets = self:GetTargets(sdata);	
				if targets and #targets > 0 then
					for k, v in pairs(targets) do
						if v and not v:IsDead() then
							self:IsCombo(sdata,targets);
							if self._hero._groupType == eGroupType_O then
								self:ProcessDamageByTarget(v, sdata,ticknum);
							else
								if v._groupType ~= eGroupType_N then
									self:ProcessDamageByTarget(v, sdata,ticknum);
								end
							end
						end
					end

					if self._skill._cfg.type == eSE_Damage then
						local target = self._hero
						if target and target:IsPlayer() then
							--战斗能量条件2触发
							local talentadd = false
							local talentodds = 0
							local cfg = i3k_db_fightsp[target._id]
							if target._talents then
								for k,v in pairs(target._talents) do
									if v._id == cfg.TalentID then
										talentadd = true
										talentodds = cfg.TriProc2[math.floor(v._lvl/7)+1]
										break;
									end
								end
							end
							if target._behavior:Test(eEBFightSP) or talentadd then
								
								local add = 0
								if target._validSkills[tonumber(cfg.LinkSkill)] then
									add = tonumber(target._validSkills[tonumber(cfg.LinkSkill)].state)*tonumber(i3k_db_fightsp[target._id].SkillAdd)
								end

								for k, v in pairs(cfg.TriCond) do
									if tonumber(v) == 2 then
										local rollnum = i3k_engine_get_rnd_u(0, 10000);
										local odds = cfg.TriProc1+add + talentodds							
										if rollnum < odds then
											if cfg.affectType == 1 then
												local overlay = target:GetFightSp()
												if overlay >= 0 and overlay <cfg.overlays then
													overlay = overlay + 1
													target:UpdateFightSp(overlay)
												end
											elseif cfg.affectType == 2 then
												local player = i3k_game_get_player()
												local hero = i3k_game_get_player_hero()
												local petcount = player:GetPetCount()
												if petcount >= 0 and petcount < cfg.overlays then
													local lvl = 1;
													for k1,v1 in pairs(hero._skills) do
														if v1._id == cfg.LinkSkill then
															lvl = v1._lvl;
														end
													end
													local cfgID = cfg.affectID1
													for k,v in pairs(target._talents) do
														if v._id == cfg.affectID2 then
															cfgID = cfg.value2[math.floor(v._lvl/7)+1]
														end
													end
													target:CreateFightSpCanYing(cfgID,1,lvl)
													--target:CreateFightSpCanYing(cfg.affectID1,1,lvl)
													target:UpdateFightSpCanYing(petcount+1)
												end
												--pet:OnUpdate(0);
											end
										end
									end
								end
							end
						end
					end
					self._skill:TriggerVFX(eVFXDamage, targets);
				end
			end
		end
	end
end

function i3k_attacker:ProcessDamageByTarget(target, sdata, ticknum, isCombo)
	local dead, dodge = self._hero:ProcessDamage(self._skill, target, sdata, ticknum, isCombo);
	if not dodge then
		self:SwitchDamageBehavior(dead, target);
	end

	if target:GetEntityType() == eET_Mercenary then
		local guid = string.split(target._guid, "|");
		local cfg = i3k_db_mercenaries[tonumber(guid[2])];
		if cfg and not target:IsDead() then
			target:UpdateProperty(ePropID_sp, 1, tonumber(cfg.HitSPIncrease), false, false);
		end
	end

	if target then
		self._attackSuc = true;
	end
end

function i3k_attacker:GetTargets(sdata)
	if self._inheritTargets then
		return self._inheritTargets;
	end

	local h = self._hero;
	local s = self._skill;
	local c = s._cfg;

	if s._replaceTargets then
		return s._replaceTargets;
	end

	local scope = s._scope;
	if scope.type == eSScopT_Owner then
		return { h };
	elseif scope.type == eSScopT_Single then
		local target = self._targets[1];
		if target and not target:IsDead() then
			return { target };
		end

		self._targets = { };
	elseif scope.type == eSScopT_SectorO then
		self._targets = { };
	end

	if not self._targetCheck then
		return { };
	end

	local alives = { };
	-- 祝福
	if c.type == eSE_Buff then
		if #h._alives[1] > 0 then
			for k, v in ipairs(h._alives[1]) do
				table.insert(alives, v);
			end
		end
	elseif c.type == eSE_Damage then
		-- 敌方
		if #h._alives[2] > 0 then
			for k, v in ipairs(h._alives[2]) do
				table.insert(alives, v);
			end
		end

		-- 中立
		if #h._alives[3] > 0 then
			for k, v in ipairs(h._alives[3]) do
				table.insert(alives, v);
			end
		end
	elseif c.type == eSE_DBuff then
		-- 敌方
		if #h._alives[2] > 0 then
			for k, v in ipairs(h._alives[2]) do
				table.insert(alives, v);
			end
		end
	end

	local targets = { };
	local target_num = 0;
	for k, v in ipairs(alives) do
		if self._targetCheck(v) then
			table.insert(targets, v.entity);
			target_num = target_num + 1;
			if c.maxTargets > 0 and target_num >= c.maxTargets then
				break;
			end
		end
	end
	if self._newtarget then
		local p1 = i3k_vec3_clone(h._curPos);
		local p2 = i3k_vec3_clone(self._newtarget._curPos);
		local rot_y = i3k_vec3_angle1(p2, p1, { x = 1, y = 0, z = 0 });
		h:SetFaceDir(0, rot_y, 0);
		for k, v in ipairs(alives) do
			if self._targetCheck(v) then
				table.insert(targets, v.entity);
			end
		end
		self._newtarget = nil;
	end

	return targets;
end

function i3k_attacker:SwitchAttackBehavior()
	local s = self._skill;
	local res = false;

	-- 自身
	if s._specialArgs.rushInfo then
		self._skill:TriggerVFX(eVFXStartBehavior, nil);
		local world = i3k_game_get_world() 
		if self._hero and (self._hero:IsPlayer() or (self._hero._hoster and self._hero._hoster:IsPlayer())) or ( world and not world._syncRpc ) then
			res = self:StartRush();
		end
	elseif s._specialArgs.summonInfo then
		self._skill:TriggerVFX(eVFXStartBehavior, nil);
		res = self:StartSummon(s._specialArgs.summonInfo);
	end
	if s._specialArgs.omnislash then
		self._skill:TriggerVFX(eVFXStartBehavior, nil);
	    if s._specialArgs.omnislash then
       		res = self:StartOmnislash();	
		end
	end
	-- 技能
	if s._specialArgs.flyInfo then
		res = self:StartFly();
	end

	if s._specialArgs.auraInfo then
		if self._hero then
			self._hero:AddAura(s, s._specialArgs.auraInfo);
		end
	end

	-- 目标
	if s._specialArgs.shiftInfo then
		if s._specialArgs.shiftInfo.type == 2 then
			self:StartShift(s._specialArgs.shiftInfo);
		end
	end

	return res;
end

function i3k_attacker:SwitchDamageBehavior(dead, target)
	local s = self._skill;

	if s._specialArgs.shiftInfo then
		if not dead then
			if s._specialArgs.shiftInfo.type == 1 or s._specialArgs.shiftInfo.type == 3 then
				if target.OnShift then
					local odds1 = i3k_engine_get_rnd_u(0, 10000);
					local odds2 = (s._specialArgs.shiftInfo.odds + s:TalentSkillChange(self,eSCType_Common,eSCCommon_shiftodds)) or 10000;
					if odds1 > odds2 then
						return false;
					end

					local dir = i3k_vec3_normalize1(i3k_vec3_sub1(target._curPos, self._hero._curPos));

					local sign = 1;
					if s._specialArgs.shiftInfo.distance < 0 then
						sign = -1;
					end

					local dist = math.abs(s._specialArgs.shiftInfo.distance);
					if s._specialArgs.shiftInfo.type == 3 then
						dist = math.min(math.abs(i3k_vec3_dist(self._hero._curPos, target._curPos) + (150 + i3k_engine_get_rnd_u(0, 50)) * sign), math.abs(s._specialArgs.shiftInfo.distance));
					end

					local shiftInfo = { };
						shiftInfo.type		= s._specialArgs.shiftInfo.type;
						shiftInfo.distance	= dist * sign;
						shiftInfo.height	= s._specialArgs.shiftInfo.height;
						shiftInfo.velocity	= s._specialArgs.shiftInfo.velocity;
					--i3k_log("onshift4")
					return target:OnShift(dir, shiftInfo);
				end
			end
		end
	elseif s._specialArgs.triSkillOnDamage then
		self:OnTriSkill(target, s._specialArgs.triSkillOnDamage);

		return false;
	end

	return false;
end

function i3k_attacker_create(hero, skill, targets, passive, child)
	local attacker = i3k_attacker.new(i3k_gen_entity_guid_new(i3k_attacker.__cname, i3k_gen_entity_guid()), child or false);
	if attacker:Create(hero, skill, targets, passive) then
		return attacker;
	end
	attacker:Release();

	return nil;
end
