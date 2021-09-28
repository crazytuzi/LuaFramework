require "Core.Role.Action.AbsAction";

PathAction = class("PathAction", AbsAction)
PathAction.PathDir = "Prefabs/Path"

function PathAction:New()
    self = { };
    setmetatable(self, { __index = PathAction });
    self:Init();
    self.actionType = ActionType.NORMAL;
    return self;
end

-- 相机动画路径完成回调
function PathAction:_OnPathComplete()
    -- Warning("PathAction:_OnPathComplete:"..type(self._onComplete).."-"..type(self._pathPrefab))
    local func = self._onComplete
    self:Clear()
    if func then func() end
end
-- 设置轨迹动画,animTarget动画目标,pathName轨迹文件名,onComplete完成回调,lookTarget相机方向目标,useMapHeight是否使用寻路层的高度
function PathAction:InitPath(animTarget, pathName, onComplete, lookTarget, useMapHeight)
    -- Warning("PathAction:InitPath,animTarget="..tostring(animTarget)..",path="..pathName
    -- ..",onComplete="..type(onComplete) ..",useMapHeight="..tostring(useMapHeight))
    self._onComplete = onComplete
    self._useMapHeight = useMapHeight
    self._pathPrefab = Resourcer.Get(PathAction.PathDir, pathName)
    self._pather = self._pathPrefab:GetComponent("CameraPathBezierAnimator")
    self._pather.animationTarget = animTarget
    self._target = animTarget
    self._pather.lookTarget = lookTarget
    self._pather.isCamera = animTarget.camera ~= nil
    self._pather:Pause()
    self._pather.AnimationFinished = function() self:_OnPathComplete() end
    -- self._pather.AnimationFinished = DelegateFactory.CameraPathBezierAnimator_AnimationFinishedEventHandler(_OnPathComplete)
    return self
end

-- 停止动作
function PathAction:Stop()
    self:_OnPathComplete()
    self.super.Stop(self.super)
end

function PathAction:Play()
    if self._pather ~= nil then
        self._pather:Play()
        if self._useMapHeight and not self._coTimer then
            self._coTimer = CoTimer.New( function() self:_OnCoTime() end, 0, -1):Start()
        end
    end
end
function PathAction:_OnCoTime()
    if not IsNil(self._target) then
        MapTerrain.SampleTerrainPositionAndSetPos(self._target)

--        self._target.position = MapTerrain.SampleTerrainPosition(self._target.position)
        -- Warning("PathAction:_OnCoTime: " .. tostring(self._target.position))
    else
        self:Clear()
    end
end
function PathAction:ClearCoTimer()
    if (self._coTimer) then
        -- Warning("PathAction:ClearCoTimer " .. tostring(self._coTimer))
        self._coTimer:Stop();
        self._coTimer = nil;
    end
    self._target = nil
end
function PathAction:Clear()
    if self._pather then
        self._pather.AnimationFinished = nil
        self._pather = nil
    end
    if self._pathPrefab then
        Resourcer.Recycle(self._pathPrefab, false)
        self._pathPrefab = nil
    end
    self._onComplete = nil
    self:ClearCoTimer()
    self._target = nil
end

-- 返回当前坐标
function PathAction:GetPos()
    if self._pather ~= nil then
        return self._pather.animationTarget.position
    end
    return Vector3:New()
end
-- 返回当前进度(0-10000)
function PathAction:GetGrogress()
    if self._pather ~= nil then
        return math.ceil(self._pather.percentage * 10000)
    end
    return 0
end
-- 设置当前进度v(0-10000)
function PathAction:SetGrogress(v)
    v = v / 10000
    if self._pather ~= nil then
        self._pather:Seek(v)
    end
end
