require "Core.Role.Controller.AbsController";
require "Core.Role.Action.Camera.LockHeroAction";
require "Core.Role.Action.Camera.LockMountAction";
require "Core.Role.Action.Camera.ShakeAction";
require "Core.Role.Action.Camera.ZoomAction";
require "Core.Role.Action.PathAction";
require "Core.Role.Action.Camera.TraceRoleAction";
require "Core.Role.Action.Camera.CameraToAction";
require "Core.Role.Action.Camera.PointAction";
require "Core.Role.Action.Camera.TrackTargetAction";
require "Core.Role.Action.Camera.LockDirctionAction";

MainCameraController = class("MainCameraController", AbsController);
MainCameraController.actionType = ControllerType.CAMERA;
MainCameraController.transform = nil;
MainCameraController.camera = nil;

MainCameraController._instance = nil;

function MainCameraController:GetInstance()
    if (MainCameraController._instance == nil) then
        MainCameraController._instance = MainCameraController:New();
    end
    return MainCameraController._instance;
end

function MainCameraController:New()
    self = { };
    setmetatable(self, { __index = MainCameraController });
    self:_Init();
    return self;
end

function MainCameraController:_Init()
    self.camera = Camera.main;
    self._applyParam = true
    MainCameraController.camera = self.camera
    -- log("MainCameraController:_Init,camera="..tostring(self.camera))
    if (self.camera) then
        self.transform = self.camera.transform;
        MainCameraController.transform = self.transform
        self.fieldOfView = self.camera.fieldOfView
        self.cullingMask = self.camera.cullingMask
        -- log("MainCameraController:_Init,transform="..tostring(self.transform))
        -- self:Test() --动态相机示
        -- self:FilterMask(LayerMask.GetMask(Layer.Player,Layer.Monster, Layer.NPC,Layer.Hero,Layer.Effect))
        -- Timer.New( function() self:RevertMask() end, 15,1):Start()
    end
end

-- 当前 相机 是否 为标准状
function MainCameraController:IsNormState()
    if DramaDirector.IsRunning() then return false end
    local act = self:GetAction();
    -- Warning("IsNormState____" .. tostring(act) .. tostring(act and act.__cname or 'nil'))
    return act and act.__cname == "LockHeroAction"
end

function MainCameraController:LockHero()
    local act = self:GetAction();
    -- log("LockHero___" .. tostring(act) .. tostring(act and act.__cname or 'nil'))
    if (act == nil or(act and act.__cname ~= "LockHeroAction")) then
        self.camera.fieldOfView = self.fieldOfView
        self:DoAction(LockHeroAction:New());
    else
        if (act.__cname ~= "LockHeroAction") then
            act:Refresh();
        end
    end
end

-- 设置相机可见LayerMask.GetMask(Layer.Player, Layer.Monster, Layer.NPC,Layer.Hero,Layer.Effect )
function MainCameraController:FilterMask(mask)
    if not self.camera then return end
    self.camera.cullingMask = mask
end
-- 还原相机可见
function MainCameraController:RevertMask()
    if not self.camera then return end
    self.camera.cullingMask = self.cullingMask
end

-- 锁定 载具 相机
-- 新版不需要了
--[[
function MainCameraController:LockMount(mountController)
    local act = self:GetAction();
    if (act == nil or(act and act.__cname ~= "LockMountAction")) then
        self:DoAction(LockMountAction:New(mountController));
    else
        if (act.__cname ~= "LockMountAction") then
            act:Refresh();
        end
    end
end
]]

function MainCameraController:GetHero()
    return HeroController.GetInstance()
end

local vback = Vector3.back
function MainCameraController:LookTarget(target)
    local transform = self.transform;
    Util.SetPos(transform, target.x, target.y + cameraOffsetY, target.z)
    Util.SetRotation(transform, cameraAngle, cameraLensRotation, 0)
    --    transform.position = Vector3.New(target.x, target.y + cameraOffsetY, target.z);
    -- transform.rotation = Quaternion.Euler(cameraAngle, cameraLensRotation, 0);
    transform:Translate(vback * cameraDistance);
end

function MainCameraController:SetPoint(pos, rotation)
    -- Warning("SetPoint:pos="..tostring(pos) .. ",rotation="..tostring(rotation))
    local transform = self.transform
    --Warning(tostring(Util.SetRotation) .. tostring(transform) .. tostring(rotation))
    -- Util.SetRotation(transform.gameObject, rotation.x, rotation.y, rotation.z)
    transform.rotation = Quaternion.Euler(rotation.x, rotation.y, rotation.z)
    Util.SetPos(transform,pos.x, pos.y, pos.z)
    --    transform.position = pos
