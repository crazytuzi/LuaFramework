------------------------------------------------------
module(..., package.seeall)

local require = require
require("i3k_state_base");
require("i3k_global");
require("logic/entity/i3k_entity_trap_def");
------------------------------------------------------

	local eSTrapEventBase	= 10000;
	local eSTrapEventLock	= 10001;	--未激活状态
	local eSTrapEventActive	= 10002;	--激活未触发状态
	local eSTrapEventAttack	= 10003;	--激活触发状态
	local eSTrapEventClosed	= 10004;	--关闭/损坏状态
	local eSTrapEventMine = 10101;	--资源点专用状态
	
	local eSTrapStateBase   = "base";
	local eSTrapStateLocked = "locked";
	local eSTrapStateActive = "active";
	local eSTrapStateAttack = "attack";
	local eSTrapStateClosed = "closed";
	local eSTrapStateMine   = "mine";

------------------------------------------------------
i3k_trap_state = i3k_class("i3k_trap_state", i3k_state_base);
function i3k_trap_state:ctor(entity)
	self._entity = entity;
	self._timeTick 	= 0;
end

function i3k_trap_state:Entry(fsm, from, evt, to)
	if i3k_state_base.Entry(self, fsm, from, evt, to) then
		self._timeTick = 0;

		return true;
	end

	return false;
end

function i3k_trap_state:OnLogic(dTick)
	if i3k_state_base.OnLogic(self, dTick) then
		self._timeTick = self._timeTick + dTick * i3k_engine_get_tick_step();

		return true;
	end

	return false;
end

------------------------------------------------------
i3k_trap_base = i3k_class("i3k_trap_base", i3k_trap_state);
function i3k_trap_base:ctor(entity, trap)
	self._entity = entity;
	self._trap   = trap;
	self._turnOn	= false;
	self._type	= eSTrapEventBase;
end

function i3k_trap_base:Entry(fsm, from, evt, to)
	if i3k_trap_state.Entry(self, fsm, evt) then
		
		if not self._turnOn then
			self._turnOn = true;
			return true;
		end
		
		return true;
	end

	return false;
end

function i3k_trap_base:OnLogic(dTick)
	if i3k_trap_state.OnLogic(self, dTick) then
		if not self._entity:IsValid() then
			return false;
		end

		return true;
	end

	return false;
end


------------------------------------------------------
i3k_trap_locked = i3k_class("i3k_trap_locked", i3k_trap_state);
function i3k_trap_locked:ctor(entity ,trap)
	self._trap	= trap;
	self._entity = entity;
	self._type = eSTrapEventLock;
	self._turnOn	= false;
	self.TransLogic	= 0;
end

function i3k_trap_locked:Entry(fsm, from, evt, to)
	if i3k_trap_state.Entry(self, fsm, from, evt, to) then
		if self._trap and self._trap._gcfg_base then
			if self._trap._gcfg_base.Action1 ~= "" then
				self._trap:Play(self._trap._gcfg_base.Action1, -1);
			else
				self._trap:Play(i3k_db_common.engine.defaultStandAction, -1);
			end
			if self._trap._gcfg_external.ActiveTransLogic1 ~= -1 then
				self.TransLogic = self._trap._gcfg_external.ActiveTransLogic1;
			end
	
			self._entity:CheckEventProcessPro(self._trap)
			return true;
		end
	end
end

function i3k_trap_locked:OnLogic(dTick)
	if i3k_trap_state.OnLogic(self, dTick) then
		if self.TransLogic ~= 0 and self._turnOn then
			
		end
	end
end
------------------------------------------------------
i3k_trap_active = i3k_class("i3k_trap_active", i3k_trap_state);
function i3k_trap_active:ctor(entity, trap)
	self._entity	= entity;
	self._trap = trap;
	self._type = eSTrapEventActive;
	self._turnOn	= false;
	self.TransLogic	= 0;
end

function i3k_trap_active:Entry(fsm, from, evt, to)
	if i3k_trap_state.Entry(self, fsm, from, evt, to) then
		if self._entity then
			if self._trap._gcfg_base then
				if self._trap._gcfg_base.Action2 ~= "" then
					self._trap:Play(self._trap._gcfg_base.Action2, -1);
				else
					self._trap:Play(i3k_db_common.engine.defaultRunAction, -1);
				end
				if self._trap._gcfg_external.ActiveTransLogic2 ~= -1 then
					self.TransLogic = self._trap._gcfg_external.ActiveTransLogic2;
				end
			
				self._entity:CheckEventObstacle(self._trap);
				self._entity:CheckEventProcessPro(self._trap);
				return true;
			end
		end
	end
end

