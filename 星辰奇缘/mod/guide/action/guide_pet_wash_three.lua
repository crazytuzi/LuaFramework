-- -------------------------------
-- 宠物洗髓引导第三部
-- zzl
-- -------------------------------
GuidePetWashThree = GuidePetWashThree or BaseClass(BasePanel)

function GuidePetWashThree:__init(panel)
    self.panel = panel
    self.path = "prefabs/ui/guide/guideanyway.unity3d"
    self.effectPath = "prefabs/effect/20104.unity3d"
    self.effect = nil

    self.resList = {
        {file = self.path, type = AssetType.Main},
        {file = self.effectPath, type = AssetType.Main},
    }

    self.step = 0

    self.next = function() self:Next() end

    self.lastGameObject = nil
end

function GuidePetWashThree:__delete()
    self:GuideEnd()
    if not BaseUtils.is_null(self.effect) then
        GameObject.DestroyImmediate(self.effect)
        self.effect = nil
    end

    if not BaseUtils.is_null(self.gameObject) then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end

    if self.assetWrapper ~= nil then
        self.assetWrapper:DeleteMe()
        self.assetWrapper = nil
    end

    self.panel = nil
    self.lastGameObject = nil
    self.next = nil
end

function GuidePetWashThree:InitPanel()
    self.gameObject = GameObject.Instantiate(self.assetWrapper:GetMainAsset(self.path))
    self.gameObject.name = "GuideAnyWay"
    UIUtils.AddUIChild(self.panel.transform.gameObject, self.gameObject)
    self.transform = self.gameObject.transform
    self.gameObject:SetActive(false)
    self.gameObject:GetComponent(Button).onClick:AddListener(function() self:Next() end)

    self.effect = GameObject.Instantiate(self.assetWrapper:GetMainAsset(self.effectPath))
    self.effect.name = "GuideSkillEffect"
    self.effect.transform:SetParent(TipsManager.Instance.model.tipsCanvas.transform)
    self.effect.transform.localScale = Vector3.one
    Utils.ChangeLayersRecursively(self.effect.transform, "UI")
    self.effect:SetActive(false)

    self.assetWrapper:DeleteMe()
    self.assetWrapper = nil

    self:Next()
end

function GuidePetWashThree:First()
    if BaseUtils.is_null(self.gameObject) then
        return
    end
    
    self.gameObject:SetActive(false)
    self.lastGameObject = self.panel.BtnWashBuyBtn.gameObject
    if BaseUtils.is_null(self.lastGameObject) then
        self:GuideEnd()
        return
    end
    self.effect.transform:SetParent(self.lastGameObject.transform)
    self.effect.transform.localScale = Vector3.one
    self.effect.transform.localPosition = Vector3(0, 0, -400)
    Utils.ChangeLayersRecursively(self.effect.transform, "UI")
    self.panel.BtnWashBuyBtn.guideClickListener = self.next
    self.effect:SetActive(true)
    TipsManager.Instance:ShowGuide({gameObject = self.lastGameObject, data = TI18N("点击开始洗髓"), forward = TipsEumn.Forward.Left})
end

function GuidePetWashThree:Second()
    -- if not self:Check1() then
    --     self:GuideEnd()
    --     return
    -- end
    if BaseUtils.is_null(self.gameObject) then
        return
    end

    self.gameObject:SetActive(false)
    if not BaseUtils.is_null(self.lastGameObject) then

        self.lastGameObject:GetComponent(Button).onClick:RemoveListener(self.next)

    end
    self.lastGameObject = self.panel.BtnReplace.gameObject
    self.effect.transform:SetParent(self.lastGameObject.transform)
    self.effect.transform.localScale = Vector3.one
    self.effect.transform.localPosition = Vector3(0, 0, -400)
    Utils.ChangeLayersRecursively(self.effect.transform, "UI")
    self.effect:SetActive(true)
    self.lastGameObject:GetComponent(Button).onClick:AddListener(self.next)
    TipsManager.Instance:ShowGuide({gameObject = self.lastGameObject, data = TI18N("洗出更好的属性啦，快替换吧"), forward = TipsEumn.Forward.Left})
end

function GuidePetWashThree:Next()
    self.step = self.step + 1
    if self.step == 1 then
        LuaTimer.Add(300, function() self:First() end)
    elseif self.step == 2 then
        LuaTimer.Add(300, function() self:Second() end)
    else
        self:GuideEnd()
    end
end

function GuidePetWashThree:GuideEnd()
    self.panel.model.canGuideThree = false
    self.panel.BtnWashBuyBtn.guideClickListener = nil
    self.gameObject:SetActive(false)
    if not BaseUtils.is_null(self.effect) then
        self.effect.transform:SetParent(TipsManager.Instance.model.tipsCanvas.transform)
        self.effect:SetActive(false)
    end
    TipsManager.Instance:HideGuide()
end