end

--  Y轴方定 目标
function MainCameraController:TrackTarget()
    self:DoAction(TrackTargetAction:New())
end
--  锁定 目标
function MainCameraController:LockPoint(pos, rotation)
    self:DoAction(PointAction:New(pos, rotation))
end
--  锁定 Y轴方rotation
function MainCameraController:LockDirction(angleX, heightY, distance, angleY)
    self:DoAction(LockDirctionAction:New(angleX, heightY, distance, angleY))
end

-- 动态相机接震动,缩放,黑屏过度,相机轨迹,相机跟随角色轨迹,相机平滑衔接到英
-- 相机震动,type震动参数类型(定义在ShakeAction),onCompleted完成回调,actionType 动作类型,notTraceHero不跟踪主
function MainCameraController:Shake(type, onComplete, actionType, notTraceHero)
    if (AutoFightManager.GetBaseSettingConfig().showSkillShakeEffect) then
        self:DoAction(ShakeAction:New(type, onComplete, actionType, notTraceHero));
    end
end
-- 相机缩放,zoomSpeed速度,continueTime缩及放分别持续时stayTime中间持续时间,onCompleted完成回调,actionType 动作类型
function MainCameraController:Zoom(zoomSpeed, continueTime, stayTime, onComplete, actionType)
    if (AutoFightManager.GetBaseSettingConfig().showSkillShakeEffect) then
        self:DoAction(ZoomAction:New(zoomSpeed, continueTime, stayTime, onComplete, actionType));
    end
end
-- 是否可以设置相机参数
function MainCameraController:CanApplyParam()
    if not self._applyParam then return false end
    if GuideManager.isForceGuiding then return false end
    return self:IsNormState()
end
-- 恢复到默认设
function MainCameraController:RevertToDefaultSet()
    local rx = cameraAngle
    local ry = cameraLensRotation
    local dis = cameraDistance
    Scene.instance:CameraResetDefault()
    UpdateCameraConfig()
    local trx = cameraAngle
    local try = cameraLensRotation
    local tdis = cameraDistance
    local tt = 1.2 t = 0
    self._applyParam = false
    Scene.instance:SetJesture(false)
    local timer = nil
    timer = FrameTimer.New( function()
        t = t + Timer.deltaTime
        local s = t / tt
        if s >= 1 then
            cameraAngle = trx
            cameraLensRotation = try
            cameraDistance = tdis
            self._applyParam = true
            Scene.instance:SetJesture(true)
            timer:Stop()
            timer = nil
            return
        end
        cameraAngle = math.LerpAngle(rx, trx, s)
        cameraLensRotation = math.LerpAngle(ry, try, s)
        cameraDistance = math.lerp(dis, tdis, s)
    end , -1, -1, false)
    timer:Start()
end

-- 相机镜头切换,黑屏过度,onCompleted完成回调,onMiddled淡入回调
function MainCameraController:ChangeCameraForBlack(onCompleted, onMiddled, color, fadeInTime, fadeOutTime, waitTime)
    local c = color and color or Color.black
    local fit = fadeInTime and fadeInTime or 1
    local fot = fadeOutTime and fadeOutTime or 1
    local wt = waitTime and waitTime or 2
    Core.ScreenEffect.instance:Fade(onCompleted, onMiddled, c, fit, fot, wt)
end
-- 设置相机轨迹动画,pathName轨迹文件onComplete完成回调,lookTarget相机方向目标
function MainCameraController:CameraPath(pathName, onComplete, lookTarget)
    local action = PathAction:New()
    action:InitPath(self.transform, pathName, onComplete, lookTarget)
    self:DoAction(action);
    return action
end
-- 设置相机跟随角色轨迹,
-- cameraPathName 相机本地轨迹动画文件可为nil
-- rolePathName 角色全局轨迹动画文件可为nil
-- onComplete完成回调
-- 角色role
-- 相机面向目标
-- 此函数会另外加载 pathName + TraceRoleAction.PATH_SUB 的相机轨迹文
function MainCameraController:TraceRolePath(cameraPathName, rolePathName, onComplete, role, lookTarget)
    local action = TraceRoleAction:New()
    action:InitPath(self.transform, cameraPathName, rolePathName, onComplete, lookTarget, role)
    self:DoAction(action);
    return action