function i3k_trap_active:OnLogic(dTick)
	if i3k_trap_state.OnLogic(self, dTick) then
		if self.TransLogic ~= 0 then
		
		end
	end
end
------------------------------------------------------
i3k_trap_attack = i3k_class("i3k_trap_attack", i3k_trap_state);
function i3k_trap_attack:ctor(entity, trap)
	self._trap	= trap;
	self._entity = entity;
	self._type = eSTrapEventAttack;
	self._turnOn	= false;
	self._timeTick 	= 0;
	self._useskill = false;
	self._useskillcool = 0;
end

function i3k_trap_attack:Entry(fsm, from, evt, to)
	if i3k_trap_state.Entry(self, fsm, from, evt, to) then
		if self._trap and self._trap._gcfg_base then
			if self._trap._gcfg_base.Action3 ~= "" then
                local alist = {}
                table.insert(alist, {actionName = self._trap._gcfg_base.Action3, actloopTimes = 1})
				if self._trap._gcfg_base.Action3 ~= "" then
                    table.insert(alist, {actionName = self._trap._gcfg_base.Action4, actloopTimes = -1})
				else
                    table.insert(alist, {actionName = i3k_db_common.engine.defaultDeadLoopAction, actloopTimes = -1})
				end
				self._trap:PlayActionList(alist, 2);	
			else
				self._trap:Play(i3k_db_common.engine.defaultWinAction, -1);
			end
			local ntype = self._trap._ntype
			if ntype == eEntityTrapType_AOE then-- AOE 技能类型(对敌方)
				local skillID = self._trap._gcfg_external.SkillID
				if skillID ~= -1 then
					self._useskill = true
					self._useskillcool = 0
				end
			end
			self:CheckUseSkill();
			self._entity:CheckEventProcessPro(self._trap);
			self._trap:SetHittable(false)
			self._turnOn	= true;
			if self._trap._obstacle and self._trap._gcfg_base.TrapType == eEntityTrapType_Barrier then
				self._trap._obstacle:Release()
				self._trap._obstacle = nil;
			end
				
			return true;
		end
	end
end

function i3k_trap_attack:OnLogic(dTick)
	if i3k_trap_state.OnLogic(self, dTick) then
		if self._turnOn then
		if dTick > 0 then
			self._timeTick = self._timeTick + dTick* i3k_db_common.engine.tickStep;
			self._useskillcool = self._useskillcool + dTick* i3k_db_common.engine.tickStep;
			if self._trap._gcfg_external.Action3Delay ~= -1 then
				if self._timeTick>self._trap._gcfg_external.Action3Delay then
					self._timeTick = 0
					self:CheckTrapType()
				end
			else
				if self._timeTick > self._trap._skill._cfg.duration then
					self._timeTick = 0
					self:CheckTrapType()
				end
			end

			----是否技能释放
			if self._useskill then
				if self._useskillcool > self._trap._gcfg_external.Value4 then
					local skillID = self._trap._gcfg_external.SkillID
					if skillID ~= -1 then
						if not self._trap:CanUseSkill() then
							self._trap._behavior:Clear(eEBAttack);
							self._trap._behavior:Clear(eEBDisAttack);
						end

						self._trap._trapskill:OnReset()
						self._trap._maunalSkill = self._trap._trapskill
					end
					self._useskillcool = 0
				end
			end
		end
	end

	return true;
	end
end

function i3k_trap_attack:CheckUseSkill()
	local ntype = self._trap._ntype
	if ntype == eEntityTrapType_AOE then
		local skillID = self._trap._gcfg_external.SkillID
		if skillID ~= -1 then
			self._useskill = true
			self._useskillcool = 0
		end
	end
end

