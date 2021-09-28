require "Core.Role.Action.SendCmd.SendMoveToAction";

SendFollowTargetAction = class("SendFollowTargetAction", SendMoveToAction)

function SendFollowTargetAction:New(target, distance, angle)
	self = {};
	setmetatable(self, {__index = SendFollowTargetAction});
	self:Init();
	self.actionType = ActionType.NORMAL;
	self._toMap = GameSceneManager.map.info.id;
	self._rDistance = distance;
	self._angle = angle
	if(angle == nil) then
		self._stopDistance = distance
	else
    self._stopDistance = 0
	end
	self.isAcrossMap = false;
	self._disRoleEvent = true;
	self._bTime = 0
	self._target = target;
	if(target) then
		if(self._angle ~= nil) then
			self._toPosition = self:_GetRandomPosition(target.transform.position);
		else
			self._toPosition = target.transform.position;
		end
	end
	if(self._isStop ~= true) then
		return self;
	end
	return nil;
end

function SendFollowTargetAction:SetTarget(target, distance)
	if(self._target ~= target) then
		local controller = self._controller;
		self._target = target;
		if(distance) then
			self._rDistance = distance;
		end
		if(target) then
			if(self._angle ~= nil) then
				self._toPosition = self:_GetRandomPosition(target.transform.position);
			else
				self._toPosition = target.transform.position;
			end
			if(controller) then
				if(self._toPosition) then
					self:_SearchPath();
					if(self._path) then
						if(self._running) then
							self:_NextPosition();
						end
					else
						self:Finish();
					end
				else
					self:Finish();
				end
			end
		end
	end
end

function SendFollowTargetAction:_Randomseed()
	local controller = self._controller;
	if(controller and controller.transform) then
		local position = controller.transform.position;
		-- math.randomseed(position.x * position.y * position.z * 100);
	end
end

function SendFollowTargetAction:_GetRandomPosition(origin)
	self:_Randomseed();
	local distance = self._rDistance * 0.9;
	local index = 0;
	local angle = self._angle;
	while(index < 9) do
		for i = 1, 3, 2 do
			local r =(angle +(i - 2) * index * 20) * math.pi / 180;
			local pt = Vector3.New(origin.x, origin.y, origin.z);
			pt.x = pt.x + math.sin(r) * distance;
			pt.z = pt.z + math.cos(r) * distance;
			if(GameSceneManager.mpaTerrain:IsWalkable(pt)) then
				return pt;
			end
		end
		index = index + 1
	end
	
	return nil;
end

function SendFollowTargetAction:_OnCompleteHandler(val)
	if(self._angle) then
		local controller = self._controller;
		local target = self._target;
		if(target and target.transform) then
			local position = controller.transform.position;
			local d = Vector3.Distance2(target.transform.position, position)
			if(d > self._rDistance or val) then
				self._bTime = 0;
				if(self._angle ~= nil) then
					self._toPosition = self:_GetRandomPosition(target.transform.position);
				else
					self._toPosition = target.transform.position;
				end
				if(controller and self._toPosition) then
					self:_SearchPath();
					if(self._path) then
						self:_NextPosition();
					else
						self:Finish();
					end
				else
					self:Finish();
				end
			else
				self:Finish();
			end
		else
			self:Finish();
		end
	else
		self:Finish();
	end
end

function SendFollowTargetAction:GetTarget()
	return self._target;
end


function SendFollowTargetAction:_OnTimerHandler()
	local target = self._target;
	self._bTime = self._bTime + Time.fixedDeltaTime
	if(target and target.transform) then
		local d = Vector3.Distance2(self._toPosition, target.transform.position)
		if(d > 2 and self._bTime > 2) then
			self:_OnCompleteHandler(true);
		else
			self:_OnMovePath();
		end
	else
		self:Finish();
	end
end
