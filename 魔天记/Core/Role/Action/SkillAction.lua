require "Core.Role.Action.RoleAction";
require "Core.Role.Skill.Stages.AbsSkillStage"

SkillAction = class("SkillAction", RoleAction)

SkillAction.currShowAmount = 0;

function SkillAction.ShowSkillName(name)
    if (SendSkillAction.currShowAmount == 0) then
        Scene.instance:SetSkyBoxEnable(false)
        MainCameraController.GetInstance():FilterMask(LayerMask.GetMask(Layer.Player, Layer.Monster, Layer.NPC, Layer.Hero, Layer.Effect, Layer.Object))
        ModuleManager.SendNotification(MainUINotes.HIDE_MAINUIPANEL);
    end
    ModuleManager.SendNotification(FightSkillNameNotes.OPEN_FIGHTSKILLNAME, name);
    SendSkillAction.currShowAmount = SendSkillAction.currShowAmount + 1;
end

function SkillAction.HideSkillName()
    if (SendSkillAction.currShowAmount > 0) then
        SendSkillAction.currShowAmount = SendSkillAction.currShowAmount - 1;
        if (SendSkillAction.currShowAmount == 0) then
            Scene.instance:SetSkyBoxEnable(true)
            MainCameraController.GetInstance():RevertMask();
            ModuleManager.SendNotification(MainUINotes.SHOW_MAINUIPANEL);
            ModuleManager.SendNotification(FightSkillNameNotes.CLOSE_FIGHTSKILLNAME, name);
        end
    end
end

function SkillAction:New(skill, target)
    self = { };
    setmetatable(self, { __index = SkillAction });
    self:Init();
    self:_InitSkill(skill, target)
    return self;
end

function SkillAction:_InitSkill(skill, target)
    self.actionType = ActionType.BLOCK;
    self._skill = skill;
    self._playing = false;
    self._target = target;
end

function SkillAction:_OnStartHandler()
    local controller = self._controller;
    if (controller) then
        local skill = self._skill;
        -- 是否使用黑屏隐藏UI显示技能名
        self._isBlackEffect = skill and skill.black and controller == PlayerManager.hero;
        self._sumTime = skill.sum_time / 1000;
        self._stageId = 1;
        self.actionType = ActionType.BLOCK;
        self.canMove =(skill.canMove == true);
        if (self._target == nil) then
            self._target = controller.target;
        end
        if (skill.break_time and skill.break_time > 0) then
            self._breakTime = skill.break_time / 1000;
        end
        controller.state = RoleState.SKILL;
        if (not controller:IsFixedRotate()) then
            controller:LockTarget(self._target);
        end
        -- controller:SetFightStatus(true);
        controller:ResetFightStatusTime()
        self:_NextSkillStage();
        if (self._target ~= nil) then
            self._targetPt = self._target.transform.position;
        end

        -- 	if (skill.vanishtime and skill.vanishtime > 0) then
        -- 		self._vanish = skill.vanish / 1000;
        -- 		self._vanishprocess = skill.vanishprocess / 1000;
        -- 		self._vanishtime = skill.vanishtime / 1000;
        -- 	end

        self:_InitTimer(0, -1);
        self:_OnStartCompleteHandler();
        controller:SetFightStatus(true);
        if (self._isBlackEffect) then
            SkillAction.ShowSkillName(skill.name);
        end
    end
end

function SkillAction:_EndSkill()
    self._skillState = 2;
    self._controller:Play(self._skill.end_actionID)
end

function SkillAction:_StartSkill()
    self._skillState = 1;
    self._controller:Play(self._skill.action_id)
end

-- 下一分段
function SkillAction:_NextSkillStage()
    if (self._skillStage) then
        self._skillStage:Dispose();
        self._skillStage = nil;
    end
    local skill = self._skill;
    local stageInfo = skill.stages[self._stageId];
    self._isPlaying = false;
    if (stageInfo) then
        self._skillStage = AbsSkillStage:New(self._controller, self._target, skill, self._stageId);
        self._skillStage:AddFinishListener(self._OnStageFinishHandler, self);
        self._stageId = self._stageId + 1;
        if (stageInfo.action_id and stageInfo.action_id ~= "") then        
            self._actName = stageInfo.action_id;
            self._controller:Play(self._actName);
        end

        if (stageInfo.LoopTime > 0) then
            self._loopTime = stageInfo.LoopTime / 1000;
        else
            self._loopTime = 0;
        end

        if (stageInfo.canMove ~= self.canMove) then
            local act = self._controller:GetCooperationAction();
            if (self.canMove) then
                if (act ~= nil and(act.__cname == "MoveToAngleAction" or act.__cname == "SendSkillMoveAction")) then
                    self._controller:Stand();
                end
            end
            self.canMove = stageInfo.canMove;
        end
        return true;
    end
    return false;
end

-- 动作完成，子类可重写
function SkillAction:_OnFinishHandler()
    local controller = self._controller;
    if (controller) then
        local cAct = controller:GetCooperationAction();
        if (not controller:HasBuffAction()) then
            if (cAct == nil or(cAct and cAct.__cname ~= "SkillMoveAction" and cAct.__cname ~= "SendSkillMoveAction")) then
                self._controller.state = RoleState.STAND;
                self._controller:Stand();
            end
        end
    end
end

-- 分段执行完毕回调
function SkillAction:_OnStageFinishHandler(stage)
    if (self._skillStage == stage) then
        self._skillStage = nil;
    end
    if (not self:_NextSkillStage()) then
        self.actionType = ActionType.NORMAL;
        self:Finish();
    end
end

function SkillAction:_OnStopHandler()
    local controller = self._controller;
    self.actionType = ActionType.NORMAL;
    if (self._isBlackEffect) then
        SkillAction.HideSkillName();
    end
    if (self._skillStage) then
        self._skillStage:Dispose();
        self._skillStage = nil;
    end
end

function SkillAction:_OnTimerHandler()
    local controller = self._controller;
    if (controller) then
        local skill = self._skill;
        local deltaTime = Time.fixedDeltaTime;
        if (self._sumTime > 0) then
            self._sumTime = self._sumTime - deltaTime;
            if (self._skillStage) then
                self._skillStage:Update(deltaTime);
            end
            if (self._breakTime) then
                self._breakTime = self._breakTime - deltaTime;
                if (self._breakTime <= 0) then
                    self.actionType = ActionType.NORMAL;
                    self._breakTime = nil;
                    self:_OnCompleteHandler();
                    return
                end
            end
--            Warning(tostring(self._actName) .. '___' .. tostring(controller:AnimIsName(self._actName))
--                 .. '__'  .. tostring(controller:AnimNormalizedTime())
--                 )
            if self._actName ~= nil and self._roleServerType ~= 1 and controller:AnimNormalizedTime() >= 0.98 then
                controller:Play(self:_GetStandActionName())
                self._actName = nil
            end
        else
            self.actionType = ActionType.NORMAL;
            self:Finish();
        end
    end
end

function SkillAction:_OnCompleteHandler()
    if (self._owner and self._finishFunc) then
        self._finishFunc(self._owner);
        self._finishFunc = nil;
    end
end
