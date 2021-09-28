require "Core.Role.Action.MoveToPathAction";

SendMoveToPathAction = class("SendMoveToPathAction", MoveToPathAction)


function SendMoveToPathAction:New(path)
	self = { };
	setmetatable(self, { __index = SendMoveToPathAction });
    self:Init();
	self.actionType = ActionType.NORMAL;
	--self._stopDistance = 0.1;
    self._disRoleEvent = true;    
	self:_InitPath(path);
	return self;
end

function SendMoveToPathAction:_OnStartCompleteHandler()
    self:_SendMessage(self._points);
end

function SendMoveToPathAction:_SendMessage(path)
    local controller = self._controller;
    if (controller) then
        local position = controller.transform.position;
        local data = Convert.PointToServer(position);
        data.paths = path;
        data.t = self._roleServerType;
        data.id = controller.id;
        SocketClientLua.Get_ins():SendMessage(CmdType.RoleMoveByPath, data);
    end
end