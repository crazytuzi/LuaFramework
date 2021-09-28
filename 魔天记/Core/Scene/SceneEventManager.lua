require "Core.Module.DramaDirector.DramaDirector"
SceneEventManager = class("SceneEventManager")

local NEAR_DISTANCE = 10
local ObstacleState = { open = "open", close = "close", opened = "opened", closed = "closed" }
-- 0:无变化1:关闭阻挡2:打开阻挡3:修改复活点4:触发剧情 5:场景物件动画
local EventStateValue = { nor = 0, open = 2, close = 1, resetLive = 3, drama = 4, sceneAction = 5, cameraAmend = 6 }
-- 1:玩家接近2:指定怪物出现3:指定怪物被击杀4:指定波数怪物被击杀5:指定波数怪物出现6:修改复活点
local ConditionType = {
    near = 1,
    monsterAppear = 2,
    monsterDie = 3,
    monstersDie = 4,
    monstersAppear = 5,
    resetLive = 6
}

local _obstacleConfig = nil -- 当前场景障碍配置
local _obstacleGO = nil -- 当前场景障碍预设
local _obstacleGroup = nil -- 当前场景障碍table{id={animator...}...}
local _obstacleNear = nil -- 当前场景靠近触发的障碍table{id={animator...}...}
local _hero = nil -- 检测靠近障碍开关的主角tranfsform
local _checkTimer = nil -- 检测靠近计时器
local _openCloseTimers = nil -- 延迟开关的计时器table{id=Timer...}
local _cameraCache = nil -- 修正镜头缓存

local insert = table.insert

function SceneEventManager:New()
    self = { };
    setmetatable(self, { __index = SceneEventManager });
    self._ChangeObstacleState = function(cmd, data2)
        self:ChangeObstacleState(data2);
    end
    return self;
end

-- 进入场景
function SceneEventManager:EnterScene(data, sceneId, mapId)
    self:Clear()
    -- Warning("SceneEventManager:EnterScene:data=" ..tostring(data) ..",sceneId=" .. sceneId .. ",mapId=" .. mapId)
    if data == nil or #data == 0 then return end
    -- data = {{id=1,st=2},{id=2,st=1},{id=3,st=1}}
    _openCloseTimers = { }
    self:_InitConfig(sceneId)
    _hero = HeroController.GetInstance().transform
    if self._hasObstacle then self:loadGO(mapId) end
    self:OnLoadedGO(data, sceneId)
