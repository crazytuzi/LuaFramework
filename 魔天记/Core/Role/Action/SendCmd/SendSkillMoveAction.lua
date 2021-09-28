require "Core.Role.Action.SkillMoveAction";

SendSkillMoveAction = class("SendSkillMoveAction", SkillMoveAction)

function SendSkillMoveAction:New(angle)
    self = { };
    setmetatable(self, { __index = SendSkillMoveAction });
    self:Init();
    self.actionType = ActionType.COOPERATION;
    self:_SetAngle(angle);
    return self;
end

function SendSkillMoveAction:SetAngle(angle)
    self:_SetAngle(angle);
    self:_OnStartCompleteHandler();
end

function SendSkillMoveAction:_OnStartCompleteHandler()
    local controller = self._controller
    if (controller) then
        local rotation = controller.transform.rotation.eulerAngles
        local position = controller.transform.position;
        local data = Convert.PointToServer(position,self._angle);        
        SocketClientLua.Get_ins():SendMessage(CmdType.RoleMoveByAngle, data);
    end
end;