function i3k_trap_attack:CheckTrapType()
	local ntype = self._trap._ntype
	local world = i3k_game_get_world();
	if ntype == eEntityTrapType_Trigger or ntype == eEntityTrapType_Barrier then
		self._turnOn = false;	
		local targetIDs = self._trap:GetTarget()
		local target = {}
		if world then
			for m,n in pairs(targetIDs) do
				for p,q in pairs(world._Traps) do
					if q._gid == n then
						table.insert(target,q)
					end
				end
			end
		end
		local target = self._trap:GetTarget()
		if target then
			for k, v in pairs(target) do
				v:SetBehavior(eSTrapEventAttack,true);
				v:SetTransLogic(eTrapTransLinkActive)
			end
		end
	elseif ntype == eEntityTrapType_Broken then
		self._turnOn = false
		if world then
			if world._mapType == g_BASE_DUNGEON and world._openType == g_FIELD then
				if self._trap._gcfg_external.MonsterCond > 0 then
					local rollnum = i3k_engine_get_rnd_u(0, 10000);
					if self._trap._gcfg_external.MonsterCond > rollnum then
						for i=1,self._trap._gcfg_external.MonsterNum do
							local monstercfg = i3k_db_monsters[self._trap._gcfg_external.MonsterID];
							if monstercfg then
								local PosX = i3k_engine_get_rnd_u(-self._trap._gcfg_external.DropRadius, self._trap._gcfg_external.DropRadius);
								local PosZ = i3k_engine_get_rnd_u(-self._trap._gcfg_external.DropRadius, self._trap._gcfg_external.DropRadius);
								local pos = self._trap._curPos
								pos.x = pos.x + PosX
								pos.z = pos.z + PosZ
								local _pos = i3k_world_pos_to_logic_pos(i3k_engine_get_valid_pos(i3k_vec3_to_engine(i3k_logic_pos_to_world_pos(pos))));

								local SEntity = require("logic/entity/i3k_monster");
								local monster = SEntity.i3k_monster.new(i3k_gen_entity_guid_new(SEntity.i3k_monster.__cname,i3k_gen_entity_guid()));
								monster:Create(self._trap._gcfg_external.MonsterID, false);
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
								monster:Birth(_pos);
								monster:Show(true, true, 100);
								monster:SetGroupType(eGroupType_E);
								monster:SetFaceDir(0, 0, 0);
								monster:Play(i3k_db_common.engine.defaultStandAction, -1);
								monster._spawnID = 0
								world:AddEntity(monster);
							end
						end
					end
				end
			end
		end	
	end
end

------------------------------------------------------
i3k_trap_closed = i3k_class("i3k_trap_closed", i3k_trap_state);
function i3k_trap_closed:ctor(entity, trap)
	self._entity = entity;
	self._trap	= trap;
	self._turnOn	= false;
	self._type = eSTrapEventClosed;
end

function i3k_trap_closed:Entry(fsm, from, evt, to)
	if i3k_trap_state.Entry(self, fsm, from, evt, to) then
		testindex = 0;
		if self._trap and self._trap._gcfg_base then
			if self._trap._gcfg_base.Action4 ~= "" then
				self._trap:Play(self._trap._gcfg_base.Action4, -1);
			else
				self._trap:Play(i3k_db_common.engine.defaultDeadLoopAction, -1);
			end
		end
		self._trap:SetHittable(false)
		if self._trap._obstacle and self._trap._gcfg_base.TrapType == eEntityTrapType_Barrier then
			self._trap._obstacle:Release()
			self._trap._obstacle = nil;
		end
		return true;
	end
end

function i3k_trap_closed:OnLogic(dTick)
	if i3k_trap_state.OnLogic(self, dTick) then
		if not self._entity:IsValid() then
			return false;
		end
	end
end

------------------------------------------------------
i3k_trap_mine = i3k_class("i3k_trap_mine", i3k_trap_state);
function i3k_trap_mine:ctor(entity, trap)
	self._trap	= trap;
	self._entity = entity;
	self._type = eSTrapEventMine;
	self._turnOn	= false;
	self.TransLogic	= 0;
end

function i3k_trap_mine:Entry(fsm, from, evt, to)
	if i3k_trap_state.Entry(self, fsm, from, evt, to) then
		self._trap:Play(i3k_db_common.engine.defaultStandAction, -1);
		self._entity:CheckEventObstacle()
		return true;
	end
end

function i3k_trap_mine:OnLogic(dTick)
	if i3k_trap_state.OnLogic(self, dTick) then

		if not self._entity:IsValid() then
			return false;
		end
	end
end