end
-- 当有相机轨迹调用播放,用于不要马上播放轨迹动画
function MainCameraController:PlayPath()
    -- logTrace("_action=" ..type(self._action).. ", .Play=".. type(self._action.Play))
    if self._action and self._action.Play then
        self._action:Play();
    end
end
-- 当前相机平滑衔接到英time用时, onComplete完成回调
function MainCameraController:ChangeCameraToHero(time, onComplete)
    local target = self:GetHero().transform.position
    local trf = self.transform;
    local pos = trf.position;
    local angle = trf.rotation;
    self:LookTarget(target)
    self:DoAction(CameraToAction:New(time, pos, angle, trf.position, trf.rotation, function()
        self:LockHero()
        if onComplete ~= nil then onComplete() end
    end , self.camera, self.camera.fieldOfView, self.fieldOfView));
end

-- 动态相机示
function MainCameraController:TestFade(onCompleted, onMiddled)
    self:ChangeCameraForBlack( function()
        logTrace("fade completed " .. type(onCompleted))
        if onCompleted ~= nil then onCompleted() end
    end , function()
        logTrace("fade middled ")
        if onMiddled ~= nil then onMiddled() end
    end , nil, 1, 2, 2)
end
function MainCameraController:TestPath(onCompleted)
    self:CameraPath("Path_10001", function()
        logTrace("PlayCameraPath completed " .. type(onCompleted))
        if onCompleted ~= nil then onCompleted() end
    end , self:GetHero():GetCenter())
end
function MainCameraController:TestTraceRolePath(onCompleted)
    local hasRolePath = false
    -- true 主角是否移动轨迹
    if hasRolePath then
        self:TraceRolePath("Path_10000_sub", "Path_10000", function()
            logTrace("TraceRolePath completed " .. type(onCompleted))
            if onCompleted ~= nil then onCompleted() end
        end , self:GetHero(), self:GetHero():GetCenter())
    else
        local pos = self:GetHero().transform.position
        pos.x = pos.x + math.random(-30, 30)
        pos.z = pos.z + math.random(-30, 30)
        self:GetHero():MoveTo(pos)
        -- 没有角色移动轨迹调用寻路移动主角,相机轨迹跟随
        self:TraceRolePath("Path_10000_sub", nil, function()
            logTrace("TraceRolePath completed " .. type(onCompleted))
            if onCompleted ~= nil then onCompleted() end
        end , self:GetHero(), self:GetHero():GetCenter())
    end
end
function MainCameraController:TestZoom(onCompleted)
    self:Zoom(10, 2, 10, function()
        logTrace("TestZoom completed " .. type(onCompleted))
        if onCompleted ~= nil then onCompleted() end
    end , ActionType.NORMAL)
end
function MainCameraController:TestShake(onCompleted)
    self:Shake(3, function()
        logTrace("TestShake completed " .. type(onCompleted))
        if onCompleted ~= nil then onCompleted() end
    end , ActionType.NORMAL)
end
function MainCameraController:TestLookHero(onCompleted)
    self:ChangeCameraToHero(3, function()
        logTrace("TestLookHero completed " .. type(onCompleted))
        if onCompleted ~= nil then onCompleted() end
    end )
end
function MainCameraController:WaterWaveEffect(flg)
    if not self.waterWave then 
        self.waterWave = UIUtil.GetComponent(self.camera, "CameraEffect")
    end
    --Warning(tostring(self.waterWave) .. tostring(flg) )
    if self.waterWave then 
        self.waterWave.enabled = true
    end    
end


function MainCameraController:TestAll()
    self:TestPath( function()
        -- 测试相机轨迹动画完成
        self:TestZoom( function()
            -- 测试相机缩放完成
            self:TestFade( function()
                -- 测试黑屏切换完成
                self:PlayPath()
            end , function()
                -- 黑屏切换中间做点什
                self:TestTraceRolePath( function()
                    -- 测试相机跟随角色并播放动
                    self:TestShake( function()
                        -- 测试相机震动
                        self:TestLookHero( function()
                            -- 测试相机衔接到英
                            print("TestAll completed-------------------------")
                        end )
                    end )
                end )
            end )
        end )
    end )
    self:PlayPath()
    -- 测试相机轨迹动画
end
function MainCameraController:Test()
    -- self:TestFade()
    -- self:TestPath()
    -- self:TestTraceRolePath()
    -- self:TestLookHero()
    self:TestAll()
end
