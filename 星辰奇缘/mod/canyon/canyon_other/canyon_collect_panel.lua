-- 峡谷之巅--操作进度条
-- @author hze
-- @date 2018/07/31

CanYonCollectPanel = CanYonCollectPanel or BaseClass(BasePanel)

function CanYonCollectPanel:__init()
    self.model = CanYonManager.Instance.model
    self.path = "prefabs/ui/collection/collection.unity3d"
    self.resList = {
        {file = self.path, type = AssetType.Main},
        {file = AssetConfig.guildleague_texture, type = AssetType.Dep},
        {file = AssetConfig.collect_textures, type = AssetType.Dep}
    }
    self.timeId = 0
    self.callback = nil
    self.cancelCallBack = nil
    self.unitActionType = nil
    self.typeicon = {
        [1] = "I18NFire",
        [2] = "I18NAttackTower",
        [3] = "I18NDefendTower",
        [4] = "I18NDefending",
    }
    self.OnOpenEvent:Add(function() self:StartUp() end)

    self.running = false

    self.cancelListener = function() self:Cancel() end
    EventMgr.Instance:AddListener(event_name.role_event_change, function()
        if self.running == true then
            self:Cancel()
        end
    end)
    self.currentTime = 0
end

function CanYonCollectPanel:__delete()
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

function CanYonCollectPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(self.path))
    self.gameObject.name = "CanYonCollectPanel"
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

function CanYonCollectPanel:StartUp()
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
    self.currentTime = Time.time
    self.txt.text = self.msg
    self.count = 0
    if self.openArgs.optype ~= nil then
        self.icon.sprite = self.assetWrapper:GetSprite(AssetConfig.guildleague_texture , self.typeicon[self.openArgs.optype])
    end
    -- print("类型"..tostring(self.openArgs.optype))
    if self.openArgs.optype ~= 3 then
        self.gameObject:SetActive(true)
        if SceneManager.Instance.sceneElementsModel.self_view ~= nil then
            if self.unitActionType == nil and self.openArgs.special ~= true then
                SceneManager.Instance.sceneElementsModel.self_view:PlayAction(SceneConstData.UnitAction.Pick)
            else
                SceneManager.Instance.sceneElementsModel.self_view:PlayAction(self.unitActionType)
                self.unitActionType = nil
            end
        end
    else
        self.model:ChangeDefendIcon(true)
        self.gameObject:SetActive(false)
        self:ShowEffect()
    end
    ModuleManager.Instance.collectCall = function() self:FixedUpdate() end
end

function CanYonCollectPanel:TimeOut()
    if self.callback ~= nil then
        self.callback()
    end
    self:Cancel()
end

function CanYonCollectPanel:FixedUpdate()
    local val = Time.time - self.currentTime
    if val >= self.time then
        self.slider.value = 1
        self:TimeOut()
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
function CanYonCollectPanel:Cancel()
    if not self.running then
        return
    end
    self:HideEffect()
    if self.openArgs.optype == 3 then
        self.model:ChangeDefendIcon(false)
    end
    -- NoticeManager.Instance:FloatTipsByString(TI18N("已取消当前操作"))
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

function CanYonCollectPanel:ShowEffect()
    if self.unitEffect == nil then
        local callback = function(effectview)
            if SceneManager.Instance.sceneElementsModel.self_view == nil or BaseUtils.isnull(SceneManager.Instance.sceneElementsModel.self_view.gameObject) then
                self.unitEffect:DeleteMe()
                self.unitEffect = nil
                return
            end
            local trans = SceneManager.Instance.sceneElementsModel.self_view:GetCachedTransform()
            effectview.transform:SetParent(trans)
            effectview.transform.localScale = Vector3.one
            effectview.transform.localPosition = Vector3(0, 1.1, 0)
            effectview.transform.rotation = Quaternion.identity
            effectview.transform:Rotate(Vector3(320, 0, 0))
            Utils.ChangeLayersRecursively(effectview.transform, "Model")
        end
        self.unitEffect = BaseEffectView.New({ effectId = 20190, callback = callback })
    else
        self.unitEffect:SetActive(true)
    end
end


function CanYonCollectPanel:HideEffect()
    if self.unitEffect ~= nil then
        self.unitEffect:SetActive(false)
    end
end