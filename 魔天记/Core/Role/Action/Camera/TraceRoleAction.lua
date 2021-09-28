require "Core.Role.Action.PathAction";
TraceRoleAction = class("TraceRoleAction", PathAction)

-- 相机动画路径完成回调
function TraceRoleAction:_OnPathComplete()
    --print("TraceRoleAction:_OnPathComplete"..type(self._onComplete)..type(self._pathPrefab)..type(self._rolePathPrefab))
    local func = self._onComplete
    self:Clear()
    if func then func() end 
end
function TraceRoleAction:InitPath(camera,cameraPathName,rolePathName,onComplete,lookTarget,role)
    --log("TraceRoleAction:InitPath,camera="..tostring(camera)
        --..",cameraPathName="..tostring(cameraPathName)..",rolePathName="..tostring(rolePathName)
        --..",onComplete="..type(onComplete)..",lookTarget="..tostring(lookTarget)..",role="..tostring(role))
    self._onComplete = onComplete;
    local hasListenComplete = false
    if cameraPathName then
        self._pathPrefab = Resourcer.Get(PathAction.PathDir,cameraPathName);
        self._pather = self._pathPrefab:GetComponent("CameraPathBezierAnimator")
        self._pather.animationTarget = camera
        self._pather.lookTarget = lookTarget
        self._pather.isCamera = true
        self._pather:Pause()
        if self._pather.mode:ToInt() ~= 1 then
            self._pather.AnimationFinished = function () self:_OnPathComplete() end
            hasListenComplete = true
        end
        --self._pather.AnimationFinished = DelegateFactory.CameraPathBezierAnimator_AnimationFinishedEventHandler(_OnPathComplete)
        self._pather.useLocalPosition = true
    end

    if rolePathName then 
        self._rolePathPrefab = Resourcer.Get(PathAction.PathDir,rolePathName);
        self._patherRole = self._rolePathPrefab:GetComponent("CameraPathBezierAnimator")
        self._patherRole.animationTarget = role.transform
        self._patherRole.isCamera = false
        self._patherRole:Pause() 
        if not hasListenComplete and self._patherRole.mode:ToInt() ~= 1 then 
            self._patherRole.AnimationFinished = function () self:_OnPathComplete() end 
        end
        self._patherRole.useLocalPosition = false
    end
    self._camera = camera
    self._cameraParent = self._camera.parent
    self._camera.parent = role.transform
    return self 
end

function TraceRoleAction:Play()
    if self._pather ~= nil then self._pather:Play() end
    if self._patherRole ~= nil then self._patherRole:Play() end
end

function TraceRoleAction:Clear()
    if self._pather  then
        self._pather.AnimationFinished = nil
        self._pather = nil
    end
    if self._patherRole  then
        self._patherRole.AnimationFinished = nil
        self._patherRole = nil
    end
    if self._pathPrefab  then
        Resourcer.Recycle(self._pathPrefab,false)
        self._pathPrefab = nil
    end
    if self._rolePathPrefab then
        Resourcer.Recycle(self._rolePathPrefab,false)
        self._rolePathPrefab = nil
    end
    if self._camera  then
        self._camera.parent = self._cameraParent
        self._cameraParent = nil
        self._camera = nil
    end
    self._onComplete = nil
end

-- 返回当前坐标
function TraceRoleAction:GetPos()
    if self._patherRole ~= nil then
        return self._patherRole.animationTarget.position
    end
    return Vector3:New()
end
-- 返回当前进度(0-10000)
function TraceRoleAction:GetGrogress()
    if self._patherRole ~= nil then
        return  math.ceil(self._patherRole.percentage * 10000)
    end
    return 0
end
-- 设置当前进度v(0-10000)
function TraceRoleAction:SetGrogress(v)
    v = v / 10000
    if self._pather ~= nil then
        self._pather:Seek(v)
    end
    if self._patherRole ~= nil then
        self._patherRole:Seek(v)
    end
end