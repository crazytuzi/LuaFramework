require "Core.Role.Action.MoveToPathAction";

MoveToAction = class("MoveToAction", MoveToPathAction)
local __portals = nil;
local __portalIndex = 1;
local insert = table.insert

function MoveToAction:New(position, map)
    self = { };
    setmetatable(self, { __index = MoveToAction });    
    local tMap = map or GameSceneManager.map.info.id;
    self:Init();
    self.actionType = ActionType.NORMAL;
    self._toPosition = position;
    self._toMap = tMap;
    -- logTrace("MoveToAction:New,map=" .. map .. ",toMap=" .. self._toMap);
    self.isAcrossMap =(self._toMap ~= GameSceneManager.map.info.id);
    return self;
end



function MoveToAction:_OnStartHandler()
    local controller = self._controller;
    if (controller) then
        controller.state = RoleState.MOVE;
        self.isListenerEvent = self.isAcrossMap;
        if (self.isListenerEvent) then
            MessageManager.AddListener(GameSceneManager, GameSceneManager.MESSAGE_SCENE_START, MoveToAction._SceneStartHandler, self);
            MessageManager.AddListener(GameSceneManager, GameSceneManager.MESSAGE_SCENE_END, MoveToAction._SceneEndHandler, self);
        end
        if (self.isAcrossMap) then
            __portals = MoveToAction:_SearchMapPortals(GameSceneManager.map.info.id, self._toMap, controller.transform.position);
            __portalIndex = 1;
            --if (__portals == nil) then
                -- MoveToAction:_DirectToMap(self._toMap);
                self:_DirectToMap(self._toMap);                
                return;
            --end
        end
        self:_SearchPath();
        if (self._path) then
            self:_NextPosition();
            self:_InitTimer(0, -1);
        else            
            self:Finish();
        end
    else
        self:Finish();
    end
end

function MoveToAction:_OnStartRemoveListenerHandler()
    if (self.isListenerEvent) then
        MessageManager.RemoveListener(GameSceneManager, GameSceneManager.MESSAGE_SCENE_START, MoveToAction._SceneStartHandler);
        MessageManager.RemoveListener(GameSceneManager, GameSceneManager.MESSAGE_SCENE_END, MoveToAction._SceneEndHandler);
    end
end

function MoveToAction:_SceneStartHandler()
    -- logTrace("MoveToAction:_SceneStartHandler:tomap="..self._toMap..",map="..GameSceneManager.map.info.id);
    if (self._controller) then 
        self:_SearchPath();
        if (self._path) then
            self:_NextPosition();
            if (self._timer == nil) then
                self:_InitTimer(0, -1);
            end
            self:Resume();

            --  到这一步，有可能意外原因导致 停止动作，
            -- 当停止动作事，设置  self:Finish();
            if self._controller ~= nil then
                self._controller:Play(RoleActionName.run);
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

function MoveToAction:_SceneEndHandler()
    -- logTrace("MoveToAction:_SceneEndHandler:_path=".. tostring(self._path));
    self._path = nil;
    self._toPoint = nil;
    self._endPoint = nil;
    self:Pause();
end

function MoveToAction:_OnCompleteHandler()
    if (GameSceneManager.map and GameSceneManager.map.info) then
        if (self._toMap == GameSceneManager.map.info.id) then

            if self._controller and(self._controller.roleType == ControllerType.HERO or(self._controller.roleType == ControllerType.MOUNT and self._controller._playerController.roleType == ControllerType.HERO)) then
                SequenceManager.TriggerEvent(SequenceEventType.Base.MOVE_TO_PATH_END, self._toPosition);
            end

            self:Finish();
        else
            self._controller:Play(self:_GetStandActionName(controller));
            self:Pause();
        end
    else
        self:Pause();
    end
end

function MoveToAction:_SearchPathHandler()

end

