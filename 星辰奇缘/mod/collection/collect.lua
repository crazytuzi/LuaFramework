-- ---------------------------------------
-- 进度条
-- hosr
-- ---------------------------------------
CollectPanel = CollectPanel or BaseClass(BasePanel)

function CollectPanel:__init()

    self.path = "prefabs/ui/collection/collection.unity3d"
    self.resList = {
        {file = self.path, type = AssetType.Main},
        {file = AssetConfig.collect_textures, type = AssetType.Dep}
    }
    self.timeId = 0
    self.callback = nil
    self.cancelCallBack = nil
    self.unitActionType = nil
    self.OnOpenEvent:Add(function() self:StartUp() end)

    self.running = false

    self.cancelListener = function() self:Cancel() end

    self.currentTime = 0

    -- 特效类型 0：场景特效 1:ui特效
    self.type = 0
    self.id = 0
    self.sound = 0
end

function CollectPanel:__delete()
    ModuleManager.Instance.collectCall = nil
    EventMgr.Instance:RemoveListener(event_name.map_click, self.cancelListener)
    EventMgr.Instance:RemoveListener(event_name.begin_fight, self.cancelListener)
    EventMgr.Instance:RemoveListener(event_name.cancel_colletion, self.cancelListener)

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self:AssetClearAll()
        self.gameObject = nil
    end
end

function CollectPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(self.path))
    self.gameObject.name = "CollectPanel"
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(TipsManager.Instance.model.tipsCanvas, self.gameObject)
    self.transform:SetSiblingIndex(1)
    local rect = self.gameObject:GetComponent(RectTransform)
    rect.anchorMax = Vector2.one
    rect.anchorMin = Vector2.zero
    rect.offsetMin = Vector2.zero
    rect.offsetMax = Vector2.zero

    local panel = self.transform:Find("Panel").gameObject
    panel:GetComponent(Button).onClick:AddListener(function() self:Cancel() end)
    panel:SetActive(false)

    self.mainObj = self.transform:Find("Main").gameObject
    self.slider = self.transform:Find("Main/Slider"):GetComponent(Slider)
    self.icon = self.transform:Find("Main/Slider/Icon"):GetComponent(Image)
    self.txt = self.transform:Find("Main/Text"):GetComponent(Text)
    self.slider.value = 1

    self:StartUp()
end

function CollectPanel:StartUp()
    if self.running then
        return
    end

    self.running = true
    self.slider.value = 0

    SceneManager.Instance.sceneElementsModel.self_data.canIdle = false

    EventMgr.Instance:AddListener(event_name.map_click, self.cancelListener)
    EventMgr.Instance:AddListener(event_name.begin_fight, self.cancelListener)
    EventMgr.Instance:AddListener(event_name.cancel_colletion, self.cancelListener)

    self.msg = self.openArgs.msg
    self.time = self.openArgs.time / 1000
    self.type = self.openArgs.type or 0
    self.id = self.openArgs.id
    self.map = self.openArgs.map
    self.x = self.openArgs.x
    self.y = self.openArgs.y
    self.sound = self.openArgs.sound or 0

    self.currentTime = Time.time
    self.txt.text = self.msg
    self.count = 0

    self.gameObject:SetActive(true)
    if SceneManager.Instance.sceneElementsModel.self_view ~= nil then
        if self.unitActionType == nil then
            SceneManager.Instance.sceneElementsModel.self_view:PlayAction(SceneConstData.UnitAction.Pick)
        else
            SceneManager.Instance.sceneElementsModel.self_view:PlayAction(self.unitActionType)
            self.unitActionType = nil
        end
    end
    ModuleManager.Instance.collectCall = function() self:FixedUpdate() end
end

function CollectPanel:TimeOut()
    if self.callback ~= nil then
        self.callback()
    end
    self:Cancel()
end

function CollectPanel:FixedUpdate()
    local val = Time.time - self.currentTime
    if val >= self.time then
        self.slider.value = 1
        self:TimeOut()
        self:PlayEffect()
        if self.sound ~= nil and self.sound ~= 0 then
            SoundManager.Instance:Play(self.sound)
        end
    else
        self.slider.value = val / self.time
    end
end
-- -----------------------------------------------
-- 在不加遮罩的情况下，以下情况要取消采集
-- 1.进战斗
-- 2.传送
-- 3.点击地面
-- 4.点任务寻路
-- -----------------------------------------------
function CollectPanel:Cancel()
    if not self.running then
        return
    end
    ModuleManager.Instance.collectCall = nil

    SceneManager.Instance.sceneElementsModel.self_data.canIdle = true

    EventMgr.Instance:RemoveListener(event_name.map_click, self.cancelListener)
    EventMgr.Instance:RemoveListener(event_name.begin_fight, self.cancelListener)
    EventMgr.Instance:RemoveListener(event_name.cancel_colletion, self.cancelListener)

    self.running = false
    if SceneManager.Instance.sceneElementsModel.self_view ~= nil and SceneManager.Instance.sceneElementsModel.self_view.lastAction == SceneConstData.UnitAction.Pick then
        SceneManager.Instance.sceneElementsModel.self_view:PlayAction(SceneConstData.UnitAction.Stand)
    end
    LuaTimer.Delete(self.timeId)
    self.timeId = 0
    self.count = 0
    self.currentTime = 0
    self.gameObject:SetActive(false)

    if self.cancelCallBack ~= nil then
        self.cancelCallBack()
        self.cancelCallBack = nil
    end
end

function CollectPanel:PlayEffect()
    if self.id == nil or self.id == 0 then
        return
    end

    local data = {}
    data.id = self.id
    data.time = 5
    data.type = self.type
    data.map = self.map
    data.x = self.x
    data.y = self.y
    EffectBrocastManager.Instance:On9907(data)
end

function CollectPanel.PlayEffectTest(id)
    local data = {}
    data.id = id
    data.time = 5
    data.type = 0
    data.map = 10001
    data.x = 3662
    data.y = 2321
    EffectBrocastManager.Instance:On9907(data)
end
