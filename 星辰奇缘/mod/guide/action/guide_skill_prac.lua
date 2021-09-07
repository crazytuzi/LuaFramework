-- ----------------------------
-- 冒险技能引导
-- hosr
-- ----------------------------
GuideSkillPrac = GuideSkillPrac or BaseClass(BasePanel)

function GuideSkillPrac:__init(panel)
    self.panel = panel
    self.path = "prefabs/ui/guide/guideanyway.unity3d"
    self.effectPath = "prefabs/effect/20104.unity3d"
    self.effectPath1 = "prefabs/effect/20103.unity3d"
    self.effect = nil
    self.effect1 = nil

    self.resList = {
        {file = self.path, type = AssetType.Main},
        {file = self.effectPath, type = AssetType.Main},
        {file = self.effectPath1, type = AssetType.Main},
    }

    self.step = 0

    self.next = function() self:Next() end
    self.toggleNext = function(a) self:Next() end

    self.lastGameObject = nil
end

function GuideSkillPrac:__delete()
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

    if not BaseUtils.is_null(self.panel.oneTimeBtn) then
        self.panel.oneTimeBtn:GetComponent(Button).onClick:RemoveListener(self.next)
    end

    if not BaseUtils.is_null(self.panel.useItemBtn) then
        self.panel.useItemBtn:GetComponent(Button).onClick:RemoveListener(self.next)
    end

    if not BaseUtils.is_null(self.panel.iconlist[4]) then
        self.panel.iconlist[4]:GetComponent(Button).onClick:RemoveListener(self.next)
    end

    if not BaseUtils.is_null(self.panel.toggle.gameObject) then
        self.panel.toggle.gameObject:GetComponent(Toggle).onValueChanged:RemoveListener(self.toggleNext)
    end


    if self.assetWrapper ~= nil then
        self.assetWrapper:DeleteMe()
        self.assetWrapper = nil
    end

    self.lastGameObject = nil
    self.next = nil
    self.toggleNext = nil
    self.panel = nil
end

function GuideSkillPrac:InitPanel()
    self.gameObject = GameObject.Instantiate(self.assetWrapper:GetMainAsset(self.path))
    self.gameObject.name = "GuideAnyWay"
    UIUtils.AddUIChild(self.panel.transform.parent.parent.gameObject, self.gameObject)
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

function GuideSkillPrac:First()
    self.gameObject:SetActive(false)
    self.lastGameObject = self.panel.oneTimeBtn.gameObject

    if BaseUtils.is_null(self.lastGameObject) then
        self:GuideEnd()
        return
    end

    self.effect.transform:SetParent(self.lastGameObject.transform)
    self.effect.transform.localScale = Vector3.one
    self.effect.transform.localPosition = Vector3(0, 0, -400)
    Utils.ChangeLayersRecursively(self.effect.transform, "UI")
    self.panel.oneTimeBtn.onClick:AddListener(self.next)
    self.effect:SetActive(true)
    TipsManager.Instance:ShowGuide({gameObject = self.lastGameObject, data = TI18N("点这里消耗银币升级冒险技能"), forward = TipsEumn.Forward.Left})
end

function GuideSkillPrac:Senond()
    if not BaseUtils.is_null(self.lastGameObject) then
        self.lastGameObject:GetComponent(Button).onClick:RemoveListener(self.next)
    end

    self.lastGameObject = self.panel.useItemBtn.gameObject
    if BaseUtils.is_null(self.lastGameObject) then
        return
    end

    self.effect.transform:SetParent(self.lastGameObject.transform)
    self.effect.transform.localScale = Vector3.one
    self.effect.transform.localPosition = Vector3(0, 0, -400)
    self.effect:SetActive(true)
    Utils.ChangeLayersRecursively(self.effect.transform, "UI")
    self.lastGameObject:GetComponent(Button).onClick:AddListener(self.next)
    TipsManager.Instance:ShowGuide({gameObject = self.lastGameObject, data = TI18N("点这里可消耗冒险笔记升级冒险技能"), forward = TipsEumn.Forward.Left})
    self.gameObject:SetActive(false)
end

function GuideSkillPrac:Third()
    if not BaseUtils.is_null(self.effect) then
        self.effect:SetActive(false)
    end

    if BaseUtils.is_null(self.gameObject) then
        return
    end

    self.gameObject:SetActive(false)
    if not BaseUtils.is_null(self.lastGameObject) then
        self.lastGameObject:GetComponent(Button).onClick:RemoveListener(self.next)
    end

    self.lastGameObject = self.panel.iconlist[4]
    if BaseUtils.is_null(self.lastGameObject) then
        return
    end

    self.effect1.transform:SetParent(self.lastGameObject.transform)
    self.effect1.transform.localScale = Vector3.one
    self.effect1.transform.localPosition = Vector3(0, 0, -400)
    Utils.ChangeLayersRecursively(self.effect1.transform, "UI")
    self.effect1:SetActive(true)
    self.lastGameObject:GetComponent(Button).onClick:AddListener(self.next)
    TipsManager.Instance:ShowGuide({gameObject = self.lastGameObject, data = TI18N("点击选择攻法指挥"), forward = TipsEumn.Forward.Right})
end

function GuideSkillPrac:Four()
    if not BaseUtils.is_null(self.effect) then
        self.effect:SetActive(false)
    end

    if BaseUtils.is_null(self.gameObject) then
        return
    end

    self.gameObject:SetActive(false)
    if not BaseUtils.is_null(self.lastGameObject) then
        self.lastGameObject:GetComponent(Button).onClick:RemoveListener(self.next)
    end

    self.lastGameObject = self.panel.toggle.gameObject
    if BaseUtils.is_null(self.lastGameObject) then
        return
    end

    self.effect1.transform:SetParent(self.lastGameObject.transform)
    self.effect1.transform.localScale = Vector3.one
    self.effect1.transform.localPosition = Vector3(0, 0, -400)
    self.effect1:SetActive(true)
    Utils.ChangeLayersRecursively(self.effect1.transform, "UI")
    self.panel.toggle.onValueChanged:AddListener(self.toggleNext)
    TipsManager.Instance:ShowGuide({gameObject = self.lastGameObject, data = TI18N("设为默认后，获得的冒险经验自动提升该技能"), forward = TipsEumn.Forward.Right})
end

function GuideSkillPrac:Next()
    self.step = self.step + 1
    if self.step == 1 then
        self:First()
    elseif self.step == 2 then
        self:Senond()
    elseif self.step == 3 then
        self:Third()
    elseif self.step == 4 then
        self:Four()
    else
        self:GuideEnd()
    end
end

function GuideSkillPrac:GuideEnd()
    if not BaseUtils.is_null(self.lastGameObject) then
        self.lastGameObject:GetComponent(Toggle).onValueChanged:RemoveListener(self.toggleNext)
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
    TipsManager.Instance:HideGuide()
end
