-- ------------------------------
-- 守护装备升级第二部
-- hosr
-- ------------------------------
GuideGuardUpgradeSec = GuideGuardUpgradeSec or BaseClass(BasePanel)

function GuideGuardUpgradeSec:__init(panel)
    self.panel = panel
    self.path = "prefabs/ui/guide/guideanyway.unity3d"
    self.effectPath = "prefabs/effect/20104.unity3d"
    self.effectPath1 = "prefabs/effect/20107.unity3d"
    self.effectPath2 = "prefabs/effect/20103.unity3d"
    self.effect = nil
    self.effect1 = nil
    self.effect2 = nil

    self.resList = {
        {file = self.path, type = AssetType.Main},
        {file = self.effectPath, type = AssetType.Main},
        {file = self.effectPath1, type = AssetType.Main},
        {file = self.effectPath2, type = AssetType.Main},
    }

    self.step = 0

    self.next = function() self:Next() end

    self.lastGameObject = nil
end

function GuideGuardUpgradeSec:__delete()
    self:GuideEnd()
    if not BaseUtils.is_null(self.effect) then
        GameObject.DestroyImmediate(self.effect)
        self.effect = nil
    end

    if not BaseUtils.is_null(self.effect1) then
        GameObject.DestroyImmediate(self.effect1)
        self.effect1 = nil
    end

    if not BaseUtils.is_null(self.effect2) then
        GameObject.DestroyImmediate(self.effect2)
        self.effect2 = nil
    end

    if not BaseUtils.is_null(self.gameObject) then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end

    if self.assetWrapper ~= nil then
        self.assetWrapper:DeleteMe()
        self.assetWrapper = nil
    end

    self.lastGameObject = nil
    self.next = nil
    self.panel = nil
end

function GuideGuardUpgradeSec:InitPanel()
    self.gameObject = GameObject.Instantiate(self.assetWrapper:GetMainAsset(self.path))
    self.gameObject.name = "GuideAnyWay"
    UIUtils.AddUIChild(self.panel.gameObject, self.gameObject)
    self.transform = self.gameObject.transform
    self.gameObject:SetActive(false)
    self.gameObject:GetComponent(Button).onClick:AddListener(function() self:Next() end)

    self.effect = GameObject.Instantiate(self.assetWrapper:GetMainAsset(self.effectPath))
    self.effect.name = "GuideSkillEffect"
    self.effect.transform:SetParent(TipsManager.Instance.model.tipsCanvas.transform)
    self.effect.transform.localScale = Vector3.one
    Utils.ChangeLayersRecursively(self.effect.transform, "UI")
    self.effect:SetActive(false)

    self.effect1 = GameObject.Instantiate(self.assetWrapper:GetMainAsset(self.effectPath1))
    self.effect1.name = "GuideSkillEffect1"
    self.effect1.transform:SetParent(TipsManager.Instance.model.tipsCanvas.transform)
    self.effect1.transform.localScale = Vector3.one
    Utils.ChangeLayersRecursively(self.effect1.transform, "UI")
    self.effect1:SetActive(false)

    self.effect2 = GameObject.Instantiate(self.assetWrapper:GetMainAsset(self.effectPath2))
    self.effect2.name = "GuideSkillEffect2"
    self.effect2.transform:SetParent(TipsManager.Instance.model.tipsCanvas.transform)
    self.effect2.transform.localScale = Vector3.one
    Utils.ChangeLayersRecursively(self.effect2.transform, "UI")
    self.effect2:SetActive(false)

    self.assetWrapper:DeleteMe()
    self.assetWrapper = nil

    self:Next()
end

function GuideGuardUpgradeSec:First()
    self.gameObject:SetActive(false)
    self.lastGameObject = self.panel.BtnOpenRight.gameObject

    self.effect.transform:SetParent(self.lastGameObject.transform)
    self.effect.transform.localScale = Vector3.one
    self.effect.transform.localPosition = Vector3(0, 0, -400)
    Utils.ChangeLayersRecursively(self.effect.transform, "UI")
    self.effect:SetActive(true)
    self.lastGameObject:GetComponent(Button).onClick:AddListener(self.next)
    TipsManager.Instance:ShowGuide({gameObject = self.lastGameObject, data = TI18N("点击打开守护装备升级界面"), forward = TipsEumn.Forward.Left})
end

function GuideGuardUpgradeSec:Senond()
    self.gameObject:SetActive(false)
    self.effect:SetActive(false)
    if not BaseUtils.is_null(self.lastGameObject) then
        self.lastGameObject:GetComponent(Button).onClick:RemoveListener(self.next)
    end

    self.lastGameObject = self.panel.BtnUpdate.gameObject
    self.effect1.transform:SetParent(self.lastGameObject.transform)
    self.effect1.transform.localScale = Vector3.one
    self.effect1.transform.localPosition = Vector3(0, 0, -400)
    self.effect1:SetActive(true)
    Utils.ChangeLayersRecursively(self.effect1.transform, "UI")
    self.lastGameObject:GetComponent(Button).onClick:AddListener(self.next)
    TipsManager.Instance:ShowGuide({gameObject = self.lastGameObject, data = TI18N("点击升级守护装备"), forward = TipsEumn.Forward.Left})
