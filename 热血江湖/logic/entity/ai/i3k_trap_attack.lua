----------------------------------------------------------------
module(..., package.seeall)

local require = require

--local baseModule = require("logic/entity/ai/i3k_trap_Closed");
local baseModule = require("logic/entity/ai/i3k_trap_base");
require("logic/entity/i3k_entity_itemdrop_def");

------------------------------------------------------
i3k_trap_attack = i3k_class("i3k_trap_Attack", baseModule.i3k_trap_base);
function i3k_trap_attack:ctor(entity)
	self._entity	= entity;
	self._type = eSTrapAttack;
	self._turnOn	= false;
	self._timeTick 	= 0;
	self._useskill = false;
	self._useskillcool = 0;
end

function i3k_trap_attack:IsValid()
	return true--self._entity:IsMoving();
end

function i3k_trap_attack:OnEnter()
	if self.__super.OnEnter(self) then
		
		if self._entity._gcfg_base.Action3 ~= "" then
            local alist = {}
            table.insert(alist, {actionName = self._entity._gcfg_base.Action3, actloopTimes = 1})
			if self._entity._gcfg_base.Action3 ~= "" then
                table.insert(alist, {actionName = self._entity._gcfg_base.Action4, actloopTimes = -1})
			else
                table.insert(alist, {actionName = i3k_db_common.engine.defaultDeadLoopAction, actloopTimes = -1})
			end
			self._entity._trapinit = false;
			self._entity:PlayActionList(alist, 2);
			local targetIDs = self._entity:GetTarget()
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
			--local target = self._entity:GetTarget()
			for k,v in pairs(target) do
				if v then
					local targetPos = v._curPos;
					if  self._entity._gcfg_external.Value2 ~= -1 then
						targetPos.x = targetPos.x + self._entity._gcfg_external.Value2;
					end
					if  self._entity._gcfg_external.Value3 ~= -1 then
						targetPos.y = targetPos.y + self._entity._gcfg_external.Value3;
					end
					if  self._entity._gcfg_external.Value4 ~= -1 then
						targetPos.z = targetPos.z + self._entity._gcfg_external.Value4;
					end
					if self._entity._gcfg_external.Value1 ~= -1 then
						self._entity:PlayAttackEffectByPos(targetPos, self._entity._gcfg_external.Value1)
					else
						self._entity:PlayAttackEffectByPos(targetPos, 100)
					end
				end
			end
		else
			--i3k_log("i3k_trap_attack|"..i3k_db_common.engine.defaultWinAction)
			self._entity:Play(i3k_db_common.engine.defaultWinAction, -1);
		end
		self:CheckEventProcessPre()
		self._entity:SetHittable(false)
		self._turnOn	= true;
		if self._entity._obstacle and self._entity._gcfg_base.TrapType == eEntityTrapType_Barrier then
			self._entity._obstacle:Release()
			self._entity._obstacle = nil;
		end

		return true;
	end

	return false;
end

function i3k_trap_attack:OnLeave()
	if self.__super.OnLeave(self) then
		return true;
	end

	return false;
end

function i3k_trap_attack:OnUpdate(dTime)
	--self._entity.OnUpdate(self, dTime);
	if self._turnOn then
		
	end
	return false;
end

function i3k_trap_attack:OnLogic(dTick)
	if self._turnOn then
		if dTick > 0 then
			self:UpdateTick(dTick);
			if self._entity._gcfg_external.Action3Delay ~= -1 then
				--i3k_log("self._timeTick:"..self._timeTick.."|"..self._entity._gcfg_external.Action3Delay)
				if self._timeTick>self._entity._gcfg_external.Action3Delay then
					self._timeTick = 0
					self:CheckEventProcess()
				end
			else
				if self._timeTick > self._entity._skill._cfg.duration then
					self._timeTick = 0
					self:CheckEventProcess()
				end
			end

			----------是否技能释放
			if self._useskill then
				if self._useskillcool > self._entity._gcfg_external.Value4 then
					local skillID = self._entity._gcfg_external.SkillID
					if skillID ~= -1 then
						if not self._entity:CanUseSkill() then
							self._entity._behavior:Clear(eEBAttack);
							self._entity._behavior:Clear(eEBDisAttack);
						end

						self._entity._trapskill:OnReset()
						self._entity._maunalSkill = self._entity._trapskill
					end
					self._useskillcool = 0
				end
			end
		end
	end

	return true;
end


