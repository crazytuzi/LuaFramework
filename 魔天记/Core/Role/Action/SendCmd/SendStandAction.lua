require "Core.Role.Action.StandAction";

SendStandAction = class("SendStandAction", StandAction)

function SendStandAction:New(position, angle)
    self = { };
    setmetatable(self, { __index = SendStandAction });
    self:Init();
    self.actionType = ActionType.SIMILARBLOCK;
    self._position = position;
    self._angle = angle; 
	--print("=========SendStandAction:New")
    return self;
end

--[[
function SendStandAction:_OnStopHandler()
    print("=========SendStandAction:Stop")
end
--]]

function SendStandAction:_OnStartCompleteHandler()
    local controller = self._controller

    if (controller and controller.transform) then
        local rotation = controller.transform.rotation.eulerAngles
        local position = controller.transform.position;
        local data = Convert.PointToServer(position, rotation.y);
        data.t = self._roleServerType;
        data.id = controller.id;
        if (controller.__cname == "HeroController") then
            MessageManager.Dispatch(PlayerManager, PlayerManager.SELFMOVEEND)
        end
        SocketClientLua.Get_ins():SendMessage(CmdType.RoleMoveEnd, data);
    end
end