end

function GuideGuardUpgradeSec:Third()
    if RoleManager.Instance.RoleData.coin < 30000 then
        self:GuideEnd()
        return
    end

    self.effect1:SetActive(false)
    self.effect:SetActive(false)
    self.gameObject:SetActive(false)
    if not BaseUtils.is_null(self.lastGameObject) then
        self.lastGameObject:GetComponent(Button).onClick:RemoveListener(self.next)
    end

    self.lastGameObject = self.panel.BtnSet.gameObject
    self.effect.transform:SetParent(self.lastGameObject.transform)
    self.effect.transform.localScale = Vector3.one
    self.effect.transform.localPosition = Vector3(0, 0, -400)
    Utils.ChangeLayersRecursively(self.effect.transform, "UI")
    self.effect:SetActive(true)
    self.lastGameObject:GetComponent(Button).onClick:AddListener(self.next)
    TipsManager.Instance:ShowGuide({gameObject = self.lastGameObject, data = TI18N("点击打开守护装备宝石镶嵌界面"), forward = TipsEumn.Forward.Left})
end

function GuideGuardUpgradeSec:Four()
    if RoleManager.Instance.RoleData.coin < 30000 then
        self:GuideEnd()
        return
    end

    self.effect1:SetActive(false)
    self.effect:SetActive(false)
    self.gameObject:SetActive(false)
    if not BaseUtils.is_null(self.lastGameObject) then
        self.lastGameObject:GetComponent(Button).onClick:RemoveListener(self.next)
    end

    self.lastGameObject = self.panel.stone_btn_update.gameObject
    self.effect1.transform:SetParent(self.lastGameObject.transform)
    self.effect1.transform.localScale = Vector3.one
    self.effect1.transform.localPosition = Vector3(0, 0, -400)
    Utils.ChangeLayersRecursively(self.effect1.transform, "UI")
    self.effect1:SetActive(true)
    self.lastGameObject:GetComponent(Button).onClick:AddListener(self.next)
    TipsManager.Instance:ShowGuide({gameObject = self.lastGameObject, data = TI18N("点击消耗银币镶嵌宝石（拆除不返还银币）"), forward = TipsEumn.Forward.Left})
end

function GuideGuardUpgradeSec:Five()
    self.gameObject:SetActive(false)
    self.effect:SetActive(false)
    self.effect1:SetActive(false)
    if not BaseUtils.is_null(self.lastGameObject) then
        self.lastGameObject:GetComponent(Button).onClick:RemoveListener(self.next)
    end

    self.lastGameObject = self.panel.closeBtn.gameObject
    self.effect2.transform:SetParent(self.lastGameObject.transform)
    self.effect2.transform.localScale = Vector3.one
    self.effect2.transform.localPosition = Vector3(-30, -30, -400)
    self.effect2:SetActive(true)
    Utils.ChangeLayersRecursively(self.effect2.transform, "UI")
    self.lastGameObject:GetComponent(Button).onClick:AddListener(self.next)
    TipsManager.Instance:ShowGuide({gameObject = self.lastGameObject, data = TI18N("点击关闭界面"), forward = TipsEumn.Forward.Left})
end

function GuideGuardUpgradeSec:Next()
    self.step = self.step + 1
    if self.step == 1 then
        self:First()
    elseif self.step == 2 then
        LuaTimer.Add(200, function() self:Senond() end)
    elseif self.step == 3 then
        LuaTimer.Add(200, function() self:Third() end)
    elseif self.step == 4 then
        LuaTimer.Add(200, function() self:Four() end)
    elseif self.step == 5 then
        self:Five()
    else
        if self.panel.model.main_win ~= nil then
            self.panel.model.main_win:GuideExtra()
        end
        self:GuideEnd()
    end
end

function GuideGuardUpgradeSec:GuideEnd()
    if not BaseUtils.is_null(self.lastGameObject) then
        self.lastGameObject:GetComponent(Button).onClick:RemoveListener(self.next)
    end
    if not BaseUtils.is_null(self.gameObject) then
        self.gameObject:SetActive(false)
    end
    if not BaseUtils.is_null(self.effect) then
        self.effect.transform:SetParent(TipsManager.Instance.model.tipsCanvas.transform)
        self.effect:SetActive(false)
    end
    if not BaseUtils.is_null(self.effect1) then
        self.effect1.transform:SetParent(TipsManager.Instance.model.tipsCanvas.transform)
        self.effect1:SetActive(false)
    end
    if not BaseUtils.is_null(self.effect2) then
        self.effect2.transform:SetParent(TipsManager.Instance.model.tipsCanvas.transform)
        self.effect2:SetActive(false)
    end
end