function i3k_trap_attack:UpdateTick(tick)
	self._timeTick = self._timeTick + tick* i3k_db_common.engine.tickStep;-- * i3k_engine_get_tick_step();
	self._useskillcool = self._useskillcool + tick* i3k_db_common.engine.tickStep;
end

function i3k_trap_attack:CheckEventProcessPre()
	local ntype = self._entity._ntype
	if ntype == eEntityTrapType_AOE then
		local skillID = self._entity._gcfg_external.SkillID
		if skillID ~= -1 then
			self._useskill = true
			self._useskillcool = 0
		end
	end
	----------------逻辑组处理
	if self._entity._LogicId ~= -1 then
		if self._entity._activeonce then
			local gcfg = i3k_db_trap_exchange;
						--local Targets = self._entity:GetProperty(ePropID_TargetId);

			local targetIDs = self._entity:GetTarget()
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

			for k,v in pairs(target) do
				local trapid = v._gid;
				for p,q in pairs(gcfg) do
					if q.trapid == trapid and q.trapgroup == v._LogicId and q.attackmode ~= -1 then
						local logic = i3k_game_get_logic();
						if logic then
							local world = logic:GetWorld();
							if world then
								if q.attackmode == eSTrapAttack then
									local args = {trapID = v._gid,trapState = eSTrapClosed};
									i3k_sbean.sync_privatemap_trap(args)
								else
									local args = {trapID = v._gid,trapState = q.attackmode};
									i3k_sbean.sync_privatemap_trap(args)
								end	
							end
						end
						v:SetTrapBehavior(q.attackmode,false);
					end
				end
			end
		else
			self._entity._activeonce = true;
		end
	
	end
end 

function i3k_trap_attack:CheckEventProcess()
	local ntype = self._entity._ntype

	if ntype == eEntityTrapType_Trigger or ntype == eEntityTrapType_Barrier then
		self._turnOn = false
		local logic = i3k_game_get_logic();
		if logic then
			local world = logic:GetWorld();
			if world then
				local args = {trapID = self._entity._gid,trapState = eSTrapClosed};
				i3k_sbean.sync_privatemap_trap(args)
			end	
		end
		self._entity:SetTrapBehavior(eSTrapClosed,true);
		local targetIDs = self._entity:GetTarget()
		local target = {}
		local logic = i3k_game_get_logic();
		local world = logic:GetWorld();
		if world then
			for m,n in pairs(targetIDs) do
				for p,q in pairs(world._Traps) do
					if q._gid == n then
						table.insert(target,q)
					end
				end
			end
		end
		--local target = self._entity:GetTarget()
		if target then
			for k, v in pairs(target) do
				--v:SetBehavior(eSTrapAttack,true);
				v:SetTransLogic(eTrapTransLinkActive)
			end
		end
	elseif ntype == eEntityTrapType_Broken then
		self._turnOn = false
		local logic = i3k_game_get_logic();
		if logic then
			local world = logic:GetWorld();
			if world then
				if world._mapType == 1 and world._openType == 0 then
					if self._entity._gcfg_external.MonsterCond > 0 then
						local rollnum = i3k_engine_get_rnd_u(0, 10000);
						if self._entity._gcfg_external.MonsterCond > rollnum then
							for i=1,self._entity._gcfg_external.MonsterNum do
								local monstercfg = i3k_db_monsters[self._entity._gcfg_external.MonsterID];
								if monstercfg then
									local PosX = i3k_engine_get_rnd_u(-self._entity._gcfg_external.DropRadius, self._entity._gcfg_external.DropRadius);
									local PosZ = i3k_engine_get_rnd_u(-self._entity._gcfg_external.DropRadius, self._entity._gcfg_external.DropRadius);
									local pos = self._entity._curPos
									pos.x = pos.x + PosX
									pos.z = pos.z + PosZ
									local _pos = i3k_world_pos_to_logic_pos(i3k_engine_get_valid_pos(i3k_vec3_to_engine(i3k_logic_pos_to_world_pos(pos)), 2));

									local SEntity = require("logic/entity/i3k_monster");
									local monster = SEntity.i3k_monster.new(i3k_gen_entity_guid_new(SEntity.i3k_monster.__cname,i3k_gen_entity_guid()));
									monster:Create(self._entity._gcfg_external.MonsterID, false);
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
				local args = {trapID = self._entity._gid,trapState = eSTrapClosed};
				i3k_sbean.sync_privatemap_trap(args)
			end	
		end
		self._entity:SetTrapBehavior(eSTrapClosed,true);
	end
end 

function create_component(entity, priority)
	return i3k_trap_attack.new(entity, priority);
end