function MoveToAction:_SearchPath()
    local controller = self._controller;
    -- logTrace("MoveToAction:_SearchPath:controller="..tostring(controller)..",_toPosition="..tostring(self._toPosition));
    if (controller) then
        -- logTrace("MoveToAction:_SearchPath:_toMap="..self._toMap..",map="..GameSceneManager.map.info.id);
        local toPosition = self._toPosition
        self.isAcrossMap =(self._toMap ~= GameSceneManager.map.info.id);
        -- log("_SearchPath")
        -- log(self._toMap)
        if (self.isAcrossMap) then
            local portal = self:_SearchToNextMapPortal(self._toMap)

            if (portal) then
                toPosition = Vector3.New(portal.x / 100, portal.y / 100, portal.z / 100);
            else
                toPosition = nil;
            end
            -- logTrace("MoveToAction:_SearchPath:cMap="..GameSceneManager.map.info.id..",toPosition="..tostring(toPosition));
        end

        if (toPosition) then
            if (not self.isAcrossMap and Vector3.Distance2(controller.transform.position, toPosition)< 0.01) then
                self:_OnCompleteHandler()
            else
            local pathStr = GameSceneManager.mpaTerrain:FindPath(controller.transform.position, toPosition);
            -- logTrace("MoveToAction:_SearchPath:pathStr="..pathStr);
            if (pathStr and pathStr ~= "") then
                local path = string.splitToNum(pathStr, ",");
                self:_InitPath(path);
                self:_SearchPathHandler();
            else
                self:Finish();
            end
            end
        else
            self:Finish();
        end
    end
end

function MoveToAction:_SearchToNextMapPortal()
    if (__portals) then
        local protal = __portals[__portalIndex];
        if (protal) then
            __portalIndex = __portalIndex + 1;
            return protal;
        end
    end
    return nil;
end
--[[
    local cMap = GameSceneManager.map.info.id;
    local tMap = self._toMap;
    local cls = self:_GetMapPortal(cMap);
    for i, v in pairs(cls) do
        if (v.to_map == tMap) then
            return v;
        else
            local closeList = { };
            local index = 1;
            local ls = self:_GetMapPortal(v.to_map);
            for ci, cv in pairs(cls) do
                insert(closeList, cv);
            end
            while (index <= #ls) do
                local cPortal = ls[index];
                index = index + 1;
                if (cPortal.to_map == tMap) then
                    return v;
                else
                    if (table.contains(closeList, cPortal) == false) then
                        local tls = self:_GetMapPortal(cPortal.to_map);
                        insert(closeList, cPortal);
                        for ii, vv in pairs(tls) do
                            if (table.contains(closeList, vv) == false) then
                                insert(ls, vv);
                            end
                        end
                    end
                end
            end
        end
    end
    return nil;
end

function MoveToAction:_GetMapPortal(id)
    local portalCfg = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_MAP_PORTAL);
    local ls = { };
    for i, v in pairs(portalCfg) do
        if (v.map == id) then
            insert(ls, v);
        end
    end
    print("======== "..id);
    PrintTable(ls);
    return ls;
end
--]]

function MoveToAction:_SearchMapPortals(cMap, tMap, pt)
    local portalCfg = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_MAP_PORTAL);
    local currentPortal = { };
    -- 直达传送
    for i, v in pairs(portalCfg) do
        if (v.map == cMap) then
            if (v.to_map == tMap) then
                return { [1] = v }
            end
            insert(currentPortal, v);
        end
    end
    -- 中转传送
    for i, v in pairs(currentPortal) do
        local map = v.to_map;
        for i2, v2 in pairs(portalCfg) do
            if (v2.map == map) then
                if (v2.to_map == tMap) then
                    return { [1] = v, [2] = v2 };
                end
            end
        end
    end
    return nil;
end

-- 直接刷到目标地图
function MoveToAction:_DirectToMap(tmap)

    local mapInfo = GameSceneManager.GetMapInfo(tmap);
    if (mapInfo) then
        if (mapInfo.type ~= 2) then
            -- 副本不能跳
            GameSceneManager.GotoScene(tmap)
        end
    end
end
