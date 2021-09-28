require "Core.Role.Action.MoveToAction";

SendMoveToAction = class("SendMoveToAction", MoveToAction)

function SendMoveToAction:New(position, map, gotoSceneNeedShowLoader ,d)
    self = { };
    setmetatable(self, { __index = SendMoveToAction });    
    local tMap = map or GameSceneManager.map.info.id;
    self:Init();
    self.actionType = ActionType.NORMAL;
    self._toPosition = position;
    self._toMap = tMap;
    self._stopDistance = d or 0
    self._gotoSceneNeedShowLoader = gotoSceneNeedShowLoader;
    self._disRoleEvent = true;
    -- logTrace("SendMoveToAction:New,map=" .. map .. ",toMap=" .. self._toMap);
    self.isAcrossMap =(self._toMap ~= GameSceneManager.map.info.id);
    return self;
end

function SendMoveToAction:SetToPosition(position)
    local controller = self._controller;
    self._toPosition = target.transform.position;
    if (controller) then
        self:_SearchPath();
    end
end

function SendMoveToAction:_SearchPathHandler()
    self:_SendMessage(self._points);
end

function SendMoveToAction:_SendMessage(path)
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

-- 直接刷到目标地图
function SendMoveToAction:_DirectToMap(tmap)
    local mapInfo = GameSceneManager.GetMapInfo(tmap);
    if (mapInfo) then
        if (mapInfo.type ~= 2) then
            -- 副本不能跳
            if self._gotoSceneNeedShowLoader then
                self._controller:Play(self:_GetStandActionName(self._controller));
                GameSceneManager.GotoSceneByLoading(tmap)
            else
                GameSceneManager.GotoScene(tmap)
            end
        else
            self:Finish()
        end
    end
end

function SendMoveToAction:_OnStopHandler()    
    local controller = self._controller;
    if (controller == PlayerManager.hero and self._disRoleEvent) then
        MessageManager.Dispatch(PlayerManager, PlayerManager.StopAutoRoad);
    end
end

function SendMoveToAction:_DispatchStartEvent()
    local controller = self._controller;
    if (controller == PlayerManager.hero and self._disRoleEvent) then
        MessageManager.Dispatch(PlayerManager, PlayerManager.StartAutoRoad);
    end
end

function SendMoveToAction:_DispatchStopEvent()
    local controller = self._controller;
    if (controller == PlayerManager.hero and self._disRoleEvent) then
        MessageManager.Dispatch(PlayerManager, PlayerManager.StopAutoRoad);
    end
end