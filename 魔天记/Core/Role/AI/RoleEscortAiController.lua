require "Core.Role.AI.AbsAiController";

RoleEscortAiController = class("RoleEscortAiController", AbsAiController);

function RoleEscortAiController:New(role)
    self = { };
    setmetatable(self, { __index = RoleEscortAiController });
    self:_Init(role);
    return self;
end

function RoleEscortAiController:SetTarget(targetId)
	self.escortTarget = targetId;

end

function RoleEscortAiController:Start()
	if (self._timer == nil) then
        self._timer = Timer.New( function(val) self:_OnTickHandler(val) end, 0.5, -1, false);
        self._timer:Start();
    end
    self:_DoEscort();
end

function RoleEscortAiController:_OnTimerHandler()
    self:_DoEscort();
end

function RoleEscortAiController:_DoEscort()
	local heroCtrl = HeroController.GetInstance();
	local myInfo = heroCtrl.info;
	
	local target = TaskUtils.GetMonster(self.escortTarget, myInfo.id);

	if target then
		if (target.state == RoleState.MOVE) then
			local pos = target.transform.position;
			local myPos = heroCtrl.transform.position;
            if TaskUtils.InCircle(myPos, pos, 4) == false then
            	heroCtrl:MoveTo(pos);
            end
		elseif heroCtrl._isAutoFight == false then
			heroCtrl:StartAutoFight();
		end
	end
end
