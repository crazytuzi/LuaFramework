require "Core.Role.AI.AbsAiController";
require "Core.Role.Action.SendCmd.SendFollowTargetAction"

GuardAiController = class("GuardAiController", AbsAiController)

GuardAiController.Max_Master_Distance = 10;
GuardAiController.Follow_Distance = 2;
GuardAiController.Attack_Distance = 20;

function GuardAiController:New(role)
	self = {};
	setmetatable(self, {__index = GuardAiController});
	self:_Init(role);
	return self;
end


function GuardAiController:_GetSkill()
	if(self._role and self._role.info) then
		local roleInfo = self._role.info;
		-- local skill = roleInfo:GetInnateSkill();
		-- if(skill and(not skill:IsCooling()) and roleInfo.mp >= skill:GetSeriesSkill().mp_cost) then
		-- 	return skill;
		-- else
			local index = 1;
			skill = roleInfo:GetSkillByIndex(index)
			while(skill ~= nil) do
				index = index + 1;
				if(not skill:IsCooling() and roleInfo.mp >= skill:GetSeriesSkill().mp_cost) then
					return skill;
				else
					skill = roleInfo:GetSkillByIndex(index);
				end
			end
			skill = roleInfo:GetBaseSkill();
			if(skill and(not skill:IsCooling()) and roleInfo.mp >= skill:GetSeriesSkill().mp_cost) then
				return skill;
			end
		-- end
	end
	return nil;
end

function GuardAiController:_GetTargetBySkill(skill)
	local role = self._role;
	local target = role.target;
	local pkType = role.info.pkType;
	local seriesSkill = skill:GetSeriesSkill();
	if(seriesSkill) then
		local skDistance = 10;
		local maxDistance = GuardAiController.Attack_Distance;
		if(seriesSkill.target_type == 1) then
			target = role;
		elseif(seriesSkill.target_type == 2) then
			-- target = role;
			target = GameSceneManager.map:GetSameTeamLowHPRole(role.info.camp, pt, maxDistance)
			if(target == nil) then
				target = role;
			else
				local sHPR = role.info.hp / role.info.hp_max;
				local tHPR = target.info.hp / target.info.hp_max;
				if(sHPR < tHPR) then
					target = role;
				end
			end
		elseif(seriesSkill.target_type == 3 or seriesSkill.target_type == 4) then
			local blSearch = false;
			if(target == nil or(target and target:IsDie())) then
				-- 目标为空，从找目标
				blSearch = true;
			else
				if(target == role or target.roleType == ControllerType.PLAYER or target:IsDie() or target.info.camp == 0 or target.info.camp == role.info.camp or target.state == RoleState.RETREAT or Vector3.Distance2(role.transform.position, target.transform.position) > maxDistance) then
					-- 目标为自身，从找目标					
					blSearch = true;
				end
			end
			if(blSearch) then
				target = GameSceneManager.map:GetCanAttackTarget(role.info.camp, role.transform.position, maxDistance, 0, nil, 2, false, true);
			end
		end
	end
	return target;
end

function GuardAiController:_OnTimerHandler()
	local role = self._role;
	if(role) then
		local master = role:GetMaster();
		if(master) then
			self:_CheckFight(master)
		end
	end
end


function GuardAiController:_CheckFight(master)
	local role = self._role;
	if(role and not role:IsDie() and master) then
		if(self._status ~= AI.Status.CastSkill) then
			if(self._skill == nil or self._skill == role.info:GetBaseSkill() or self._skill:IsCooling() or self._skill.mp_cost > role.info.mp) then
				self._skill = self:_GetSkill();
			end
			if(self._skill) then
				local target = self:_GetTargetBySkill(self._skill);
				if(target ~= role.target) then
					role:SetTarget(target);
					if(target == nil) then
						self._status = AI.Status.Normal
					end
				end
				if(target) then
					local d =(self._skill.distance + target.info.radius) / 100 * 0.95;
					if(Vector3.Distance2(role.transform.position, target.transform.position) >= d) then
						if(self._status ~= AI.Status.ToTarget) then
							self:_Randomseed();
							local act = role:DoAction(SendFollowTargetAction:New(target, d * 0.9, math.random(0, 360)))
							if(act) then
								act:AddEventListener(self, GuardAiController._CheckMoveToFinishHandler, GuardAiController._CheckMoveToFinishHandler);
								self._status = AI.Status.ToTarget;
							end
						else
							if(role.state == RoleState.STAND) then
								self._sp = role.transform.position;
								self._status = AI.Status.Stand;
							else
								local act = role:GetAction();
								if(act) then
									act:SetTarget(target, d);
								end
							end
						end
					else
						if(self._status ~= AI.Status.ToTarget) then
							self:_CheckCastSkill(master);
						end
					end
				else
					self:_CheckFollow(master)
				end
			else
				if(self._status ~= AI.Status.ToTarget) then
					self:_CheckFollow(master)
				end
			end
		end
	end
end

function GuardAiController:_CheckCastSkill(master)
	local role = self._role;
	if(role and not role:IsDie() and master and self._skill) then
		if(self._status ~= AI.Status.CastSkill) then
			local act = role:DoAction(SendSkillAction:New(self._skill));
			if(act) then
				act:AddEventListener(self, GuardAiController._CheckSkillFinishHandler, GuardAiController._CheckSkillFinishHandler);
				self._status = AI.Status.CastSkill;
			end
		end
	end
end

function GuardAiController:_CheckFollow(master)
	local role = self._role;
	if(role and not role:IsDie() and master) then
		local distance = Vector3.Distance2(role.transform.position, master.transform.position);
		if(distance > GuardAiController.Follow_Distance * 1.1) then
			if(self._status ~= AI.Status.Follow) then
				local mAngle = master:GetAngleY() + 180;
				local guardCount = master:GetGuardCount();
				local site = self._role:GetSite();
				mAngle =(mAngle - 75 +(150 / guardCount) *(site - 1))
				local act = role:DoAction(SendFollowTargetAction:New(master, GuardAiController.Follow_Distance, mAngle))
				if(act) then
					act:AddEventListener(self, GuardAiController._CheckFollowFinishHandler, GuardAiController._CheckFollowFinishHandler);
					self._status = AI.Status.Follow;
				end
			else
				if(role.state == RoleState.STAND) then
					self._sp = role.transform.position;
					self._status = AI.Status.Stand;
				end
			end
		else
			if(self._status == AI.Status.Stand) then
				self:_CheckStand(master);
			end
		end
	end
end

function GuardAiController:_CheckStand(master)
	local role = self._role;
	if(role and not role:IsDie() and master) then
		if(self._status ~= AI.Status.Stand) then
			role:DoAction(SendStandAction:New());
			self._status = AI.Status.Stand
		end
	end
end


function GuardAiController:_CheckFollowFinishHandler()
	self._status = AI.Status.Stand;
end

function GuardAiController:_CheckMoveToFinishHandler()
	local role = self._role;
	if(role and not role:IsDie()) then
		if(self._status == AI.Status.ToTarget) then
			self._status = AI.Status.Fight;
		end
	else
		self._status = AI.Status.Stand;
	end
end

function GuardAiController:_CheckSkillFinishHandler()
	local role = self._role;
	if(role and not role:IsDie()) then
		if(self._status == AI.Status.CastSkill) then
			self._status = AI.Status.Fight;
		end
	else
		self._status = AI.Status.Stand;
	end
end