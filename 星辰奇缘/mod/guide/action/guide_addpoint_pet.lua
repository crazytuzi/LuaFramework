-- -------------------------------------
-- 宠物加点引导
-- hosr
-- -------------------------------------
GiudeAddpointPet = GiudeAddpointPet or BaseClass(BasePanel)

function GiudeAddpointPet:__init(panel)
    self.panel = panel
    self.path = "prefabs/ui/guide/guideanyway.unity3d"
    self.effectPath = "prefabs/effect/20103.unity3d"
    self.effectPath1 = "prefabs/effect/20104.unity3d"
    self.effect = nil
    self.effect1 = nil

    self.resList = {
        {file = self.path, type = AssetType.Main},
        {file = self.effectPath, type = AssetType.Main},
        {file = self.effectPath1, type = AssetType.Main},
    }

    self.step = 0

    self.next = function() self:Next() end

    self.lastGameObject = nil
end

function GiudeAddpointPet:__delete()
    self:GuideEnd()
    if not BaseUtils.is_null(self.effect) then
        GameObject.DestroyImmediate(self.effect)
        self.effect = nil
    end

    if not BaseUtils.is_null(self.effect1) then
        GameObject.DestroyImmediate(self.effect1)
        self.effect1 = nil
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

function GiudeAddpointPet:InitPanel()
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
    self.effect1.name = "GuideSkilleffect1"
    self.effect1.transform:SetParent(TipsManager.Instance.model.tipsCanvas.transform)
    self.effect1.transform.localScale = Vector3.one
    Utils.ChangeLayersRecursively(self.effect1.transform, "UI")
    self.effect1:SetActive(false)

    self.assetWrapper:DeleteMe()
    self.assetWrapper = nil

    self:Next()
end

function GiudeAddpointPet:First()
    self.effect:SetActive(false)
    self.effect1:SetActive(false)
    self.gameObject:SetActive(false)

    self.lastGameObject = self.panel.autoBtn
    if BaseUtils.is_null(self.lastGameObject) then
        self:GuideEnd()
        return
    end

    self.effect1.transform:SetParent(self.lastGameObject.transform)
    self.effect1.transform.localScale = Vector3.one
    self.effect1.transform.localPosition = Vector3(0, 0, -400)
    Utils.ChangeLayersRecursively(self.effect1.transform, "UI")
    self.lastGameObject:GetComponent(Button).onClick:AddListener(self.next)
    self.effect1:SetActive(true)
    TipsManager.Instance:ShowGuide({gameObject = self.lastGameObject, data = TI18N("点这里，按默认加点方式加点"), forward = TipsEumn.Forward.Left})
end

function GiudeAddpointPet:Senond()
    self.effect:SetActive(false)
    self.effect1:SetActive(false)
    self.gameObject:SetActive(false)

    if not BaseUtils.is_null(self.lastGameObject) then
        self.lastGameObject:GetComponent(Button).onClick:RemoveListener(self.next)
    end

    self.lastGameObject = self.panel.sureBtn
    self.effect1.transform:SetParent(self.lastGameObject.transform)
    self.effect1.transform.localScale = Vector3.one
    self.effect1.transform.localPosition = Vector3(0, 0, -400)
    self.effect1:SetActive(true)
    Utils.ChangeLayersRecursively(self.effect1.transform, "UI")
    self.lastGameObject:GetComponent(Button).onClick:AddListener(self.next)
    TipsManager.Instance:ShowGuide({gameObject = self.lastGameObject, data = TI18N("点这里，确认实施已选择的加点计划"), forward = TipsEumn.Forward.Left})
    self.gameObject:SetActive(false)
end

function GiudeAddpointPet:Third()
    self.effect:SetActive(false)
    self.effect1:SetActive(false)
    self.gameObject:SetActive(false)
    if not BaseUtils.is_null(self.lastGameObject) then
        self.lastGameObject:GetComponent(Button).onClick:RemoveListener(self.next)
    end

    self.lastGameObject = self.panel.setBtn
    self.effect.transform:SetParent(self.lastGameObject.transform)
    self.effect.transform.localScale = Vector3.one
    self.effect.transform.localPosition = Vector3(0, 0, -400)
    Utils.ChangeLayersRecursively(self.effect.transform, "UI")
    self.effect:SetActive(true)
    self.lastGameObject:GetComponent(Button).onClick:AddListener(self.next)
    TipsManager.Instance:ShowGuide({gameObject = self.lastGameObject, data = TI18N("可以在这里设置智能加点方式哦"), forward = TipsEumn.Forward.Left})
    -- self.gameObject:SetActive(true)
end

function GiudeAddpointPet:Next()
    self.step = self.step + 1
    if self.step == 1 then
        self:First()
    elseif self.step == 2 then
        self:Senond()
    -- elseif self.step == 3 then
        -- self:Third()
    else
        DramaManager.Instance:Send11023(DramaEumn.OnceGuideType.PetAddpoint)
        self:GuideEnd()
    end
end

function GiudeAddpointPet:GuideEnd()
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
end
