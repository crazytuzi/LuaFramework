---
--- Created by R2D2.
--- DateTime: 2019/3/7 19:21
---

CreateRoleSceneManager = {}

local self  = CreateRoleSceneManager

CreateRoleSceneManager.Scene_Create = "LoginScene"
CreateRoleSceneManager.abName = "asset/loginscene" .. AssetsBundleExtName
CreateRoleSceneManager.Scene_Main = "main"
CreateRoleSceneManager.Effects = {
    "effect_feixiangqianfang",
}

self.isChangeScene = false
self.is_load = false

self.changeSceneCallBack = nil

function CreateRoleSceneManager:LoadAB(cls,call_back)
    if self.is_load then
        call_back(CreateRoleSceneManager.Scene_Create)
        return
    end

    self.changeSceneCallBack = call_back

    if self.isChangeScene then
        return
    end

    self.isChangeScene = true
    local function changeScneneEnd(activeSceneName)
        self.isChangeScene = false
        if CreateRoleSceneManager.changeSceneCallBack then
            CreateRoleSceneManager.changeSceneCallBack(activeSceneName)
        end
        CreateRoleSceneManager.changeSceneCallBack = nil
    end
    local function loadAbCallBack()
        CreateRoleSceneManager:LoadCreateScene(changeScneneEnd)
    end
    if lua_resMgr:IsInDownLoadList(CreateRoleSceneManager.abName) then
        local function down_load_call_back(abName)
            lua_resMgr:LoadScene(cls, CreateRoleSceneManager.Scene_Create, loadAbCallBack)
        end
        lua_resMgr:AddDownLoadList(cls, CreateRoleSceneManager.abName, down_load_call_back, Constant.LoadResLevel.Urgent)
    else
        lua_resMgr:LoadScene(cls, CreateRoleSceneManager.Scene_Create, loadAbCallBack)
    end
end

---加载创角场景
function CreateRoleSceneManager:LoadCreateScene(loadCallBack, progressCallBack)
    self.LoadedCallBack = loadCallBack
    self.ProgressCallBack = progressCallBack
    SceneSwitch.Instance:LoadSceneAsync(self.Scene_Create, 1, handler(self, self.OnSceneLoaded), handler(self, self.OnLoadProgress))
end

---卸载创角场景
function CreateRoleSceneManager:UnloadCreateScene(unLoadCallBack)
    self.UnloadCallBack = unLoadCallBack
    SceneSwitch.Instance:UnloadScene(self.Scene_Create, handler(self, self.OnSceneUnloaded))
end

------------------------------以下为回调方法---------------------------
function CreateRoleSceneManager:OnLoadProgress(value)
    if (self.ProgressCallBack) then
        self.ProgressCallBack(value)
    end
end

function CreateRoleSceneManager:OnSceneUnloaded(sceneName)
    if (self.UnloadCallBack) then
        self.UnloadCallBack(sceneName)
    end
    self:UnLoadObject()
end

function CreateRoleSceneManager:UnLoadObject()
    self.is_load = false
    self.Camera = nil
    self.CameraAnimator = nil
    self.CameraStartPos = nil

    self.R1Pos = nil
    self.R2Pos = nil
    self.TgPos = nil

    self.effect_list = nil
end

function CreateRoleSceneManager:OnSceneLoaded(sceneName)
    if (sceneName == self.Scene_Create) then
        SceneSwitch.Instance:ActiveScene(sceneName, handler(self, self.OnActiveSceneChanged))
    end
end

function CreateRoleSceneManager:OnActiveSceneChanged(orgSceneName, activeSceneName)
    if (activeSceneName == self.Scene_Create) then
        self:GetScenePoint()

        if (self.LoadedCallBack) then
            self.LoadedCallBack(activeSceneName)
        end
    end
end

function CreateRoleSceneManager:GetScenePoint()
    self.is_load = true
    
    --self.Camera = GameObject.Find("Camera"):GetComponent("Camera")
    self.Camera = GameObject.Find("CreateRole_Camera")
    self.CameraAnimator = self.Camera:GetComponent('Animator')
    self.CameraStartPos = self.Camera.transform.position

    self.R1Pos = GameObject.Find("RolePos1").transform.position
    self.R2Pos = GameObject.Find("RolePos2").transform.position
    self.TgPos = GameObject.Find("TargetPos").transform.position

    self.effect_list = {}
    for _, v in ipairs(CreateRoleSceneManager.Effects) do
        local e = GameObject.Find(v)
        if (e) then
            SetVisible(e.transform, false)
            self.effect_list[v] = e
        end
    end
end

function CreateRoleSceneManager:SetEffectVisible(effect_name, isVisible)
    if (self.effect_list[effect_name]) then
        SetVisible(self.effect_list[effect_name], false)
        if (isVisible) then
            SetVisible(self.effect_list[effect_name], true)
        end
    end
end

function CreateRoleSceneManager:PlayCameraAnimation(actionName)
    if (self.CameraAnimator) then
        SetGlobalPosition(self.Camera.transform, self.CameraStartPos.x, self.CameraStartPos.y, self.CameraStartPos.z)
        self.CameraAnimator:CrossFade(actionName, 0)
    end
end

function CreateRoleSceneManager:ResetCamera()
    self.CameraAnimator:CrossFade("idle", 0)
    SetGlobalPosition(self.Camera.transform, self.CameraStartPos.x, self.CameraStartPos.y, self.CameraStartPos.z)
end

return CreateRoleSceneManager