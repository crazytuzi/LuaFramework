require "Core.Role.Action.SkillStandAction";

SendSkillStandAction = class("SendSkillStandAction", SkillStandAction)

function SendSkillStandAction:New()
    self = { };
    setmetatable(self, { __index = SendSkillStandAction });
    self:Init();
    self.actionType = ActionType.COOPERATION;
    return self;
end

function SendSkillStandAction:_OnStartHandler()
    local controller = self._controller
    if (controller) then
        local rotation = controller.transform.rotation.eulerAngles
        local position = controller.transform.position;
        local data = Convert.PointToServer(position,rotation.y);
        SocketClientLua.Get_ins():SendMessage(CmdType.RoleMoveEnd, data);
    end
end