require "Core.Role.Action.AbsAction";

PortalStandAction = class("PortalStandAction", AbsAction)

function PortalStandAction:New()
	self = {};
	setmetatable(self, {__index = PortalStandAction});
	self:Init();
	self.actionType = ActionType.BLOCK;
	self._isInPortal = false;
	return self;
end

function PortalStandAction:_OnStartHandler()
	if(self._controller) then
		self._target = HeroController.GetInstance();
		self:_InitTimer(0.5, - 1);
		self.pos = self._controller.transform.position
	end
end

function PortalStandAction:_OnTimerHandler()
	local controller = self._controller;
	if(controller) then
		local target = controller.target;
		if(target) then
			local act = target:GetAction();
			if(act ~= nil and(act.__cname == "SendMoveToAngleAction" or act.__cname == "SendMoveToAction" or act.__cname == "SendMoveToNpcAction")) then
				local dis = Vector3.Distance2(self.pos, target.transform.position)
				if(dis < 2) then
					if(not self._isInPortal) then
						local targetAction = target:GetAction()
						--controller:Pause();
						-- controller:StopAutoFight();
						if(targetAction and targetAction.isAcrossMap) then
							target:Pause();
						else
							target:StopAction(3);
							target:Stand();
						end
						local to =
						{
							sid = controller.info.to_map;
							pid = controller.info.id;
							position = controller.info.toPosition;
						}
						self._isInPortal = GameSceneManager.GotoScene(controller.info.to_map, nil, to);
						if self._isInPortal then controller:Pause() end
					end
				else
					if(self._isInPortal) then
						controller:Resume();
						self._isInPortal = false;
					end
				end
				if dis < 25 then controller:CheckLoadModel() end
			end
		end
	end
end 