----------------------------------------------------
i3k_trap_mgr_net = i3k_class("i3k_trap_mgr_net");
function i3k_trap_mgr_net:ctor(entity)
	
	self._trap_sm		= i3k_state_machine.new(eSTrapStateClosed);
	-- init state machine
	local base_state = i3k_trap_base.new(self, entity);
	local locked_state = i3k_trap_locked.new(self, entity);
	local active_state = i3k_trap_active.new(self, entity);
	local attack_state = i3k_trap_attack.new(self, entity);
	local closed_state = i3k_trap_closed.new(self, entity);
	local mine_state   = i3k_trap_mine.new(self, entity);
	
	self._trap_sm:AddTransition(eSTrapStateBase,     eSTrapEventLock,    eSTrapStateLocked,   locked_state);
	self._trap_sm:AddTransition(eSTrapStateBase,     eSTrapEventActive,    eSTrapStateActive,   active_state);
	self._trap_sm:AddTransition(eSTrapStateBase,     eSTrapEventAttack,    eSTrapStateAttack,   attack_state);    
	self._trap_sm:AddTransition(eSTrapStateBase,     eSTrapEventClosed,    eSTrapStateClosed,   closed_state);
	self._trap_sm:AddTransition(eSTrapStateBase,     eSTrapEventMine,      eSTrapStateMine,     mine_state);
	
	self._trap_sm:AddTransition(eSTrapStateLocked,   eSTrapEventActive,    eSTrapStateActive,   active_state);
	self._trap_sm:AddTransition(eSTrapStateLocked,   eSTrapEventAttack,    eSTrapStateAttack,   attack_state);
	self._trap_sm:AddTransition(eSTrapStateLocked,   eSTrapEventClosed,    eSTrapStateClosed,   closed_state);
	
	self._trap_sm:AddTransition(eSTrapStateActive,   eSTrapEventAttack,    eSTrapStateAttack,   attack_state);    
	self._trap_sm:AddTransition(eSTrapStateActive,   eSTrapEventClosed,    eSTrapStateClosed,   closed_state);
		
	self._trap_sm:AddTransition(eSTrapStateAttack,   eSTrapEventClosed,    eSTrapStateClosed,   closed_state);
	
	self._trap_sm:AddTransition(eSTrapStateMine,      eSTrapEventClosed,    eSTrapStateClosed,   closed_state);
	
	self._trap_sm:AddTransition(eSTrapStateClosed,    eSTrapEventBase,      eSTrapStateBase,     base_state);
	
end

function i3k_trap_mgr_net:StartLocked()
	return self._trap_sm:ProcessEvent(eSTrapEventLock);
end

function i3k_trap_mgr_net:StartActive()
	self._trap_sm:ProcessEvent(eSTrapEventActive);	
end

function i3k_trap_mgr_net:StartAttack()
	self._trap_sm:ProcessEvent(eSTrapEventAttack);
end

function i3k_trap_mgr_net:StartMine()
	return self._trap_sm:ProcessEvent(eSTrapEventMine);
end

function i3k_trap_mgr_net:StartClosed()
	self._trap_sm:ProcessEvent(eSTrapEventClosed);
end

function i3k_trap_mgr_net:IsTurnOn()
	return self._turnOn;
end

function i3k_trap_mgr_net:IsValid()
	return true;
end

function i3k_trap_mgr_net:ChangeTrap(atype)
	self._statu = atype;
	self._trap_sm:ProcessEvent(eSTrapEventBase);
	if atype == eSTrapEventLock then
		self:StartLocked();
	elseif atype == eSTrapEventActive then
		self:StartActive();
	elseif atype == eSTrapEventAttack then
		self:StartAttack();
	elseif atype == eSTrapEventClosed then
		self:StartClosed();
	elseif atype == eSTrapEventMine then
		self:StartMine();
	end
end

function i3k_trap_mgr_net:CheckEventObstacle(trap)
	local ntype = nil;
	if trap then	
		if trap._ntype then
			ntype = trap._ntype;
		else
			ntype = trap:GetPropertyValue(ePropID_TrapType);	
		end
		if ntype == eEntityTrapType_Barrier then
			if trap._obstacle then
	
			else
				if trap._obstacleValid then
					local obstacle = require("logic/battle/i3k_obstacle");
					trap._obstacle = obstacle.i3k_obstacle.new(i3k_gen_entity_guid_new(obstacle.i3k_obstacle.__cname,i3k_gen_entity_guid()));
					if trap._obstacle:Create(trap._gcfg_external.Pos, trap._gcfg_external.Direction, trap._gcfg_base.obstacleType, trap._gcfg_base.obstacleArgs) then
						trap._obstacle:Show(false, true,10);
					else
						trap._obstacle = nil;
					end
				end
			end
		end
	end
end

function i3k_trap_mgr_net:CheckEventProcessPro(trap)
	if trap then
		if trap._LogicId ~= -1 then
			if trap._activeonce then
				local gcfg = i3k_db_trap_exchange;
				local targetIDs = self._trap:GetTarget()
				local target = {}
				local logic = i3k_game_get_logic();
				local world = logic:GetWorld();
				if world then
					for m,n in pairs(targetIDs) do
						for p,q in pairs(world._Traps) do
							local guid = string.split(q._guid, "|")
							if tonumber(guid[2]) == n then
								table.insert(target,q)
							end
						end
					end
				end
				
			else
				self._trap._activeonce = true;
			end
		end
	end
end

function i3k_trap_mgr_net:OnUpdate(dTime)
	local state = self._trap_sm._cur_state_obj;
	if state ~= nil then
		state:OnUpdate(dTime);
	end
end

function i3k_trap_mgr_net:OnLogic(dTick)
	local state = self._trap_sm._cur_state_obj;
	if state ~= nil then
		state:OnLogic(dTick);
	end
end

function create_mgr_net(entity)
	return i3k_trap_mgr_net.new(entity);	
end
