require "Core.Role.Action.SendCmd.SendSkillAction";

SendAttackAction = class("SendAttackAction", SendSkillAction)
SendAttackAction._ATTACK_TIME_DELAY = 0.5;
SendAttackAction._attackIndex = 0;
SendAttackAction._attackTime = 0;

function SendAttackAction:New()
    self = { };
    setmetatable(self, { __index = SendAttackAction });
    self:Init();
    self.actionType = ActionType.BLOCK;
    self._playing = false;
    return self;
end

function SendAttackAction:_OnStartHandler()
    local controller = self._controller;
    if (controller) then
        local bSkillCount = table.getCount(controller.info.currBaseSkills);
        if (Time.time - SendAttackAction._attackTime > SendAttackAction._ATTACK_TIME_DELAY) then
            SendAttackAction._attackIndex = 1;
        elseif (SendAttackAction._attackIndex >= bSkillCount) then
            SendAttackAction._attackIndex = 1;
        else
            SendAttackAction._attackIndex = SendAttackAction._attackIndex + 1;
        end
        --SendAttackAction._attackIndex = 5;
		self.tsk = controller.info:GetBaseSkillByIndex(SendAttackAction._attackIndex);
	--self:_InitSkill(skill:GetSeriesSkill());
        local skill = self.tsk:GetSeriesSkill();
		self._skill = skill;
        SendAttackAction._attackTime = Time.time;
        
		self._sumTime = skill.sum_time / 1000;        
		self._stageId = 1;
		
        self.actionType = ActionType.BLOCK;
		self.canMove = (skill.canMove == true);
        if (skill.break_time and skill.break_time > 0) then
            self._breakTime = skill.break_time / 1000;
        end        
        controller.state = RoleState.SKILL;		
        controller:LockTarget(controller.target);    
		controller:SetFightStatus(true);
		self._lockTarget = controller.target;
        self:_NextSkillStage();
        if (controller.target ~= nil) then            
            self._targetPt = controller.target.transform.position;
        end        
        self:_InitTimer(0, -1);
        self:_OnStartCompleteHandler();
    end
end

function SendAttackAction:_OnCompleteHandler()
    SendAttackAction._attackTime = Time.time;
    self.actionType = ActionType.NORMAL;
end

function SendAttackAction:_OnStopHandler()
    local controller = self._controller;
    self.actionType = ActionType.NORMAL;
    if (self._rangeEffect) then
        self._rangeEffect:Dispose();
        self._rangeEffect = nil;
    end	
     SendAttackAction._attackTime = Time.time;
end