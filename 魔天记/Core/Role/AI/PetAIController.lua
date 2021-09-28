require "Core.Role.AI.AbsAiController"
require "Core.Role.Action.SendCmd.SendFollowTargetAction"

PetAiController = class("PetAiController", AbsAiController)

PetAiController.Max_Master_Distance = 10;
PetAiController.Follow_Distance = 3;


function PetAiController:New(role)
	self = {};
	setmetatable(self, {__index = PetAiController});
	self:_Init(role);
	self._status = AI.Status.Stand
	self._waitTime = 5;
	self._attackTime = 5;	
	return self;
end

function PetAiController:_GetSkill()
	if(self._role and self._role.info) then
		local roleInfo = self._role.info;
		-- local skill = roleInfo:GetInnateSkill();
		-- if (skill and(not skill:IsCooling())) then
		--     return skill;
		-- else
		local index = 1;
		skill = roleInfo:GetSkillByIndex(index)
		while(skill ~= nil) do
			index = index + 1;
			if(not skill:IsCooling()) then
				return skill;
			else
				skill = roleInfo:GetSkillByIndex(index);
			end
		end
		skill = roleInfo:GetBaseSkill();
		if(skill and(not skill:IsCooling())) then
			return skill;
		end
		-- end
	end
	return nil;
end

function PetAiController:_GetRandomPosition()
	self:_Randomseed();
	local master = self._role:GetMaster();
	local masterPt = master.transform.position;
	local d = HireAIController.Follow_Distance / 3 * 2;
	local distance = math.random() *(HireAIController.Follow_Distance / 3) + d;
	local angle = math.random(0, 360);
	local index = 0;
	while(index < 9) do
		for i = 1, 3, 2 do
			local r =(angle +(i - 2) * index * 20) * math.pi / 180;
			local pt = Vector3.New(masterPt.x, masterPt.y, masterPt.z);
			pt.x = pt.x + math.sin(r) * distance;
			pt.z = pt.z + math.cos(r) * distance;
			--if (GameSceneManager.mpaTerrain:IsWalkable(pt) and GameSceneManager.mpaTerrain:IsWalkPath(masterPt,pt)) then            
			if(GameSceneManager.mpaTerrain:IsWalkable(pt)) then
				return MapTerrain.SampleTerrainPosition(pt);
			end
		end
		index = index + 1
	end
	return nil;
end

function PetAiController:_OnTimerHandler()
	local role = self._role;
	
	if(role and not role:IsDie()) then
		local master = self._role:GetMaster();
		if(master) then
			self:_CheckFlash(master)
		end
	end
end

function PetAiController:_OnStopHandler()
	local role = self._role;
	if(role and not role:IsDie() and self._status ~= AI.Status.CastSkill) then
		role:StopAction(3)
		role:DoAction(SendStandAction:New());
		self._status = AI.Status.Stand
	end
end

function PetAiController:_CheckFlash(master)
	local role = self._role;
	if(role and not role:IsDie() and master) then
		local distance = Vector3.Distance2(role.transform.position, master.transform.position);
		if(distance > PetAiController.Max_Master_Distance) then
			local action = role:GetAction();
			if(action == nil or(action and action.actionType ~= ActionType.BLOCK)) then
				local transform = role.transform;
				local toPt = self:_GetRandomPosition();
				if(toPt) then
					local angle = math.atan2(toPt.x - transform.position.x, toPt.z - transform.position.z) / math.pi * 180;
					role:SetTarget(nil);
					role:StopAction(3);
					role:DoAction(SendStandAction:New(toPt, angle));
					self:_CheckStand(master);
				end
			end
		else
			self:_CheckSearch(master)
		end
	end
end

function PetAiController:_CheckSearch(master)
	local role = self._role;
	if(role and not role:IsDie() and master) then
		if(master.state ~= RoleState.SKILL) then
			self._attackTime = self._attackTime - self._delayTime;
		else
			self._attackTime = 5;
		end
		if(self._attackTime <= 0) then
			role:SetTarget(nil);
		end 
		if(role.target ~= nil and(not role.target:IsDie())) then
			self:_CheckFight(master);
		else
			self:_CheckFollow(master);
		end
	end
end

function PetAiController:_CheckFight(master)
	local role = self._role;
	if(role and not role:IsDie() and master) then
		local skill = self:_GetSkill(); 
		self._status = AI.Status.Fight
		
		if(skill) then
			local action = role:GetAction();
			if(action == nil or(action and action.actionType ~= ActionType.BLOCK)) then
				local target = role.target;
				local d =(skill.distance + target.info.radius) / 100 * 0.95;
				if(Vector3.Distance2(role.transform.position, target.transform.position) < d) then
					role:DoAction(SendSkillAction:New(skill));
				else
					if(action and action.__cname == "SendMoveToSkillAction") then
						action:SetTarget(target);
					else
						role:DoAction(SendMoveToSkillAction:New(target, skill));
					end
				end
			end
		end
	end
end

function PetAiController:_CheckFollow(master)
	local role = self._role;
	if(role and not role:IsDie() and master) then
		local distance = Vector3.Distance2(role.transform.position, master.transform.position);
		if(distance > PetAiController.Follow_Distance * 1.1) then
			if(self._status ~= AI.Status.Follow) then
				local act = role:DoAction(SendFollowTargetAction:New(master, PetAiController.Follow_Distance / 3 * 2, math.random(0, 360)));
				if(act) then
					act:AddEventListener(self, PetAiController._CheckFollowFinishHandler);
					self._status = AI.Status.Follow;
				end
			end
		else
			if(self._status == AI.Status.Stand) then
				self:_CheckStand(master);
			elseif(self._status == AI.Status.Patrol) then
				self:_CheckPatrol(master);
			end
		end
	end
end

function PetAiController:_CheckStand(master)
	local role = self._role;
	if(role and not role:IsDie() and master) then
		if(self._status ~= AI.Status.Stand) then
			self._waitTime = 5
			role:DoAction(SendStandAction:New());
			self._status = AI.Status.Stand
		else
			self._waitTime = self._waitTime - self._delayTime;
			
			if(self._waitTime <= 0) then
				self:_CheckPatrol(master)
			end
		end
	end
end

function PetAiController:_CheckPatrol(master)
	local role = self._role;
	if(role and not role:IsDie() and master) then
		if(self._status ~= AI.Status.Patrol) then			
			local pt = self:_GetRandomPosition();		
			if(pt) then
				local act = role:DoAction(SendMoveToAction:New(pt))						
				if(act) then							
					act:AddEventListener(self, PetAiController._CheckPatrolFinishHandler);
					self._status = AI.Status.Patrol;
				end
			end
		end
	end
end

function PetAiController:_CheckPatrolFinishHandler()
	if(self._status == AI.Status.Patrol) then
		self._status = AI.Status.Stand;
		self._waitTime = 5
	end
end

function PetAiController:_CheckFollowFinishHandler()
	self._status = AI.Status.Stand;
	self._waitTime = 5
end 