end
function SceneEventManager:loadGO(mapId)
    _obstacleGroup = { }
    _obstacleGO = Resourcer.Get("Prefabs/Obstacle", mapId .. "_obstacle")
    if _obstacleGO == nil then return end
    local trf = _obstacleGO.transform
    local num = trf.childCount
    -- Warning("SceneEventManager:loadGO:_obstacleGO=" .. _obstacleGO.name .. ",num=" .. num)
    for i = 0, num - 1, 1 do
        local cTrf = trf:GetChild(i)
        local name = cTrf.name
        local id = string.split(name, '_')[1]
        if _obstacleGroup[id] == nil then _obstacleGroup[id] = { } end
        insert(_obstacleGroup[id], cTrf)
        -- Warning("name=" ..name ..",id=" .. id  .. ",num=" .. (#_obstacleGroup[id]) )
    end
    MapTerrain.GetInstance():InitObstacle()
end
function SceneEventManager:OnLoadedGO(data, sceneId)
    self:_InitData(data)
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.SceneObstaclChange, self._ChangeObstacleState)
end
function SceneEventManager:_InitConfig(sceneId)
    local obsIds = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_MAP)[sceneId]
    if not (obsIds) then
        log("场景表中不存在" .. sceneId)
    end
    -- [704041] --
    obsIds = obsIds["map_obstacle"]
    _obstacleConfig = { }
    self._hasObstacle = false
    local obsConfig = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_OBSTACLE)
    for i, v in pairs(obsIds) do
        local conf = obsConfig[v]
        _obstacleConfig[v] = conf
        if (conf == nil) then
            log("obstacle表中找不到" .. tostring(v))
        end

        if conf.condition == ConditionType.near then
            if _obstacleNear == nil then _obstacleNear = { } end
            if _checkTimer == nil then
                _checkTimer = self:_GetTimer(0.2, -1, function(val) self:CheckNearObstacle(val) end, nil)
            end
            local par = conf.condition_para
            local conff = { }
            conff["id"] = v
            conff["pos"] = Vector3.New(par[1] / 100, 0, par[2] / 100)
            conff["dis"] = par[3] / 100
            conff.conf = conf
            _obstacleNear[v] = conff
        end
        if not self._hasObstacle then
            self._hasObstacle = conf.initial_state == EventStateValue.open or conf.initial_state == EventStateValue.close
            or conf.results == EventStateValue.open or conf.results == EventStateValue.close
        end
    end
    -- PrintTable(_obstacleConfig)
    -- Warning("SceneEventManager:OnLoadedGO:sceneId="..sceneId.. ",obsLen=" .. #_obstacleConfig)
end
function SceneEventManager:_GetTimer(duration, loop, onTime, OnComplete)
    local t = Timer.New(onTime, duration, loop, false)
    if OnComplete then t:AddCompleteListener(OnComplete) end
    t:Start();
    return t
end;
function SceneEventManager:_InitData(data)
    for i, v in pairs(data) do
        self:ChangeObstacleState(v, true)
    end
end
function SceneEventManager:UpdateData(data)
    for i, v in pairs(data) do
        self:ChangeObstacleState(v, false)
    end
end

-- 障碍状态改变
function SceneEventManager:ChangeObstacleState(data, isInit)
    self:ChangeObstacleStateing(data.id, data.st, isInit)
    if data.rt and data.rt > 0 then
        local msg = {
            downTime = data.rt / 1000,
            prefix = LanguageMgr.Get("downTime/prefix")
            ,
            endMsg = LanguageMgr.Get("MainUI/MainUIPanel/StartFight")
            ,
            endMsgDuration = 3
        }
        -- PrintTable(msg,"",Warnging)
        MessageManager.Dispatch(SceneEventManager, DownTimer.DOWN_TIME_START, msg);
    end
end
function SceneEventManager:ChangeObstacleStateing(id, eventState, isInit)
    -- Warning("SceneEventManager:ChangeObstacleStateing:id=" .. id .. ",eventState=" .. tostring(eventState))
    local conf = _obstacleConfig[id]
    if conf then
        if eventState == EventStateValue.open or eventState == EventStateValue.close then
            local open = eventState == EventStateValue.open
            local t = _openCloseTimers[id];
            if t then t:Stop() end
            if open then
                -- Warning(tostring(t) .. "___" .. tostring(_obstacleConfig[id]))
                local rp = conf.results_para[1]
                rp = rp and string.trim( rp ) or ""
                local t = string.len(rp) > 0 and tonumber(rp) or 0
                if t > 0 then
                    _openCloseTimers[id] = self:_GetTimer(t / 1000, 1, function(val)
                        -- Warning("SceneEventManager:ChangeObstacleStateing,delay id=" .. id .. ",open=" .. tostring(open))
                        MapTerrain.GetInstance():ChangeObstacleState(id, open)
                        _openCloseTimers[id] = nil
                    end )
                else
                    MapTerrain.GetInstance():ChangeObstacleState(id, open)
                end
            else
                -- Warning("SceneEventManager:ChangeObstacleStateing:" .. id .. ",open=" .. tostring(open))
                MapTerrain.GetInstance():ChangeObstacleState(id, open)
            end

            local anims = _obstacleGroup[tostring(id)]
            -- Warning("SceneEventManager:ChangeObstacleStateing:anims=" .. type(anims))
            if anims == nil then return end
            local change = false
            local toState = open and ObstacleState.open or ObstacleState.close
            for i, v in pairs(anims) do
                change = self:_ChangeStateView(id, v, open, toState, change);
            end
            -- Warning("change=" .. tostring(change) .. ",toState=" .. tostring(toState))
        elseif eventState == EventStateValue.drama then
            local t = conf.results_para[1]
            t = t and tonumber(t) or 0
            if not isInit then DramaDirector.Trigger(t) end
            -- DramaDirector.Trigger(tonumber(conf.results_para[1]))
        elseif eventState == EventStateValue.sceneAction then
            local rp = conf.results_para
            local animName = isInit and ObstacleState.opened or ObstacleState.open
            if #rp == 1 or isInit then
                self:_PlaySceneAct(rp[1], animName)
            else
                Timer.New( function() self:_PlaySceneAct(rp[1], animName) end, tonumber(rp[2]) / 1000, 1, false):Start()
            end
        end
    end
end
function SceneEventManager:_PlaySceneAct(objname, animName)
    if not _obstacleConfig then return end
    local act = self:_GetSceneAct(objname)
    act:Play(animName)
end
function SceneEventManager:_GetSceneAct(objname)
    local trf = GameObject.Find(objname)
    local animator = trf:GetComponent("Animator")
    return animator
end

function SceneEventManager:_ChangeStateView(id, cTrf, open, toState, change)
    local animator = cTrf:GetComponent("Animator")
    -- Warning(id .. cTrf.name ..  tostring(open) .. toState .. tostring(change) .. tostring(animator))
    if animator then
        if not change then
            local animatorInfo = animator:GetCurrentAnimatorStateInfo(0);
            if open then
                if animatorInfo:IsName(ObstacleState.close) or animatorInfo:IsName(ObstacleState.closed) then
                    change = true
                end
            else
                if animatorInfo:IsName(ObstacleState.open) or animatorInfo:IsName(ObstacleState.opened) then
                    change = true
                end
            end
            if not change then return end
        end
        animator:Play(toState)
    else
        -- Warning(tostring(cTrf:FindChild(ObstacleState.open)))
        local openV = cTrf:FindChild(ObstacleState.open).gameObject;
        local opened = cTrf:FindChild(ObstacleState.opened).gameObject;
        local close = cTrf:FindChild(ObstacleState.close).gameObject;
        local closed = cTrf:FindChild(ObstacleState.closed).gameObject;
        openV:SetActive(false);
        opened:SetActive(false);
        close:SetActive(false);
        closed:SetActive(false);
        -- Warning(tostring(openV) .. tostring(opened) .. tostring(close) .. tostring(closed))
        if open then
            openV:SetActive(true);
        else
            close:SetActive(true);
        end

        local effecttime = "effect" .. cTrf.name .. id
        local oldt = _openCloseTimers[effecttime];
        if oldt then oldt:Stop() end
        _openCloseTimers[effecttime] = self:_GetTimer(1.5, 1, function(val)
            _openCloseTimers[effecttime] = nil
            -- Warning("SceneEventManager:ChangeObstacleStateing,delay id=" .. id .. ",open=" .. tostring(open))
            if open then
                openV:SetActive(false);
                opened:SetActive(true);
            else
                close:SetActive(false);
                closed:SetActive(true);
            end
        end )
    end
    return true
end

-- 检查是否靠近障碍
function SceneEventManager:CheckNearObstacle(args)
    local hpos = _hero.position
    for i, v in pairs(_obstacleNear) do
        local opos = v["pos"]
        local dis = Vector3.Distance2(hpos, opos)
        local near = dis < v["dis"]
        local res = v.conf["results"]
        if res == EventStateValue.drama then
            if near and not v.trigger then
                DramaDirector.Trigger(tonumber(v.conf.results_para[1]))
                v.trigger = true
            end
        elseif res == EventStateValue.open or res == EventStateValue.close then
            if v["st"] ~= near then
                v["st"] = near
                local data = { id = v["id"], st = near and EventStateValue.open or EventStateValue.close }
                SocketClientLua.Get_ins():SendMessage(CmdType.SceneObstaclChange, data)
                break;
            end
        elseif res == EventStateValue.cameraAmend then
            if near and(not _cameraCache or not _cameraCache[i .. ""]) then
                if not _cameraCache then _cameraCache = { } end
                _cameraCache[i .. ""] = true
                local rp = v.conf.results_para
                MainCameraController.GetInstance():LockDirction(tonumber(rp[1]), tonumber(rp[2]), tonumber(rp[3]), tonumber(rp[4]))
            end
        end
    end
end
-- 清空修正镜头缓存
function SceneEventManager.ClearCameraCache()
    _cameraCache = nil
end

-- 清理
function SceneEventManager:Clear()
    MessageManager.Dispatch(SceneEventManager, DownTimer.DOWN_TIME_END);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.SceneObstaclChange, self._ChangeObstacleState)
    _obstacleConfig = nil
    if _obstacleGO then
        Resourcer.Recycle(_obstacleGO, false)
        _obstacleGO = nil
    end
    _obstacleGroup = nil
    _obstacleNear = nil
    _hero = nil
    if _checkTimer then
        _checkTimer:Stop()
        _checkTimer = nil
    end
    if _openCloseTimers then
        for i, t in pairs(_openCloseTimers) do t:Stop() end
        _openCloseTimers = nil
    end
end
